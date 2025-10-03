// DataValidation
// URLMacro.swift
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
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct URLMacro: ExpressionMacro, DataValidationMacro {

    // MARK: - ExpressionMacro

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard node.arguments.count <= 2 else {
            throw MacroExpansionErrorMessage("#URL accepts at most two arguments.")
        }

        let segments = try node.arguments.first
            .required(reason: "#URL requires a string literal segment with no interpolation.")
            .expression
            .as(StringLiteralExprSyntax.self)
            .required(reason: "#URL requires a string literal segment with no interpolation.")
            .segments

        guard segments.count == 1 else {
            throw MacroExpansionErrorMessage("#URL requires a string literal segment with no interpolation.")
        }

        let urlString = try segments.first
            .required()
            .as(StringSegmentSyntax.self)
            .required()
            .content
            .text

        if node.arguments.count > 1 {
            let strictArgument = try node.arguments
                .last
                .required()
                .expression
                .as(BooleanLiteralExprSyntax.self)
                .required(reason: "#URL's strictValidation argument requires a boolean literal expression")
                .literal
            if strictArgument.text == "true" {
                try validateURL(urlString, strict: true)
            } else {
                try validateURL(urlString, strict: false)
            }
        } else {
            try validateURL(urlString, strict: true)
        }

        return "Foundation.URL(string: \"\(raw: urlString)\")!"
    }

}
