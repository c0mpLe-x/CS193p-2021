 # 📱Animated Set Card Game in SwiftUI:

![SetCard Game ](Animated SetGame.gif)

## 🗂Required Tasks:

✅ Your assignment this week must still play a solo game of Set. <br />
✅ In this version, though, when there is a match showing and the user chooses another card, do not replace the matched cards; instead, discard them (leaving fewer cards in the game). <br />
✅ Add a “deck” and a “discard pile” to your UI. They can be any size you want and you can put them anywhere you want on screen, but they should not be part of your main grid of cards and they should each look like a stack of cards (for example, they should have the same aspect ratio as the cards that are in play). <br />
✅ The deck should contain all the not-yet-dealt cards in the game. They should be “face down” (i.e. you should not be able to see the symbols on them). <br />
✅ The discard pile should contain all the cards that have been discarded from the game (i.e. the cards that were discarded because they matched). These cards should be face up (i.e. you should be able to see the symbols on the last discarded card). Obviously the discard pile is empty when your game starts. <br />
✅ Any time matched cards are discarded, they should be animated to “fly” to the discard pile. <br />
✅ You don’t need your “Deal 3 More Cards” button any more. Instead, tapping on the deck should deal 3 more cards. <br />
✅ Whenever more cards are dealt into the game for any reason (including to start the game), their appearance should be animated by “flying them” from the deck into place. <br />
✅ Note that dealing 3 more cards when a match is showing on the board still should replace those cards and that those matched cards would be flying to the discard pile at the same time as the 3 new cards are flying from the deck (see Extra Credit too). <br />
✅ All the card repositioning and resizing that was required by Required Task 2 in last week’s assignment must now be animated. If your cards from last week never changed their size or position as cards were dealt or discarded, then fix that this week so that they do. <br />
✅ When a match occurs, use some animation (your choice) to draw attention to the match. <br />
✅ When a mismatch occurs, use some animation (your choice) to draw attention to the mismatch. This animation must be very noticeably different from the animation used to show a match (obviously). <br />

## 📎Extra Credit:

✅1. Have your deck and/or discard pile be either “sloppy” (i.e. not a perfectly neat stack) or show the first few cards slightly offset (so that it looks more like a stack). <br />
✅2. When you deal 3 more cards and there is a match showing, start animating the matched cards flying to the discard pile before the animation of the 3 new cards flying in from the deck starts. In other words, give the user a better impression of “I just replaced these 3 cards for you” by delaying the dealing animation a short bit in this scenario. The animations can still overlap, but delaying the dealing one just a little bit can result in a pleasing effect. <br />
✅3. Make the cards that you deal out flip from face down (as they are in the deck) to face up (as they are once they are in play). You can use/modify the .cardify ViewModifier from lecture if you want. <br />
✅4. Add any other animation you can think of that would make sense. <br />
