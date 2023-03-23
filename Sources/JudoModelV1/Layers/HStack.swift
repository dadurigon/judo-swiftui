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

import SwiftUI

public class HStack: Layer {
    public var alignment = VerticalAlignment.center { willSet { objectWillChange.send() } }
    public var spacing = CGFloat(8) { willSet { objectWillChange.send() } }
    
    required public init() {
        super.init()
    }
    
    // MARK: Hierarchy

    override public var isLeaf: Bool {
        false
    }

    override public func canAcceptChild(ofType type: Node.Type) -> Bool {
        type is Layer.Type
    }
    
    // MARK: Traits
    
    override public var traits: Traits {
        [
            .insettable,
            .paddable,
            .frameable,
            .stackable,
            .offsetable,
            .shadowable,
            .fadeable,
            .actionable,
            .layerable,
            .accessible,
            .metadatable,
            .codePreview
        ]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let hStack = super.copy(with: zone) as! HStack
        hStack.alignment = alignment
        hStack.spacing = spacing
        return hStack
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case alignment
        case spacing
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alignment = try container.decode(VerticalAlignment.self, forKey: .alignment)
        spacing = try container.decode(CGFloat.self, forKey: .spacing)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alignment, forKey: .alignment)
        try container.encode(spacing, forKey: .spacing)
        try super.encode(to: encoder)
    }
}