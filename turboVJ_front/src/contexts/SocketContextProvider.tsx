import { ReactNode } from "react";
import { SocketContext, SocketContextType } from "./SocketContext";

interface SocketContextProviderProps {
    children: ReactNode;
}
export default function SocketContextProvider(props: SocketContextProviderProps) {
    const value: SocketContextType = {
        socket: new WebSocket("ws://localhost:8080/websocket")
    }
    return <SocketContext.Provider value={value}>
        {props.children}
    </SocketContext.Provider>
}