// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0
// Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ 
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
// =========================================================================================================

#define sat(a) clamp(a,0.,1.)
#define PI acos(-1.)
mat2 r2d(float a)
{
  float c = cos(a), s= sin(a);
   return mat2(c,-s,s,c);
}
vec3 getCam(vec3 rd, vec2 uv)
{
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+(r*uv.x+u*uv.y)*.6);

}

float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}



vec2 _min(vec2 a, vec2 b)
{
  if(a.x<b.x)
  return a;
  return b;
}
float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}
vec2 map(vec3 p)
{
  vec2 acc = vec2(1000.,-1.);
  float repx = .5;
  float idx = floor((p.x+repx*.5)/repx);
  p.x = mod(p.x+repx*.5,repx)-repx*.5;
  float repy =5.;
  p.y= mod(p.y+repy*.5,repy)-repy*.5;

  p.yz*=r2d(length(p.yz)*.5-iTime*.1+idx*5.-.4*iTime*abs(sin(idx+.5)));

  float an = atan(p.y,p.z);
  float rep = PI*2./12.;
  float id = floor((an+rep*.5)/rep);
  p.x+= sin(p.y*20.-iTime*4.)*.02*sat(length(p.yz));
  float sector = mod(an+rep*.5,rep)-rep*.5;
  p.yz = vec2(sin(sector),cos(sector))*length(p.yz);

  float blob = sdCapsule(p,vec3(0.,0.,-0.5),
    vec3(0.,0.,1.5),.12);
    //blob = length(p.xy)-.1;
  p.z-=1.5;
  vec3 pm= p-vec3(0.,0.,-.1);
  vec3 p2 = p;
  p2.x=abs(p2.x);
  p2.xz*= r2d(.5);
  //p2.x=abs(p2.x);
  blob = min(blob, length(p2.xy)-.002);
  blob = max(blob,p.z-.2);
  vec3 p3 =p;
  p3.x= abs(p3.x);
  blob = min(blob,length(p3-vec3(0.1,0.,.2))-.02);
  p.x= abs(p.x);
  float eyes = length(p.xz-vec2(.03,0.))-.02;

  float mat = sat(eyes*400.);

  float mouth = length(pm.xz)-.05;
  mouth = max(mouth, -pm.z);
  mat = mix(mat, 2., 1.-sat(mouth*400.));

pm.x+= sin(pm.z*150.-7.*iTime)*.01;
  float tongue = sdSegment(pm.xz,
    vec2(0.,0.),vec2(0.,.025))-.01;
    tongue = max(tongue, mouth);
  mat = mix(mat, 3., 1.-sat(tongue*4000.));
  acc= _min(acc, vec2(blob,mat));

  return acc;// length(p-vec3(0.,.0,1.))-.1;
}

vec3 accCol;
vec3 trace(vec3 ro, vec3 rd)
{
    accCol = vec3(0.);
  vec3 p= ro;
  for(int i= 0;i<128 && distance(p,ro)<10.;++i)
  {
    vec2 res = map(p);
    if(res.x<0.01)
      return vec3(res.x,distance(p,ro),res.y);
    p+=rd*res.x*.3;
    vec3 rgb = mix(vec3(0.996,0.290,0.165), 
    vec3(0.996,0.651,0.165), sin(iTime+10.*p.x+p.y)*.5+.5);
    accCol += rgb*(1.-sat(res.x/.2))*.025
    *(1.+texture(iChannel0, vec2(0.1,0.)).x);//*sat(p.y*3.+4.5);
  }
  return vec3(-1.);
}

vec3 getNorm(vec3 p, float d)
{
  vec2 e = vec2(0.01,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x,
    map(p-e.yxy).x,
    map(p-e.yyx).x));
}

vec3 rdr(vec2 uv)
{
  vec3 col = vec3(0.);
  uv.x+=.3;
  vec3 ro = vec3(.5,0.5,-2.);
  vec3 ta = vec3(0.,-3.2,0.);
  vec3 rd = normalize(ta-ro);
  rd = getCam(rd,uv);
  vec3 res = trace(ro,rd);
  if(res.y>0.)
  {
    vec3 p = ro+rd*res.y;
    vec3 n = getNorm(p,res.x);
    col = n*.5+.5;
    col = vec3(.1);
    if(res.z==0.)
    col = vec3(1.);
    if (res.z==2.)
    col = vec3(.7,0.1,0.);
    if (res.z==3.)
    col= vec3(1.,0.3,0.3);
  }
  col += accCol;
  float beat = 1./2.2;
  //col = mix(col, 1.-col, pow(mod(iTime,beat)/beat,2.));
  return col;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 uv = (fragCoord.xy-.5*iResolution.xy)/
    iResolution.xx;
  vec3 col = rdr(uv);
  col *= 1.-sat((length(uv)-.2)*2.);
  fragColor = vec4(col, 1.0);
}