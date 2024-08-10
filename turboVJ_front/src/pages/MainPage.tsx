import { ShaderSurface } from "../components/ShaderComponent";

export default function MainPage() {
    return <div className="">
        <div className="absolute w-full h-full flex flex-col">
        <ShaderSurface/>
        <ShaderSurface/>
        </div>
        <div className="absolute flex flex-col">
            {/* Hello world ! */}
            {/* <button>next visual</button> */}
        </div>
    </div>
}