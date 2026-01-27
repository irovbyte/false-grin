extends Camera2D

@onready var weapon = $WeaponInHand

func _ready():
	print("Игра готова! Нажмите ЛКМ для стрельбы")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shoot()

func shoot():
	var random_value = randf() * 100.0
	
	if random_value <= 40.0:  # 40% шанс
		successful_shot()
	else:  # 60% шанс
		misfire()

func successful_shot():
	print("🔥 УДАЧНЫЙ ВЫСТРЕЛ! 💥")
	
	# Анимация отдачи
	if weapon:
		var original_pos = weapon.position
		var tween = create_tween()
		tween.tween_property(weapon, "position:x", original_pos.x - 30, 0.08)
		tween.tween_property(weapon, "position:x", original_pos.x, 0.15)

func misfire():
	print("❌ Холостой выстрел... *клик*")
	
	# Лёгкая анимация
	if weapon:
		var tween = create_tween()
		tween.tween_property(weapon, "rotation_degrees", 5, 0.05)
		tween.tween_property(weapon, "rotation_degrees", 0, 0.05)
