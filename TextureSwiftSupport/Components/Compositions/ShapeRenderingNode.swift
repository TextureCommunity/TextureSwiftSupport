//
// Copyright (c) 2020 Hiroshi Kimura(Muukii) <muuki.app@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

import AsyncDisplayKit

public final class ShapeRenderingNode: NamedDisplayNodeBase, ShapeDisplaying {
    
  private struct Backing: Hashable {
    var shapeFillColor: UIColor? = .black
    var shapePath: UIBezierPath?
    var shapeLineWidth: CGFloat = 0
    var shapeStrokeColor: UIColor?
  }
  
  private final class ParameterBox: NSObject {
    let backing: Backing
    init(backing: Backing) {
      self.backing = backing
    }
  }
  
  private var backing: Backing = .init() {
    didSet {
      setNeedsDisplay()
    }
  }

  public var shapeFillColor: UIColor? {
    get { backing.shapeFillColor }
    set { backing.shapeFillColor = newValue }
  }
  
  public var shapePath: UIBezierPath? {
    get { backing.shapePath }
    set { backing.shapePath = newValue }
  }
  
  public var shapeLineWidth: CGFloat {
    get { backing.shapeLineWidth }
    set { backing.shapeLineWidth = newValue }
  }
  
  public var shapeStrokeColor: UIColor? {
    get { backing.shapeStrokeColor }
    set { backing.shapeStrokeColor = newValue }
  }
    
  private let updateClosure: Update?
  
  public override init() {
    self.updateClosure = nil
    super.init()
    isOpaque = false
    backgroundColor = .clear
  }
    
  public init(update: @escaping Update) {
    self.updateClosure = update
    super.init()
    isOpaque = false
    backgroundColor = .clear
    clipsToBounds = false
  }
  
  public override func layout() {
    super.layout()
    if let closure = updateClosure {
      shapePath = closure(bounds)
    }
  }
  
  public override func drawParameters(forAsyncLayer layer: _ASDisplayLayer) -> NSObjectProtocol? {
    ParameterBox(backing: backing)
  }
  
  public override class func draw(_ bounds: CGRect, withParameters parameters: Any?, isCancelled isCancelledBlock: () -> Bool, isRasterizing: Bool) {
    
    guard let parameter = parameters as? ParameterBox else { return }
    
    let backing = parameter.backing
    
    guard let path = backing.shapePath else { return }
    
    path.lineWidth = backing.shapeLineWidth
        
    backing.shapeFillColor?.setFill()
    path.fill()
    
    backing.shapeStrokeColor?.setStroke()

    path.stroke()
    
  }
  
}

