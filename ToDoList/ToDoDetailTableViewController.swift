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
    
    // MARK: Status des Save-Buttons
    
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
    
    // MARK: Ausblenden der UI-Tastatur
    
    // Sorgt dafür, dass beim Drücken der Enter-Taste auf der UI-Tastatur
    // die Tastatur ausgeblendet wird.
    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    // MARK: Umschalten des "Erledigt-Hakens"
    
    // Schaltet den Button um. Setzt bzw. löscht das Häkchen.
    @IBAction func isCompleteButtonTapped(_ sender: UIButton) {
        isCompleteButton.isSelected.toggle()
    }
    
    // MARK: Datumstextfeld updaten
    
    // Formatiert und setzt den Text in das Datumstextfeld.
    func updateDueDateLabel(date: Date) {
        dueDateLabel.text = date.formatted(.dateTime.month(.defaultDigits).day().year(.defaultDigits).hour().minute())
    }
    
    // Ruft bei jeder Änderung am DatePicker updateDueDateLabel() auf
    // und übergibt dabei das neue Datum.
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDueDateLabel(date: sender.date)
    }
    
    // MARK: viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveButtonState()
        updateDueDateLabel(date: dueDateDatePicker.date)
        
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
