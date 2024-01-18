//
//  SessionDelegator.swift
//  Rythmm
//
//  Created by Dominik Deren on 04/01/2024.
//

import Foundation
import WatchConnectivity

#if os(watchOS)
import ClockKit
#endif

// Custom notifications happen when Watch Connectivity activation or reachability status changes,
// or when receiving or sending data. Clients observe these notifications to update the UI.
//
extension Notification.Name {
    static let dataDidFlow = Notification.Name("DataDidFlow")
    static let activationDidComplete = Notification.Name("ActivationDidComplete")
    static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
}

// Implement WCSessionDelegate methods to receive Watch Connectivity data and notify clients.
// Handle WCSession status changes.
//
class SessionDelegator: NSObject, WCSessionDelegate {
    
    let session: WCSession
    
    init (session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.connect()
    }
    
    func connect() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
       
        session.activate()
    }
    
    // Monitor WCSession activation state changes.
    //
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activation state: \(activationState) error: \(String(describing: error)) \(session.isReachable)")
        postNotificationOnMainQueueAsync(name: .activationDidComplete)
    }
    
    // Monitor WCSession reachability state changes.
    //
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("sessionReachabilityDidChange: \(session.isReachable)")
        postNotificationOnMainQueueAsync(name: .reachabilityDidChange)
    }
    
    // Did receive a piece of message data, and the peer doesn't need a response.
    //
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        postNotificationOnMainQueueAsync(name: .dataDidFlow, object: messageData)
    }
//    
//    // Did receive a piece of message data, and the peer needs a response.
//    //
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        self.session(session, didReceiveMessageData: messageData)
        replyHandler(messageData) // Echo back the time stamp.
    }
    // WCSessionDelegate methods for iOS only.
    //
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    #endif
    
    // Post a notification on the main thread asynchronously.
    //
    private func postNotificationOnMainQueueAsync(name: NSNotification.Name, object: Data? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: object)
        }
    }
}
