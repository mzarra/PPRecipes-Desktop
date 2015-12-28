//
//  PPRRecipeMO.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/7/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import CoreData

class PPRRecipeMO: NSManagedObject {

    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        return formatter
    }()

    func lastUsedString() -> String {
        if let date = self.valueForKey("lastUsed") as? NSDate {
            return dateFormatter.stringFromDate(date)
        } else {
            return "Never Used"
        }
    }
}