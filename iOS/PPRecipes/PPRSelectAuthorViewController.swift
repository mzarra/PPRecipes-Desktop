//
//  PPRSelectAuthorViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/7/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRSelectAuthorViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var managedObjectContext: NSManagedObjectContext?
    var fResultsController: NSFetchedResultsController?
    var selectAuthorClosure: ((NSManagedObject) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem()

        guard let moc = managedObjectContext else {
            fatalError("Context not assigned")
        }

        let fetch = NSFetchRequest(entityName: "Author")
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        fResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fResultsController?.delegate = self

        do {
            try fResultsController?.performFetch()
        } catch {
            fatalError("Error performing fetch: \(error)")
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        guard let count = fResultsController?.fetchedObjects?.count else {
            fatalError("Failed to access FRC")
        }
        let path = NSIndexPath(forRow: count, inSection: 0)

        if editing {
            tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Fade)
        } else {
            tableView.insertRowsAtIndexPaths([path], withRowAnimation: .Fade)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let controller = segue.destinationViewController as? PPRTextEditViewController else {
            fatalError("Unexpected controller in segue")
        }

        controller.textChangedClosure = { (text: String) in
            let fetch = NSFetchRequest(entityName: "Author")
            fetch.predicate = NSPredicate(format: "name == %@", text)

            guard let moc = self.managedObjectContext else {
                fatalError("MOC not assigned")
            }

            var error: NSError? = nil
            let count = moc.countForFetchRequest(fetch, error: &error)
            if count == NSNotFound {
                fatalError("Failed to perform fetch: \(error)")
            }

            if count > 0 {
                throw NSError(domain: "PragProg", code: 1123, userInfo: [NSLocalizedDescriptionKey:"Author already exists"])
            }

            let newAuthor = NSEntityDescription.insertNewObjectForEntityForName("Author", inManagedObjectContext: moc)
            newAuthor.setValue(text, forKey: "name")
        }
    }

//MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = fResultsController?.fetchedObjects?.count else {
            fatalError("Failed to realize FRC")
        }
        if editing {
            return count + 1
        } else {
            return count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let count = fResultsController?.fetchedObjects?.count else {
            fatalError("Failed to realize FRC")
        }
        if indexPath.row >= count {
            guard let cell = tableView.dequeueReusableCellWithIdentifier(kInsertCellIdentifier) else {
                fatalError("Failed to retrieve cell for identifier: \(kInsertCellIdentifier)")
            }
            return cell
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath)

        let author = fResultsController?.objectAtIndexPath(indexPath)
        cell.textLabel?.text = author?.valueForKey("name") as? String

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Insert {
            performSegueWithIdentifier("addAuthor", sender: self)
            return
        }

        guard let mo = fResultsController?.objectAtIndexPath(indexPath) as? NSManagedObject,
            let moc = managedObjectContext else {
            fatalError("Failed to realize MO or MOC")
        }

        moc.deleteObject(mo)
    }

//MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let count = fResultsController?.fetchedObjects?.count else {
            fatalError("Failed to realize FRC")
        }
        if indexPath.row >= count {
            return true
        }

        let author = fResultsController?.objectAtIndexPath(indexPath)

        if let recipes = author?.valueForKey("recipes") as? [NSManagedObject] {
            return recipes.count == 0
        } else {
            return true
        }
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        guard let count = fResultsController?.fetchedObjects?.count else {
            fatalError("Failed to realize FRC")
        }

        if indexPath.row >= count {
            return .Insert
        }

        let author = fResultsController?.objectAtIndexPath(indexPath)

        guard let recipes = author?.valueForKey("recipes") as? [NSManagedObject] else {
            return .Delete
        }
        if recipes.count > 0 {
            return .None
        }
        return .Delete
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let count = fResultsController?.fetchedObjects?.count else {
            fatalError("Failed to realize FRC")
        }
        if indexPath.row >= count {
            return
        }

        guard let author = fResultsController?.objectAtIndexPath(indexPath) as? NSManagedObject else {
            fatalError("Failed to realize FRC")
        }

        selectAuthorClosure?(author)

        navigationController?.popViewControllerAnimated(true)
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