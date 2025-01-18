
#define GLOW_SAMPLES 20
#define GLOW_DISTANCE 0.05
#define GLOW_POW 1.1
#define GLOW_OPACITY 2.76

#define sat(a) clamp(a, 0., 1.)
#define PI 3.14159265
#define TAU (PI*2.0)

mat2 r2d(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }
float hash11(float seed)
{
    return mod(sin(seed*123.456789)*123.456,1.);
}

vec3 getCam(vec3 rd, vec2 uv)
{
    float fov = 1.;
    vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
    vec3 u = normalize(cross(rd, r));
    return normalize(rd+fov*(r*uv.x+u*uv.y));
}

vec2 _min(vec2 a, vec2 b)
{
    if (a.x < b.x)
        return a;
    return b;
}

float _cucube(vec3 p, vec3 s, vec3 th)
{
    vec3 l = abs(p)-s;
    float cube = max(max(l.x, l.y), l.z);
    l = abs(l)-th;
    float x = max(l.y, l.z);
    float y = max(l.x, l.z);
    float z = max(l.x, l.y);
    
    return max(min(min(x, y), z), cube);
}

float _cube(vec3 p, vec3 s)
{
    vec3 l = abs(p)-s;
    return max(l.x, max(l.y, l.z));
}
float _sqr(vec2 uv, vec2 s)
{
    vec2 l = abs(uv)-s;
    return max(l.x, l.y);
}
float _seed;
float rand()
{
    _seed++;
    return hash11(_seed);
}
float _grid(vec3 p, vec3 sp, float sz)
{
    p = mod(p+sp*.5,sp)-sp*.5;
    return min(length(p.xy)-sz, min(length(p.xz)-sz, length(p.yz)-sz));
}
vec2 map(vec3 p)
{
    vec2 acc = vec2(10000.,-1.);
p.y += iTime;
    acc = _min(acc, vec2(length(p)-1., 0.));
    float x = p.x;
    p.x += sin(iTime*.5+p.y)*.35;
    float rep = .5;
    float id = floor((p.y+rep*.5)/rep);
    p.y = mod(p.y+rep*.5,rep)-rep*.5;
    
    float plane = abs(p.y)-.01;
    float cut = sin(p.x*7.+id*.5)*.2
    -sin(p.x*3.3-id)*.4
    -sin(p.x*1.3-id)*.2
    -sat((abs(x)-2.5)*1.)*.7+.3;
    plane = max(plane, -p.z-cut);
    acc = _min(acc, vec2(plane, id));


    return acc;
}

vec3 getNorm(vec3 p, float d)
{
    vec2 e = vec2(0.01, 0.);
    return normalize(vec3(d)-vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x));
}

vec3 trace(vec3 ro, vec3 rd, int steps)
{
    vec3 p = ro;
    for (int i = 0; i < steps && distance(p, ro) < 50.; ++i)
    {
        vec2 res = map(p);
        if (res.x < 0.01)
            return vec3(res.x, distance(p, ro), res.y);
        p+=rd*res.x*.35;
    }
    return vec3(-1.);
}

vec3 getMat(vec3 p, vec3 n, vec3 rd, vec3 res)
{
    vec3 rgb = mix(
    vec3(0.078,0.624,0.588),
    vec3(0.824,0.141,0.961), 
    sin(res.z+iTime)*.5+.5);
    vec3 col = rgb*sat((-p.z+.4)*.5);
    col *= sat(sin(p.y+iTime*3.+sin(p.x-iTime))*.5+.5);
    return col;
}

vec3 rdr(vec2 uv)
{
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(0.,-1.,-3.);
    vec3 ta = vec3(0.,6.,0.);
    vec3 rd = normalize(ta-ro);
    
    rd = getCam(rd, uv);
    vec3 res = trace(ro, rd, 128);
    float depth = 100.;
    if (res.y > 0.)
    {
        depth = res.y;
        vec3 p = ro+rd*res.y;
        vec3 n = getNorm(p, res.x);
        col = n*.5+.5;
        col = getMat(p, n, rd, res)*2.;
        uv.y += .4;
        vec2 uvt = vec2(atan(uv.y, uv.x), 1./length(uv)+iTime);
        uvt.x += sin(uvt.y*10.)*.025;
        col += (6.*pow(sat(texture(iChannel0, uvt*.1).x-.5),3.)
        *vec3(1.000,0.682,0.000)
        +10.*pow(sat(texture(iChannel0, (uvt+vec2(0.,iTime*.5))*.2).x-.5),10.)
        *vec3(0.722,1.000,0.620))*
        sat(sin(uvt.x*3.-iTime)*.3+.7);
    }
    col = mix(col, vec3(.1), 1.-exp(-depth*0.017));
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 ouv = (fragCoord)/iResolution.xy;
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.xx;
    uv *= -1.;
    _seed = iTime+texture(iChannel0, uv).x;
    //vec2 off = .75*(vec2(rand(), rand())-.5)*2.*1./iResolution.x;
    vec3 col = rdr(uv);
        col = sat(col);
    vec2 off = vec2(1., -1.)/(iResolution.x*1.5);

    /*if (true)//diff > 0.3) // Not so cheap antialiasing
    {
        //col = vec3(1.,0.,0.);
        vec3 acc = col;
        acc += rdr(uv+off.xx);
        acc += rdr(uv+off.xy);
        acc += rdr(uv+off.yy);
        acc += rdr(uv+off.yx);
        col = acc/5.;
        
    }*/
    //col *= 1.9/(col+1.);
    //col = pow(col, vec3(1.2));
    vec2 rep = vec2(.12);
    vec2 id = floor((uv+rep*.5)/rep);
    uv = mod(uv+rep*.5,rep)-rep*.5;
    float shape = _sqr(uv, rep*.4);
    col = mix(col, col.zxy, sat((texture(iChannel0, id*.05+floor(iTime)*.1).x-.5)*100.));
    col = sat(col);
    //col = mix(col, texture(iChannel1, fragCoord/iResolution.xy).xyz, .7);
    fragColor = vec4(col,1.0);
}