import Foundation

/// An `actor` that accumulates token usage per model and prices it against a
/// `PricingRegistry`.
///
/// `TokenMeter` is the primary entry point of the kit. It serializes all
/// mutation through the actor, so it is safe to record usage from many
/// concurrent provider calls — mirroring the concurrency model of
/// `ProviderGatewayKit`'s `LLMSession` and `ProviderRouter`.
public actor TokenMeter {

    private let registry: PricingRegistry
    private var perModel: [String: TokenUsage] = [:]

    /// Creates a meter backed by a pricing registry.
    ///
    /// - Parameter registry: Defaults to `PricingRegistry.makeDefault()`.
    public init(registry: PricingRegistry = PricingRegistry.makeDefault()) {
        self.registry = registry
    }

    /// Records raw usage for a model identifier.
    public func record(_ usage: TokenUsage, for modelID: String) {
        perModel[modelID, default: .zero] += usage
    }

    /// Records usage from any `UsageReporting` value (e.g. a provider response).
    public func record(from report: some UsageReporting) {
        record(report.usage, for: report.modelID)
    }

    /// The accumulated usage for a single model, or `.zero` if none.
    public func usage(for modelID: String) -> TokenUsage {
        perModel[modelID] ?? .zero
    }

    /// The summed usage across every model recorded so far.
    public func totalUsage() -> TokenUsage {
        perModel.values.reduce(.zero, +)
    }

    /// The cost, in USD, accumulated for a single model.
    ///
    /// Returns zero when the model has no recorded usage or no known pricing.
    public func cost(for modelID: String) async -> Decimal {
        let usage = perModel[modelID] ?? .zero
        guard let pricing = await registry.pricing(for: modelID) else {
            return 0
        }
        return pricing.cost(for: usage)
    }

    /// The total cost, in USD, across every recorded model.
    public func totalCost() async -> Decimal {
        var sum: Decimal = 0
        for modelID in perModel.keys {
            sum += await cost(for: modelID)
        }
        return sum
    }

    /// Builds an immutable `MeterReport` snapshot of the current state.
    public func report() async -> MeterReport {
        var lines: [MeterReport.Line] = []
        for (modelID, usage) in perModel.sorted(by: { $0.key < $1.key }) {
            let cost = await cost(for: modelID)
            lines.append(MeterReport.Line(modelID: modelID, usage: usage, cost: cost))
        }
        return MeterReport(
            lines: lines,
            totalUsage: totalUsage(),
            totalCost: await totalCost()
        )
    }

    /// Clears all accumulated usage.
    public func reset() {
        perModel.removeAll()
    }
}
