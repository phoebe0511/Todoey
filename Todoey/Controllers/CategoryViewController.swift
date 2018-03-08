//
//  CategryViewController.swift
//  Todoey
//
//  Created by Hsiu Ping Lin on 2018/3/8.
//  Copyright © 2018年 Hsiu Ping Lin. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    let contextDB = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()

    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alertdlg = UIAlertController(title: "Add New Category Item", message: "", preferredStyle: .alert)
        var textFiled = UITextField()
        alertdlg.addTextField { (dlgTextField) in
            dlgTextField.placeholder = "Create new item"
            textFiled = dlgTextField
        }
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let item = Category(context: self.contextDB)
            item.name = textFiled.text
            self.itemArray.append(item)
            self.saveData()
            self.tableView.reloadData()
        }
        alertdlg.addAction(alertAction)
        present(alertdlg, animated: true, completion: nil)
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let todoeyView = segue.destination as! TodoListViewController
        todoeyView.selectCategory = itemArray[(tableView.indexPathForSelectedRow?.row)!]
    }
    
    func saveData(){
        do{
           try contextDB.save()
        }catch{
            print("Error categroy db saving : \(error)")
        }
    }
    
    func loadData(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        do{
            itemArray = try contextDB.fetch(request)
        }catch{
            print("Error category db loading : \(error)")
        }
        
    }
    
}
