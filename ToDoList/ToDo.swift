//
//  ToDo.swift
//  ToDoList
//
//  Created by Sebastian Stark on 02.03.26.
//

import Foundation

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
}
