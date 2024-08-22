import { useEffect, useState } from "react";
import { useSocket } from "../contexts/SocketContext"
import TurboButton from "../components/TurboButton";
import ProgressBar from "../components/ProgressBar";
import WindowComponent from "../components/WindowComponent";
import DisplayFFT from "../components/DisplayFFT";
import VisualItemDisplay from "../components/VisualItemDisplay";
import {DndContext} from '@dnd-kit/core';
import { SocketPayload } from "../SocketTypes";

export interface HardwareStats {
    GPUUsage: number;
    GPUTemperature: number;
    GPUTotalMemory: number;
    GPUUsedMemory: number;

    CPUUsage: number;
    CPUTemperature: number;
    CPUTotalMemory: number;
    CPUUsedMemory: number;

}
export default function ControlPage() {
    const { socket } = useSocket();
    const [stats, setStats] = useState<HardwareStats>({
        GPUUsage: 0,
        GPUTemperature: 0,
        GPUTotalMemory: 0,
        GPUUsedMemory: 0,
        CPUUsage: 0,
        CPUTemperature: 0,
        CPUTotalMemory: 0,
        CPUUsedMemory: 0,
    });

    const [fft, setFFT] = useState<number[]>([]);

    useEffect(() => {
        if (socket) {
            socket.onMessage((data) => {
                console.log("Received message control page", data);
                if (data.method === 'hardware_stats') {
                    setStats(data.data);
                }
            });
        }
        // TODO clear callback ?
    }, []);


    const gpuStats = [
        {
            displayName: "GPUTemp",
            progress: stats.GPUTemperature / 100.0,
            value: stats.GPUTemperature + "C"
        },
        {
            displayName: "GPUUse",
            progress: stats.GPUUsage / 100.0,
            value: stats.GPUUsage + "%"
        },
        {
            displayName: "GPUMem",
            progress: stats.GPUUsedMemory / stats.GPUTotalMemory,
            value: stats.GPUUsedMemory + " / " + stats.GPUTotalMemory + " MiB"
        }
    ]
    const cpuStats = [
        {
            displayName: "CPUTemp",
            progress: stats.CPUTemperature / 100.0,
            value: stats.CPUTemperature + "C"
        },
        {
            displayName: "CPUUse",
            progress: stats.CPUUsage / 100.0,
            value: Math.round(stats.CPUUsage) + "%"
        },
        {
            displayName: "CPUMem",
            progress: stats.CPUUsedMemory / stats.CPUTotalMemory,
            value: Math.round(stats.CPUUsedMemory) + " / " + Math.round(stats.CPUTotalMemory) + " MiB"
        }
    ]
    return <>
        <div className="absolute w-full h-full" style={{
            background: "linear-gradient(0deg, rgba(2,0,36,1) 0%, rgba(30,30,91,1) 35%, rgba(31,71,130,1) 100%)",
        }}>
            <div className="absolute w-full h-full bg-black opacity-60" />
            <div className="absolute w-full h-full p-8  flex flex-col gap-10">

                <div className="absolute">
                    <DisplayFFT />
                </div>
                <div className="relative w-[700px] flex items-center justify-center left-[50%] translate-x-[-50%]" style={{ aspectRatio: '1800/400' }}>
                    <div className="absolute w-full h-full" style={{
                        backgroundImage: 'url(./UI/RoundBar.png)',
                        backgroundSize: 'contain'
                    }}>

                    </div>
                    <div className="absolute z-[500] flex">
                        <TurboButton state={false} />
                        <div className="absolute bottom-0 left-[50%] translate-x-[-50%] font-black text-gray-400 drop-shadow-xl">
                            TURBO
                        </div>
                    </div>
                    <div className="absolute w-full flex flex-row px-8 justify-between">
                        <div className="w-[230px] flex flex-col">
                            {gpuStats.map(gpu => {
                                return <div className="flex flex-row items-center gap-2">
                                    <div className="text-white text-xs">{gpu.displayName}</div>
                                    <ProgressBar progress={gpu.progress} />
                                    <div className="text-white text-xs">{gpu.value}</div>

                                </div>
                            })}
                        </div>
                        <div className="w-[230px] flex flex-col">
                            {cpuStats.map(cpu => {
                                return <div className="flex flex-row items-center gap-2">
                                    <div className="text-white text-xs">{cpu.displayName}</div>
                                    <ProgressBar progress={cpu.progress} />
                                    <div className="text-white text-xs">{cpu.value}</div>

                                </div>
                            })}
                        </div>
                    </div>
                </div>
                <div className="flex flex-row gap-10 h-[650px]">
                    <WindowComponent title={"Live samples"}>
                        <div className="flex flex-col gap-2">
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                        </div>
                    </WindowComponent>
                    <WindowComponent title={"collection"}>
                    <div className="flex flex-col gap-2">
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                            <VisualItemDisplay image={""} title={"Hello"} comment={"I'm a comment"} />
                        </div>
                    </WindowComponent>
                </div>
            </div>
        </div>
    </>
}