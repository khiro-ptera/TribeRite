# TribeRite: A WIP Card Battler RPG to improve my Godot and create something cool in the meanwhile

## Mechanics:

### Card Types
```
There are 4 types of cards: Monsters, Spells, Counters, and Arenas
```

### Monsters
```
Players have a Stack of Monsters
The first Monster in the Stack is the Active Monster
The other Monsters are referred to as Stack Monsters
Their position in the Stack is initially determined by the order in which they are played
Monsters with no Sacrifice can be played with no cost (except from their effect) during the Play Phase
To play a Monster with Sacrifice, a player must Sacrifice Monsters in the Stack equal to the Sacrifice cost
Sacrificed Monsters are sent to the Dzone
If a Monster's HP is reduced to 0 or less, it is Discarded
```

### Spells
```
Spells can be played with no cost (except from their effect) during the Play Phase
Spells are Discarded when played
```

### Counters
```
Counters cost Intel to play
Counters can only be played during the opponent's Counter Phase
Counters are Discarded when played
```

### Arenas
```
Arenas can be played with no cost (except from their effect) during the Play Phase
Arenas stay on the field left of the player's Stack when played
When the controller of an Arena plays another Arena, the current Arena is Discarded
```

### Resources
```
There are two innate resources: Draws and Intel
On the first turn, players start with 4 Draws and 0 Intel
Draws can be consumed to draw cards
Intel can be used to play Counter cards
The initial max hand size is 5 cards
Cards drawn past the max hand size are Discarded 
```

### DZone
```
When a card is Discarded, it is sent to the DZone
A card sent to the DZone overrides previous cards sent to the DZone
```

### Effect Keywords
```
Birthrite (Monster/Arena): Triggers when the card is played to the Stack
Deathrite (Monster/Arena): Triggers when the card is sent from the Stack to the DZone
Haunt (Any): An Aura effect that is in play when the card is in the DZone
Start of Turn (Any): Triggers during the Start Phase
End of Turn (Any): Triggers during the End Phase
On Kill (Any): Triggers when a card deals damage that reduces an opposing Monster's HP to 0 or less
```

### Phases and Turns
```
There are 4 phases to each player turn: Start Phase, Play Phase, Fight Phase, and End Phase
During the Start Phase, the turn player gets 1 Draw and 1 Intel (including the first turn), and Start of Turn effects trigger
During the Play Phase, the turn player can play Monsters, Spells, and Arenas, as well as consume Draws to draw cards
During the Counter Phase, the turn player's opponent can spend their Intel to active Counter cards
During the Fight Phase, the turn player's Active Monster (AM) attacks the opponent's Active Monster
Damage is dealt to the opponent's AM's HP equal to the player's AM's ATK, before effects
During the End Phase, End of Turn effects trigger
After the End Phase, the other player's turn begins from their Start Phase
```
