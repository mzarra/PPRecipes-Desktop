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
    let dataController = PPRDataController() {
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
//        guard let window = NSApplication.sharedApplication().mainWindow else {
//            print("mainWindow is nil")
//        }
//        guard let controller = window.windowController else {
//            print("windowController is nil")
//        }
//        if let view = controller.contentViewController as? ViewController {
//            view.dataController = dataController
//        } else {
//            print("did not inject dataController")
//        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        dataController.saveContext()
    }

    @IBAction func addImage(sender: AnyObject) {
    }

}

