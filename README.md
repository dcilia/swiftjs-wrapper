# swiftjs-wrapper

__Introduction__:

**JavascriptCore** is a powerful framework on the macOS/iOS/tvOS platform.  Interacting with it through ```swift``` leaves much to be desired since it is still an ```Objective-C``` framework.

```swiftjs-wrapper``` aims to alleviate some of the boilerplate and add some type safety to interacting with ```JavascriptCore```.

Functionality is focused right now on loading a script from a file and interacting with the objects and functions through the native side.

**Supported Platforms**:

```macOS 10.10+```,  ```iOS 11.0+```,  ```tvOS 11.0+``` are all supported.

**Usage**:

Load a ```Javascript``` file from the ```Bundle```:

```Javascript<JavascriptFile> ``` is the main entry point of loading ```Javascript``` into a ```JSContext``` as well as using the ```context``` to call additional functions, so its probably a good idea to keep this object around in memory.  You can create as many ```Javascript<JavascriptFile> ``` instances as you need, each one creates its own ```context```.



Here is an example of how to use ```Javascript<JavascriptFile> ```:

```swift
static func loader() throws -> Javascript<JavascriptFile> {

        let bundle = Bundle(for: SomeClassYouCreate.self)
        guard let path = bundle.url(forResource: "bundle", withExtension: "js") else {
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
```

After initializing an instance of ``` Javascript<JavascriptFile>``` call ```load()``` to set everything up:

```swift
try loader.load()
```

Great! So we have now loaded our ```Javascript``` into a ```context``` and everything is all setup.  How can we start interacting with the ```Javascript``` code?  The first step is to conform to ```JavascriptModule```, here is an example:

```swift
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
```

Highlight on this for a moment:

```swift
public func call<FunctionName, ReturnType, Arguments>(name: FunctionName, args: Arguments, onObject: Any?) throws -> ReturnType {

        throw JSBridgeError.couldNotInitialize
    }
```

```swiftjs-wrapper``` includes a special generic function with constraints to make calling ```Javascript``` functions easy.  It is declared in ```Javascript.swift```:

```swift
public func call<FunctionName, ReturnType, Arguments, Object>(name: FunctionName, args: Arguments, onObject: Object?) throws -> ReturnType where FunctionName : JSBridgeBox<JSBridgeCallType, String> , Arguments : JSBridgeBox<String, Array<Any>>, Object : JSValue
```

By throwing an error in our struct's implementation of this function - we want to make sure we call the above version of the function.  For our use case we want the default functionality.  This constrained version of the function covers most use cases in interacting with the ```Javascript``` code, including being able to specify what type action to take on the calling function to ```Javascript``` through the use of the ```JSBridgeCallType```:

```swift
public enum JSBridgeCallType : String {
    case function = "function"
    case object = "object"
    case module = "module"
}
```

which allows us to do something like:

```swift
        let _name = name.value
        let flatArgs = args.value.compactMap { return $0 }

        switch name.key {
        case .function:
            guard let funk : ReturnType = onObject?.invokeMethod(_name, withArguments:    flatArgs) as? ReturnType else { throw JSBridgeError.failure }
            return funk
        case .module,
             .object:
            guard let object : ReturnType = onObject?.objectForKeyedSubscript(_name) as? ReturnType else { throw JSBridgeError.failure }
            return object
        }
```

So what does the API interaction look like when actually using this in code? (see ```swiftjs_wrapperTests.swift```):

```swift
            let loader = try self.getLoader()
            try loader.load()

            //Call the function "personJSON" , which returns a String (as JSON)
            let caller = try MyModule(context: loader.context)

            let funkName = JSBridgeBox(key: JSBridgeCallType.function, value: "personJSON")
            let args = JSBridgeBox(key: "args", value: [Any]())
            let result : JSValue = try caller.call(name: funkName, args: args, onObject: caller.module)
            let str : String = try result.convert(to: .string)


            guard let _data = str.data(using: .utf8) else { return }
            let person = try JSONDecoder().decode(Person.self, from: _data)

```

:100: