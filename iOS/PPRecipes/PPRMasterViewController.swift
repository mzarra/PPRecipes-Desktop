//
//  PPREntryViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRMasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var managedObjectContext: NSManagedObjectContext?
    var fResultsController: NSFetchedResultsController?
    var detailController: PPRDetailViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem()

        if let navController = splitViewController?.viewControllers.last as? UINavigationController {
            detailController = navController.topViewController as? PPRDetailViewController
        }

        let fetch = NSFetchRequest(entityName: "Recipe")
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        guard let moc = managedObjectContext else {
            fatalError("MOC not initialized")
        }
        fResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fResultsController?.delegate = self
        do {
            try fResultsController?.performFetch()
        } catch {
            fatalError("Unable to fetch: \(error)")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            fatalError("Unidetified segue")
        }

        switch identifier {
        case "showRecipe":
            guard let controller = segue.destinationViewController as? PPRDetailViewController else {
                fatalError("Unexpected view controller in segue")
            }
            if let path = tableView.indexPathForSelectedRow {
                controller.recipeMO = fResultsController?.objectAtIndexPath(path) as? PPRRecipeMO
            }
        case "addRecipe":
            guard let controller = segue.destinationViewController as? PPREditRecipeViewController else {
                fatalError("Unexpected view controller in segue")
            }
            guard let moc = managedObjectContext else {
                fatalError("Context not set")
            }
            guard let recipe = NSEntityDescription.insertNewObjectForEntityForName("Recipe", inManagedObjectContext: moc) as? PPRRecipeMO else {
                fatalError("Failed to create new entity, is entity class not set in the model?")
            }
            controller.recipeMO = recipe
        default:
            fatalError("Unexpected segue: \(identifier)")
        }
    }

//MARK UITableViewDelegate

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let count = fResultsController?.sections?.count else {
            fatalError("Failed to resolve FRC")
        }
        return count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fResultsController?.sections?[section] else {
            fatalError("Failed to resolve FRC")
        }
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath)
        let object = fResultsController?.objectAtIndexPath(indexPath)
        cell.textLabel?.text = object?.valueForKey("name") as? String
        return cell
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