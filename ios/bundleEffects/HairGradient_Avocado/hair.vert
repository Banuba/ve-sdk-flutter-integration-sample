#version 300 es

layout( location = 0 ) in vec3 attrib_pos;

layout(std140) uniform glfx_BASIS_DATA
{
	highp vec4 unused;
	highp vec4 glfx_SCREEN;
	highp vec4 glfx_BG_MASK_T[2];
	highp vec4 glfx_HAIR_MASK_T[2];
};

uniform sampler2D hair_bounds;

out float var_color_uv;
out vec2 var_bg_uv;
out vec2 var_hairmask_uv;

void main()
{
	mat2x3 hair_basis = mat2x3(glfx_HAIR_MASK_T[0].xyz, glfx_HAIR_MASK_T[1].xyz);
	mat3 hair_inv_basis = inverse(mat3(glfx_HAIR_MASK_T[0].xyz,glfx_HAIR_MASK_T[1].xyz,vec3(0.,0.,1.)));
	
	vec2 bounds = texelFetch(hair_bounds,ivec2(0,0),0).xy;

	float y = bounds[0] + (attrib_pos.y*0.5+0.5)*(bounds[1]-bounds[0]);

	gl_Position = vec4( attrib_pos.x, y*2.-1., 0.,1. );

	var_color_uv = 1.-(attrib_pos.y*0.5+0.5);
	var_bg_uv = gl_Position.xy*0.5+0.5;
	
	var_hairmask_uv = vec3(gl_Position.xy,1.)*hair_basis;
}