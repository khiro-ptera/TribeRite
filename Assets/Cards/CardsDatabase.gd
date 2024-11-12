# Monster Info: [Type, Name, Element, ATK, HP, Sacrifice, Starter, Effect]
# Spell Info: [Type, Name, Effect]
# Counter Info: [Type, Name, Cost, Effect]
# Arena Info: [Type, Name, Effect]

enum {Emberspright, Polarius, Enrage, Fling, Flowerbeds}

const DATA = {
	Emberspright:
		["Monsters", "Emberspright", "Fire", 100, 100, 0, true, "On Kill: Double ATK and HP."],
	Polarius:
		["Monsters", "Polarius", "Electric", 40, 200, 0, true, "Gains 10 ATK for every other allied monster."],
	Enrage:
		["Spells", "Enrage", "Give a monster 30 ATK this turn."],
	Fling:
		["Counters", "Fling", 3, "Swap your opponent's first and second monster."],
	Flowerbeds:
		["Arenas", "Flowerbeds", "Start of Turn: All allied monsters recover 15 HP."]
}
