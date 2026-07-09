import XCTest
@testable import TokenMeterKit

final class TokenUsageTests: XCTestCase {

    func testTotalTokensSumsFields() {
        let usage = TokenUsage(promptTokens: 10, completionTokens: 5)
        XCTAssertEqual(usage.promptTokens, 10)
        XCTAssertEqual(usage.completionTokens, 5)
        XCTAssertEqual(usage.totalTokens, 15)
    }

    func testNegativeCountsAreClampedToZero() {
        let usage = TokenUsage(promptTokens: -3, completionTokens: -7)
        XCTAssertEqual(usage.promptTokens, 0)
        XCTAssertEqual(usage.completionTokens, 0)
        XCTAssertEqual(usage.totalTokens, 0)
    }

    func testZeroConstant() {
        XCTAssertEqual(TokenUsage.zero, TokenUsage(promptTokens: 0, completionTokens: 0))
    }

    func testPlusOperator() {
        let a = TokenUsage(promptTokens: 1, completionTokens: 2)
        let b = TokenUsage(promptTokens: 3, completionTokens: 4)
        XCTAssertEqual(a + b, TokenUsage(promptTokens: 4, completionTokens: 6))
    }

    func testPlusEqualsOperator() {
        var a = TokenUsage(promptTokens: 1, completionTokens: 1)
        a += TokenUsage(promptTokens: 2, completionTokens: 3)
        XCTAssertEqual(a, TokenUsage(promptTokens: 3, completionTokens: 4))
    }

    func testCodableRoundTrip() throws {
        let usage = TokenUsage(promptTokens: 11, completionTokens: 22)
        let data = try JSONEncoder().encode(usage)
        let decoded = try JSONDecoder().decode(TokenUsage.self, from: data)
        XCTAssertEqual(usage, decoded)
    }
}
