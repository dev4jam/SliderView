//
//  SliderView.swift
//  Dehancer UI
//
//  Created by Dmitry Klimkin on 15/8/2024.
//

import SwiftUI

public struct SliderView<LeadingView: View, TrailingView: View>: View {
  public enum Increment {
    case none
    case fixed(CGFloat)
  }
    
  /// A binding to a variable that holds the current slider value.
  @Binding public var value: CGFloat
  
  /// The lower and upper bounds of the slider
  public var range: ClosedRange<CGFloat>
  
  /// The anchor point value
  public let anchorValue: CGFloat

  /// Default point value
  public let defaultValue: CGFloat

  /// The increment by which the value should change. If this is none, the value changes continuously.
  public let increment: Increment
  
  /// The size of the slider's thumb.
  public let thumbSize: CGFloat

  /// The size of the slider's thumb touch area.
  public let thumbTouchSize: CGFloat

  /// The color of the slider's thumb.
  public let thumbColor: Color

  /// The color of the slider's thumb touch area.
  public let thumbTouchColor: Color

  /// The size of the anchor point of the slider,
  public let anchorPointSize: CGFloat
  
  /// The corner radius of the slider's guide bar.
  public let guideBarCornerRadius: CGFloat
  
  /// The color of the slider's guide bar.
  public let guideBarColor: Color
  
  /// The height of the slider's guide bar.
  public let guideBarHeight: CGFloat
  
  /// The color of the slider's tracking bar.
  public let trackingBarColor: Color
  
  /// The height of the slider's tracking bar.
  public let trackingBarHeight: CGFloat
  
  /// The shadow radius of the slider's thumb.
  public let shadow: CGFloat
    
  /// The color of the slider's disable view.
  public let disabledColor: Color
  
  /// Enable / Disable slider
  public let enabled: Bool
  
  /// Enable / Disable haptic feedback when max / min / anchor value selected
  public let hapticEnabled: Bool

  /// Enable / Disable sticking value to anchor / default / min / max values on change
  public let stickyValuesEnabled: Bool

  /// The shadow radius' color.
  public let shadowColor: Color
  
  /// Optional leading view: for example title view
  public let leadingView: LeadingView?
  
  /// Optional trailing view: for eample value view
  public let trailingView: TrailingView?

  private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
  
  private let stickyValuePercentage: CGFloat
  
  private let normalizedAnchor: CGFloat

  private let normalizedDefaultValue: CGFloat

  private let normalizedMinValue: CGFloat

  private let normalizedMaxValue: CGFloat

  @State
  private var lastDefaultBorderValue: CGFloat

  @State
  private var lastMinBorderValue: CGFloat

  @State
  private var lastMaxBorderValue: CGFloat

  @State
  private var lastAnchorBorderValue: CGFloat
  
  private var normalizedValue: CGFloat {
    normalizedValueOf(value)
  }

