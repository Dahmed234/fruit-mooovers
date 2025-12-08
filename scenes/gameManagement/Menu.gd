extends Control

class_name Menu

#signal button_pressed(button_name)

@onready var sprite_2d: Sprite2D = $"../Sprite2D"
@export var ui_scale: int

func _ready() -> void:
	var final_size: Vector2 = Vector2 (0,0.0)
	var labels: Array[Node] = get_children()
	# handle resizing to make text not blurry
	for label in labels:
		label.add_theme_font_size_override("font_size",ui_scale)
		var text_size = label.get_minimum_size()
		var ui_size = label.size
		var n_size = Vector2(max(ui_size.x,text_size.x),max(ui_size.y,text_size.y))
		final_size.x = max(n_size.x,size.x)
		final_size.y += n_size.y
	sprite_2d.region_rect.size = final_size + Vector2(40,40)

func _process(delta: float) -> void:
	sprite_2d.region_rect.position.x += delta * 10.0
	sprite_2d.region_rect.position.y += delta * 10.0
