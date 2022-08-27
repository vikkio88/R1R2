extends Node2D
var is_linux = false
var is_game_started = false
var currently_shown = null

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


onready var Cam = $Cam;
onready var noise = OpenSimplexNoise.new()
var noise_y = 0
var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].
export var decay = 0.8  # How quickly the shaking stops [0, 1].
export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
export var max_roll = 0.1  # Maximum rotation in radians (use sparingly)


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
var buttonClicked = buttonsClickedDefault

func _init():
	is_linux = not ("Window" in OS.get_name())

func get_random_game_sprite_node_key():
   var keys = GameSpriteNodes.keys()
   return keys[randi() % keys.size()]

func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

#func _input(event):
#	if event is InputEventJoypadMotion:
#		print_debug(event.as_text())
#	if event is InputEventJoypadButton:
#		print_debug((event.as_text()))

func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	Cam.rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	Cam.offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	Cam.offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)

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
	
	
	if Input.is_action_just_released("startlinux" if is_linux else "start") and not is_game_started:
		print_debug("start")
		is_game_started = true
		$GameTimer.start()
	
	var clicked = check_button_click()
	var was_a_button_clicked = clicked.size() > 0
	if was_a_button_clicked:
		trauma = .15
	
	check_clicked_correctness(clicked)

	if Input.is_action_just_released("ui_accept"):
		trauma = .5
	
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	
	buttonClicked = buttonsClickedDefault.duplicate()
	
	
func check_button_click():
	var clicked = []
	for key in buttonClicked:
		if key in SpriteNodes:
			if buttonClicked[key]:
				clicked.push_back(key)
			SpriteNodes[key].visible = buttonClicked[key]
	return clicked

func check_clicked_correctness(clicked):
	if clicked.size() < 1:
		return
	
	if currently_shown in clicked:
		print_debug("you clicked the currently shown")
		if clicked.size() > 1:
			print_debug("but you clicked also others", currently_shown, clicked)
	else:
		print_debug("you clicked the wrong button", currently_shown, clicked)


func _on_GameTimer_timeout():
	print_debug("tick")
	if is_game_started:
		for key in GameSpriteNodes:
			GameSpriteNodes[key].visible = false
		var key = get_random_game_sprite_node_key()
		var node_to_show = GameSpriteNodes[key]
		node_to_show.visible = true
		currently_shown = key
		
