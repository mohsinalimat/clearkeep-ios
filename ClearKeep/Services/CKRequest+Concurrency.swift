//
//  CKRequest+Concurrency.swift
//  Riot
//
//  Created by klinh on 8/28/19.
//  Copyright © 2019 matrix.org. All rights reserved.
//

import Foundation
import PromiseKit

extension CKAPIClient {
    // Pseudo code, will be updated
    func generatePassphraseAndBackupKey(_ model: CKPassphrase.Request, keyModel: CKPassphrase.Request, completion: @escaping(CKPassphrase.Response?, CKPassphrase.Response?, Error?) -> Void ) {
        firstly {
            when(fulfilled: generatePassphrase(model), generateBackupKey(keyModel))
            }.done ({ tagsResponse, courseResponse in
                completion(tagsResponse, courseResponse, nil)
            }).catch ({ error in
                completion(nil, nil, error)
            })
    }
}
