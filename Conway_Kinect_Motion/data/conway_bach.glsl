// Conway's game of life

#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_COLOR_SHADER

uniform float time;
uniform float ageSpeed;
uniform vec2 resolution;
uniform sampler2D ppixels;
uniform sampler2D depthImg;
uniform vec2 kinectResolution;
uniform float minThreshold;
uniform float maxThreshold;

vec4 live = vec4(1.0,1.,1.,1.);
vec4 dead = vec4(0.,0.,0.,1.);
vec4 dying = vec4(1.,0.,1.,1.);

bool isPersonPresent;

void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec2 pixel = 1./resolution;

	// kinect depth value -> max value 2048 and min value 0
	// normalized for comparison as float (0-1)
	vec2 kinectPosition = ( gl_FragCoord.xy / resolution.xy );
	float brightness = texture2D(depthImg, kinectPosition).r
					+ texture2D(depthImg, kinectPosition).g
					+ texture2D(depthImg, kinectPosition).b;
	if( brightness < maxThreshold && brightness > minThreshold ) {//isPersonPresent) {
		float rnd1 = mod(fract(sin(dot(position + time * 0.001, vec2(14.9898,78.233))) * 43758.5453), 1.0);
		if (rnd1 > 0.5) {
			gl_FragColor = live;
		} else {
			gl_FragColor = dying;
		}
	} else {
		int sum = 0;
		if(texture2D(backbuffer, position + pixel * vec2(-1., -1.)).r + texture2D(backbuffer, position + pixel * vec2(-1., -1.)).g + texture2D(backbuffer, position + pixel * vec2(-1., -1.)).b > 2.99)
			sum+=1;
		if(texture2D(backbuffer, position + pixel * vec2(-1., 0.)).r + texture2D(backbuffer, position + pixel * vec2(-1., 0.)).g + texture2D(backbuffer, position + pixel * vec2(-1., 0.)).b > 2.99)
			sum+=1;
		if(texture2D(backbuffer, position + pixel * vec2(-1., 1.)).r + texture2D(backbuffer, position + pixel * vec2(-1., 1.)).g + texture2D(backbuffer, position + pixel * vec2(-1., 1.)).b > 2.99)
			sum+=1;
		if(texture2D(backbuffer, position + pixel * vec2(1., -1.)).r + texture2D(backbuffer, position + pixel * vec2(1., -1.)).g + texture2D(backbuffer, position + pixel * vec2(1., -1.)).b > 2.99)
			sum+=1;
		if(texture2D(backbuffer, position + pixel * vec2(-1., 0.)).r + texture2D(backbuffer, position + pixel * vec2(1., 0.)).g + texture2D(backbuffer, position + pixel * vec2(1., 0.)).b > 2.99)
			sum+=1;
		if(texture2D(backbuffer, position + pixel * vec2(1., 1.)).r + texture2D(backbuffer, position + pixel * vec2(1., 1.)).g + texture2D(backbuffer, position + pixel * vec2(1., 1.)).b > 2.99)
			sum+=1;
		if(texture2D(backbuffer, position + pixel * vec2(0., -1.)).r + texture2D(backbuffer, position + pixel * vec2(0., -1.)).g + texture2D(backbuffer, position + pixel * vec2(0., -1.)).b > 2.99)
			sum+=1;
		if(texture2D(backbuffer, position + pixel * vec2(0., 1.)).r + texture2D(backbuffer, position + pixel * vec2(0., 1.)).g + texture2D(backbuffer, position + pixel * vec2(0., 1.)).b > 2.99)
			sum+=1;
		vec4 me = texture2D(backbuffer, position);
vec4 me = texture2D(ppixels, position);
		
		if (me.r + me.g + me.b <= 0.1) {	// if dead
			if (sum == 3) {					// bring to life with 3 neighbors
				gl_FragColor = live;
			} else if (me.r > ageSpeed) {
				gl_FragColor = vec4(me.r-ageSpeed, 0.0, 0.8, 1.);
			} else if (me.b > ageSpeed) {
				gl_FragColor = vec4(0.0, 0.0, me.b - ageSpeed, 1.);
			} 
			else {
				gl_FragColor = dead;
			}
		} else {
			if ((sum == 2) || (sum == 3)) {
				gl_FragColor = live;
			} else {
				gl_FragColor = dying;
			}
		}
	}
}