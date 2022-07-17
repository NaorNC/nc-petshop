# #Image

![Screenshot_1](https://user-images.githubusercontent.com/81817039/171646793-4bcccde5-4633-4461-90e4-7732e406bb13.png)

# Briefly about the system

The system comes with basic and interesting options. Other than that, there is an option of K9 (/petattack & /petsearch) that basically your dog can attack and search for the suspect if he has drugs on him (of course you will define the items in shared.lua).
More advanced updates will be released to the petshop system in the future.

* If you have any question, discord - https://discord.gg/cKt4Mpd2PQ

# Installation

* Download the script and put it in the [resource] folder.
* Download qb-target & qb-input & qb-menu (if you don't have) and put it in the [resource] or [standalone] folder. (it doesn't really matter)
Add the following code to your server.cfg/resouces.cfg
```
ensure qb-target
ensure qb-menu
ensure qb-input
ensure nc-petshop
```

# Dependencies
* [qb-target](https://github.com/qbcore-framework/qb-target)
* [qb-input](https://github.com/qbcore-framework/qb-input)
* [qb-menu](https://github.com/qbcore-framework/qb-menu)

# SQL (important!)

```lua
CREATE TABLE IF NOT EXISTS `pets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(60) DEFAULT NULL,
  `modelname` varchar(250) DEFAULT NULL,
  `health` tinyint(4) NOT NULL DEFAULT 100,
  `illnesses` varchar(60) NOT NULL DEFAULT 'none',
  `name` varchar(255) DEFAULT 'Pet',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=218 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
```
# Put this lines on in your core -> shared -> items.lua

```lua
["petfood"] 						= {["name"] = "petfood",					["label"] = "Pet Food",				["weight"] = 500,		["type"] = "item",		["image"] = "petfood.png",		["unique"] = false, 	["useable"] = false,	["shouldClose"] = false,	["combinable"] = nil,	["description"] = "Food" },
["tennisball"] 						= {["name"] = "tennisball",					["label"] = "Tennis Ball",				["weight"] = 500,		["type"] = "item",		["image"] = "tennisball.png",		["unique"] = false, 	["useable"] = true,	["shouldClose"] = false,	["combinable"] = nil,	["description"] = "Food" },
```

# Inventory image
![tennisball](https://i.ibb.co/FX1bcYv/tennisball.png)
![petfood](https://i.ibb.co/tm2tSwR/petfood.png)

- Add the petfood.png & tennisball.png to your inventory -> html -> images

# Map
To get the map that appears in the photo (of the store):
https://github.com/BaziForYou/petshop_map-fivem
