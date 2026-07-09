import Foundation

/// Per-model pricing expressed in US dollars per one million tokens.
///
/// Prices are stored as `Decimal` to avoid binary floating-point rounding
/// error when accumulating many small costs.
public struct ModelPricing: Sendable, Hashable, Codable {

      /// USD charged per 1,000,000 input (prompt) tokens.
      public let inputPerMillion: Decimal

      /// USD charged per 1,000,000 output (completion) tokens.
      public let outputPerMillion: Decimal

      /// Creates a pricing entry.
      ///
      /// Negative inputs are clamped to zero so a malformed catalog can never
      /// produce a negative cost.
      public init(inputPerMillion: Decimal, outputPerMillion: Decimal) {
                self.inputPerMillion = Swift.max(0, inputPerMillion)
                self.outputPerMillion = Swift.max(0, outputPerMillion)
      }

      /// Computes the cost, in USD, of a given usage record under this pricing.
      public func cost(for usage: TokenUsage) -> Decimal {
                let million: Decimal = 1_000_000
                let inputCost = (Decimal(usage.promptTokens) / million) * inputPerMillion
                let outputCost = (Decimal(usage.completionTokens) / million) * outputPerMillion
                return inputCost + outputCost
      }
}
