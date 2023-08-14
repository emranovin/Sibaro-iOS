//
//  I18nService.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/23/1402 AP.
//

import Foundation

@dynamicMemberLookup
class I18nService: ObservableObject {
    
    private let storage = StorageService()
    
    var i18n: Language {
        set {
            storage.i18n = newValue
            objectWillChange.send()
        }
        get {
            return storage.i18n
        }
    }
    
    subscript(dynamicMember key: String) -> String {
        NSLocalizedString(key, tableName: i18n.rawValue, bundle: Bundle.main, value: key, comment: key)
    }
    
}
