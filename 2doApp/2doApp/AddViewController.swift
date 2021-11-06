//
//  AddViewController.swift
//  2doApp
//
//  Created by Michal T on 29/10/2021.
//

import Foundation
import UIKit

protocol AddViewControllerDelegate: AnyObject {
  func addViewControllerDidCancel(_ controller: AddViewController)  // obsługa anulowania dodawania zadania
  func addViewControllerDidFinishAdding(_ controller: AddViewController, item: TaskItem)    // obsługa dodawania zadania
    func addViewControllerDidFinishEditing(_ controller: AddViewController, item: TaskItem) // obsługa edycji zadania
}

class AddViewController: UITableViewController, UITextFieldDelegate, AddViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var listPicker: UIPickerView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    weak var delegate: AddViewControllerDelegate?
    
    var itemToEdit: TaskItem?
    var pickedList: String? = ""
    var taskList = [NSLocalizedString("WORK_LIST", comment: ""), NSLocalizedString("PERSONAL_LIST", comment: ""),NSLocalizedString("OTHER_LIST", comment: "")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listPicker.delegate = self
        listPicker.dataSource = self
        navigationItem.largeTitleDisplayMode = .never
        if let item = itemToEdit {
            editModeSetup(item: item)
        } else {
            doneButton.isEnabled = false
            listPicker.selectRow(0, inComponent: 0, animated: true)
            self.pickedList = self.taskList[0]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      nameTextField.becomeFirstResponder()  // focus na nameTextField
    }
    
    func editModeSetup(item: TaskItem) {    // ustawienia pod edycje zadania
        title = NSLocalizedString("EDIT_TITLE", comment: "")
        nameTextField.text = item.name
        datePicker.date = item.date!
        doneButton.isEnabled = true
        switch item.list {
        case NSLocalizedString("WORK_LIST", comment: ""):
            listPicker.selectRow(0, inComponent: 0, animated: true)
            self.pickedList = self.taskList[0]
        case NSLocalizedString("PERSONAL_LIST", comment: ""):
            listPicker.selectRow(1, inComponent: 0, animated: true)
            self.pickedList = self.taskList[1]
        case NSLocalizedString("OTHER_LIST", comment: ""):
            listPicker.selectRow(2, inComponent: 0, animated: true)
            self.pickedList = self.taskList[2]
        default:
            break
        }
    }
    
    // MARK: - Actions from navigation
    @IBAction func cancel() {
        delegate?.addViewControllerDidCancel(self)
    }

    @IBAction func done() {
        if let item = itemToEdit {
            item.name = nameTextField.text!
            item.date = datePicker.date
            item.list = pickedList!
            delegate?.addViewControllerDidFinishEditing(self, item: item)
        } else {
            if (nameTextField.text!.count > 0 && pickedList != "") {
                let item = TaskItem()
                item.name = nameTextField.text!
                item.date = datePicker.date
                item.list = pickedList!
                
                delegate?.addViewControllerDidFinishAdding(self, item: item)
            } else {    // komunikat o nie udanym dodaniu zadania
                let alert = UIAlertController(title: NSLocalizedString("ADD_ERROR", comment: ""), message: NSLocalizedString("ADD_ERROR_MESSAGE", comment: ""), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      return nil
    }
    
    // MARK: - Text Field Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      let oldText = textField.text!
      let stringRange = Range(range, in: oldText)!
      let newText = oldText.replacingCharacters(in: stringRange, with: string)
      if newText.isEmpty {
        doneButton.isEnabled = false    // blokowanie przycisku Done
      } else {
          if (pickedList != "") {   // odblokowanie przycisku Done przy wybranej liscie
              doneButton.isEnabled = true
          }
      }
      return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
      doneButton.isEnabled = false
      return true
    }
    
    // MARK: - Add Item ViewController Delegates
    func addViewControllerDidCancel(_ controller: AddViewController) {
      navigationController?.popViewController(animated: true)
    }

    func addViewControllerDidFinishAdding(_ controller: AddViewController, item: TaskItem) {
      navigationController?.popViewController(animated: true)
    }
    
    func addViewControllerDidFinishEditing(_ controller: AddViewController, item: TaskItem) {
      navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UIPickerView Delegate && DateSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  self.taskList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.taskList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickedList = self.taskList[row]
        if (nameTextField.text!.count > 0) {    // odblokowaniu przycisku Done przy jakims tekscie w tytule zadania
            doneButton.isEnabled = true
        }
    }
}
