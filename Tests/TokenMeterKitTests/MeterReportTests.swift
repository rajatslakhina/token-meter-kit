import XCTest
@testable import TokenMeterKit

final class MeterReportTests: XCTestCase {

    func testLineInitStoresValues() {
        let line = MeterReport.Line(
            modelID: "gpt-4o",
            usage: TokenUsage(promptTokens: 1, completionTokens: 2),
            cost: Decimal(string: "0.5")!
        )
        XCTAssertEqual(line.modelID, "gpt-4o")
        XCTAssertEqual(line.usage.totalTokens, 3)
        XCTAssertEqual(line.cost, Decimal(string: "0.5"))
    }

    func testFormattedContainsModelsTotalsAndCosts() {
        let lines = [
            MeterReport.Line(
                modelID: "gpt-4o",
                usage: TokenUsage(promptTokens: 1_200, completionTokens: 350),
                cost: Decimal(string: "0.01125")!
            )
        ]
        let report = MeterReport(
            lines: lines,
            totalUsage: TokenUsage(promptTokens: 1_200, completionTokens: 350),
            totalCost: Decimal(string: "0.01125")!
        )
        let text = report.formatted()
        XCTAssertTrue(text.contains("gpt-4o"))
        XCTAssertTrue(text.contains("TOTAL"))
        XCTAssertTrue(text.contains("1200"))
        XCTAssertTrue(text.contains("1550"))
        XCTAssertTrue(text.contains("$0.01125"))
        XCTAssertTrue(text.contains("Prompt"))
    }

    func testFormattedRoundsCostToSixPlaces() {
        let report = MeterReport(
            lines: [
                MeterReport.Line(
                    modelID: "m",
                    usage: TokenUsage(promptTokens: 0, completionTokens: 0),
                    cost: Decimal(string: "0.123456789")!
                )
            ],
            totalUsage: .zero,
            totalCost: Decimal(string: "0.123456789")!
        )
        let text = report.formatted()
        XCTAssertTrue(text.contains("$0.123457"))
    }

    func testCodableRoundTrip() throws {
        let report = MeterReport(
            lines: [
                MeterReport.Line(
                    modelID: "m",
                    usage: TokenUsage(promptTokens: 1, completionTokens: 1),
                    cost: Decimal(1)
                )
            ],
            totalUsage: TokenUsage(promptTokens: 1, completionTokens: 1),
            totalCost: Decimal(1)
        )
        let data = try JSONEncoder().encode(report)
        let decoded = try JSONDecoder().decode(MeterReport.self, from: data)
        XCTAssertEqual(report, decoded)
    }
}
