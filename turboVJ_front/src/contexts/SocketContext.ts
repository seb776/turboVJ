import React from "react";
import { SocketPayload } from "../SocketTypes";

export class MySocket {
    socket: WebSocket | undefined;
    constructor() {
        this.socket = undefined;
    }

    connect(url: string) {
        this._callbacks = [];
        this.socket = new WebSocket(url);
        this.socket.addEventListener("message", (data) => {
            this._callbacks.forEach(cb => {
                cb(JSON.parse(data.data));
            });
        });
    }


    send(data: any) {
        if (this.socket) {
            this.socket.send(data);
        }
    }
    _callbacks: ((data: SocketPayload) => void)[] = [];

    onMessage(callback: (data: SocketPayload) => void) {
        this._callbacks.push(callback);
    };

    clearCallbacks() {
        this._callbacks = [];
    }
}

export interface SocketContextType {
    socket?: MySocket;
}

export const SocketContext = React.createContext({
    socket: undefined
} as SocketContextType)

export function useSocket() {
    return React.useContext(SocketContext);
}