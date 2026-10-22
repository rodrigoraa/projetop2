# Ciclo da partida implementado com assistência de IA.
class_name PartidaPantano
extends Node2D

enum { INICIO, JOGANDO, VITORIA, DERROTA }

@export var sobrevivencia := false

var estado := INICIO
var coletados := 0
var meta := 20
# Snapshot do Timer somente ao encerrar; não avança como um segundo relógio.
var tempo_restante_final := 60.0

func _ready() -> void:
	$Jogador.vida_alterada.connect(atualizar_hud)
	$Jogador.morreu.connect(ao_morrer)
	$Arena.item_coletado.connect(registrar_coleta)
	$Interface.iniciar_solicitado.connect(iniciar_partida)
	$Interface.reiniciar_solicitado.connect(iniciar_partida)
	$Relogio.timeout.connect(ao_terminar_tempo)
	$Interface.configurar_modo(sobrevivencia)
	$Arena.parar()
	$Jogador.definir_ativo(false)
	$Jogador.global_position = $Arena.obter_inicio()
	atualizar_hud()
	$Interface.mostrar_inicio()

func _process(_delta: float) -> void:
	if sobrevivencia and estado == JOGANDO:
		atualizar_hud()

func iniciar_partida() -> void:
	if estado == JOGANDO:
		return
	$Arena.limpar()
	coletados = 0
	tempo_restante_final = $Relogio.wait_time
	estado = JOGANDO
	if sobrevivencia:
		$Relogio.start()
	$Jogador.reiniciar($Arena.obter_inicio())
	$Interface.ocultar_telas()
	atualizar_hud()
	$Arena.iniciar($Jogador, not sobrevivencia)

func registrar_coleta() -> void:
	if estado != JOGANDO or sobrevivencia:
		return
	coletados += 1
	atualizar_hud()
	if coletados >= meta:
		encerrar(true)

func atualizar_hud(_vida: int = 0) -> void:
	var restante: float = $Relogio.time_left if estado == JOGANDO and sobrevivencia else tempo_restante_final
	$Interface.atualizar_hud($Jogador.vida, coletados, meta, ceili(restante))

func ao_morrer() -> void:
	encerrar(false)

func ao_terminar_tempo() -> void:
	if sobrevivencia and estado == JOGANDO and $Relogio.time_left <= 0.0:
		encerrar(true)

func encerrar(venceu: bool) -> void:
	if estado != JOGANDO:
		return
	# Sobrevivência só vence quando o Timer termina, inclusive em chamadas tardias.
	if sobrevivencia and venceu and $Relogio.time_left > 0.0:
		return
	if sobrevivencia:
		tempo_restante_final = $Relogio.time_left
	# Trava o resultado antes de parar atores/timers e processar sinais tardios.
	estado = VITORIA if venceu else DERROTA
	$Relogio.stop()
	$Arena.parar()
	atualizar_hud()
	var sobrevivido := floori($Relogio.wait_time - tempo_restante_final)
	$Interface.mostrar_resultado(venceu, coletados, sobrevivido)
