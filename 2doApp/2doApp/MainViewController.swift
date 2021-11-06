//
//  ViewController.swift
//  2doApp
//
//  Created by Michal T on 27/10/2021.
//

import UIKit

class MainViewController: UITableViewController, AddViewControllerDelegate {
    
    var items = [TaskItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
//        print("Data file path is \(dataFilePath())")    // sciezka do pliku .plist
        loadTaskItems()
    }
    
    func documentsDirectory() -> URL {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return paths[0]
    }

    func dataFilePath() -> URL {
      return documentsDirectory().appendingPathComponent("2doApp.plist")
    }
    
    func saveTaskItems() {  // zapisywanie pliku .plist
      let encoder = PropertyListEncoder()
      do {
        let data = try encoder.encode(items)
        try data.write(
          to: dataFilePath(),
          options: Data.WritingOptions.atomic)
      } catch {
        print("Error encoding item array: \(error.localizedDescription)")
      }
    }
    
    func loadTaskItems() {  // ladowanie pliku .plist
      let path = dataFilePath()
      if let data = try? Data(contentsOf: path) {
        let decoder = PropertyListDecoder()
        do {
          items = try decoder.decode(
            [TaskItem].self,
            from: data)
        } catch {
          print("Error decoding item array: \(error.localizedDescription)")
        }
      }
    }
    
    // MARK: - UITableView DataSource & Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let backgroundView = backgroundViewInit()
        if (items.count > 0) {  // ukrywanie komunikatu o braku zadan
            self.tableView.backgroundView = nil
            return 1
        } else {    // wyswietlanie komunikatu o braku zadan
            self.tableView.backgroundView = backgroundView;
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskItem", for: indexPath)

        let item = items[indexPath.row]

        configureText(for: cell, with: item)
        configureCheckmark(for: cell, with: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
          let item = items[indexPath.row]
          item.checked.toggle()
          configureCheckmark(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        saveTaskItems()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath:IndexPath) -> Bool {
      return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            // tworzenie akcji (usun, edytuj) dostępnych przy swipe/przesunięciu komórki
        let delete = deleteSwipeActionInit(indexPath: indexPath)
        let edit = editSwipeActionInit(indexPath: indexPath)
        
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [delete, edit])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }
    
    // MARK: - UITableViewCell configs
    
    func deleteSwipeActionInit(indexPath: IndexPath) -> UIContextualAction {    // swipe usuwanie
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("REMOVE", comment: "")) { (action, sourceView, completionHandler) in
            let alert = UIAlertController(title: NSLocalizedString("DELETE_TITLE", comment: ""), message: NSLocalizedString("DELETE_MESSAGE", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("YES_REMOVE", comment: ""), style: UIAlertAction.Style.destructive, handler: { action in
                self.items.remove(at: indexPath.row)
                let indexPaths = [indexPath]
                self.tableView.deleteRows(at: indexPaths, with: .automatic)
                self.saveTaskItems()
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("NO", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        return deleteAction
    }
    
    func editSwipeActionInit(indexPath: IndexPath) -> UIContextualAction {  // swipe edycja
        let editAction = UIContextualAction(style: .normal, title: NSLocalizedString("EDIT", comment: "")) { (action, sourceView, completionHandler) in
            self.performSegue(withIdentifier: "editTask", sender: indexPath)
            self.saveTaskItems()
            completionHandler(true)
        }
        return editAction
    }
 
    func configureCheckmark(for cell: UITableViewCell, with item: TaskItem) {
      if item.checked {
        cell.accessoryType = .checkmark
      } else {
        cell.accessoryType = .none
      }
    }
    
    func configureText(for cell: UITableViewCell, with item: TaskItem) {
        let labelTitle = cell.viewWithTag(89) as! UILabel
        let labelList = cell.viewWithTag(3) as! UILabel
        let labelDue = cell.viewWithTag(10) as! UILabel
        labelTitle.text = item.name
        labelList.text = item.list
        switch labelList.text { // ustawienie unikalnych kolorów w zależności od listy
        case NSLocalizedString("WORK_LIST", comment: ""):
            labelList.textColor = UIColor.orange
            labelTitle.textColor = UIColor.orange
        case NSLocalizedString("PERSONAL_LIST", comment: ""):
            labelList.textColor = UIColor.purple
            labelTitle.textColor = UIColor.purple
        case NSLocalizedString("OTHER_LIST", comment: ""):
            labelList.textColor = UIColor.cyan
            labelTitle.textColor = UIColor.cyan
        case .none: break
        case .some(_): break
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        let strDate = dateFormatter.string(from: item.date!)
        labelDue.text = strDate
        
        if (item.date! < Date.now) && !item.checked {   // zmiana koloru daty zadania w przypadku 'przeterminowania'
            labelDue.textColor = UIColor.red
        }
    }
    
    func backgroundViewInit() -> UIView {
        let backgroundView = UIView(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width, height:self.view.bounds.size.height))
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        
        noDataLabel.text          = NSLocalizedString("NO_DATA_TEXT", comment: "")
        noDataLabel.textColor     = UIColor.black
        noDataLabel.numberOfLines = 3
        noDataLabel.backgroundColor = UIColor.white
        noDataLabel.textAlignment = .center
        backgroundView.addSubview(noDataLabel)
        
        return backgroundView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            let controller = segue.destination as! AddViewController
            controller.delegate = self
        } else if segue.identifier == "editTask" {
            let controller = segue.destination as! AddViewController
            controller.delegate = self
            if let indexPath = sender as? IndexPath {   // przekazanie elementu do edycji
              controller.itemToEdit = items[indexPath.row]
            }
        }
    }
    
    // MARK: - Add Item ViewController Delegates
    func addViewControllerDidCancel(_ controller: AddViewController) {
      navigationController?.popViewController(animated: true)
    }

    func addViewControllerDidFinishAdding(_ controller: AddViewController, item: TaskItem) {    // obsługa dodania zadania
        let newRowIndex = items.count
        items.append(item)

        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        let alert = UIAlertController(title: NSLocalizedString("ADD_SUCCESS_TITLE", comment: ""), message: NSLocalizedString("ADD_SUCCES_MESSAGE", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: { action in
            self.navigationController?.popViewController(animated:true)
            self.saveTaskItems()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addViewControllerDidFinishEditing(_ controller: AddViewController, item: TaskItem) {   // obsługa edycji zadania
      if let index = items.firstIndex(of: item) {
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) {
          configureText(for: cell, with: item)
        }
      }
      navigationController?.popViewController(animated: true)
        saveTaskItems()
    }
    


}

