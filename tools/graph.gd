extends Panel

onready var size = get_size()

onready var size_x = int(size.x)

var points = []
var color = Color(0, 1, 0)
var cn = 0
onready var maxn = size_x
onready var maxv = int(size.y)

func _ready():
	points.resize(size_x)
	for i in range(size_x):
		points[i] = 0

func _draw():
	for i in range(size_x-3):
		draw_line(Vector2(i, size.y-points[i]), Vector2(i+1, size.y-points[i+1]), color)

func add_value(value):
	if (cn < size_x-1):
		points[cn] = value
		cn += 1
	else:
		for i in range(size_x-2):
			points[i] = points[i+1]
			points[cn] = value
	if (value > maxv):
		var foo = maxv/value
		for i in range(size_x-2):
			points[i] *= foo
		
	

