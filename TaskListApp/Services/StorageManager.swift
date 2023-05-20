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
    
    // MARK: - Core Data stack
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
    
// MARK: - CRUD Methods
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
        let taskToDelete = fetchData()[index]
        viewContext.delete(taskToDelete)
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func update(_ task: Task, withName taskName: String) -> Task {
            task.title = taskName
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
            return task
        }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
