extends Panel

onready var game = get_node("..")
onready var time_btn = get_node("Time/Button")
onready var time_current = get_node("Time/Current")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func info_update():
	time_current.set_text("%02d:%02d:%02d day %d" % [floor(game.second), game.minute, game.hour, game.day])

func _on_Button_pressed():
	game.time(time_btn.is_pressed())


func _on_HSlider_value_changed(value):
	game.dt = pow(floor(value), 2)


func _on_HelpBtn_pressed():
	game.help.popup()


func _on_ResetBtn_pressed():
	game.reactor_reset()

