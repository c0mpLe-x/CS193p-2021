 # 📱EmojiArt in SwiftUI:

![Animated EmojiArt.gif](EmojiArt.gif)

## 🗂Required Tasks:

✅ Download the version of EmojiArt from Lecture 10. Do not break anything that is working there as part of your solution to this assignment. <br />
✅ Support the selection of one or more of the emojis which have been dragged into your EmojiArt document (i.e. you’re selecting the emojis in the document, not the ones in the palette at the bottom). You can show which emojis are selected in any way you’d like. The selection is not persistent (in other words, restarting your app will not preserve the selection). <br />
✅ Tapping on an unselected emoji should select it. <br />
✅ Tapping on a selected emoji should unselect it. <br />
✅ Single-tapping on the background of your EmojiArt (i.e. single-tapping anywhere except on an emoji) should deselect all emoji. <br />
✅ Dragging a selected emoji should move the entire selection to follow the user’s finger. <br />
✅ If the user makes a dragging gesture when there is no selection, pan the entire document (i.e., as EmojiArt does in L10). <br />
✅ If the user makes a pinching gesture anywhere in the EmojiArt document and there is a selection, all of the emojis in the selection should be scaled by the amount of the pinch. <br />
✅ If there is no selection at the time of a pinch, the entire document should be scaled. <br />
✅ Make it possible to delete emojis from the EmojiArt document. This Required Task is intentionally not saying what user-interface actions should cause this. Be creative and try to find a way to delete the emojis that feels comfortable and intuitive. <br />

## 📎Extra Credit:

✅1. Allow dragging unselected emoji separately. In other words, if the user drags an emoji that is part of the selection, move the entire selection (as required above). But if the user drags an emoji that is not part of the selection, then move only that emoji (and do not add it to the selection). You will find that this is a much more comfortable interface for placing emojis. Doing this will very likely require you to have a more sophisticated @GestureState for your drag gesture. <br />
✅2. Zooming in to high zoomScales starts to make the emoji look a bit “grainy”. This is because we are using scaleEffect to scale the Text up. These emoji would look quite a bit sharper if we scaled the font size itself. In other words, a font of size 100 is going to look sharper than a font of size 20 with a scaleEffect of 5. But as we learned back in Memorize, trying to zoom a font by just changing its size results in poor animation because the .font modifier is not animatable. See if you can figure out how to make an AnimatableSystemFontModifier that will animate the size of a system font and use that instead of the combination of .font and .scaleEffect we are using now. This ViewModifier can be written in 6 lines of code (not saying you have to do it that efficiently, but just so you know what’s possible). <br />
