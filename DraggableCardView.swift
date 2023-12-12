//
//  DraggableCardView.swift
//
//
//  Created by Łukasz Malicki on 12/12/2023.
//


import SwiftUI

enum CardSwipeDirection: Int {
  case left
  case right
  case up
  case down
  
  static let allDirections: [CardSwipeDirection] = [left, up, right, down]
  
  var vector: CGVector {
    switch self {
    case .left:
      return CGVector(dx: -1, dy: 0)
    case .right:
      return CGVector(dx: 1, dy: 0)
    case .up:
      return CGVector(dx: 0, dy: -1)
    case .down:
      return CGVector(dx: 0, dy: 1)
    }
  }
}

public enum CardSwipeBottom {
  case bottom
  
  public static func direction(degrees: Double) -> Self? {
    switch degrees {
    case 135..<225: return .bottom
    default: return nil
    }
  }
}


struct DraggableCardView<Content: View>: View {
  
  private let content: () -> Content
  private let onSwipe: ((CardSwipeDirection) -> Void)?
  private let overlay: (Double, CGSize, CardSwipeDirection) -> (any View)?
  
  @State private var translation: CGSize = .zero
  @State private var dragPercent: Double = .zero
  @State private var activeDragDirection: CardSwipeDirection?
  
  init(
    @ViewBuilder content: @escaping () -> Content,
    onSwipe: @escaping (CardSwipeDirection) -> Void,
    @ViewBuilder overlay: @escaping (Double, CGSize, CardSwipeDirection) -> (any View)?
  ) {
    self.content = content
    self.onSwipe = onSwipe
    self.overlay = overlay
  }
  
  var body: some View {
    ZStack(alignment: .bottom, content: {
      VStack {
        content()
        
        // add show extra shadow to the card
          .shadow(radius: 15)
          .overlay(content: {
            if
              let dragDirection = activeDragDirection,
              let overlayView = self.overlay(dragPercent, translation, dragDirection)
            {
              AnyView(overlayView)
            }
          })
        Spacer(minLength: 0)
      }
    })
    
    // rotate card when dragging left/right
    .rotationEffect(.degrees(Double(translation.width/5)))
    
    // move card while dragging
    .offset(
      x: translation.width * 3,
      y: translation.height * 1.1
    )
    
    // add drag gesture handler
    .gesture(
      DragGesture(minimumDistance: 2)
        .onChanged(onDrag)
        .onEnded(onDragEnd)
    )
  }
}

extension DraggableCardView {
  
  
  
  func onDrag(_ gesture: DragGesture.Value) {
    translation = gesture.translation
    dragPercent = gesture.getDragPercentage()
    activeDragDirection = activeDirection(gesture: gesture)
  }
  
  func onDragEnd(_ gesture: DragGesture.Value) {
    if dragPercent > 0.7 {
      
      let dragDirection = activeDirection(gesture: gesture)
      onSwipe?(dragDirection)
      
    } else {
      withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
        translation = .zero
        dragPercent = .zero
        self.activeDragDirection = nil
      }
    }
  }
  
  private func getDirection(_ geo: CGSize) -> CardSwipeDirection? {
    
    if geo.width >= 1 {
      return CardSwipeDirection.right
    }
    
    if geo.width <= -1 {
      return CardSwipeDirection.left
    }
    
    if geo.height >= 1 {
      return CardSwipeDirection.down
    }
    
    if geo.height <= -1 {
      return CardSwipeDirection.up
    }
    
    return nil
  }
  
  public func activeDirection(gesture: DragGesture.Value) -> CardSwipeDirection {
    let xDiff = gesture.location.x - gesture.startLocation.x
    let yDiff = gesture.location.y - gesture.startLocation.y
    
    if abs(xDiff) > abs(yDiff) {
      self.translation.width = gesture.translation.width
      if xDiff > 0 {
        return CardSwipeDirection.right
      }
      
      return CardSwipeDirection.left
    } else {
      self.translation.height = gesture.translation.height
      if yDiff > 0 {
        return CardSwipeDirection.down
      }
      return CardSwipeDirection.up
    }
  }
  
}

extension DragGesture.Value {
  
  func getDragPercentage() -> Double {
    
    let gesture = self
    
    let xDiff = gesture.location.x - gesture.startLocation.x
    let yDiff = gesture.location.y - gesture.startLocation.y
    
    if abs(xDiff) > abs(yDiff) {
      let screenWidth = UIScreen.main.bounds.width / 4
      let dragPercentage = min(1.0, abs(xDiff / screenWidth))
      return dragPercentage
    } else {
      let screenHeight = UIScreen.main.bounds.height / 4
      let dragPercentage = min(1.0, abs(yDiff / screenHeight))
      return dragPercentage
    }
  }
}
