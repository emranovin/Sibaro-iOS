//
//  LanguageService.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/23/1402 AP.
//

import Foundation

@dynamicMemberLookup
class LanguageService: ObservableObject {
    
    private let storage = StorageService()
    
    var language: Language {
        set {
            storage.language = newValue
            objectWillChange.send()
        }
        get {
            return storage.language
        }
    }
    
    subscript(dynamicMember key: String) -> String {
        NSLocalizedString(key, tableName: language.rawValue, bundle: Bundle.main, value: key, comment: key)
    }
    
}
