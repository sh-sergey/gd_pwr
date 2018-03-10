extends Panel

onready var game = get_node("..")
onready var rod_panel = get_node("../RodPanel")

onready var rod_id = get_node("Rod/Id")
onready var rod_pos = get_node("Rod/Pos")
onready var shift_btn = get_node("Rod/Shift")

var shift = false
var rod_mul = 1

func _ready():
	
	pass



func update_info():
	rod_id.set_text("Rod: %d-%d" % [game.rods[rod_panel.current_rod].x, game.rods[rod_panel.current_rod].y])
	rod_pos.set_text("Rod pos: %d" % game.rods[rod_panel.current_rod].pos)


func _on_RodUp_pressed():
	game.rod_move(rod_panel.current_rod, 1 * rod_mul)
	update_info()
	rod_panel.rod_update()


func _on_RodDown_pressed():
	game.rod_move(rod_panel.current_rod, -1 * rod_mul)
	update_info()
	rod_panel.rod_update()


func _on_Shift_pressed():
	if (shift):
		shift = false
		rod_mul = 1
		shift_btn.set_pressed(false)
	else:
		shift = true
		rod_mul = 10
		shift_btn.set_pressed(true)
