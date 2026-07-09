import Foundation

/// A value type describing the token consumption of a single LLM interaction.
///
/// `TokenUsage` is deliberately transport-agnostic so it can be produced from
/// any provider response — whether it comes from an on-device model, a cloud
/// API, or a self-hosted endpoint routed through `ProviderGatewayKit`.
public struct TokenUsage: Sendable, Hashable, Codable {

      /// Tokens consumed by the prompt / input side of the exchange.
      public let promptTokens: Int

      /// Tokens produced by the model on the completion / output side.
      public let completionTokens: Int

      /// The sum of prompt and completion tokens.
      public var totalTokens: Int {
                promptTokens + completionTokens
      }

      /// Creates a usage record.
      ///
      /// - Parameters:
      ///   - promptTokens: Non-negative count of input tokens.
      ///   - completionTokens: Non-negative count of output tokens.
      public init(promptTokens: Int, completionTokens: Int) {
                self.promptTokens = max(0, promptTokens)
                self.completionTokens = max(0, completionTokens)
      }

      /// A usage record with all counts set to zero.
      public static let zero = TokenUsage(promptTokens: 0, completionTokens: 0)

      /// Adds two usage records field-by-field.
      public static func + (lhs: TokenUsage, rhs: TokenUsage) -> TokenUsage {
                TokenUsage(
                              promptTokens: lhs.promptTokens + rhs.promptTokens,
                              completionTokens: lhs.completionTokens + rhs.completionTokens
                )
      }

      /// Accumulates `rhs` into `lhs` in place.
      public static func += (lhs: inout TokenUsage, rhs: TokenUsage) {
                lhs = lhs + rhs
      }
}
