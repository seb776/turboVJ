import { Shaders, Node, GLSL } from "gl-react";
import { useSocket } from "../contexts/SocketContext";
import { useEffect, useState } from "react";
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

void main() {
    vec2 cuv = uv-.5;
    vec4 outFrag = vec4(0,0,0,1);
    outFrag.xyz += texture(visual0Tex, uv).xyz * fader0;
    outFrag.xyz += texture(visual1Tex, uv).xyz * fader1;
    // outFrag.xyz += texture(visual2Tex, uv).xyz * fader2;
    // outFrag.xyz += texture(visual3Tex, uv).xyz * fader3;
    // outFrag.xyz += texture(visual4Tex, uv).xyz * fader4;
    // outFrag.xyz += texture(visual5Tex, uv).xyz * fader5;
    // outFrag.xyz += texture(visual6Tex, uv).xyz * fader6;
    // outFrag.xyz += texture(visual7Tex, uv).xyz * fader7;
    myOutputColor = outFrag;
}
`;

interface ComposerShaderProps {
    visuals: any[]; // TODO proper type ?
}

export default function ComposerShader(props: ComposerShaderProps) {
    const { socket } = useSocket();
    const [ currentMidi, setCurrentMidi ] = useState<KorgNanoKontrol2_State | undefined>();

    useEffect(()=>{
        if (socket) {
            socket.onMessage((data) => {
                console.log("Received korg_nanokontrol2", data.data);
                if (data.method === 'korg_nanokontrol2') {
                    setCurrentMidi(data.data);
                }
            });
        }
    }, []);

    let uniforms = {
        iResolution: [window.innerWidth, window.innerHeight],
        iTime: 0,
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
        console.log("HERERERE2", obj);
        uniforms = {...uniforms, ...obj};
    });
    
    console.log("HERERERE", uniforms);


    props.visuals.forEach((visual, index) => {
        (uniforms as any)["visual" + index + "Tex"] = visual;
    });

    

    return <>
        <Node ignoreUnusedUniforms shader={{ frag: COMPOSER_SHADER }} uniforms={uniforms}
        />
    </>
}