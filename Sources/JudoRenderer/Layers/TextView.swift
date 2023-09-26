// Copyright (c) 2023-present, Rover Labs, Inc. All rights reserved.
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Rover.
//
// This copyright notice shall be included in all copies or substantial portions of
// the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import SwiftUI
import JudoModel

struct TextView: SwiftUI.View {
    @Environment(\.data) private var data
    @Environment(\.isBold) private var isBold
    @Environment(\.isItalic) private var isItalic

    @ObservedObject private var text: JudoModel.Text

    init(text: JudoModel.Text) {
        self.text = text
    }

    var body: some SwiftUI.View {
        RealizeText(text.value) { text in
            textContent(text)
        }
    }
    
    @ViewBuilder
    private func textContent(_ string: String) -> some View {
        /// Apply the .bold() and .italic() modifiers if running less than iOS 16, as outlined in Backport+bold and Backport+italic.
        if #available(iOS 16, macOS 13, *) {
            SwiftUI.Text(string)
        } else {
            if isBold && isItalic {
                SwiftUI.Text(string).bold().italic()
            } else if isBold {
                SwiftUI.Text(string).bold()
            } else if isItalic {
                SwiftUI.Text(string).italic()
            } else {
                SwiftUI.Text(string)
            }
        }
    }
}
