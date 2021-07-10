// Modules to control application life and create native browser window
const { app, BrowserWindow, Menu, MenuItem, dialog, ipcMain } = require('electron')

if (require('electron-squirrel-startup')) return app.quit();

function createMenu (window)
{
  const updateMenuItem = function (menuItem) {
    // remove "Edit" from the application menu.
    // replace "View/Reload" with custom one.
    // replace "Help" with custom one.

    if (menuItem.role == "editmenu")
      return null;
    if (menuItem.role == "viewmenu") {
      let submenu = new Menu();
      menuItem.submenu.items.forEach(i => {
        if (i.role == "reload") { i.click = () => { window.webContents.send("reload"); } }
        submenu.append(i);
      });
      let newMenuItem = new MenuItem({ id: menuItem.id, role: menuItem.role, label: menuItem.label, submenu: submenu });
      return newMenuItem;
    }
    if (menuItem.role == "help") {
      const template = [
        {
          label: "Help",
          click: () => { window.webContents.send("showInstructionsDialog"); }
        }
      ]
      const submenu = Menu.buildFromTemplate(template)
      let newMenuItem = new MenuItem({ id: menuItem.id, role: menuItem.role, label: menuItem.label, submenu: submenu });
      return newMenuItem;
    }
    return menuItem;
  }

  const oldMenu = Menu.getApplicationMenu()
  let newMenu = new Menu();
  oldMenu.items.map(updateMenuItem).forEach(i => { if (i != null) newMenu.append(i); });
  Menu.setApplicationMenu(newMenu);
}

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow

function createWindow () {
  // Create the browser window.
  mainWindow = new BrowserWindow({
    width: 990,
    height: 960,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false,
      preload: `${__dirname}/preload.js`
    }
  })

  createMenu(mainWindow);

  // and load the index.html of the app.
  mainWindow.loadFile('index.html')

  // Open the DevTools.
  // mainWindow.webContents.openDevTools()

  // Emitted when the window is closed.
  mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
  })
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)


// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On macOS it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') app.quit()
})

app.on('activate', function () {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) createWindow()
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.

ipcMain.handle("openSetupDirectoryChooser",  async (event, message) => {
  const result = await dialog.showOpenDialog(mainWindow, { properties: ['openDirectory'] });
  return result.canceled ? null : result.filePaths;
});
