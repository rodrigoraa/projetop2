# Interface em português criada com assistência de IA; ícones Ninja Adventure (CC0).
class_name InterfacePantano
extends CanvasLayer

signal iniciar_solicitado
signal reiniciar_solicitado

var sobrevivencia := false

const CORACAO := preload("res://sprites/ninja-adventure/Ui/LifeReceptacle/heart.png")

func _ready() -> void:
	var tema := Theme.new()
	tema.default_font_size = 15
	tema.set_color("font_color", "Label", Color("f1f4dd"))
	tema.set_color("font_color", "Button", Color("14251b"))
	tema.set_color("font_focus_color", "Button", Color("14251b"))
	tema.set_color("font_hover_color", "Button", Color("14251b"))
	tema.set_color("font_pressed_color", "Button", Color("14251b"))
	tema.set_stylebox("normal", "Button", caixa(Color("c8e49a"), Color("c8e49a"), 1))
	tema.set_stylebox("hover", "Button", caixa(Color("e1f3b9"), Color("e1f3b9"), 1))
	tema.set_stylebox("pressed", "Button", caixa(Color("9fc17b"), Color("9fc17b"), 1))
	var foco := caixa(Color.TRANSPARENT, Color("ffffff"), 2)
	foco.expand_margin_left = 3
	foco.expand_margin_right = 3
	foco.expand_margin_top = 3
	foco.expand_margin_bottom = 3
	tema.set_stylebox("focus", "Button", foco)
	tema.set_stylebox("panel", "PanelContainer", caixa(Color("172b22"), Color("729668"), 1))
	for controle in [$HUD, $Inicio, $Resultado]:
		controle.theme = tema
	var fundo_hud := caixa(Color("12221d"), Color("425a3c"), 0)
	fundo_hud.content_margin_top = 3
	fundo_hud.content_margin_bottom = 3
	fundo_hud.content_margin_left = 12
	fundo_hud.content_margin_right = 12
	$HUD.add_theme_stylebox_override("panel", fundo_hud)
	var quadro_coracao := AtlasTexture.new()
	quadro_coracao.atlas = CORACAO
	quadro_coracao.region = Rect2(64, 0, 16, 16)
	for i in range(3):
		var icone := TextureRect.new()
		icone.texture = quadro_coracao
		icone.custom_minimum_size = Vector2(16, 16)
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		$HUD/Linha/Coracoes.add_child(icone)
	$Inicio/Cartao/Conteudo/Iniciar.pressed.connect(func(): iniciar_solicitado.emit())
	$Resultado/Cartao/Conteudo/Reiniciar.pressed.connect(func(): reiniciar_solicitado.emit())

func caixa(fundo: Color, borda: Color, largura: int) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = fundo
	estilo.border_color = borda
	estilo.set_border_width_all(largura)
	estilo.set_corner_radius_all(4)
	estilo.content_margin_left = 20
	estilo.content_margin_right = 20
	estilo.content_margin_top = 16
	estilo.content_margin_bottom = 16
	return estilo

func configurar_modo(modo_sobrevivencia: bool) -> void:
	sobrevivencia = modo_sobrevivencia
	$HUD/Linha/Folha.visible = not sobrevivencia
	$HUD/Linha/Itens.visible = not sobrevivencia
	$HUD/Linha/Tempo.visible = sobrevivencia
	$Inicio/Cartao/Conteudo/Objetivo/Folha.visible = not sobrevivencia
	$Inicio/Cartao/Conteudo/Modo.text = "SOBREVIVÊNCIA  •  MODO HORDA" if sobrevivencia else "COLETA  •  MODO HORDA"
	$Inicio/Cartao/Conteudo/Objetivo/Texto.text = "Sobreviva por 60 segundos" if sobrevivencia else "Reúna 20 folhas para vencer"

func mostrar_inicio() -> void:
	$Resultado.hide()
	$Inicio.show()
	$Inicio/Cartao/Conteudo/Iniciar.grab_focus()

func ocultar_telas() -> void:
	$Inicio.hide()
	$Resultado.hide()

func atualizar_hud(vida: int, coletados: int, meta: int, tempo_restante: int = 60) -> void:
	$HUD/Linha/Vida.text = "Vidas: %d" % vida
	$HUD/Linha/Itens.text = "Itens: %d / %d" % [coletados, meta]
	$HUD/Linha/Tempo.text = "Tempo: %d s" % tempo_restante
	for i in range($HUD/Linha/Coracoes.get_child_count()):
		$HUD/Linha/Coracoes.get_child(i).modulate.a = 1.0 if i < vida else 0.2

func mostrar_resultado(venceu: bool, coletados: int, tempo_sobrevivido: int = 0) -> void:
	$Inicio.hide()
	$Resultado/Cartao/Conteudo/Titulo.text = "Vitória!" if venceu else "Fim de jogo"
	$Resultado/Cartao/Conteudo/Resumo.text = "Você reuniu as 20 folhas!" if venceu else "Os sapos alcançaram você."
	$Resultado/Cartao/Conteudo/Contagem.text = "Itens coletados: %d / 20" % coletados
	if sobrevivencia:
		$Resultado/Cartao/Conteudo/Resumo.text = "Você sobreviveu aos 60 segundos!" if venceu else "Os sapos alcançaram você."
		$Resultado/Cartao/Conteudo/Contagem.text = "Tempo sobrevivido: %d s" % tempo_sobrevivido
	$Resultado.show()
	$Resultado/Cartao/Conteudo/Reiniciar.grab_focus()
