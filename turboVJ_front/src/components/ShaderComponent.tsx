import React, { useEffect, useRef, useState } from "react";
import { Shaders, Node, GLSL, Uniform } from "gl-react";
import { Surface } from "gl-react-dom";
import { useSocket } from "../contexts/SocketContext";
import ComposerShader, { KorgNanoKontrol2_State } from "./ComposerShader";

const shaderTemplate = GLSL`#version 300 es

precision highp float;
out vec4 myOutputColor;
in vec2 uv;
uniform vec2 iResolution;
uniform float iTime;

___REPLACE___ME___

void main() {
    vec2 cuv = uv-.5;
    vec4 outFrag = vec4(1,0,0,1);
    mainImage(outFrag, uv*iResolution);
    myOutputColor = outFrag;
}
`

interface IShaderProps {
    code: string;
    uniforms: UniformDTO[];
}
export const MainShader = (props: IShaderProps) => {
    const refMidi = useRef<KorgNanoKontrol2_State>();
    const { socket } = useSocket();
    const refNode = useRef<any>();
    const [width, setWidth] = useState<number>(0);
    const [height, setHeight] = useState<number>(0);
    const [time, setTime] = useState<number>(0);

    const refLoop = useRef<number>();

    function handleResize() {
        // console.log("WINDOW", window.innerWidth, window.innerHeight, refNode);
        setWidth(window.innerWidth);
        setHeight(window.innerHeight);
    }

    function handleLoop(curTime: DOMHighResTimeStamp) {
        let offsetTime = refMidi ? refMidi.current?.rightSide[2].knob : 0;
        if (refMidi)
        console.log("OFFSET", refMidi.current?.rightSide[2].knob)
        setTime(curTime / 1000.0 + (offsetTime-0.5)*10.);
        refLoop.current = requestAnimationFrame(handleLoop);
    };
    useEffect(() => {
        window.addEventListener("resize", handleResize);
        if (socket) {
            socket.onMessage((data) => {
                console.log("Received korg_nanokontrol2", data.data);
                if (data.method === 'korg_nanokontrol2') {
                    refMidi.current = data.data;
                }
            });
        }
        handleResize();
        handleLoop(0);
        return () => {
            window.removeEventListener("resize", handleResize);
            if (refLoop && refLoop.current)
                cancelAnimationFrame(refLoop.current);
        }
    }, []);

    const code = structuredClone(shaderTemplate);
    const newCode = code.replace("___REPLACE___ME___", props.code);
    // {frag: shaders.code}
    const uniforms = { iResolution: [width, height], iTime: time };
    const uniformsOptions = {};
    props.uniforms.forEach(el => {
        (uniforms as any)[el.name] = el.source;
        (uniformsOptions as any)[el.name] = {
            wrap: "repeat"
        };
    })
    // console.log("UNIFORMS ", uniforms)
    return <Node ignoreUnusedUniforms ref={refNode} shader={{ frag: newCode }} uniforms={uniforms} uniformsOptions={uniformsOptions} />;
};

interface ShaderProps {
}

const API_ROOT = "http://localhost:8080";


interface UniformDTO {
    name: string;
    source: string;
}

interface VisualDTO {
    type: string;
    source: string;
    uniforms: UniformDTO[];
}

interface VisualsDTO {
    visuals: VisualDTO[];
}

interface ReadyVisualDTO {
    code: string;
    uniforms: UniformDTO[];
}

export const ShaderSurface = (props: ShaderProps) => {
    const { socket } = useSocket();

    const [visuals, setVisuals] = useState<ReadyVisualDTO[]>([]);

    const [width, setWidth] = useState<number>(0);
    const [height, setHeight] = useState<number>(0);

    useEffect(() => {
        fetch(`${API_ROOT}/visuals`).then(b => b.text()).then(text => {
            const visualsJsonObj = JSON.parse(text) as VisualsDTO;
            const visualsDTO = visualsJsonObj.visuals;
            Promise.all(visualsDTO.map(el => handleClick(el))).then((visuals) => {
                setVisuals(visuals);
            })
        })
    }, []);

    function handleResize() {
        setWidth(window.visualViewport?.width ?? window.innerHeight);
        setHeight(window.visualViewport?.height ?? window.innerHeight);
    }


    useEffect(() => {
        handleResize();
        window.addEventListener("resize", handleResize);
        return () => {
            window.removeEventListener("resize", handleResize);
        }
    }, []);

    function handleClick(visual: VisualDTO): Promise<ReadyVisualDTO> {
        return new Promise((resolve, reject) => {

            fetch(`${API_ROOT}/resource/${btoa(visual.source)}`).then(b => b.text()).then(text => {
                let codeUniforms = "";

                const transformedUniforms: UniformDTO[] = [];

                visual.uniforms.forEach(el => {
                    codeUniforms += `uniform sampler2D ${el.name};\n`;
                    transformedUniforms.push({
                        name: el.name,
                        source: `${API_ROOT}/resource/${btoa(el.source)}`
                    })
                })

                resolve({ code: codeUniforms + "\n\n" + text, uniforms: transformedUniforms })
            })
        });

    }

    return (<div className=" w-full h-full">
        <Surface pixelRatio={0.5} width={width} height={height} style={{ width: '100vw', height: '100vh', justifyContent: 'center' }}>
            <ComposerShader visuals={
                visuals.map(el => <MainShader code={el.code} uniforms={el.uniforms} />)
            } />
        </Surface>
    </div>);
}