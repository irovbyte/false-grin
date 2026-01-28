extends CanvasLayer

signal shoot_mask_pressed
signal shoot_self_pressed
signal next_level_pressed
signal menu_pressed

# --- ССЫЛКИ ---
@onready var damage_overlay = $DamageOverlay
@onready var info_panel = $MessageContainer
@onready var info_label = $MessageContainer/InfoPanel/InfoLabel
@onready var turn_indicator = $TurnIndicator

# Кнопки
@onready var actions_container = $ActionsContainer
@onready var btn_shoot_mask = $ActionsContainer/BtnShootMask
@onready var btn_shoot_self = $ActionsContainer/BtnShootSelf
@onready var result_container = $ResultContainer
@onready var btn_next = $ResultContainer/BtnNext
@onready var btn_menu = $ResultContainer/BtnMenu

# Текстуры для смены хода (если нужны)
var tex_turn_player = preload("res://assets/sprites/ui/label_turn_player.png")
var tex_turn_mask = preload("res://assets/sprites/ui/label_turn_mask.png")

func _ready():
	# Подключаем сигналы кнопок
	btn_shoot_mask.pressed.connect(func(): emit_signal("shoot_mask_pressed"))
	btn_shoot_self.pressed.connect(func(): emit_signal("shoot_self_pressed"))
	btn_next.pressed.connect(func(): emit_signal("next_level_pressed"))
	btn_menu.pressed.connect(func(): emit_signal("menu_pressed"))
	
	reset_ui()

func reset_ui():
	info_panel.hide()
	turn_indicator.hide()
	actions_container.hide()
	result_container.hide()
	damage_overlay.modulate.a = 0

# --- ФУНКЦИИ ПОКАЗА ТЕКСТА ---

# 1. Временное сообщение (появляется и исчезает)
func show_message(text, duration=2.0):
	info_panel.show()
	info_label.text = text
	await get_tree().create_timer(duration).timeout
	# ВАЖНО: Мы скрываем панель только если текст не изменился за это время
	if info_label.text == text: 
		info_panel.hide()

# 2. Постоянное сообщение (висит, пока не скроем сами)
func set_permanent_text(text):
	info_panel.show()
	info_label.text = text

# 3. Принудительно скрыть окно
func hide_message():
	info_panel.hide()

func show_turn(is_player_turn):
	turn_indicator.show()
	if is_player_turn:
		# turn_indicator.texture = tex_turn_player # Раскомментируй, если меняешь картинку
		actions_container.show()
	else:
		# turn_indicator.texture = tex_turn_mask
		actions_container.hide()

func show_game_over(is_win):
	actions_container.hide()
	turn_indicator.hide()
	result_container.show()
	info_panel.show()
	if is_win:
		btn_next.show()
		info_label.text = "ПОБЕДА"
	else:
		btn_next.hide()
		info_label.text = "ТЫ ПОГИБ"

func flash_damage():
	var tween = create_tween()
	tween.tween_property(damage_overlay, "modulate:a", 1.0, 0.1)
	tween.tween_property(damage_overlay, "modulate:a", 0.0, 2.0)
