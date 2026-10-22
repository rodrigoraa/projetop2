# Arena acadêmica criada com assistência de IA; arte de Pixel-boy e AAA (CC0).
class_name ArenaPantano
extends Node2D

const CELULA := 16
const PASTA := "res://sprites/ninja-adventure/Backgrounds/Tilesets/"
const GRAMA := Vector2i(11, 12)
const ARVORE := Vector2i(0, 0)
const PEDRA := Vector2i(15, 10)
const TERRA := Vector2i(14, 11)

@export var tamanho := Vector2i(640, 384)

func _ready() -> void:
	montar_cenario()

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
