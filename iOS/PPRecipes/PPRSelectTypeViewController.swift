//
//  PPRSelectTypeViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRSelectTypeViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var fResultsController: NSFetchedResultsController?
    var managedObjectContext: NSManagedObjectContext?
    var typeChangedClosure: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetch = NSFetchRequest(entityName: "Type")
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        guard let moc = managedObjectContext else {
            fatalError("MOC not assigned before use")
        }
        fResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fResultsController?.delegate = self

        do {
            try fResultsController?.performFetch()
        } catch {
            fatalError("Failed to perform fetch: \(error)")
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

//MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = fResultsController?.fetchedObjects?.count else {
            fatalError("Failed to retrieve objects from FRC")
        }
        return count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath)

        guard let type = fResultsController?.objectAtIndexPath(indexPath) else {
            fatalError("Failed to retrieve referenced managed object")
        }

        cell.textLabel?.text = type.valueForKey("name") as? String
        return cell
    }

//MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let type = fResultsController?.objectAtIndexPath(indexPath) else {
            fatalError("Failed to retrieve referenced managed object")
        }
        guard let name = type.valueForKey("name") as? String else {
            fatalError("Failed to retrieve name from managed object")
        }
        typeChangedClosure?(name)

        navigationController?.popViewControllerAnimated(true)
    }
}