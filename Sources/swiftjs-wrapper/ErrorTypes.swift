//
//  ErrorTypes.swift
//  Playground
//
//  Created by  dcilia on 6/7/18.
//  Copyright © 2018  dcilia. All rights reserved.
//

import Foundation

public enum JSBridgeError : Error {
    case null
    case failure
    case couldNotInitialize

    public var localizedDescription: String {
        switch self {
        case .null:
            return "The operation / bridge returned a null value."
        case .couldNotInitialize:
            return "Could not intialize the script."
        case .failure:
            return "The operation / bridge returned a failure."
        }
    }
}

public enum JavascriptError : Error {
    case couldNotEvaluate
    case evaluationIsNull

    public var localizedDescription: String {
        switch self {
        case .couldNotEvaluate:
            return "The wrapper could not evaulate the script."
        case .evaluationIsNull:
            return "The wrapper returned a null value for the script."
        }
    }
}

