//
//  ThemeEditor.swift
//  Memorize
//
//  Created by Він on 02.07.2022.
//

import SwiftUI

struct ThemeEditor: View {
    @Binding var theme: MemoryTheme
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                nameSection
                editEmojiSection
                removedEmojisSection
                addEmojisSection
                pairsStepperSection
                colorPickerSection
            }
            .onAppear {
                MemoryTheme.RGBAColor.colorPalette.forEach { RGBA in
                    themeColorsPalette.append(Color(rgbaColor: RGBA))
                }
            }
            .navigationTitle("Edit \(theme.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    var nameSection: some View {
        Section(header: Text("Theme Name")
            .font(.headline)
            .fontWeight(.bold)
        ) {
            TextField("Name", text: $theme.name)
        }
    }
    
    @State private var unavailableNumberOfEmojiSection: Bool = false
    
    var editEmojiSection: some View {
        Section(header: Text("Emojis")
            .font(.headline)
            .fontWeight(.bold)
        ) {
            let emojis = theme.emojis.map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(
                minimum: ThemeEditorConstant.gridItemAdaptiveToMinimum))])
            {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .alert(isPresented: $unavailableNumberOfEmojiSection) {
                            Alert(
                                title: Text("Current number of Emoji Not Available"),
                                message: Text("Your number of Emoji cannot be less " +
                                              "than two to create a game.")
                            )
                        }
                        .onTapGesture {
                            withAnimation {
                                if theme.emojis.count == 2 {
                                    unavailableNumberOfEmojiSection = true
                                } else {
                                    theme.emojis.removeAll(where: { String($0) == emoji })
                                }
                                if theme.emojis.count < theme.numberOfPairs {
                                    theme.numberOfPairs -= 1
                                }
                            }
                        }
                }
            }
            .font(.system(size: ThemeEditorConstant.size))
        }
    }
    
    var removedEmojisSection: some View {
        Section(header: Text("Removed Emojis")
            .font(.headline)
            .fontWeight(.bold)
        ) {
            let removedEmojis = theme.removedEmojis.map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(
                minimum: ThemeEditorConstant.gridItemAdaptiveToMinimum))])
            {
                ForEach(removedEmojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                theme.emojis = emoji + theme.emojis
                            }
                        }
                }
            }
            .font(.system(size: ThemeEditorConstant.size))
        }
    }
    
    @State private var emojisToAdd = ""
    
    var addEmojisSection: some View {
        Section(header: Text("Add Emoji")
            .font(.headline)
            .fontWeight(.bold)
        ) {
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd) { emoji in
                    addEmoji(emoji)
                }
        }
    }
    
    func addEmoji(_ emojis: String) {
        withAnimation {
            theme.emojis = (emojis + theme.emojis)
                .filter {$0.isEmoji}
                .removingDuplicateCharacters
        }
    }
    
    var pairsStepperSection: some View {
        Section(header: Text("Card Count")
            .font(.headline)
            .fontWeight(.bold)
        ) {
            Stepper(
                String("\(theme.numberOfPairs) Pairs"),
                value: $theme.numberOfPairs,
                in: 2...theme.emojis.count,
                step: 1
            )
        }
        
    }
    
    var colorPickerSection: some View {
        Section(header: Text("Color")
            .font(.headline)
            .fontWeight(.bold)
        ) {
            let bindingColor = Binding<Color>(
                get: { Color(rgbaColor: theme.color) },
                set: { color in
                    theme.color = MemoryTheme.RGBAColor(color: color)
                }
            )
            VStack() {
                LazyVGrid(columns: [GridItem(.adaptive(
                    minimum: ThemeEditorConstant.gridItemAdaptiveToMinimum))])
                {
                    ForEach(themeColorsPalette, id: \.self) { color in
                        themeColorExample(color: color)
                            .onTapGesture {
                                withAnimation {
                                    theme.color = MemoryTheme.RGBAColor(color: color)
                                }
                            }
                    }
                    .aspectRatio(ThemeEditorConstant.aspectRatio, contentMode: .fill)
                }
                ColorPicker("Color Picker:", selection: bindingColor)
            }
            .padding(.vertical)
        }
    }
    
    @State var themeColorsPalette: [Color] = []
    
    private func themeColorExample(color: Color) -> some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: ThemeEditorConstant.cornerRadius)
                .foregroundColor(color)
            if Color(rgbaColor: theme.color) == color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.blue)
            }
        }
    }
    
    struct ThemeEditorConstant {
        static let gridItemAdaptiveToMinimum: CGFloat = 40
        static let aspectRatio: CGFloat = 2/3
        static let cornerRadius: CGFloat = 10
        static let size: CGFloat = 40
    }
}

struct ThemeEditor_Previews: PreviewProvider {
    static var previews: some View {
        ThemeEditor(theme: .constant(ThemeStore(named: "Def").choose(at: 1)))
    }
}
