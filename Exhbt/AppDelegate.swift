//
//  AppDelegate.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 27/06/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import AppTrackingTransparency
import Firebase
import FirebaseCore
import FirebaseMessaging
import Kingfisher
import PhotosUI
import Pushy
import UIKit
import UserNotifications
import YPImagePicker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()

        // Configure Kingfisher's Cache
        let cache = ImageCache.default

        // Constrain Memory Cache to 10 MB
        cache.memoryStorage.config.totalCostLimit = 1024 * 1024 * 10

        // Constrain Disk Cache to 500 MB
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 500

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        // Initialize Pushy SDK
        let pushy = Pushy(UIApplication.shared)

        // Register the user for push notifications
        pushy.register({ error, deviceToken in
            // Handle registration errors
            guard error == nil else {
                debugLog(self, "PUSH - Failed to register for push notifications")
                return
            }

            debugLog(self, "PUSH - Registered for push notifications deviceToken: \(deviceToken)")

            // TODO: Find a better way to sync device token
            // Sync device token if needed
            UserSettings.shared.notificationsDeviceToken = deviceToken
            UserSettings.shared.hasSyncedNotificationsDeviceToken = false

        })

        pushy.toggleInAppBanner(true)

        // Handle incoming notifications
        pushy.setNotificationHandler({ data, completionHandler in
            // Print notification payload
            debugLog(self, "PUSH - Received notification: \(data)")

            // Reset iOS badge number (and clear all app notifications)
            UIApplication.shared.applicationIconBadgeNumber = 0

            AppState.shared.shouldRefreshNotificationsBadgeCount.send()

            // Call this completion handler when you finish processing
            // the notification (after any asynchronous operations, if applicable)
            completionHandler(UIBackgroundFetchResult.newData)
        })

        pushy.setNotificationClickListener({ data in
            // Reset iOS badge number (and clear all app notifications)
            UIApplication.shared.applicationIconBadgeNumber = 0

            // Send value to publisher
            AppState.shared.receivedNotification.send()

            debugLog(self, "PUSH - Clicked on notification: \(data)")

        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.requestPermission()
        }

        return true
    }

    func requestPermission() {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            switch status {
            case .authorized:
                // Tracking authorization dialog was shown
                // and we are authorized
                print("Authorized")
            case .denied:
                // Tracking authorization dialog was
                // shown and permission is denied
                print("Denied")
            case .notDetermined:
                // Tracking authorization dialog has not been shown
                print("Not Determined")
            case .restricted:
                print("Restricted ")
            @unknown default:
                break
            }
        })
    }

    // MARK: UISceneSession Lifecycle

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

//    func application(_ application: UIApplication,
//                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
//        -> UIBackgroundFetchResult {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//        // Print message ID.
    ////        if let messageID = userInfo[gcmMessageIDKey] {
    ////            print("Message ID: \(messageID)")
    ////        }
//
//        // Print full message.
//
//        return UIBackgroundFetchResult.newData
//    }
//
//    // [END receive_message]
//    func application(_ application: UIApplication,
//                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Unable to register for remote notifications: \(error.localizedDescription)")
//    }
//
//    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
//    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
//    // the FCM registration token.
//    func application(_ application: UIApplication,
//                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        debugLog(self, "PUSH - didRegisterForRemoteNotificationsWithDeviceToken deviceToken \(deviceToken)")
//
//        // With swizzling disabled you must set the APNs token here.
//        // Messaging.messaging().apnsToken = deviceToken
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//        debugLog(self, "PUSH - userNotificationCenter didReceive")
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
//        debugLog(self, "PUSH - userNotificationCenter willPresent")
//        return [.sound, .badge, .banner]
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
//        debugLog(self, "PUSH - userNotificationCenter openSettingsFor")
//    }
}
