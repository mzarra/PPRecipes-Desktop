import Cocoa
import CoreData

class ViewController: NSViewController {
    var dataController: PPRDataController! {
        didSet {
            managedObjectContext = dataController.mainContext
        }
    }
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

