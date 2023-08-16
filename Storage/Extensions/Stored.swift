//
//  Stored.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/25/1402 AP.
//
import Foundation
import Combine
import SimpleKeychain

enum StoredLocation {
    case standard
    case keychain
    
    func data(for key: String) -> Data? {
        switch self {
        case .keychain:
            return try? SimpleKeychain().data(forKey: key)
        case .standard:
            return UserDefaults.standard.data(forKey: key)
        }
    }
    
    func set(_ value: Data, for key: String) {
        switch self {
        case .keychain:
            try? SimpleKeychain().set(value, forKey: key)
        case .standard:
            UserDefaults.standard.set(value, forKey: key)
        }
    }
}


@propertyWrapper
struct Stored<Value: Codable> {
    var wrappedValue: Value {
        willSet {  // Before modifying wrappedValue
            publisher.subject.send(newValue)
        }
    }

    var projectedValue: Publisher {
        publisher
    }
    private var publisher: Publisher
    struct Publisher: Combine.Publisher {
        typealias Output = Value
        typealias Failure = Never
        var subject: CurrentValueSubject<Value, Never> // PassthroughSubject will lack the call of initial assignment
        func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            subject.subscribe(subscriber)
        }
        init(_ output: Output) {
            subject = .init(output)
        }
    }
    init(wrappedValue: Value, key: String, in location: StoredLocation = .standard) {
        var value = wrappedValue
        if let data = location.data(for: key) {
            do {
                value = try JSONDecoder().decode(Value.self, from: data)
            } catch {}
        }
        self.wrappedValue = value
        publisher = Publisher(value)
    }
    static subscript<OuterSelf: ObservableObject>(
        _enclosingInstance observed: OuterSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<OuterSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<OuterSelf, Self>
    ) -> Value {
        get {
            observed[keyPath: storageKeyPath].wrappedValue
        }
        set {
            if let subject = observed.objectWillChange as? ObservableObjectPublisher {
                subject.send() // Before modifying wrappedValue
                observed[keyPath: storageKeyPath].wrappedValue = newValue
            }
        }
    }
}
