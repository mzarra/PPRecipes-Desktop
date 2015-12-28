import Cocoa
import CoreData

class ViewController: NSViewController {
  let dataController = PPRDataController() {  error in
  }

  override func viewWillDisappear() {
    dataController.saveContext()
  }

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

