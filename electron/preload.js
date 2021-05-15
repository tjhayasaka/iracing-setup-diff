const { contextBridge, ipcRenderer } = require('electron')

function getSetupDirectory_(directory)
{
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

function getSetupDirectory()
{
  const d0 = "C:/Users/hayasaka/Documents/iRacing/setups";
  const d1 = "/home/hayasaka/new/i/iracing/setups/";
  return getSetupDirectory_(d0) || getSetupDirectory_(d1) || d0;
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
          return [{ ignored: { ...commonProps, ...{ what: "-Current-" } } }];
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
  app.ports.doneReadSetupFiles.send(JSON.stringify(result));
}

contextBridge.exposeInMainWorld('api', {
  getSetupDirectory() {
    return getSetupDirectory();
  },
  readExportedSetupFiles(app, directory) {
    return readExportedSetupFiles(app, directory);
  }
})
