//
//  CKRoomBaseCell.swift
//  Riot
//
//  Created by Sinbad Flyce on 1/19/19.
//  Copyright © 2019 matrix.org. All rights reserved.
//

import Foundation

class CKRoomBaseCell: UITableViewCell {
    
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
