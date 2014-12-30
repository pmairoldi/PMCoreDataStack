import UIKit
import CoreData
import ReactiveCocoa

public class CoreDataTableViewController: UITableViewController {
    
    var viewModel:CoreDataViewModel!
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        assert(viewModel != nil, "you must specify a view model")
        
        viewModel.willChangeContentSignal.takeUntil(rac_willDeallocSignal()).subscribeNext { [unowned self] (_) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.beginUpdates()
            })
        }
        
        viewModel.didChangeObjectSignal.takeUntil(rac_willDeallocSignal()).subscribeNext { [unowned self] (tuple) -> Void in
            
            let type = NSFetchedResultsChangeType(rawValue: tuple[1].unsignedLongValue)!
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                switch type {
                case .Insert:
                    if let newIndexPath = tuple[2] as? NSIndexPath {
                        self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                case .Delete:
                    if let indexPath = tuple[0] as? NSIndexPath {
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                case .Update:
                    if let indexPath = tuple[0] as? NSIndexPath {
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                case .Move:
                    switch (tuple[0], tuple[2]) {
                    case let (indexPath as NSIndexPath, newIndexPath as NSIndexPath):
                        self.tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
                    default:
                        break
                    }
                }
            })
        }
        
        viewModel.didChangeSectionSignal.takeUntil(rac_willDeallocSignal()).subscribeNext { [unowned self] (tuple) -> Void in
            
            let sectionIndex = tuple[0].unsignedIntegerValue
            let type = NSFetchedResultsChangeType(rawValue: tuple[1].unsignedLongValue)!
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                switch type {
                case .Insert:
                    self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic) //make fade?
                case .Delete:
                    self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic) //make fade?
                default:
                    break
                }
            })
        }

        viewModel.didChangeContentSignal.takeUntil(rac_willDeallocSignal()).subscribeNext { [unowned self] (_) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.endUpdates()
            })
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return viewModel.numberOfSections()
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.numberOfObjectsInSection(section)
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        assert(true, "must override cellForRowAtIndexPath")
        return UITableViewCell();
    }
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
