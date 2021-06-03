extends Node

onready var rod_panel = get_node("RodPanel")
onready var rod_control = get_node("RodControl")
onready var reactor_panel = get_node("LeftPanel/ReactorPanel")
onready var reactor_control = get_node("LeftPanel/ReactorPanel/ReactorControl")
onready var main_panel = get_node("MainPanel")
onready var timer = get_node("Timer")
onready var help = get_node("Help")

var sect_w = 3
var sect_h = 3
var rsize_w = sect_w * 3
var rsize_h = sect_h * 3

var sectors = []
var rods = []
var cells = []
var cell_dis = []
var cell_count

var tmp_npower = []

const NEUT_CYCLE = 1000
const BASE_REACT = 1.0001

const NEUT_E = 0.64e-7
const AIR_POWER = 1

var dt = 1

var second = 0
var minute = 0
var hour = 0
var day = 1

var full_power = 0
var prev_power = 1
var avr_npower = 0
var avr_reactivity = 1.0

class sector:
	var id = 0
	var x = 0
	var y = 0
	var react = BASE_REACT
	var rfr = AIR_POWER
	var npower = AIR_POWER
	var cells = []
	var nb = []

class rod:
	var pos = 0
	var x = 0
	var y = 0
	var cell
	var sector

class cell:
	var exist = true
	var x = 0
	var y = 0
	var id = 0
	var nb = []
	var power = 0

func _ready():
	OS.set_window_position((OS.get_screen_size() - OS.get_window_size()) / 2)
	
	set_process_unhandled_key_input(true)
	
	for i in range(9):
		cell_dis.append(1/Vector2(i%3-1, i/3-1).length())
	reactor_start_state()
	
	help.popup()

func time(start):
	if (start):
		timer.start()
	else:
		timer.stop()

func time_set(value):
	pass

func reactor_update():
	second += dt
	while (second >= 60):
		second -= 60
		minute += 1
	if (minute > 59):
		minute -= 60
		hour += 1
	if (hour > 23):
		hour -= 24
		day += 1
	
	var react = 0
	var pwr = 0
	
	for p in sectors:
		p.react = BASE_REACT
		if (p.npower < 1):
			p.npower = AIR_POWER
	
	for p in rods:
		var x = (100 - p.position)*0.01
		p.sector.react += -0.005*(2.5/(1.5/(x-0.5)+x*4-2)+0.5)
	
	for s in sectors:
		s.react = exp((s.react - 1) * NEUT_CYCLE * dt)
		s.npower *= s.react
		
		for i in s.nb:
			tmp_npower[i.id] += s.npower*0.14*dt
		s.npower *= 0.14
		react = max(s.npower/s.rfr - 1, react)
		s.rfr = s.npower
		s.npower = tmp_npower[s.x+s.y*sect_w]
		
		for c in cells:
			c.power = s.npower*NEUT_E*50*9
			pwr += c.power
	
	
	for i in range(sect_h*sect_w):
		tmp_npower[i] = 0
	
	full_power = pwr
	
	avr_reactivity = react
	prev_power = full_power
	
	
	main_panel.info_update()
	reactor_panel.labels_update()
	reactor_control.info_update()

func reactor_reset():
	reactor_start_state()

func reactor_start_state():
	cell_count = 0
	second = 0
	minute = 0
	hour = 0
	day = 0
	dt = 1
	tmp_npower.clear()
	cells.clear()
	rods.clear()
	
	cells.resize(rsize_h * rsize_w)
	for i in range(sect_h * sect_w):
		tmp_npower.append(0)
	for s in range(sect_w * sect_h):
		var s_x = s % sect_w
		var s_y = s / sect_h
		var sect = sector.new()
		sect.id = s
		sect.x = s_x
		sect.y = s_y
		
		#Creating cells for current sector (3x3)
		for i in range(9):
			var obj = cell.new()
			obj.x = (s_x * 3) + (i % 3)
			obj.y = (s_y * 3) + (i / 3)
			var abs_i = (obj.y * 9) + obj.x
			obj.exist = (plan_default[abs_i] != 0)
			obj.id = abs_i
			if (plan_default[abs_i] != 0):
				cell_count += 1
			cells[abs_i] = obj
			sect.cells.push_back(obj)
		
		sectors.push_back(sect)
	#Finding nb cells for everybody cell
	for p in cells:
		for i in range(-1, 2):
			for j in range(-1, 2):
				var x = p.x+i
				var y = p.y+j
				if ((x >= 0 && x < rsize_w) && (y >= 0 && y < rsize_h)):
					if (x+y*rsize_w != p.id && cells[x+y*rsize_w].exist):
						p.nb.push_back(cells[x+y*rsize_w])
	
	#Finding nb sectors for everybody sector
	for p in sectors:
		for i in range(-1, 2):
			for j in range(-1, 2):
				var x = p.x+i
				var y = p.y+j
				if ((x >= 0 && x < sect_w) && (y >= 0 && y < sect_h)):
					if (x+y*sect_w != p.id):
						p.nb.push_back(sectors[x+y*sect_w])
	
	#Creating control rods for some cells
	for h in range(rsize_h):
		for w in range(rsize_w):
			if (plan_default[w + h*rsize_h] == 2):
				var obj = rod.new()
				obj.x = w
				obj.y = h
				obj.cell = cells[w + h*rsize_h]
				obj.sector = sectors[(obj.x/3) + (obj.y/3 * sect_w)]
				rods.push_back(obj)
	
	reactor_control.info_update()
	rod_panel.reset_buttons()
	rod_panel.rod_update()
	main_panel.info_update()

func rod_move_and_collide(rod, d):
	rods[rod].position = clamp(rods[rod].position + d, 0, 100)

func rod_ep():
	for p in rods:
		p.position = 0
	reactor_panel.labels_update()
	reactor_control.info_update()
	rod_panel.rod_update()

func rods_up():
	for p in rods:
		p.position = 100
	reactor_panel.labels_update()
	reactor_control.info_update()
	rod_panel.rod_update()

var plan_default = [0,0,1,1,1,1,1,0,0,
					0,1,1,2,1,2,1,1,0,
					1,2,1,1,1,1,1,2,1,
					1,1,1,2,1,2,1,1,1,
					1,2,1,1,1,1,1,2,1,
					1,1,1,2,1,2,1,1,1,
					1,2,1,1,1,1,1,2,1,
					0,1,1,2,1,2,1,1,0,
					0,0,1,1,1,1,1,0,0]

func _unhandled_key_input(key_event):
	if (key_event.is_action_pressed("cs_up")):
		rod_move_and_collide(rod_panel.current_rod, 1)
	elif (key_event.is_action_pressed("cs_down")):
		rod_move_and_collide(rod_panel.current_rod, -1)
	elif (key_event.is_action_pressed("ce_up")):
		rod_move_and_collide(rod_panel.current_rod, 10)
	elif (key_event.is_action_pressed("ce_down")):
		rod_move_and_collide(rod_panel.current_rod, -10)
	elif (key_event.scancode == KEY_E):
		rod_ep()
	rod_panel.rod_update()
	rod_control.update_info()

func _on_Timer_timeout():
	reactor_update()

