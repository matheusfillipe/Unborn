extends Object

# TODO have these in a global class
enum COLOR {
	WHITE
	BLACK
	BLUE
	GREEN
	YELLOW
	RED
	}

enum Scenery {
	safezone,
	hell,
	heaven
}

# Number: message
var spirit_messages = {
	3: "Some parts of the world will stop having spirits after a while",
	6: "Sometimes it takes more than one attempt to get one spirit",
	10: "Please take me out of here",
	15: "You need to collect a certain number of spirits from heaven and hell to reincarnate",
	25: "We are what we eat even after we die. Take care with red spirits lowering you health",
	30: "We are what we eat even after we die. Take care with red spirits lowering you health",
	35: "Green spirits are life",
	40: "Don't stop collecting spirits even if you think you reached the goal",
	50: "Use big spirits as a shield from enemies"
}

var random_messages = [
	"I've been here... forever",
	"Thanks for taking me in",
	]

# scenery: {color: count}
var goal = {
	Scenery.hell: {
		COLOR.WHITE: 20,
		COLOR.YELLOW: 10,
		COLOR.RED: 5,
		COLOR.GREEN: 1,
	},
	Scenery.heaven: {
		COLOR.WHITE: 20,
		COLOR.YELLOW: 10,
		COLOR.RED: 5,
		COLOR.GREEN: 1,
	},
}

func next_message() -> int:
	for n in spirit_messages:
		return n
	return -1


func pop_message(n: int) -> String:
	var msg = spirit_messages[n]
	spirit_messages.erase(n)
	return msg
