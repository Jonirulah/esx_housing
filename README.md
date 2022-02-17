# esx_housing

Made it for ESX Legacy
This script hasn't been tested on previous versions of ESX, so compatibility is not assured.

[FEATURES]
- Players are able to disconnect in their house, at entering the server the house where he stayed in will load automatically.
- Highly optimized (0.01ms) (client), in server-side the database is loaded on startup, so the script uses the cached JSON for all internal queries.
- House sync interval, all houses are synced within the clients in real time, for the database, houses are being syncronized with Config.SyncInterval, by default every 1 minute, all the houses that has been changed, (keys, inventory, etc) are updated on the database instead of updating them for every single change.
- Almost everything configurable (prices, interiors, coords, keys).
- Players can give keys to other players allowing them to access his house in case he's not online, invites are working as well, also owners have the option to reset the keys or sell the house in their [F5 Menu].
- Adminstration has a house creating menu.
- Houses can get removed automatically when they are unused for more time than allowed on the config.


- No logging is provided, you should add yours wherever you want to get things logged.

# Personal Note
Remember that community improvements/PR are what make projects better, if you wanna add something new into esx_housing you are free to do so by forking the project or making a new branch with your fork.

Due to the fact that I don't own any FiveM server and I don't have the intention to add features to the project (wardrobes, shells, etc) I don't intend to update the script. As I always said forking esx_housing and adding features to it is something that I approve and you are free to do so.

esx_housing was made with the intention of having a good/simple house system (non-bloated) where developers are able to add the features they want with this "base" that I made with the intention of being as lightweight as possible, since most of FiveM housing systems are made from scratch (private) and almost all of those are paid scripts so having a good/simple house system free and able to be extended/continued is something that I always wanted FiveM to have and I think esx_housing matches this purpose.
