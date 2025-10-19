shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex_colour = texture(TEXTURE, UV);
	float grayscale = dot(tex_colour.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(vec3(grayscale), tex_colour.a) * vec4(.44, .67, .41, 1.0) * 1.5;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
