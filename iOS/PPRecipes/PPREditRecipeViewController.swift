//
//  PPREditRecipeViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPREditRecipeViewController: UITableViewController {
    var recipeMO: PPRRecipeMO?

    func populateTableData() {
        var index = 0

        while index <= 6 {
            let path = NSIndexPath(forRow: index, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(path)
            switch index {
            case 0:
                if let name = recipeMO?.valueForKey("name") as? String {
                    cell?.detailTextLabel?.text = name
                }
            case 1:
                if let type = recipeMO?.valueForKey("type") as? String {
                    cell?.detailTextLabel?.text = type
                }
            case 2:
                if let serves = recipeMO?.valueForKey("serves") as? String {
                    cell?.detailTextLabel?.text = serves
                }
            case 3:
                if let lastUsed = recipeMO?.lastUsedString() {
                    cell?.detailTextLabel?.text = lastUsed
                }
            case 4:
                if let author = recipeMO?.valueForKeyPath("author.name") as? String {
                    cell?.detailTextLabel?.text = author
                }
            case 5:
                guard let textView = cell?.viewWithTag(1123) as? UITextField else {
                    fatalError("Failed to find textField")
                }
                if let desc = recipeMO?.valueForKey("desc") as? String {
                    textView.text = desc
               }
            case 6:
                if let objects = recipeMO?.valueForKey("ingredients") as? [NSManagedObject] {
                    cell?.detailTextLabel?.text = "\(objects.count)"
                }

            default:
                fatalError("Bad index: \(index)")
            }
            ++index
        }
    }

    @IBAction func save(sender: AnyObject) {
        //MSZ ToDo

        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func cancel(sender: AnyObject) {
        guard let mo = recipeMO else {
            fatalError("recipe is nil")
        }
        guard let moc = mo.managedObjectContext else {
            fatalError("recipe is not associated with a context")
        }
        if mo.inserted {
            moc.deleteObject(mo)
        } else {
            moc.refreshObject(mo, mergeChanges: false)
        }

        navigationController?.popViewControllerAnimated(true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            fatalError("Unidentified segue")
        }
        switch identifier {
        case "editRecipeName":
            guard let controller = segue.destinationViewController as? PPRTextEditViewController else {
                fatalError("Unexpected view controller in segue")
            }
            prepareForEditRecipeNameSegue(controller)
        case "selectRecipeType":
            guard let controller = segue.destinationViewController as? PPRSelectTypeViewController else {
                fatalError("Unexpected view controller in segue")
            }
            prepareForSelectTypeSegue(controller)
        case "selectNumberOfServings":
            guard let controller = segue.destinationViewController as? PPRTextEditViewController else {
                fatalError("Unexpected view controller in segue")
            }
            prepareForSetServingsSegue(controller)
        case "selectLastUsed":
            guard let controller = segue.destinationViewController as? PPRSetDateViewController else {
                fatalError("Unexpected view controller in segue")
            }
            prepareForSetDateSegue(controller)
        case "selectAuthor":
            guard let controller = segue.destinationViewController as? PPRSelectAuthorViewController else {
                fatalError("Unexpected view controller in segue")
            }
            prepareForSelectAuthorSegue(controller)
            print("")
        case "selectIngredients":
            guard let controller = segue.destinationViewController as? PPREditIngredientListViewController else {
                fatalError("Unexpected view controller in segue")
            }
            prepareForSelectIngredientSegue(controller)
        case "editDescription":
            guard let controller = segue.destinationViewController as? PPRTextEditViewController else {
                fatalError("Unexpected view controller in segue")
            }
            prepareForDirectionsSegue(controller)
        default:
            fatalError("Unrecognized segue: \(identifier)")
        }
    }

    func prepareForSelectIngredientSegue(controller: PPREditIngredientListViewController) {
        controller.recipeMO = recipeMO

        controller.updateIngredientCountBlock = { (ingredientCount: Int) in
            let path = NSIndexPath(forRow: 6, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(path)
            cell?.detailTextLabel?.text = "\(ingredientCount)"
        }
    }

    func prepareForSelectAuthorSegue(controller: PPRSelectAuthorViewController) {
        controller.managedObjectContext = recipeMO?.managedObjectContext
        controller.selectAuthorClosure = { (authorMO: NSManagedObject) in
            let path = NSIndexPath(forRow: 4, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(path)
            self.recipeMO?.setValue(authorMO, forKey: "author")
            cell?.detailTextLabel?.text = authorMO.valueForKey("name") as? String
        }
    }

    func prepareForSetDateSegue(controller: PPRSetDateViewController) {
        if let date = recipeMO?.valueForKey("lastUsed") as? NSDate {
            controller.datePicker?.date = date
        }

        controller.dateChangedClosure = { (newDate: NSDate) in
            self.recipeMO?.setValue(newDate, forKey: "lastUsed")
            let path = NSIndexPath(forRow: 3, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(path)
            cell?.detailTextLabel?.text = self.recipeMO?.lastUsedString()
        }
    }

    func prepareForSetServingsSegue(controller: PPRTextEditViewController) {
        if let number = recipeMO?.valueForKey("serves") as? NSNumber {
            controller.text = number.stringValue
        } else {
            controller.text = "0"
        }

        controller.textChangedClosure = { (text: String) in
            let numberFormatter = NSNumberFormatter()
            guard let servings = numberFormatter.numberFromString(text) else {
                throw NSError(domain: "PragProg", code: 1123, userInfo: [NSLocalizedDescriptionKey : "Invalid servings"])
            }

            self.recipeMO?.setValue(servings, forKey: "serves")
            let path = NSIndexPath(forRow: 2, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(path)
            cell?.detailTextLabel?.text = text
        }
    }

    func prepareForSelectTypeSegue(controller: PPRSelectTypeViewController) {
        controller.managedObjectContext = recipeMO?.managedObjectContext
        controller.typeChangedClosure = { (text: String) in
            self.recipeMO?.setValue(text, forKey: "type")
            let path = NSIndexPath(forRow: 1, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(path)
            cell?.detailTextLabel?.text = text
        }
    }

    func prepareForEditRecipeNameSegue(controller: PPRTextEditViewController) {
        controller.text = recipeMO?.valueForKey("name") as? String

        controller.textChangedClosure = { (text: String) in
            self.recipeMO?.setValue(text, forKey: "name")
            let path = NSIndexPath(forRow: 0, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(path)
            cell?.detailTextLabel?.text = text
        }
    }

    func prepareForDirectionsSegue(controller: PPRTextEditViewController) {
        controller.text = recipeMO?.valueForKey("desc") as? String

        controller.textChangedClosure = { (text: String) in
            self.recipeMO?.setValue(text, forKey: "desc")
            let path = NSIndexPath(forRow: 5, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(path)
            cell?.detailTextLabel?.text = text
        }
    }
}
