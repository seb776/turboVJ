// Fork of "3D Blobs" by z0rg. https://shadertoy.com/view/stlcWr
// 2025-01-06 21:20:45

// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0
// Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ 
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
// =========================================================================================================

#define sat(a) clamp(a,0.,1.)

vec3 camp;

vec2 map(vec3 p)
{
  vec2 acc = vec2(1000.,-1.);

  float a = texture(iChannel0, p.xz*.01+vec2(0.,iTime)*0.001).x-.4;
  float b = texture(iChannel0,p.xy*0.02+vec2(iTime,0.)*0.002).x-.1;
  return vec2(max(-a*b+.2,-(length(p-camp)-1.)),0.);//*texture2D(noise,p.xz).x-.5,0.);

  return acc;
}
vec3 accCol;
vec3 trace(vec3 ro, vec3 rd, int steps)
{
  camp = ro;
  vec3 p = ro;
  for (int i = 0; i<steps&& distance (p,ro)<15.;++i)
  {
    vec2 res = map(p);
    res.x = min(res.x,.9);
    if (res.x<0.001)
      return vec3(res.x,distance(p,ro),res.y);
    accCol+= sat(.5+.5*sin(length(p)*20.-5.*iTime))*.03*mix(vec3(0.278,0.514,0.212),vec3(.2,.5,.4),sat(abs(p.x*1.))*(1.-sat(res.x/.5)));
    p+= rd*res.x*.75;
  }
  return vec3(-1.);
}

vec3 getCam(vec3 rd, vec2 uv)
{
  float fov = 1.;
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 u = normalize(cross(rd,r));
  return normalize(rd+fov*(r*uv.x+u*uv.y));
}

vec3 getNorm(vec3 p, float d)
{
  vec2 e = vec2(0.001,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x));
}



vec3 rdr(vec2 uv)
{
  vec3 col;

  float z = mod(iTime,18.);
  vec3 ro = vec3(0.,-5.,-5.+z);
  vec3 ta = vec3(0.,-1.,z);
  float t = mod(iTime,9.);
  if (t<3.)
  {
  }
  else if(t<6.)
  {
    ta = vec3(-5.,0.,0.);
  }
  else
  {
    ro = vec3(sin(iTime),sin(iTime*.5),cos(iTime));
  }
  vec3 rd = normalize(ta-ro);

  rd = getCam(rd,uv);
  accCol = vec3(0.);
  vec3 res = trace(ro,rd,128);
  float depth = 5.;
  if (res.y>0.)
  {
    vec3 p = ro+rd*res.y;
    vec3 n = getNorm(p,res.x);
    col = n*.5+.5;
    vec3 rgb = mix(vec3(0.),vec3(0.976,0.157,0.447)*2.,sat((sin((p.x+p.z)*20.)-.75)*400.));
    col = rgb;
    depth = res.y;
  }
  col+= accCol.zxy;
    col = mix(col, col*.2, depth/10.);
    col = mix(col, col.zxy, 1.-sat((length(uv)-.2)*500.));
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 uv = (fragCoord.xy-vec2(.5)*iResolution.xy) / iResolution.xx;
  vec3 col = rdr(uv);
  //col = pow(col,vec3(1.45));
  //col += col/(2.+col);
  //col *= 1.5*(1.-sat(length(uv)));
  //col *= pow(1.-sat(length(uv)-.2), 2.);
  fragColor = vec4(col, 1.0);
}