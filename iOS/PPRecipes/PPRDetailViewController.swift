//
//  PPRDetailViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRDetailViewController: UITableViewController {
    var recipeMO: PPRRecipeMO?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let detailView = view as? PPRDetailView else {
            fatalError("Wrong view assigned to view controller")
        }
        guard let recipe = recipeMO else {
            fatalError("Recipe unassigned")
        }
        detailView.populateFromRecipe(recipe)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            fatalError("Unidentified segue")
        }
        assert(identifier == "editRecipe", "Unexpected identifier: \(identifier)")

        guard let controller = segue.destinationViewController as? PPREditRecipeViewController else {
            fatalError("Unexpected view controller in segue")
        }

        controller.recipeMO = recipeMO
    }

    //START: action
    func action(sender: AnyObject) {
        let controller = UIAlertController()
        var action = UIAlertAction(title: "Mail Recipe", style: .Default) {
            (action) in
            self.mailRecipe()
        }
        controller.addAction(action)
        action = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        controller.addAction(action)
        presentViewController(controller, animated: true, completion: nil)
    }
    //END: action

    //START: mailRecipe
    func mailRecipe() {
        guard let mo = recipeMO else {
            fatalError("Unexpected nil recipe")
        }
        let operation = PPRExportOperation(mo, completionHandler: {
            (data, error) in
            if error != nil {
                fatalError("Export failed: \(error)")
            }
            //Mail the data to a friend
        })
        NSOperationQueue.mainQueue().addOperation(operation)
    }
    //END: mailRecipe
}

class PPRDetailView: UIView {
    @IBOutlet var recipeNameLabel: UILabel?
    @IBOutlet var authorLabel: UILabel?
    @IBOutlet var typeLabel: UILabel?
    @IBOutlet var servesLabel: UILabel?
    @IBOutlet var lastServedLabel: UILabel?
    @IBOutlet var descriptionLabel: UILabel?

    func populateFromRecipe(recipeMO: PPRRecipeMO) {
        recipeNameLabel?.text = recipeMO.valueForKey("name") as? String
        authorLabel?.text = recipeMO.valueForKeyPath("author.name") as? String
        typeLabel?.text = recipeMO.valueForKey("type") as? String

        if let value = recipeMO.valueForKey("serves") as? NSNumber {
            servesLabel?.text = value.stringValue
        } else {
            servesLabel?.text = "Unknown"
        }

        lastServedLabel?.text = recipeMO.lastUsedString()
        descriptionLabel?.text = recipeMO.valueForKey("desc") as? String
    }
}