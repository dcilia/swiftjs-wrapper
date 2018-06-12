//
//  Loader.swift
//  Playground
//
//  Created by  dcilia on 5/17/18.
//  Copyright © 2018  dcilia. All rights reserved.
//

import Foundation

/// A protocol of loading a resource
public protocol Loader {

    /// A type conforming to Resource
    associatedtype T : Resource
    /// An instance of resource as T
    var resource : T { get set }
}

///A representation of a Resource
public protocol Resource {
    /// A description of the resource
    var description : String { get }
    /// Loads the resource
    ///
    /// - Returns: Void
    /// - Throws: An error that conforms to Error
    func load() throws -> Void
}

/// File Errors
///
/// - notImplemented: Function was not implemented.
public enum FileError : Error {
    case notImplemented

    public var localizedDescription: String {
        switch self {
        case .notImplemented:
            return "The required function was not implemented."
        }
    }
}

/// File Representation of a Resource
public protocol File : Resource {
    /// The raw data type
    associatedtype RawDataType
    /// The 'path' to the resource
    var path : URL { get set }
    /// Raw Data Representation
    var raw : RawDataType? { get set }
}

public extension File {

    /// A summary describing the File resource
    var description: String { return "A File Representation of a Resource" }

    /// Loading the file (resource)
    ///
    /// - Throws: an instance of FileError
    func load() throws {
        throw FileError.notImplemented
    }
}

