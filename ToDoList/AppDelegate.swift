//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Sebastian Stark on 02.03.26.
//

import UIKit

// Einstiegspunkt der App.
// Der AppDelegate reagiert auf globale Ereignisse wie App-Start,
// Benachrichtigungen oder das Erstellen neuer UI-Szenen.

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    
    // MARK: - App Start
    
    // Wird aufgerufen, sobald die App gestartet wurde.
    // Hier ist der den Notification-Delegate implementiert, damit Benachrichtigungen
    // auch angezeigt werden, wenn die App im Vordergrund läuft.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Der AppDelegate empfängt Benachrichtigungen, auch wenn die App geöffnet ist.
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    
    // MARK: - Benachrichtigungen im Vordergrund
    
    // Wird aufgerufen, wenn eine Benachrichtigung eintrifft, während die App aktiv im Vordergrund ist.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
 
    
    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

