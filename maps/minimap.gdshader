shader_type canvas_item;

uniform float radius;

// lol https://www.youtube.com/watch?v=7z674igWjpU

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	vec2 local_coords = (UV - center);
	float distance = length(local_coords);
	
	float circleRadius = radius / float(2);
	
	if (distance > circleRadius) {
		discard;
	}
}