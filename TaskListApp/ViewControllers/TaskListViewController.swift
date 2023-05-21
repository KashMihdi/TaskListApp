//
//  TaskListViewController.swift
//  TaskListApp
//
//  Created by Alexey Efimov on 17.05.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {

    // MARK: - Private Properties
    private let storageManager = StorageManager.shared
    private let cellID = "cell"
    private var taskList: [Task] = []

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }

    // MARK: - Action Methods
    @objc private func addNewTask() {
        showAlert(
            withTitle: "New Task",
            andMessage: "What do you want to do?"){ [weak self] task in
            self?.save(task)
        }
    }
    
    // MARK: - AlertController
    private func showAlert(
        withTitle title: String,
        andMessage message: String,
        completion: @escaping (_ taskName: String) -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            completion(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { [weak self] _ in
            guard let index = self?.tableView.indexPathForSelectedRow else { return }
            self?.tableView.deselectRow(at: index, animated: true)
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { [weak self] textText in
            textText.placeholder = "New Task"
            guard let index = self?.tableView.indexPathForSelectedRow else { return }
            textText.text = self?.taskList[index.row].title
        }
        present(alert, animated: true)
    }
    
    // MARK: - CRUD Methods
    private func fetchData() {
       storageManager.fetchData(completion: { [weak self] result in
            switch result {
            case .success(let tasks):
                self?.taskList = tasks
                self?.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    private func save(_ taskName: String) {
        taskList.append(storageManager.save(taskName))
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    private func delete(_ indexPath: IndexPath) {
        let task = taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        storageManager.delete(task)
    }
    
    private func update(_ taskName: String, _ indexPath: IndexPath) {
        if taskList[indexPath.row].title == taskName {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        taskList[indexPath.row].title = taskName
        storageManager.update(taskList[indexPath.row], withName: taskName)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(
            withTitle: "Update Task",
            andMessage: "What do you want to change?") { [weak self] task in
                self?.update(task, indexPath)
            }
    }
}

// MARK: - SetupUI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
}
