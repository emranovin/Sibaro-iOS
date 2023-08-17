//
//  ServiceFactory.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/24/1402 AP.
//

import Foundation

struct Factory<T> {
    
    private weak var container: Container?
    private var key: String
    
    init(_ container: Container, factory: @escaping () -> T) {
        self.container = container
        self.key = String(describing: T.self)
        container.manager.register(key: key, clear: false, factory: factory)
    }
    
    func register(factory: @escaping () -> T) {
        container?.manager.register(key: key, clear: true, factory: factory)
    }
    
    func callAsFunction() -> T? {
        container?.manager.resolve(key: key)
    }

    func resolve() -> T? {
        container?.manager.resolve(key: key)
    }
}

protocol AnyServiceFactoryContainer {}
struct ServiceFactoryContainer<T>: AnyServiceFactoryContainer {
    let factory: () -> T
}
