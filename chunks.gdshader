shader_type spatial;
uniform sampler2D atlas : filter_nearest, source_color ;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float y = UV.y / 64.0;
	float x = UV.x / 64.0;
	vec2 surface = vec2(x,y);
	
	ALBEDO = texture(atlas, surface).rgb;
	ROUGHNESS = 1.0; 
    SPECULAR = 0.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
