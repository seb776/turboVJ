import midi from 'midi'

export interface KorgNanoKontrol2_VerticalAreaState {
    fader: number;
    knob: number;
    sButton: number;
    mButton: number;
    rButton: number;
}
export interface KorgNanoKontrol2_State { // TODO common sources
    rightSide: KorgNanoKontrol2_VerticalAreaState[];
}

let midiInput: midi.Input | undefined = undefined;

export function ResetMidi(midiState: KorgNanoKontrol2_State, onMidiMessage: (state: KorgNanoKontrol2_State) => void) {
    if (midiInput) {
        midiInput.closePort();
    }
    midiInput = new midi.Input();
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
        // console.log(midiState);
        onMidiMessage(midiState);
        // console.log(`m: ${message} d: ${deltaTime}`);
    });
    midiInput.openPort(0);
}