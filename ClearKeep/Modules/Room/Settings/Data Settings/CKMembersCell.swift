//
//  MembersCell.swift
//  FileXib
//
//  Created by Hiếu Nguyễn on 1/9/19.
//  Copyright © 2019 Hiếu Nguyễn. All rights reserved.
//

import UIKit

class CKMembersCell: UITableViewCell {

    @IBOutlet weak var imageMember: UIImageView!
    @IBOutlet weak var btnMembers: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageMember.image = UIImage(named: "ic_room_members")
        self.accessoryType = .disclosureIndicator
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
