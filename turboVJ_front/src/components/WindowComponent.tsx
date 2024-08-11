import { ReactNode } from "react"

interface WindowComponentProps {
    children?: ReactNode;
    title: any;
}

export default function WindowComponent(props: WindowComponentProps) {
    return <>
        <div className="relative w-[500px] h-full" style={{
            filter: 'drop-shadow(0 0 0.75rem purple)'
        }}>
            <div className="absolute w-full h-full flex flex-col items-center">
                <div className="w-[300px] flex items-center justify-center pt-4" style={{
                    backgroundImage: 'url(./UI/TitleBar.png)',
                    aspectRatio: '600/100',
                    backgroundSize: 'contain'
                }}>
                    <div className="font-black uppercase text-gray-600 drop-shadow-2xl">
                        {props.title}

                    </div>
                </div>
                <div className=" w-full" style={{
                    aspectRatio: '820/126',
                    backgroundImage: 'url(./UI/WindowTop.png)',
                    backgroundSize: 'contain'
                }} />
                <div className="w-full px-8 h-full" style={{
                    backgroundImage: 'url(./UI/WindowMiddle.png)',
                    minHeight: 69,
                    backgroundSize: 'contain',
                    overflowY: 'scroll'
                }}>
                    {props.children}
                </div>
                <div className="w-full" style={{
                    backgroundImage: 'url(./UI/WindowTop.png)',
                    aspectRatio: '820/126',
                    transform: 'rotate(180deg)',
                    backgroundSize: 'contain'
                }} />
            </div>
        </div>
    </>
}