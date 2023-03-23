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

import JudoModel
import SwiftUI

struct BackgroundViewModifier: SwiftUI.ViewModifier {
    @ObservedObject var modifier: JudoModel.BackgroundModifier

    func body(content: Content) -> some SwiftUI.View {
        content
            .background(self.content, alignment: self.modifier.alignment.swiftUIValue)
    }
    
    @ViewBuilder private var content: some SwiftUI.View {
        SwiftUI.ZStack {
            ForEach(orderedLayers) {
                LayerView(layer: $0)
            }
        }
    }

    private var orderedLayers: [Layer] {
        modifier.children.reversed().allOf(type: Layer.self)
    }
}