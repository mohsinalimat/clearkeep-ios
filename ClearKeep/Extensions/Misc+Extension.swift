//
//  Misc+Extension.swift
//  Riot
//
//  Created by Sinbad Flyce on 1/25/19.
//  Copyright © 2019 matrix.org. All rights reserved.
//

import Foundation

extension MXKTableViewCell {

    // MARK: - CLASS VAR
    class var className: String {
        return String(describing: self)
    }
    
    // MARK: - CLASS OVERRIDEABLE
    
    open class var identifier: String {
        return self.nibName
    }
    
    open class var nibName: String {
        return self.className
    }
    
    class var nib: UINib {
        return UINib.init(nibName: self.nibName, bundle: nil)
    }
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}


extension MXRoomState {
    
    /**
     Try to get created of Date
     */
    var createdDate: Date? {
        
        // loop via rse
        for rev in self.stateEvents {
            
            // is room create event
            if rev.eventType == __MXEventTypeRoomCreate {
                
                // found created date
                return Date(timeIntervalSince1970: TimeInterval(rev.ageLocalTs / 1000))
            }
        }
        
        // not found
        return nil
    }
}

extension MXEvent {
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(self.ageLocalTs / 1000))
    }
}