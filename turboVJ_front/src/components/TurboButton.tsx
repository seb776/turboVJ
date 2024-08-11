import { useState } from "react";

interface TurboButtonProps {
    size?: number;
    onClick?: () => void;
    state: boolean;
}

export default function TurboButton(props: TurboButtonProps) {
    const [ isHover, setIsHover ] = useState(false);
    const size = props.size ?? 200;
    
    function onMouseOver() {
        setIsHover(true);
    }
    function onMouseLeave() {
        setIsHover(false);
    }
    const icon = props.state ? "TurboButtonOn.png" : "TurboButtonOff.png";
    const filter = isHover ? "brightness(1.2)" : "";

    return <>
        <div className="" style={{ 
            backgroundImage: `url(./UI/${icon})`, 
            backgroundSize: 'contain',
            width: size,
            height: size,
            filter: filter
            }}
            onMouseOver={onMouseOver}
            onMouseLeave={onMouseLeave}
            >
        </div>
    </>
}