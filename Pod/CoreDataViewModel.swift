import UIKit
import CoreData
import ReactiveCocoa

public class CoreDataViewModel: NSObject, NSFetchedResultsControllerDelegate {

    let willChangeContentSignal:RACSignal = RACSignal.empty()
    let didChangeObjectSignal:RACSignal = RACSignal.empty()
    let didChangeSectionSignal:RACSignal = RACSignal.empty()
    let didChangeContentSignal:RACSignal = RACSignal.empty()
    
    let managedObjectContext:NSManagedObjectContext
    let fetchedResultsController:NSFetchedResultsController
    
    public init(objectConext: NSManagedObjectContext, fetchController: NSFetchedResultsController) {

        managedObjectContext = objectConext
        fetchedResultsController = fetchController
        
        super.init()

        willChangeContentSignal = willChangeContent()
        didChangeObjectSignal = didChangeObject()
        didChangeSectionSignal = didChangeSection()
        didChangeContentSignal = didChangeContent()
        
        fetchedResultsController.delegate = self
        
        switch fetchedResultsController.performFetch() {
        case .Success:
            break
        case .Failure(let error):
            println(error)
        }
    }
    
    public func numberOfSections() -> Int {
        
        if let sections = fetchedResultsController.sections {
            
            return sections.count
        }
        
        return 0
    }
    
    public func numberOfObjectsInSection(section: Int) -> Int {
        
        if let sections = fetchedResultsController.sections {
            
            let sectionInfo = sections[section] as NSFetchedResultsSectionInfo
            
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    public func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        
        return fetchedResultsController.objectAtIndexPath(indexPath)
    }
    
    private func willChangeContent() -> RACSignal {
        
        return rac_signalForSelector(Selector("controllerWillChangeContent:"), fromProtocol: NSFetchedResultsControllerDelegate.self).map({ (_) -> AnyObject! in
            
            return nil
        })
    }
    
    private func didChangeObject() -> RACSignal {
        
        return rac_signalForSelector(Selector("controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:"), fromProtocol: NSFetchedResultsControllerDelegate.self).map({ (protocolTuple) -> AnyObject! in
            
            let tuple = protocolTuple as RACTuple
            
            let indexPath = tuple[2] as NSIndexPath! ?? RACTupleNil()
            let type = tuple[3] as NSNumber
            let newIndexPath = tuple[4] as NSIndexPath! ?? RACTupleNil()
            
            return RACTuple(objectsFromArray: [indexPath, type, newIndexPath], convertNullsToNils: true)
        })
    }
    
    private func didChangeSection() -> RACSignal {
        
        return rac_signalForSelector(Selector("controller:didChangeSection:atIndex:forChangeType:"), fromProtocol: NSFetchedResultsControllerDelegate.self).map({ (protocolTuple) -> AnyObject! in
            
            let tuple = protocolTuple as RACTuple

            let sectionIndex = tuple[2] as NSIndexPath! ?? RACTupleNil()
            let type = tuple[3] as NSNumber
            
            return RACTuple(objectsFromArray: [sectionIndex, type], convertNullsToNils: true)
        })
    }
    
    private func didChangeContent() -> RACSignal {
        
        return rac_signalForSelector(Selector("controllerDidChangeContent:"), fromProtocol: NSFetchedResultsControllerDelegate.self).map({ (_) -> AnyObject! in
            
            return nil
        })
    }
}
