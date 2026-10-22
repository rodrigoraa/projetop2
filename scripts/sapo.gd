# Perseguição direta implementada com assistência de IA.
class_name SapoPantano
extends CharacterBody2D

const VELOCIDADE := 40.0

var alvo: CharacterBody2D
var ativo := true
var tempo_animacao := 0.0

func definir_alvo(jogador: CharacterBody2D) -> void:
	alvo = jogador

func definir_ativo(valor: bool) -> void:
	ativo = valor
	if not ativo:
		velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not ativo or not is_instance_valid(alvo):
		return
	velocity = global_position.direction_to(alvo.global_position) * VELOCIDADE
	move_and_slide()
	tempo_animacao += delta
	$Sprite2D.frame = int(tempo_animacao * 4.0) % 2
