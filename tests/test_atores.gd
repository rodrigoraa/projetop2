# Testes funcionais criados com assistência de IA; cenas e física reais.
extends SceneTree

var falhas := 0
var verificacoes := 0
var mortes := 0
var vidas: Array[int] = []

func _initialize() -> void:
	call_deferred("executar")

func exigir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func quadros(total: int) -> void:
	for i in range(total):
		await physics_frame
	# Observar o resultado depois do processamento físico do último quadro.
	await process_frame

func mover(jogador: CharacterBody2D, inicio: Vector2, acoes: Array[String], total: int) -> Vector2:
	jogador.reiniciar(inicio)
	for acao in acoes:
		Input.action_press(acao)
	await quadros(total)
	for acao in acoes:
		Input.action_release(acao)
	return jogador.global_position - inicio

func executar() -> void:
	for arquivo in ["res://entities/jogador.tscn", "res://entities/sapo.tscn", "res://scripts/principal.gd"]:
		exigir(ResourceLoader.exists(arquivo), "Ator/interface ainda ausente: " + arquivo)
	if falhas > 0:
		terminar()
		return
	var arena := (load("res://scenes/arena.tscn") as PackedScene).instantiate()
	root.add_child(arena)
	var jogador := (load("res://entities/jogador.tscn") as PackedScene).instantiate() as CharacterBody2D
	root.add_child(jogador)
	await quadros(2)
	for acao in ["mover_esquerda", "mover_direita", "mover_cima", "mover_baixo"]:
		var teclas: Array[int] = []
		for evento in InputMap.action_get_events(acao):
			if evento is InputEventKey:
				teclas.append(evento.physical_keycode)
		var esperadas := {"mover_esquerda": [KEY_A, KEY_LEFT], "mover_direita": [KEY_D, KEY_RIGHT], "mover_cima": [KEY_W, KEY_UP], "mover_baixo": [KEY_S, KEY_DOWN]}
		for tecla in esperadas[acao]:
			exigir(teclas.has(tecla), "WASD e setas devem mapear " + acao)
	var horizontal := await mover(jogador, Vector2(280, 160), ["mover_direita"], 30)
	var diagonal := await mover(jogador, Vector2(280, 160), ["mover_direita", "mover_baixo"], 30)
	exigir(horizontal.x > 36 and horizontal.x < 44, "Entrada deve mover a 80 px/s: " + str(horizontal))
	exigir(absf(diagonal.length() / horizontal.length() - 1.0) <= 0.05, "Diagonal deve ter velocidade normalizada.")
	exigir(diagonal.x > 0 and diagonal.y > 0, "Duas ações devem mover ambos os eixos.")
	await mover(jogador, Vector2(48, 64), ["mover_esquerda"], 60)
	exigir(jogador.global_position.x >= 37, "Jogador não pode atravessar borda esquerda.")
	await mover(jogador, Vector2(160, 96), ["mover_direita"], 60)
	exigir(jogador.global_position.x <= 171.1, "Jogador não pode atravessar pedra.")
	jogador.reiniciar(Vector2(320, 192))
	jogador.definir_ativo(false)
	Input.action_press("mover_direita")
	await quadros(12)
	Input.action_release("mover_direita")
	exigir(jogador.global_position.is_equal_approx(Vector2(320, 192)), "Jogador inativo deve parar.")
	jogador.reiniciar(Vector2(320, 192))
	var sapo := (load("res://entities/sapo.tscn") as PackedScene).instantiate() as CharacterBody2D
	arena.get_node("Atores").add_child(sapo)
	sapo.global_position = Vector2(380, 192)
	sapo.definir_alvo(jogador)
	var distancia := sapo.global_position.distance_to(jogador.global_position)
	await quadros(30)
	var reducao := distancia - sapo.global_position.distance_to(jogador.global_position)
	exigir(reducao > 18 and reducao < 22, "Sapo deve perseguir a 40 px/s em chão livre: " + str(reducao))
	sapo.definir_ativo(false)
	var posicao_sapo := sapo.global_position
	await quadros(10)
	exigir(sapo.global_position.is_equal_approx(posicao_sapo), "Sapo inativo deve parar.")
	jogador.vida_alterada.connect(func(vida: int): vidas.append(vida))
	jogador.morreu.connect(func(): mortes += 1)
	sapo.global_position = jogador.global_position
	await quadros(4)
	exigir(jogador.vida == 2, "Contato na hurtbox deve tirar uma vida.")
	exigir(jogador.get_node("Sprite2D").modulate.a < 1.0, "Invencibilidade deve ser visível.")
	await quadros(30)
	exigir(jogador.vida == 2, "Contato contínuo não deve causar dano dentro de 1 s.")
	await quadros(36)
	exigir(jogador.vida == 1, "Contato contínuo deve voltar a causar dano após 1 s.")
	await quadros(65)
	exigir(jogador.vida == 0 and mortes == 1, "Vida zero deve emitir morte uma única vez.")
	jogador.receber_dano()
	await quadros(65)
	exigir(jogador.vida == 0 and mortes == 1, "Morte não pode se repetir nem vida ficar negativa.")
	exigir(vidas == [2, 1, 0], "Sinal de vida deve acompanhar danos: " + str(vidas))
	jogador.reiniciar(Vector2(320, 192))
	exigir(jogador.vida == 3 and jogador.global_position == Vector2(320, 192), "Reinício restaura posição e três vidas.")
	sapo.queue_free()
	await quadros(2)
	arena.iniciar(jogador)
	var timer := arena.get_node("Horda") as Timer
	exigir(not timer.is_stopped() and is_equal_approx(timer.wait_time, 2.0), "Horda inicia com intervalo de 2 s.")
	# Sinal real do Timer permite ultrapassar o limite sem esperar vários minutos.
	timer.timeout.emit()
	exigir(arena.get_node("Atores").get_child_count() == 1, "Timeout precisa criar sapo.")
	exigir(is_equal_approx(timer.wait_time, 1.9), "Intervalo deve multiplicar por 0,95.")
	var primeiro := arena.get_node("Atores").get_child(0) as CharacterBody2D
	exigir(primeiro.global_position.distance_to(jogador.global_position) >= 64.0, "Nascimento precisa ficar a 64 px do jogador.")
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = primeiro.get_node("CollisionShape2D").shape
	consulta.transform = primeiro.global_transform
	consulta.collision_mask = 1
	exigir(arena.get_world_2d().direct_space_state.intersect_shape(consulta).is_empty(), "Sapo deve nascer livre do mundo.")
	for i in range(100):
		timer.timeout.emit()
	exigir(arena.get_node("Atores").get_child_count() == 48, "Horda nunca deve ultrapassar 48 sapos.")
	exigir(timer.wait_time >= 0.8 and is_equal_approx(timer.wait_time, 0.8), "Intervalo deve chegar ao piso de 0,8 s sem ultrapassá-lo.")
	arena.parar()
	exigir(timer.is_stopped(), "Parar deve interromper nascimentos.")
	var posicao_jogador := jogador.global_position
	Input.action_press("mover_direita")
	await quadros(10)
	Input.action_release("mover_direita")
	exigir(jogador.global_position == posicao_jogador, "Parar arena também deve congelar jogador.")
	var posicoes: Array[Vector2] = []
	for ator in arena.get_node("Atores").get_children():
		posicoes.append(ator.global_position)
	await quadros(10)
	for i in range(posicoes.size()):
		exigir(arena.get_node("Atores").get_child(i).global_position == posicoes[i], "Parar deve congelar sapos.")
	timer.timeout.emit()
	exigir(arena.get_node("Atores").get_child_count() == 48, "Arena parada ignora timeout.")
	arena.limpar()
	exigir(arena.get_node("Atores").get_child_count() == 0, "Limpar remove atores anteriores.")
	# Todos os pontos muito perto: adiar nascimento.
	for ponto in arena.obter_nascedouros():
		ponto.global_position = jogador.global_position
	arena.iniciar(jogador)
	timer.timeout.emit()
	exigir(arena.get_node("Atores").get_child_count() == 0, "Sem ponto afastado deve adiar nascimento.")
	# Pontos afastados, porém dentro de uma lagoa: também adiar.
	for ponto in arena.obter_nascedouros():
		ponto.global_position = Vector2(88, 168)
	timer.timeout.emit()
	exigir(arena.get_node("Atores").get_child_count() == 0, "Pontos bloqueados pelo mundo não servem.")
	arena.queue_free()
	jogador.queue_free()
	await quadros(2)
	var jogo := (load("res://scenes/principal.tscn") as PackedScene).instantiate()
	root.add_child(jogo)
	await quadros(2)
	var personagem := jogo.get_node("Jogador") as CharacterBody2D
	exigir(personagem.vida == 3 and not jogo.get_node("Arena/Horda").is_stopped(), "Partida deve iniciar jogador e horda.")
	exigir(jogo.get_node("Interface/Vida").text.contains("3"), "Interface deve apresentar vida inicial.")
	for i in range(3):
		personagem.receber_dano()
		await quadros(61)
	exigir(jogo.get_node("Arena/Horda").is_stopped(), "Morte deve parar partida.")
	exigir(jogo.get_node("Interface/Reiniciar").visible, "Morte deve oferecer reinício.")
	jogo.get_node("Interface/Reiniciar").pressed.emit()
	await quadros(2)
	exigir(personagem.vida == 3 and not jogo.get_node("Arena/Horda").is_stopped(), "Botão deve reiniciar vida e horda.")
	exigir(jogo.get_node("Arena/Atores").get_child_count() == 0, "Reinício deve remover horda anterior.")
	jogo.queue_free()
	await process_frame
	terminar()

func terminar() -> void:
	print("Atores: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas > 0 else 0)
