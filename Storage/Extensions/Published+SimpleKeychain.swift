//
//  Published+SimpleKeychain.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/23/1402 AP.
//
import Combine
import Foundation
import SimpleKeychain

fileprivate var cancellableSet: Set<AnyCancellable> = []


extension Published where Value == Optional<String> {
    init(wrappedValue defaultValue: Value, keychain key: String) {
        let simpleKeychain = SimpleKeychain()
        if let data = try? simpleKeychain.data(forKey: key) {
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
                let simpleKeychain = SimpleKeychain()
                do {
                    let data = try JSONEncoder().encode(val)
                    try? simpleKeychain.set(data, forKey: key)
                } catch {
                    // Do nothing
                }
            }
            .store(in: &cancellableSet)
    }
}
