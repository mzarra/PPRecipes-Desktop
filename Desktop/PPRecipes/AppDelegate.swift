//
//  AppDelegate.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/26/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  //    let dataController = PPRDataController() { (error) in
  //    }

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    //        guard let window = NSApplication.sharedApplication().mainWindow else {
    //            fatalError("mainWindow is nil")
    //        }
    //        guard let controller = window.windowController else {
    //            fatalError("windowController is nil")
    //        }
    //        if let view = controller.contentViewController as? ViewController {
    //            view.dataController = dataController
    //        } else {
    //            fatalError("did not inject dataController")
    //        }
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    //        dataController.saveContext()
  }

  @IBAction func addImage(sender: AnyObject) {
    let openPanel = NSOpenPanel()
    openPanel.canChooseDirectories = false
    openPanel.canCreateDirectories = false
    openPanel.allowsMultipleSelection = false

    guard let window = NSApplication.sharedApplication().mainWindow else {
      fatalError("mainWindow is nil")
    }
    guard let controller = window.windowController?.contentViewController as? ViewController else {
      fatalError("Failed to retrieve view controller")
    }
    guard let recipe = controller.recipeArrayController?.selectedObjects.last else {
      fatalError("No recipe selected")
    }

    openPanel.beginSheetModalForWindow(window) { (result) in
      if result == NSFileHandlingPanelCancelButton { return }
      guard let fileURL = openPanel.URLs.last else {
        fatalError("Failed to retrieve openPanel.URLs")
      }

      let fileManager = NSFileManager.defaultManager()
      let support = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
      let guid = NSProcessInfo.processInfo().globallyUniqueString
      guard let destURL = support.last?.URLByAppendingPathComponent(guid) else {
        fatalError("Failed to construct destination url")
      }

      do {
        try fileManager.copyItemAtURL(fileURL, toURL: destURL)
      } catch {
        fatalError("Failed to copy item: \(error)")
      }

      recipe.setValue(destURL.path, forKey: "imagePath")
    }

  }

}

