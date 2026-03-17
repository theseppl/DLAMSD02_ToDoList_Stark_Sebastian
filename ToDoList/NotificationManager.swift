//
//  NotificationManager.swift
//  ToDoList
//
//  Created by Sebastian Stark on 09.03.26.
//

import Foundation
import UserNotifications

// Zuständig für Benachrichtigungen (z.B. 15 Minuten vorher...).
class NotificationManager {
    
    // Statisches Proberty -> Wird in der gesamten App verwendet, ohne mehrfach erzeugt zu werden.
    static let shared = NotificationManager()
    
    // Privater Initializer verhindert, dass weitere Instanzen erstellt werden.
    private init() {}
    
    
    // MARK: - Berechtigung anfragen
    
    // Fordert die Berechtigung für lokale Benachrichtigungen an.
    // Diese Anfrage erfolgt einmalig beim ersten App-Start.
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            
            // Fehlerbehandlung
            if let error = error {
                print("Fehler bei der Anfrage:", error)
            }
            
            print("Benachrichtigungen erlaubt:", granted)
        }
    }
    
    
    // MARK: - Erinnerung planen
    
    // Plant eine Benachrichtigung für ein bestimmtes ToDo.
    // Die Erinnerung wird um reminderOffsetMinutes vor dem Fälligkeitsdatum ausgelöst.
    func scheduleNotification(for toDo: ToDo) {
        
        // -1 bedeutet: Nutzer möchte keine Erinnerung für dieses ToDo.
        if toDo.reminderOffsetMinutes == -1 { return }
        
        // Inhalt der Benachrichtigung
        let content = UNMutableNotificationContent()
        content.title = "Erinnerung"
        content.body = "Eine Aufgabe ist fällig: \(toDo.title)"
        content.sound = .default
        
        // Zeitpunkt der Erinnerung berechnen
        let reminderDate = toDo.dueDate.addingTimeInterval(TimeInterval(-toDo.reminderOffsetMinutes * 60))
        
        // Datumsinformationen die der Trigger benötigt
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        
        // Trigger, der die Notification zum richtigen Zeitpunkt auslöst
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )
        
        // Jede Notification erhält die UUID des ToDos als Identifier.
        // Dadurch kann sie später gezielt gelöscht oder ersetzt werden.
        let request = UNNotificationRequest(
            identifier: toDo.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        // Notification beim System registrieren
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Fehler beim Planen der Notification:", error)
            }
        }
    }
    
    
    // MARK: - Erinnerung löschen
    
    // Entfernt eine geplante Benachrichtigung für ein bestimmtes ToDo.
    // Wird z. B. aufgerufen, wenn ein ToDo gelöscht oder geändert wird.
    func removeNotification(for toDo: ToDo) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [toDo.id.uuidString])
    }
}
