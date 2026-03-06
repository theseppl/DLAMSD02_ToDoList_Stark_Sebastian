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
    
    var isDatePickerHidden = true
    let dateLabelIndexPath = IndexPath(row: 0, section: 1)
    let datePickerIndexPath = IndexPath(row: 1, section: 1)
    let notesIndexPath = IndexPath(row: 0, section: 2)
    
    var toDo: ToDo?
    
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
        dueDateLabel.text = date.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year(.defaultDigits).hour().minute())
    }
    
    // Ruft bei jeder Änderung am DatePicker updateDueDateLabel() auf
    // und übergibt dabei das neue Datum.
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDueDateLabel(date: sender.date)
    }
    
    // MARK: Ein- und Ausblenden des DatePickers
    
    // Wenn der übergebene Index der des DatePickers ist, wird in Abhängigkeit
    // vom Flag die Höhe der Zeile ggf. auf 0 gesetzt.
    // Die Zeile für die Notizen erhält eine feste Höhe von 200.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerIndexPath where isDatePickerHidden == true:
            return 0
        case datePickerIndexPath:
            return 216
        case notesIndexPath:
            return 200
        default:
            return UITableView.automaticDimension
        }
    }
    
    /*
     override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
     switch indexPath {
     case datePickerIndexPath:
     return 216
     case notesIndexPath:
     return 200
     default:
     return UITableView.automaticDimension
     }
     }
     */
    
    // Wenn der Index der des DateLabels betätigt wird, wird das Flag umgeschaltet.
    // Das Label aufgefrischt und die tableView geupdated.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == dateLabelIndexPath {
            isDatePickerHidden.toggle()
            updateDueDateLabel(date: dueDateDatePicker.date)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    // MARK: Daten für Übergabe vorbereiten
    
    // Wenn sichergestellt ist, das die saveUnwind-Segue ausgeführt werden soll,
    // werden die Werte aus der Eingabe in Konstanten gespeichert und für die Segue vorbereitet.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
        
        // Holt die Werte aus den UI-Elementen
        let title = titleTextField.text!
        let isComplete = isCompleteButton.isSelected
        let dueDate = dueDateDatePicker.date
        let notes = notesTextView.text
        
        // Wenn toDo bereits existiert, werden die vorhandenen Werte überschrieben.
        // Ansonsten ein neues toDo-Objekt erstellt.
        if toDo != nil {
            toDo?.title = title
            toDo?.isComplete = isComplete
            toDo?.dueDate = dueDate
            toDo?.notes = notes
        } else {
            toDo = ToDo(title: title, isComplete: isComplete, dueDate: dueDate, notes: notes)
        }
    }
    
    // MARK: viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentDueDate: Date
        if let toDo = toDo {
            navigationItem.title = "ToDo"
            titleTextField.text = toDo.title
            isCompleteButton.isSelected = toDo.isComplete
            currentDueDate = toDo.dueDate
            notesTextView.text = toDo.notes
        } else {
            currentDueDate = Date().addingTimeInterval(86400)
        }
        
        dueDateDatePicker.date = currentDueDate
        updateDueDateLabel(date: currentDueDate)
        updateSaveButtonState()
        
        
        // updateSaveButtonState()
        
        // Setzt das angezeigte Datum im Textfeld per Default 24h in die Zukunft.
        dueDateDatePicker.date = Date().addingTimeInterval(86400)
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
