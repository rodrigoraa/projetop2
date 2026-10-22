# Ciclo da partida implementado com assistência de IA.
class_name PartidaPantano
extends Node2D

enum { INICIO, JOGANDO, VITORIA, DERROTA }

var estado := INICIO
var coletados := 0
var meta := 20

func _ready() -> void:
	$Jogador.vida_alterada.connect(atualizar_hud)
	$Jogador.morreu.connect(ao_morrer)
	$Arena.item_coletado.connect(registrar_coleta)
	$Interface.iniciar_solicitado.connect(iniciar_partida)
	$Interface.reiniciar_solicitado.connect(iniciar_partida)
	$Arena.parar()
	$Jogador.definir_ativo(false)
	$Jogador.global_position = $Arena.obter_inicio()
	atualizar_hud()
	$Interface.mostrar_inicio()

func iniciar_partida() -> void:
	if estado == JOGANDO:
		return
	$Arena.limpar()
	coletados = 0
	estado = JOGANDO
	$Jogador.reiniciar($Arena.obter_inicio())
	$Interface.ocultar_telas()
	atualizar_hud()
	$Arena.iniciar($Jogador)

func registrar_coleta() -> void:
	if estado != JOGANDO:
		return
	coletados += 1
	atualizar_hud()
	if coletados >= meta:
		encerrar(true)

func atualizar_hud(_vida: int = 0) -> void:
	$Interface.atualizar_hud($Jogador.vida, coletados, meta)

func ao_morrer() -> void:
	encerrar(false)

func encerrar(venceu: bool) -> void:
	if estado != JOGANDO:
		return
	# Trava o resultado antes de parar atores/timers e processar sinais tardios.
	estado = VITORIA if venceu else DERROTA
	$Arena.parar()
	$Interface.mostrar_resultado(venceu, coletados)
