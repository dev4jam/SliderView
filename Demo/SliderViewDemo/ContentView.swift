//
//  ContentView.swift
//  SliderViewDemo
//
//  Created by IT Jedi AU on 16/8/2024.
//

import SwiftUI
import SliderView

struct ContentView: View {
  @State var example1Value: CGFloat = 60.0
  @State var example2Value: CGFloat = 80.0
  @State var example3Value: CGFloat = 50.0
  @State var example4Value: CGFloat = 20.0
  @State var example5Value: CGFloat = 80.0
  @State var example6Value: CGFloat = 150.0
  @State var example7Value: CGFloat = 1.7
  @State var sliderEnabled: Bool = true
  
  var body: some View {
    ScrollView {
      VStack {
        Spacer()
        Text("\(example1Value)")
        SliderView(
          value: $example1Value,
          range: -100...100,
          increment: .none,
          thumbSize: 20,
          thumbColor: .gray,
          anchorPointSize: 4,
          guideBarCornerRadius: 1,
          guideBarColor: .gray,
          guideBarHeight: 2,
          trackingBarColor: .blue,
          trackingBarHeight: 2,
          shadow: 0,
          shadowColor: .clear
        )
        .padding(.bottom, 50)

        Text("\(example2Value)")
        SliderView(
          value: $example2Value,
          range: -30...130,
          anchorValue: 100.0,
          defaultValue: 20.0,
          increment: .none,
          thumbSize: 20,
          thumbTouchSize: 50,
          thumbColor: .gray,
          thumbTouchColor: .red.opacity(0.3),
          anchorPointSize: 4,
          guideBarCornerRadius: 1,
          guideBarColor: .gray,
          guideBarHeight: 2,
          trackingBarColor: .blue,
          trackingBarHeight: 2,
          shadow: 0,
          shadowColor: .clear
        )
        .padding(.bottom, 50)
        
        Text("\(Int(example3Value))")
        SliderView(
          value: $example3Value,
          range: 30...200,
          anchorValue: 100.0,
          defaultValue: 30.0,
          increment: .fixed(5),
          thumbSize: 20,
          thumbTouchSize: 50,
          thumbColor: .white,
          anchorPointSize: 8,
          guideBarCornerRadius: 12,
          guideBarColor: .gray.opacity(0.8),
          guideBarHeight: 24,
          trackingBarColor: .white,
          trackingBarHeight: 2,
          shadow: 0,
          shadowColor: .clear
        )
        .padding(.bottom, 50)
        
        Text("\(example4Value)")
        SliderView(
          value: $example4Value,
          range: 0...100,
          anchorValue: 0.0,
          defaultValue: 0.0,
          increment: .none,
          thumbSize: 20,
          thumbColor: .white,
          anchorPointSize: 4,
          guideBarCornerRadius: 1,
          guideBarColor: .white,
          guideBarHeight: 2,
          trackingBarColor: .green,
          trackingBarHeight: 2,
          shadow: 1,
          shadowColor: .gray
        )
        .padding(.bottom, 50)

        Text("\(example5Value)")
        SliderView(
          value: $example5Value,
          range: 0...100,
          anchorValue: 100.0,
          defaultValue: 100.0,
          increment: .none,
          thumbSize: 20,
          thumbColor: .gray,
          anchorPointSize: 8,
          guideBarCornerRadius: 1,
          guideBarColor: .gray,
          guideBarHeight: 2,
          trackingBarColor: .red,
          trackingBarHeight: 2,
          shadow: 0,
          shadowColor: .clear
        )
        .padding(.bottom, 50)
        
        Text("\(example6Value)")
        SliderView(
          value: $example6Value,
          range: 50...250,
          anchorValue: 100.0,
          defaultValue: 150.0,
          increment: .none,
          thumbSize: 20,
          thumbTouchSize: 50,
          thumbColor: .gray,
          anchorPointSize: 4,
          guideBarCornerRadius: 1,
          guideBarColor: .gray,
          guideBarHeight: 2,
          trackingBarColor: .orange,
          trackingBarHeight: 2,
          shadow: 0,
          shadowColor: .clear,
          hapticEnabled: true,
          stickyValuesEnabled: true
        )
        .padding(.bottom, 50)
        
        Text("\(example7Value)")

        SliderView(
          value: $example7Value,
          range: -3...3,
          increment: .none,
          thumbSize: 20,
          thumbTouchSize: 40,
          thumbColor: .gray,
          anchorPointSize: 4,
          guideBarCornerRadius: 1,
          guideBarColor: .gray,
          guideBarHeight: 2,
          trackingBarColor: .blue,
          trackingBarHeight: 2,
          shadow: 0,
          shadowColor: .clear,
          disabledColor: .black.opacity(0.3),
          enabled: sliderEnabled,
          leading: {
            Text("Exposure")
          },
          trailing: {
            Text(String(format: "%.2f", example7Value))
          }
        )
        .padding(.bottom, 50)
        
        Button {
          sliderEnabled = !sliderEnabled
        } label: {
          Text(sliderEnabled ? "Disable" : "Enable")
        }
        .padding(.bottom, 50)
      }
      .padding(.all, 30)
    }
  }
}

#Preview {
  ContentView()
}
