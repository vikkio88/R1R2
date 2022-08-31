extends Node2D
var is_linux = false
var is_game_started = false
var currently_shown = null

var PRINT_INPUT_DEBUG = false

const buttonsClickedDefault = {
	Y = false, X = false, A = false, B = false, RB = false, RT = false, LB = false, LT = false
}

var score: int = 0
var score_checked = false

onready var Cam = $Cam
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
onready var LabelWrong = $Wrong;
onready var LabelCorrect = $Correct;
onready var LabelMissed = $Missed;

var buttonClicked = buttonsClickedDefault

const buttonInputMap = {
	X = ["X"],
	Y = ["Y"],
	A = ["A"],
	B = ["B"],
	RB = ["RB"],
	RT = ["RT", "RTlinux"],
	LB = ["LB"],
	LT = ["LT", "LTlinux"],
}


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


func _input(event):
	if not PRINT_INPUT_DEBUG:
		return

	if event is InputEventJoypadMotion:
		print_debug(event.as_text())
	if event is InputEventJoypadButton:
		print_debug(event.as_text())


func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	Cam.rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	Cam.offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	Cam.offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 3, noise_y)


func _process(delta):
	for key in buttonsClickedDefault:
		var input = (
			buttonInputMap[key][0]
			if buttonInputMap[key].size() == 1
			else (buttonInputMap[key][1] if is_linux else buttonInputMap[key][0])
		)
		if Input.is_action_just_released(input) or Input.is_action_pressed(input):
			buttonClicked[key] = true
			if PRINT_INPUT_DEBUG:
				print_debug("pressed: ", key)
				print_debug("input: ", input)
				print_debug("clicked: ", buttonClicked[key])

	if (
		(
			Input.is_action_just_released("startlinux" if is_linux else "start")
#			or Input.is_action_just_released("ui_accept")
		)
		and not is_game_started
	):
		print_debug("start")
		is_game_started = true
		$GameTimer.start()

	var clicked = check_button_click()
	var was_a_button_clicked = clicked.size() > 0
	if was_a_button_clicked:
		trauma = .15

	check_clicked_correctness(clicked)

#	if Input.is_action_just_released("ui_accept"):
#		trauma = .5

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


func check_clicked_correctness(clicked, missed = false):
	if clicked.size() < 1 or not is_game_started or score_checked:
		return

	if currently_shown in clicked and clicked.size() == 1:
		score += 1
		Input.start_joy_vibration(0, .1, .2, .2)
		LabelCorrect.visible = true
	else:
		score -= 1
		trauma = .5
		Input.start_joy_vibration(0, .2, .4, .4)
		if not missed:
			LabelWrong.visible = true
		else:
			LabelMissed.visible = true

	score_checked = true
	$GameTimer.stop()
	$ResetTimer.start()
	for key in GameSpriteNodes:
			GameSpriteNodes[key].visible = false
	
	score = 0 if score < 0 else score
	$ScoreLabel.text = "SCORE: %d" % score


func _on_GameTimer_timeout():
	if is_game_started and not score_checked and currently_shown != null:
		check_clicked_correctness(["wrong"], true)
		return
		
		
	if is_game_started:
		# here we need to check if when the time expires whether the button was clicked
		score_checked = false
		for key in GameSpriteNodes:
			GameSpriteNodes[key].visible = false
		var key = get_random_game_sprite_node_key()
		var node_to_show = GameSpriteNodes[key]
		node_to_show.visible = true
		currently_shown = key


func _on_ResetTimer_timeout():
	LabelCorrect.visible = false
	LabelWrong.visible = false
	LabelMissed.visible = false
	$GameTimer.start()
