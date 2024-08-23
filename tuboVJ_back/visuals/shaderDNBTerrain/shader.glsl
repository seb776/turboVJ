const vec3 EPS = vec3(0.01,0.,0.);
const float PI = 3.14159265;
mat2 r2d(float a){float sa = sin(a);float ca=cos(a);return mat2(ca,sa,-sa,ca);}

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
float _cir(vec2 uv, float sz)
{
  return length(uv)-sz;
}

float _loz(vec2 uv,float sz)
{
  return lenny(uv)-sz;
}

float _sqr(vec2 uv, vec2 sz)
{
  vec2 r = abs(uv)-sz;
  return max(r.x,r.y);
}

float _sqr(vec3 p, vec3 sz)
{
  vec3 r = abs(p)-sz;
  return max(max(r.x,r.y),r.z);
}
vec3 lookat(vec2 uv, vec3 dir)
{
  float fov = 5.;
  uv *= fov;
  dir = normalize(dir);
  vec3 right = normalize(cross(dir, vec3(0.,1.,0.)));
  vec3 up = normalize(cross(dir, right));

  return dir + uv.x * right + uv.y*up;
}

float map(vec3 p)
{
   float ax = iTime+atan(p.y, p.x);
    float ay = -iTime+atan(p.z, p.y);
    float stepval = EPS.x;
    float snd = texelFetch(iChannel1, ivec2(int(abs(p.x)*1.), 0), 0).x;
    
 
    return -p.y +5.+ 5.*snd+(3.*texture(iChannel0, p.xz*.002+iTime*0.002).x+3.*texture(iChannel0, p.xz*.0002+iTime*0.002).x);

    //
   if (p.y < 5.-2.*pow(texture(iChannel0, p.xz*.002+iTime*0.002).x, .5)*pow(texture(iChannel0, p.xz*.0005).x, .5))//  -.1*sin(p.z)+.5*sin(p.z+sin(p.x))+.3*sin(p.x*.5+p.z)+sat(sin(p.x*2.3))*.01*sin(p.x*50.);
   return EPS.x*100.;
    return -EPS.x*1.;
}

vec3 getNormal( vec3 p )
{
    float d = 8.;
    return normalize( vec3( map(p-d*EPS.xyy) - map(p+d*EPS.xyy),
                            d*EPS.x,
                            map(p-d*EPS.yyx) - map(p+d*EPS.yyx) ) );
}

vec3 normal(vec3 p, float d)
{
	return getNormal(p);
  float xPos = map(p-EPS.xyy);
  float yPos = map(p-EPS.yxy);
  float zPos = map(p-EPS.yyx);
  //return (vec3(xPos, yPos,zPos)-d)/EPS.x;
  return vec3(map(p-EPS.xyy)-map(p+EPS.xyy),
    map(p-EPS.yxy)-map(p+EPS.yxy),
    map(p-EPS.yyx)-map(p+EPS.yyx));
}

vec3 blinn(vec3 L, vec3 N, vec3 V, vec3 p)
{
    vec3 LpV = L + V;
    vec3 H = LpV/ length(LpV);
    float NdotL = dot(N, L);
    
    vec3 sunambient = sat(dot(N, vec3(0.,-1.,1.)))*vec3(.23,.34,.57)*2.;
    vec3 diffuse = sat(NdotL) * vec3(.5,.2,.75) * 50./length(LpV);
    
    float NdotH = dot(N, H);
    
    vec3 spec = pow(sat(NdotH), 1.)*vec3(.4,.6,.9)*2.;
    float snd = texelFetch(iChannel1, ivec2(int(abs(p.x)*1.), 0), 0).x;
    return (diffuse+sunambient+spec)*(2.-mod(length(vec2(0.,-2.)+p.xz*.05)+iTime+snd*5., 2.))*.5;
}

vec4 rdr3D(vec2 uv)
{
  vec3 orig = vec3(0.,.5+sin(iTime)*.5+sin(iTime*.35),-5);
  vec3 lookatpos = vec3(0.);
  vec3 dir = normalize(lookat(uv, lookatpos-orig));
  vec3 p = orig + dir;

  for (int i = 0; i <2024;++i)
  {
    float d = map(p);

    if (d < EPS.x)
    {

      vec3 norm = normalize(normal(p,d));
      //turn vec4(norm*.5+.5,1.);
             vec3 lPos = 15.*vec3(sin(iTime),5., cos(iTime));
        return vec4(blinn(lPos-p, norm, orig-p, p), 1.);
        /*
 
        vec3 OL = ;
        vec3 CamO = ;
        vec3 refl = normalize(reflect(CamO, norm));
        return vec4(vec3(1.)*pow(sat(dot(refl, OL)), 5.) ,1.);
        */
       //rern vec4(dot(norm,normalize(lPos-p))*vec3(1.),1.);
    }
    p+= dir*0.1;
  }
  return vec4(0.);
}

vec3 rdrScn(vec2 uv)
{
  vec3 land;
  vec3 light = .5*vec3(239,114,116)/255.;
   // float coef = 
  land = mix(light,vec3(.1,.1,.2),sat(1.-length(uv)));
  vec4 col = rdr3D(uv);
  land = mix(land, col.xyz, col.w);
  return land;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 uv = fragCoord.xy / iResolution.xx;
  uv -= vec2(.5)*iResolution.xy/iResolution.xx;
//  uv*= 4.2; // horizontal
uv*= 4.2; //vertical

    //uv.x = abs(uv.x);

    vec2 newUv2 = vec2(.5*mod(atan(uv.x, uv.y), .7*PI*1.)/PI, 0.1/(-length(uv)));
    vec2 newUv = vec2(.5*atan(uv.x, uv.y)/PI, .1*(-length(uv)));
  vec3 col;// = rdrScn(newUv);
col += rdrScn(newUv2);
     col += (1.-sat(lenny(uv*vec2(.4,1.))))*vec3(.23,.12,.34)*5.;
col *= 1.-length(uv*.5);
  fragColor = vec4(col, 1.0);
}