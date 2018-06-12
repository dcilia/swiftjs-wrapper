//
//  Module.swift
//  Playground
//
//  Created by  dcilia on 5/30/18.
//  Copyright © 2018  dcilia. All rights reserved.
//

import Foundation

/// A generic module type
public protocol Module {
    /// A backing type for the object.
    associatedtype BackingType
    associatedtype Name
    /// The name of the module
    var name : Name { get set }

    func call<FunctionName, ReturnType, Arguments>(name: FunctionName, args : Arguments, onObject: Any?) throws -> ReturnType
}
