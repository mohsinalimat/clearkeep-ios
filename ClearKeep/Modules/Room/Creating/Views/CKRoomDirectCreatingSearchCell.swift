//
//  CKRoomAddingSearchCell.swift
//  Riot
//
//  Created by Sinbad Flyce on 1/22/19.
//  Copyright © 2019 matrix.org. All rights reserved.
//

import Foundation

final class CKRoomDirectCreatingSearchCell: CKRoomCreatingBaseCell {

    // MARK: - OUTLET
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - PROPERTY
    internal var beginSearchingHandler: ((String) -> Void)?
    
    // MARK: - OVERRIDE
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.searchBar.placeholder = "Search people on Directory"
        self.searchBar.delegate = self
    }
}

extension CKRoomDirectCreatingSearchCell: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        beginSearchingHandler?(searchText)
    }
}