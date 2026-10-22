# Sobrevivência Aula 09 verificada com assistência de IA; cenas, timers e física reais.
extends SceneTree

const CENA := "res://scenes/aula09_sobrevivencia.tscn"
var falhas := 0
var verificacoes := 0
var resultados := 0

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

func confirmar(tecla: Key) -> void:
	var evento := InputEventKey.new()
	evento.keycode = tecla
	evento.pressed = true
	root.push_input(evento)
	await quadros()
	evento = InputEventKey.new()
	evento.keycode = tecla
	root.push_input(evento)
	await quadros()

func conferir_interface(interface: Node) -> void:
	for caminho in ["HUD/Linha/Folha", "HUD/Linha/Itens", "Inicio/Cartao/Conteudo/Objetivo/Folha"]:
		exigir(not interface.get_node(caminho).visible, "Sobrevivência oculta folhas/contador: " + caminho)
	for painel in ["Inicio", "Resultado"]:
		if not interface.get_node(painel).visible:
			continue
		for controle in interface.get_node(painel + "/Cartao/Conteudo").get_children():
			if controle is Control and controle.visible:
				var retangulo: Rect2 = controle.get_global_rect()
				exigir(Rect2(0, 0, 640, 384).encloses(retangulo), "Texto/botão cabe em 640x384: " + str(controle.name))
				if controle is Label:
					exigir(controle.get_minimum_size().x <= controle.size.x, "Texto não corta horizontalmente: " + str(controle.name))

func conferir_parada(jogo: Node) -> void:
	for caminho in ["Relogio", "Arena/Horda", "Arena/NascimentoItens"]:
		exigir(jogo.get_node(caminho).is_stopped(), "Resultado/início para timer " + caminho)

func eventos_tardios(jogo: Node) -> void:
	jogo.registrar_coleta()
	jogo.get_node("Arena").item_coletado.emit()
	jogo.get_node("Arena").nascer_item()
	jogo.get_node("Arena/NascimentoItens").timeout.emit()
	jogo.get_node("Arena/Horda").timeout.emit()
	jogo.get_node("Relogio").timeout.emit()
	jogo.get_node("Jogador").receber_dano()
	jogo.get_node("Jogador").morreu.emit()

