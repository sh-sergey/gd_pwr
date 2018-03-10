extends Control

onready var game = get_node("../..")
onready var panel = get_node("Panel")

const MIN_IND_SIZE = 20
const MAX_IND_SIZE = 80

onready var img = preload("assets/c0.tex")

var inds = []
var label_info = []
var ind_labels = []
var ind_lamps = []

var lamp_color = [Color(0.65, 1, 0.5, 1), Color(1, 1, 1, 0), 
				  Color(1, 0.85, 0, 1), Color(0.1, 0.42, 0, 1), Color(1, 0, 0, 1)]

var poligon = []

var cell_count
var power_display = false

func _ready():
	reset_ind()
	pass

func labels_update():
	if (power_display):
		var coeff = 1/(game.full_power*(game.cell_count*2)-0.01)
		for i in range(cell_count):
			if (label_info[i].exist):
				ind_labels[i].set_text(str(game.cells[i].power).pad_decimals(1))

func labels_set():
	if (!power_display):
		for i in range(cell_count):
			if (label_info[i].exist):
				ind_labels[i].set_text("%d-%d" % [label_info[i].x,label_info[i].y])

func reset_ind():
	cell_count = game.rsize_w*game.rsize_h
	var size_x = panel.get_size().x / game.rsize_w
	var size_y = panel.get_size().y / game.rsize_h
	var ind_size = clamp(min(size_x, size_y), MIN_IND_SIZE, MAX_IND_SIZE)
	
	var ind = get_node("Indicator")
	
	ind_labels.clear()
	label_info.clear()
	inds.clear()
	
	var offset = Vector2(panel.get_size().x - game.rsize_w*ind_size, panel.get_size().y - game.rsize_h*ind_size)*0.5
	for h in range(game.rsize_h):
		for w in range(game.rsize_w):
			var obj = ind.duplicate()
			obj.set_size(Vector2(ind_size, ind_size))
			obj.set_pos(Vector2(w*ind_size, h*ind_size) + offset)
			panel.add_child(obj)
			var label = obj.get_node("Label")
			if (game.plan_default[w + h*game.rsize_h] == 1):
				obj.set_texture(img)
				obj.set_modulate(Color(0.4, 0.4, 0.4))
			elif (game.plan_default[w + h*game.rsize_h] == 2):
				obj.set_texture(img)
				obj.set_modulate(Color(0.2, 0.4, 0.2))
			var lamp = obj.get_node("Lamp")
			lamp.set_modulate(lamp_color[1])
			obj.show()
			inds.push_back(obj)
			ind_labels.push_back(label)
			ind_lamps.push_back(lamp)
			label_info.push_back({x = w, y = h, exist = (game.plan_default[w + h*game.rsize_h] != 0)})
	labels_set()


func _on_PowerDisp_toggled(pressed):
	power_display = pressed
	labels_set()
	labels_update()
