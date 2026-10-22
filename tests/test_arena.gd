# Verificações funcionais escritas com assistência de IA.
extends SceneTree

var falhas := 0
var verificacoes := 0

func _initialize() -> void:
	call_deferred("executar")

func exigir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func livre(arena: Node2D, ponto: Vector2, raio: float = 7.0) -> bool:
	var forma := CircleShape2D.new()
	forma.radius = raio
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.transform = Transform2D(0.0, ponto)
	consulta.collision_mask = 1
	return arena.get_world_2d().direct_space_state.intersect_shape(consulta).is_empty()

func executar() -> void:
	# A ausência da arena deve falhar com código não zero no primeiro RED.
	exigir(ResourceLoader.exists("res://scenes/arena.tscn"), "Arena ainda não existe.")
	if falhas > 0:
		terminar()
		return
	var cena := load("res://scenes/arena.tscn") as PackedScene
	exigir(cena != null, "Arena precisa ser uma PackedScene válida.")
	if cena == null:
		terminar()
		return
	var arena := cena.instantiate() as Node2D
	root.add_child(arena)
	await physics_frame
	await physics_frame
	exigir(arena.get("tamanho") == Vector2i(640, 384), "Arena deve medir 640 × 384 pixels.")
	for metodo in ["obter_inicio", "obter_pontos_itens", "obter_nascedouros"]:
		exigir(arena.has_method(metodo), "Consulta obrigatória ausente: " + metodo)
	if falhas > 0:
		arena.queue_free()
		terminar()
		return
	var limites := Rect2(32, 32, 576, 320)
	var inicio: Vector2 = arena.obter_inicio()
	exigir(limites.has_point(inicio), "Início deve estar dentro da arena.")
	exigir(livre(arena, inicio), "Início precisa estar livre para o jogador.")
	for dados in [[arena.obter_pontos_itens(), 8, "itens"], [arena.obter_nascedouros(), 4, "nascedouros"]]:
		var pontos: Array = dados[0]
		exigir(pontos.size() >= dados[1], "Quantidade insuficiente de " + dados[2])
		var posicoes: Array[Vector2] = []
		for ponto in pontos:
			exigir(ponto is Marker2D, "Cada ponto deve ser um Marker2D.")
			if ponto is Marker2D:
				exigir(limites.has_point(ponto.global_position), "Ponto fora dos limites: " + ponto.name)
				exigir(livre(arena, ponto.global_position), "Ponto bloqueado: " + ponto.name)
				exigir(not posicoes.has(ponto.global_position), "Pontos repetidos: " + ponto.name)
				posicoes.append(ponto.global_position)
	# Amostrar todo o perímetro detecta buracos de uma célula.
	for x in range(8, 640, 16):
		exigir(not livre(arena, Vector2(x, 8), 1), "Borda superior aberta.")
		exigir(not livre(arena, Vector2(x, 376), 1), "Borda inferior aberta.")
	for y in range(8, 384, 16):
		exigir(not livre(arena, Vector2(8, y), 1), "Borda esquerda aberta.")
		exigir(not livre(arena, Vector2(632, y), 1), "Borda direita aberta.")
	for ponto in [Vector2(88, 168), Vector2(552, 200), Vector2(192, 96)]:
		exigir(not livre(arena, ponto, 1), "Água/pedra precisa colidir no mundo: " + str(ponto))
	for y in range(128, 257, 32):
		for x in range(256, 385, 32):
			exigir(livre(arena, Vector2(x, y)), "Centro deve continuar transitável.")
	exigir(arena.get_node_or_null("Chao") is TileMapLayer, "Chão precisa usar TileMapLayer.")
	arena.queue_free()
	var principal := load("res://scenes/principal.tscn") as PackedScene
	exigir(principal != null, "Cena principal precisa existir.")
	if principal != null:
		var jogo := principal.instantiate()
		root.add_child(jogo)
		for nome in ["Atores", "Itens"]:
			exigir(jogo.get_node("Arena").get_node_or_null(nome) is Node2D, "Contêiner reservado ausente: " + nome)
		for nome in ["Horda", "NascimentoItens"]:
			var timer := jogo.get_node("Arena").get_node_or_null(nome) as Timer
			exigir(timer != null, "Timer reservado ausente: " + nome)
			if timer != null:
				exigir(timer.is_stopped() and not timer.autostart, "Timer deve iniciar inativo: " + nome)
		jogo.queue_free()
	terminar()

func terminar() -> void:
	print("Arena: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas > 0 else 0)