  public init(
    value: Binding<CGFloat>,
    range: ClosedRange<CGFloat>,
    anchorValue: CGFloat? = nil,
    defaultValue: CGFloat? = nil,
    increment: Increment = .none,
    thumbSize: CGFloat = 16,
    thumbTouchSize: CGFloat = 44,
    thumbColor: Color = .white,
    thumbTouchColor: Color = .clear,
    anchorPointSize: CGFloat = 0,
    guideBarCornerRadius: CGFloat = 2,
    guideBarColor: Color = .gray,
    guideBarHeight: CGFloat = 4,
    trackingBarColor: Color = .white,
    trackingBarHeight: CGFloat = 4,
    shadow: CGFloat = 2,
    shadowColor: Color = .gray,
    disabledColor: Color = .gray.opacity(0.3),
    enabled: Bool = true,
    hapticEnabled: Bool = false,
    stickyValuesEnabled: Bool = false,
    @ViewBuilder leading: () -> LeadingView? = { EmptyView() },
    @ViewBuilder trailing: () -> TrailingView? = { EmptyView() }
  ) {
    assert(thumbSize <= thumbTouchSize, "Thumb touch area should be larger than thumb size")

    self._value = value
    self.range = range
    self.increment = increment
    self.thumbSize = thumbSize
    self.thumbTouchSize = thumbTouchSize
    self.thumbColor = thumbColor
    self.thumbTouchColor = thumbTouchColor
    self.anchorPointSize = anchorPointSize
    self.guideBarCornerRadius = guideBarCornerRadius
    self.guideBarColor = guideBarColor
    self.guideBarHeight = guideBarHeight
    self.trackingBarColor = trackingBarColor
    self.trackingBarHeight = trackingBarHeight
    self.shadow = shadow
    self.shadowColor = shadowColor
    self.disabledColor = disabledColor
    self.enabled = enabled
    self.hapticEnabled = hapticEnabled
    self.stickyValuesEnabled = stickyValuesEnabled
    self.leadingView = leading()
    self.trailingView = trailing()
    self.stickyValuePercentage = 3.0
    
    self.lastMaxBorderValue = CGFloat.infinity
    self.lastMinBorderValue = CGFloat.infinity
    self.lastDefaultBorderValue = CGFloat.infinity
    self.lastAnchorBorderValue = CGFloat.infinity

    if let anchorValue {
      self.anchorValue = anchorValue
    } else {
      self.anchorValue = range.lowerBound + (range.upperBound - range.lowerBound) / 2
    }
        
    if let defaultValue {
      self.defaultValue = defaultValue
    } else {
      self.defaultValue = self.anchorValue
    }
    
    let absoluteRangeCenter = (range.upperBound - range.lowerBound) / 2
    let rangeCenter = absoluteRangeCenter + range.lowerBound

    self.normalizedAnchor = (self.anchorValue - rangeCenter) / absoluteRangeCenter
    self.normalizedDefaultValue = (self.defaultValue - rangeCenter) / absoluteRangeCenter
    self.normalizedMinValue = (range.lowerBound - rangeCenter) / absoluteRangeCenter
    self.normalizedMaxValue = (range.upperBound - rangeCenter) / absoluteRangeCenter
    
    assert(range.lowerBound <= value.wrappedValue && value.wrappedValue <= range.upperBound,
           "Value (\(value.wrappedValue)) should be within provided range (\(range.lowerBound)...\(range.upperBound))")
    assert(range.lowerBound <= self.anchorValue && self.anchorValue <= range.upperBound,
           "Anchor value (\(self.anchorValue)) should be within provided range (\(range.lowerBound)...\(range.upperBound))")
    assert(range.lowerBound <= self.defaultValue && self.defaultValue <= range.upperBound,
           "Default value (\(self.defaultValue)) should be within provided range (\(range.lowerBound)...\(range.upperBound))")
  }
  
