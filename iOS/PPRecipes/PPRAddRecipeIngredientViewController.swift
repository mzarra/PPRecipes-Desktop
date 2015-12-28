//
//  PPRAddRecipeIngredientViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRAddRecipeIngredientViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var recipeIngredientMO: NSManagedObject!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        guard let ingredientType = recipeIngredientMO.valueForKey("ingredient") else {
            return
        }

        let path = NSIndexPath(forRow: 1, inSection: 0)
        guard let cell = tableView.cellForRowAtIndexPath(path) else {
            return
        }
        cell.textLabel?.text = ingredientType.valueForKeyPath("unitOfMeasure.name") as? String
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { fatalError("Segue without an identifier") }
        let destination = segue.destinationViewController

        switch destination {
        case let controller as PPRTextEditViewController:
            let quantity = recipeIngredientMO.valueForKey("quantity") as! NSNumber
            controller.text = quantity.stringValue
            controller.textChangedClosure = {
                (newText: String) in
                let numberFormatter = NSNumberFormatter()
                guard let quantity = numberFormatter.numberFromString(newText) else {
                    let userInfo = [NSLocalizedDescriptionKey: "Invalid quantity"]
                    throw NSError(domain: "PragProg", code: 1123, userInfo: userInfo)
                }

                let path = NSIndexPath(forRow: 0, inSection: 0)
                let cell = self.tableView.cellForRowAtIndexPath(path)
                cell?.detailTextLabel?.text = newText
                self.recipeIngredientMO.setValue(quantity, forKey: "quantity")
            }
        case let controller as PPRSelectIngredientTypeViewController:
            controller.managedObjectContext = recipeIngredientMO.managedObjectContext
            controller.selectIngredientType = {
                (ingredientType: NSManagedObject) in
                self.recipeIngredientMO.setValue(ingredientType, forKey: "ingredient")

                var path = NSIndexPath(forRow: 1, inSection: 0)
                var cell = self.tableView.cellForRowAtIndexPath(path)
                cell?.detailTextLabel?.text = ingredientType.valueForKey("name") as? String

                path = NSIndexPath(forRow: 0, inSection: 0)
                cell = self.tableView.cellForRowAtIndexPath(path)
                cell?.textLabel?.text = ingredientType.valueForKeyPath("unitOfMeasure.name") as? String
            }
        default:
            print("Unknown identifier: \(identifier)")
        }
    }

    func save(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    func cancel(sender: AnyObject) {
        let moc = recipeIngredientMO.managedObjectContext
        moc?.deleteObject(recipeIngredientMO)
        navigationController?.popViewControllerAnimated(true)
    }
}