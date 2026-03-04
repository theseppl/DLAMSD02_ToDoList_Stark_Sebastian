//
//  ToDoDetailTableViewController.swift
//  ToDoList
//
//  Created by Sebastian Stark on 04.03.26.
//

import UIKit

class ToDoDetailTableViewController: UITableViewController {
    
    
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var isCompleteButton: UIButton!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var dueDateDatePicker: UIDatePicker!
    @IBOutlet var notesTextView: UITextView!
    
    //Ruft bei jeder Änderung des Textfeldes updateSaveButtonState auf.
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    // Setzt den Status des Save-Buttons in Abhängigkeit zum Inhalt des Textfeldes.
    func updateSaveButtonState() {
        // shouldEnableSaveButton ist ein Boolean
        let shouldEnableSaveButton = titleTextField.text?.isEmpty == false
        saveButton.isEnabled = shouldEnableSaveButton
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveButtonState()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