func executar() -> void:
	exigir(ResourceLoader.exists(ProjectSettings.get_setting("application/run/main_scene")), "F5 abre uma cena válida do projeto.")
	exigir(ResourceLoader.exists(CENA), "Cena Aula 09 deve existir e reutilizar a partida.")
	if not ResourceLoader.exists(CENA):
		terminar()
		return
	var jogo := (load(CENA) as PackedScene).instantiate()
	root.add_child(jogo)
	await quadros()
	var arena := jogo.get_node("Arena")
	var jogador := jogo.get_node("Jogador")
	var interface := jogo.get_node("Interface")
	var relogio := jogo.get_node("Relogio") as Timer
	var tempo := interface.get_node("HUD/Linha/Tempo") as Label
	var painel := interface.get_node("Resultado") as Control
	painel.visibility_changed.connect(func():
		if painel.visible:
			resultados += 1)
	exigir(jogo.sobrevivencia and jogo.estado == jogo.INICIO, "Cena usa modo sobrevivência e inicia na apresentação.")
	exigir(relogio.one_shot and is_equal_approx(relogio.wait_time, 60.0), "Relógio é one-shot de 60 segundos.")
	conferir_parada(jogo)
	exigir(not jogador.ativo and jogador.vida == 3, "Início parado com três vidas.")
	exigir(tempo.visible and tempo.text == "Tempo: 60 s", "HUD começa com 60 segundos.")
	exigir(interface.get_node("Inicio/Cartao/Conteudo/Objetivo/Texto").text.contains("60"), "Objetivo explica os 60 segundos.")
	exigir(interface.get_node("Inicio/Cartao/Conteudo/Iniciar").has_focus(), "Iniciar recebe foco.")
	conferir_interface(interface)
	await quadros(65)
	exigir(tempo.text == "Tempo: 60 s" and jogo.estado == jogo.INICIO, "Tempo não corre na apresentação.")
	await confirmar(KEY_ENTER)
	exigir(jogo.estado == jogo.JOGANDO and not interface.get_node("Inicio").visible, "Enter inicia o jogo pelo botão focado.")
	exigir(not relogio.is_stopped() and not arena.get_node("Horda").is_stopped(), "Partida inicia relógio e horda.")
	exigir(arena.get_node("NascimentoItens").is_stopped() and arena.get_node("Itens").get_child_count() == 0, "Sobrevivência não inicia itens.")
	for i in range(25):
		jogo.registrar_coleta()
		arena.item_coletado.emit()
	arena.nascer_item()
	arena.get_node("NascimentoItens").timeout.emit()
	exigir(jogo.coletados == 0 and jogo.estado == jogo.JOGANDO, "Coleta nunca altera contador ou vence sobrevivência.")
	exigir(arena.get_node("Itens").get_child_count() == 0, "Chamadas diretas/sinais tardios não criam itens durante jogo.")
	# Dano continua vindo do contato físico real e respeita invencibilidade.
	arena.get_node("Horda").stop()
	var inimigo := (load("res://entities/sapo.tscn") as PackedScene).instantiate()
	arena.get_node("Atores").add_child(inimigo)
	inimigo.global_position = jogador.global_position
	inimigo.definir_ativo(false)
	await quadros(5)
	exigir(jogador.vida == 2 and jogo.estado == jogo.JOGANDO, "Primeiro contato físico tira somente uma vida.")
	exigir(interface.get_node("HUD/Linha/Vida").text == "Vidas: 2", "HUD acompanha dano físico.")
	await quadros(130)
	exigir(jogador.vida == 0 and jogo.estado == jogo.DERROTA and resultados == 1, "Três danos físicos encerram em derrota única.")
	conferir_parada(jogo)
	var restante_derrota := int(tempo.text.trim_prefix("Tempo: ").trim_suffix(" s"))
	var sobrevivido := 60 - restante_derrota
	exigir(sobrevivido == 2, "Derrota física após cerca de dois segundos relata dois segundos completos.")
	var contagem := interface.get_node("Resultado/Cartao/Conteudo/Contagem") as Label
	exigir(contagem.text == "Tempo sobrevivido: %d s" % sobrevivido, "Derrota relata segundos completos derivados do Timer.")
	exigir(tempo.text == "Tempo: %d s" % restante_derrota, "Derrota preserva contagem regressiva coerente.")
	var texto_derrota := contagem.text
	var tempo_derrota := tempo.text
	conferir_interface(interface)
	eventos_tardios(jogo)
	jogo.encerrar(true)
	await quadros(65)
	exigir(jogo.estado == jogo.DERROTA and resultados == 1 and jogo.coletados == 0, "Eventos tardios preservam derrota e contador.")
	exigir(contagem.text == texto_derrota and tempo.text == tempo_derrota, "Resultado/tempo ficam congelados após derrota.")
	# Reinício pela tecla Espaço; vitória aguarda 3600 quadros naturais a 60 FPS.
	var antigos := arena.get_node("Atores").get_children()
	exigir(interface.get_node("Resultado/Cartao/Conteudo/Reiniciar").has_focus(), "Reiniciar recebe foco.")
	await confirmar(KEY_SPACE)
	exigir(jogo.estado == jogo.JOGANDO and jogador.vida == 3, "Espaço reinicia e restaura três vidas.")
	exigir(tempo.text == "Tempo: 60 s" and relogio.time_left > 59.8, "Reinício restaura 60 segundos completos.")
	for antigo in antigos:
		exigir(not is_instance_valid(antigo), "Reinício remove instâncias antigas.")
	exigir(arena.get_node("Atores").get_child_count() == 0 and arena.get_node("Itens").get_child_count() == 0, "Reinício começa sem sapos/itens antigos.")
	# Reiniciar após encerrar fornece a fronteira exata para medir a duração natural.
	jogo.encerrar(false)
	jogo.iniciar_partida()
	exigir(relogio.time_left == 60.0 and tempo.text == "Tempo: 60 s", "Reinício síncrono dá Timer e HUD exatamente 60.")
	jogador.definir_ativo(false)
	await quadros(119)
	exigir(jogo.estado == jogo.JOGANDO and tempo.text == "Tempo: 59 s", "Contagem regressiva arredonda fração de segundo para cima.")
	await quadros(6)
	exigir(tempo.text == "Tempo: 58 s", "Contagem regressiva atualiza durante a partida.")
	exigir(arena.get_node("Atores").get_child_count() > 0, "Horda produz sapos pelo timeout natural.")
	exigir(arena.get_node("NascimentoItens").is_stopped() and arena.get_node("Itens").get_child_count() == 0, "Sem itens mesmo após tempo natural.")
	await quadros(3474)
	exigir(jogo.estado == jogo.JOGANDO and tempo.text == "Tempo: 1 s", "Em 3599 quadros ainda falta um segundo exibido; vitória não vem cedo.")
	exigir(arena.get_node("Atores").get_child_count() == 48, "Horda natural alcança e respeita o limite 48.")
	await quadros(1)
	# Timer usa ponto flutuante: timeout pode precisar do próximo passo físico.
	if jogo.estado == jogo.JOGANDO:
		await quadros(1)
	exigir(jogo.estado == jogo.VITORIA and resultados == 3, "60 segundos naturais vencem, sem emitir timeout no teste de duração.")
	exigir(tempo.text == "Tempo: 0 s" and contagem.text == "Tempo sobrevivido: 60 s", "Vitória mostra zero restante e 60 sobrevividos.")
	exigir(interface.get_node("Resultado/Cartao/Conteudo/Resumo").text.contains("60"), "Resultado de sobrevivência informa objetivo cumprido.")
	conferir_parada(jogo)
	conferir_interface(interface)
	var total_sapos := arena.get_node("Atores").get_child_count()
	eventos_tardios(jogo)
	jogo.encerrar(false)
	await quadros()
	exigir(jogo.estado == jogo.VITORIA and resultados == 3 and jogador.vida == 3, "Eventos tardios preservam vitória e vidas.")
	exigir(arena.get_node("Atores").get_child_count() == total_sapos and arena.get_node("Itens").get_child_count() == 0, "Nenhum nascimento depois da vitória.")
	antigos = arena.get_node("Atores").get_children()
	interface.get_node("Resultado/Cartao/Conteudo/Reiniciar").pressed.emit()
	exigir(jogador.vida == 3 and relogio.time_left == 60.0 and tempo.text == "Tempo: 60 s", "Reinício após vitória restaura três vidas e 60 segundos.")
	await quadros()
	for antigo in antigos:
		exigir(not is_instance_valid(antigo), "Reinício após vitória elimina sapo antigo.")
	exigir(arena.get_node("Atores").get_child_count() == 0 and arena.get_node("Itens").get_child_count() == 0, "Reinício não deixa instâncias antigas.")
	jogo.queue_free()
	await quadros()
	terminar()

func terminar() -> void:
	print("Sobrevivência: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas > 0 else 0)
