//
//  ViewModel.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/25/1402 AP.
//

import Foundation
import Combine
import DependencyFactory

class BaseViewModel: ObservableObject {
    @Injected(\.i18n) var i18n
    var cancelBag: Set<AnyCancellable> = []
}
