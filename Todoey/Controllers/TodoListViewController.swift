//
//  ViewController.swift
//  Todoey
//
//  Created by Hsiu Ping Lin on 2018/3/6.
//  Copyright © 2018年 Hsiu Ping Lin. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
//    var titleArray = ["Eat launch🍱", "領錢", "喝飲料🎊", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"]
    var itemArray = [ItemCellEncodable]()
    var dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist", isDirectory: false)
    let DEFAULT_NAME = "TodoeyItemArray"
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        print(dataFilePath ?? "no data file")
        super.viewDidLoad()
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
        //print(itemArray[indexPath.row].title, ite)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //print(indexPath)
        tableView.reloadData()
        saveItemData()
        //print(indexPath, tableView.cellForRow(at: indexPath)?.isSelected)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Action of buttons
    @IBAction func btnPressedAdd(_ sender: UIBarButtonItem) {
        var textFiled = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (alertaction) in
            if let textSrt = textFiled.text {
                let newItem = ItemCellEncodable()
                newItem.title = textSrt
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
    //MARK: FileManager save and load
    func saveItemData() {
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        }catch{
            print("Error encode item array, \(error)")
        }
    }
    
    func loadItemData() {
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do{
                itemArray = try decoder.decode([ItemCellEncodable].self, from: data)
            }catch{
                print("Error decode item array: \(error)")
            }
        }
    }
    
}

