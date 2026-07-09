import Foundation

/// A protocol describing any value that can report the token usage and the
/// model identifier of a completed LLM interaction.
///
/// This is the seam that lets `TokenMeterKit` compose with
/// `ProviderGatewayKit`: a provider's response type can conform to
/// `UsageReporting`, and the meter records it without knowing anything about
/// the concrete provider.
public protocol UsageReporting: Sendable {

    /// The identifier of the model that produced the interaction.
    var modelID: String { get }

    /// The tokens consumed by the interaction.
    var usage: TokenUsage { get }
}

/// A minimal concrete `UsageReporting` value, useful for tests, adapters, and
/// call sites that only have the raw numbers on hand.
public struct UsageReport: UsageReporting, Sendable, Hashable, Codable {

    public let modelID: String
    public let usage: TokenUsage

    public init(modelID: String, usage: TokenUsage) {
        self.modelID = modelID
        self.usage = usage
    }
}
