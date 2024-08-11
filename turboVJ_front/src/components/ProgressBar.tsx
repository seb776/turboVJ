
interface ProgressBarProps {
    progress: number;
}

export default function ProgressBar(props: ProgressBarProps) {
    const totalWidth = 50;

    return <>
        <div className="border-2 h-[10px]" style={{
                width: totalWidth 
        }}>
            <div className="bg-white h-full" style={{
                width: totalWidth * props.progress
            }}>

            </div>
        </div>
    </>
}