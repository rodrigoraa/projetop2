extends Node2D

@export var portas: Array[Vector2] = []
var perto_porta := -1
var casa_atual := -1
var perto_saida := false
var dica: Label
@onready var jogador: CharacterBody2D = get_parent().get_node("Jogador")
@onready var interior: Node2D = $Interior
@onready var camera: Camera2D = $Interior/Camera2D

func _ready() -> void:
	interior.hide()
	for i in range(portas.size()):
		var area := Area2D.new()
		area.name = "Porta%d" % (i+1)
		area.position = portas[i]
		area.collision_layer = 0
		area.collision_mask = 2
		var colisor := CollisionShape2D.new()
		var forma := RectangleShape2D.new()
		forma.size = Vector2(24,24)
		colisor.shape = forma
		area.add_child(colisor)
		add_child(area)
		area.body_entered.connect(_aproximou.bind(i))
		area.body_exited.connect(_afastou.bind(i))
	$Interior/Saida.body_entered.connect(_aproximou_saida)
	$Interior/Saida.body_exited.connect(_afastou_saida)
	dica = Label.new()
	dica.name = "DicaAbrigo"
	dica.position = Vector2(0,700)
	dica.size = Vector2(1280,32)
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dica.add_theme_font_size_override("font_size",22)
	dica.add_theme_color_override("font_color",Color(1,0.9,0.65))
	dica.add_theme_color_override("font_shadow_color",Color.BLACK)
	dica.add_theme_constant_override("shadow_offset_x",2)
	dica.add_theme_constant_override("shadow_offset_y",2)
	get_parent().get_node("HUD").add_child(dica)

func _process(_delta: float) -> void:
	if get_parent().finalizada:
		dica.hide()
		return
	dica.visible = jogador.escondido or perto_porta >= 0
	if jogador.escondido:
		dica.text = "E — sair da casa" if perto_saida else "Você está escondido. A porta fica ao sul."
	elif perto_porta >= 0:
		dica.text = "E — entrar na casa"
	if Input.is_action_just_pressed("interagir"):
		if jogador.escondido and perto_saida:
			sair()
		elif not jogador.escondido and perto_porta >= 0:
			entrar(perto_porta)

func entrar(indice: int) -> void:
	if jogador.escondido or indice < 0 or indice >= portas.size():
		return
	casa_atual = indice
	jogador.escondido = true
	jogador.velocity = Vector2.ZERO
	interior.show()
	jogador.global_position = interior.global_position + Vector2(160,140)
	camera.enabled = true
	camera.make_current()

func sair() -> void:
	if casa_atual < 0:
		return
	jogador.global_position = portas[casa_atual] + Vector2(0,6)
	jogador.velocity = Vector2.ZERO
	jogador.escondido = false
	camera.enabled = false
	(jogador.get_node("Camera2D") as Camera2D).make_current()
	interior.hide()
	perto_saida = false
	casa_atual = -1

func _aproximou(body: Node2D, indice: int) -> void:
	if body == jogador:
		perto_porta = indice

func _afastou(body: Node2D, indice: int) -> void:
	if body == jogador and perto_porta == indice:
		perto_porta = -1

func _aproximou_saida(body: Node2D) -> void:
	if body == jogador:
		perto_saida = true

func _afastou_saida(body: Node2D) -> void:
	if body == jogador:
		perto_saida = false
