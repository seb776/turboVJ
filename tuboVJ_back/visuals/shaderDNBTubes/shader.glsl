const float PI = 3.14159265;
mat2 r2d(float a){float sa = sin(a);float ca=cos(a);return mat2(ca,sa,-sa,ca);}
float time;

float lenny(vec2 v)
{
  return abs(v.x)+abs(v.y);
}
float sat(float a)
{
  return clamp(a,0.,1.);
}
vec3 sat(vec3 v)
{
  return vec3(sat(v.x),sat(v.y), sat(v.z));
}
float _sub(float a, float b)
{
  return max(a,-b);
}
float _union(float a, float b)
{
  return min(a, b);
}
float _cir(vec2 uv, float sz)
{
  return length(uv)-sz;
}

float _loz(vec2 uv,float sz)
{
  return lenny(uv)-sz;
}

float _sdSph(vec3 uv)
{
    // TODO sphere like freq ball done with bonzomatic
    return length(uv)-.5;
}



float _sqr(vec2 uv, vec2 sz)
{
  vec2 r = abs(uv)-sz;
  return max(r.x,r.y);
}

vec2 repeat(vec2 uv, vec2 rep)
{
    return mod(uv+0.5*rep,rep)-0.5*rep;
}

vec3 repeat(vec3 uv, vec3 rep)
{
    return mod(uv+0.5*rep,rep)-0.5*rep;
}

float _trees(vec2 uv, float sz, float rep)
{
    uv = repeat(uv, vec2(rep+0.05*sin(uv.y*2.+1.5), 5.));
    return _sqr(uv, vec2(sz, 2.));
}

float _cyl(vec3 p, vec3 a, vec3 b, float r)
{
    vec3  ba = b - a;
    vec3  pa = p - a;
    float baba = dot(ba,ba);
    float paba = dot(pa,ba);
    float x = length(pa*baba-ba*paba) - r*baba;
    float y = abs(paba-baba*0.5)-baba*0.5;
    float x2 = x*x;
    float y2 = y*y*baba;
    
    float d = (max(x,y)<0.0)?-min(x2,y2):(((x>0.0)?x2:0.0)+((y>0.0)?y2:0.0));
    
    return sign(d)*sqrt(abs(d))/baba;
}

vec3 lookAt(vec3 dir, vec2 uv)
{
  dir = normalize(dir);
  vec3 right = -normalize(cross(dir, vec3(0., 1., 0.)));
  vec3 up = normalize(cross(dir, right));
vec2 fov = vec2(2.);
  return dir+right*uv.x*fov.x+up*uv.y*fov.y;
}
float rng(float a, float mi, float ma)
{
    return float(a > mi && a < ma);
}

vec3 texCross(vec2 uv)
{
    uv += .5*vec2(sin(time), cos(time));
    uv *= r2d(time);
    uv *= 3.;
    uv = repeat(uv, vec2(1.));
    float coef = _union(_sqr(uv, vec2(.01, .2)), _sqr(uv, vec2(.01, .2).yx));
    return (1.-sat(coef*200.))*vec3(.34,.43,.56); 
    return vec3(0.);
}

float map(vec3 p)
{
    
    p.xy *= r2d(time);
    p = repeat(p, vec3(2.));
    //p.yz *= r2d(time);
    float len = 5.;
    float rad = .5;
    float a = _cyl(p, vec3(0.,-len, 0.), vec3(0.,len, 0.), rad);
    float b = _cyl(p, vec3(-len, 0., 0.), vec3(len, 0., 0.), rad);
    float c = _cyl(p, vec3(0.,0.,-len), vec3(0.,0.,len), rad);
    return _union(a, _union(b, c));
}

vec3 rdr3D(vec2 uv)
{
    vec3 lookAtPos = vec3(0.);
    vec3 orig = vec3(sin(time), cos(time), -2.5);
    vec3 dir = lookAt(lookAtPos - orig, uv); 
    vec3 p = orig + dir;
    float dist = 0.;
    for (int i = 0; i < 256; ++i)
    {
        float d = map(p);
        if (d < 0.001)
        {
            return vec3(.5)*sat(dist);
        }
        dist += d;
        p += dir * d*0.999;
    }
    return vec3(0.);
}

vec3 rdrScn(vec2 uv)
{
  vec3 land;
  vec3 light = vec3(100.,200.,197.)/255.;
  land = mix(vec3(.1,.1,.2),light,sat(.0+sat(1.-length(uv))));
    
  float trees = _trees(uv+vec2(time, 0.).yx, 0.05+sin(time+uv.x)*.1, 0.3);
  
  //land += .2*vec3(.5,.7,.74)*(sat(trees*20.));
land += light*sat(1.-lenny(uv*.5))*(sin(time+uv.x+PI)*.5+.5);
    vec3 blackStripsCol = texCross(uv)*(1.-sat(trees*250.));
  return land+rdr3D(uv)*(sat(.8+sat(trees*50.)))+blackStripsCol*.5;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    time = iTime*.2;
  vec2 uv = fragCoord.xy / iResolution.xx;
  uv -= vec2(.5)*iResolution.xy/iResolution.xx;
//  uv*= 4.2; // horizontal
uv*= 3.2+smoothstep(0., .439, mod(time,.4389))*.1; //vertical
    uv *= r2d(PI/12.);
  vec3 col = rdrScn(uv);


  fragColor = vec4(col, 1.0);
}