  public var body: some View {
    GeometryReader { proxy in
      ZStack {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            if let leadingView {
              leadingView
            }
            
            Spacer()
            
            if let trailingView {
              trailingView
            }
          }
          
          ZStack {
            guideBar
            centerPointCircle(in: proxy)
            trackingBar(size: getRectangleSize(proxy: proxy), in: proxy)
            thumb(in: proxy)
              .allowsHitTesting(enabled)
              .gesture(DragGesture().onChanged { dragGesture(gesture: $0, proxy: proxy) })
              .onTapGesture(count: 2, perform: {
                if hapticEnabled {
                  feedbackGenerator.impactOccurred()
                }
                
                if stickyValuesEnabled {
                  value = defaultValue
                }
                lastDefaultBorderValue = defaultValue
              })
          }
        }
        
        if !enabled {
          disabledView
        }
      }
    }
    .onAppear() {
      // Prepare the feedback generator to reduce latency
      feedbackGenerator.prepare()
    }
  }
  
  private func normalizedValueOf(_ value: CGFloat) -> CGFloat {
    let absoluteRangeCenter = (range.upperBound - range.lowerBound) / 2
    let rangeCenter = absoluteRangeCenter + range.lowerBound
    let pos = (value - rangeCenter) / absoluteRangeCenter
        
    return pos
  }
  
  private func realValueFrom(_ normalizedValue: CGFloat) -> CGFloat {
    let absoluteRangeCenter = (range.upperBound - range.lowerBound) / 2
    let rangeCenter = absoluteRangeCenter + range.lowerBound
    let value = normalizedValue * absoluteRangeCenter + rangeCenter
        
    return value
  }
  
  private func dragGesture(gesture: DragGesture.Value, proxy: GeometryProxy) {
    let normalizedLocation = (gesture.location.x - thumbTouchSize / 2) / ((proxy.size.width - thumbSize) / 2)
    
    let normalizedValue = max(min(1.0, normalizedLocation), -1.0)
    let updatedValue = realValueFrom(normalizedValue)
    let clampedValue = max(min(updatedValue, range.upperBound), range.lowerBound)
    
    switch increment {
    case .fixed(let increment):
      value = (clampedValue / increment).rounded() * increment
    case .none:
      value = clampedValue
    }
    
    let normValue = normalizedValue
        
    checkDefaultValueBorder(normValue: normValue)
    checkMaxValueBorder(normValue: normValue)
    checkMinValueBorder(normValue: normValue)
    checkAnchorValueBorder(normValue: normValue)
  }
  
  private func checkDefaultValueBorder(normValue: CGFloat) {
    let offset = normalizedMaxValue * 2 / 100.0 * stickyValuePercentage;

    if (normValue >= normalizedDefaultValue - offset && normValue <= normalizedDefaultValue + offset) {
      if (lastDefaultBorderValue != normalizedDefaultValue) {
        lastDefaultBorderValue = normalizedDefaultValue;
        
        if stickyValuesEnabled {
          value = defaultValue
        }
        
        if hapticEnabled {
          feedbackGenerator.impactOccurred()
        }
      }
    } else {
      lastDefaultBorderValue = normValue;
    }
  }
  
  private func checkMinValueBorder(normValue: CGFloat) {
    let offset = normalizedMaxValue * 2 / 100.0 * stickyValuePercentage;

    if (normValue >= normalizedMinValue - offset && normValue <= normalizedMinValue + offset) {
      if (lastMinBorderValue != normalizedMinValue) {
        lastMinBorderValue = normalizedMinValue;
        
        if stickyValuesEnabled {
          value = range.lowerBound
        }
        
        if hapticEnabled {
          feedbackGenerator.impactOccurred()
        }
      }
    } else {
      lastMinBorderValue = normValue;
    }
  }
  
  private func checkMaxValueBorder(normValue: CGFloat) {
    let offset = normalizedMaxValue * 2 / 100.0 * stickyValuePercentage;

    if (normValue >= normalizedMaxValue - offset && normValue <= normalizedMaxValue + offset) {
      if (lastMaxBorderValue != normalizedMaxValue) {
        lastMaxBorderValue = normalizedMaxValue;
        
        if stickyValuesEnabled {
          value = range.upperBound
        }
        
        if hapticEnabled {
          feedbackGenerator.impactOccurred()
        }
      }
    } else {
      lastMaxBorderValue = normValue;
    }
  }
  
  private func checkAnchorValueBorder(normValue: CGFloat) {
    let offset = normalizedMaxValue * 2 / 100.0 * stickyValuePercentage;

    if (normValue >= normalizedAnchor - offset && normValue <= normalizedAnchor + offset) {
      if (lastAnchorBorderValue != normalizedAnchor) {
        lastAnchorBorderValue = normalizedAnchor;
        
        if stickyValuesEnabled {
          value = anchorValue
        }
        
        if hapticEnabled {
          feedbackGenerator.impactOccurred()
        }
      }
    } else {
      lastAnchorBorderValue = normValue;
    }
  }
}

