//
//  Injections.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/24/1402 AP.
//

import Foundation
import SwiftUI
import Combine

@propertyWrapper
struct Injected<T> {
    private var dependency: T?
    
    init(_ keyPath: KeyPath<Container, Factory<T>>) {
        self.dependency = Container.shared[keyPath: keyPath]()
    }
    
    init<C: ManagedContainer>(_ keyPath: KeyPath<C, Factory<T>>, in container: C) {
        self.dependency = container[keyPath: keyPath]()
    }
    
    var wrappedValue: T {
        get { return dependency! }
        mutating set { dependency = newValue }
    }

    var projectedValue: Injected<T> {
        get { return self }
        mutating set { self = newValue }
    }
    
    static subscript<OuterSelf: ObservableObject>(
        _enclosingInstance observed: OuterSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<OuterSelf, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<OuterSelf, Self>
    ) -> T where OuterSelf.ObjectWillChangePublisher == ObservableObjectPublisher {
        get {
            if observed[keyPath: storageKeyPath].cancellable == nil {
            // This is executed only once.
                observed[keyPath: storageKeyPath].setup(observed)
            }
            return observed[keyPath: storageKeyPath].wrappedValue
        }
        set {
            observed.objectWillChange.send() // willSet
            observed[keyPath: storageKeyPath].wrappedValue = newValue
        }
    }
    
    private var cancellable: AnyCancellable?
    // Subscribe to objectWillChange of wrappedvalue.
    // When wrappedValue sends a notification, call the _enclosingInstance's objectWillChange.send().
    // Use a closure to weakly reference _enclosingInstance.
    private mutating func setup<OuterSelf: ObservableObject>(_ enclosingInstance: OuterSelf) where OuterSelf.ObjectWillChangePublisher == ObservableObjectPublisher {
        cancellable = (wrappedValue as? BaseService)?.objectWillChange.receive(on: RunLoop.main).sink(receiveValue: { [weak enclosingInstance] _ in
            (enclosingInstance?.objectWillChange)?.send()
        })
    }

}

/*
@propertyWrapper
struct LazyInject<T> {
    private var dependency: T?
    private var didInit: Bool = false
    private var keyPath: KeyPath<ServiceContainer, ServiceFactory<T>>
    
    init(_ keyPath: KeyPath<ServiceContainer, ServiceFactory<T>>) {
        self.keyPath = keyPath
    }
    
    var wrappedValue: T? {
        mutating get {
            if !didInit {
                dependency = ServiceContainer.shared[keyPath: keyPath]()
            }
            return dependency
        }
    }

    var projectedValue: LazyInject<T> {
        get { return self }
    }

}

@propertyWrapper
struct WeakLazyInject<T> {
    private weak var dependency: AnyObject?
    private var didInit: Bool = false
    private var keyPath: KeyPath<ServiceContainer, ServiceFactory<T>>
    
    init(_ keyPath: KeyPath<ServiceContainer, ServiceFactory<T>>) {
        self.keyPath = keyPath
    }
    
    var wrappedValue: T? {
        mutating get {
            if !didInit {
                let dep: T? = ServiceContainer.shared[keyPath: keyPath]()
                dependency = dep as AnyObject
            }
            return dependency as? T
        }
    }

    var projectedValue: WeakLazyInject<T> {
        get { return self }
    }

}

@propertyWrapper
struct InjectedObject<T>: DynamicProperty where T: ObservableObject {
    @StateObject fileprivate var dependency: T
    
    init(_ keyPath: KeyPath<ServiceContainer, ServiceFactory<T>>) {
        self._dependency = StateObject(wrappedValue: ServiceContainer.shared[keyPath: keyPath]()!)
    }

    public var wrappedValue: T {
        get { dependency }
    }
    
    public var projectedValue: ObservedObject<T>.Wrapper {
        return $dependency
    }

}*/
