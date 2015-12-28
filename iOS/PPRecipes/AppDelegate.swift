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

  //START:newAppDidFinish
  func application(application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [NSObject: AnyObject]?) -> Bool {
    dataController = PPRDataController() {
      (inError) in
      if let error = inError {
        self.displayError(error)
      } else {
        self.contextInitialized()
      }
    }
    //END:newAppDidFinish
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

  //START: criticalErrorDisplay
  func displayError(error: NSError) {
    var message = "The recipes database is either corrupt or was created by a"
    message += " newer version of Grokking Recipes. Please contact support to"
    message += " assist with this error. \n\(error.localizedDescription)"
    let alert = UIAlertController(title: "Error", message: message,
      preferredStyle: .Alert)
    let close = UIAlertAction(title: "Close", style: .Cancel, handler: {
      (action) in
      //Probably terminate the application
    })
    alert.addAction(close)
    if let controller = window?.rootViewController {
      controller.presentViewController(alert, animated: true, completion: nil)
    }
  }
  //END: criticalErrorDisplay

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