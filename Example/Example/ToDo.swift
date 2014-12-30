import UIKit
import CoreData

@objc(ToDo)

class ToDo: NSManagedObject {
    
    @NSManaged var task: String
    @NSManaged var date: NSDate
    @NSManaged var position: Int

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(context: NSManagedObjectContext) {
        
        self.init(name: "ToDo", context: context)
    }
}
