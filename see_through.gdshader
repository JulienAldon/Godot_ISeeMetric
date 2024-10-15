shader_type canvas_item;
uniform sampler2D mask;

void fragment() {
	vec4 colour = texture(TEXTURE, UV);
    colour.a *= texture(mask, UV).a;
    
    COLOR = colour;
}
//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
