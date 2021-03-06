#if !canImport(ObjectiveC)
import XCTest

extension DDAgentServiceTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DDAgentServiceTests = [
        ("testSendPayload", testSendPayload),
        ("testSendPayloadReportsError", testSendPayloadReportsError),
    ]
}

extension DDEncodingTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DDEncodingTests = [
        ("testComplexEncoding", testComplexEncoding),
        ("testSimpleEncoding", testSimpleEncoding),
    ]
}

extension DDSpanContextTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DDSpanContextTests = [
        ("testDescription", testDescription),
    ]
}

extension DDSpanTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DDSpanTests = [
        ("testBaggageItems", testBaggageItems),
        ("testNamedTags", testNamedTags),
        ("testOperationNameCanBeChanged", testOperationNameCanBeChanged),
    ]
}

extension DDSwiftTracerTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DDSwiftTracerTests = [
        ("testDoesntSendUnfinishedSpansToAgent", testDoesntSendUnfinishedSpansToAgent),
        ("testSendsTracesToAgentService", testSendsTracesToAgentService),
        ("testStartSpanAddsTags", testStartSpanAddsTags),
        ("testStartSpanCachesTrace", testStartSpanCachesTrace),
        ("testStartSpanDoesntDuplicatedTracesInCache", testStartSpanDoesntDuplicatedTracesInCache),
        ("testStartSpanUsesCurrentDateWhenNonePassedIn", testStartSpanUsesCurrentDateWhenNonePassedIn),
        ("testStartSpanUsesDatePassedIn", testStartSpanUsesDatePassedIn),
        ("testStartSpanUsesParentSpan", testStartSpanUsesParentSpan),
    ]
}

extension DDTextCarrierTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DDTextCarrierTests = [
        ("testExtract", testExtract),
        ("testExtractIsCaseInsensitive", testExtractIsCaseInsensitive),
        ("testExtractWithMissingData", testExtractWithMissingData),
        ("testInject", testInject),
        ("testInjectWithWrongTypeDoesNothing", testInjectWithWrongTypeDoesNothing),
    ]
}

extension DDTraceCacheTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DDTraceCacheTests = [
        ("testCacheAsSequence", testCacheAsSequence),
        ("testCacheHandlesRemoval", testCacheHandlesRemoval),
        ("testCacheWorksEmpty", testCacheWorksEmpty),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(DDAgentServiceTests.__allTests__DDAgentServiceTests),
        testCase(DDEncodingTests.__allTests__DDEncodingTests),
        testCase(DDSpanContextTests.__allTests__DDSpanContextTests),
        testCase(DDSpanTests.__allTests__DDSpanTests),
        testCase(DDSwiftTracerTests.__allTests__DDSwiftTracerTests),
        testCase(DDTextCarrierTests.__allTests__DDTextCarrierTests),
        testCase(DDTraceCacheTests.__allTests__DDTraceCacheTests),
    ]
}
#endif
