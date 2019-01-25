//
//  ImagePickerSelectionPolicy.swift
//  Image Picker
//
//  Created by Peter Stajger on 06/09/2017.
//  Copyright © 2017 Inloop. All rights reserved.
//

import Foundation

///
/// Helper class that determines which cells are selected, multiple selected or
/// highlighted.
///
/// We allow selecting only asset items, action items are only highlighted,
/// camera item is untouched.
///
struct ImagePickerSelectionPolicy {
    
    func shouldSelectItem(atSection section: Int, layoutConfiguration: LayoutConfiguration) -> Bool {
        switch section {
        case layoutConfiguration.sectionIndexForActions, layoutConfiguration.sectionIndexForCamera:
            return false
        default:
            return true
        }
    }
    
    func shouldHighlightItem(atSection section: Int, layoutConfiguration: LayoutConfiguration) -> Bool {
        switch section {
        case layoutConfiguration.sectionIndexForCamera:
            return false
        default:
            return true
        }
    }
    
}
