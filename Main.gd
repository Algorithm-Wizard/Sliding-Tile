extends Node2D

var moves := 0

func _on_Game_solved():
	$Label.text = "Solved in %d moves!" % moves
	moves = 0

func _on_Game_mixing():
	$Label.text = "Mixing... Please wait"

func _on_Game_move():
	moves += 1
	$Label.text = "Moves made: %d" % moves

func _on_Game_mixed():
	$Label.text = "Ready"
	moves = 0

func _on_NewGame_button_down():
	$Game.reset()
	$Game.mixBoard()
	moves = 0


func _on_Solve_button_down():
	$Game.autoSolve()
