import { motion, useMotionValue, useTransform, useSpring, AnimatePresence } from 'framer-motion';
import { Mic, Scissors, Sparkles, Menu, Bot, Brush, Feather } from 'lucide-react';
import React, { useState, useEffect, useRef } from 'react';

// Floating 3D Prism (Tetrahedron) Background
const FloatingPrismBackground = () => {
    // Generate random prisms - Memoize to prevent regeneration on re-renders
    const prisms = React.useMemo(() => Array.from({ length: 15 }, (_, i) => ({
        id: i,
        x: Math.random() * 100,
        y: Math.random() * 100,
        z: Math.random() * -200 - 50,
        rotateX: Math.random() * 360,
        rotateY: Math.random() * 360,
        size: 80 + Math.random() * 100, // Increased size
        delay: Math.random() * 5,
        duration: 15 + Math.random() * 10 // Slower, more majestic movement
    })), []);

    return (
        <div
            className="absolute inset-0 overflow-hidden pointer-events-none"
            style={{ perspective: '1000px' }}
        >
            {prisms.map((prism) => (
                <motion.div
                    key={prism.id}
                    className="absolute transform-style-3d"
                    style={{
                        left: `${prism.x}%`,
                        top: `${prism.y}%`,
                        width: prism.size,
                        height: prism.size,
                        transformStyle: 'preserve-3d',
                    }}
                    initial={{
                        opacity: 0,
                        z: prism.z,
                        rotateX: prism.rotateX,
                        rotateY: prism.rotateY
                    }}
                    animate={{
                        opacity: [0.4, 0.7, 0.4], // Increased opacity
                        y: [-40, 40, -40], // Increased movement range
                        rotateX: [prism.rotateX, prism.rotateX + 180, prism.rotateX + 360],
                        rotateY: [prism.rotateY, prism.rotateY + 180, prism.rotateY + 360],
                        rotateZ: [0, 180, 360],
                    }}
                    transition={{
                        duration: prism.duration,
                        delay: prism.delay,
                        repeat: Infinity,
                        ease: "linear",
                    }}
                >
                    {/* Tetrahedron Faces with increased visibility */}
                    {/* We construct a tetrahedron using 4 triangles */}
                    {/* CSS math determines the exact angles for a regular tetrahedron */}
                    {/* Face 1 (Bottom) */}
                    <div
                        className="absolute w-full h-full bg-gradient-to-br from-primary/20 to-transparent border-b border-primary/40 backdrop-blur-[2px]"
                        style={{
                            clipPath: 'polygon(50% 0%, 0% 100%, 100% 100%)',
                            transformOrigin: '50% 100%',
                            transform: 'rotateX(90deg) translateZ(0px)',
                            boxShadow: '0 0 15px rgba(139, 92, 246, 0.1)'
                        }}
                    />
                    {/* Face 2 (Front) */}
                    <div
                        className="absolute w-full h-full bg-gradient-to-br from-secondary/20 to-transparent border-b border-secondary/40 backdrop-blur-[2px]"
                        style={{
                            clipPath: 'polygon(50% 0%, 0% 100%, 100% 100%)',
                            transformOrigin: '50% 100%',
                            transform: 'rotateX(-19.5deg) translateZ(0px)',
                            boxShadow: '0 0 15px rgba(255, 255, 255, 0.1)'
                        }}
                    />
                    {/* Face 3 (Back Right) */}
                    <div
                        className="absolute w-full h-full bg-gradient-to-br from-accent/20 to-transparent border-b border-accent/40 backdrop-blur-[2px]"
                        style={{
                            clipPath: 'polygon(50% 0%, 0% 100%, 100% 100%)',
                            transformOrigin: '50% 100%',
                            transform: 'rotateY(-120deg) rotateX(-19.5deg) translateZ(0px)',
                            boxShadow: '0 0 15px rgba(245, 158, 11, 0.1)'
                        }}
                    />
                    {/* Face 4 (Back Left) */}
                    <div
                        className="absolute w-full h-full bg-gradient-to-br from-primary/20 to-transparent border-b border-primary/40 backdrop-blur-[2px]"
                        style={{
                            clipPath: 'polygon(50% 0%, 0% 100%, 100% 100%)',
                            transformOrigin: '50% 100%',
                            transform: 'rotateY(120deg) rotateX(-19.5deg) translateZ(0px)',
                            boxShadow: '0 0 15px rgba(139, 92, 246, 0.1)'
                        }}
                    />
                </motion.div>
            ))}
        </div>
    );
};

