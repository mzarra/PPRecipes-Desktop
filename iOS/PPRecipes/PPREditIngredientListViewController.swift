//
//  PPREditIngredientListViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPREditIngredientListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var fResultsController: NSFetchedResultsController?
    var recipeMO: NSManagedObject?
    var updateIngredientCountBlock: ((ingredientCount: Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem()

        guard let mo = recipeMO else {
            fatalError("Failed to set managed object")
        }
        let fetch = NSFetchRequest(entityName: "RecipeIngredient")
        fetch.predicate = NSPredicate(format: "recipe == %@", mo)
        fetch.sortDescriptors = [NSSortDescriptor(key: "ingredient.name", ascending: true)]

        guard let moc = mo.managedObjectContext else {
            fatalError("managed object is not assigned to a context")
        }
        fResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fResultsController?.delegate = self

        do {
            try fResultsController?.performFetch()
        } catch {
            fatalError("Failed to execute fetch: \(error)")
        }

    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        guard let count = fResultsController?.fetchedObjects?.count else {
            fatalError("Unable to retrieve fetchedObjects")
        }
        let path = NSIndexPath(forRow: count, inSection: 0)

        if editing {
            tableView.insertRowsAtIndexPaths([path], withRowAnimation: .Fade)
        } else {
            tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Fade)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            fatalError("Unknown segue")
        }
        assert(identifier == "addIngredient", "Unexpected segue: \(identifier)")
        guard let controller = segue.destinationViewController as? PPRAddRecipeIngredientViewController else {
            fatalError("Unexpected destination view controller: \(segue.destinationViewController.self)")
        }

        guard let moc = recipeMO?.managedObjectContext else {
            fatalError("failed to retrieve context")
        }
        let recipeIngredient = NSEntityDescription .insertNewObjectForEntityForName("RecipeIngredient", inManagedObjectContext: moc)
        controller.recipeIngredientMO = recipeIngredient
        editing = false
    }

//MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = fResultsController?.sections?[section].numberOfObjects else {
            fatalError("Failed to retrieve section count")
        }
        if editing {
            return count + 1
        } else {
            return count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let count = fResultsController?.sections?[indexPath.row].numberOfObjects else {
            fatalError("Failed to retrieve section count")
        }
        if indexPath.row >= count {
            guard let cell = tableView.dequeueReusableCellWithIdentifier(kInsertCellIdentifier) else {
                fatalError("Failed to retrieve cell for identifier: \(kInsertCellIdentifier)")
            }
            return cell
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath)
        guard let ingredient = fResultsController?.objectAtIndexPath(indexPath) as? NSManagedObject else {
            fatalError("Failed to retrieve object")
        }
        cell.textLabel?.text = ingredient.valueForKeyPath("ingredient.name") as? String

        let quantity = ingredient.valueForKey("quantity")
        let unit = ingredient.valueForKeyPath("ingredient.unitOfMeasure.name")
        cell.detailTextLabel?.text = "\(quantity) \(unit)"

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Insert {
            performSegueWithIdentifier("addIngredient", sender: self)
            return
        }

        guard let mo = fResultsController?.objectAtIndexPath(indexPath), let moc = fResultsController?.managedObjectContext else {
            fatalError("Failed to retrieve object or context")
        }
        moc.deleteObject(mo as! NSManagedObject)
    }

//MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        guard let count = fResultsController?.sections?[indexPath.row].numberOfObjects else {
            fatalError("Failed to retrieve section count")
        }
        if indexPath.row >= count {
            return .Insert
        }
        return .Delete
    }

//MARK: NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default: break
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}