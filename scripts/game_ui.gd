extends Control

# --- СИГНАЛЫ ---
signal shoot_mask_pressed
signal shoot_self_pressed
signal next_level_pressed
signal menu_pressed

# --- ССЫЛКИ НА УЗЛЫ ---
@onready var damage_overlay = $DamageOverlay
@onready var info_panel = $MessageContainer
@onready var info_label = $MessageContainer/InfoPanel/InfoLabel
@onready var turn_indicator = $TurnIndicator

# Кнопки действий
@onready var actions_container = $ActionsContainer
@onready var btn_shoot_mask = $ActionsContainer/BtnShootMask
@onready var btn_shoot_self = $ActionsContainer/BtnShootSelf

# Кнопки финала
@onready var result_container = $ResultContainer
@onready var btn_next = $ResultContainer/BtnNext
@onready var btn_menu = $ResultContainer/BtnMenu

# --- ТЕКСТУРЫ (Загружаем заранее) ---
var tex_turn_player = preload("res://assets/sprites/ui/label_turn_player.png")
var tex_turn_mask = preload("res://assets/sprites/ui/label_turn_mask.png")

func _ready():
	# Подключаем нажатия
	btn_shoot_mask.pressed.connect(func(): emit_signal("shoot_mask_pressed"))
	btn_shoot_self.pressed.connect(func(): emit_signal("shoot_self_pressed"))
	btn_next.pressed.connect(func(): emit_signal("next_level_pressed"))
	btn_menu.pressed.connect(func(): emit_signal("menu_pressed"))
	
	# Скрываем все лишнее на старте
	reset_ui()

func reset_ui():
	info_panel.hide()
	turn_indicator.hide()
	actions_container.hide()
	result_container.hide()
	damage_overlay.modulate.a = 0 # Прозрачный

# --- ФУНКЦИИ ПОКАЗА ---

func show_message(text, duration=2.0):
	info_panel.show()
	info_label.text = text
	await get_tree().create_timer(duration).timeout
	info_panel.hide()

func show_turn(is_player_turn):
	turn_indicator.show()
	if is_player_turn:
		turn_indicator.texture = tex_turn_player
		actions_container.show() # Показываем кнопки только игроку
	else:
		turn_indicator.texture = tex_turn_mask
		actions_container.hide() # Прячем кнопки

func show_game_over(is_win):
	actions_container.hide()
	turn_indicator.hide()
	result_container.show()
	
	if is_win:
		btn_next.show()
		btn_menu.show()
		info_label.text = "ПОБЕДА"
	else:
		btn_next.hide() # Нельзя идти дальше, если умер
		btn_menu.show()
		info_label.text = "ТЫ ПОГИБ"
	
	info_panel.show()

# --- ЭФФЕКТЫ ---

func flash_damage():
	# Резкое появление черноты и плавное исчезновение
	var tween = create_tween()
	tween.tween_property(damage_overlay, "modulate:a", 1.0, 0.1) # Резко темно
	tween.tween_property(damage_overlay, "modulate:a", 0.0, 2.0) # Медленно светлеет
