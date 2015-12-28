//
//  PPRCreateIngredientTypeViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRCreateIngredientTypeViewController: UITableViewController {
    var ingredientTypeMO: NSManagedObject?

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            fatalError("Unidentified segue")
        }

        switch identifier {
        case "setName":
            guard let controller = segue.destinationViewController as? PPRTextEditViewController else {
                fatalError("Unexpected controller type")
            }
            controller.text = ingredientTypeMO?.valueForKey("name") as? String
            controller.textChangedClosure = { (text: String) in
                let path = NSIndexPath(forRow: 0, inSection: 0)
                let cell = self.tableView.cellForRowAtIndexPath(path)
                cell?.detailTextLabel?.text = text
                self.ingredientTypeMO?.setValue(text, forKey: "name")
            }
        case "setValue":
            guard let controller = segue.destinationViewController as? PPRTextEditViewController else {
                fatalError("Unexpected controller type")
            }
            controller.text = (ingredientTypeMO?.valueForKey("cost") as? NSNumber)?.stringValue
            controller.textChangedClosure = { (text: String) in
                let numberFormatter = NSNumberFormatter()
                guard let value = numberFormatter.numberFromString(text) else {
                    throw NSError(domain: "PragProg", code: 1123, userInfo: [NSLocalizedDescriptionKey : "Invalid value"])
                }

                let path = NSIndexPath(forRow: 1, inSection: 0)
                let cell = self.tableView.cellForRowAtIndexPath(path)
                cell?.detailTextLabel?.text = text
                self.ingredientTypeMO?.setValue(value, forKey: "cost")
            }
        case "selectUnitOfMeasure":
            guard let controller = segue.destinationViewController as? PPRSelectUnitOfMeasureViewController else {
                fatalError("Unexpected controller type")
            }
            controller.selectUnitOfMeasure = { (unit: NSManagedObject) in
                self.ingredientTypeMO?.setValue(unit, forKey: "unitOfMeasure")

                let path = NSIndexPath(forRow: 2, inSection: 0)
                let cell = self.tableView.cellForRowAtIndexPath(path)
                cell?.detailTextLabel?.text = unit.valueForKey("name") as? String
            }
        default:
            print("Unrecognized identifier: \(identifier)")
        }
    }

    func cancel(sender: AnyObject) {
        if let moc = ingredientTypeMO?.managedObjectContext {
            moc.deleteObject(ingredientTypeMO!)
        }
        navigationController?.popViewControllerAnimated(true)
    }

    func save(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}