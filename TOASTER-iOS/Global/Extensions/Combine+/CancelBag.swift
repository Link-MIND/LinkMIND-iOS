//
//  CancelBag.swift
//  TOASTER-iOS
//
//  Created by 민 on 9/29/24.
//

import Combine

class CancelBag {
    var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}

extension AnyCancellable {
    func store(in cancelBag: CancelBag) {
        cancelBag.cancellables.insert(self)
    }
}
