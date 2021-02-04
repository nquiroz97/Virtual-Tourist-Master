//
//  DataController.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/16/20.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    var context:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        
    }
    
    func configureContexts() {
        context.automaticallyMergesChangesFromParent = true
        
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}



// MARK: - Autosaving

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if context.hasChanges {
            try? context.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
