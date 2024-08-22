import { ReactNode } from "react";
import { MySocket, SocketContext, SocketContextType } from "./SocketContext";

interface SocketContextProviderProps {
    children: ReactNode;
}
export default function SocketContextProvider(props: SocketContextProviderProps) {
    const value: SocketContextType = {
        socket: new MySocket()
    }
    value.socket?.connect("ws://localhost:8080/websocket");
    return <SocketContext.Provider value={value}>
        {props.children}
    </SocketContext.Provider>
}