//
//  ToDo.swift
//  ToDoList
//
//  Created by Sebastian Stark on 02.03.26.
//

import Foundation

// Modell eines ToDo-Objektes
struct ToDo: Equatable {
    
    // Universal Unique ID
    // Jede Instanz erhält automatisch einen eindeutigen Identifier.
    let id = UUID()
    
    var title: String
    var isComplete: Bool
    var dueDate: Date
    var notes: String?
    
    // Die Funktion sorgt dafür, dass ToDos über den ==-Operator
    // anhand ihrer ID verglichen werden können.
    static func == (lhs: ToDo, rhs: ToDo) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Funktion lädt vorhandene ToDos aus dem Permanentspeicher
    // und gibt diese an die aufrufende Stelle zurück.
    static func loadToDos() -> [ToDo]? {
        return nil
    }
    
    // Testdaten
    static func loadSampleToDos() -> [ToDo] {
        
        let toDo1 = ToDo(title: "To-Do One", isComplete: false, dueDate: Date(), notes: "Notes 1")
        let toDo2 = ToDo(title: "To-Do Two", isComplete: false, dueDate: Date(), notes: "Notes 2")
        let toDo3 = ToDo(title: "To-Do Three", isComplete: false, dueDate: Date(), notes: "Notes 3")
        
        return [toDo1, toDo2, toDo3]
    }
    
}
