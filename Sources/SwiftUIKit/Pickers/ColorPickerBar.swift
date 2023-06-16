//
//  ColorPickerBar.swift
//  SwiftUIKit
//
//  Created by Daniel Saidi on 2023-06-13.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import Foundation

#if os(iOS) || os(macOS)
import SwiftUI

/**
 This color picker bar can be used to select colors, using a
 SwiftUI `ColorPicker` and a list of colors.

 The picker supports both optional and non-optional bindings.

 Note that you have to pass in a list of colors. You can use
 `.colorPickerBarColors` for a standard set of colors.
 */
@available(iOS 15.0, macOS 12.0, *)
public struct ColorPickerBar: View {

    /**
     Create a color picker bar with an optional binding.

     - Parameters:
       - value: The optional value to bind to.
       - colors: The colors to list in the bar, by default `.colorPickerBarColors`.
       - config: The configuration to use, by default `.standard`.
       - style: The style to use, by default `.standard`.
     */
    public init(
        value: Binding<Color?>,
        colors: [Color] = .colorPickerBarColors,
        config: Configuration = .standard,
        style: Style = .standard
    ) {
        self.value = value
        self.colors = colors
        self.config = config
        self.style = style
    }

    /**
     Create a color picker bar.

     - Parameters:
       - value: The non-optional value to bind to.
       - colors: The colors to list in the bar, by default `.colorPickerBarColors`.
       - config: The configuration to use, by default `.standard`.
       - style: The style to use, by default `.standard`.
     */
    public init(
        value: Binding<Color>,
        colors: [Color] = .colorPickerBarColors,
        config: Configuration = .standard,
        style: Style = .standard
    ) {
        self.value = .init(get: {
            value.wrappedValue
        }, set: {
            value.wrappedValue = $0 ?? .clear
        })
        self.colors = colors
        self.config = config
        self.style = style
    }

    private let value: Binding<Color?>
    private let colors: [Color]
    private let config: Configuration
    private let style: Style

    @Environment(\.colorScheme)
    private var colorScheme

    public var body: some View {
        HStack(spacing: 0) {
            picker
            if !colors.isEmpty {
                divider
                scrollView
            }
            if config.addResetButton {
                divider
                resetButton
            }
        }
        .labelsHidden()
    }
}

@available(iOS 15.0, macOS 12.0, *)
public extension ColorPickerBar {

    /// This type can be used to config a ``ColorPickerBar``.
    struct Configuration {

        /**
         Create a color picker bar configuration.

         - Parameters:
           - addOpacityToPicker: Whether or not to add color picker opacity, by default `true`.
           - addResetButton: Whether or not to add add a reset button to the bar, by default `false`.
           - resetButtonValue: The color to apply when tapping the reset button, by default `nil/clear`.
         */
        public init(
            addOpacityToPicker: Bool = true,
            addResetButton: Bool = false,
            resetButtonValue: Color? = nil
        ) {
            self.addOpacityToPicker = addOpacityToPicker
            self.addResetButton = addResetButton
            self.resetButtonValue = resetButtonValue
        }

        /// Whether or not to add color picker opacity.
        public var addOpacityToPicker: Bool

        /// Whether or not to add a reset button to the bar.
        public var addResetButton: Bool

        /// The color to apply when tapping the reset button.
        public var resetButtonValue: Color?

        /// Get the standard configuration.
        public static var standard: Configuration = .init()
    }

    /// This type can be used to style a ``ColorPickerBar``.
    struct Style {

        /**
         Create a color picker bar configuration.

         - Parameters:
           - animation: The animation to apply when picking color, by default `.default`.
           - spacing: The bar item spacing, by default `10`.
           - colorSize: The size of non-selected colors, by default `20`.
           - selectedColorSize: The size of the selected color, by default `30`.
           - resetButtonImage: The image to use as reset button image, by default `circle.slash`.
         */
        public init(
            animation: Animation = .default,
            spacing: Double = 10.0,
            colorSize: Double = 20.0,
            selectedColorSize: Double = 30.0,
            resetButtonImage: Image = Image(systemName: "xmark.circle")
        ) {
            self.animation = animation
            self.spacing = spacing
            self.colorSize = colorSize
            self.selectedColorSize = selectedColorSize
            self.resetButtonImage = resetButtonImage
        }

        /// The animation to apply when picking colors.
        public var animation: Animation

        /// The bar item spacing.
        public var spacing: Double

        /// The size of non-selected colors.
        public var colorSize: Double

