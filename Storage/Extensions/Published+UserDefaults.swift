//
//  Published+UserDefaults.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/23/1402 AP.
//
import Combine
import Foundation

fileprivate var cancellableSet: Set<AnyCancellable> = []

enum UserDefaultsSuite {
    case standard
    
    var userDefaults: UserDefaults {
        switch self {
        case .standard:
            return .standard
        }
    }
}

extension Published where Value: Codable {
    init(wrappedValue defaultValue: Value, key: String, suite: UserDefaultsSuite = .standard) {
        if let data = suite.userDefaults.data(forKey: key) {
            do {
                let value = try JSONDecoder().decode(Value.self, from: data)
                self.init(initialValue: value)
            } catch {
                self.init(initialValue: defaultValue)
            }
        } else {
            self.init(initialValue: defaultValue)
        }

        projectedValue
            .sink { val in
                do {
                    let data = try JSONEncoder().encode(val)
                    suite.userDefaults.set(data, forKey: key)
                } catch {
                    // Do nothing
                }
            }
            .store(in: &cancellableSet)
    }
}
