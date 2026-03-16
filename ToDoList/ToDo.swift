//
//  ToDo.swift
//  ToDoList
//
//  Created by Sebastian Stark on 02.03.26.
//

import Foundation

// Datenmodell eines einzelnen ToDo-Eintrags.
// Equatable: ermöglicht Vergleiche (z. B. für Updates oder Löschungen)
// Codable: ermöglicht einfaches Speichern/Laden als Property List (plist)
struct ToDo: Equatable, Codable {
    
    // MARK: - Eigenschaften
    
    // Universal Unique ID
    // Eindeutige ID für jedes ToDo.
    // Wird automatisch vergeben und bleibt über die gesamte Lebensdauer stabil.
    let id: UUID
    
    // Titel des ToDos (Pflichtfeld).
    var title: String
    
    // Gibt an, ob das ToDo bereits erledigt wurde.
    var isComplete: Bool
    
    // Fälligkeitsdatum des ToDos.
    var dueDate: Date
    
    // Optionaler Notiztext.
    var notes: String?
    
    // Zeitversatz für Erinnerungen in Minuten (z. B. 15 Minuten vorher).
    var reminderOffsetMinutes: Int
    
    // Optionaler Ortsname, den der Nutzer eingibt.
    var locationName: String?
    
    // Optional gespeicherte Koordinaten für Kartenintegration.
    var latitude: Double?
    var longitude: Double?

    
    // MARK: - Initializer
    
    // Eigener Initializer, um sicherzustellen, dass jedes ToDo eine UUID erhält.
    // Codable benötigt einen expliziten Initializer, wenn zusätzliche Logik vorhanden ist.
    init(title: String, isComplete: Bool, dueDate: Date, notes: String?, reminderOffsetMinutes: Int = 0) {
        
        self.id = UUID() // Jede Instanz erhält einen eindeutigen Identifier.
        self.title = title
        self.isComplete = isComplete
        self.dueDate = dueDate
        self.notes = notes
        self.reminderOffsetMinutes = reminderOffsetMinutes
    }
    
    // MARK: - Speicherpfad
    
    // Basisverzeichnis der App, in dem Nutzerdaten abgelegt werden dürfen.
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // Vollständiger Pfad zur Datei, in der alle ToDos gespeichert werden.
    // Format: Property List (.plist)
    static let archiveURL = documentsDirectory.appendingPathComponent("toDos").appendingPathExtension("plist")
    
    
    // MARK: - Vergleich (Equatable)
    
    // Die Funktion sorgt dafür, dass ToDos über den ==-Operator anhand ihrer ID verglichen werden können.
    // Zwei ToDos gelten als gleich, wenn ihre IDs übereinstimmen.
    // Das ist wichtig, weil Titel, Datum etc. sich ändern können.
    static func == (lhs: ToDo, rhs: ToDo) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    // MARK: - Laden und Speichern
    
    // Lädt gespeicherte ToDos aus der plist-Datei.
    // Gibt nil zurück, wenn keine Datei existiert oder ein Fehler auftritt.
    static func loadToDos() -> [ToDo]? {
        guard let codedToDos = try? Data(contentsOf: archiveURL) else {return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<ToDo>.self, from: codedToDos)
    }
    
    // Speichert ein Array von ToDos persistent in einer plist-Datei.
    static func saveToDos(_ toDos: [ToDo]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedToDos = try? propertyListEncoder.encode(toDos)
        try? codedToDos?.write(to: archiveURL, options: .noFileProtection)
    }
    
    
    // MARK: - Beispieldaten
    
    // Testdaten
    // Werden exemplarisch in die App geladen, wenn keine eigenen Aufgaben hinterlegt sind.
    static func loadSampleToDos() -> [ToDo] {
        
        let toDo1 = ToDo(title: "Geschirr abwaschen", isComplete: false, dueDate: Date(), notes: "... und abtrocknen.")
        let toDo2 = ToDo(title: "Rasen mähen", isComplete: false, dueDate: Date(), notes: "Es regnet heute zum Glück.")
        let toDo3 = ToDo(title: "Lernen lernen", isComplete: false, dueDate: Date(), notes: "...lernen.")
        return [toDo1, toDo2, toDo3]
    }
}
