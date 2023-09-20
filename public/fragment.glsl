precision mediump float;

uniform float millis;

// input variables
uniform bool animated;
uniform float x_offset;
uniform float y_offset;
uniform float r;
uniform float blurriness;
uniform float alpha;
uniform float detail;

// input color
uniform float inRed;
uniform float inBlue;
uniform float inGreen;


// input backgroundimage
uniform sampler2D background;

// pos
varying vec2 pos;

vec2 randomGradient(vec2 p) {
    p = p + 0.02;
    float x = dot(p, vec2(123.4, 234.5));
    float y = dot(p, vec2(234.5, 345.6));
    vec2 gradient = vec2(x, y);
    gradient = sin(gradient);
    gradient = gradient * 41231.5453;
    if (animated){
        gradient = sin(gradient + (millis/1000.));
    };
    gradient = sin(gradient);
    return gradient;

}

// Signed distance field functions
float sdfCircle(in vec2 p, in float r) {
    return length(p) - r;
}

float dot2(in vec2 v ) { return dot(v,v); }

float sdTrapezoid( in vec2 p, in float r1, float r2, float he )
{
    vec2 k1 = vec2(r2,he);
    vec2 k2 = vec2(r2-r1,2.0*he);
    p.x = abs(p.x);
    vec2 ca = vec2(p.x-min(p.x,(p.y<0.0)?r1:r2), abs(p.y)-he);
    vec2 cb = p - k1 + k2*clamp( dot(k1-p,k2)/dot2(k2), 0.0, 1.0 );
    float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot2(ca),dot2(cb)) );
}

float sdfOrientedBox(in vec2 p, in vec2 a, in vec2 b, float th) {
    float l = length(b - a);
    vec2 d = (b - a) / l;
    vec2 q = (p - (a + b) * 0.5);
    q = mat2(d.x, -d.y, d.y, d.x) * q;
    q = abs(q) - vec2(l, th) * 0.5;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}

vec2 cubic(vec2 p) {
    return p * p * (3.0 - p * 2.0);
}

vec2 quintic(vec2 p) {
    return p * p * p * (10.0 + p * (-15.0 + p * 6.0));
}

void main() {
    // flips image
    vec2 newPos = pos;
    newPos.y = 1. - newPos.y;

    // creates a vec4 of the current pixel
    vec4 imageColor = texture2D(background,newPos);

    // normalizes coordinates
    vec2 uv = gl_FragCoord.xy / vec2(700,700);
    uv = uv - 0.5;
    uv = uv * vec2(700,700) / 100.0;

    // test colors
    vec4 blue = vec4(0.65,0.85,1.0,1.);
    vec4 orange = vec4(0.9,0.6,0.3,1.);
    vec3 black = vec3(0.,0.,0.);

    vec4 color = blue;

    //creates a circle in for the perlin noise
    float radius = r;
    vec2 center = vec2(0.0 + x_offset,0.0 + y_offset);
    float d = sdfCircle(uv - center, radius);


    //create perlin Noise

    vec2 puv = gl_FragCoord.xy / vec2(700,700);



    puv = puv * detail;
    vec2 gridId = floor(puv);
    vec2 gridUv = fract(puv);

    vec3 perlin_color = vec3(gridUv,0.0);;

    vec2 bl = gridId + vec2(0.0, 0.0);
    vec2 br = gridId + vec2(1.0, 0.0);
    vec2 tl = gridId + vec2(0.0, 1.0);
    vec2 tr = gridId + vec2(1.0, 1.0);

    vec2 gradBl = randomGradient(bl);
    vec2 gradBr = randomGradient(br);
    vec2 gradTl = randomGradient(tl);
    vec2 gradTr = randomGradient(tr);

    vec2 gridCell = gridId + gridUv;
    float distG1 = sdfOrientedBox(gridCell, bl, bl + gradBl / 2.0, 0.02);
    float distG2 = sdfOrientedBox(gridCell, br, br + gradBr / 2.0, 0.02);
    float distG3 = sdfOrientedBox(gridCell, tl, tl + gradTl / 2.0, 0.02);
    float distG4 = sdfOrientedBox(gridCell, tr, tr + gradTr / 2.0, 0.02);
    if (distG1 < 0.0 || distG2 < 0.0 || distG3 < 0.0 || distG4 < 0.0) {
        perlin_color = vec3(1.0);
    }

    float circleRadius = 11.5;
    vec2 circleCenter = vec2(0.5, 0.5);
    float distToCircle = sdfCircle(gridUv - circleCenter, circleRadius);
    perlin_color = distToCircle > 0.0 ? perlin_color : vec3(0.,0.,0.);

    vec2 distFromPixelToBl = gridUv - vec2(0.0, 0.0);
    vec2 distFromPixelToBr = gridUv - vec2(1.0, 0.0);
    vec2 distFromPixelToTl = gridUv - vec2(0.0, 1.0);
    vec2 distFromPixelToTr = gridUv - vec2(1.0, 1.0);

    float dotBl = dot(gradBl, distFromPixelToBl);
    float dotBr = dot(gradBr, distFromPixelToBr);
    float dotTl = dot(gradTl, distFromPixelToTl);
    float dotTr = dot(gradTr, distFromPixelToTr);

    gridUv = quintic(gridUv);

    float b = mix(dotBl, dotBr, gridUv.x);
    float t = mix(dotTl, dotTr, gridUv.x);
    float perlin = mix(b, t, gridUv.y);

    //create grid




    // hard edge
    //color = d > 0.0 ? imageColor : vec4(1.);

    // soft edge
    vec4 perlin_image = mix(vec4(inRed, inGreen, inBlue, 0.),vec4(imageColor),vec4(smoothstep((1.-perlin+blurriness),.2,.8)));
    vec4 background = mix(perlin_image,imageColor,vec4(smoothstep(alpha,.0,1.-d)));

    if (color.a < 0.1)
            discard;


    gl_FragColor = vec4(background);
}