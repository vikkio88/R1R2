extends Node2D
var is_linux = false
var is_game_started = false

const buttonsClickedDefault = {
	Y = false,
	X = false,
	A = false,
	B = false,
	RB = false,
	RT = false,
	LB = false,
	LT = false
}

onready var SpriteNodes = {
	Y = $InputView/Active/Y,
	X = $InputView/Active/X,
	A = $InputView/Active/A,
	B = $InputView/Active/B,
	RB = $InputView/Active/RB,
	RT = $InputView/Active/RT,
	LB = $InputView/Active/LB,
	LT = $InputView/Active/LT
}

onready var GameSpriteNodes = {
	Y = $GameView/Y,
	X = $GameView/X,
	A = $GameView/A,
	B = $GameView/B,
	RB = $GameView/RB,
	RT = $GameView/RT,
	LB = $GameView/LB,
	LT = $GameView/LT
}

func _init():
	is_linux = not ("Window" in OS.get_name())

#func _input(event):
#	if event is InputEventJoypadMotion:
#		print_debug(event.as_text())


var buttonClicked = buttonsClickedDefault

func _process(delta):
	if Input.is_action_just_released("Y") or Input.is_action_pressed("Y"):
		buttonClicked.Y = true;
		print_debug("y")
	if Input.is_action_just_released("X") or Input.is_action_pressed("X"):
		buttonClicked.X = true;
		print_debug("x")
	if Input.is_action_just_released("A") or Input.is_action_pressed("A"):
		buttonClicked.A = true;
		print_debug("a")
	if Input.is_action_just_released("B") or Input.is_action_pressed("B"):
		buttonClicked.B = true;
		print_debug("b")
	if Input.is_action_just_released("RB") or Input.is_action_pressed("RB"):
		buttonClicked.RB = true;
		print_debug("rb")
	if Input.is_action_just_released("LB") or Input.is_action_pressed("LB"):
		buttonClicked.LB = true;
		print_debug("lb")
	if  Input.is_action_pressed("RTlinux" if is_linux else "RT"):
		buttonClicked.RT = true
		print_debug("rt")
			
	if Input.is_action_pressed("LTlinux" if is_linux else "LT"):
		buttonClicked.LT = true
		print_debug("lt")
	
	for key in buttonClicked:
		if key in SpriteNodes:
			SpriteNodes[key].visible = buttonClicked[key]
	
	buttonClicked = buttonsClickedDefault.duplicate()
	
	
func is_default(buttonClicked:Dictionary) -> bool:
	for key in buttonClicked:
		if buttonClicked[key]: 
			return false
	return true
