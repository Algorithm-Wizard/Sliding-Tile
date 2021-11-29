extends Node2D

const MINLEVEL := 2

enum States {mix, sliding, none, ready, queued}
enum Moves {up, down, left, right, none}

export(int) var size :int = (Tile_Class.MINSIZE + 1) * MINLEVEL - 1 setget _setSize
export var bgColor := Color.black setget _setBGColor
export var level := MINLEVEL setget _setLevel
export(int) var tileSize := Tile_Class.MINSIZE setget _setTileSize

var Tile := preload("res://Tile.tscn")
var board := []
var blankRow = -1
var blankCol = -1
var state = States.none
var queued = Moves.none

func _ready():
	reset()

func _setBGColor(val :Color):
	$BackGround.color = val

func _setSize(val :int):
	size = int(max((Tile_Class.MINSIZE + 1) * MINLEVEL - 1, val))
	var bwidth :int = $Border.border_width
	$Border.rect_position = Vector2.ONE * (1 - bwidth)
	$Border.rect_size = Vector2.ONE * (size + bwidth * 2)
	$BackGround.rect_position = Vector2.ONE * -bwidth
	$BackGround.rect_size = Vector2.ONE * (size + bwidth * 2)

func _setLevel(val :int):
	if val == level:
		return
	level = int(max(MINLEVEL, val))
	reset()

func _setTileSize(val :int):
	if val == tileSize:
		return
	tileSize = int(max(Tile_Class.MINSIZE, val))
	reset()

func reset():
	$Tween.stop_all()
	for col in board:
		for tile in col:
			if tile != null:
				remove_child(tile)
				tile.queue_free()
	board.clear()
	var num := 1
	for row in level:
		board.append([])
	for row in level:
		for col in level:
			board[row].append(null)
	for row in level:
		var cols = level
		if row == level - 1:
			cols -= 1
		for col in cols:
			var tile := Tile.instance()
			add_child(tile)
			tile.position = Vector2(col, row) * (tileSize + 1)
			tile.setSize(tileSize)
			tile.setLabel(num)
			tile.connect("clicked",self,"selected")
			board[row][col] = tile
			num += 1
	blankCol = level - 1
	blankRow = level - 1
	state = States.ready

func selected(val):
	if not (state in [States.ready, States.sliding]):
		return
	if blankRow > 0 and board[blankRow - 1][blankCol].label == val:
		doMove(Moves.down)
	elif blankCol > 0 and board[blankRow][blankCol - 1].label == val:
		doMove(Moves.right)
	elif blankRow < level - 1 and board[blankRow + 1][blankCol].label == val:
		doMove(Moves.up)
	elif blankCol < level - 1 and board[blankRow][blankCol + 1].label == val:
		doMove(Moves.left)

func doMove(move :int):
	var tile
	if state == States.sliding:
		state = States.queued
		queued = move
	if state == States.ready:
		state = States.sliding
		match move:
			Moves.down:
				tile = board[blankRow - 1][blankCol]
				$Tween.interpolate_property(tile, "position", tile.position, tile.position + Vector2(0, tileSize), 1, Tween.TRANS_QUAD)
				$Tween.start()
				board[blankRow][blankCol] = tile
				blankRow -= 1
				board[blankRow][blankCol] = null
				print("down")
			Moves.up:
				tile = board[blankRow + 1][blankCol]
				$Tween.interpolate_property(tile, "position", tile.position, tile.position + Vector2(0, -tileSize), 1, Tween.TRANS_QUAD)
				$Tween.start()
				board[blankRow][blankCol] = tile
				blankRow += 1
				board[blankRow][blankCol] = null
				print("up")
			Moves.left:
				tile = board[blankRow][blankCol + 1]
				$Tween.interpolate_property(tile, "position", tile.position, tile.position + Vector2(-tileSize, 0), 1, Tween.TRANS_QUAD)
				$Tween.start()
				board[blankRow][blankCol] = tile
				blankCol += 1
				board[blankRow][blankCol] = null
				print("left")
			Moves.right:
				tile = board[blankRow][blankCol - 1]
				$Tween.interpolate_property(tile, "position", tile.position, tile.position + Vector2(tileSize, 0), 1, Tween.TRANS_QUAD)
				$Tween.start()
				board[blankRow][blankCol] = tile
				blankCol -= 1
				board[blankRow][blankCol] = null
				print("right")
	
func _on_Tween_tween_all_completed():
	if state == States.sliding:
		state = States.ready
	if state == States.queued:
		state = States.ready
		doMove(queued)
