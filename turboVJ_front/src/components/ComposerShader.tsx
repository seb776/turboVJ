import { Shaders, Node, GLSL } from "gl-react";

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

void main() {
    vec2 cuv = uv-.5;
    vec4 outFrag = vec4(1,0,0,1);
    outFrag.xyz = texture(visual0Tex, uv).xyz;
    outFrag.xyz += texture(visual1Tex, uv).xyz*.5;
    myOutputColor = outFrag;
}
`;

interface ComposerShaderProps {
    visuals: any[]; // TODO proper type ?
}

export default function ComposerShader(props: ComposerShaderProps) {
    const uniforms = {
        iResolution: [window.innerWidth, window.innerHeight],
        iTime: 0
    };

    props.visuals.forEach((visual, index) => {
        (uniforms as any)["visual" + index + "Tex"] = visual;
    });

    return <>
        <Node shader={{ frag: COMPOSER_SHADER }} uniforms={uniforms}
        />
    </>
}