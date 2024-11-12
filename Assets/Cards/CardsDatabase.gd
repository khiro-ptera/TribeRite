# Monster Info: [Type, Name, Element, ATK, HP, Sacrifice, Starter, Effect]
# Spell Info: [Type, Name, Effect]
# Counter Info: [Type, Name, Cost, Effect]
# Arena Info: [Type, Name, Effect]

enum {Emberspright, Polarius, Enrage, Fling, Flowerbeds, NoxatuRitual, PotOfReeds, Goopa}

const DATA = {
	Emberspright:
		["Monsters", "Emberspright", "Fire", 100, 100, 0, true, "On Kill: Double ATK and HP."],
	Goopa:
		["Monsters", "Goopa", "Earth", 20, 120, 0, true, "Birthrite and Deathrite: Restore 25 HP to all allies."],
	Polarius:
		["Monsters", "Polarius", "Electric", 40, 200, 0, true, "Gains 10 ATK for every other allied monster."],
	Enrage:
		["Spells", "Enrage", "Give your active monster 30 ATK this turn."],
	NoxatuRitual:
		["Spells", "Noxatu Ritual", "Discard your last allied monster. \nGain 2 draw."],
	Fling:
		["Counters", "Fling", 3, "Swap your opponent's first and second monster."],
	PotOfReeds:
		["Counters", "Pot of Reeds", 2, "Gain 2 draw."],
	Flowerbeds:
		["Arenas", "Flowerbeds", "Start of Turn: All allied monsters recover 15 HP."],
}
