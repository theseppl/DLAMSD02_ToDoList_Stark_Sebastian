//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by Sebastian Stark on 02.03.26.
//

import Foundation
import UIKit

// Hauptliste aller ToDos.
// Zeigt offene, erledigte und gefilterte Aufgaben an.
class ToDoTableViewController: UITableViewController, ToDoCellDelegate {
    
    
    // MARK: - Eigenschaften
    
    // Hauptliste aller ToDos.
    var toDos = [ToDo]()
    
    // Gefilterte Liste (z. B. nur offene oder nur erledigte).
    var filteredToDos = [ToDo]()
    
    // Gibt an, ob aktuell ein Filter aktiv ist.
    var isFiltering = false
    
    
    // MARK: - TableView Datenquelle
    
    // Anzahl der Zeilen in der Tabelle.
    // Wenn gefiltert wird → gefilterte Liste, sonst komplette Liste.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredToDos.count : toDos.count
    }
    
    // Liefert eine konfigurierte UITableViewCell für die angefragte Zeile zurück.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Zelle vom Typ ToDoCell abrufen.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell
        
        // Passendes ToDo auswählen (gefiltert oder ungefiltert).
        let toDo = isFiltering ? filteredToDos[indexPath.row] : toDos[indexPath.row]
        
        // UI der Zelle setzen.
        cell.titleLabel?.text = toDo.title
        cell.isCompleteButton.isSelected = toDo.isComplete
        
        // Der Controller wird als Delegate gesetzt,
        // damit er auf Button-Taps in der Zelle reagieren kann.
        cell.delegate = self
        return cell
    }
    
    
    // MARK: - Löschen von ToDos
    
    // Gibt zurück, welche Zellen bearbeitet werden können. (hier alle)
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Wird eine Zelle nach links gewischt, erscheint ein Delete-Button.
    // Es wird dafür gesorgt, dass die ToDo-Daten aus dem Array und die Zeile aus der TableView entfernt werden.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // Das korrekte ToDo ermitteln (gefiltert oder ungefiltert).
            let toDoToDelete = isFiltering ? filteredToDos[indexPath.row] : toDos[indexPath.row]
            
            // Aus Hauptliste löschen
            if let index = toDos.firstIndex(of: toDoToDelete) {
                toDos.remove(at: index)
            }
            
            // Aus Filterliste löschen
            if isFiltering {
                filteredToDos.remove(at: indexPath.row)
            }
            
            // Zeile aus Tabelle entfernen.
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Änderungen speichern.
            ToDo.saveToDos(toDos)
            
            // Filter erneut anwenden, damit die Ansicht konsistent bleibt.
            if isFiltering {
                applyFilter(.open) // oder .completed, je nach aktivem Filter
            }
        }
    }
    
    
    // MARK: - Rückkehr aus dem Detail-Controller
    
    // Wird ausgeführt, wenn der Nutzer im Detail-Controller auf „Speichern“ tippt.
    @IBAction func unwindToToDoList(segue: UIStoryboardSegue) {
        
        // Sichergehen, dass die übergebene Segue vom Save-Button stammt.
        // -> Der Save-Button wurde gedrückt.
        guard segue.identifier == "saveUnwind" else {return}
        let sourceViewController = segue.source as! ToDoDetailTableViewController
        
        // Wenn eine Instanz des Datenmodells im Quell-Viewcontroller der Segue existiert,
        // wird diese Instanz am Ende des ToDos-Arrays angehängt und in die tableView eingefügt.
        // Bzw. bestehende ToDos und tableViews aktualisiert.
        if let toDo = sourceViewController.toDo {
            
            // Prüft, ob dieses ToDo bereits in der Liste existiert.
            if let indexOfExistingToDo = toDos.firstIndex(of: toDo) {
                
                // Existierendes ToDo aktualisieren
                toDos[indexOfExistingToDo] = toDo
                
                // Bestehende Mitteilung löschen und neue planen
                NotificationManager.shared.removeNotification(for: toDo)
                // Mitteilung neu planen
                if toDo.reminderOffsetMinutes != -1 {
                    NotificationManager.shared.scheduleNotification(for: toDo)
                }
                
                // Zeile aktualisieren.
                tableView.reloadRows(at: [IndexPath(row: indexOfExistingToDo, section: 0)], with: .automatic)
                
                // Wenn ToDo noch nicht in Liste existiert.
            } else {
                // Neues toDo am Ende des Array anhängen.
                let newIndexPath = IndexPath(row: toDos.count, section: 0)
                toDos.append(toDo)
                
                // Erinnerung planen.
                NotificationManager.shared.scheduleNotification(for: toDo)
                
                // Neue Zeile einfügen
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        
        // Änderungen speichern.
        ToDo.saveToDos(toDos)
        
        // Filter aktualisieren.
        if isFiltering {
            applyFilter(.open) // oder .completed, je nach aktivem Filter
        }
    }
    
    
    // MARK: - Navigation zu Detail-Controller
    
    // Wird aufgerufen, wenn eine Zelle oder der Add-Button gedrückt wird.
    @IBSegueAction func editToDo(_ coder: NSCoder, sender: Any?) -> ToDoDetailTableViewController? {
        
        // Eine Instanz des ToDoDetailTableViewController wird erstellt.
        let detailController = ToDoDetailTableViewController(coder: coder)
        
        // Prüfung, ob der Sender eine Zelle ist. -> ToDo bearbeiten
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell)
                
        // Wenn der Sender der Add-Button ist, gib einen leeren Controller zurück.
        // Es wird ein leerer detailController zurückgegeben.
        else {
            return detailController
        }
        
        // Wurde eine Zelle ausgewählt wird dem Controller das entsprechende ToDo übergeben
        // und dieser zurückgegeben.
        tableView.deselectRow(at: indexPath, animated: true)
        detailController?.toDo = toDos[indexPath.row]
        return detailController
    }
    
    
    // MARK: - Delegate: Checkmark in Zelle getippt
    
    // Funktion zum Protokoll ToDoCellDelegate
    // Wird aufgerufen, wenn der Nutzer in einer Zelle den Haken antippt.
    // Über den Index des Zelle wird der passende CheckMarkButton gefunden und umgeschaltet.
    func checkMarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            
            // ToDo erledigt umschalten.
            var toDo = toDos[indexPath.row]
            toDo.isComplete.toggle()
            toDos[indexPath.row] = toDo
            
            // Speichern.
            ToDo.saveToDos(toDos)
            
            // Filter aktualisieren.
            if isFiltering {
                applyFilter(.open)
            } else {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    
    // MARK: - Filter-Menü
    
    // Filter: Alle Aufgaben
    @IBAction func filterAllTapped(_ sender: UIBarButtonItem) {
        applyFilter(.all)
    }
    
    // Filter: Offene Aufgaben
    @IBAction func filterOpenTapped(_ sender: UIBarButtonItem) {
        applyFilter(.open)
    }
    
    // Filter: Abgeschlossene Aufgaben
    @IBAction func filterCompletedTapped(_ sender: UIBarButtonItem) {
        applyFilter(.completed)
    }
    
    
    // MARK: - Filter-Logik
    
    enum FilterType {
        case all
        case open
        case completed
    }
    
    // Wendet den ausgewählten Filter an.
    func applyFilter(_ type: FilterType) {
        switch type {
            
        // Es wird nicht gefiltert.
        // Das Array filteredToDos bleibt leer.
        case .all:
            isFiltering = false
            filteredToDos = []
        
        // Es wird gefiltert.
        // Das Array filteredToDos erhält offene Aufgaben.
        case .open:
            isFiltering = true
            filteredToDos = toDos.filter { !$0.isComplete }
        
        // Es wird gefiltert.
        // Das Array filteredToDos erhält abgeschlossene Aufgaben.
        case .completed:
            isFiltering = true
            filteredToDos = toDos.filter { $0.isComplete }
        }
        
        // Die Tabellensicht wird aufgefrischt.
        tableView.reloadData()
    }
    
    
    // MARK: - Bearbeiten-Button
    
    // Schaltet den Bearbeitungsmodus ein/aus.
    @objc func toggleEditMode() {
        setEditing(!isEditing, animated: true)
        
        // Titel dynamisch anpassen
        navigationItem.leftBarButtonItem?.title = isEditing ? "Fertig" : "Bearbeiten"
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ToDos laden (persistente Daten oder Beispiel-Daten).
        if let savedToDos = ToDo.loadToDos() {
            toDos = savedToDos
        } else {
            toDos = ToDo.loadSampleToDos()
        }
        
        // Berechtigung für Benachrichtigungen anfragen.
        NotificationManager.shared.requestAuthorization()
        
        // Benutzerdefinierter Bearbeiten-Button.
        let customEditButton = UIBarButtonItem(
            title: "Bearbeiten",
            style: .plain,
            target: self,
            action: #selector(toggleEditMode)
        )
        navigationItem.leftBarButtonItem = customEditButton
    }
}
