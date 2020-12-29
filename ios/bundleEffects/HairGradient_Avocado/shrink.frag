#version 300 es

precision mediump float;
precision mediump sampler2D;

in float var_y;

layout( location = 0 ) out float F;

layout(std140) uniform glfx_BASIS_DATA
{
	highp vec4 unused;
	highp vec4 glfx_SCREEN;
	highp vec4 glfx_BG_MASK_T[2];
	highp vec4 glfx_HAIR_MASK_T[2];
};

uniform sampler2D glfx_HAIR_MASK;

void main()
{
	ivec2 sz = textureSize(glfx_HAIR_MASK,0).xy;
	float w = float(max(sz.x,sz.y));
	float uv_y = var_y *2. - 1.;
	mat2x3 hair_basis = mat2x3(glfx_HAIR_MASK_T[0].xyz, glfx_HAIR_MASK_T[1].xyz);
	for( float x = 1./w; x < 1.; x += 2./w )
	{
		vec2 uv = vec3(x*2.-1.,uv_y,1.)*hair_basis;
		if( texture( glfx_HAIR_MASK, uv ).x > 0.25 )
		{
			F = 1.;
			return;
		}
	}
	F = 0.;
}
