//
//  PPRSelectIngredientTypeViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRSelectIngredientTypeViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var managedObjectContext: NSManagedObjectContext?
    var selectIngredientType: ((ingredientType: NSManagedObject) -> Void)?
    var fResultsController: NSFetchedResultsController?

    let currencyFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let moc = managedObjectContext else {
            fatalError("No MOC assigned")
        }

        navigationItem.rightBarButtonItem = editButtonItem()

        let request = NSFetchRequest(entityName: "Ingredient")
        request.sortDescriptors = [NSSortDescriptor(key: "name",
            ascending: true)]

        fResultsController = NSFetchedResultsController(fetchRequest: request,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil)

        fResultsController?.delegate = self

        do {
            try fResultsController?.performFetch()
        } catch {
            fatalError("Failed to perform fetch: \(error)")
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        guard let count = fResultsController?.fetchedObjects?.count else {
            fatalError("Failed to get row count")
        }
        let iRowPath = NSIndexPath(forRow: count, inSection: 0)

        if editing {
            tableView.deleteRowsAtIndexPaths([iRowPath], withRowAnimation: .Fade)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            fatalError("Unidentified segue")
        }
        guard let moc = managedObjectContext else {
            fatalError("No MOC assigned")
        }

        assert(identifier == "createIngredientType", "Unexpected identifier")

        switch segue.destinationViewController {
        case let controller as PPRCreateIngredientTypeViewController:
            let ingredientType = NSEntityDescription.insertNewObjectForEntityForName("Ingredient", inManagedObjectContext: moc)
            controller.ingredientTypeMO = ingredientType
        default: break
        }
        editing = false
    }

//MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sections = fResultsController?.sections else {
            fatalError("Unable to retrieve sections from results controller")
        }
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fResultsController?.sections else {
            fatalError("Unable to retrieve sections from results controller")
        }
        if self.editing {
            return sections.count + 1
        } else {
            return sections.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let sections = fResultsController?.sections else {
            fatalError("Unable to retrieve sections from results controller")
        }
        if indexPath.row >= sections.count {
            guard let cell = tableView.dequeueReusableCellWithIdentifier(kInsertCellIdentifier) else {
                fatalError("Failed to resolve cell")
            }
            return cell
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath)

        let ingredientType = fResultsController?.objectAtIndexPath(indexPath)
        cell.textLabel?.text = ingredientType?.valueForKey("name") as? String

        var valueString: String? = currencyFormatter.stringFromNumber(0)
        if let value = ingredientType?.valueForKey("cost") as? NSNumber {
            valueString = currencyFormatter.stringFromNumber(value)
        }

        if let units = ingredientType?.valueForKeyPath("unitOfMeasure.name") as? String {
            valueString = "\(valueString) per \(units)"
        }

        cell.detailTextLabel?.text = valueString

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let objectToDelete = fResultsController?.objectAtIndexPath(indexPath) as! NSManagedObject
            managedObjectContext?.deleteObject(objectToDelete)
            return
        }

        performSegueWithIdentifier("createIngredientType", sender: self)
    }

//MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ingredientType = fResultsController?.objectAtIndexPath(indexPath) as! NSManagedObject
        selectIngredientType?(ingredientType: ingredientType)

        performSegueWithIdentifier("createIngredientType", sender: self)
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        guard let objects = fResultsController?.fetchedObjects else {
            fatalError("Unable to retrieve sections from results controller")
        }
        if indexPath.row <= objects.count {
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