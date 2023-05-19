//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Kasharin Mikhail on 18.05.2023.
//

import Foundation
import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    private lazy var viewContext = persistentContainer.viewContext
    
    private init() {}

    func fetchData() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        var taskList: [Task] = []
        
        do {
            taskList = try viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        return taskList
    }
    
     func save(_ taskName: String) -> Task {
        let task = Task(context: viewContext)
        task.title = taskName
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        return task
    }
    
    func delete(_ index: Int) {
        var taskList = fetchData()
        do {
            let delete = taskList.remove(at: index)
            viewContext.delete(delete)
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateTask(with taskName: String) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let taskList = try viewContext.fetch(fetchRequest)
            
            if let index = taskList.firstIndex(where: { $0.title == taskName }) {
                let taskToUpdate = taskList[index]
                taskToUpdate.title = taskName
                
                try viewContext.save()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
