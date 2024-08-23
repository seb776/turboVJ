import { Shaders, Node, GLSL } from "gl-react";
import { useSocket } from "../contexts/SocketContext";
import { useEffect, useRef, useState } from "react";
import { SocketPayload } from "../SocketTypes";

export interface KorgNanoKontrol2_VerticalAreaState {
    fader: number;
    knob: number;
    sButton: number;
    mButton: number;
    rButton: number;
}
export interface KorgNanoKontrol2_State {
    rightSide: KorgNanoKontrol2_VerticalAreaState[];
}

const COMPOSER_SHADER = GLSL`#version 300 es

precision highp float;
out vec4 myOutputColor;
in vec2 uv;
uniform vec2 iResolution;
uniform float iTime;
uniform sampler2D visual0Tex;
uniform sampler2D visual1Tex;
uniform sampler2D visual2Tex;
uniform sampler2D visual3Tex;
uniform sampler2D visual4Tex;
uniform sampler2D visual5Tex;
uniform sampler2D visual6Tex;
uniform sampler2D visual7Tex;

uniform float knob0;
uniform float fader0;
uniform float sButton0;
uniform float mButton0;
uniform float rButton0;
uniform float knob1;
uniform float fader1;
uniform float sButton1;
uniform float mButton1;
uniform float rButton1;
uniform float knob2;
uniform float fader2;
uniform float sButton2;
uniform float mButton2;
uniform float rButton2;
uniform float knob3;
uniform float fader3;
uniform float sButton3;
uniform float mButton3;
uniform float rButton3;
uniform float knob4;
uniform float fader4;
uniform float sButton4;
uniform float mButton4;
uniform float rButton4;
uniform float knob5;
uniform float fader5;
uniform float sButton5;
uniform float mButton5;
uniform float rButton5;
uniform float knob6;
uniform float fader6;
uniform float sButton6;
uniform float mButton6;
uniform float rButton6;
uniform float knob7;
uniform float fader7;
uniform float sButton7;
uniform float mButton7;
uniform float rButton7;
#define sat(a) clamp(a, 0., 1.)
#define FFT(a) 1.
#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))

void main() {
    vec2 buv = uv;
    vec2 cuv = uv-.5;
    vec3 col = vec3(0,0,0);
    if (sButton1 > 0.5)
        buv = abs(buv-.5)+.5;
    if (mButton1 > 0.5) {
        float an = atan(cuv.y, cuv.x);
        buv = vec2(mod(an, 3.14/4.)*.15, length(cuv));
    }
    if (rButton1 > 0.5) {
        float an = atan(cuv.y, cuv.x);
        buv = vec2(mod(an, 3.14/2.)*.15, length(cuv));
    }
    col += texture(visual0Tex, buv).xyz * fader0;
    col += texture(visual1Tex, buv).xyz * fader1;
    col += texture(visual2Tex, buv).xyz * fader2;
    col += texture(visual3Tex, buv).xyz * fader3;
    col += texture(visual4Tex, buv).xyz * fader4;
    col += texture(visual5Tex, buv).xyz * fader5;
    col += texture(visual6Tex, buv).xyz * fader6;
    col += texture(visual7Tex, buv).xyz * fader7;

    float time = iTime;
    float flicker = 1./16.;
    col = mix(col, col+vec3(1.,.2,.5)*(1.-sat(length(cuv)))*2., FFT(0.1)*knob1*mod(time, flicker)/flicker);
    col = mix(col, col+vec3(1.,.2,.5).zxy*(1.-sat(length(cuv)))*2., sButton0*mod(time, flicker)/flicker);
    col = mix(col, col.zxy, mButton0*mod(time, flicker)/flicker);
    col = mix(col, 1.-col.zxy, rButton0*mod(time, flicker)/flicker);
  col =mix(col, col.xxx, sat(knob7*2.));
  col.xy *= rot(knob6*6.28); 
  col.yz *= rot(knob6*6.28);
  col = abs(col); 
    myOutputColor = vec4(col, 1.);
}
`;

interface ComposerShaderProps {
    visuals: any[]; // TODO proper type ?
}

export default function ComposerShader(props: ComposerShaderProps) {
    const { socket } = useSocket();
    const [ currentMidi, setCurrentMidi ] = useState<KorgNanoKontrol2_State | undefined>();
    const [time, setTime] = useState<number>(0);

    const refLoop = useRef<number>();

    function handleLoop(curTime: DOMHighResTimeStamp) {
        setTime(curTime / 1000.0);
        refLoop.current = requestAnimationFrame(handleLoop);
    };

    useEffect(()=>{
        handleLoop(0);
        if (socket) {
            socket.onMessage((data) => {
                // console.log("Received korg_nanokontrol2", data.data);
                if (data.method === 'korg_nanokontrol2') {
                    setCurrentMidi(data.data);
                }
            });
        }
    }, []);

    let uniforms = {
        iResolution: [window.innerWidth, window.innerHeight],
        iTime: time,
    };

    currentMidi?.rightSide.map((verticalArea, index) => {
        const object :any = {};

        const knobName = "knob" + index;
        const faderName = "fader" + index;
        const sName = "sButton" + index;
        const mName = "mButton" + index;
        const rName = "rButton" + index;

        object[knobName] = verticalArea.knob;
        object[faderName] = verticalArea.fader;
        object[sName] = verticalArea.sButton;
        object[mName] = verticalArea.mButton;
        object[rName] = verticalArea.rButton;
        
        return object;
    }).forEach((obj) => {
        // console.log("HERERERE2", obj);
        uniforms = {...uniforms, ...obj};
    });
    
    // console.log("HERERERE", uniforms);


    props.visuals.forEach((visual, index) => {
        (uniforms as any)["visual" + index + "Tex"] = visual;
    });

    

    return <>
        <Node ignoreUnusedUniforms shader={{ frag: COMPOSER_SHADER }} uniforms={uniforms}
        />
    </>
}