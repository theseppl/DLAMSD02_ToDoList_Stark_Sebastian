//
//  NotificationManager.swift
//  ToDoList
//
//  Created by Sebastian Stark on 09.03.26.
//

import Foundation
import UserNotifications

import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    private init() {}
    
    
    // MARK: - Berechtigung anfragen
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("Fehler bei der Anfrage:", error)
            }
            print("Benachrichtigungen erlaubt:", granted)
        }
    }
    
    
    // MARK: - Erinnerung planen
    func scheduleNotification(for toDo: ToDo) {
        
        let content = UNMutableNotificationContent()
        content.title = "Erinnerung"
        content.body = "Dein ToDo ist fällig: \(toDo.title)"
        content.sound = .default
        
        // Datum des ToDos → Trigger
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: toDo.dueDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: toDo.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Fehler beim Planen der Notification:", error)
            }
        }
    }
    
    
    // MARK: - Erinnerung löschen
    func removeNotification(for toDo: ToDo) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [toDo.id.uuidString])
    }
}


