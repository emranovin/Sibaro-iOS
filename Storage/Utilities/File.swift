//
//  File.swift
//  Sibaro
//
//  Created by Emran Novin on 9/28/23.
//

import Foundation
import Combine

enum Directory {
    case signing
    
    var url: URL {
        switch self {
        case .signing:
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        }
    }
}

@propertyWrapper
struct File {
    let directory: Directory
    let name: String
    var wrappedValue: Data? {
        willSet {  // Before modifying wrappedValue
            let defaultDirectory = directory.url.appendingPathComponent(name)
            guard let newValue else {
                try? FileManager.default.removeItem(at: defaultDirectory)
                return
            }
            try? newValue.write(to: defaultDirectory, options: .atomic)
        }
    }
    
    var projectedValue: Publisher {
        publisher
    }
    
    private var publisher: Publisher
    struct Publisher: Combine.Publisher {
        typealias Output = Data?
        typealias Failure = Never
        var subject: CurrentValueSubject<Data?, Never> // PassthroughSubject will lack the call of initial assignment
        func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            subject.subscribe(subscriber)
        }
        init(_ output: Output) {
            subject = .init(output)
        }
    }
    
    init(wrappedValue: Data? = nil, name: String, in directory: Directory) {
        self.directory = directory
        self.name = name
        let url = directory.url.appendingPathComponent(name)
        let data = (try? Data(contentsOf: url)) ?? wrappedValue
        self.wrappedValue = data
        publisher = Publisher(data)
    }
    
    static subscript<OuterSelf: ObservableObject>(
        _enclosingInstance observed: OuterSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<OuterSelf, Data?>,
        storage storageKeyPath: ReferenceWritableKeyPath<OuterSelf, Self>
    ) -> Data? {
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
