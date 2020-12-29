#version 300 es

#if defined GL_EXT_shader_framebuffer_fetch
#extension GL_EXT_shader_framebuffer_fetch : require
#elif defined GL_ARM_shader_framebuffer_fetch
#extension GL_ARM_shader_framebuffer_fetch : require
#endif

precision highp float;

in float var_color_uv;
in vec2 var_bg_uv;
in vec2 var_hairmask_uv;

layout(std140) uniform glfx_GLOBAL
{
	highp mat4 glfx_MVP;
	highp mat4 glfx_PROJ;
	highp mat4 glfx_MV;
	highp vec4 glfx_VIEW_QUAT;

	highp vec4 hair_colors[8];
	highp vec4 hair_colors_size;
};

#ifdef GL_EXT_shader_framebuffer_fetch
layout( location = 0 ) inout vec4 F;
#else
layout( location = 0 ) out vec4 F;
#endif

#if !defined GL_EXT_shader_framebuffer_fetch && !defined GL_ARM_shader_framebuffer_fetch
uniform sampler2D glfx_BACKGROUND;
#endif

uniform sampler2D glfx_HAIR_MASK;

vec3 rgb2yuv(vec3 rgb)
{
	vec3 yuv;
	yuv.x = rgb.r * 0.299 + rgb.g * 0.587 + rgb.b * 0.114;
	yuv.y = rgb.r * -0.169 + rgb.g * -0.331 + rgb.b * 0.5 + 0.5;
	yuv.z = rgb.r * 0.5 + rgb.g * -0.419 + rgb.b * -0.081 + 0.5;
	return yuv;
}

vec3 yuv2rgb(vec3 yuv)
{
	float Y = yuv.x;
	vec2 UV = yuv.yz - 0.5;
	return vec3(Y+1.4*UV.y,Y-0.343*UV.x-0.711*UV.y,Y+1.765*UV.x);
}

void main()
{
#if defined GL_EXT_shader_framebuffer_fetch
	vec3 bg = F.xyz;
#elif defined GL_ARM_shader_framebuffer_fetch
	vec3 bg = gl_LastFragColorARM.xyz;
#else
	vec3 bg = texture( glfx_BACKGROUND, var_bg_uv ).xyz;
#endif

	float color_coord = max(0.,var_color_uv*hair_colors_size.x-0.5);
	int color_i0 = int(color_coord);
	int color_i1 = min(color_i0+1,int(hair_colors_size.x)-1);
	vec4 hair_color = mix( hair_colors[color_i0], hair_colors[color_i1], smoothstep(0.,1.,fract(color_coord)) );

	float alpha = texture( glfx_HAIR_MASK, var_hairmask_uv )[0];
	float beta = 0.5;//0.5;

	vec3 pixel = rgb2yuv(bg);
	vec3 yuv = rgb2yuv(hair_color.xyz);

	if(alpha > 0.05)
	{
		pixel[1] = (1. - alpha)*pixel[1] + alpha*((beta)*pixel[1] + (1. - beta)*yuv[1]);
		pixel[2] = (1. - alpha)*pixel[2] + alpha*((beta)*pixel[2] + (1. - beta)*yuv[2]);
	}

	F = vec4(yuv2rgb(pixel), 1.);
}
