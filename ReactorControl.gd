extends Panel

onready var game = get_node("../../..")

onready var reactivity = get_node("Reactivity/Value")
onready var period = get_node("Period/Value")
onready var power = get_node("Power/Value")

func _ready():
	
	pass

func info_update():
	reactivity.set_text(str(game.avr_reactivity).pad_decimals(4))
	period.set_text(str(1 / game.avr_reactivity).pad_decimals(1))
	power.set_text(str(game.full_power).pad_decimals(1))


func _on_Button_pressed():
	game.rod_ep()


func _on_Button_2_pressed():
	game.rods_up()

