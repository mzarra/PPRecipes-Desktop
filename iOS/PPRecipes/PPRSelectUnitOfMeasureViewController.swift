//
//  PPRSelectUnitOfMeasureViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRSelectUnitOfMeasureViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var managedObjectContext: NSManagedObjectContext?
    var selectUnitOfMeasure: ((unitOfMeasure: NSManagedObject) -> Void)?
    var fResultsController: NSFetchedResultsController?

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetch = NSFetchRequest(entityName: "UnitOfMeasure")
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        guard let moc = self.managedObjectContext else {
            fatalError("No MOC assigned")
        }
        fResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fResultsController?.delegate = self

        do {
            try fResultsController?.performFetch()
        } catch {
            fatalError("Failed to performFetch: \(error)")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            fatalError("Unidentified Segue")
        }
        if identifier != "addUnitOfMeasure" {
            fatalError("Unknown Segue: \(identifier)")
        }
        let controller = segue.destinationViewController as! PPRTextEditViewController

        controller.textChangedClosure = { (text: String) in
            if text.characters.count == 0 {
                throw NSError(domain: "PragProg", code: 1123, userInfo: [NSLocalizedDescriptionKey : "Invalid Name"])
            }
            guard let moc = self.managedObjectContext else {
                fatalError("No MOC assigned")
            }
            let fetch = NSFetchRequest(entityName: "UnitOfMeasure")
            fetch.predicate = NSPredicate(format: "name == %@", text)
            var error: NSError? = nil
            let count = moc.countForFetchRequest(fetch, error: &error)
            if count == NSNotFound {
                fatalError("Error fetching: \(error)")
            }
            if count > 0 {
                throw NSError(domain: "PragProg", code: 1123, userInfo: [NSLocalizedDescriptionKey: "Already Exists"])
            }
            let uom = NSEntityDescription.insertNewObjectForEntityForName("UnitOfMeasure", inManagedObjectContext: moc)
            uom.setValue(text, forKey: "name")

            self.dismissViewControllerAnimated(true) {}
        }

    }

//MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionInfo = fResultsController?.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }

//MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let uom = fResultsController?.objectAtIndexPath(indexPath) as! NSManagedObject
        selectUnitOfMeasure?(unitOfMeasure: uom)
        navigationController?.popViewControllerAnimated(true)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath)
        let uom = fResultsController?.objectAtIndexPath(indexPath) as! NSManagedObject
        cell.textLabel?.text = uom.valueForKey("name") as? String

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