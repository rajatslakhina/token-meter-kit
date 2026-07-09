import Foundation

/// An immutable snapshot of everything a `TokenMeter` has accumulated.
public struct MeterReport: Sendable, Hashable, Codable {

    /// A single per-model line item within a report.
    public struct Line: Sendable, Hashable, Codable {
        public let modelID: String
        public let usage: TokenUsage
        public let cost: Decimal

        public init(modelID: String, usage: TokenUsage, cost: Decimal) {
            self.modelID = modelID
            self.usage = usage
            self.cost = cost
        }
    }

    /// Per-model line items, sorted by model identifier.
    public let lines: [Line]

    /// The summed usage across every model.
    public let totalUsage: TokenUsage

    /// The summed cost across every model, in USD.
    public let totalCost: Decimal

    public init(lines: [Line], totalUsage: TokenUsage, totalCost: Decimal) {
        self.lines = lines
        self.totalUsage = totalUsage
        self.totalCost = totalCost
    }

    /// Renders the report as a plain-text table suitable for logs or a CLI.
    public func formatted() -> String {
        var out = "Model                Prompt   Completion   Total     Cost(USD)\n"
        out += "-------------------------------------------------------------------\n"
        for line in lines {
            out += Self.row(
                model: line.modelID,
                prompt: line.usage.promptTokens,
                completion: line.usage.completionTokens,
                total: line.usage.totalTokens,
                cost: line.cost
            )
        }
        out += "-------------------------------------------------------------------\n"
        out += Self.row(
            model: "TOTAL",
            prompt: totalUsage.promptTokens,
            completion: totalUsage.completionTokens,
            total: totalUsage.totalTokens,
            cost: totalCost
        )
        return out
    }

    private static func row(
        model: String,
        prompt: Int,
        completion: Int,
        total: Int,
        cost: Decimal
    ) -> String {
        let name = model.padding(toLength: 20, withPad: " ", startingAt: 0)
        let promptCol = String(prompt).padding(toLength: 9, withPad: " ", startingAt: 0)
        let compCol = String(completion).padding(toLength: 13, withPad: " ", startingAt: 0)
        let totalCol = String(total).padding(toLength: 10, withPad: " ", startingAt: 0)
        return "\(name)\(promptCol)\(compCol)\(totalCol)$\(Self.money(cost))\n"
    }

    private static func money(_ value: Decimal) -> String {
        var rounded = Decimal()
        var source = value
        NSDecimalRound(&rounded, &source, 6, .plain)
        return "\(rounded)"
    }
}
