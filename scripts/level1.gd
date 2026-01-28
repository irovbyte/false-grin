extends Node2D

# ССЫЛКИ ПО ТВОЕМУ ДЕРЕВУ СЦЕНЫ
@onready var ui = $GameUI
@onready var shotgun = $GameUI/WeaponLayer/PlayerHand/ShotgunSprite
@onready var mask_sprite = $WeaponLayer/EnemyHand/MaskEnemy

# ТВОИ ТЕКСТУРЫ ВЫСТРЕЛА
var tex_player_shoot = preload("res://assets/sprites/ui/weapons/shoot_enemy.png")
var tex_mask_shoot = preload("res://assets/sprites/ui/weapons/shotgun_muzzle_splash.png")
var tex_idle = preload("res://assets/sprites/ui/weapons/normal_gun.png")

var player_hp = 2
var mask_hp = 2
var magazine = [] 
var current_round_index = 0

func _ready():
	randomize()
	# Проверка на наличие пушки, чтобы не вылетало
	if shotgun == null:
		shotgun = find_child("ShotgunSprite", true, false)
	
	ui.shoot_mask_pressed.connect(_on_shoot_mask)
	ui.shoot_self_pressed.connect(_on_shoot_self)
	ui.menu_pressed.connect(func(): get_tree().reload_current_scene())
	
	start_game_sequence()

# УПРОЩЕННЫЙ ВЫСТРЕЛ
func perform_shot(to_enemy: bool):
	if shotgun == null: return
	
	ui.set_permanent_text("ВЫСТРЕЛ...")
	ui.btn_shoot_mask.disabled = true
	ui.btn_shoot_self.disabled = true

	var is_live = get_bullet()
	
	if is_live:
		# Меняем картинку в зависимости от того, кто стреляет
		if to_enemy:
			shotgun.texture = tex_player_shoot
			mask_hp -= 1
			# Маска краснеет при попадании
			var t = create_tween()
			t.tween_property(mask_sprite, "modulate", Color.RED, 0.1)
			t.tween_property(mask_sprite, "modulate", Color.WHITE, 0.1)
		else:
			shotgun.texture = tex_mask_shoot
			player_hp -= 1
			ui.flash_damage()
	else:
		print("Осечка!")

	await get_tree().create_timer(0.4).timeout
	shotgun.texture = tex_idle # Возвращаем обычный вид
	ui.update_hp(player_hp, mask_hp)
	
	if not check_game_end():
		# Логика ходов
		if not to_enemy and not is_live:
			start_turn(true) # Холостой в себя — снова твой ход
		else:
			start_turn(not to_enemy if is_live else false)

func _on_shoot_mask(): perform_shot(true)
func _on_shoot_self(): perform_shot(false)

func start_game_sequence():
	player_hp = 2
	mask_hp = 2
	ui.update_hp(player_hp, mask_hp)
	magazine = [true, true, false, false]
	magazine.shuffle()
	current_round_index = 0
	await ui.show_message("ЗАРЯДКА...", 1.5)
	start_turn(randf() > 0.5)

func start_turn(is_player):
	if check_game_end(): return
	if current_round_index >= magazine.size():
		start_game_sequence()
		return

	ui.show_turn(is_player)
	if is_player:
		ui.set_permanent_text("ТВОЙ ВЫБОР")
	else:
		ui.set_permanent_text("МАСКА ДУМАЕТ...")
		await get_tree().create_timer(1.2).timeout 
		# Маска стреляет либо в тебя (70%), либо в себя (30%)
		perform_shot(randf() > 0.7)

func get_bullet():
	if current_round_index < magazine.size():
		var b = magazine[current_round_index]
		current_round_index += 1
		return b
	return false

func check_game_end():
	if player_hp <= 0:
		ui.show_game_over(false)
		return true
	if mask_hp <= 0:
		ui.show_game_over(true)
		return true
	return false
