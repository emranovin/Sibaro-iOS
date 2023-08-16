//
//  ServiceContainer.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/24/1402 AP.
//

import Foundation

final class Container {
    lazy var manager: ContainerManager = {
        return ContainerManager(self)
    }()
    static let shared: Container = Container()
}

final class ContainerManager {
    private weak var container: Container?
    private var registered: [String:AnyServiceFactoryContainer] = [:]
    private var registeredCached: [String:Any] = [:]
    
    init(_ container: Container) {
        self.container = container
    }
    
    func register<T>(
        key: String,
        clear: Bool = true,
        factory: @escaping () -> T
    ) {
        globalContainerRecursiveLock.lock()
        if clear || registered[key] == nil {
            registeredCached[key] = nil
            registered[key] = ServiceFactoryContainer(factory: factory)
        }
        globalContainerRecursiveLock.unlock()
    }
    
    func resolve<T>(key: String) -> T? {
        globalContainerRecursiveLock.lock()
        print("cache \(key) \(registeredCached[key])")
        let value = (registeredCached[key] as? T) ?? (registered[key] as? ServiceFactoryContainer<T>)?.factory()
        registeredCached[key] = value
        print("cache out \(key) \(value)")
        globalContainerRecursiveLock.unlock()
        return value
    }
}
