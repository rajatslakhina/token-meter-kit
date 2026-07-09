import Foundation

/// A thread-safe catalog mapping model identifiers to their `ModelPricing`.
///
/// The registry is an `actor` so it can be shared safely across concurrent
/// provider calls — the same way `ProviderGatewayKit` shares its router.
public actor PricingRegistry {

      private var table: [String: ModelPricing]

      /// Creates a registry seeded with an optional initial table.
      public init(_ table: [String: ModelPricing] = [:]) {
                self.table = table
      }

      /// Registers (or overwrites) the pricing for a model identifier.
      public func register(_ pricing: ModelPricing, for modelID: String) {
                table[modelID] = pricing
      }

      /// Returns the pricing for a model identifier, or `nil` if unknown.
      public func pricing(for modelID: String) -> ModelPricing? {
                table[modelID]
      }

      /// The identifiers currently known to the registry.
      public var knownModels: [String] {
                table.keys.sorted()
      }

      /// A small, illustrative default catalog.
      ///
      /// These numbers are placeholders for demonstration only and are not a
      /// live price list — callers should register their own current rates.
      public static func makeDefault() -> PricingRegistry {
                // 0.15 and 0.60 are written as exact Decimal fractions to avoid both
                // force-unwrapping and binary floating-point imprecision.
                let fifteenCents = Decimal(15) / Decimal(100)
                let sixtyCents = Decimal(60) / Decimal(100)
                return PricingRegistry([
                              "gpt-4o": ModelPricing(inputPerMillion: 5, outputPerMillion: 15),
                              "gpt-4o-mini": ModelPricing(inputPerMillion: fifteenCents,
                                                                                                  outputPerMillion: sixtyCents),
                              "claude-sonnet": ModelPricing(inputPerMillion: 3, outputPerMillion: 15),
                              "on-device": ModelPricing(inputPerMillion: 0, outputPerMillion: 0)
                ])
      }
}