// Enhanced Organic Liquid Mist Effect
const FluidMist = () => {
    // Generate fizz/bubble particles - Memoized
    const bubbles = React.useMemo(() => Array.from({ length: 8 }, (_, i) => ({
        id: i,
        x: Math.random() * 100,
        size: 4 + Math.random() * 6,
        delay: Math.random() * 5,
        duration: 3 + Math.random() * 4
    })), []);

    return (
        <div className="absolute inset-[-80px] -z-10 opacity-60"> {/* Slightly reduced opacity */}
            {/* Main Organic Blob - Pink/Rose */}
            <motion.div
                className="absolute inset-0 bg-gradient-to-tr from-pink-400/40 to-fuchsia-400/40 blur-[60px]"
                animate={{
                    borderRadius: [
                        "60% 40% 30% 70% / 60% 30% 70% 40%",
                        "30% 60% 70% 40% / 50% 60% 30% 60%",
                        "60% 40% 30% 70% / 60% 30% 70% 40%"
                    ],
                    rotate: [0, 180, 360],
                    scale: [1, 1.1, 0.9, 1],
                }}
                transition={{
                    duration: 15,
                    repeat: Infinity,
                    ease: "easeInOut"
                }}
            />

            {/* Secondary Organic Blob - Soft Purple/Violet */}
            <motion.div
                className="absolute w-[120%] h-[120%] bg-purple-400/30 blur-[50px]"
                style={{ left: '-10%', top: '-10%' }}
                animate={{
                    borderRadius: [
                        "40% 60% 70% 30% / 40% 50% 60% 50%",
                        "60% 30% 50% 70% / 60% 40% 60% 40%",
                        "40% 60% 70% 30% / 40% 50% 60% 50%"
                    ],
                    rotate: [360, 180, 0],
                    x: [-30, 30, -30],
                    y: [20, -20, 20],
                }}
                transition={{
                    duration: 18,
                    repeat: Infinity,
                    ease: "easeInOut"
                }}
            />

            {/* Accent Blob - Warm Rose/White for highlights */}
            <motion.div
                className="absolute w-[80%] h-[80%] bg-rose-300/30 blur-[50px]"
                style={{ left: '10%', top: '10%' }}
                animate={{
                    opacity: [0.4, 0.7, 0.4],
                    scale: [0.8, 1.1, 0.8],
                    borderRadius: [
                        "50% 50% 50% 50% / 50% 50% 50% 50%",
                        "30% 70% 70% 30% / 30% 30% 70% 70%",
                        "50% 50% 50% 50% / 50% 50% 50% 50%"
                    ]
                }}
                transition={{
                    duration: 8,
                    repeat: Infinity,
                    ease: "easeInOut"
                }}
            />

            {/* Fizz/Bubbles - Rising Particles */}
            <div className="absolute inset-0 overflow-hidden rounded-[3rem]">
                {bubbles.map((bubble) => (
                    <motion.div
                        key={bubble.id}
                        className="absolute bg-white/50 rounded-full blur-[1px]"
                        style={{
                            left: `${bubble.x}%`,
                            width: bubble.size,
                            height: bubble.size,
                        }}
                        initial={{ y: '120%', opacity: 0 }}
                        animate={{
                            y: '-20%',
                            opacity: [0, 1, 0],
                            scale: [0.5, 1, 1.2]
                        }}
                        transition={{
                            duration: bubble.duration,
                            repeat: Infinity,
                            delay: bubble.delay,
                            ease: "easeOut"
                        }}
                    />
                ))}
            </div>
        </div>
    );
};

