mat2 r2d(float a)
{
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
}
#define sat(a) clamp(a,0.1,1.)
float _bbox(vec3 p, vec3 s,vec3 t)
{
  vec3 l = abs(p)-s;
  float c = max(l.x,max(l.y,l.z));
  l = abs(l)-s*t;

  float x = max(max(l.x,c),l.y);
  float y = max(max(l.z,c),l.y);
  float z = max(max(l.x,c),l.z);
  return min(min(x,y),z);
}
float _cube(vec3 p, vec3 sz)
{
  vec3 l = abs(p)-sz;
  return max(max(l.x,l.y),l.z);
}

vec3 getCam(vec3 rd, vec2 uv)
{
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd,r));
  //uv/= 2.2+length(uv)*1.;
  return normalize(rd+(r*uv.x+u*uv.y)*3.);
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

p.xy*=r2d(p.z*.7);
vec3 p2 = p+vec3(0.,0.,iTime*.4);

vec3 rep = vec3(2.,1.,1.1);
float idz = floor((p2.z+rep.z*.5)/rep.z);
p2.xy*=r2d(idz);
p2 = mod(p2+rep*.5,rep)-rep*.5;

//float shape = _bbox(p2,vec3(.3), vec3(.01));
float shape = _cube(p2,vec3(.5));
float rad = sin(p.z*.25+iTime*.5)*.5+1.;
shape = max(shape, -(length(p.xy)-rad));
acc = _min(acc, vec2(shape,0.));


  return acc;
}

vec3 getNorm(float d, vec3 p)
{
  vec2 e = vec2(0.01,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x));
}
vec3 accCol;
vec4 trace(vec3 ro, vec3 rd, int steps)
{
  accCol = vec3(0.);
  vec3 p = ro;
  for (int i = 0;i<steps&&distance(p,ro)<100.;++i)
  {
    vec2 res = map(p);
    if (res.x<0.01)
      return vec4(res.x,distance(p,ro),res.y,float(i));
    accCol += vec3(.1,sin(p.z*3.),sin(p.z)*.5+.5)*
      (1.-sat(res.x/0.4))*.07;
    p+=rd*res.x;

  }
  return vec4(-1.);
}

vec3 rdr(vec2 uv)
{

  vec3 col= vec3(0.);


  float t = iTime*.1;

  vec3 ro = vec3(0.,sin(t*.5)*.5,cos(t)*1.);
  vec3 ta = vec3(0.1,0.,0.);
  vec3 rd = normalize(ta-ro);

  rd = getCam(rd,uv);
  float steps = 128.;
  vec4 res = trace(ro,rd, 128);
  if (res.y >0.)
  {
    steps = res.w;
    vec3 p = ro+rd*res.y;
    vec3 n = getNorm(res.x,p);
    col = n*.5+.5;
    col = vec3(.2,.3,.5)*.5;
  }
  col = mix(col, vec3(1.,.4,.3)*1.,(steps/128.)*(.5+length(uv)));
col+=accCol;
col = pow(col, vec3(1.5));
  return col;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 uv = (fragCoord.xy-.5*iResolution.xy) / iResolution.xx;



  vec3 col = rdr(uv*2.);

  fragColor = vec4(col, 1.0);
}