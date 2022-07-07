//
//  ThemeChooser.swift
//  Memorize
//
//  Created by Він on 29.06.2022.
//

import SwiftUI

struct ThemeChooser: View {
    @EnvironmentObject var store: ThemeStore
    
    @State var games: [Int: EmojiMemoryGame] = [:]
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.themes) { theme in
                    createThemeGame(for: theme)
                        .gesture(editMode == .active ? editTheme(theme) : nil)
                        
                }
                .onDelete { indexSet in
                    store.themes.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, newOffset in
                    store.themes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle(("Memorize"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    addNewThemeButton
                }
                ToolbarItem { EditButton() }
            }
            .environment(\.editMode, $editMode)
        }
        .onChange(of: store.themes) { themes in
            themes.forEach { theme in
                games[theme.id]?.theme = theme
            }
        }
        .onAppear {
            store.themes.forEach { games[$0.id] = EmojiMemoryGame($0) }
        }
        .sheet(item: $themeToEdit) { theme in
            ThemeEditor(theme: $store.themes[theme])
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    var addNewThemeButton: some View {
        Button {
            editMode = .active
            store.insertTheme()
            if let newTheme = store.themes.first {
                games[newTheme.id] = EmojiMemoryGame(newTheme)
                themeToEdit = newTheme
                
            }
        } label: {
            Image(systemName: "plus")
        }
    }
    
    @ViewBuilder
    private func createThemeGame(for theme: MemoryTheme) -> some View {
        if let game = games[theme.id] {
            NavigationLink(destination: EmojiMemoryGameView()
                    .environmentObject(game)
            ) {
                VStack(alignment: .leading) {
                    Text(theme.name)
                        .foregroundColor(Color(rgbaColor: theme.color))
                        .font(.largeTitle)
                    if theme.numberOfPairs == theme.emojis.count {
                        Text("All of " + theme.emojis)
                            .lineLimit(1)
                    } else {
                        Text("\(theme.numberOfPairs) pairs from " + theme.emojis)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
    
    private func editTheme(_ theme: MemoryTheme) -> some Gesture {
            TapGesture()
                .onEnded {
                    themeToEdit = theme
                }
    }
    
    @State var themeToEdit: MemoryTheme?
}



struct ThemeChooser_Previews: PreviewProvider {
    static var previews: some View {
        let store = ThemeStore(named: "def")
        ThemeChooser()
            .environmentObject(store)
    }
}
