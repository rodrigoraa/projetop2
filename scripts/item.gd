# Base: ficha Coleta da Aula 10 do Prof. Ezefferth.
extends Area2D

var coletado := false

func _on_body_entered(_body: Node2D) -> void:
	if coletado:
		return
	coletado = true
	get_tree().current_scene.coletou()
	queue_free()
