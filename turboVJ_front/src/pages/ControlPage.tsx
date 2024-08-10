import { useEffect, useState } from "react";
import { useSocket } from "../contexts/SocketContext"
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
    const [ stats, setStats ] = useState<HardwareStats>({
        GPUUsage: 0,
        GPUTemperature: 0,
        GPUTotalMemory: 0,
        GPUUsedMemory: 0,
        CPUUsage: 0,
        CPUTemperature: 0,
        CPUTotalMemory: 0,
        CPUUsedMemory: 0,
    });

    useEffect(() => {
        if (socket) {
            socket.addEventListener("message", (data) => {
                console.log('received message',data)
                setStats(JSON.parse(data.data));
            });
        }
        // TODO clear callback ?
    }, []);

    const statsNames = Object.keys(stats);
    return <>
        <div className="flex flex-col w-full">
            {statsNames.map(el=>{
                return <div className="flex flex-row">
                        <div>
                            {el}
                        </div>
                        <div>
                            {(stats as any)[el]}
                        </div>
                    </div>
            })}
        </div>
    </>
}