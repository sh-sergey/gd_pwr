extends Control

onready var game = get_node("..")
onready var rod_control = get_node("../RodControl")

var rod_btn_mode = false
var rod_count

var rod_btn = []
var rod_btn_label = []

var current_rod

var min_btn_size = 40
var max_btn_size = 80
var max_btn_dis = 320

func _ready():
	pass

func rod_update():
	for i in range(rod_count):
		rod_btn_label[i].set_text(str(game.rods[i].position))

func reset_buttons():
	rod_btn.clear()
	rod_btn_label.clear()
	var rods = []
	for i in range(game.rsize_h):
		rods.append([])
	for i in range(game.rods.size()):
		rods[game.rods[i].y].append({x = game.rods[i].x, y = game.rods[i].y, id = i})
	for i in range(rods.size()-1, -1, -1):
		if (rods[i].empty()):
			rods.remove_and_collide(i)
	
	rod_count = 0
	for i in rods:
		rod_count += i.size()
	
	var max_x = 0
	var max_y = rods.size()
	for i in rods:
		if (i.size() > max_x):
			max_x = i.size()
	
	var size_x = get_size().x / max_x
	var size_y = get_size().y / max_y
	var btn_size = clamp(min(size_x, size_y), min_btn_size, max_btn_size)
	
	var rod_offset = []
	for i in range(rods.size()):
		rod_offset.append([])
	for h in range(rods.size()):
		for i in range(rods[h].size()):
			if (i > 0):
				rod_offset[h].append(clamp((rods[h][i].x - rods[h][i-1].x) * btn_size, 0, max_btn_dis))
			else:
				rod_offset[h].append(0)
	
	var btn = get_node("RodBtn")
	
	for i in rod_btn:
		i.free()
	rod_btn.clear()
	
	var offset_y = (get_size().y - max_y*btn_size)*0.5
	for h in range(rods.size()):
		var dis = 0
		for i in rod_offset[h]:
			dis += i
		var real_dis = clamp(dis, (get_size().x - max_x*btn_size), dis)
		var k = real_dis / dis
		for i in rod_offset[h]:
			i *= k
		var offset_x = (get_size().x - max_x*btn_size - dis)*0.5
		var offset = Vector2(offset_x, offset_y)
		var count_x = 0
		for w in range(rods[h].size()):
			var obj = btn.duplicate()
			obj.set_size(Vector2(btn_size, btn_size))
			obj.set_position(Vector2(rod_offset[h][w] + count_x, h*btn_size) + offset)
			count_x += rod_offset[h][w]
			add_child(obj)
			obj.show()
			obj.get_node("Button").connect("pressed", get_node("."), "_rod_btn_click", [rods[h][w].id])
			rod_btn.push_back(obj.get_node("Button"))
			obj.get_node("Button").set_text("%d-%d" % [rods[h][w].x, rods[h][w].y])
			rod_btn_label.push_back(obj.get_node("Label"))
	
	current_rod = 0
	rod_control.update_info()
	rod_btn[current_rod].set_pressed(true)

func _rod_btn_click(id):
	rod_btn[current_rod].set_pressed(false)
	current_rod = id
	rod_btn[current_rod].set_pressed(true)
	rod_control.update_info()