// Magnetic Button component (Magnetic effect removed, kept for styling/hover)
const MagneticButton = ({ children, className, primary = false }: { children: React.ReactNode; className?: string; primary?: boolean }) => {
    return (
        <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className={`${className} relative overflow-hidden group`}
        >
            {primary && (
                <motion.div
                    className="absolute inset-0 bg-gradient-to-r from-primary via-secondary to-primary bg-[length:200%_100%]"
                    animate={{ backgroundPosition: ['0% 0%', '100% 0%', '0% 0%'] }}
                    transition={{ duration: 3, repeat: Infinity, ease: 'linear' }}
                />
            )}
            <span className="relative z-10 flex items-center justify-center gap-2">{children}</span>
            <motion.div
                className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity"
                style={{
                    background: primary
                        ? 'radial-gradient(circle at center, rgba(255,255,255,0.3) 0%, transparent 70%)'
                        : 'radial-gradient(circle at center, rgba(139,92,246,0.2) 0%, transparent 70%)'
                }}
            />
        </motion.button>
    );
};

// Typing text animation component
const TypewriterText = ({ text, delay = 0 }: { text: string; delay?: number }) => {
    const [displayText, setDisplayText] = useState('');
    const [showCursor, setShowCursor] = useState(true);

    useEffect(() => {
        const timeout = setTimeout(() => {
            let i = 0;
            const interval = setInterval(() => {
                if (i <= text.length) {
                    setDisplayText(text.slice(0, i));
                    i++;
                } else {
                    clearInterval(interval);
                    setTimeout(() => setShowCursor(false), 500);
                }
            }, 50);
            return () => clearInterval(interval);
        }, delay);
        return () => clearTimeout(timeout);
    }, [text, delay]);

    return (
        <span>
            {displayText}
            {showCursor && <motion.span animate={{ opacity: [1, 0] }} transition={{ duration: 0.5, repeat: Infinity }} className="ml-0.5">|</motion.span>}
        </span>
    );
};

// Animated letter component for headline
const AnimatedLetter = ({ letter, delay }: { letter: string; delay: number }) => (
    <motion.span
        className="inline-block"
        initial={{ opacity: 0, y: 50, rotateX: -90 }}
        animate={{ opacity: 1, y: 0, rotateX: 0 }}
        transition={{
            duration: 0.6,
            delay,
            type: "spring",
            stiffness: 100,
        }}
    >
        {letter === ' ' ? '\u00A0' : letter}
    </motion.span>
);

// Animated word/line component
const AnimatedLine = ({ text, baseDelay, className }: { text: string; baseDelay: number; className?: string }) => (
    <span className={className}>
        {text.split('').map((letter, i) => (
            <AnimatedLetter key={i} letter={letter} delay={baseDelay + i * 0.03} />
        ))}
    </span>
);



