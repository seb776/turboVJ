#define sat(a) clamp(a, 0., 1.)

mat2 r2d(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }
#define PI 3.141592653
float _time;
float lenny(vec2 v)
{
  return abs(v.x)+abs(v.y);
}
vec2 _min(vec2 a, vec2 b)
{
    if (a.x < b.x)
        return a;
    return b;
}

float _cube(vec3 p, vec3 s)
{
    vec3 l = abs(p)-s;
    return max(l.x, max(l.y, l.z));
}

float _cubeWire(vec3 p, vec3 s, vec3 th)
{
    vec3 l = abs(p)-s;
    float cube = max(l.x, max(l.y, l.z));
    l = abs(l)-th;
    
    float x = max(l.y, l.z);
    float y = max(l.x, l.z);
    float z = max(l.x, l.y);
    
    float cucube = max(min(min(x, y), z), cube);
    return cucube;
}

vec2 map(vec3 p)
{
    vec2 acc = vec2(1000., -1.);
    
    vec3 sz = vec3(1.+sin(_time*.15),.3+sin(_time)*.5+.5,1.);
    vec3 rep = vec3(2.5);
    vec3 id = floor((p+rep*.5)/rep);
    vec3 lim = rep*5.5*vec3(1.,.6,1.);

     p.y = abs(p.y);
    p.y = p.y+sz.y*2.;
    p = clamp(p, -lim, lim);
    p = mod(p+rep*.5,rep)-rep*.5;
    //p.x = mod(p.x+rep.x*.5, rep.x)-rep.x*.5;
    //if (abs(id.x) < 5. && abs(id.y) < 5. && id.z > -sz.z*.5)
    {
    
        acc = _min(acc, vec2(_cube(p, sz*.97*(sin(_time)*.2+.5)), 0.));
        acc = _min(acc, vec2(_cubeWire(p, sz, vec3(0.02)), 1.));
    }
    return acc;
}

vec3 getCam(vec3 rd, vec2 uv)
{
    float fov = 3.;
    vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
    vec3 u = normalize(cross(rd, r));
    
    return normalize(rd+fov*(r*uv.x+u*uv.y));
}
#define FFT(a) texture(iChannel0, vec2(a, 0.), 0.).x
vec3 accCol;
vec3 trace(vec3 ro, vec3 rd, int steps)
{
    accCol = vec3(0.);
    vec3 p = ro;
    for (int i = 0; i < steps; ++i)
    {
        vec2 res = map(p);
        if (res.x < 0.01)
            return vec3(res.x, distance(p, ro), res.y);
        p+=rd*res.x;
        if (res.y == 1.)
            accCol += .5*vec3(cos(FFT(length(p.xz)*.2)*3.)*.5+.5, cos(p.z)*.2+.8, sin(p.y+iTime)*.5+.5)*(1.-sat(res.x/.35))*.1;
    }
    return vec3(-1.);
}

vec3 getNorm(vec3 p, float d)
{
    vec2 e = vec2(0.01,0.);
    return normalize(vec3(d)-vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x));
}

vec3 rdra(vec2 uv)
{
    vec3 col = vec3(0.);
    float dist = 20.+15.*sin(_time*.2);
    float t= sin(_time *.15)*6.;
    vec3 ro = vec3(sin(t),0.,cos(t))*dist+vec3(0.,sin(_time*.25)*5.,0.);
    uv *= r2d(sin(_time)*1.2);
    
    vec3 ta = vec3(0.,0.,0.);
    vec3 rd = normalize(ta-ro);
    
    rd = getCam(rd, uv);
    
    vec3 res = trace(ro, rd, 128);
    if (res.y > 0.)
    {
        vec3 p = ro +rd*res.y;
        vec3 n = getNorm(p, res.x);
        if (res.z == 0.)
            col = vec3(0.);
        else
        {
            col = vec3(1.)*pow(1.-sat(distance(p, ro)/45.), .5);
        }
         col += accCol*.8*vec3(0.722,0.906,1.000)*(1.-sat(length(uv*1.7)));    
    }
    //col *= 1.5;
    col += accCol*.2*vec3(0.400,0.800,1.000)*(1.-sat(length(uv*2.)));

    return col;
}

vec3 rdrb(vec2 uv)
{
  vec3 col = vec3(0.);
    return col;
}

vec3 rdr(vec2 uv)
{
    return mix(rdra(uv), rdra(uv*vec2(-1.,1.)).yzx, sat((sin(_time*.25))*400.));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-vec2(.5)*iResolution.xy)/iResolution.xx;
    _time = iTime;//+texture(iChannel2, fragCoord/8.).x*iTimeDelta;
    uv *= 1.-length(uv*sin(_time));
    vec3 col = rdr(uv);
    //if(false)
    { // Not so cheap antialiasing SSAA x4
        vec2 off = vec2(1., -1.)/(iResolution.x*1.75);
        col += rdr(uv-off.xx);
        col += rdr(uv-off.xy);
        col += rdr(uv-off.yy);
        col += rdr(uv-off.yx);
        col = col /5.;
    }
    col.xz *= r2d(sin(iTime)*.5+.5);
    col.xz = abs(col.xz);
    col.xy *= r2d(sin(iTime*.5)*.5+.5);
    col.xy = abs(col.xy);
    col = pow(col, vec3(1.5));
    //col = mix(col, texture(iChannel0, fragCoord/iResolution.xy).xyz, .85*sat(length(uv*3.)));
    fragColor = vec4(col,1.0);
}