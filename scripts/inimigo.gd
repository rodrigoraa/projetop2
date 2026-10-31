# Base: Aula 10 do Prof. Ezefferth; estados pedidos no projeto.
extends CharacterBody2D

enum Estado { ESPERAR, PERSEGUIR, SURGIR }

@export var velocidade: float = 40.0
@export var vida: int = 1
var estado := Estado.ESPERAR
var margem := Vector2.ZERO
var tempo_surgindo := 0.0
@onready var sprite: Sprite2D = $Sprite2D
@onready var agente: NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta: float) -> void:
	if estado == Estado.SURGIR:
		_emergir(delta)
		return
	var jogador := get_tree().get_first_node_in_group("player") as Node2D
	var mapa := agente.get_navigation_map()
	var mapa_pronto := NavigationServer2D.map_get_iteration_id(mapa) > 0 and NavigationServer2D.map_get_closest_point_owner(mapa, global_position).is_valid()
	var pode_perseguir: bool = jogador != null and not jogador.escondido and mapa_pronto
	estado = Estado.PERSEGUIR if pode_perseguir else Estado.ESPERAR
	match estado:
		Estado.ESPERAR:
			velocity = Vector2.ZERO
		Estado.PERSEGUIR:
			# O agente calcula o caminho; o inimigo anda ate o proximo ponto.
			agente.target_position = jogador.global_position
			var proximo := agente.get_next_path_position()
			velocity = global_position.direction_to(proximo) * velocidade
			move_and_slide()
			sprite.frame = 0
			if not is_zero_approx(velocity.x):
				sprite.flip_h = velocity.x < 0.0

func levar_golpe() -> void:
	if vida <= 0:
		return
	vida -= 1
	if vida <= 0:
		get_tree().current_scene.inimigo_morreu(self)
		queue_free()

func sair_do_lago(destino: Vector2) -> void:
	margem = destino
	tempo_surgindo = 0.0
	collision_mask = 0
	estado = Estado.SURGIR
	sprite.modulate.a = 0.35
	sprite.scale = Vector2(0.65, 0.65)

func _emergir(delta: float) -> void:
	tempo_surgindo += delta
	velocity = Vector2.ZERO
	var progresso := minf(1.0, tempo_surgindo / 0.35)
	sprite.modulate.a = lerpf(0.35, 1.0, progresso)
	sprite.scale = Vector2.ONE * lerpf(0.65, 1.0, progresso)
	if progresso < 1.0:
		return
	sprite.frame = 2
	velocity = global_position.direction_to(margem) * minf(90.0, global_position.distance_to(margem) / delta)
	move_and_slide()
	if global_position.distance_to(margem) < 1.0:
		collision_mask = 5
		estado = Estado.ESPERAR
		sprite.frame = 0
