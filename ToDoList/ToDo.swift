//
//  ToDo.swift
//  ToDoList
//
//  Created by Sebastian Stark on 02.03.26.
//

import Foundation

// Modell eines ToDo-Objektes
struct ToDo: Equatable, Codable {
    
    // Universal Unique ID
    let id: UUID
    
    var title: String
    var isComplete: Bool
    var dueDate: Date
    var notes: String?
    var reminderOffsetMinutes: Int
    
    // Eigener Initializer um UUID und Codable zu ermöglichen.
    init(title: String, isComplete: Bool, dueDate: Date, notes: String?, reminderOffsetMinutes: Int = 0) {
        // Jede Instanz erhält einen eindeutigen Identifier.
        self.id = UUID()
        self.title = title
        self.isComplete = isComplete
        self.dueDate = dueDate
        self.notes = notes
        self.reminderOffsetMinutes = reminderOffsetMinutes
    }
    
    // Der Pfad für die persistente Speicherung wird definiert.
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("toDos").appendingPathExtension("plist")
    
    // Die Funktion sorgt dafür, dass ToDos über den ==-Operator
    // anhand ihrer ID verglichen werden können.
    static func == (lhs: ToDo, rhs: ToDo) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Funktion lädt vorhandene ToDos aus dem persitenten Speicher
    // und gibt diese an die aufrufende Stelle zurück.
    static func loadToDos() -> [ToDo]? {
        guard let codedToDos = try? Data(contentsOf: archiveURL) else {return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<ToDo>.self, from: codedToDos)
    }
    
    // Funktion zum Speichern von ToDos im persistenten Speicher.
    static func saveToDos(_ toDos: [ToDo]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedToDos = try? propertyListEncoder.encode(toDos)
        try? codedToDos?.write(to: archiveURL, options: .noFileProtection)
    }
    
    // Testdaten
    static func loadSampleToDos() -> [ToDo] {
        
        let toDo1 = ToDo(title: "To-Do One", isComplete: false, dueDate: Date(), notes: "Notes 1")
        let toDo2 = ToDo(title: "To-Do Two", isComplete: false, dueDate: Date(), notes: "Notes 2")
        let toDo3 = ToDo(title: "To-Do Three", isComplete: false, dueDate: Date(), notes: "Notes 3")
        return [toDo1, toDo2, toDo3]
    }
}
