# Base: Aulas 09 e 10 do Prof. Ezefferth.
extends Node2D

@export var cena_inimigo: PackedScene
var finalizada := false
var abates := 0

@onready var horda: Timer = $Horda
@onready var relogio: Timer = $Relogio
@onready var jogador: CharacterBody2D = $Jogador
@onready var texto_vida: Label = $HUD/Vida
@onready var texto_tempo: Label = $HUD/Tempo

func _process(_delta: float) -> void:
	texto_vida.text = "Vida: %d  Abates: %d" % [jogador.vida, abates]
	texto_tempo.text = "Tempo: %d" % ceili(relogio.time_left)

func _on_horda_timeout() -> void:
	if finalizada:
		return
	var inimigo := cena_inimigo.instantiate() as CharacterBody2D
	var ponto: Marker2D = $Nascedouros.get_children().pick_random()
	add_child(inimigo)
	inimigo.global_position = ponto.global_position
	# A horda aperta: cada inimigo chega um pouco mais cedo que o anterior.
	horda.wait_time = maxf(0.5, horda.wait_time * 0.95)

func _on_relogio_timeout() -> void:
	vencer()

func vencer() -> void:
	encerrar("res://scenes/vitoria.tscn")

func perder() -> void:
	encerrar("res://scenes/derrota.tscn")

func encerrar(destino: String) -> void:
	if finalizada:
		return
	finalizada = true
	horda.stop()
	relogio.stop()
	# call_deferred: troca de cena só no fim do quadro, quando a física terminou.
	get_tree().change_scene_to_file.call_deferred(destino)

func inimigo_morreu(_inimigo: Node2D) -> void:
	if not finalizada:
		abates += 1
