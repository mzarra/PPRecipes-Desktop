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
    }

}