        /// The size of the selected color.
        public var selectedColorSize: Double

        /// The image to use as reset button image
        public var resetButtonImage: Image

        /// Get the standard style.
        public static var standard: Style = .init()
    }
}

@available(iOS 15.0, macOS 12.0, *)
private extension ColorPickerBar {

    var divider: some View {
        Divider()
            .padding(0)
            .frame(maxHeight: style.selectedColorSize)
    }

    var picker: some View {
        ColorPicker(
            "",
            selection: value ?? .clear,
            supportsOpacity: config.addOpacityToPicker
        )
        .fixedSize()
        .padding(.trailing, style.spacing)
    }

    var resetButton: some View {
        Button {
            value.wrappedValue = config.resetButtonValue
        } label: {
            style.resetButtonImage
                .resizable()
                .frame(width: style.colorSize, height: style.colorSize)
        }
        .padding(.leading)
    }

    var scrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: style.spacing) {
                ForEach(Array(colors.enumerated()), id: \.offset) {
                    scrollViewButton(for: $0.element)
                }
            }
            .padding(.horizontal, style.spacing)
            .padding(.vertical, 2)
        }.frame(maxWidth: .infinity)
    }

    func scrollViewButton(for color: Color) -> some View {
        Button {
            value.wrappedValue = color
        } label: {
            let size = scrollViewCircleSize(for: color)
            scrollViewCircle(for: color)
                .frame(width: size, height: size)
                .padding(.vertical, isSelected(color) ? 0 : 5)
                .animation(style.animation, value: value.wrappedValue)
        }.buttonStyle(.plain)
    }

    @ViewBuilder
    func scrollViewCircle(for color: Color) -> some View {
        Circle()
            .stroke(scrollViewCircleStroke(for: color), lineWidth: 1)
            .background(scrollViewCircleBackground(for: color))
    }

    @ViewBuilder
    func scrollViewCircleBackground(for color: Color) -> some View {
        if color == .clear {
            Image(systemName: "circle.dotted")
                .resizable()
        } else {
            Circle()
                .fill(color)
                .shadow(.badge)
        }
    }

    func scrollViewCircleSize(for color: Color) -> Double {
        isSelected(color) ? style.selectedColorSize : style.colorSize
    }

    func scrollViewCircleStroke(for color: Color) -> Color {
        if color == .black && colorScheme == .dark { return .white }
        return .clear
    }
}

@available(iOS 15.0, macOS 12.0, *)
private extension ColorPickerBar {

    func isSelected(_ color: Color) -> Bool {
        value.wrappedValue == color
    }

    func select(color: Color) {
        value.wrappedValue = color
    }
}

@available(iOS 15.0, macOS 12.0, *)
public extension Collection where Element == Color {

    /// Get a standard list of `ColorPickerBar` colors.
    static var colorPickerBarColors: [Color] {
        [
            .black, .gray, .white,
            .red, .pink, .orange, .yellow,
            .indigo, .purple, .blue, .cyan, .teal, .mint,
            .green, .brown
        ]
    }

    static func colorPickerBarColors(withClearColor: Bool) -> [Color] {
        let standard = colorPickerBarColors
        guard withClearColor else { return standard }
        return [.clear] + standard
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct ColorPickerBar_Previews: PreviewProvider {

    struct Preview: View {

        @State
        private var color1: Color = .red

        @State
        private var color2: Color = .yellow

        @State
        private var color3: Color = .purple

        @State
        private var optionalColor: Color? = nil

        @State
        var optionalDouble: Double? = nil

        var pickers: some View {
            VStack(alignment: .leading, spacing: 0) {
                ColorPickerBar(
                    value: $color1,
                    colors: [.red, .green, .blue]
                )
                ColorPickerBar(
                    value: $color2
                )
                ColorPickerBar(
                    value: $color3,
                    colors: .colorPickerBarColors(withClearColor: true)
                )
                ColorPickerBar(
                    value: $optionalColor,
                    colors: .colorPickerBarColors(withClearColor: true),
                    config: .init(
                        addOpacityToPicker: false,
                        addResetButton: true,
                        resetButtonValue: nil
                    )
                )
            }
            .padding()
        }

        var body: some View {
            VStack {
                Text("\(optionalDouble ?? -1)")
                Slider(value: $optionalDouble ?? 0.0, in: 0.0...1.0)
                pickers
                pickers
                .background(Color.black)
                .colorScheme(.dark)
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}
#endif
