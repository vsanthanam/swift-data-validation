// DataValidation
// DataValidationMacro.swift
//
// MIT License
//
// Copyright (c) 2025 Varun Santhanam
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
//
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import SwiftSyntaxMacros

protocol DataValidationMacro {}

extension DataValidationMacro {

    @discardableResult
    static func validateEmailAddress(
        _ string: String
    ) throws -> String {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed == string else {
            throw MacroExpansionErrorMessage("\"\(string)\" is not a valid email address.")
        }

        let withMailTo = "mailto:\(string)"

        let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: withMailTo, options: [], range: NSRange(location: 0, length: withMailTo.utf16.count))

        guard let match = matches.first,
              matches.count == 1,
              match.resultType == .link,
              let url = match.url,
              url.scheme == "mailto",
              match.range.length == withMailTo.utf16.count else {
            throw MacroExpansionErrorMessage("\"\(string)\" is not a valid email address.")
        }
        return withMailTo

    }

    static func validateURL(
        _ url: String,
        strict: Bool
    ) throws {
        guard URL(string: url) != nil else {
            throw MacroExpansionErrorMessage("\"\(url)\" is not a valid URL")
        }
        guard strict else {
            return
        }
        try performStrictValidation(url)
    }

    private static func performStrictValidation(
        _ string: String
    ) throws {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              trimmed == string else {
            throw MacroExpansionErrorMessage("\"\(string)\" is not a valid URL")
        }
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let range = NSRange(string.startIndex..<string.endIndex, in: string)
            let matches = detector.matches(in: string, options: [], range: range)
            guard matches.count == 1,
                  let match = matches.first,
                  match.resultType == .link,
                  match.range == range else {
                throw MacroExpansionErrorMessage("\"\(string)\" is not a valid URL")
            }
            guard let components = URLComponents(string: string) else {
                throw MacroExpansionErrorMessage("\"\(string)\" is not a valid URL")
            }
            if components.scheme == nil {
                throw MacroExpansionErrorMessage("\"\(string)\" is missing a valid scheme")
            }
            if components.host == nil {
                throw MacroExpansionErrorMessage("\"\(string)\" is missing a valid host")
            }
        } catch {
            if error is MacroExpansionErrorMessage {
                throw error
            } else {
                throw MacroExpansionErrorMessage("Unknown macro excpansion failure")
            }
        }
    }

}
