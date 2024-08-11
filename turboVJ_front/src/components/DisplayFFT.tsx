import { Node, GLSL } from "gl-react";
import { Surface } from "gl-react-dom";
import { useEffect, useState } from "react";

const WIDTH = 500;
const HEIGHT = 100;

const FFTDisplayFrag = GLSL`#version 300 es

precision highp float;
out vec4 myOutputColor;
in vec2 uv;
uniform vec2 iResolution;
uniform float iTime;
uniform float[16] FFT;
#define sat(a) clamp(a, 0., 1.)

vec3 rdr(vec2 uv_) 
{
    float rep = 1./16.;
    float id = floor((uv_.x+rep*.5) / rep);
    uv_.x = mod((uv_.x+rep*.5), rep)-rep*.5;
    float pattern = sin(uv_.y*100.);
    vec3 col = vec3(0.);
    col = sat(pattern)*vec3(1.);
    float h = FFT[int(id+8.)]*.25;
    float mask = max(abs(uv_.x)-rep*.2, uv_.y-h);

    return col*(1.-sat(mask*500.));
}

void main() {
    vec2 cuv = uv-.5;
    vec3 col = rdr(cuv);
    myOutputColor = vec4(col, length(col));
}
`;

export default function DisplayFFT() {
    const [ fft, setFFT ] = useState<number[]>([]);

    useEffect(()=>{
        const intervalIdx = setInterval(()=>{
            const newFFT = [];
            for (let i =0; i < 16; ++i) {
                newFFT.push(Math.random());
            }
            setFFT(newFFT)
        }, 100);
        return () => {
            clearInterval(intervalIdx);
        }
    }, []);

    return <div className="" style={{
        width: WIDTH,
        height: HEIGHT
    }}>

    <Surface width={WIDTH} height={HEIGHT}>
        <Node shader={{frag: FFTDisplayFrag}} uniforms={{FFT: fft}}/>
    </Surface>
    </div>
}