extends Node2D

const CHUNK_SIZE = 16
const TILE_SIZE = 16
const VIEW_DISTANCE = 2
const FLOWER_CHANCE = 0.003
const FLOWER_CHANCE2 = 0.001
const GRASS_CHANCE = 0.01
const BUSH_CHANCE = 0.002

const GRASS_GROUND_SPRITE = preload("res://sprites/grass_ground.png")
const FLOWER_SPRITE = preload("res://sprites/flowie.png")
const FLOWER_SPRITE2 = preload("res://sprites/flowie2.png")
const BUSH_SPRITE = preload("res://sprites/bush.png")
const GRASS_SPRITE = preload("res://sprites/grass.png")
const GRASS_SPRITE2 = preload("res://sprites/grass2.png")
const GRASS_SPRITE3 = preload("res://sprites/grass3.png")

var active_chunks = {}
var viewport_size: Vector2

class Chunk extends Node2D:
	var ground_tiles: Node2D
	var decoration_sprites: Node2D
	
	func _init():
		ground_tiles = Node2D.new()
		add_child(ground_tiles)
		
		decoration_sprites = Node2D.new()
		add_child(decoration_sprites)
	
	func cleanup():
		queue_free()

func _ready():
	viewport_size = get_viewport_rect().size
	generate_visible_chunks()

func create_chunk(chunk_pos: Vector2i) -> Chunk:
	var chunk = Chunk.new()
	chunk.position = Vector2(chunk_pos.x * CHUNK_SIZE * TILE_SIZE, 
						   chunk_pos.y * CHUNK_SIZE * TILE_SIZE)
	
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var pos = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			
			var ground = Sprite2D.new()
			ground.texture = GRASS_GROUND_SPRITE
			ground.position = pos
			chunk.ground_tiles.add_child(ground)
			
			if x % 2 == 0 and y % 2 == 0:
				if randf() < FLOWER_CHANCE * 2:
					add_decoration(chunk, FLOWER_SPRITE, pos)
				if randf() < FLOWER_CHANCE2 * 2:
					add_decoration(chunk, FLOWER_SPRITE2, pos)
				
				if randf() < GRASS_CHANCE * 2:
					add_decoration(chunk, GRASS_SPRITE, pos)
				if randf() < GRASS_CHANCE * 2:
					add_decoration(chunk, GRASS_SPRITE2, pos)
				if randf() < GRASS_CHANCE * 2:
					add_decoration(chunk, GRASS_SPRITE3, pos)
				
				if randf() < BUSH_CHANCE * 2:
					add_decoration(chunk, BUSH_SPRITE, pos)
	
	return chunk

func add_decoration(chunk: Chunk, texture: Texture2D, pos: Vector2):
	var shadow = Sprite2D.new()
	shadow.texture = preload("res://sprites/shadow.png")
	shadow.position = pos + Vector2(1, 6)
	shadow.scale = Vector2(1, 1)
	shadow.modulate = Color(0, 0, 0, 0.4)
	chunk.decoration_sprites.add_child(shadow)
	
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	chunk.decoration_sprites.add_child(sprite)

func generate_visible_chunks():
	var chunks_x = ceil(viewport_size.x / (CHUNK_SIZE * TILE_SIZE)) + 1
	var chunks_y = ceil(viewport_size.y / (CHUNK_SIZE * TILE_SIZE)) + 1
	
	for x in range(-chunks_x/2, chunks_x/2 + 1):
		for y in range(-chunks_y/2, chunks_y/2 + 1):
			generate_chunk(Vector2i(x, y))

func generate_chunk(chunk_pos: Vector2i):
	if active_chunks.has(chunk_pos):
		return
	
	var chunk = create_chunk(chunk_pos)
	add_child(chunk)
	active_chunks[chunk_pos] = chunk

func update_chunks(player_pos: Vector2):
	var current_chunk = Vector2i(
		floor(player_pos.x / (CHUNK_SIZE * TILE_SIZE)),
		floor(player_pos.y / (CHUNK_SIZE * TILE_SIZE))
	)
	
	for x in range(-VIEW_DISTANCE, VIEW_DISTANCE + 1):
		for y in range(-VIEW_DISTANCE, VIEW_DISTANCE + 1):
			var check_chunk = current_chunk + Vector2i(x, y)
			if not active_chunks.has(check_chunk):
				generate_chunk(check_chunk)
	
	var chunks_to_remove = []
	for pos in active_chunks:
		if abs(pos.x - current_chunk.x) > VIEW_DISTANCE or \
		   abs(pos.y - current_chunk.y) > VIEW_DISTANCE:
			chunks_to_remove.append(pos)
	
	for pos in chunks_to_remove:
		active_chunks[pos].cleanup()
		active_chunks.erase(pos)

var update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.35

func _process(delta: float):
	update_timer += delta
	if update_timer >= UPDATE_INTERVAL:
		update_timer = 0.0
		if has_node("../Player"):
			update_chunks(get_node("../Player").position)
