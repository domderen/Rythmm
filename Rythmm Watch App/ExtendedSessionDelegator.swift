//
//  ExtendedSessionDelegator.swift
//  Rythmm Watch App
//
//  Created by Dominik Deren on 09/01/2024.
//

import Foundation
import WatchKit

class ExtendedSessionDelegator: NSObject, WKExtendedRuntimeSessionDelegate, ObservableObject {
    static let sessionStarted = Notification.Name("SessionStarted")
    
    @Published var extendedSession: WKExtendedRuntimeSession
    
    init(extendedSession: WKExtendedRuntimeSession = WKExtendedRuntimeSession()) {
        self.extendedSession = extendedSession
        super.init()
        self.extendedSession.delegate = self
    }
    
    func initExtSession() {
        self.extendedSession = WKExtendedRuntimeSession()
        self.extendedSession.delegate = self
    }
    
    func start() {
        switch (self.extendedSession.state) {
        case .running, .scheduled:
            print("Extended session already started")
        case .notStarted:
            print("Starting extended session")
            self.extendedSession.start()
        case .invalid:
            print("Extended session is invalid, recreating and starting.")
            initExtSession()
            self.extendedSession.start()
        default:
            print("Unhandled extended session state \(String(describing: self.extendedSession.state))")
        }
    }
    
    func stop() {
        print("In stop session \(String(describing: self.extendedSession.state))")
        if self.extendedSession.state == .running {
            self.extendedSession.invalidate()
        }
    }
    
    // MARK:- Extended Runtime Session Delegate Methods
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended session started")
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Self.sessionStarted, object: nil)
        }
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Finish and clean up any tasks before the session ends.
        print("Extended session about to expire")
    }
        
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        // Track when your session ends.
        // Also handle errors here.
        print("Extended session about to die, reason: \(reason), error: \(String(describing:error))")
    }
    
    deinit {
        self.stop()
    }
}
