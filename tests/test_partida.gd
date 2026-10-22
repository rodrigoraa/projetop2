# Testes do ciclo completo criados com assistência de IA; cenas e física reais.
extends SceneTree

var falhas := 0
var verificacoes := 0
var resultados := 0
var sinais_itens := 0

func _initialize() -> void:
	call_deferred("executar")

func exigir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func quadros(total: int = 3) -> void:
	for i in range(total):
		await physics_frame
	await process_frame

func luminancia(cor: Color) -> float:
	var linear := cor.srgb_to_linear()
	return linear.r * 0.2126 + linear.g * 0.7152 + linear.b * 0.0722

func conferir_timers(arena: Node, parados: bool) -> void:
	for nome in ["Horda", "NascimentoItens"]:
		exigir(arena.get_node(nome).is_stopped() == parados, "%s: timer %s" % ["parado" if parados else "ativo", nome])

func coletar(jogo: Node) -> void:
	var arena := jogo.get_node("Arena")
	if arena.get_node("Itens").get_child_count() == 0:
		arena.get_node("NascimentoItens").timeout.emit()
	var item := arena.get_node("Itens").get_child(0) as Area2D
	var anterior: int = jogo.coletados
	item.coletado.connect(func(_item: Area2D): sinais_itens += 1)
	jogo.get_node("Jogador").global_position = item.global_position
	await quadros(4)
	exigir(jogo.coletados == anterior + 1, "Contato físico deve contabilizar exatamente um item.")
	exigir(not is_instance_valid(item), "Item coletado precisa sair da árvore.")

