import XCTest
@testable import TokenMeterKit

final class TokenMeterTests: XCTestCase {

    func testRecordAndUsageForModel() async {
        let meter = TokenMeter()
        await meter.record(TokenUsage(promptTokens: 100, completionTokens: 50), for: "gpt-4o")
        await meter.record(TokenUsage(promptTokens: 10, completionTokens: 5), for: "gpt-4o")
        let usage = await meter.usage(for: "gpt-4o")
        XCTAssertEqual(usage, TokenUsage(promptTokens: 110, completionTokens: 55))
    }

    func testUsageForUnknownModelIsZero() async {
        let meter = TokenMeter()
        let usage = await meter.usage(for: "never-seen")
        XCTAssertEqual(usage, .zero)
    }

    func testRecordFromUsageReporting() async {
        let meter = TokenMeter()
        let report = UsageReport(
            modelID: "claude-sonnet",
            usage: TokenUsage(promptTokens: 800, completionTokens: 1_100)
        )
        await meter.record(from: report)
        let usage = await meter.usage(for: "claude-sonnet")
        XCTAssertEqual(usage, TokenUsage(promptTokens: 800, completionTokens: 1_100))
    }

    func testTotalUsageSumsAcrossModels() async {
        let meter = TokenMeter()
        await meter.record(TokenUsage(promptTokens: 1, completionTokens: 2), for: "a")
        await meter.record(TokenUsage(promptTokens: 3, completionTokens: 4), for: "b")
        let total = await meter.totalUsage()
        XCTAssertEqual(total, TokenUsage(promptTokens: 4, completionTokens: 6))
    }

    func testCostForKnownModel() async {
        let meter = TokenMeter()
        await meter.record(TokenUsage(promptTokens: 1_200, completionTokens: 350), for: "gpt-4o")
        // gpt-4o default: $5/M in, $15/M out -> 0.006 + 0.00525 = 0.01125
        let cost = await meter.cost(for: "gpt-4o")
        XCTAssertEqual(cost, Decimal(string: "0.01125"))
    }

    func testCostForKnownModelWithoutRecordedUsageIsZero() async {
        // Known pricing but no usage recorded: exercises the `.zero` fallback
        // and returns a zero cost.
        let meter = TokenMeter()
        let cost = await meter.cost(for: "gpt-4o")
        XCTAssertEqual(cost, Decimal(0))
    }

    func testCostForUnknownPricingIsZero() async {
        // Empty registry -> guard-else path returns 0 even though usage exists.
        let meter = TokenMeter(registry: PricingRegistry())
        await meter.record(TokenUsage(promptTokens: 999, completionTokens: 999), for: "mystery")
        let cost = await meter.cost(for: "mystery")
        XCTAssertEqual(cost, Decimal(0))
    }

    func testTotalCostAcrossModels() async {
        let meter = TokenMeter()
        await meter.record(TokenUsage(promptTokens: 1_200, completionTokens: 350), for: "gpt-4o")
        await meter.record(TokenUsage(promptTokens: 5_000, completionTokens: 2_000), for: "on-device")
        // on-device is free, so total equals the gpt-4o cost.
        let total = await meter.totalCost()
        XCTAssertEqual(total, Decimal(string: "0.01125"))
    }

    func testReportSnapshotIsSortedAndConsistent() async {
        let meter = TokenMeter()
        await meter.record(TokenUsage(promptTokens: 800, completionTokens: 1_100), for: "claude-sonnet")
        await meter.record(TokenUsage(promptTokens: 1_200, completionTokens: 350), for: "gpt-4o")
        let report = await meter.report()
        let totalCost = await meter.totalCost()
        XCTAssertEqual(report.lines.map(\.modelID), ["claude-sonnet", "gpt-4o"])
        XCTAssertEqual(report.totalUsage, TokenUsage(promptTokens: 2_000, completionTokens: 1_450))
        XCTAssertEqual(report.totalCost, totalCost)
    }

    func testResetClearsState() async {
        let meter = TokenMeter()
        await meter.record(TokenUsage(promptTokens: 10, completionTokens: 10), for: "gpt-4o")
        await meter.reset()
        let totalUsage = await meter.totalUsage()
        let modelUsage = await meter.usage(for: "gpt-4o")
        XCTAssertEqual(totalUsage, .zero)
        XCTAssertEqual(modelUsage, .zero)
        let report = await meter.report()
        XCTAssertTrue(report.lines.isEmpty)
        XCTAssertEqual(report.totalCost, Decimal(0))
    }
}
