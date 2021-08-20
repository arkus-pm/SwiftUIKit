//
//  MultiPicker.swift
//  SwiftUIKit
//
//  Created by Daniel Saidi on 2021-08-20.
//  Copyright © 2021 Daniel Saidi. All rights reserved.
//

import SwiftUI

/**
 This picker view lists a collection of items in a `MenuList`
 and binds the selection to an external value.
 
 The picker accepts any `Equatable & Identifiable` item type
 and uses the provided `listItem` builder to build list item
 views for each item in the provided `items` collection.
 */
public struct MultiPicker<Item: Equatable & Identifiable, ItemView: View>: View, DismissableView {
    
    public init(
        title: String,
        items: [Item],
        selection: Binding<[Item]>,
        listItem: @escaping ItemViewBuilder) {
        self.title = title
        self.items = items
        self.selection = selection
        self.listItem = listItem
    }
    
    private let title: String
    private let items: [Item]
    private let selection: Binding<[Item]>
    private let listItem: ItemViewBuilder
    
    public typealias ItemViewBuilder = (_ item: Item, _ isSelected: Bool) -> ItemView
    
    @Environment(\.presentationMode) public var presentationMode
    
    public var body: some View {
        MenuList(title) {
            ForEach(items) {
                listItemView(for: $0)
            }
        }.withTitle(title)
    }
}

private extension View {
    
    @ViewBuilder
    func withTitle(_ title: String) -> some View {
        #if os(iOS) || os(tvOS) || os(watchOS)
        self.navigationBarTitle(title)
        #else
        self
        #endif
    }
}

private extension MultiPicker {
    
    func listItemView(for item: Item) -> some View {
        Button(action: { toggleSelection(for: item) }) {
            listItem(item, isSelected(item))
        }
    }
}

private extension MultiPicker {
    
    func isSelected(_ item: Item) -> Bool {
        selection.wrappedValue.contains(item)
    }
    
    func toggleSelection(for item: Item) {
        if isSelected(item) {
            selection.wrappedValue = selection.wrappedValue.filter { $0 != item }
        } else {
            selection.wrappedValue.append(item)
        }
    }
}

struct MultiPicker_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State private var selection = [PreviewItem.all[0]]
        
        var body: some View {
            NavigationView {
                MultiPicker(
                    title: "Pick something",
                    items: PreviewItem.all,
                    selection: $selection) { item, isSelected in
                        PreviewPickerItem(item: item, isSelected: isSelected)
                    }
            }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}

private struct PreviewItem: Identifiable, Equatable {
    
    let name: String
    
    var id: String { name }
    
    static let all = [
        PreviewItem(name: "Item #1"),
        PreviewItem(name: "Item #2"),
        PreviewItem(name: "Item #3"),
        PreviewItem(name: "Item #4"),
        PreviewItem(name: "Item #5")
    ]
}

private struct PreviewPickerItem: View, PickerListItem {
    
    let item: PreviewItem
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            checkmark
        }
    }
}
