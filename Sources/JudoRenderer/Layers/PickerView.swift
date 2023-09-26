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

struct PickerView: SwiftUI.View {
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data

    private var isTextBinding: Bool
    private var options: [PickerOption]

    @ObservedObject var picker: JudoModel.Picker

    init(picker: JudoModel.Picker) {
        self.picker = picker
        self.isTextBinding = picker.textSelection != nil
        self.options = picker.options

    }

    var body: some View {
        RealizeText(picker.label) { label in
            if isTextBinding {
                SwiftUI.Picker(label, selection: stringSelectionBinding) {
                    ForEach(options) { option in
                        row(for: option)
                            .tag(textTag(option))
                    }
                }
            } else {
                SwiftUI.Picker(label, selection: numberSelectionBinding) {
                    ForEach(options) { option in
                        row(for: option)
                            .tag(numberTag(option))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func row(for option: PickerOption) -> some View {
        RealizeText(option.title ?? "") { title in
            if let imageReference = option.icon?.forceResolve(properties: componentState.properties, data: data) {
                if title.isEmpty {
                    ImageReferenceView(
                        imageReference: imageReference,
                        resizing: .none,
                        renderingMode: .original,
                        symbolRenderingMode: .monochrome
                    )
                } else {
                    SwiftUI.Label {
                        SwiftUI.Text(title)
                    } icon: {
                        ImageReferenceView(
                            imageReference: imageReference,
                            resizing: .none,
                            renderingMode: .original,
                            symbolRenderingMode: .monochrome
                        )
                    }
                }
            } else {
                SwiftUI.Text(title)
            }
        }
    }

    private var stringSelectionBinding: Binding<String?> {
        Binding {
            picker.textSelection?.forceResolve(properties: componentState.properties, data: data)
        } set: { newValue in
            guard let newValue else {
                return
            }
            
            if case let .property(name) = picker.textSelection?.binding {
                componentState.bindings[name]?.value = .text(newValue)
            }
        }
    }

    private func textTag(_ option: PickerOption) -> String? {
        if let textValue = option.textValue {
            return textValue.forceResolve(properties: componentState.properties, data: data)
        }

        return nil
    }

    private var numberSelectionBinding: Binding<Double?> {
        Binding {
            picker.numberSelection?.forceResolve(properties: componentState.properties, data: data)
        } set: { newValue in
            guard let newValue else {
                return
            }
            
            if case let .property(name) = picker.numberSelection?.binding {
                componentState.bindings[name]?.value = .number(newValue)
            }
        }
    }

    private func numberTag(_ option: PickerOption) -> Double? {
        if let numberValue = option.numberValue {
            return numberValue.forceResolve(properties: componentState.properties, data: data)
        }

        return nil
    }
}
