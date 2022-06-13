extends Label

onready var tween = $Tween
onready var timer = $Timer

func _ready():
	tween.interpolate_property(self, "modulate:a", 0, 1, 0.3, Tween.TRANS_SINE)
	tween.start()

func textprocess(message, timeonscreen):
	set_text(message)
	timer.start(timeonscreen)
	yield(timer, "timeout")
	tween.interpolate_property(self, "modulate:a", 1, 0, 0.3, Tween.TRANS_SINE)
	tween.start()
	yield(tween, "tween_all_completed")
	queue_free()
