#define sat(a) clamp(a,0.,1.)
#define PI 3.14159265
mat2 r2d(float a){float c = cos(a),s=sin(a);return mat2(c,-s,s,c);}
float _sqr(vec2 uv, vec2 s)
{
  vec2 l = abs(uv)-s;
  return max(l.x,l.y);
}

float _star(vec2 uv, float sz, float t)
{
  float a = atan(uv.y,uv.x);
  float stp = PI*2./4.;
  float sector = mod(a+stp*.5,stp)-stp*.5;
  uv = vec2(sin(sector),cos(sector))*length(uv);
  return _sqr(uv-vec2(0.,sz*2.), vec2(sz*.05,sz));
}

vec3 rdr(vec2 uv, float sharp)
{
  uv*=.5;
  vec2 ouv = uv;

  vec3 col = vec3(0.);
  float shp = 400.*sharp;

  vec2 rep = vec2(.5);
  vec2 id = floor((uv+rep*.5)/rep);
  uv = mod(uv+rep*.5,rep)-rep*.5;
  uv*=r2d(sin(iTime+id.x));

  float sz = .05;
  float maska = sat(sin(id.x*5.+id.y*100.+id.y*5.+length(uv)*15.-iTime*5.));
  float cir = abs(length(uv)-sz*2.)-.001;
  col = maska*vec3(1.)*(1.-sat(_star(uv,sz,0.)*shp));
  col = mix(col,vec3(1.),maska*(1.-sat(cir*shp)));
  col += maska*.5*vec3(1.)*smoothstep(0.,1.,
    1.-sat(_star(uv,sz,0.)*20.*sharp));
  col += maska*.5*vec3(1.)*(1.-sat(cir*20.*sharp));
  col*=vec3(sin(length(id))*.2+.7,.5,.1);
  return col;
}

vec3 rdr2(vec2 uv,vec2 ouv)
{

  vec3 col=rdr(uv*1.5,1.);
  col+= rdr(uv*.5+.1,.25).zxy*.5;
  col+= rdr(uv*2.5+.1,.2).xxx*vec3(.75,.2,.7)*.15;
 col = col*1.5;
 vec3 rgb = vec3(.1,.7,.7);
 rgb.xy*=r2d(iTime);
 rgb= abs(rgb);
 col = mix(col, rgb*2.,
   pow(sat(.05/length(ouv)),1.));
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

  vec2 uv = (fragCoord.xy-.5*iResolution.xy) /iResolution.xx;
  vec2 ouv = uv;
 // uv.x += sin(length(uv)+iTime)*.5;
  uv*=r2d(.1*sin(.5*iTime+5.*length(uv))/length(uv));
  uv = vec2(5.*atan(uv.y,uv.x)/PI,1./length(uv)+5.*iTime);
  vec3 col=rdr2(uv,ouv);
  col = pow(col, vec3(1.4));
  fragColor = vec4(col, 1.0);
}