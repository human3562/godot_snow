shader_type canvas_item;

#define HEIGHT_TILES 3.0
#define HEIGHT_OCTAVES 2
#define HEIGHT_AMP 0.25
#define HEIGHT_GAIN 0.1
#define HEIGHT_LACUNARITY 2.0

#define EROSION_TILES 4.0
#define EROSION_OCTAVES 5
#define EROSION_GAIN 0.5
#define EROSION_LACUNARITY 2.0

// Scale the input slope, leading to more erosion.
#define EROSION_SLOPE_STRENGTH 3.0
// Continuously modify the noise direction based on the previous fractal sample.
// This is what gives the slopes an interesting "branching" structure.
// A higher value will give you more branches.
#define EROSION_BRANCH_STRENGTH 2.0
// Maximum amount the erosion will modify the base height map
#define EROSION_STRENGTH 0.04

#define WATER_HEIGHT 0.45

vec2 hash(in vec2 x) {
	const vec2 k = vec2(0.3183099, 0.3678794);
	x = x*k + k.yx;
	return -1.0 + 2.0 * fract(16.0 * k*fract( x.x*x.y*(x.x+x.y)) );
}

vec3 noised( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );

    vec2 u = f*f*f*(f*(f*6.0-15.0)+10.0);
    vec2 du = 30.0*f*f*(f*(f-2.0)+1.0);

    vec2 ga = hash( i + vec2(0.0,0.0) );
    vec2 gb = hash( i + vec2(1.0,0.0) );
    vec2 gc = hash( i + vec2(0.0,1.0) );
    vec2 gd = hash( i + vec2(1.0,1.0) );

    float va = dot( ga, f - vec2(0.0,0.0) );
    float vb = dot( gb, f - vec2(1.0,0.0) );
    float vc = dot( gc, f - vec2(0.0,1.0) );
    float vd = dot( gd, f - vec2(1.0,1.0) );

    return vec3( va + u.x*(vb-va) + u.y*(vc-va) + u.x*u.y*(va-vb-vc+vd),   // value
                 ga + u.x*(gb-ga) + u.y*(gc-ga) + u.x*u.y*(ga-gb-gc+gd) +  // derivatives
                 du * (u.yx*(va-vb-vc+vd) + vec2(vb,vc) - va));
}

vec3 erosion(in vec2 p, vec2 dir)
{
    vec2 ip = floor(p);
    vec2 fp = fract(p);
    float f = 2.0 * PI;
    vec3 va = vec3(0.0);
    float wt = 0.0;
    for (int i=-2; i<=1; i++)
    {
        for (int j=-2; j<=1; j++)
        {
            vec2 o = vec2(float(i), float(j));
            vec2 h = hash(ip - o) * 0.5;
            vec2 pp = fp + o - h;
            float d = dot(pp, pp);
            float w = exp(-d * 2.0);
            wt +=w;
            float mag = dot(pp, dir);
            va += vec3(cos(mag * f), -sin(mag * f) * (pp * 0.0 + dir)) * w;
        }
    }
    return va / wt;
}

vec3 mountain(vec2 p, float s) {
    //First generate a base heightmap
    //it can be based on any type of noise
    //so long as you also generate normals
    //Im just doing basic FBM based terrain using
    //iq's analytic derivative gradient noise
    vec3 n = vec3(0.0);
    float nf = 1.0;
    float na = 0.6;
    for (int i=0;i<2;i++) {
       n+= noised(p*s*nf)*na*vec3(1.0, nf, nf);
       na *= 0.5;
       nf *= 2.0;
    }

    //take the curl of the normal to get the gradient facing down the slope
    vec2 dir = n.zy*vec2(1.0, -1.0);

    //Now we compute another fbm type noise
    // erosion is a type of noise with a strong directionality
    //we pass in the direction based on the slope of the terrain
    //erosion also returns the slope. we add that to a running total
    //so that the direction of successive layers are based on the
    //past layers
    vec3 h = vec3(0.0);
    float a = 0.7*(smoothstep(0.3, 0.5,n.x*0.5+0.5)); //smooth the valleys
    float f = 1.0;
    for (int i=0;i<5;i++) {
        h+= erosion(p*f, dir+h.zy*vec2(1.0, -1.0))*a*vec3(1.0, f, f);
        a*=0.4;
        f*=2.0;
    }
    //remap height to [0,1] and add erosion
    //looks best when erosion amount is small
    //not sure about adding the normals together, but it looks okay
    return vec3(smoothstep(-1.0, 1.0, n.x)+h.x*0.05, (n.yz+h.yz)*0.5+0.5);
}

vec2 Heightmap(vec2 uv)
{
    vec2 p = uv * HEIGHT_TILES;

    // FBM terrain
    vec3 n = vec3(0.0);
    float nf = 1.0;
    float na = HEIGHT_AMP;
    for (int i = 0; i < HEIGHT_OCTAVES; i++)
    {
        n += noised(p * nf) * na * vec3(1.0, nf, nf);
        na *= HEIGHT_GAIN;
        nf *= HEIGHT_LACUNARITY;
    }

    // [-1, 1] -> [0, 1]
    n.x = n.x * 0.5 + 0.5;

    // Take the curl of the normal to get the gradient facing down the slope
    vec2 dir = n.zy * vec2(1.0, -1.0) * EROSION_SLOPE_STRENGTH;

    // Now we compute another fbm type noise
    // erosion is a type of noise with a strong directionality
    // we pass in the direction based on the slope of the terrain
    // erosion also returns the slope. we add that to a running total
    // so that the direction of successive layers are based on the
    // past layers
    vec3 h = vec3(0.0);

    float a = 0.5;
    float f = 1.0;

    // Smooth valleys
    //a *= (smoothstep(0.0, 1.0, n.x));

    a *= smoothstep(WATER_HEIGHT - 0.1, WATER_HEIGHT + 0.2, n.x);

    int octaves = EROSION_OCTAVES;

    for (int i = 0; i < octaves; i++)
    {
        h += erosion(p * EROSION_TILES * f, dir + h.zy * vec2(1.0, -1.0) * EROSION_BRANCH_STRENGTH) * a * vec3(1.0, f, f);
        a *= EROSION_GAIN;;
        f *= EROSION_LACUNARITY;
    }

    return vec2(n.x + (h.x - 0.5) * EROSION_STRENGTH, h.x);
}


void fragment() {
	vec2 iResolution = TEXTURE_PIXEL_SIZE;
	vec2 uv = UV.xy/iResolution.xy * 5.0;

    vec2 h = Heightmap(uv);


    // Calculate an accurate normal from neighbouring points
    vec2 uv1 = uv + vec2(1.0, 0.0) / 512.0;
    vec2 uv2 = uv + vec2(0.0, 1.0) / 512.0;
    vec2 h1 = Heightmap(uv1);
    vec2 h2 = Heightmap(uv2);
    vec3 v1 = vec3(uv1 - uv, (h1.x - h.x));
    vec3 v2 = vec3(uv2 - uv, (h2.x - h.x));
    vec3 normal = normalize(cross(v1, v2)).xzy;

    COLOR = vec4(h.x, normal.xz, 1.0);
}