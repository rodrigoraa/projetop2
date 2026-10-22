# Conexão provisória da partida implementada com assistência de IA.
extends Node2D

func _ready() -> void:
	$Jogador.vida_alterada.connect(atualizar_vida)
	$Jogador.morreu.connect(encerrar_partida)
	$Interface/Reiniciar.pressed.connect(reiniciar)
	reiniciar()

func reiniciar() -> void:
	$Arena.limpar()
	$Jogador.reiniciar($Arena.obter_inicio())
	$Interface/Reiniciar.hide()
	$Interface/Mensagem.hide()
	$Arena.iniciar($Jogador)

func atualizar_vida(vida: int) -> void:
	$Interface/Vida.text = "Vidas: %d" % vida

func encerrar_partida() -> void:
	$Arena.parar()
	$Interface/Mensagem.show()
	$Interface/Reiniciar.show()
	$Interface/Reiniciar.grab_focus()
