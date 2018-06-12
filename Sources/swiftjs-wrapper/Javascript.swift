//
//  Javascript.swift
//  Playground
//
//  Created by  dcilia on 5/29/18.
//  Copyright © 2018  dcilia. All rights reserved.
//

import JavaScriptCore

public protocol JavascriptModule : Module {

    var context : JSContext { get set }
    var module : JSValue { get set }
    init(context : JSContext) throws
}

extension JavascriptModule {

    public func call<FunctionName, ReturnType, Arguments, Object>(name: FunctionName, args: Arguments, onObject: Object?) throws -> ReturnType where FunctionName : JSBridgeBox<JSBridgeCallType, String> , Arguments : JSBridgeBox<String, Array<Any>>, Object : JSValue {

        let _name = name.value
        let flatArgs = args.value.compactMap { return $0 }

        switch name.key {
        case .function:
            guard let funk : ReturnType = onObject?.invokeMethod(_name, withArguments: flatArgs) as? ReturnType else { throw JSBridgeError.failure }
            return funk
        case .module,
             .object:
            guard let object : ReturnType = onObject?.objectForKeyedSubscript(_name) as? ReturnType else { throw JSBridgeError.failure }
            return object
        }
    }
}

public final class JSBridgeUtils : NSObject {
    public static let bundle : Bundle = Bundle(for: JSBridgeUtils.self)
}

public enum JSBridgeCallType : String {
    case function = "function"
    case object = "object"
    case module = "module"
}


extension JSValue {

    public enum ConversionError : Error {
        case incorrectValue

        public var localizedDescription: String {
            switch self {
            case .incorrectValue:
                return "The conversion could not be completed.  Check conversion types, values and try again."
            }
        }
    }

    public func convert<T : Equatable>(to: JavascriptTypes) throws -> T {

        let val : T?

        switch to {

        case .bool:
            val = toBool() as? T
        case .dictionary:
            val = toDictionary() as? T
        case .null:
            val = self as? T
        case .number:
            val = toNumber() as? T
        case .object:
            val = toObject() as? T
        case .string:
            val = toString() as? T
        case .rect:
            val = toRect() as? T
        case .array:
            val = toArray() as? T
        case .size:
            val =  toSize() as? T
        case .int32:
            val = toInt32() as? T
        case .date:
            val = toDate() as? T
        case .point:
            val = toPoint() as? T
        case .range:
            val = toRange() as? T
        case .double:
            val = toDouble() as? T
        }

        guard let _val = val else { throw ConversionError.incorrectValue }
        return _val
    }
}

public final class JSBridgeBox<T, U> {

    public var key : T
    public var value : U

    public init(key: T, value: U) {
        self.key = key
        self.value = value
    }
}

public enum JavascriptTypes {
    case string
    case object
    case number
    case bool
    case dictionary
    case null
    case rect
    case size
    case array
    case int32
    case date
    case point
    case range
    case double

}

public protocol JavascriptFileType : File {}

public struct JavascriptFile : JavascriptFileType {

    public typealias RawDataType = String //JS Script as a String
    public var path: URL
    public var raw: String?
}

extension JavascriptFile {

    public init(path: URL) throws {
        self.path = path
        raw = try String(contentsOf: path)
    }
}

public struct Javascript<U : JavascriptFileType> : Loader {

    public typealias T = U
    public var resource: U
    public let context : JSContext

    public init(resource: U) throws {
        context = JSContext()
        context.exceptionHandler = { context, exception in
            print("JS Error: \(exception?.description ?? "unknown error")")
        }
        self.resource = resource
    }
}

extension Javascript where U == JavascriptFile {

    public func load() throws -> Void {

        do {

            guard let raw = resource.raw, let result = context.evaluateScript(raw) else {
                throw JavascriptError.couldNotEvaluate
            }

            if JSValueIsNull(result.context.jsGlobalContextRef, result.jsValueRef) == true {
                throw JavascriptError.evaluationIsNull
            }
        }
        catch {
            throw error
        }
    }
}
