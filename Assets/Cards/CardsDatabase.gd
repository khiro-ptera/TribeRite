# Monster Info: [Type, Name, Element, ATK, HP, Sacrifice, Starter, Effect]
# Spell Info: [Type, Name, Effect]
# Counter Info: [Type, Name, Cost, Effect]
# Arena Info: [Type, Name, Effect]

enum {
	Emberspright, 
	Polarius, 
	Goopa, 
	Opturtle,
	Veilex,
	Graspweed,
	BrightmaneMartyr,
	
	Enrage, 
	NoxatuRitual, 
	BleakfountainPact, 
	
	PotOfReeds, 
	Fling, 
	
	Flowerbeds, 
	HellfireCanyon,
	School,
	}

const DATA = {
	Emberspright:
		["Monsters", "Emberspright", "Fire", 100, 80, 0, true, "On Kill: Double ATK and HP."],
	Opturtle:
		["Monsters", "Opturtle", "Water", 30, 240, 1, false, "Deathrite: Gain 1 Draw."],
	Veilex:
		["Monsters", "Veilex", "Electric", 75, 250, 2, false, "Birthrite: Gain 1 Intel for each allied monster."],
	Goopa:
		["Monsters", "Goopa", "Earth", 20, 120, 0, true, "Birthrite and Deathrite: All other allied monsters gain 20 HP."],
	Polarius:
		["Monsters", "Polarius", "Electric", 40, 200, 0, true, "Gains 10 ATK for every other allied monster."],
	Graspweed:
		["Monsters", "Graspweed", "Earth", 40, 90, 0, true, "Haunt: Your opponent's active monster loses 25 ATK."],
	BrightmaneMartyr:
		["Monsters", "Brightmane Martyr", "Steel", 70, 180, 1, false, "Deathrite: Gain 1 Intel. Haunt: Your allied Steel monsters gain 40 ATK."],
	Enrage:
		["Spells", "Enrage", "Your active monster gains 25 ATK."],
	NoxatuRitual:
		["Spells", "Noxatu Ritual", "Discard your last allied monster. \nGain 2 Draw."],
	BleakfountainPact:
		["Spells", "Bleakfountain Pact", "Lose all your Draw. \nYour active monster gains 30 ATK and HP for each Draw lost."],
	Fling:
		["Counters", "Fling", 3, "Swap your opponent's first and second monster."],
	PotOfReeds:
		["Counters", "Pot of Reeds", 2, "Gain 2 draw."],
	Flowerbeds:
		["Arenas", "Flowerbeds", "Your allied monsters gain 30 HP."],
	HellfireCanyon:
		["Arenas", "Hellfire Canyon", "Your allied monsters gain 20 ATK."],
	School:
		["Arenas", "School", "Deathrite: Gain 1 Intel and 1 Draw."],
}
