// DataValidation
// EmailStringMacro.swift
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

public struct EmailStringMacro: ExpressionMacro, DataValidationMacro {

    // MARK: - ExpressionMacro

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard node.arguments.count == 1 else {
            throw MacroExpansionErrorMessage("#email accepts at most two arguments.")
        }

        let segments = try node.arguments.first
            .required(reason: "#email requires a string literal segment with no interpolation.")
            .expression
            .as(StringLiteralExprSyntax.self)
            .required(reason: "#email requires a string literal segment with no interpolation.")
            .segments

        guard segments.count == 1 else {
            throw MacroExpansionErrorMessage("#email requires a string literal segment with no interpolation.")
        }

        let emailString = try segments.first
            .required()
            .as(StringSegmentSyntax.self)
            .required()
            .content
            .text

        let wrapped = try validateEmailAddress(emailString)
        return "\"\(raw: wrapped)\""
    }

}