func executar() -> void:
	var jogo := (load("res://scenes/principal.tscn") as PackedScene).instantiate()
	root.add_child(jogo)
	await quadros()
	var arena := jogo.get_node("Arena")
	conferir_timers(arena, true)
	exigir(not jogo.get_node("Jogador").ativo, "Tela inicial deve manter jogador inativo.")
	for metodo in ["iniciar_partida", "registrar_coleta", "encerrar"]:
		exigir(jogo.has_method(metodo), "Contrato da partida ausente: " + metodo)
	for arquivo in ["res://entities/item.tscn", "res://scenes/interface.tscn"]:
		exigir(ResourceLoader.exists(arquivo), "Cena obrigatória ausente: " + arquivo)
	if falhas > 0:
		jogo.queue_free()
		await process_frame
		terminar()
		return
	var interface := jogo.get_node("Interface")
	var painel := interface.get_node("Resultado") as Control
	painel.visibility_changed.connect(func():
		if painel.visible:
			resultados += 1)
	exigir(jogo.estado == jogo.INICIO and jogo.meta == 20 and jogo.coletados == 0, "Estado inicial e meta devem estar definidos.")
	exigir(interface.get_node("Inicio").visible, "Tela inicial precisa aparecer.")
	exigir(interface.get_node("Inicio/Cartao/Conteudo/Iniciar").has_focus(), "Iniciar deve receber foco de teclado.")
	var iniciar := interface.get_node("Inicio/Cartao/Conteudo/Iniciar") as Button
	var texto := luminancia(iniciar.get_theme_color("font_focus_color"))
	var fundo := luminancia(iniciar.get_theme_stylebox("normal").bg_color)
	exigir((maxf(texto, fundo) + 0.05) / (minf(texto, fundo) + 0.05) >= 4.5, "Botão focado precisa de contraste legível.")
	for icone in interface.get_node("HUD/Linha/Coracoes").get_children():
		exigir(icone.texture.get_size() == Vector2(16, 16), "Coração deve exibir um quadro quadrado, sem comprimir a folha de sprites.")
	interface.get_node("Inicio/Cartao/Conteudo/Iniciar").pressed.emit()
	conferir_timers(arena, false)
	exigir(jogo.estado == jogo.JOGANDO and not interface.get_node("Inicio").visible, "Botão deve iniciar partida.")
	exigir(arena.get_node("Itens").get_child_count() == 1, "Cada partida começa com um item.")
	exigir(is_equal_approx(arena.get_node("NascimentoItens").wait_time, 3.0), "Itens nascem a cada três segundos.")
	# Isolar a coleta da pressão da horda, depois de comprovar os dois timers ativos.
	arena.get_node("Horda").stop()
	var primeiro := arena.get_node("Itens").get_child(0) as Area2D
	exigir(primeiro.collision_layer == 0 and primeiro.collision_mask == 2, "Itens detectam somente a camada do jogador.")
	var sapo := (load("res://entities/sapo.tscn") as PackedScene).instantiate()
	arena.get_node("Atores").add_child(sapo)
	sapo.global_position = primeiro.global_position
	sapo.definir_ativo(false)
	await quadros()
	exigir(not primeiro.foi_coletado and jogo.coletados == 0, "Sapos não podem coletar itens.")
	sapo.queue_free()
	await quadros()
	# Contrato público da arena: parar congela itens; iniciar também os reativa.
	arena.parar()
	conferir_timers(arena, true)
	exigir(not primeiro.ativo, "Parar deve desativar coleta dos itens existentes.")
	arena.iniciar(jogo.get_node("Jogador"))
	await quadros()
	conferir_timers(arena, false)
	exigir(primeiro.ativo and primeiro.monitoring, "Iniciar deve reativar a coleta dos itens existentes.")
	exigir(arena.get_node("Itens").get_child_count() == 1, "Retomar arena não duplica o item inicial.")
	arena.get_node("Horda").stop()
	# Lotar todos os pontos: sem empilhamento nem alteração de posições.
	for i in range(arena.obter_pontos_itens().size() + 2):
		arena.get_node("NascimentoItens").timeout.emit()
	var posicoes: Array[Vector2] = []
	for item in arena.get_node("Itens").get_children():
		exigir(not posicoes.has(item.global_position), "Cada ponto recebe somente um item.")
		posicoes.append(item.global_position)
	exigir(posicoes.size() == arena.obter_pontos_itens().size(), "Todos os pontos devem poder ser ocupados.")
	arena.get_node("NascimentoItens").timeout.emit()
	var depois: Array[Vector2] = []
	for item in arena.get_node("Itens").get_children():
		depois.append(item.global_position)
	exigir(depois == posicoes, "Tick lotado não altera contagem nem posições.")
	var liberado := arena.get_node("Itens").get_child(0).global_position as Vector2
	await coletar(jogo)
	jogo.get_node("Jogador").global_position = arena.obter_inicio()
	await quadros()
	arena.get_node("NascimentoItens").timeout.emit()
	exigir(arena.get_node("Itens").get_child_count() == posicoes.size(), "Coleta libera o ponto para novo nascimento.")
	exigir(arena.get_node("Itens").get_child(-1).global_position == liberado, "Único ponto livre deve ser reutilizado.")
	for i in range(18):
		await coletar(jogo)
	exigir(jogo.coletados == 19 and jogo.estado == jogo.JOGANDO and not painel.visible, "Em dezenove itens a partida continua.")
	await coletar(jogo)
	exigir(sinais_itens == 20, "Cada um dos vinte contatos emite coleta uma única vez.")
	exigir(jogo.estado == jogo.VITORIA and painel.visible and resultados == 1, "Vinte itens encerram com vitória única.")
	exigir(interface.get_node("Resultado/Cartao/Conteudo/Titulo").text.contains("Vitória"), "Vitória aparece em português.")
	conferir_timers(arena, true)
	var restantes := arena.get_node("Itens").get_child_count()
	jogo.registrar_coleta()
	jogo.encerrar(false)
	arena.item_coletado.emit()
	arena.get_node("NascimentoItens").timeout.emit()
	arena.get_node("Horda").timeout.emit()
	jogo.get_node("Jogador").receber_dano()
	await quadros()
	exigir(jogo.estado == jogo.VITORIA and jogo.coletados == 20 and resultados == 1, "Eventos tardios não alteram vitória/contador nem repetem resultado.")
	exigir(arena.get_node("Itens").get_child_count() == restantes, "Resultado congela nascimento de itens.")
	# Duas derrotas e reinícios exercitam limpeza e ausência de conexões duplicadas.
	for rodada in range(2):
		var antigos: Array = arena.get_node("Itens").get_children() + arena.get_node("Atores").get_children()
		interface.get_node("Resultado/Cartao/Conteudo/Reiniciar").pressed.emit()
		await quadros()
		conferir_timers(arena, false)
		exigir(jogo.estado == jogo.JOGANDO and jogo.coletados == 0 and jogo.get_node("Jogador").vida == 3, "Reinício restaura estado, contador e vida.")
		exigir(arena.get_node("Atores").get_child_count() == 0 and arena.get_node("Itens").get_child_count() == 1, "Reinício limpa atores/itens e cria somente o item inicial.")
		for antigo in antigos:
			exigir(not is_instance_valid(antigo), "Reinício não deixa instâncias antigas órfãs.")
		var jogadores := 0
		for filho in jogo.get_children():
			if filho is CharacterBody2D:
				jogadores += 1
		exigir(jogadores == 1, "Reinício mantém exatamente um jogador.")
		await coletar(jogo)
		exigir(jogo.coletados == 1, "Após reinício não pode haver conexão duplicada de coleta.")
		arena.get_node("Horda").stop()
		var inimigo := (load("res://entities/sapo.tscn") as PackedScene).instantiate()
		arena.get_node("Atores").add_child(inimigo)
		inimigo.global_position = jogo.get_node("Jogador").global_position
		inimigo.definir_ativo(false)
		await quadros(135)
		exigir(jogo.get_node("Jogador").vida == 0 and jogo.estado == jogo.DERROTA, "Contato físico contínuo deve terminar em derrota.")
		exigir(resultados == rodada + 2 and painel.visible, "Cada derrota apresenta resultado somente uma vez.")
		exigir(interface.get_node("Resultado/Cartao/Conteudo/Reiniciar").has_focus(), "Recomeçar recebe foco de teclado.")
		conferir_timers(arena, true)
		jogo.registrar_coleta()
		jogo.encerrar(true)
		exigir(jogo.estado == jogo.DERROTA and jogo.coletados == 1, "Eventos tardios preservam derrota e contagem.")
	# Uma nova vitória depois de duas derrotas confirma o ciclo completo repetido.
	interface.get_node("Resultado/Cartao/Conteudo/Reiniciar").pressed.emit()
	await quadros()
	conferir_timers(arena, false)
	arena.get_node("Horda").stop()
	for i in range(20):
		await coletar(jogo)
	exigir(jogo.estado == jogo.VITORIA and jogo.coletados == 20 and resultados == 4, "Nova vitória mantém emissão única depois de múltiplos reinícios.")
	conferir_timers(arena, true)
	# Reiniciar no último ponto visitado não pode coletar à distância por contato antigo.
	var ultima_posicao := jogo.get_node("Jogador").global_position as Vector2
	for ponto in arena.obter_pontos_itens():
		if ponto.global_position != ultima_posicao:
			ponto.queue_free()
	await quadros()
	interface.get_node("Resultado/Cartao/Conteudo/Reiniciar").pressed.emit()
	await quadros()
	exigir(jogo.coletados == 0 and arena.get_node("Itens").get_child_count() == 1, "Teleporte do reinício não deve gerar coleta por contato da partida anterior.")
	jogo.queue_free()
	await quadros()
	terminar()

func terminar() -> void:
	print("Partida: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas > 0 else 0)
