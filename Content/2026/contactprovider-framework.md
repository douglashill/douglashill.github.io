date: 2026-04-14T08:18:30+0100
%%%

TIL about the [ContactProvider](https://developer.apple.com/documentation/contactprovider) framework on iOS (not Mac). Sounds like a way to build an end-to-end encrypted replacement for iCloud/CardDAV contacts sync if you can get your head around the difference between `ContactItemEnumerating` and `ContactItemEnumerator`.

![protocol ContactItemEnumerating: A protocol to provide enumerators for collections of contact items. protocol ContactItemEnumerator: A protocol to provide enumerations of all contact items and changed contact items.](screenshot.png)
