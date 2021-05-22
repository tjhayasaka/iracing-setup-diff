const { contextBridge, ipcRenderer } = require('electron')

let storedSetupDirectory = "/home/hayasaka/new/i/iracing/setups";

async function openSetupDirectoryChooser(app)
{
  const directory = await ipcRenderer.invoke("openSetupDirectoryChooser");
  if (directory) {
    storedSetupDirectory = "" + directory;
    app.ports.doneGetStoredSetupDirectory.send(storedSetupDirectory);
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
  app.ports.doneGetStoredSetupDirectory.send(storedSetupDirectory);
  //app.ports.doneGetStoredSetupDirectoryError.send("not implemented");
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

function readExportedSetupFiles_(setupDirectory, relativeDirectory)
{
  const fs = require('fs');
  const directory = setupDirectory + relativeDirectory;
  try {
    const result = fs.readdirSync(directory).flatMap(basename => {
      const localFilename = directory + basename
      const stat = fs.lstatSync(localFilename)
      const isDirectory = stat.isDirectory()
      const isFile = stat.isFile()
      if (isDirectory) {
        return readExportedSetupFiles_(setupDirectory, relativeDirectory + basename + "/");
      } else if (isFile) {
        const commonProps = { basename: basename, filename: relativeDirectory.replace("/", "") + basename };
        if (basename == "-Current-")
          return [{ ignored: { ...commonProps, ...{ what: "binary setup file" } } }];
        if (basename.endsWith(".sto"))
          return [{ ignored: { ...commonProps, ...{ what: "binary setup file" } } }];
        if (basename.endsWith(".htm"))
          return [{ exportedSetupFile: { ...commonProps, ...{ setupHtml: fs.readFileSync(localFilename, "utf8") } } }];
        return [{ ignored: { ...commonProps, ...{ what: "unknown file type" } } }];
      } else
        return [{ ignored: { ...commonProps, ...{ what: "unknown directory entry type" } } }];
    });
    return result;
  }
  catch (ex) {
    console.error(ex.name + ': ' + ex.message);
    const commonProps = { basename: "", filename: directory };
    return [{ error: { ...commonProps, ...{ what: "caught exception: " + ex.name + ": " + ex.message } } }];
  }
}

function readExportedSetupFiles(app, directory)
{
  const result = readExportedSetupFiles_(directory, "/");
  app.ports.doneReadExportedSetupFiles.send(JSON.stringify(result));
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
  }
})
