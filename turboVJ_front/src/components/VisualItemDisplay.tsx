interface VisualItemDisplayProps {
    image: string;
    title: string;
    comment: string;
}

export default function VisualItemDisplay(props: VisualItemDisplayProps) {
    const size = 50;
    return <div className="flex flex-row gap-2" style={{height: size}}>
        <div className="bg-black" style={{
            width: size,
            height: size
        }}/>
        <div className="flex flex-col">
            <div className="font-bold text-white">
                {props.title}
            </div>
            <div className="text-white">
                {props.comment}
            </div>
        </div>
    </div>
}