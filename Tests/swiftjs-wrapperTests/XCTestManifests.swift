import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(swiftjs_wrapperTests.allTests),
    ]
}
#endif
