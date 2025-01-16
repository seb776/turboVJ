import { exec } from "child_process";
import si from 'systeminformation'
import os from 'os-utils'

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

export const HARDWARE_STATS: HardwareStats = {
    GPUUsage: 0,
    GPUTemperature: 0,
    GPUTotalMemory: 0,
    GPUUsedMemory: 0,
    CPUUsage: 0,
    CPUTemperature: 0,
    CPUTotalMemory: 0,
    CPUUsedMemory: 0
}



export function SetupHardwareMonitoring(callback?: (stats: HardwareStats) => void) {
    exec("../OpenHardwareMonitor/OpenHardwareMonitor.exe");

setInterval(()=>{
    exec("nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,memory.total,memory.used --format=csv,noheader", (err, stdout, stderr) =>{
        const values = stdout.split(",");
        HARDWARE_STATS.GPUTemperature = parseFloat(values[0]);
        HARDWARE_STATS.GPUUsage = parseFloat(values[1].replace("%", "").trim());
        HARDWARE_STATS.GPUTotalMemory = parseFloat(values[2].replace("MiB", "").trim());
        HARDWARE_STATS.GPUUsedMemory = parseFloat(values[3].replace("MiB", "").trim());
    });
    exec("powershell ./GetCPUTemp.ps1", (err, stdout, stderr) =>{
        const values = stdout.match(/[^\r\n]+/g);
        if (values && values.length) {
            HARDWARE_STATS.CPUTemperature = parseFloat(values[values?.length - 1]);
        }
    });
    os.cpuUsage(percentCPU =>{
        HARDWARE_STATS.CPUUsage = percentCPU * 100.0;
    })
    HARDWARE_STATS.CPUTotalMemory = os.totalmem() ;
    HARDWARE_STATS.CPUUsedMemory = os.totalmem() - os.freemem();
    if (callback) {
        callback(HARDWARE_STATS);
    }
    // console.log('hardwareStats ' + JSON.stringify(HARDWARE_STATS));
}, 1000);
}