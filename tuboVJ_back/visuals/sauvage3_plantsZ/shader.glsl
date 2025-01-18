#define sat(a) clamp(a, 0., 1.)
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))
#define PI 3.14159265
#define TAU (PI*2.0)


float lenny(vec2 v)
{
    return abs(v.x) + abs(v.y);
}
vec2 _min(vec2 a, vec2 b)
{
    if (a.x < b.x)
        return a;
    return b;
}
float _sqr(vec2 uv, vec2 s)
{
    vec2 l = abs(uv)-s;
    return max(l.x, l.y);
}
float _cir(vec2 uv, float r)
{
    return length(uv)-r;
}
float sdf_zicon(vec2 uv)
{
  float th = 0.01*4.;
  float sz = 0.1;
  float acc = 1000.;

  acc = abs(_cir(uv-vec2(.3), sz))-th;
  acc = min(acc,abs(_cir(uv-vec2(-.3), sz))-th);
  acc = min(acc,abs(_cir(uv-vec2(-.3,.3), sz*.7))-th);
  acc = min(acc,abs(_cir(uv-vec2(.3,-.35), sz*1.3))-th);

  acc = min(acc, _sqr(uv-vec2(-0.015,.3), vec2(.21,th)));
  acc = min(acc, _sqr((uv-vec2(-0.0,.0))*rot(-PI/4.), vec2(.32,th)));
  acc = min(acc, _sqr((uv-vec2(-0.015,-.3))*rot(0.1), vec2(.19,th)));

    return acc;
}

vec2 map(vec3 p)
{
    vec2 acc = vec2(10000.,-1.);
    
    vec3 pz = p+vec3(0.,.2+sin(iTime)*.3,0.);
    pz.y *= -1.;
    pz.yz *= rot(PI*.25);

    float z = sdf_zicon(pz.xy*.5);
    float zinf = z;
    z = max(z, abs(pz.z)-.2);
    acc = _min(acc, vec2(z, 0.));

    
    return acc;
}

vec3 getNorm(vec3 p, float d)
{
    vec2 e = vec2(0.001, 0.);
    return normalize(vec3(d)-vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x));
}

vec3 trace(vec3 ro, vec3 rd, int steps)
{
    vec3 p = ro;
    for (int i = 0; i < steps && distance(p, ro) < 30.; ++i)
    {
        vec2 res = map(p);
        if (res.x < 0.001)
            return vec3(res.x, distance(p, ro), res.y);
        p+=rd*res.x*.5;
    }
    return vec3(-1.);
}

vec3 getCam(vec3 rd, vec2 uv)
{
    float fov = 1.;
    vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
    vec3 u = normalize(cross(rd, r));
    return normalize(rd+fov*(r*uv.x+u*uv.y));
}



vec3 rdr3D(vec2 uv)
{
    vec3 col = vec3(0.);
    
    float t = iTime;
    float d = 5.;
    vec3 ro = vec3(sin(t)*d,-2.*sin(iTime),cos(t)*d);
    vec3 ta = vec3(0.,0.,0.);
    vec3 rd = normalize(ta-ro);
    
    rd = getCam(rd, uv);
    vec3 res = trace(ro, rd, 256);
    if (res.y > 0.)
    {
        vec3 p = ro+rd*res.y;
        vec3 n = getNorm(p, res.x);
        col = n*.5+.5;
        if (res.z == 0.)
        {
            col = vec3(1.);
            vec3 refv = vec3(0.,1.,0.);
            refv.yz *= rot(PI*.25);
            if (sat(abs(dot(n,refv))) < 0.1)
                col = vec3(0.2);
        }
        if (res.z == 1.)
        {
            col = vec3(0.141,0.557,1.000);
            if (sat(abs(dot(n, vec3(0.,1.,0.)))) < 0.8)
            {
                vec3 lpos = vec3(0.,-5.,5.);
                vec3 ldir = normalize(lpos-p);
                
                col = vec3(1.,0.,0.)*sat(dot(n,ldir));
            }
        }
        col = mix(vec3(.2,.5,.6), vec3(0.5,.1,.1), col.x);
    }
    
    return col;
}

vec3 rdr(vec2 uv)
{
    vec3 col = vec3(0.);
    uv = abs(uv);
    for (float i = 0.; i < 32.; ++i)
    {
        vec2 p = uv+vec2(sin(i*.5+iTime*.3), cos(i))*1.5;
        
        p *= rot(sin(i*.15-iTime)+iTime*.1);
        float scalef=mod(iTime+i*.1, 1.);
        p *= mix(1.,.5, scalef);
        vec4 sampl = texture(iChannel0, (p+.5-vec2(0.,.2)));
        vec3 rgb = mix(vec3(0.247,0.133,0.133), sat(abs(p.y))*vec3(0.027,0.431,0.259), sampl.x);
        rgb *= 1.-sampl.z;
        rgb.xy *= rot(i+iTime);
        rgb = abs(rgb)*3.;
        col = mix(col, rgb, sampl.w*mix(0.,1., scalef));

    }
    col += vec3(1.000,0.824,0.439)*pow(1.-sat(lenny(uv)*.5),.8);
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.xx;
    vec3 col = rdr(uv*6.*(1.-length(uv)*.5));
    vec3 d3 = rdr3D(uv*.9);
    col = mix(col, col+d3, length(d3));
    fragColor = vec4(col,1.0);
}