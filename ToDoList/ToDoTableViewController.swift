//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by Sebastian Stark on 02.03.26.
//

import Foundation
import UIKit

class ToDoTableViewController: UITableViewController, ToDoCellDelegate {
    var toDos = [ToDo]()
    
    // Gibt die Anzahl an Objekten in der Sektion zurück.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDos.count
    }
    
    // Liefert eine konfigurierte UITableViewCell für die angefragte Zeile zurück.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Holt eine Zelle als Instanz der Klasse ToDoCell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell
        
        // Holt die Daten für die Zelle.
        let toDo = toDos[indexPath.row]
        cell.titleLabel?.text = toDo.title
        cell.isCompleteButton.isSelected = toDo.isComplete
        
        // ToDoTableViewController setzt sich als Cell-Delegate
        cell.delegate = self
        
        /*
         // Darstellung der Zelle erzeugen.
         var content = cell.defaultContentConfiguration()
         content.text = toDo.title
         
         // Zelle übernimmt erzeugte Darstellung.
         cell.contentConfiguration = content
         
         */
        
        return cell
    }
    
    // Gibt zurück, welche Zellen bearbeitet werden können. (hier alle)
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Wird eine Zelle nach links gewischt, erscheint ein Delete-Button.
    // Es wird dafür gesorgt, dass die ToDo-Daten aus dem Array
    // und die Zeile aus der TableView entfernt werden.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            toDos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            // Persistente Speicherung.
            ToDo.saveToDos(toDos)
        }
    }
    
    // Methode wird ausgeführt, wenn zur ToDo-List zurückgekehrt wird.
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
                
                // Existierende ToDos und tableView-Zeilen aktualisieren
                toDos[indexOfExistingToDo] = toDo
                tableView.reloadRows(at: [IndexPath(row: indexOfExistingToDo, section: 0)], with: .automatic)
                
            } else {
                // Neues toDo am Ende des Array anhängen.
                let newIndexPath = IndexPath(row: toDos.count, section: 0)
                toDos.append(toDo)
                
                // Neue Zeile in tableView einfügen
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        ToDo.saveToDos(toDos)
    }
    
    @IBSegueAction func editToDo(_ coder: NSCoder, sender: Any?) -> ToDoDetailTableViewController? {
        
        // Eine Instanz des ToDoDetailTableViewController wird erstellt.
        let detailController = ToDoDetailTableViewController(coder: coder)
        
        // Prüfung, ob der Sender eine Zelle ist.
        // Wurde Add-Button gedrückt, ist der Sender keine Zelle
        // -> ein leerer detailController wird zurückgegeben.
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            // Wenn der Sender der Add-Button ist, gib einen leeren Controller zurück.
            return detailController
        }
        
        // Wurde eine Zelle ausgewählt wird dem Controller das entsprechende ToDo übergeben
        // und dieser zurückgegeben.
        tableView.deselectRow(at: indexPath, animated: true)
        detailController?.toDo = toDos[indexPath.row]
        return detailController
    }
    
    // Funktion zum Protokoll ToDoCellDelegate
    // Über den Index des Zelle wird der passende CheckMarkButton gefunden
    // und umgeschaltet.
    func checkMarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            var toDo = toDos[indexPath.row]
            toDo.isComplete.toggle()
            toDos[indexPath.row] = toDo
            tableView.reloadRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(toDos)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Wenn es ToDo-Daten auf dem Festspeicher gibt, werden sie geladen.
        // Wenn nicht, werden die ToDo-Testdaten geladen.
        if let savedToDos = ToDo.loadToDos() {
            toDos = savedToDos
        } else {
            toDos = ToDo.loadSampleToDos()
        }
        
        // Erstellt den intelligenten Edit-Button für Anzeige der Delete-Buttons
        navigationItem.leftBarButtonItem = editButtonItem
    }
}
