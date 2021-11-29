extends Node2D
class_name Tile_Class

signal clicked(label)

const MINSIZE :int= 52
export(int) var size :int = MINSIZE setget setSize
export var label = "XX" setget setLabel

func setSize(val :int):
	size = int(max(MINSIZE, val))
	var vsize = Vector2.ONE * size
	$Label.theme.default_font.size = int(size/1.75) - 8
	$Label.set_size(vsize)
	$Label/Panel.set_size(vsize)
	$Label.margin_right = size
	$Label.margin_bottom = size
	$Button.set_size(vsize)

func setLabel(val):
	label = str(val).left(2)
	$Label.text = label

func _on_Button_pressed():
	emit_signal("clicked", label)
