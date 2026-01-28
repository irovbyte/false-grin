extends Control

# Сигналы: мы будем кричать Уровню, что игрок нажал кнопку
signal shoot_enemy_pressed
signal shoot_self_pressed

# Ссылки на контейнеры с сердцами
@onready var player_hp_container = $FrameLeft/PlayerHP
@onready var enemy_hp_container = $FrameRight/EnemyHP

# Ссылки на кнопки
@onready var btn_enemy = $BtnEnemy
@onready var btn_self = $BtnSelf

func _ready():
	# Подключаем нажатие кнопок к нашим сигналам
	btn_enemy.pressed.connect(_on_btn_enemy_click)
	btn_self.pressed.connect(_on_btn_self_click)

func _on_btn_enemy_click():
	# Передаем сигнал наверх (в Level1)
	emit_signal("shoot_enemy_pressed")

func _on_btn_self_click():
	emit_signal("shoot_self_pressed")

# --- УНИВЕРСАЛЬНЫЕ ФУНКЦИИ ОБНОВЛЕНИЯ ---

# Обновить жизни Игрока
func update_player_health(current_hp):
	_update_hearts(player_hp_container, current_hp)

# Обновить жизни Врага
func update_enemy_health(current_hp):
	_update_hearts(enemy_hp_container, current_hp)

# Внутренняя функция: удаляет лишние сердца
func _update_hearts(container, hp):
	var hearts = container.get_children()
	# Если сердец больше, чем жизней -> удаляем лишние
	while hearts.size() > hp:
		var h = hearts.pop_back() # Берем последнее
		h.queue_free() # Удаляем
