extends Node2D

var moves := 0

func _on_Game_solved():
	$Label.text = "Solved in %d moves!" % moves

func _on_Game_mixing():
	$Label.text = "Mixing... Please wait"
	moves = 0

func _on_Game_move():
	moves += 1
	$Label.text = "Moves made: %d" % moves

func _on_Game_mixed():
	$Label.text = "Ready"

func _on_NewGame_button_down():
	$Game.reset()
