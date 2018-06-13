import XCTest
import JavaScriptCore
@testable import swiftjs_wrapper


final class swiftjs_wrapperTests: XCTestCase {

    static var allTests = [
        ("testJavascriptLoader", testJavascriptLoader),
        ("testCallingFunctionInJS", testCallingFunctionInJS),
        ("testCallingObjectInJS", testCallingObjectInJS),
        ("testCallingFunctionInJSWithJSON", testCallingFunctionInJSWithJSON),
        ("testCallingFunctionInJSWithArgument", testCallingFunctionInJSWithArgument)
    ]

    func testJavascriptLoader() {

        do {

            let loader = try swiftjs_wrapperTests.loader()
            try loader.load()
            XCTAssert(true) //good to go!
        }
        catch {
            print(error)
            XCTAssert(false)
            return
        }
    }

    func testCallingFunctionInJS() {

        do {
            let loader = try swiftjs_wrapperTests.loader()
            try loader.load()

            //Call the function "sayHello" , which returns a String
            let caller = try MyModule(context: loader.context)

            let funkName = JSBridgeBox(key: JSBridgeCallType.function, value: "sayHello")
            let args = JSBridgeBox(key: "args", value: [Any]())
            let result : JSValue = try caller.call(name: funkName, args: args, onObject: caller.module)
            let str : String = try result.convert(to: .string)

            XCTAssertEqual("Hello", str)

        }
        catch {
            print(error)
            XCTAssert(false)
            return
        }
    }

    func testCallingFunctionInJSWithArgument() {
        do {
            let loader = try swiftjs_wrapperTests.loader()
            try loader.load()

            //Call the function "sayHello" , which returns a String
            let caller = try MyModule(context: loader.context)

            let funkName = JSBridgeBox(key: JSBridgeCallType.function, value: "sayHelloToMe")
            let _input : [Any] = ["David"]
            let args = JSBridgeBox(key: "args", value: _input)
            let result : JSValue = try caller.call(name: funkName, args: args, onObject: caller.module)
            let str : String = try result.convert(to: .string)

            XCTAssertEqual("Hello David", str)

        }
        catch {
            print(error)
            XCTAssert(false)
            return
        }
    }

    func testCallingObjectInJS() {

        do {
            let loader = try swiftjs_wrapperTests.loader()
            try loader.load()

            //Call the function "sayHello" , which returns a String
            let caller = try MyModule(context: loader.context)

            let funkName = JSBridgeBox(key: JSBridgeCallType.object, value: "Person")
            let args = JSBridgeBox(key: "args", value: [Any]())
            let result : JSValue = try caller.call(name: funkName, args: args, onObject: caller.module)
            let dict : NSDictionary = try result.convert(to: .dictionary)

            XCTAssertEqual("John Example", dict.object(forKey: "name") as! String)
            XCTAssertEqual("john@example.com", dict.object(forKey: "email") as! String)
            XCTAssertEqual("212-556-5433", dict.object(forKey: "phone") as! String)

            print(dict.debugDescription)

        }
        catch {
            print(error)
            XCTAssert(false)
            return
        }

    }

    func testCallingFunctionInJSWithJSON() {

        do {
            let loader = try swiftjs_wrapperTests.loader()
            try loader.load()

            //Call the function "sayHello" , which returns a String
            let caller = try MyModule(context: loader.context)

            let funkName = JSBridgeBox(key: JSBridgeCallType.function, value: "personJSON")
            let args = JSBridgeBox(key: "args", value: [Any]())
            let result : JSValue = try caller.call(name: funkName, args: args, onObject: caller.module)
            let str : String = try result.convert(to: .string)


            guard let _data = str.data(using: .utf8) else { XCTAssert(true); return }
            let person = try JSONDecoder().decode(Person.self, from: _data)
            dump(person)
            XCTAssertNotNil(person)

            XCTAssertEqual("John Example", person.name)
            XCTAssertEqual("john@example.com", person.email)
            XCTAssertEqual("212-556-5433", person.phone)

        }
        catch {
            print(error)
            XCTAssert(false)
            return
        }
    }
}

extension swiftjs_wrapperTests {

    static func loader() throws -> Javascript<JavascriptFile> {

        let bundle = Bundle(for: swiftjs_wrapperTests.self)
        guard let path = bundle.url(forResource: "bundle", withExtension: "js") else {
            XCTAssert(false)
            throw JSBridgeError.couldNotInitialize
        }

        do {

            let file : JavascriptFile = try JavascriptFile(path: path)
            let loader : Javascript<JavascriptFile> = try Javascript(resource: file)
            return loader
        }
        catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
