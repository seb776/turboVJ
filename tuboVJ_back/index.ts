import fastify from 'fastify'
import fs from 'fs'
import path from 'path'
import cors from '@fastify/cors'
import { SetupHardwareMonitoring, HARDWARE_STATS, HardwareStats } from './SetupHardwareMonitoring'
import websocket from '@fastify/websocket'
import * as WebSocket from 'ws';
import midi from 'midi'

interface KorgNanoKontrol2_VerticalAreaState {
    fader: number;
    knob: number;
    sButton: number;
    mButton: number;
    rButton: number;
}
interface KorgNanoKontrol2_State {    
    rightSide: KorgNanoKontrol2_VerticalAreaState[];
}

const midiState: KorgNanoKontrol2_State = {
    rightSide: []
}

for (let i = 0 ; i < 8; ++i) {
    midiState.rightSide.push({
        fader: 0,
        knob: 0,
        sButton: 0,
        mButton: 0,
        rButton: 0
    })
}

const midiInput = new midi.Input();
midiInput.on('message', (deltaTime, message) => {
    // The message is an array of numbers corresponding to the MIDI bytes:
    //   [status, data1, data2]
    // https://www.cs.cf.ac.uk/Dave/Multimedia/node158.html has some helpful
    // information interpreting the messages.
    if (message[1] >= 16 && message[1] <= 23) {
        // knob
        const targetIndex = message[1] - 16;
        midiState.rightSide[targetIndex].knob = message[2] / 127.0;
    }
    else if (message[1] >= 0 && message[1] <= 7) {
        // Fader
        const targetIndex = message[1];
        midiState.rightSide[targetIndex].fader = message[2] / 127.0;
    }
    else if (message[1] >= 32 && message[1] <= 39) {
        // S button
        const targetIndex = message[1] - 32;
        midiState.rightSide[targetIndex].sButton = message[2] / 127.0;
    }
    else if (message[1] >= 48 && message[1] <= 55) {
        // M button
        const targetIndex = message[1] - 48;
        midiState.rightSide[targetIndex].mButton = message[2] / 127.0;
    }
    else if (message[1] >= 64 && message[1] <= 71) {
        // R button
        const targetIndex = message[1] - 64;
        midiState.rightSide[targetIndex].rButton = message[2] / 127.0;
    }
    console.log(midiState);
    // console.log(`m: ${message} d: ${deltaTime}`);
  });
  
  // Open the first available input port.
  midiInput.openPort(0);


const connectedSockets: WebSocket.WebSocket[] = [];

SetupHardwareMonitoring((stats: HardwareStats) =>{
    connectedSockets.forEach(sock=>{
        if (sock) {
            sock.send(JSON.stringify(stats));
        }
    })
    // console.log("SENDING " + connectedSockets.length + JSON.stringify(stats) )
});
const server = fastify()

// Serve static files for shaders
server.register(require('@fastify/static'), {
    root: path.join(__dirname, 'visuals'),
})



// CORS
server.register(cors, {
    origin: '*', // Allow all origins
});



server.register(websocket)

server.register(async function (fastify) {
    server.get('/websocket', { websocket: true }, (connection /* SocketStream */, req /* FastifyRequest */) => {
        console.log('websocket connected');
        connectedSockets.push(connection);
        connection.on('open', () => {
            console.log('websocket opened');
    
        })
        connection.on('message', message => {
          // message.toString() === 'hi from client'
          connection.send('hi from server')
        })
        connection.on('close', ()=>{
            const foundIndex = connectedSockets.indexOf(connection);
            if (foundIndex > 0) {
                connectedSockets.splice(foundIndex);
            }
            console.log("Closing socket");
        })
        connection.on('error', (err)=>{
            console.error("ERROR " + err);
        })
      })
  })


server.get('/ping', async (request, reply) => {
    return 'pong\n'
})

server.get('/resource/:resourcePathb64', async (request, reply) => {
    const resourcePathb64 = (request.params as any).resourcePathb64;
    const path = Buffer.from(resourcePathb64, 'base64').toString('utf-8');
    console.log("HERE path " + path);
    // TODO decorate / type reply to use fastify static
    return (reply as any).sendFile(path);
})

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

server.get('/visuals', async (request, reply) => {
    let folderContent = fs.readdirSync("./visuals/");

    let visualsDTO: VisualsDTO = {
        visuals: []
    };
    folderContent.forEach(file => {
        if (file !== "common_assets") {
            try {
                const jsonPath = path.join("visuals", file, "info.json");
                const jsonContent = fs.readFileSync(jsonPath).toString();
                const visualDTO = JSON.parse(jsonContent) as VisualDTO;
                visualsDTO.visuals.push(visualDTO);
            }
            catch (err) {
                console.error(err);
            }
        }
    })

    return visualsDTO;
})

server.listen({ port: 8080 }, (err, address) => {
    if (err) {
        console.error(err)
        process.exit(1)
    }
    console.log(`Server listening at ${address}`)
})
