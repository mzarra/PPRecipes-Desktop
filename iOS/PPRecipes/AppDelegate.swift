//
//  AppDelegate.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import UIKit

let kInsertCellIdentifier = "kInsertCellIdentifier"
let kCellIdentifier = "kCellIdentifier"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var fileToOpenURL: NSURL?
  var dataController: PPRDataController?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    dataController = PPRDataController() {
      self.contextInitialized()
    }
    guard let navController = window?.rootViewController as? UINavigationController else {
      fatalError("Root view controller is not a navigation controller")
    }
    guard let controller = navController.topViewController as? PPRMasterViewController else {
      fatalError("Top view controller is not a master view controller")
    }

    controller.managedObjectContext = dataController?.mainContext

    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    dataController?.saveContext()
  }

  func applicationDidEnterBackground(application: UIApplication) {
    dataController?.saveContext()
  }

  func applicationWillTerminate(application: UIApplication) {
    dataController?.saveContext()
  }

  //START:contextInitialized
  func contextInitialized() {
    if let url = self.fileToOpenURL {
      self.consumeIncomingFileURL(url)
    }
  }
  //END:contextInitialized

  //START:consumeIncomingFileURL
  func consumeIncomingFileURL(url: NSURL) {
    guard let data = NSData(contentsOfURL: url) else {
      print("No data loaded")
      return
    }
    guard let moc = dataController?.mainContext else {
      fatalError("mainContext is nil")
    }
    let op = PPRImportOperation(data: data, context: moc, handler: {
      (incomingError) in
      if let error = incomingError {
        print("Error importing data: \(error)")
        //Present an error to the user
      } else {
        //Clear visual feedback
      }
    })
    NSOperationQueue.mainQueue().addOperation(op)
    //Give visual feedback of the import
  }
  //END:consumeIncomingFileURL

  //START:openURL
  func application(application: UIApplication, openURL url: NSURL,
    sourceApplication: String?, annotation: AnyObject) -> Bool {
    guard let controller = dataController else {
      fileToOpenURL = url
      return true
    }
    if controller.persistenceInitialized {
      consumeIncomingFileURL(url)
    } else {
      fileToOpenURL = url
    }
    return true
  }
  //END:openURL

}