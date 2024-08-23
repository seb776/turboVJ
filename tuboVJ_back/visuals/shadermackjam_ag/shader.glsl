// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0
// Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ 
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
// =========================================================================================================

#define FFTI(a) iTime
//texture(texFFTIntegrated, a).x
#define FFTS(a) (texture(iChannel1, vec2(a, 0.)).x*.2)
#define sat(a) clamp(a, 0., 1.)
#define PI 3.14159265

float _seed;
float hash11(float seed)
{
  return fract(sin(seed*123.456)*123.456);
}

float rand()
{
  return hash11(_seed++);
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
  return mix(max(l.x, max(l.y, l.z)), length(p)-s.x, 1.1);
}

mat2 r2d(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c);}

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

vec2 map(vec3 p)
{
  vec3 op = p;
  vec2 acc = vec2(10000.,-1.);
  
  acc = _min(acc, vec2(length(p+vec3(0.,0.,-15.))-1., 0.));
 
  p.xz *= r2d(.5*sin(.1*p.y));
  p.xz += vec2(sin(iTime), cos(iTime*5.1+p.y*.1))*1.;
  float rad = 20.;
  vec3 pdart = p+vec3(0.,FFTI(.05)*20.+iTime*85.,0.);
  float adart = atan(pdart.z, pdart.x);
  float stpdart = PI*2./10.;
  float sector = mod(adart+stpdart*.5,stpdart)-stpdart*.5;
  pdart.xz = vec2(sin(sector), cos(sector))*length(pdart.xz);
  float repyd = 15.;
  float idda = floor((pdart.y+repyd*.5)/repyd);
//  pdart.xz *= r2d(idda);
  float rada = mix(10.,40.,sin(idda)*.5+.5);
  pdart -= vec3(0.,45.,rada);
  pdart.y = mod(pdart.y+repyd*.5,repyd)-repyd*.5;
  float dart = _cube(pdart, vec2(.1,5.).xxy);
  acc = _min(acc, vec2(length(pdart-vec3(0.,0.,-5.))-0.25,-1.));
  
  acc = _min(acc, vec2(dart, 0.));
  
  vec3 pcube = p;
  float stpcube = PI*2./4.;
  float sectorcube = mod(adart+stpcube*.5,stpcube)-stpcube*.5;
  pcube.xz = vec2(sin(sectorcube), cos(sectorcube))*length(pcube.xz);
  float repyc = .5;
  float radb = mix(10.,20.,sin(repyc)*.5+.5);
  pcube -= vec3(0.,0.,radb);

  pcube.y = mod(pcube.y+repyc*.5,repyc)-repyc*.5;
  acc = _min(acc, vec2(_cube(pcube, vec3(.5,.2,2.)), 1.));
  
  float tunnel = -(length(p.xz)-rad);
  acc = _min(acc, vec2(tunnel, 0.));
  
  vec3 pcc = op-vec3(0.,55.,0.);
  pcc.xz *= r2d(iTime);
  pcc.yz *= r2d(.5*iTime);
  acc = _min(acc, vec2(_cucube(pcc-vec3(0.,15.,0.), vec3(1.), vec3(.01)), -5.));
  
  return acc;
}

vec3 getCam(vec3 rd, vec2 uv)
{
  float fov = 1.;
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+fov*(r*uv.x+u*uv.y));
}

vec3 getNorm(vec3 p, float d)
{
  vec2 e = vec2(0.01,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x)); 
}
vec3 accLight;
vec3 trace(vec3 ro, vec3 rd, int steps)
{
  accLight = vec3(0.);
  vec3 p  = ro;
  for (int i = 0; i < steps; ++i)
  {
    vec2 res = map(p);
    if (res.x < 0.01)
      return vec3(res.x, distance(p, ro), res.y);
    if (res.y < 0.)
      accLight += (vec3(172, 38, 235)/255.)*0.1+vec3(sin(distance(p, ro)*1.+iTime)*.5+.5, .5, .1)*(1.-sat(res.x/5.5))*.2*sat(sin(p.y*.05+5.*iTime));

    p+=rd*res.x*.5;
  }
  return vec3(-1.);
}

vec3 rdr(vec2 uv)
{
  vec3 background = vec3(212, 140, 32)/255.;
  vec3 col = background;
  
  vec3 ro = vec3(0.,-5.,-5.);
  vec3 ta = vec3(sin(iTime)*5.,85.,0.);
  vec3 rd = normalize(ta-ro);
  
  rd = getCam(rd, uv);

  float depth = 150.;
  vec3 res = trace(ro, rd, 128);
  if (res.y > 0.)
  {
    depth = res.y;
    vec3 p = ro+rd*res.y;
    vec3 n = getNorm(p, res.x);
    col = n*.5+.5;
    
    col = (vec3(23, 24, 51)/255.)*sat(dot(normalize(vec3(n.x, -1., n.z)), n));
  }
  col += accLight;
  col = mix(col, vec3(0.), 1.-sat(exp(-depth*depth*0.0001)));
  return col;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy-.5*iResolution.xy)/iResolution.xx;
  
  //uv *= r2d(-iTime*.5);
  //uv = abs(uv);
  //uv -= vec2(.2+uv.y, 0.);
  //uv *= r2d(.1*iTime);
  //uv = abs(uv);
 float stp = .01*length(uv);
  //uv = floor(uv/stp)*stp;
  
  //uv -= vec2(.25);
  //uv *= r2d(FFTI(.1)*10.);
 // uv = abs(uv);
  
  vec3 col = rdr(uv);
  
  col *= 1.-sat(length(uv));
  //col = mix(col, vec3(199, 242, 58)/255., 1.-pow(sat(length(col)),8.));
  col = pow(col, vec3(1.45));
  //col *= vec3(199, 242, 58)/255.;
  float beat = 1./8.;
  col += (mod(iTime, beat)/beat)*sat(FFTS(.1)*col)*45.;
  //col = mix(col, texture(iChannel0, gl_FragCoord.xy/iResolution.xy).xyz, .5);
  col.xy *= r2d(iTime*.5);
  col = abs(col);
	fragColor = vec4(col, 1.);
}