//
//  PPRSetDateViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRSetDateViewController: UIViewController {
    @IBOutlet var datePicker: UIDatePicker?
    var dateChangedClosure: ((newDate: NSDate) -> Void)?

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func done(sender: AnyObject) {
        guard let date = datePicker?.date else {
            fatalError("unable to retrieve date")
        }
        dateChangedClosure?(newDate: date)
        navigationController?.popViewControllerAnimated(true)
    }
}