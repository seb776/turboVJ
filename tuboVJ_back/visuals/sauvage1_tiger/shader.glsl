#define sat(a) clamp(a, 0., 1.)
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))
float speed = 1.;
float tentacle(vec2 uv, float seed)
{   

    float th = mix(.1,.2, sin(seed)*.5+.5);
    if (uv.x >0.)
        return abs(uv.y-sin(uv.x*5.+sin(iTime+seed)*.9+seed+iTime*.3*speed)*.1)-pow(uv.x,.6)*th;
    return 1.;
}

vec3 rdr(vec2 uv)
{
    vec3 col = vec3(0.93, 0.38, 0.75);
    
    for (float i = 0.;i < 7.; ++i)
    {
        vec2 p = (uv)*rot(i*.8)-vec2(0.05,0.);
        float shape = tentacle(p, i);
        col = mix(col, vec3(0.45, 0.03, 0.33), 1.-sat(shape*500.));
    }
    
    float an = atan(uv.y, uv.x);
    float cir1 = length(uv)-.39-sin(an*10.+iTime)*.05;
    col = mix(col, vec3(0.14, 0.22, 0.03), sat(cir1*500.));
    
    vec2 uvt = uv;
    float repx = .55;
    float id = floor((uvt.x+repx*.5)/repx);
    uvt.x = mod(uvt.x+repx*.5,repx)-repx*.5;
    vec4 tex = texture(iChannel0, (uvt*.25-.5+vec2(sin(iTime+uvt.y*5.+id)*.01,id*.09+iTime*.01)));
    col = mix(col, vec3(0.09, 0.42, 0.41), tex.w);
    col = mix(col, vec3(0.02, 0.14, 0), tex.w*(1.-tex.x));
    
    
    col *= pow(sat(length(uv)-.1),.4)*2.;
    vec2 uvf = (uv*.5-.5)-vec2(0.,-.05);
    float px = .002*sin(iTime);
    uvf = floor(uvf/px)*px;
    vec4 face = texture(iChannel1, uvf);
    col = mix(col, face.xyz, face.w);
    
    col *= sat(fwidth(col.x)*15.+.2);
    float facel = texture(iChannel2, uvf).x;
    col += vec3(1.,0.1,0.1)*facel*2.;
    col += vec3(1.,.1,.05)*(1.-sat(length(uv)*2.))*.5;
    if (sin(iTime*.1)< 0.)
      return col;
    float beat = 1./2.;
        beat = mod(iTime, beat)/beat; 
        
        col = mix(vec3(0.), vec3(0.996,0.447,0.690), 
        mix(1.-sat(face.x), sat(face.x), beat));
    for (float i = 0.; i < 16.; ++i)
    {
        vec2 uvmask = uvf+vec2(sin(i), cos(i))*i*.002;
        float facemask = texture(iChannel1, uvmask).x;
    
        col += mix(vec3(0.), vec3(0.996,0.145,0.612), beat*sat(facemask))/16.;
    }
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.xx;

    vec3 col = rdr(uv);

    fragColor = vec4(col,1.0);
}