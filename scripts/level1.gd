extends Node2D

# ССЫЛКИ
@onready var shotgun = $WeaponLayer/PlayerHand/ShotgunSprite
@onready var ui = $GameUI # Теперь мы общаемся только с этим главным узлом UI

# НАСТРОЙКИ УРОВНЯ
var magazine = [true, false, true, false] 
var current_ammo = 0
var player_hp = 2
var enemy_hp = 2 # На Level 2 можно будет поставить 3 или 4!

func _ready():
	shotgun.play("idle")
	
	# ПОДКЛЮЧАЕМ UI К УРОВНЮ
	# Когда UI кричит "нажали кнопку", мы запускаем функцию стрельбы
	ui.shoot_enemy_pressed.connect(shoot_enemy)
	ui.shoot_self_pressed.connect(shoot_self)
	
	print("Уровень 1 начат.")

# --- ЛОГИКА СТРЕЛЬБЫ ---
func shoot_enemy():
	if current_ammo >= magazine.size():
		print("Обойма пуста!")
		return

	# Блокируем кнопки, чтобы не спамить (опционально)
	ui.btn_enemy.disabled = true
	ui.btn_self.disabled = true

	shotgun.play("aim_enemy")
	await get_tree().create_timer(0.5).timeout
	
	var is_live = magazine[current_ammo]
	current_ammo += 1
	
	if is_live:
		shotgun.play("shoot_enemy")
		enemy_hp -= 1
		# ВОТ ОНО! Мы просто говорим UI: "Обнови жизни врага"
		ui.update_enemy_health(enemy_hp)
		check_win_fail()
	else:
		shotgun.play("misfire_enemy")
	
	await shotgun.animation_finished
	shotgun.play("idle")
	
	# Разблокируем кнопки
	ui.btn_enemy.disabled = false
	ui.btn_self.disabled = false

func shoot_self():
	if current_ammo >= magazine.size():
		return

	ui.btn_enemy.disabled = true
	ui.btn_self.disabled = true

	shotgun.play("aim_self")
	await get_tree().create_timer(0.5).timeout
	
	var is_live = magazine[current_ammo]
	current_ammo += 1
	
	if is_live:
		shotgun.play("shoot_self")
		player_hp -= 1
		# Говорим UI: "Обнови мои жизни"
		ui.update_player_health(player_hp)
		check_win_fail()
	else:
		# Холостой в себя = сохранение хода
		pass 
		
	await shotgun.animation_finished
	shotgun.play("idle")
	
	ui.btn_enemy.disabled = false
	ui.btn_self.disabled = false

func check_win_fail():
	if enemy_hp <= 0:
		print("ПОБЕДА!")
		# Тут можно вызвать ui.show_win_screen()
	if player_hp <= 0:
		print("ПОРАЖЕНИЕ...")
