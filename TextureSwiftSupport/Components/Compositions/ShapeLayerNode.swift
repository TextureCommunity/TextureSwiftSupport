//
//  ShapeLayerNode.swift
//  AppUIKit
//
//  Created by muukii on 2019/01/27.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation

import AsyncDisplayKit

fileprivate final class BackingShapeLayerNode : ASDisplayNode {
  
  public override var supportsLayerBacking: Bool {
    return true
  }
  
  public override var layer: CAShapeLayer {
    return super.layer as! CAShapeLayer
  }
        
  public override init() {
    super.init()
    setLayerBlock {
      let shape = CAShapeLayer()
      shape.fillColor = UIColor.clear.cgColor
      shape.strokeColor = UIColor.clear.cgColor
      return shape
    }
  }
}

/// A node that displays shape with CAShapeLayer
public final class ShapeLayerNode : NamedDisplayNodeBase, ShapeDisplaying {
  
  private let backingNode = BackingShapeLayerNode()
  
  public typealias PrimitiveUpdate = (ShapeLayerNode) -> Void
  
  private let updateClosure: PrimitiveUpdate

  public var usesInnerBorder: Bool = true {
    didSet {
      setNeedsLayout()
    }
  }

  public override var supportsLayerBacking: Bool {
    return true
  }
  
  public var shapeLayer: CAShapeLayer {
    backingNode.layer
  }
  
  // To be thread-safe, using stored property
  public var shapeLineWidth: CGFloat = 0 {
    didSet {
      backingNode.layer.lineWidth = shapeLineWidth
      setNeedsLayout()
    }
  }
  
  public var shapeStrokeColor: UIColor? {
    get {
      return backingNode.layer.strokeColor.map { UIColor(cgColor: $0) }
    }
    set {
      ASPerformBlockOnMainThread {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer {
          CATransaction.commit()
        }
        self.backingNode.layer.strokeColor = newValue?.cgColor
      }
    }
  }
  
  public var shapeFillColor: UIColor? {
    get {
      return backingNode.layer.fillColor.map { UIColor(cgColor: $0) }
    }
    set {
      ASPerformBlockOnMainThread {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer {
          CATransaction.commit()
        }
        self.backingNode.layer.fillColor = newValue?.cgColor
      }
    }
  }
  
  public override func layout() {
    super.layout()
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    defer {
      CATransaction.commit()
    }
    updateClosure(self)
  }
  
  public override var frame: CGRect {
    didSet {
      ASPerformBlockOnMainThread {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer {
          CATransaction.commit()
        }
        self.updateClosure(self)
      }
    }
  }

  public convenience init(
    update: @escaping Update
  ) {
    self.init { (`self`: ShapeLayerNode) in
      self.backingNode.layer.path = update(self.bounds).cgPath
    }
  }
  
  public init(
    update: @escaping PrimitiveUpdate
  ) {
    self.updateClosure = update
    super.init()
    backgroundColor = .clear
    backingNode.backgroundColor = .clear
    backingNode.isLayerBacked = true
    automaticallyManagesSubnodes = true
  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    if usesInnerBorder {
      return ASWrapperLayoutSpec(
        layoutElement: ASInsetLayoutSpec(
          insets: .init(
            top: shapeLineWidth / 2,
            left: shapeLineWidth / 2,
            bottom: shapeLineWidth / 2,
            right: shapeLineWidth / 2
          ),
          child: backingNode
        )
      )
    } else {
      return ASWrapperLayoutSpec(layoutElement: backingNode)
    }
    
  }

}
