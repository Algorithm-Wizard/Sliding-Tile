extends Node2D

signal solved
signal mixing
signal move
signal mixed

const MINLEVEL := 2

enum States {mix, sliding, none, ready, queued}
enum Moves {up, down, left, right, none}

export(int) var size :int = (Tile_Class.MINSIZE + 1) * MINLEVEL - 1 setget _setSize
export var bgColor := Color.black setget _setBGColor
export var level := MINLEVEL setget _setLevel
export(int) var tileSize := Tile_Class.MINSIZE setget _setTileSize
export var mix := 120

var Tile := preload("res://Tile.tscn")
var board := []
var blankRow := -1
var blankCol := -1
var state = States.none
var queued = Moves.none
var _mix := -1
var _invLast :int = Moves.none

func _ready():
	randomize()
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
	$Tween.remove_all()
	state = States.mix
	_mix = mix
	_invLast = Moves.none
	emit_signal("mixing")
	nextMix()

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

func doMove(move :int, speed :float = .5):
	var tile
	if state == States.sliding:
		state = States.queued
		queued = move
	if state == States.ready:
		state = States.sliding
		emit_signal("move")
	if state in [States.sliding, States.mix]:
		match move:
			Moves.down:
				tile = board[blankRow - 1][blankCol]
				$Tween.interpolate_property(tile, "position", tile.position, tile.position + Vector2(0, tileSize + 1), speed, Tween.TRANS_QUAD)
				$Tween.start()
				board[blankRow][blankCol] = tile
				blankRow -= 1
				_invLast = Moves.up
			Moves.up:
				tile = board[blankRow + 1][blankCol]
				$Tween.interpolate_property(tile, "position", tile.position, tile.position + Vector2(0, -tileSize - 1), speed, Tween.TRANS_QUAD)
				$Tween.start()
				board[blankRow][blankCol] = tile
				blankRow += 1
				_invLast = Moves.down
			Moves.left:
				tile = board[blankRow][blankCol + 1]
				$Tween.interpolate_property(tile, "position", tile.position, tile.position + Vector2(-tileSize - 1, 0), speed, Tween.TRANS_QUAD)
				$Tween.start()
				board[blankRow][blankCol] = tile
				blankCol += 1
				_invLast = Moves.right
			Moves.right:
				tile = board[blankRow][blankCol - 1]
				$Tween.interpolate_property(tile, "position", tile.position, tile.position + Vector2(tileSize + 1, 0), speed, Tween.TRANS_QUAD)
				$Tween.start()
				board[blankRow][blankCol] = tile
				blankCol -= 1
				_invLast = Moves.left
		board[blankRow][blankCol] = null
	
func _on_Tween_tween_all_completed():
	match state:
		States.sliding:
			state = States.ready
			if checkWin():
				emit_signal("solved")
		States.queued:
			state = States.ready
			doMove(queued)
		States.mix:
			nextMix()

func nextMix():
	if _mix < 0:
		state = States.ready
		emit_signal("mixed")
		return
	_mix -= 1
	var iMove := randi() % 4
	var allMoves := [Moves.up, Moves.down, Moves.left, Moves.right]
	while !checkMove(allMoves[iMove]) or allMoves[iMove] == _invLast:
		iMove = randi() % 4
	doMove(allMoves[iMove], .05)

func checkMove(move: int) -> bool:
	match move:
		Moves.down:
			return blankRow > 0
		Moves.right:
			return blankCol > 0
		Moves.up:
			return blankRow < level - 1
		Moves.left:
			return blankCol < level - 1
	return false

func checkWin() -> bool:
	var num := 1
	for row in level:
		var cols := level
		if row == level - 1:
			cols -= 1
		for col in cols:
			if board[row][col] == null:
				return false
			if board[row][col].getLabel() != str(num):
				return false
			num += 1
	return true
