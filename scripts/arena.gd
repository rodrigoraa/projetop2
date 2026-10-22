# Arena acadêmica criada com assistência de IA; arte de Pixel-boy e AAA (CC0).
class_name ArenaPantano
extends Node2D

signal item_coletado

const ITEM := preload("res://entities/item.tscn")
const SAPO := preload("res://entities/sapo.tscn")
const MAXIMO_SAPOS := 48
const INTERVALO_MINIMO := 0.8

var jogador: CharacterBody2D
var ativa := false
var itens_habilitados := true

const CELULA := 16
const PASTA := "res://sprites/ninja-adventure/Backgrounds/Tilesets/"
const GRAMA := Vector2i(11, 12)
const ARVORE := Vector2i(0, 0)
const PEDRA := Vector2i(15, 10)
const TERRA := Vector2i(14, 11)

@export var tamanho := Vector2i(640, 384)

func _ready() -> void:
	montar_cenario()
	$Horda.timeout.connect(nascer_sapo)
	$NascimentoItens.timeout.connect(nascer_item)

func obter_inicio() -> Vector2:
	return $Inicio.global_position

func obter_pontos_itens() -> Array[Marker2D]:
	var pontos: Array[Marker2D] = []
	for ponto in $PontosItens.get_children():
		pontos.append(ponto as Marker2D)
	return pontos

func obter_nascedouros() -> Array[Marker2D]:
	var pontos: Array[Marker2D] = []
	for ponto in $Nascedouros.get_children():
		pontos.append(ponto as Marker2D)
	return pontos

func montar_cenario() -> void:
	# Os atlas usam somente regiões verificadas dos PNGs originais.
	var conjunto := TileSet.new()
	conjunto.tile_size = Vector2i(CELULA, CELULA)
	var piso := criar_atlas("TilesetFloor.png")
	for coordenada in [GRAMA, Vector2i(12, 12), Vector2i(13, 12), Vector2i(14, 12), TERRA]:
		piso.create_tile(coordenada)
	conjunto.add_source(piso, 0)
	var agua := criar_atlas("TilesetWater.png")
	for y in range(6, 9):
		for x in range(0, 3):
			agua.create_tile(Vector2i(x, y))
	conjunto.add_source(agua, 1)
	var natureza := criar_atlas("TilesetNature.png")
	natureza.create_tile(ARVORE, Vector2i(2, 2))
	natureza.create_tile(PEDRA, Vector2i(2, 2))
	conjunto.add_source(natureza, 2)
	for camada in [$Chao, $Agua, $Vegetacao]:
		camada.tile_set = conjunto

	for y in range(tamanho.y / CELULA):
		for x in range(tamanho.x / CELULA):
			var tile := GRAMA
			var variacao := (x * 13 + y * 7) % 19
			if variacao < 3:
				tile = Vector2i(12 + variacao, 12)
			# Clareira larga e trilha vertical, sempre transitáveis.
			if (x >= 9 and x <= 30 and y >= 10 and y <= 13) or (x >= 18 and x <= 21 and y >= 4 and y <= 19):
				tile = TERRA
			$Chao.set_cell(Vector2i(x, y), 0, tile)

	criar_lagoa(Vector2i(3, 7), Vector2i(5, 7))
	criar_lagoa(Vector2i(32, 9), Vector2i(5, 7))
	# Árvores fecham a moldura visual. As quatro paredes não deixam frestas.
	for x in range(0, 40, 2):
		$Vegetacao.set_cell(Vector2i(x, 0), 2, ARVORE)
		$Vegetacao.set_cell(Vector2i(x, 22), 2, ARVORE)
	for y in range(2, 22, 2):
		$Vegetacao.set_cell(Vector2i(0, y), 2, ARVORE)
		$Vegetacao.set_cell(Vector2i(38, y), 2, ARVORE)
	criar_colisao(Rect2(0, 0, 640, 32), "BordaSuperior")
	criar_colisao(Rect2(0, 352, 640, 32), "BordaInferior")
	criar_colisao(Rect2(0, 32, 32, 320), "BordaEsquerda")
	criar_colisao(Rect2(608, 32, 32, 320), "BordaDireita")
	for celula in [Vector2i(11, 5), Vector2i(25, 17), Vector2i(9, 18), Vector2i(29, 4)]:
		$Vegetacao.set_cell(celula, 2, PEDRA)
		criar_colisao(Rect2(Vector2(celula * CELULA), Vector2(32, 32)), "Pedra")

