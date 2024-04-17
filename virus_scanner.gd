extends Node3D

# virus scanner
var	virus_scanner_image: Image = null
const image_size = 64

# Called when the node enters the scene tree for the first time.
func _ready():
	create_virus_scanner_image()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_virus_scanner_image()
	
func create_virus_scanner_image():
	virus_scanner_image = Image.create(image_size,image_size,false,Image.FORMAT_RGBA8)
	$ImageDisplay.texture = ImageTexture.create_from_image(virus_scanner_image)

func update_virus_scanner_image():
	virus_scanner_image.fill_rect(Rect2i(0,0,image_size,image_size),Color(0,0,0,0))
	var virii = get_tree().get_nodes_in_group("virii")
	var color = Color(1,1,1,1)
	var origin = global_position
	var basis = global_basis
	for virus in virii:
		var rel_pos = virus.global_position - origin
		var u = basis.x.dot(rel_pos)
		var v = basis.y.dot(rel_pos)
		var w = basis.z.dot(rel_pos)
		var phi = Vector2(u,v).angle()
		var xi = Vector2(-w,v).angle()
		
		var x=image_size/2 + cos(phi) * xi * image_size/(2*PI)
		var y=image_size/2 + sin(phi) * xi * image_size/(2*PI)
		virus_scanner_image.set_pixel(x,y,color)	
	
	$ImageDisplay.texture.update(virus_scanner_image)
	
	var count = virii.size()
	$CountLabel3D.text =  "{0}".format([count])
