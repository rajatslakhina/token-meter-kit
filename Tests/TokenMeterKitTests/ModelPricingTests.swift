import XCTest
@testable import TokenMeterKit

final class ModelPricingTests: XCTestCase {

    func testCostComputesInputAndOutput() {
        let pricing = ModelPricing(inputPerMillion: 10, outputPerMillion: 20)
        let usage = TokenUsage(promptTokens: 1_000_000, completionTokens: 500_000)
        // input: 1.0M * $10 = $10 ; output: 0.5M * $20 = $10 ; total $20
        XCTAssertEqual(pricing.cost(for: usage), Decimal(20))
    }

    func testCostOfZeroUsageIsZero() {
        let pricing = ModelPricing(inputPerMillion: 5, outputPerMillion: 15)
        XCTAssertEqual(pricing.cost(for: .zero), Decimal(0))
    }

    func testNegativePricesAreClampedToZero() {
        let pricing = ModelPricing(inputPerMillion: -5, outputPerMillion: -9)
        XCTAssertEqual(pricing.inputPerMillion, Decimal(0))
        XCTAssertEqual(pricing.outputPerMillion, Decimal(0))
        let usage = TokenUsage(promptTokens: 1_000, completionTokens: 1_000)
        XCTAssertEqual(pricing.cost(for: usage), Decimal(0))
    }

    func testFractionalCost() {
        let pricing = ModelPricing(inputPerMillion: Decimal(string: "0.15")!,
                                   outputPerMillion: Decimal(string: "0.60")!)
        let usage = TokenUsage(promptTokens: 4_000, completionTokens: 900)
        // input: 0.004M * 0.15 = 0.0006 ; output: 0.0009M * 0.60 = 0.00054
        XCTAssertEqual(pricing.cost(for: usage), Decimal(string: "0.00114"))
    }

    func testCodableRoundTrip() throws {
        let pricing = ModelPricing(inputPerMillion: 3, outputPerMillion: 12)
        let data = try JSONEncoder().encode(pricing)
        let decoded = try JSONDecoder().decode(ModelPricing.self, from: data)
        XCTAssertEqual(pricing, decoded)
    }
}
