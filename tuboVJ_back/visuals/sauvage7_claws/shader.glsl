#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))
#define sat(a) clamp(a, 0., 1.)


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.xx;
    uv *= rot(.5+iTime*.05);
    uv *= 2.;
    uv *= 1.-length(uv)*.5;
    vec3 col = vec3(0.);
    vec2 rep = vec2(.12);
    uv.x += iTime*.05;
    vec2 id = floor((uv+rep*.5)/rep);
    uv = mod(uv+rep*.5,rep)-rep*.5;
    uv *= rot(length(id)*5.31+id.x*3.3);
    float sz = mix(1.,2.,texture(iChannel1, id*.1).x);
    float off = texture(iChannel1, id*.01).x;
    col = texture(iChannel0, uv*5.*sz+.5).xxx*sat(sin(off*10.+uv.y*10.-3.*iTime));
    col *= pow(texture(iChannel1, id*.02).x, 4.)*15.;
    col *= vec3(1.,.2,.3);
    fragColor = vec4(col,1.0);
}