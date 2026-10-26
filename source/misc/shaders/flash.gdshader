shader_type canvas_item;

uniform bool active = false;
uniform vec3 rgb;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 color = vec4(rgb.x, rgb.y, rgb.z, previous_color.a);
	vec4 new_color = previous_color;
	if (active == true)
	{
		new_color = color;
	}
	COLOR = new_color;
}