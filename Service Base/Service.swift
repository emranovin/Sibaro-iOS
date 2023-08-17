//
//  Service.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/25/1402 AP.
//

import Foundation
import Combine

class BaseService: ObservableObject {
    var cancelBag: Set<AnyCancellable> = []
}
