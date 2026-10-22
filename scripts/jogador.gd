# Movimento e vida implementados com assistência de IA.
class_name JogadorPantano
extends CharacterBody2D

signal vida_alterada(vida: int)
signal morreu

const VELOCIDADE := 80.0
const INVENCIBILIDADE := 1.0

var vida: int = 3
var ativo := true
var invencivel_restante := 0.0
var direcao := 0
var tempo_animacao := 0.0

func _physics_process(delta: float) -> void:
	invencivel_restante = maxf(0.0, invencivel_restante - delta)
	$Sprite2D.modulate.a = 0.45 if invencivel_restante > 0.0 else 1.0
	if not ativo:
		return
	var entrada := Input.get_vector("mover_esquerda", "mover_direita", "mover_cima", "mover_baixo")
	velocity = entrada * VELOCIDADE
	move_and_slide()
	animar(entrada, delta)
	if $Hurtbox.has_overlapping_bodies():
		receber_dano()

func animar(entrada: Vector2, delta: float) -> void:
	if entrada != Vector2.ZERO:
		if absf(entrada.x) > absf(entrada.y):
			direcao = 3 if entrada.x > 0 else 2
		else:
			direcao = 0 if entrada.y > 0 else 1
		tempo_animacao += delta
		$Sprite2D.frame = direcao + (int(tempo_animacao * 8.0) % 4) * 4
	else:
		tempo_animacao = 0.0
		$Sprite2D.frame = direcao

func receber_dano() -> void:
	if not ativo or vida <= 0 or invencivel_restante > 0.0:
		return
	vida -= 1
	invencivel_restante = INVENCIBILIDADE
	vida_alterada.emit(vida)
	if vida == 0:
		definir_ativo(false)
		morreu.emit()

func definir_ativo(valor: bool) -> void:
	ativo = valor and vida > 0
	if not ativo:
		velocity = Vector2.ZERO

func reiniciar(posicao: Vector2) -> void:
	global_position = posicao
	vida = 3
	velocity = Vector2.ZERO
	invencivel_restante = 0.0
	direcao = 0
	tempo_animacao = 0.0
	$Sprite2D.frame = 0
	$Sprite2D.modulate = Color.WHITE
	definir_ativo(true)
	vida_alterada.emit(vida)
