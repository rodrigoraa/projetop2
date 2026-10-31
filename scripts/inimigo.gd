# Base: Aula 10 do Prof. Ezefferth; estados pedidos no projeto.
extends CharacterBody2D

enum Estado { ESPERAR, PERSEGUIR }

@export var velocidade: float = 40.0
@export var vida: int = 1
var estado := Estado.ESPERAR
@onready var agente: NavigationAgent2D = $NavigationAgent2D

func _physics_process(_delta: float) -> void:
	var jogador := get_tree().get_first_node_in_group("player") as Node2D
	var mapa_pronto := NavigationServer2D.map_get_iteration_id(agente.get_navigation_map()) > 0
	estado = Estado.PERSEGUIR if jogador != null and mapa_pronto else Estado.ESPERAR
	match estado:
		Estado.ESPERAR:
			velocity = Vector2.ZERO
		Estado.PERSEGUIR:
			# O agente calcula o caminho; o inimigo anda ate o proximo ponto.
			agente.target_position = jogador.global_position
			var proximo := agente.get_next_path_position()
			velocity = global_position.direction_to(proximo) * velocidade
			move_and_slide()

func levar_golpe() -> void:
	if vida <= 0:
		return
	vida -= 1
	if vida <= 0:
		get_tree().current_scene.inimigo_morreu(self)
		queue_free()
