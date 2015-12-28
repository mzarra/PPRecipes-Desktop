//
//  RecipeIngredientToIngredient.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/14/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import CoreData

class RecipeIngredientToIngredient: NSEntityMigrationPolicy {

  //START:createDestinationInstancesForSourceInstance1
  override func createDestinationInstancesForSourceInstance(src: NSManagedObject,
    entityMapping mapping: NSEntityMapping,
    manager: NSMigrationManager) throws {
    let destMOC = manager.destinationContext
    guard let dEntityName = mapping.destinationEntityName else {
      fatalError("Destination entity name is nil")
    }

    guard let name = src.valueForKey("name") as? String else {
      fatalError("Source object did not have a value for 'name'")
    }
    //END:createDestinationInstancesForSourceInstance1

    //START:createDestinationInstancesForSourceInstance2
    var userInfo: [NSObject:AnyObject]
    if let managerUserInfo = manager.userInfo {
      userInfo = managerUserInfo
    } else {
      userInfo = [NSObject:AnyObject]()
    }

    var ingredientLookup: [String:NSManagedObject]!
    if let lookup = userInfo["ingredients"] as? [String:NSManagedObject] {
      ingredientLookup = lookup
    } else {
      ingredientLookup = [String:NSManagedObject]()
      userInfo["ingredients"] = ingredientLookup
    }

    var uofmLookup: [String:NSManagedObject]!
    if let lookup = userInfo["unitOfMeasure"] as? [String:NSManagedObject] {
      uofmLookup = lookup
    } else {
      uofmLookup = [String:NSManagedObject]()
      userInfo["unitOfMeasure"] = uofmLookup
    }
    //END:createDestinationInstancesForSourceInstance2

    //START:createDestinationInstancesForSourceInstance3
    var dest = ingredientLookup[name]
    if dest == nil {
      dest = NSEntityDescription.insertNewObjectForEntityForName(dEntityName,
        inManagedObjectContext: destMOC)
      dest!.setValue(name, forKey:"name")
      ingredientLookup[name] = dest

      guard let uofmName = src.valueForKey("unitOfMeasure") as? String else {
        fatalError("Unit of Measure name is nil")
      }
      var uofm = uofmLookup[uofmName]
      if uofm == nil {
        let eName = "UnitOfMeasure"
        uofm = NSEntityDescription.insertNewObjectForEntityForName(eName,
          inManagedObjectContext: destMOC)
        uofm!.setValue(uofmName, forKey:"name")
        dest!.setValue(uofm, forKey:"unitOfMeasure")
        uofmLookup[name] = uofm
      }
    }
    //END:createDestinationInstancesForSourceInstance3
    //START:createDestinationInstancesForSourceInstance4
    manager.userInfo = userInfo
  }
  //END:createDestinationInstancesForSourceInstance4

  //START:createRelationshipsForDestinationInstance
  override func createRelationshipsForDestinationInstance(dest: NSManagedObject,
    entityMapping mapping: NSEntityMapping,
    manager: NSMigrationManager) throws {
  }
  //END:createRelationshipsForDestinationInstance
}
