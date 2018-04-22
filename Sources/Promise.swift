//
//  Promise.swift
//  DHPromise
//
//  Created by David Harris on 02/10/17.
//  Copyright © 2017 thedavidharris. All rights reserved.
//

import Foundation

enum PromiseState {
    case resolved
    case rejected
    case pending
}

class Promise<Value> {

    var state: PromiseState {
        switch result {
        case .some(let resultValue):
            switch resultValue {
            case .success:
                return .resolved
            case .failure:
                return .rejected
            }
        case .none:
            return .pending
        }
    }

    var result: Result<Value>? {
        didSet {
            fireCompletionCallbacks()
        }
    }


    var value: Value? {
        return result?.value
    }

    var error: Error? {
        return result?.error
    }

    private lazy var successCallbacks = [(Value) -> Void]()
    private lazy var errorCallbacks = [(Error) -> Void]()

    public convenience init(_ work: @escaping (_ resolve: @escaping (Value) -> (), _ reject: @escaping (Error) -> ()) throws -> ()) {
        self.init()
        do {
            try work(self.resolve, self.reject)
        } catch let error {
            self.reject(with: error)
        }
    }

    func resolve(with value: Value) {
        self.result = .success(value)
    }

    func reject(with error: Error) {
        self.result = .failure(error)
    }

    @discardableResult func then(_ callback: @escaping (Value) -> Void) -> Promise<Value> {
        successCallbacks.append(callback)
        return self
    }

    @discardableResult func onError(_ callback: @escaping (Error) -> Void) -> Promise<Value> {
        errorCallbacks.append(callback)
        return self
    }

    private func fireCompletionCallbacks() {
        switch state {
        case .resolved:
            successCallbacks.forEach {
                result?.value.map($0)
            }
        case .rejected:
            errorCallbacks.forEach {
                result?.error.map($0)
            }
        case .pending:
            break
        }
    }
}
