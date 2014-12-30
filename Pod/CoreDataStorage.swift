import CoreData
import LlamaKit

public enum StoreType {
    
    case Sqlite
    case Binary
    case Memory
    
    func toString() -> NSString {
        
        switch self {
        case .Sqlite:
            return NSSQLiteStoreType
        case .Binary:
            return NSBinaryStoreType
        case .Memory:
            return NSInMemoryStoreType
        }
    }
}

public class CoreDataStorage: NSObject {
    
    private let modelName: String
    private let storeType: StoreType
    private let storeOptions: [NSObject : AnyObject]?

    let managedObjectModel: NSManagedObjectModel = NSManagedObjectModel()
    let persistentStoreCoordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
    let managedObjectContext: NSManagedObjectContext = NSManagedObjectContext()
    
    public init(modelName name: String, storeType type: StoreType, storeOptions options: [NSObject : AnyObject]?) {

        modelName = name
        storeType = type
        
        super.init()

        if type == StoreType.Memory {
            
            storeOptions = nil
        }
            
        else {
            
            if let _storeOptions = options {
                storeOptions = _storeOptions
            }
                
            else {
                storeOptions = defaultStoreOptions(storeType)
            }
        }
        
        managedObjectModel = managedObjectModel(managedObjectModelPath(modelName))
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        let persistancePath = storePathForFilename(persistentFilePath(persistentStoreDirectory(directoryPath()), fileName: sqliteFileName(modelName)))

        addPersistanceStoreWithPath(persistentStoreCoordinator, storePath: persistancePath, options: storeOptions)
        
        managedObjectContext =  managedObjectContext(persistentStoreCoordinator)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: managedObjectContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "managedObjectContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: managedObjectContext)
    }
    
     deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: managedObjectContext)
    }
    
    private func sqliteFileName(filePath: String) -> String {
        
        if filePath.pathExtension == "sqlite" {
            return filePath
        }
        
        if let path = filePath.stringByDeletingPathExtension.stringByAppendingPathExtension("sqlite") {
            
            return path
        }
        
        return filePath
    }
    
    private func defaultStoreOptions(storeType: StoreType) -> [NSObject : AnyObject]? {
        
        if (storeType != StoreType.Memory) {
            return [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        }
        
        return nil
    }
    
    private func directoryPath() -> String {
        
        if let displayName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as String? {
            
            return displayName
        }
        
        return "CoreDataStorage"
    }
    
    private func persistentStoreDirectory(directoryPath: String) -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let basePath = (paths.count > 0) ? paths[0] as String : NSTemporaryDirectory()
        
        let fullPath = basePath.stringByAppendingPathComponent(directoryPath)
        
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(fullPath) {
            fileManager.createDirectoryAtPath(fullPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        return fullPath
    }
    
    private func persistentFilePath(directory: String, fileName: String) -> String {
        
        return directory.stringByAppendingPathComponent(fileName)
    }
    
    private func addPersistanceStoreWithPath(persistentStoreCoordinator: NSPersistentStoreCoordinator, storePath: NSURL?, options: [NSObject : AnyObject]?) -> NSPersistentStore? {
        
        if let aStorePath = storePath {
            
            return persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: aStorePath, options: options, error: nil);
        }
            
        else {
            
            return persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
        }
    }
    
    private func managedObjectModelPath(name: String) -> String? {
        
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: "mom") {
            
            return path
        }
        
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: "momd") {
            
            return path
        }
        
        return nil
    }
    
    private func managedObjectModel(path: String?) -> NSManagedObjectModel {
        
        if let momPath = path {
            
            if let momURL = NSURL(fileURLWithPath: momPath) {
                
                if let managedObject = NSManagedObjectModel(contentsOfURL: momURL) {
                    
                    return managedObject
                }
            }
        }
        
        return NSManagedObjectModel()
    }
    
    private func storePathForFilename(filePath: String?) -> NSURL? {
        
        if let _filePath = filePath {
            
            if let storePath = NSURL(fileURLWithPath: _filePath) {
                
                return storePath
            }
        }
        
        return nil
    }

    private func managedObjectContext(persistentStoreCoordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        
        //TODO: check for queue
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
        managedObjectContext.undoManager = nil;
        
        return managedObjectContext
    }
    
    private func managedObjectContextDidSave(notification: NSNotification) {
        
        //TODO: check for queue
        let sender = notification.object as NSManagedObjectContext;
        
        if sender != managedObjectContext && sender.persistentStoreCoordinator == managedObjectContext.persistentStoreCoordinator {
            
            if let dictionary = notification.userInfo as [NSObject : AnyObject]? {
                
                if let array = dictionary[NSUpdatedObjectsKey] as [NSManagedObject]? {
                    
                    for object:NSManagedObject in array {
                        managedObjectContext.objectWithID(object.objectID)
                    }
                }
            }
            
            managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
}

extension NSManagedObject {
    
    convenience public init(name: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)
        
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
    }
}

extension NSManagedObjectContext {
    
    public func save() -> Result<Void> {
        
        if persistentStoreCoordinator?.persistentStores.count <= 0 {
            return failure(CoreDataStorage.noPersistentStoresError())
        }
        
        var error: NSError?
        save(&error)
        
        if let _error = error {
            return failure(_error)
        }
        
        else {
            return success()
        }
    }
}

extension NSFetchedResultsController {
    
    public func performFetch() -> Result<Void> {
        
        var error: NSError?
        performFetch(&error)
        
        if let _error = error {
            return failure(_error)
        }
            
        else {
            return success()
        }
    }
}

extension CoreDataStorage {
    
    public class func noPersistentStoresError() -> NSError {
        return NSError(domain: "CoreDataStorage", code: 1, userInfo: [NSLocalizedDescriptionKey: "This NSPersistentStoreCoordinator has no persistent stores. It cannot perform a save operation."])
    }
}