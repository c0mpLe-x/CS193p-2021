//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 4/26/21.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            trash
                .zIndex(1.0)
            documentBody
            palette
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0,0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size).exclusively(before: singleTapToUnselect()))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .border(Color.red, width: isChosen(emoji) ? 1 : 0)
                            .animatableSystemFontModifier(fontSize: fontSize(for: emoji))
                            .position(position(for: emoji, in: geometry))
                            .gesture(singleTapToSelect(emoji)
                                .simultaneously(
                                    with: !selectedEmojis.isEmpty ?
                                    emojiPanOffsetGesture(emoji) :
                                    nil
                                ))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText,.url,.image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(zoomGesture()
                .simultaneously(
                    with: selectedEmojis.isEmpty ?
                    panGesture() :
                    nil
                ))
        }
    }
    
    // MARK: - Drag and Drop
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: defaultEmojiFontSize / zoomScale
                    )
                }
            }
        }
        return found
    }
    
    // MARK: - Positioning/Sizing Emoji
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        gestureEmojiPan.isMovableEmoji(emoji) ?
        convertFromEmojiCoordinates((emoji.x + Int(gestureEmojiPan.offset.width), emoji.y + Int(gestureEmojiPan.offset.height)), in: geometry) :
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size) * zoomScale
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    // MARK: - Emoji Selection
    
    @State private var selectedEmojis = Set<EmojiArtModel.Emoji>()
    
    private func singleTapToUnselect() -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                withAnimation {
                    selectedEmojis.removeAll()
                }
            }
    }
    
    private func singleTapToSelect(_ emoji: EmojiArtModel.Emoji) -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                withAnimation {
                    chooseEmoji(emoji)
                }
            }
    }
    
    private func chooseEmoji(_ emoji: EmojiArtModel.Emoji) {
        selectedEmojis.toggleMembership(of: emoji)
    }
    
    private func isChosen(_ emoji: EmojiArtModel.Emoji) -> Bool {
        if selectedEmojis.index(matching: emoji) != nil {
            return true
        }
        return false
    }
    
    // MARK: - Zooming
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * (selectedEmojis.isEmpty ? gestureZoomScale : 1)
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                if !selectedEmojis.isEmpty {
                    let scaleUpdate = latestGestureScale / gestureZoomScale
                    selectedEmojis.forEach({ document.scaleEmoji($0, by: scaleUpdate) })
                }
                gestureZoomScale = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                if selectedEmojis.isEmpty {
                    steadyStateZoomScale *= gestureScaleAtEnd
                }
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0  {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    // MARK: - Emoji Panning
    
    @GestureState private var gestureEmojiPan = EmojiPann()
    
    private func moveEmoji(emoji: EmojiArtModel.Emoji, by size: CGSize) {
        if !selectedEmojis.isEmpty, !isChosen(emoji) {
            document.moveEmoji(emoji, by: size)
        } else {
            selectedEmojis.forEach { document.moveEmoji($0, by: size) }
        }
    }
    
    private func emojiPanOffsetGesture(_ emoji: EmojiArtModel.Emoji) -> some Gesture {
           DragGesture()
            .updating($gestureEmojiPan) { latestMoveValue, gestureMove, _ in
                isChosen(emoji) ?
                selectedEmojis.forEach { gestureMove.moveEmoji($0, by: latestMoveValue.distance / zoomScale) } :
                gestureMove.moveEmoji(emoji, by: latestMoveValue.distance / zoomScale)
            }
            .onEnded { finalDragGestureValue in
               moveEmoji(emoji: emoji, by: finalDragGestureValue.translation / zoomScale)
            }
    }
    
    private struct EmojiPann {
           var panningEmojiIndex = [Int]()
           var offset = CGSize.zero
           
           mutating func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
               panningEmojiIndex.append(emoji.id)
               self.offset = offset
           }
           
           func isMovableEmoji(_ emoji: EmojiArtModel.Emoji) -> Bool {
               panningEmojiIndex.contains(emoji.id)
           }
       }
    
    // MARK: - Panning
    
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    // MARK: - Trash
    
    var trash: some View {
        Button {
            withAnimation {
                selectedEmojis.forEach { document.deleteEmoji($0) }
            }
        } label: {
            Label("Delete Emoji", systemImage: "trash")
        }
    }

    // MARK: - Palette
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
    let testEmojis = "😀😷🦠💉👻👀🐶🌲🌎🌞🔥🍎⚽️🚗🚓🚲🛩🚁🚀🛸🏠⌚️🎁🗝🔐❤️⛔️❌❓✅⚠️🎶➕➖🏳️"
}

struct ScrollingEmojisView: View {
    let emojis: String

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
