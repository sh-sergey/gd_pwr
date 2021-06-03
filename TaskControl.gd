extends Label

var seconds = 300
var complete = false

func _ready():
	
	pass

#func task_check():
#	if (!complete):
#		if (full_power > 18e3 && full_power < 20e3):
#			seconds -= 1*dt
#			if (seconds == 0):
#				complete = true
#				label.set_text("Task completed!")
#			else:
#				label.set_text("Power %d2 E (18000;20000) time remained %d" % [full_power, seconds])
#		else:
#			seconds = 300
#			label.set_text("Power %d !E (18000;20000)" % [full_power])

