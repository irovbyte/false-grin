extends Control

@onready var light = $LampHanging/PointLight2D
@onready var lamp = $LampHanging
@onready var mask = $MaskFace

var mask_start_y = 0.0
var time_passed = 0.0

func _ready():
	if mask:
		mask_start_y = mask.position.y

func _process(delta):
	time_passed += delta
	
	if lamp:
		lamp.rotation = sin(time_passed * 1.5) * 0.05
	
	if mask:
		mask.position.y = mask_start_y + sin(time_passed * 2.0) * 10.0

	if light:
		if randf() > 0.99:
			light.energy = randf_range(0.1, 0.5)
		else:
			var target_energy = 1.0 + randf_range(-0.05, 0.05)
			light.energy = move_toward(light.energy, target_energy, 0.1)

func _on_btn_play_pressed():
	print("Кнопка Играть")

func _on_btn_exit_pressed():
	get_tree().quit()