func criar_atlas(arquivo: String) -> TileSetAtlasSource:
	var atlas := TileSetAtlasSource.new()
	atlas.texture = load(PASTA + arquivo)
	atlas.texture_region_size = Vector2i(CELULA, CELULA)
	return atlas

func criar_lagoa(inicio: Vector2i, medida: Vector2i) -> void:
	for y in range(medida.y):
		for x in range(medida.x):
			# 0/2 são bordas; a célula central se repete no interior.
			var coluna := 0 if x == 0 else (2 if x == medida.x - 1 else 1)
			var linha := 6 if y == 0 else (8 if y == medida.y - 1 else 7)
			$Agua.set_cell(inicio + Vector2i(x, y), 1, Vector2i(coluna, linha))
	criar_colisao(Rect2(Vector2(inicio * CELULA), Vector2(medida * CELULA)), "Lagoa")

func criar_colisao(area: Rect2, nome: String) -> void:
	var corpo := StaticBody2D.new()
	corpo.name = nome
	corpo.collision_layer = 1 # Mundo.
	corpo.collision_mask = 0
	corpo.position = area.get_center()
	var forma := RectangleShape2D.new()
	forma.size = area.size
	var colisao := CollisionShape2D.new()
	colisao.shape = forma
	corpo.add_child(colisao)
	$Colisoes.add_child(corpo)

func iniciar(alvo: CharacterBody2D, com_itens: bool = true) -> void:
	jogador = alvo
	itens_habilitados = com_itens
	ativa = true
	jogador.definir_ativo(true)
	for ator in $Atores.get_children():
		ator.definir_alvo(jogador)
		ator.definir_ativo(true)
	for item in $Itens.get_children():
		item.definir_ativo(itens_habilitados)
	$Horda.start(2.0)
	$NascimentoItens.stop()
	if itens_habilitados:
		$NascimentoItens.start(3.0)
		if $Itens.get_child_count() == 0:
			nascer_item()

func parar() -> void:
	ativa = false
	$Horda.stop()
	$NascimentoItens.stop()
	if is_instance_valid(jogador):
		jogador.definir_ativo(false)
	for ator in $Atores.get_children():
		ator.definir_ativo(false)
	for item in $Itens.get_children():
		item.definir_ativo(false)

func limpar() -> void:
	parar()
	jogador = null
	for conteiner in [$Atores, $Itens]:
		for filho in conteiner.get_children():
			conteiner.remove_child(filho)
			filho.queue_free()

func nascer_sapo() -> void:
	if not ativa or not is_instance_valid(jogador) or $Atores.get_child_count() >= MAXIMO_SAPOS:
		return
	var pontos := obter_nascedouros()
	pontos.shuffle()
	for ponto in pontos:
		if ponto.global_position.distance_to(jogador.global_position) < 64.0:
			continue
		var forma := CircleShape2D.new()
		forma.radius = 5.0
		var consulta := PhysicsShapeQueryParameters2D.new()
		consulta.shape = forma
		consulta.transform = Transform2D(0.0, ponto.global_position)
		consulta.collision_mask = 1
		if not get_world_2d().direct_space_state.intersect_shape(consulta).is_empty():
			continue
		var sapo := SAPO.instantiate() as CharacterBody2D
		$Atores.add_child(sapo)
		sapo.global_position = ponto.global_position
		sapo.definir_alvo(jogador)
		$Horda.wait_time = maxf(INTERVALO_MINIMO, $Horda.wait_time * 0.95)
		return

func nascer_item() -> void:
	if not ativa or not itens_habilitados:
		return
	var ocupados: Array[Vector2] = []
	for item in $Itens.get_children():
		if not item.foi_coletado and not item.is_queued_for_deletion():
			ocupados.append(item.global_position)
	var pontos := obter_pontos_itens()
	pontos.shuffle()
	for ponto in pontos:
		if ocupados.has(ponto.global_position):
			continue
		var item := ITEM.instantiate() as Area2D
		item.position = $Itens.to_local(ponto.global_position)
		item.coletado.connect(ao_coletar_item)
		$Itens.add_child(item)
		return

func ao_coletar_item(_item: Area2D) -> void:
	if ativa and itens_habilitados:
		item_coletado.emit()
