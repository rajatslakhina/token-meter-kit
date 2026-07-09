import Foundation
import TokenMeterKit

/// A tiny stand-in for a provider response you might receive from
/// `ProviderGatewayKit`. In a real app this would be the response type of a
/// concrete `LLMProvider`; here it just carries the numbers.
struct SimulatedResponse: UsageReporting {
    let modelID: String
    let usage: TokenUsage
}

@main
struct Demo {
    static func main() async {
        print("== TokenMeterKit demo ==\n")

        // A meter backed by the illustrative default pricing catalog.
        let meter = TokenMeter()

        // Simulate a routed conversation: the gateway failed over between a
        // cloud model and the on-device model, and we meter every hop.
        let hops: [SimulatedResponse] = [
            SimulatedResponse(modelID: "gpt-4o",
                              usage: TokenUsage(promptTokens: 1_200, completionTokens: 350)),
            SimulatedResponse(modelID: "gpt-4o-mini",
                              usage: TokenUsage(promptTokens: 4_000, completionTokens: 900)),
            SimulatedResponse(modelID: "claude-sonnet",
                              usage: TokenUsage(promptTokens: 800, completionTokens: 1_100)),
            SimulatedResponse(modelID: "on-device",
                              usage: TokenUsage(promptTokens: 5_000, completionTokens: 2_000))
        ]

        for hop in hops {
            await meter.record(from: hop)
        }

        let report = await meter.report()
        print(report.formatted())

        let total = await meter.totalCost()
        print("\nBilled spend for this conversation: $\(total)")
    }
}
