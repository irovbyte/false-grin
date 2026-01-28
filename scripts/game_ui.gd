extends CanvasLayer

signal shoot_mask_pressed
signal shoot_self_pressed
signal menu_pressed

@onready var info_panel = $MessageContainer
@onready var info_label = $MessageContainer/InfoPanel/InfoLabel
@onready var turn_indicator = $TurnIndicator
@onready var actions_container = $ActionsContainer
@onready var result_container = $ResultContainer
@onready var damage_overlay = $DamageOverlay

func _ready():
	# Подключаем кнопки к сигналам
	$ActionsContainer/BtnShootMask.pressed.connect(func(): emit_signal("shoot_mask_pressed"))
	$ActionsContainer/BtnShootSelf.pressed.connect(func(): emit_signal("shoot_self_pressed"))
	$ResultContainer/BtnMenu.pressed.connect(func(): emit_signal("menu_pressed"))
	reset_ui()

func reset_ui():
	info_panel.hide()
	turn_indicator.hide()
	actions_container.hide()
	result_container.hide()
	damage_overlay.modulate.a = 0

# Функция для обновления сердечек
func update_hp(p_hp, m_hp):
	# Игрок (Лево)
	$FrameLeft/PlayerHP/heart_icon.visible = p_hp >= 1
	$FrameLeft/PlayerHP/heart_icon2.visible = p_hp >= 2
	# Маска (Право)
	$FrameRight/EnemyHP/heart_icon.visible = m_hp >= 1
	$FrameRight/EnemyHP/heart_icon2.visible = m_hp >= 2

func show_message(text, duration=1.5):
	info_panel.show()
	info_label.text = text
	await get_tree().create_timer(duration).timeout
	info_panel.hide()

func set_permanent_text(text):
	info_panel.show()
	info_label.text = text

func show_turn(is_player_turn):
	turn_indicator.show()
	actions_container.visible = is_player_turn

func flash_damage():
	var tween = create_tween()
	tween.tween_property(damage_overlay, "modulate:a", 1.0, 0.1)
	tween.tween_property(damage_overlay, "modulate:a", 0.0, 0.5)

func show_game_over(is_win):
	actions_container.hide()
	result_container.show()
	info_panel.show()
	info_label.text = "ВЫЖИЛ" if is_win else "ПОГИБ"
