extends Control

class_name Menu

signal button_pressed(button_name)


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var v_box_container: VBoxContainer = $VBoxContainer
@export var ui_scale: int


func _ready() -> void:
	var size: Vector2 = Vector2 (0,0.0)
	var labels: Array[Node] = v_box_container.get_children()
	# handle resizing to make text not blurry
	for label in labels:
		label.add_theme_font_size_override("font_size",ui_scale)
		var text_size = label.get_minimum_size()
		var ui_size = label.size
		var n_size = Vector2(max(ui_size.x,text_size.x),max(ui_size.y,text_size.y))
		size.x = max(n_size.x,size.x)
		size.y += n_size.y
	sprite_2d.region_rect.size = size + Vector2(40,40)
	
	for button in v_box_container.get_children():
		if button is Button:
			button.connect("pressed",_on_button_pressed.bind(button.name))


func _process(delta: float) -> void:
	sprite_2d.region_rect.position.x += delta * 10.0
	sprite_2d.region_rect.position.y += delta * 10.0
	
func _on_button_pressed(button_name):
	emit_signal("button_pressed",button_name)
