const { contextBridge, ipcRenderer } = require('electron')

let pidReadExportedSetupFiles = 0;

const storageKeyStoredSetupDirectory = "setupDirectory";

async function openSetupDirectoryChooser(app)
{
  const directory = await ipcRenderer.invoke("openSetupDirectoryChooser");
  if (directory) {
    const storedSetupDirectory = "" + directory;
    localStorage.setItem(storageKeyStoredSetupDirectory, storedSetupDirectory);
    app.ports.doneSetStoredSetupDirectory.send(storedSetupDirectory);
  }
}

async function getDefaultSetupDirectory(app)
{
  const Registry = require("winreg");
  let registry = new Registry({
    hive: Registry.HKCU,
    key: "\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders"
  });
  registry.values(function (err, items) {
    if (err) {
      const message = "couldn't retrieve registry '" + registry.key + "' from HKCU: " + err
      console.log(message);
      app.ports.doneGetDefaultSetupDirectoryError.send(message);
      return;
    }

    let r = null;
    for (let i = 0; i < items.length; i++) {
      if (items[i].name === "Personal") {
        r = items[i].value;
        break;
      }
    }

    if (!r) {
      const message = "couldn't find 'Personal' in registry '" + registry.key + "' from HKCU"
      console.log(message);
      app.ports.doneGetDefaultSetupDirectoryError.send(message);
      return;
    }

    const path = require('path');
    r = path.join(r, "iRacing/setups").replaceAll("%USERPROFILE%", process.env.USERPROFILE || "envvar_%USERPROFILE%_does_not_exist");
    console.log("defaultSetupDirectory = " + r);
    app.ports.doneGetDefaultSetupDirectory.send(r);
  });
}

function getStoredSetupDirectory(app)
{
  try {
    const storedSetupDirectory = localStorage.getItem(storageKeyStoredSetupDirectory);
    if (storedSetupDirectory)
      app.ports.doneGetStoredSetupDirectory.send(storedSetupDirectory);
    else
      app.ports.doneGetStoredSetupDirectoryError.send("couldn't find '" + storageKeyStoredSetupDirectory + "' in localStorage");
  }
  catch (ex) {
    console.error(ex.name + ': ' + ex.message);
    const message = "" + ex.name + ': ' + ex.message;
    console.log(message)
    app.ports.doneGetStoredSetupDirectoryError.send(message);
  }
}

function getSetupDirectory_(directory)
{
  if (!directory)
    return null;
  const fs = require('fs');
  try {
    const stat = fs.lstatSync(directory)
    const isDirectory = stat.isDirectory()
    return isDirectory ? directory : null;
  }
  catch (ex) {
    return null;
  }
}

function getSetupDirectory(app, defaultSetupDirectory, storedSetupDirectory)
{
  directory = getSetupDirectory_(storedSetupDirectory) || defaultSetupDirectory;
  app.ports.doneGetSetupDirectory.send(directory);
}

async function readExportedSetupFiles_(app, pid, setupDirectory, relativeDirectory)
{
  app.ports.progress.send(0);
  const sleep = msec => new Promise(resolve => setTimeout(resolve, msec));
  await sleep(0); // allow elm to render views
  const fs = require('fs');
  const directory = setupDirectory + relativeDirectory;
  try {
    const processOne = async basename => {
      if (pid != pidReadExportedSetupFiles)
        return [];
      const localFilename = directory + basename;
      const stat = fs.lstatSync(localFilename);
      const isDirectory = stat.isDirectory();
      const isFile = stat.isFile();
      const commonProps = { basename: basename, filename: relativeDirectory.replace("/", "") + basename };
      if (isDirectory) {
        const _ = await readExportedSetupFiles_(app, pid, setupDirectory, relativeDirectory + basename + "/");
        return [];
      } else if (isFile) {
        if (basename == "-Current-")
          return [{ ignored: { ...commonProps, ...{ what: "" } } }]; // "binary setup file"
        if (basename.endsWith(".sto"))
          return [{ ignored: { ...commonProps, ...{ what: "" } } }]; // "binary setup file"
        if (basename.endsWith(".htm"))
          return [{ exportedSetupFile: { ...commonProps, ...{ setupHtml: fs.readFileSync(localFilename, "utf8") } } }];
        return [{ ignored: { ...commonProps, ...{ what: "unknown file type" } } }];
      } else
        return [{ ignored: { ...commonProps, ...{ what: "unknown directory entry type" } } }];
    };
    const result_ = await Promise.all(fs.readdirSync(directory).map(processOne));
    const result = result_.flat(Infinity);
    // console.log(result)
    app.ports.partialResultReadExportedSetupFiles.send([pid, JSON.stringify(result)]);
    return;
  }
  catch (ex) {
    console.error(ex.name + ': ' + ex.message);
    const commonProps = { basename: "", filename: directory };
    const result = [{ error: { ...commonProps, ...{ what: "caught exception: " + ex.name + ": " + ex.message } } }];
    app.ports.partialResultReadExportedSetupFiles.send([pid, JSON.stringify(result)]);
    return;
  }
}

async function readExportedSetupFiles(app, directory)
{
  const pid = (pidReadExportedSetupFiles += 1);
  app.ports.startedReadExportedSetupFiles.send(pid);
  // console.log("readExportedSetupFiles: " + pid + ": dir = '" + directory + "': start");
  const result = await readExportedSetupFiles_(app, pidReadExportedSetupFiles, directory, "/");
  if (pid != pidReadExportedSetupFiles) {
    console.log("readExportedSetupFiles: " + pid + ": dir = '" + directory + "': canceled");
    app.ports.doneCancelReadExportedSetupFiles.send(pid);
    return;
  }
  // console.log("readExportedSetupFiles: " + pid + ": dir = '" + directory + "': finish");

  app.ports.doneReadExportedSetupFiles.send(pid);
}

function cancelReadExportedSetupFiles(app, pid)
{
  if (pid == pidReadExportedSetupFiles)
    pidReadExportedSetupFiles += 1;
}

contextBridge.exposeInMainWorld('api', {
  openSetupDirectoryChooser(app) {
    openSetupDirectoryChooser(app);
  },
  getDefaultSetupDirectory(app) {
    getDefaultSetupDirectory(app);
  },
  getStoredSetupDirectory(app) {
    getStoredSetupDirectory(app);
  },
  getSetupDirectory(app, defaultSetupDirectory, storedSetupDirectory) {
    getSetupDirectory(app, defaultSetupDirectory, storedSetupDirectory);
  },
  readExportedSetupFiles(app, directory) {
    readExportedSetupFiles(app, directory);
  },
  cancelReadExportedSetupFiles(app, pid) {
    cancelReadExportedSetupFiles(app, pid);
  }
})
