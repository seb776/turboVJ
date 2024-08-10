float _seed;
float hash11(float seed)
{
  return fract(sin(seed*123.456)*123.456);
}
float rand()
{
  return hash11(_seed++);
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
#define sat(a) clamp(a,0.1,1.)

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
col+=accCol;
//col = mix(col, texture(iChannel1,ouv).xyz,.6);
  return col;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 uv = (fragCoord.xy-.5*iResolution.xy) / iResolution.xx;
vec2 ouv = (fragCoord.xy/iResolution.xy);

  _seed = uv.x+length(uv)+iTime;//texture(iChannel0,uv).x+iTime;

  vec3 col = rdr(uv,ouv);
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