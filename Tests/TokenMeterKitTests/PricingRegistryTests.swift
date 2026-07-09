import XCTest
@testable import TokenMeterKit

final class PricingRegistryTests: XCTestCase {

    func testEmptyRegistryReturnsNil() async {
        let registry = PricingRegistry()
        let pricing = await registry.pricing(for: "missing")
        XCTAssertNil(pricing)
        let known = await registry.knownModels
        XCTAssertEqual(known, [])
    }

    func testRegisterAndLookup() async {
        let registry = PricingRegistry()
        let pricing = ModelPricing(inputPerMillion: 1, outputPerMillion: 2)
        await registry.register(pricing, for: "my-model")
        let fetched = await registry.pricing(for: "my-model")
        XCTAssertEqual(fetched, pricing)
    }

    func testRegisterOverwrites() async {
        let registry = PricingRegistry()
        await registry.register(ModelPricing(inputPerMillion: 1, outputPerMillion: 1), for: "m")
        await registry.register(ModelPricing(inputPerMillion: 9, outputPerMillion: 9), for: "m")
        let fetched = await registry.pricing(for: "m")
        XCTAssertEqual(fetched, ModelPricing(inputPerMillion: 9, outputPerMillion: 9))
    }

    func testSeededInitAndKnownModelsSorted() async {
        let registry = PricingRegistry([
            "zeta": ModelPricing(inputPerMillion: 1, outputPerMillion: 1),
            "alpha": ModelPricing(inputPerMillion: 1, outputPerMillion: 1)
        ])
        let known = await registry.knownModels
        XCTAssertEqual(known, ["alpha", "zeta"])
    }

    func testDefaultCatalogHasExpectedModels() async {
        let registry = PricingRegistry.makeDefault()
        let known = await registry.knownModels
        XCTAssertEqual(known, ["claude-sonnet", "gpt-4o", "gpt-4o-mini", "on-device"])
        let onDevice = await registry.pricing(for: "on-device")
        XCTAssertEqual(onDevice, ModelPricing(inputPerMillion: 0, outputPerMillion: 0))
    }
}
