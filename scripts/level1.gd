extends Node2D

# --- ВАЖНЫЕ ИСПРАВЛЕНИЯ ПУТЕЙ ---
@onready var shotgun = $GameUI/WeaponLayer/PlayerHand/ShotgunSprite
@onready var ui = $GameUI

# --- ПЕРЕМЕННЫЕ ИГРЫ ---
var player_hp = 2
var mask_hp = 2
var magazine = [] 
var current_round_index = 0

func _ready():
	randomize()
	
	# Подключение кнопок интерфейса к функциям уровня
	ui.shoot_mask_pressed.connect(_on_shoot_mask)
	ui.shoot_self_pressed.connect(_on_shoot_self)
	
	# Кнопки финала
	ui.next_level_pressed.connect(func(): print("Переход на уровень 2..."))
	ui.menu_pressed.connect(func(): get_tree().reload_current_scene())

	start_game_sequence()

# --- СЦЕНАРИЙ ИГРЫ ---

func start_game_sequence():
	await ui.show_message("УРОВЕНЬ 1", 2.0)
	
	# Генерируем патроны
	magazine = [true, true, false, false]
	magazine.shuffle()
	current_round_index = 0
	
	print("Патроны в очереди: ", magazine)
	await ui.show_message("ЗАРЯДКА: 2 БОЕВЫХ, 2 ХОЛОСТЫХ", 3.0)
	
	# Кто ходит первый
	start_turn(randf() > 0.5)

func start_turn(is_player):
	if check_game_end(): return
	
	# Если патроны кончились
	if current_round_index >= magazine.size():
		await ui.show_message("ПАТРОНЫ КОНЧИЛИСЬ...", 2.0)
		start_game_sequence()
		return

	ui.show_turn(is_player)
	
	if is_player:
		ui.set_permanent_text("ВЫБЕРИ ЦЕЛЬ") # Надпись висит постоянно
		ui.btn_shoot_mask.disabled = false
		ui.btn_shoot_self.disabled = false
	else:
		ui.set_permanent_text("ХОД МАСКИ...") # Надпись висит пока маска думает
		ui.btn_shoot_mask.disabled = true
		ui.btn_shoot_self.disabled = true
		await get_tree().create_timer(1.5).timeout 
		ai_make_choice()

# --- ЛОГИКА ИГРОКА ---

func _on_shoot_mask():
	ui.hide_message() # Убираем текст при нажатии
	disable_buttons()
	
	shotgun.play("aim_enemy")
	await get_tree().create_timer(0.5).timeout
	
	var is_live = get_bullet() 
	if is_live:
		shotgun.play("shoot_enemy")
		mask_hp -= 1
	else:
		shotgun.play("misfire_enemy")
	
	await shotgun.animation_finished
	shotgun.play("idle")
	start_turn(false) # Ход переходит к маске

func _on_shoot_self():
	ui.hide_message() # Убираем текст при нажатии
	disable_buttons()
	
	shotgun.play("aim_self")
	await get_tree().create_timer(0.5).timeout
	
	var is_live = get_bullet()
	if is_live:
		shotgun.play("shoot_self")
		ui.flash_damage()
		player_hp -= 1
		await shotgun.animation_finished
		shotgun.play("idle")
		start_turn(false) # Боевой в себя -> переход хода
	else:
		# ХОЛОСТОЙ В СЕБЯ = ДОП ХОД
		await shotgun.animation_finished
		shotgun.play("idle")
		start_turn(true) # Снова ход игрока

# --- ЛОГИКА МАСКИ (ИИ) ---

func ai_make_choice():
	var shoot_player = randf() > 0.5
	var is_live = get_bullet()
	
	if shoot_player:
		if is_live:
			ui.flash_damage()
			player_hp -= 1
		start_turn(true)
	else:
		if is_live:
			mask_hp -= 1
			start_turn(true)
		else:
			start_turn(false) # Маска выстрелила в себя холостым -> ходит снова

# --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ---

func get_bullet():
	var b = magazine[current_round_index]
	current_round_index += 1
	return b

func disable_buttons():
	ui.btn_shoot_mask.disabled = true
	ui.btn_shoot_self.disabled = true

func check_game_end():
	if player_hp <= 0:
		ui.show_game_over(false)
		return true
	if mask_hp <= 0:
		ui.show_game_over(true)
		return true
	return false
