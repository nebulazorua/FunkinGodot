extends Node2D



@onready var list: Node2D = %list
@onready var info_label: Label = %label
@onready var info_texture: TextureRect = %texture
@onready var music: AudioStreamPlayer = %music

static var selected: int = 1


func _ready() -> void:
	GlobalAudio.music.stop()
	music.play()

	selected = 0
	change_selection(1)


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if not event.is_pressed():
		return

	if event.is_action(&'ui_cancel'):
		music.stop()
		GlobalAudio.music.play()
		SceneManager.switch_to('res://scenes/menus/main_menu.tscn')
	if event.is_action(&'ui_accept'):
		var item: ListedAlphabet = list.get_child(selected)
		if item is CreditsContributor:
			OS.shell_open(item.link)
	if event.is_action(&'ui_down') or event.is_action(&'ui_up'):
		change_selection(roundi(Input.get_axis(&'ui_up', &'ui_down')))


func change_selection(amount: int = 0) -> void:
	selected = wrapi(selected + amount, 0, list.get_child_count())
	for i in list.get_child_count():
		var item: ListedAlphabet = list.get_child(i)
		item.target_y = i - selected
		item.modulate.a = 0.6 + (float(item.target_y == 0) * 0.4)

	if amount == 0:
		return

	var item: ListedAlphabet = list.get_child(selected)
	if item.text.is_empty() or item.scale != Vector2.ONE:
		change_selection(signi(amount))
		return

	if item is CreditsContributor:
		info_label.text = item.role
		info_texture.texture = item.texture
	GlobalAudio.get_player(^'MENU/SCROLL').play()
