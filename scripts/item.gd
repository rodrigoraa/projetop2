# Coletável implementado com assistência de IA; arte original Ninja Adventure (CC0).
class_name ItemPantano
extends Area2D

signal coletado(item: Area2D)

var foi_coletado := false
var ativo := true

func _ready() -> void:
	body_entered.connect(ao_contato)

func ao_contato(corpo: Node2D) -> void:
	if not ativo or foi_coletado or not corpo is CharacterBody2D or corpo.collision_layer & 2 == 0:
		return
	# Após um teleporte, body_entered pode ainda carregar o contato anterior.
	var colisao := corpo.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if colisao == null or not $CollisionShape2D.shape.collide($CollisionShape2D.global_transform, colisao.shape, colisao.global_transform):
		return
	foi_coletado = true
	coletado.emit(self)
	queue_free()

func definir_ativo(valor: bool) -> void:
	ativo = valor
	# body_entered pode encerrar a partida durante o flush da física.
	set_deferred("monitoring", valor)
