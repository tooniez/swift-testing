//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors
//

extension ABI {
  /// A type implementing the JSON encoding of
  /// ``Event/HumanReadableOutputRecorder/Message`` for the ABI entry point and
  /// event stream output.
  ///
  /// This type is not part of the public interface of the testing library. It
  /// assists in converting values to JSON; clients that consume this JSON are
  /// expected to write their own decoders.
  struct EncodedMessage<V>: Sendable where V: ABI.Version {
    /// A type implementing the JSON encoding of ``Event/Symbol`` for the ABI
    /// entry point and event stream output.
    ///
    /// For descriptions of individual cases, see ``Event/Symbol``.
    enum Symbol: String, Sendable {
      case `default`
      case skip
      case pass
      case passWithWarnings = "_passWithWarnings"
      case passWithKnownIssue
      case fail
      case difference
      case warning
      case details
      case attachment = "_attachment"

      init(encoding symbol: Event.Symbol) {
        self = switch symbol {
        case .default:
          .default
        case .skip:
          .skip
        case let .pass(knownIssueCount):
          if knownIssueCount > 0 {
            .passWithKnownIssue
          } else {
            .pass
          }
        case .passWithWarnings:
          .passWithWarnings
        case .fail:
          .fail
        case .difference:
          .difference
        case .warning:
          .warning
        case .details:
          .details
        case .attachment:
          .attachment
        }
      }
    }

    /// The symbol associated with this message.
    var symbol: Symbol

    /// The human-readable, unformatted text associated with this message.
    var text: String

    init(encoding message: borrowing Event.HumanReadableOutputRecorder.Message) {
      symbol = Symbol(encoding: message.symbol ?? .default)
      text = message.conciseStringValue ?? message.stringValue
    }
  }
}

// MARK: - Codable

extension ABI.EncodedMessage: Codable {}
extension ABI.EncodedMessage.Symbol: Codable {}
