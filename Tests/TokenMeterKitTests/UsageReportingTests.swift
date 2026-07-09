import XCTest
@testable import TokenMeterKit

final class UsageReportingTests: XCTestCase {

    func testUsageReportExposesModelAndUsage() {
        let report = UsageReport(
            modelID: "gpt-4o",
            usage: TokenUsage(promptTokens: 5, completionTokens: 6)
        )
        XCTAssertEqual(report.modelID, "gpt-4o")
        XCTAssertEqual(report.usage, TokenUsage(promptTokens: 5, completionTokens: 6))
    }

    func testUsageReportConformsToUsageReporting() {
        let reporting: any UsageReporting = UsageReport(
            modelID: "m",
            usage: TokenUsage(promptTokens: 1, completionTokens: 1)
        )
        XCTAssertEqual(reporting.modelID, "m")
        XCTAssertEqual(reporting.usage.totalTokens, 2)
    }

    func testCodableRoundTrip() throws {
        let report = UsageReport(
            modelID: "claude-sonnet",
            usage: TokenUsage(promptTokens: 7, completionTokens: 8)
        )
        let data = try JSONEncoder().encode(report)
        let decoded = try JSONDecoder().decode(UsageReport.self, from: data)
        XCTAssertEqual(report, decoded)
    }
}