private extension SliderView {
  private func thumb(in proxy: GeometryProxy) -> some View {
    ZStack {
      Rectangle()
        .fill(thumbTouchColor)
        .frame(width: thumbTouchSize, height: thumbTouchSize)

      Circle()
        .fill(thumbColor)
        .frame(width: thumbSize, height: thumbSize)
        .shadow(color: shadowColor, radius: shadow)
    }
    .offset(x: (proxy.size.width - thumbSize) / 2 * normalizedValue, y: 0)
  }
  
  private func trackingBar(size: CGSize, in proxy: GeometryProxy) -> some View {
    Rectangle()
      .fill(trackingBarColor)
      .frame(width: size.width, height: size.height)
      .offset(x: trackingBarOffsetX(size: size, in: proxy), y: 0)
  }
  
  private var guideBar: some View {
    Rectangle()
      .fill(guideBarColor)
      .clipShape(RoundedRectangle(cornerRadius: guideBarCornerRadius))
      .frame(width: nil, height: guideBarHeight)
  }
  
  private func centerPointCircle(in proxy: GeometryProxy) -> some View {
    Circle()
      .fill(trackingBarColor)
      .frame(width: anchorPointSize, height: anchorPointSize)
      .offset(x: centerPointCircleOffsetX(in: proxy), y: 0)
  }
  
  private var disabledView: some View {
    Rectangle()
      .fill(disabledColor)
      .frame(width: nil, height: nil)
  }
  
  private func centerPointCircleOffsetX(in proxy: GeometryProxy) -> CGFloat {
    guard anchorValue != range.upperBound else { return proxy.size.width / 2 - anchorPointSize / 2 }
    guard anchorValue != range.lowerBound else { return -proxy.size.width / 2 + anchorPointSize / 2 }

    return (proxy.size.width - thumbSize) / 2 * normalizedAnchor
  }
    
  private func trackingBarOffsetX(size: CGSize, in proxy: GeometryProxy) -> CGFloat {
    var offset: CGFloat = 0
    
    if value <= anchorValue {
      offset = size.width / 2 + (proxy.size.width - thumbSize) / 2 * normalizedValue
      
      if anchorValue == range.upperBound {
        offset += thumbSize / 2
      }
    } else {
      offset = size.width / 2 + (proxy.size.width - thumbSize) / 2 * normalizedAnchor
      
      if anchorValue == range.lowerBound {
        offset -= thumbSize / 2
      }
    }
        
    return offset
  }

  private func trackingBarLength(proxyLength: CGFloat) -> CGFloat {
    let normValue = normalizedValue
    let normAnchor = normalizedAnchor
    let lengthToValue = abs(proxyLength / 2 * normValue)
    let lengthToAnchor = abs(proxyLength / 2 * normAnchor)
    
    var length: CGFloat = 0.0
    
    if (normValue < 0.0 && normAnchor < 0.0) || (normValue > 0.0 && normAnchor > 0.0) {
      length = abs(lengthToValue - lengthToAnchor)
    } else {
      length = lengthToValue + lengthToAnchor
    }
            
    return length
  }
  
  private func getRectangleSize(proxy: GeometryProxy) -> CGSize {
    CGSize(width: trackingBarLength(proxyLength: proxy.size.width - thumbSize), height: trackingBarHeight)
  }
}

private extension View {
  func frame(size: CGSize) -> some View {
    self.frame(width: size.width, height: size.height)
  }
}

#Preview {
  @State var value: CGFloat = 100.0
  
  return VStack {
    Spacer()
    SliderView(
      value: $value,
      range: -30...100,
      anchorValue: 70.0,
      defaultValue: 50.0,
      increment: .none,
      thumbSize: 20,
      thumbTouchSize: 50,
      thumbColor: .gray,
      thumbTouchColor: .red.opacity(0.3),
      anchorPointSize: 8,
      guideBarCornerRadius: 1,
      guideBarColor: .gray,
      guideBarHeight: 2,
      trackingBarColor: .blue,
      trackingBarHeight: 2,
      shadow: 0,
      shadowColor: .clear,
      enabled: true,
      leading: {
        Text("Slider")
      },
      trailing: {
        Text("\(value)")
      }
    )
    .padding(.all, 40)
    Spacer()
  }
}