export const Hero = () => {
    const x = useMotionValue(0);
    const y = useMotionValue(0);
    const [chatStep, setChatStep] = useState(0);

    // Animate chat messages
    useEffect(() => {
        const timers = [
            setTimeout(() => setChatStep(1), 800),
            setTimeout(() => setChatStep(2), 2500),
            setTimeout(() => setChatStep(3), 4200),
            setTimeout(() => setChatStep(4), 5900),
            setTimeout(() => setChatStep(5), 7600),
        ];
        return () => timers.forEach(clearTimeout);
    }, []);

    // Smooth spring animation for mouse movement
    const mouseX = useSpring(x, { stiffness: 50, damping: 20 });
    const mouseY = useSpring(y, { stiffness: 50, damping: 20 });

    function handleMouseMove({ currentTarget, clientX, clientY }: React.MouseEvent) {
        const { left, top, width, height } = currentTarget.getBoundingClientRect();
        const xPct = (clientX - left) / width - 0.5;
        const yPct = (clientY - top) / height - 0.5;
        x.set(xPct);
        y.set(yPct);
    }

    // Tilt transformations


    return (
        <section
            onMouseMove={handleMouseMove}
            className="min-h-screen bg-background flex items-center justify-center relative overflow-hidden perspective-1000"
            style={{ perspective: 1000 }}
        >
            {/* Floating 3D Prisms Background */}
            <FloatingPrismBackground />

            {/* Dynamic Background Blobs */}
            <div className="absolute inset-0 overflow-hidden pointer-events-none">
                <motion.div
                    style={{ x: useTransform(mouseX, [-0.5, 0.5], [-50, 50]), y: useTransform(mouseY, [-0.5, 0.5], [-50, 50]) }}
                    className="absolute top-[-10%] left-[-10%] w-[600px] h-[600px] bg-primary/10 rounded-full blur-[100px]"
                />
                <motion.div
                    style={{ x: useTransform(mouseX, [-0.5, 0.5], [50, -50]), y: useTransform(mouseY, [-0.5, 0.5], [50, -50]) }}
                    className="absolute bottom-[-10%] right-[-10%] w-[600px] h-[600px] bg-secondary/10 rounded-full blur-[100px]"
                />
                <motion.div
                    animate={{ rotate: 360 }}
                    transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                    className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] opacity-20"
                >
                    <div className="absolute inset-0 rounded-full border border-primary/20" />
                    <div className="absolute inset-8 rounded-full border border-secondary/20" />
                    <div className="absolute inset-16 rounded-full border border-accent/20" />
                </motion.div>
            </div>

            <div className="container mx-auto px-4 z-10 grid lg:grid-cols-2 gap-12 items-center">
                {/* Text Content */}
                <div className="text-center lg:text-left">
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ duration: 0.3 }}
                    >


                        {/* Animated Headline */}
                        <h1 className="text-5xl lg:text-7xl font-bold text-slate-800 mb-6 leading-tight">
                            <AnimatedLine text="AIと共に" baseDelay={0.3} />
                            <br />
                            <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-secondary">
                                <AnimatedLine text="英語の壁を超える" baseDelay={0.6} />
                            </span>
                        </h1>

                        {/* Animated Description */}
                        <motion.p
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 1.2, duration: 0.6 }}
                            className="text-xl text-slate-600 mb-8 max-w-xl mx-auto lg:mx-0"
                        >
                            SOZOの英会話は、あなたの英語学習を革新します。24時間365日、AIがあなたの専属コーチに。
                            さぁ、新しい学習体験を始めましょう。
                        </motion.p>

                        {/* Magnetic Buttons */}
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 1.4, duration: 0.6 }}
                            className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start"
                        >
                            <MagneticButton
                                primary
                                className="text-white font-bold py-4 px-8 rounded-full shadow-lg shadow-primary/30 text-lg"
                            >
                                無料で始める
                            </MagneticButton>
                            <MagneticButton className="bg-white hover:bg-slate-50 text-slate-700 font-bold py-4 px-8 rounded-full border border-slate-200 shadow-sm text-lg">
                                <Mic size={20} />
                                デモを見る
                            </MagneticButton>
                        </motion.div>
                    </motion.div>
                </div>

                {/* 3D Phone Mockup */}
                <motion.div
                    initial={{ opacity: 0, scale: 0.8, y: 0 }}
                    animate={{ opacity: 1, scale: 1, y: [0, -20, 0] }}
                    transition={{
                        opacity: { delay: 0.5, duration: 0.8 },
                        scale: { delay: 0.5, duration: 0.8, type: "spring" },
                        y: { duration: 6, repeat: Infinity, ease: "easeInOut" }
                    }}
                    style={{ transformStyle: "preserve-3d" }}
                    className="relative mx-auto w-[300px] h-[600px]"
                >
                    {/* Fluid Mist Background */}
                    <FluidMist />

                    {/* Floating Icon 1 (Scissors) */}
                    <motion.div
                        initial={{ opacity: 0, x: -50 }}
                        animate={{
                            opacity: 1,
                            x: 0,
                            y: [0, -15, 0],
                            rotate: [0, 5, 0]
                        }}
                        transition={{
                            opacity: { delay: 1.6 },
                            x: { delay: 1.6, duration: 0.5 },
                            y: { duration: 4, repeat: Infinity, ease: "easeInOut" },
                            rotate: { duration: 4, repeat: Infinity, ease: "easeInOut" }
                        }}
                        style={{
                            x: useTransform(mouseX, [-0.5, 0.5], [10, -10]),
                            y: useTransform(mouseY, [-0.5, 0.5], [10, -10]),
                        }}
                        className="absolute -top-12 -left-8 z-20 filter drop-shadow-xl"
                    >
                        <Scissors size={48} className="text-white" />
                        <motion.div
                            className="absolute inset-0 bg-white/20 blur-xl rounded-full -z-10"
                            animate={{ opacity: [0, 0.5, 0], scale: [1, 1.2, 1] }}
                            transition={{ duration: 2, repeat: Infinity }}
                        />
                    </motion.div>

                    {/* Floating Icon 2 (Feather) */}
                    <motion.div
                        initial={{ opacity: 0, x: 50 }}
                        animate={{
                            opacity: 1,
                            x: 0,
                            y: [0, 20, 0],
                            rotate: [0, -5, 0]
                        }}
                        transition={{
                            opacity: { delay: 2.1 },
                            x: { delay: 2.1, duration: 0.5 },
                            y: { duration: 5, repeat: Infinity, ease: "easeInOut", delay: 1 },
                            rotate: { duration: 5, repeat: Infinity, ease: "easeInOut", delay: 1 }
                        }}
                        style={{
                            x: useTransform(mouseX, [-0.5, 0.5], [-15, 15]),
                            y: useTransform(mouseY, [-0.5, 0.5], [-10, 10]),
                        }}
                        className="absolute -top-20 -right-16 z-20 filter drop-shadow-xl"
                    >
                        <motion.div
                            animate={{ rotate: [0, 10, 0] }}
                            transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
                        >
                            <Feather size={40} className="text-secondary" />
                        </motion.div>
                    </motion.div>

                    {/* Floating Icon 4 (Scissors - Floating) */}
                    <motion.div
                        initial={{ opacity: 0, x: -50 }}
                        animate={{
                            opacity: 1,
                            x: 0,
                            y: [0, -10, 0],
                            rotate: [0, 45, 0]
                        }}
                        transition={{
                            opacity: { delay: 3.1 },
                            x: { delay: 3.1, duration: 0.5 },
                            y: { duration: 6, repeat: Infinity, ease: "easeInOut" },
                            rotate: { duration: 7, repeat: Infinity, ease: "easeInOut" }
                        }}
                        style={{
                            x: useTransform(mouseX, [-0.5, 0.5], [20, -20]),
                            y: useTransform(mouseY, [-0.5, 0.5], [15, -15]),
                        }}
                        className="absolute top-1/2 -left-16 z-20 filter drop-shadow-xl"
                    >
                        <Scissors size={28} className="text-white/80 rotate-45" />
                    </motion.div>

                    {/* Floating Icon 5 (Brush) */}
                    <motion.div
                        initial={{ opacity: 0, x: 50 }}
                        animate={{
                            opacity: 1,
                            x: 0,
                            y: [0, 15, 0],
                            rotate: [0, -10, 0]
                        }}
                        transition={{
                            opacity: { delay: 3.6 },
                            x: { delay: 3.6, duration: 0.5 },
                            y: { duration: 5.5, repeat: Infinity, ease: "easeInOut" },
                            rotate: { duration: 6, repeat: Infinity, ease: "easeInOut" }
                        }}
                        style={{
                            x: useTransform(mouseX, [-0.5, 0.5], [-20, 20]),
                            y: useTransform(mouseY, [-0.5, 0.5], [-15, 15]),
                        }}
                        className="absolute bottom-32 -right-16 z-20 filter drop-shadow-xl"
                    >
                        <Brush size={32} className="text-primary" />
                    </motion.div>



                    {/* Phone Frame - Overflow visible for popping elements */}
                    <div className="relative w-[280px] h-[580px] bg-slate-900 rounded-[3rem] border-8 border-slate-800 shadow-2xl transform-style-3d">
                        {/* Inner clipped container for background/header/bottombar */}
                        <div className="absolute inset-0 rounded-[2.5rem] overflow-hidden bg-slate-50 flex flex-col">
                            {/* App Header */}
                            <div className="h-24 bg-gradient-to-r from-secondary to-primary p-6 pt-10 text-white flex justify-between items-start">
                                <Menu size={20} />
                                <span className="font-bold">SOZO Salon</span>
                                <div className="w-8 h-8 rounded-full bg-white/20" />
                            </div>

                            {/* Background for chat area */}
                            <div className="flex-1 bg-slate-50" />

                            {/* Bottom Bar */}
                            <div className="h-16 bg-white border-t border-slate-100 flex justify-around items-center text-slate-300">
                                <motion.div
                                    className="w-6 h-6 rounded-full bg-secondary"
                                    whileHover={{ scale: 1.2 }}
                                />
                                <div className="w-6 h-6 rounded-full bg-slate-200" />
                                <div className="w-6 h-6 rounded-full bg-slate-200" />
                            </div>
                        </div>

                        {/* Chat Layer - Positioned on top, allowing overflow */}
                        <div className="absolute inset-0 pt-24 px-4 flex flex-col gap-6 pointer-events-none">
                            {/* AI Message (Customer) - Popping out Left */}
                            <AnimatePresence>
                                {chatStep >= 1 && (
                                    <motion.div
                                        initial={{ opacity: 0, x: -100, scale: 0.5, rotate: -10 }}
                                        animate={{ opacity: 1, x: -40, scale: 1, rotate: -5 }}
                                        className="flex gap-2 relative z-10"
                                        style={{ marginLeft: '-3rem' }} // Exaggerated pull out
                                    >
                                        <div className="relative">
                                            <motion.div
                                                className="w-10 h-10 rounded-full bg-secondary flex items-center justify-center text-white border-2 border-white shadow-lg z-20 relative"
                                                animate={{ scale: [1, 1.1, 1] }}
                                                transition={{ duration: 0.3 }}
                                            >
                                                <Bot size={24} />
                                            </motion.div>
                                            {/* Decorative blob behind avatar */}
                                            <motion.div
                                                className="absolute inset-0 bg-secondary/30 rounded-full blur-md -z-10"
                                                animate={{ scale: [1, 1.5, 1] }}
                                                transition={{ duration: 2, repeat: Infinity }}
                                            />
                                        </div>

                                        <motion.div
                                            className="bg-white p-4 rounded-2xl rounded-tl-none shadow-xl text-xs text-slate-700 font-medium max-w-[90%] border border-slate-100 relative"
                                            animate={{ y: [0, -5, 0] }}
                                            transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                                        >
                                            <TypewriterText text="Hello! I'd like a bob cut, please." delay={200} />
                                            {/* Fun decorative elements */}
                                            <motion.div
                                                className="absolute -top-2 -right-2 text-yellow-400"
                                                initial={{ scale: 0 }}
                                                animate={{ scale: [0, 1.2, 1] }}
                                                transition={{ delay: 0.5 }}
                                            >
                                                <Sparkles size={16} fill="currentColor" />
                                            </motion.div>
                                        </motion.div>
                                    </motion.div>
                                )}
                            </AnimatePresence>

                            {/* User Message (Staff) - Popping out Right */}
                            <AnimatePresence>
                                {chatStep >= 2 && (
                                    <motion.div
                                        initial={{ opacity: 0, x: 100, scale: 0.5, rotate: 5 }}
                                        animate={{ opacity: 1, x: 40, scale: 1, rotate: 3 }}
                                        className="flex gap-2 flex-row-reverse relative z-10"
                                        style={{ marginRight: '-3rem', marginTop: '0.5rem' }} // Exaggerated pull out
                                    >
                                        <motion.div
                                            className="bg-gradient-to-br from-primary to-secondary text-white p-4 rounded-2xl rounded-tr-none shadow-xl text-xs font-medium max-w-[90%] relative"
                                            initial={{ scale: 0.8 }}
                                            animate={{ scale: 1, y: [0, 5, 0] }}
                                            transition={{ y: { duration: 4, repeat: Infinity, ease: "easeInOut" } }}
                                        >
                                            <TypewriterText text="Sure! Would you like layers?" delay={200} />
                                            <motion.div
                                                className="absolute -bottom-1 -left-1 w-2 h-2 bg-white rounded-full"
                                                animate={{ opacity: [1, 0.5, 1] }}
                                                transition={{ duration: 2, repeat: Infinity }}
                                            />
                                        </motion.div>
                                    </motion.div>
                                )}
                            </AnimatePresence>

                            {/* AI Message 2 (New) */}
                            <AnimatePresence>
                                {chatStep >= 3 && (
                                    <motion.div
                                        initial={{ opacity: 0, x: -100, scale: 0.5, rotate: -5 }}
                                        animate={{ opacity: 1, x: -50, scale: 1, rotate: -2 }}
                                        className="flex gap-2 relative z-10"
                                        style={{ marginLeft: '-3.5rem', marginTop: '0.5rem' }}
                                    >
                                        <div className="w-10 h-10 rounded-full bg-secondary flex items-center justify-center text-white text-xs border-2 border-white shadow-lg">
                                            <Bot size={24} />
                                        </div>
                                        <motion.div
                                            className="bg-white p-4 rounded-2xl rounded-tl-none shadow-xl text-xs text-slate-700 font-medium max-w-[90%] border border-slate-100 relative"
                                        >
                                            <TypewriterText text="Yes, and some highlights too!" delay={200} />
                                        </motion.div>
                                    </motion.div>
                                )}
                            </AnimatePresence>

                            {/* User Message 2 (New) */}
                            <AnimatePresence>
                                {chatStep >= 4 && (
                                    <motion.div
                                        initial={{ opacity: 0, x: 100, scale: 0.5, rotate: 5 }}
                                        animate={{ opacity: 1, x: 50, scale: 1, rotate: 2 }}
                                        className="flex gap-2 flex-row-reverse relative z-10"
                                        style={{ marginRight: '-4rem', marginTop: '0.5rem' }}
                                    >
                                        <motion.div
                                            className="bg-gradient-to-br from-primary to-secondary text-white p-4 rounded-2xl rounded-tr-none shadow-xl text-xs font-medium max-w-[90%] relative"
                                        >
                                            <TypewriterText text="Perfect! Let's get started." delay={200} />
                                        </motion.div>
                                    </motion.div>
                                )}
                            </AnimatePresence>

                            {/* Listening Indicator */}
                            <AnimatePresence>
                                {chatStep >= 5 && (
                                    <motion.div
                                        initial={{ opacity: 0, y: 10 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        className="flex gap-2 items-center justify-center mt-4 bg-white/80 backdrop-blur-md py-2 px-4 rounded-full shadow-lg mx-auto border border-white/50"
                                    >
                                        <motion.div
                                            animate={{ scale: [1, 1.2, 1] }}
                                            transition={{ duration: 0.8, repeat: Infinity }}
                                            className="text-primary"
                                        >
                                            <Mic size={14} />
                                        </motion.div>
                                        <span className="text-[10px] font-bold text-primary">AI is engaging...</span>
                                        <motion.div className="flex gap-1">
                                            {[0, 1, 2].map((i) => (
                                                <motion.div
                                                    key={i}
                                                    className="w-1 h-1 bg-primary rounded-full"
                                                    animate={{ y: [0, -4, 0] }}
                                                    transition={{ duration: 0.6, repeat: Infinity, delay: i * 0.1 }}
                                                />
                                            ))}
                                        </motion.div>
                                    </motion.div>
                                )}
                            </AnimatePresence>
                        </div>
                    </div>

                    {/* Phone Reflection */}
                    <motion.div
                        className="absolute inset-0 rounded-[2.5rem] pointer-events-none"
                        style={{
                            background: 'linear-gradient(135deg, rgba(255,255,255,0.3) 0%, transparent 50%, rgba(255,255,255,0.1) 100%)',
                        }}
                        animate={{
                            opacity: [0.3, 0.5, 0.3],
                        }}
                        transition={{ duration: 3, repeat: Infinity }}
                    />
                </motion.div>
            </div >
        </section >
    );
};
