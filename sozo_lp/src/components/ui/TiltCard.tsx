import { useRef, useState, useEffect } from "react";
import type { MouseEvent } from "react";
import { motion, useMotionValue, useSpring, useTransform } from "framer-motion";
import { cn } from "../../lib/utils";

interface TiltCardProps extends React.HTMLAttributes<HTMLDivElement> {
    children: React.ReactNode;
    className?: string;
    tiltIntensity?: number;
    glareOpacity?: number;
    scaleOnHover?: number;
}

export const TiltCard = ({
    children,
    className,
    tiltIntensity = 20,
    glareOpacity = 0.4,
    scaleOnHover = 1.02,
    ...props
}: TiltCardProps) => {
    const ref = useRef<HTMLDivElement>(null);
    const [disabled, setDisabled] = useState(false);

    useEffect(() => {
        // Disable on touch devices
        const checkMobile = () => {
            setDisabled(window.matchMedia("(hover: none)").matches);
        };
        checkMobile();
        window.addEventListener("resize", checkMobile);
        return () => window.removeEventListener("resize", checkMobile);
    }, []);

    const x = useMotionValue(0);
    const y = useMotionValue(0);

    const mouseX = useSpring(x, { stiffness: 150, damping: 15 });
    const mouseY = useSpring(y, { stiffness: 150, damping: 15 });

    const rotateX = useTransform(mouseY, [-0.5, 0.5], [tiltIntensity, -tiltIntensity]);
    const rotateY = useTransform(mouseX, [-0.5, 0.5], [-tiltIntensity, tiltIntensity]);

    // Glare position
    const glareX = useTransform(mouseX, [-0.5, 0.5], ["0%", "100%"]);
    const glareY = useTransform(mouseY, [-0.5, 0.5], ["0%", "100%"]);

    const handleMouseMove = (e: MouseEvent<HTMLDivElement>) => {
        if (!ref.current || disabled) return;

        const rect = ref.current.getBoundingClientRect();
        const width = rect.width;
        const height = rect.height;

        const mouseXPos = e.clientX - rect.left;
        const mouseYPos = e.clientY - rect.top;

        const xPct = mouseXPos / width - 0.5;
        const yPct = mouseYPos / height - 0.5;

        x.set(xPct);
        y.set(yPct);
    };

    const handleMouseLeave = () => {
        x.set(0);
        y.set(0);
    };

    return (
        <motion.div
            ref={ref}
            onMouseMove={handleMouseMove}
            onMouseLeave={handleMouseLeave}
            style={{
                rotateX,
                rotateY,
                transformStyle: "preserve-3d",
            }}
            whileHover={!disabled ? { scale: scaleOnHover } : {}}
            className={cn("relative transition-all duration-200 ease-out will-change-transform", className)}
            {...props as any}
        >
            <div
                style={{
                    transform: !disabled ? "translateZ(50px)" : "none",
                    transformStyle: "preserve-3d",
                }}
                className="h-full w-full"
            >
                {children}
            </div>

            {/* Glare Effect */}
            <motion.div
                style={{
                    background: `radial-gradient(circle at center, rgba(255,255,255,${glareOpacity}) 0%, transparent 80%)`,
                    left: glareX,
                    top: glareY,
                    opacity: useTransform(mouseX, (value) => (value === 0 ? 0 : 1)), // Only show moving
                    transform: "translate(-50%, -50%)",
                    pointerEvents: "none",
                    width: "150%",
                    height: "150%",
                    position: "absolute",
                    zIndex: 50,
                    mixBlendMode: "overlay",
                }}
            />
        </motion.div>
    );
};
