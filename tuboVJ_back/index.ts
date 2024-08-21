import fastify from 'fastify'
import fs from 'fs'
import path from 'path'
import cors from '@fastify/cors'
import { SetupHardwareMonitoring, HARDWARE_STATS, HardwareStats } from './SetupHardwareMonitoring'
import websocket from '@fastify/websocket'
import * as WebSocket from 'ws';
import midi from 'midi'
import { KorgNanoKontrol2_State, ResetMidi } from './SetupMidi'


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

setInterval(()=>{
    ResetMidi(midiState);
}, 1000)

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
