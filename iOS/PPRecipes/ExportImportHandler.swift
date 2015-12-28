//
//  ExportImportHandler.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/10/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import CoreData

let PPExportRelationship = "PPExportRelationship"

class PPRExportOperation: NSOperation {
  let parentContext: NSManagedObjectContext
  let recipeID: NSManagedObjectID
  let handler: (data: NSData?, error: NSError?) -> Void

  //START: init
  init(_ aRecipe: PPRRecipeMO, completionHandler aHandler: (data: NSData?,
    error: NSError?) -> Void) {

    guard let moc = aRecipe.managedObjectContext else {
      fatalError("Recipe has no context")
    }
    self.parentContext = moc
    recipeID = aRecipe.objectID
    handler = aHandler
    super.init()
  }
  //END: init

  //START: newMOC
  override func main() {
    let type = NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType
    let localMOC = NSManagedObjectContext(concurrencyType: type)
    localMOC.parentContext = parentContext
    //END: newMOC

    //START: localMO
    localMOC.performBlockAndWait({
      let localRecipe = localMOC.objectWithID(self.recipeID)
      //END: localMO

      //START: mainEnd
      let json = self.moToDictionary(localRecipe)
      do {
        let data = try NSJSONSerialization.dataWithJSONObject(json, options: [])
        dispatch_async(dispatch_get_main_queue()) {
          self.handler(data: data, error: nil)
        }
      } catch let error as NSError {
        dispatch_async(dispatch_get_main_queue()) {
          self.handler(data: nil, error: error)
        }
      }
    })
  }
  //END: mainEnd

  //START:moToDictionary1
  func moToDictionary(mo: NSManagedObject) -> [String:AnyObject] {
    var dict = [String:AnyObject]()
    let entity = mo.entity

    for (key, value) in entity.attributesByName {
      dict[key] = value
    }
    //END:moToDictionary1
    //START:moToDictionary2
    let relationships = entity.relationshipsByName
    for (name, relDesc) in relationships {
      if let skip = relDesc.userInfo?[PPExportRelationship] as? NSString {
        if skip.boolValue {
          continue
        }
      }
      //END:moToDictionary2
      //START:moToDictionary3
      if relDesc.toMany {
        if let children = mo.valueForKey(name) as? [NSManagedObject] {
          var array = [[String:AnyObject]]()
          for childMO in children {
            array.append(moToDictionary(childMO))
          }
          dict[name] = array
        }
      } else {
        if let childMO = mo.valueForKey(name) as? NSManagedObject {
          dict[name] = moToDictionary(childMO)
        }
      }
    }

    return dict
  }
  //END:moToDictionary3
}

class PPRImportOperation: NSOperation {
  let incomingData: NSData
  let parentContext: NSManagedObjectContext

  //START:init
  init(data: NSData, context: NSManagedObjectContext,
    handler: (error: NSError?) -> Void) {
    incomingData = data
    parentContext = context
    super.init()
  }
  //END:init

  override func main() {
    //START:newContextToMainStore
    let type = NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType
    let localMOC = NSManagedObjectContext(concurrencyType: type)
    localMOC.parentContext = parentContext
    //END:newContextToMainStore

    //START:performBlockAndWait
    localMOC.performBlockAndWait({
      do {
        try self.processRecipeIntoContext(localMOC)

        try localMOC.save()
      } catch {
        fatalError("Failed to import: \(error)")
      }
    })
  }
  //END:performBlockAndWait

  //START:convertDataToJSON
  func processRecipeIntoContext(moc: NSManagedObjectContext) throws {
    let json = try NSJSONSerialization.JSONObjectWithData(incomingData,
      options: [])

    guard let entity = NSEntityDescription.entityForName("Recipe",
      inManagedObjectContext: moc) else {
      fatalError("Unable to resolve Recipe")
    }

    switch json {
    case let single as [String:AnyObject]:
      let recipe = NSManagedObject(entity: entity,
        insertIntoManagedObjectContext: moc)
      populateFromDictionary(single, withMO: recipe)
    case let array as [[String:AnyObject]]:
      for recipeJSON in array {
        let recipe = NSManagedObject(entity: entity,
          insertIntoManagedObjectContext: moc)
        populateFromDictionary(recipeJSON, withMO: recipe)
      }
    default: break
    }
  }
  //END:convertDataToJSON

  //START:populateManagedObject1
  func populateFromDictionary(incoming: [String: AnyObject],
    withMO object:NSManagedObject) {

    let entity = object.entity
    for (key, _) in entity.attributesByName {
      object.setValue(incoming[key], forKey:key)
    }
    //END:populateManagedObject1

    //START:populateManagedObject2
    guard let moc = object.managedObjectContext else {
      fatalError("No context available")
    }
    let createChild: (childDict: [String:AnyObject],
      entity:NSEntityDescription,
      moc:NSManagedObjectContext) -> NSManagedObject = {
      (childDict, entity, moc) in
      let destMO = NSManagedObject(entity: entity,
        insertIntoManagedObjectContext: moc)
      self.populateFromDictionary(childDict, withMO: destMO)
      return destMO
    }
    //END:populateManagedObject2

    //START:populateManagedObject3
    for (name, relDesc) in entity.relationshipsByName {
      let childStructure = incoming[name]
      if childStructure == nil {
        continue
      }
      guard let destEntity = relDesc.destinationEntity else {
        fatalError("no destination entity assigned")
      }
      if relDesc.toMany {
        guard let childArray = childStructure as? [[String: AnyObject]] else {
          fatalError("To many relationship with malformed JSON")
        }
        var children = [NSManagedObject]()
        for child in childArray {
          let mo = createChild(childDict: child, entity: destEntity, moc: moc)
          children.append(mo)
        }
        object.setValue(children, forKey: name)
      } else {
        guard let child = childStructure as? [String: AnyObject] else {
          fatalError("To many relationship with malformed JSON")
        }
        let mo = createChild(childDict: child, entity: destEntity, moc: moc)
        object.setValue(mo, forKey: name)
      }
    }
  }
  //END:populateManagedObject3
}



