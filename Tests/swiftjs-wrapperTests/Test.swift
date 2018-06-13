//
//  Test.swift
//  JSBridgeKit
//
//  Created by  dcilia on 6/10/18.
//  Copyright © 2018  dcilia. All rights reserved.
//

import JavaScriptCore
import swiftjs_wrapper

public struct MyModule : JavascriptModule {

    public func call<FunctionName, ReturnType, Arguments>(name: FunctionName, args: Arguments, onObject: Any?) throws -> ReturnType {

        throw JSBridgeError.couldNotInitialize
    }


    public typealias BackingType = JSValue
    public typealias Name = JSBridgeBox<JSBridgeCallType, String>

    public var name: JSBridgeBox<JSBridgeCallType, String> = JSBridgeBox(key: .module, value: "MyModule")
    public var context: JSContext
    public var module: JSValue

    public init(context: JSContext) throws {
        print(#function)

        do {
            self.context = context
            guard let _module = context.objectForKeyedSubscript(self.name.value) else {
                throw JSBridgeError.couldNotInitialize
            }

            self.module = _module
        }
        catch {
            throw error
        }
    }
}

struct Person : Codable {
    let name : String
    let email : String
    let phone : String
}
