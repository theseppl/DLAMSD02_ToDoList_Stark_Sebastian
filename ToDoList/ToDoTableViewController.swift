//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by Sebastian Stark on 02.03.26.
//

import Foundation
import UIKit

class ToDoTableViewController: UITableViewController {
    var toDos = [ToDo]()
    
    // Gibt die Anzahl an Objekten in der Sektion zurück.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDos.count
    }
    
    // Liefert eine konfigurierte UITableViewCell für die angefragte Zeile zurück.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Holt eine Zelle.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath)
        
        // Holt die Daten für die Zelle.
        let toDo = toDos[indexPath.row]
        
        // Darstellung der Zelle erzeugen.
        var content = cell.defaultContentConfiguration()
        content.text = toDo.title
        
        // Zelle übernimmt erzeugte Darstellung.
        cell.contentConfiguration = content
        return cell
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
    }
}
