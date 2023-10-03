//
//  I18nService.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/23/1402 AP.
//

import Foundation
import DependencyFactory

@dynamicMemberLookup
protocol I18nServicable: BaseService {
    subscript(dynamicMember key: String) -> String { get }
    var language: Language { get set }
}

class I18nService: BaseService, I18nServicable {
    
    @Injected(\.storage) var storage
    
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
