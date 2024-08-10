import React from "react";

export interface SocketContextType {
    socket?: WebSocket;
}

export const SocketContext = React.createContext({
    socket: undefined
} as SocketContextType)

export function useSocket() {
    return React.useContext(SocketContext);
}