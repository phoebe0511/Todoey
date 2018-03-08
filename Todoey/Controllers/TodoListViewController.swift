//
//  ViewController.swift
//  Todoey
//
//  Created by Hsiu Ping Lin on 2018/3/6.
//  Copyright © 2018年 Hsiu Ping Lin. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    let contextDB = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [TodoeyItems]()
    var selectCategory : Category?{
        didSet{
            loadItemData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItemData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = (itemArray[indexPath.row].done) ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        tableView.reloadData()
        saveItemData() //commit db data here

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Action of buttons
    @IBAction func btnPressedAdd(_ sender: UIBarButtonItem) {
        var textFiled = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (alertaction) in
            if let textSrt = textFiled.text {
                let newItem = TodoeyItems(context: self.contextDB)
                newItem.title = textSrt
                newItem.done = false
                newItem.parentCategory = self.selectCategory
                self.itemArray.append(newItem)
                self.saveItemData()
                
                self.tableView.reloadData()
            }
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textFiled = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: database save and load
    func saveItemData() {
        do{
            try contextDB.save()
        }catch{
            print("Error saving item array, \(error)")
        }
    }
    
    func loadItemData(with request : NSFetchRequest<TodoeyItems> = TodoeyItems.fetchRequest(), predicate : NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectCategory?.name)!)
        if let additionPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        do{
            itemArray = try contextDB.fetch(request)
        }catch{
            print("Error fetching data: \(error)")
        }
        //tableView.reloadData()
    }
    
}

extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<TodoeyItems> = TodoeyItems.fetchRequest()
        //string comparisons are by default case and diacritic sensitive
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItemData(with: request, predicate: request.predicate)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItemData()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}

