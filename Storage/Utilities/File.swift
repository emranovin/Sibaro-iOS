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
    case installing
    case temp
    
    var url: URL {
        switch self {
        case .signing:
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                .appendingPathComponent("Signing", isDirectory: true)
                .creatingDirectories()
        case .installing:
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                .appendingPathComponent("Installing", isDirectory: true)
                .creatingDirectories()
        case .temp:
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                .appendingPathComponent("temp", isDirectory: true)
                .creatingDirectories()
        }
    }
}

struct FileContainer {
    let directory: Directory
    let name: String
    
    private let `default`: Data?
    
    var url: URL {
        directory.url.appendingPathComponent(name)
    }
    
    init(name: String, directory: Directory, with data: Data? = nil) {
        self.name = name
        self.directory = directory
        `default` = data
        if let data {
            if !FileManager.default.fileExists(atPath: url.path) {
                save(data: data)
            }
        }
    }
    
    mutating func delete() {
        try? FileManager.default.removeItem(at: url)
    }
    
    mutating func save(data: Data?) {
        guard let data else {
            delete()
            return
        }
        try? data.write(to: url, options: .atomic)
    }
    
    var data: Data? {
        let url = directory.url.appendingPathComponent(name)
        return (try? Data(contentsOf: url)) ?? `default`
    }
}

@propertyWrapper
struct File {
    var wrappedValue: FileContainer
    
    var projectedValue: Publisher {
        publisher
    }
    
    private var publisher: Publisher
    struct Publisher: Combine.Publisher {
        typealias Output = FileContainer
        typealias Failure = Never
        var subject: CurrentValueSubject<FileContainer, Never> // PassthroughSubject will lack the call of initial assignment
        func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            subject.subscribe(subscriber)
        }
        init(_ output: Output) {
            subject = .init(output)
        }
    }
    
    init(wrappedValue: Data? = nil, name: String, in directory: Directory) {
        let container = FileContainer(name: name, directory: directory, with: wrappedValue)
        self.wrappedValue = container
        publisher = Publisher(container)
    }
    
    static subscript<OuterSelf: ObservableObject>(
        _enclosingInstance observed: OuterSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<OuterSelf, FileContainer>,
        storage storageKeyPath: ReferenceWritableKeyPath<OuterSelf, Self>
    ) -> FileContainer {
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
