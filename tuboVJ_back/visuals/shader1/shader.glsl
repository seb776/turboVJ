#define sat(a) clamp(a, 0., 1.)
float _seed;
float hash11(float seed)
{
  return fract(sin(seed*123.456)*123.456);
}
float rand()
{
  return hash11(_seed++);
}
float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

vec3 grad(float f)
{
    float stp = 0.01;
    f = sat(f);
    f = floor(f/stp)*stp;
    vec3 cols[5];
    
    cols[0] = vec3(0.58f, 1.f, 0.2f);
    cols[1] = vec3(1.f, 0.f, 0.56f);
    cols[2] = vec3(0.07f, 0.18f, 0.38f);
    cols[3] = vec3(0.0);
    cols[4] = vec3(0.0);

    float cur = f*4.0;
    int icur = int(floor(cur));
    int next = min(icur+1, 4);
    return mix(cols[icur], cols[next], fract(cur)); 
}

float _cube(vec3 p, vec3 s)
{
  vec3 l = abs(p)-s;
  return max(l.x,max(l.y,l.z));
}
float _cucube(vec3 p, vec3 s,vec3 t)
{
  vec3 l = abs(p)-s;
  float c = max(l.x,max(l.y,l.z));
  l = abs(l)-s*t;

  float x = max(max(l.x,c),l.y);
  float y = max(max(l.z,c),l.y);
  float z = max(max(l.x,c),l.z);
  return min(min(x,y),z);
}
mat2 r2d(float a)
{
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
}

vec3 getCam(vec3 rd, vec2 uv)
{
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd,r));
  return normalize(rd+(r*uv.x+u*uv.y)*.75);
}

vec2 _min(vec2 a, vec2 b)
{
  if(a.x<b.x)
  return a;
  return b;
}

vec2 map(vec3 p)
{
  vec3 op = p;
  vec2 acc = vec2(10000.,-1.);

//acc = _min(acc, vec2(length(p)-1.,0.));
acc = _min(acc, vec2(-p.y,1.));
float time = iTime*.5;
p.z+=time*.65;
vec2 rep = vec2(1.);
vec3 p2 = p-vec3(0.,-.25,0.);
vec2 id = floor((p2.xz+rep*.5)/rep);
float ida = abs(id.x+10.*id.y);
p2.xz = mod(p2.xz+rep*.5,rep)-rep*.5;
float t = time*2.+ida;
p2.y+=abs(sin(t*2.))*.1;
p2.yz*=r2d(-t);

float cube = _cube(p2,vec3(.2));
acc = _min(acc,vec2(cube,ida));
float cubew = _cucube(p2,vec3(.21),vec3(.1));
cubew -= noise(op*20.)*.05;
acc = _min(acc,vec2(cubew,-ida));
  return acc;
}

vec3 getNorm(float d, vec3 p)
{
  vec2 e = vec2(0.01,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x));
}
vec3 accCol;
vec3 trace(vec3 ro, vec3 rd, int steps)
{
  accCol = vec3(0.);
  vec3 p = ro;
  for (int i = 0;i<steps&&distance(p,ro)<40.;++i)
  {
    vec2 res = map(p);
    if (res.x<0.01)
      return vec3(res.x,distance(p,ro),res.y);
    p+=rd*res.x*.35;
      accCol += vec3(1.)*(1.-sat(res.x/.5))*.05;
  }
  return vec3(-1.);
}

float randomSample(float x) 
{
  return texture(iChannel0,vec2(x*.01+iTime*.005)).x;
}

vec3 getMat(vec3 p, vec3 n, vec3 rd, vec3 res)
{
  vec3 col = n*.5+.5;
  float gsz = 5.;
  if (res.z==1.)
  {
    vec2 gridh = sin(p.xz*gsz)-.9;
    col*= 0.*sat(max(gridh.x,gridh.y)*100.);
  }
  if (res.z<0.)
  {
    vec2 gridh = sin(p.xy*gsz)-.9;
    col= vec3(1.)*2.*pow(randomSample(res.z),4.);
  }
  if(res.z>1.)
  col = vec3(0.);
  return col;
}

vec3 rdr(vec2 uv,vec2 ouv)
{

  vec3 col= vec3(0.);
  float t = iTime*.33;
  vec3 ro = vec3(4.,-4.,2.);
  vec3 ta = vec3(0.,0.,0.);
  vec3 rd = normalize(ta-ro);

  rd = getCam(rd,uv);

  vec3 res = trace(ro,rd, 128);
  vec3 acc = accCol;
  float y =-1.;
  if (res.y >0.)
  {
    vec3 p = ro+rd*res.y;
    vec3 n = getNorm(res.x,p);
    y = p.y;
    col = getMat(p,n,rd,res);
    if(res.z != 0.)
    {
      vec3 refl = normalize(reflect(rd,n)
        +(vec3(rand(),rand(),rand())-.5)*.1);
      vec3 resrefl = trace(p+n*.01,refl,128);
      if(resrefl.y>0.)
      {
        vec3 prefl = p+n*.01+refl*resrefl.y;
        vec3 nrefl = getNorm(resrefl.x,prefl);
        col+= getMat(prefl,nrefl,refl,resrefl);
      }
    }
  }
col+=acc;
//col = mix(col, texture(iChannel1,ouv).xyz,.6);
col = grad(1.-col.x);
  return col;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 uv = (fragCoord.xy-.5*iResolution.xy) / iResolution.xx;
vec2 ouv = (fragCoord.xy/iResolution.xy);

  _seed = uv.x+length(uv)+iTime;//texture(iChannel0,uv).x+iTime;

  vec3 col = rdr(uv,ouv);
  if (false)
    { // Not so cheap antialiasing SSAA x4

        vec2 off = vec2(1., -1.)/(iResolution.x*2.);
        vec3 acc = col;
        // To avoid too regular pattern yielding aliasing artifacts
        mat2 rot = r2d(uv.y*5.); // a bit of value tweaking, appears to be working well
        acc += rdr(uv-off.xx*rot,ouv);
        acc += rdr(uv-off.xy*rot,ouv);
        acc += rdr(uv-off.yy*rot,ouv);
        acc += rdr(uv-off.yx*rot,ouv);
        col = acc/5.;
    }
    //  col = texture(iChannel0, uv).xxx;
  fragColor = vec4(col, 1.0);
}