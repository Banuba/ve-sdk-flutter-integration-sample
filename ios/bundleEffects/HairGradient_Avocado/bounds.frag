#version 300 es

precision lowp float;
precision lowp sampler2D;

layout( location = 0 ) out vec2 F;

uniform sampler2D hair_vertical;

void main()
{
	vec2 minmax = vec2(0.,1.);
	for( int y = 0; y != 256; ++y )
	{
		if( texelFetch(hair_vertical,ivec2(0,y),0).x > 0.5 )
		{
			minmax[0] = (0.5+float(y))/256. - 1./256.;
			break;
		}
	}

	for( int y = 255; y > 0; --y )
	{
		if( texelFetch(hair_vertical,ivec2(0,y),0).x > 0.5 )
		{
			minmax[1] = (0.5+float(y))/256. + 1./256.;
			break;
		}
	}


	F = minmax;
}
