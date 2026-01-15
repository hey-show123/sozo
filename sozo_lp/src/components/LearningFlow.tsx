
import { motion, useScroll, useTransform, useSpring } from 'framer-motion';
import { useRef } from 'react';
import {
    Zap,
    Quote,
    ListOrdered,
    MessageCircle,
    Mic,
    Sparkles
} from 'lucide-react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

const cn = (...inputs: (string | undefined | null | false)[]) => twMerge(clsx(inputs));

export const LearningFlow = () => {
    const targetRef = useRef<HTMLDivElement>(null);
    const { scrollYProgress } = useScroll({
        target: targetRef,
    });

    // Map scroll to 0 -> -300 degrees (stop at last step, index 5)
    // Step 1 (0) to Step 6 (300). We rotate container -300 to bring Step 6 to front.
    // Prevents "Step 1" from appearing again after Step 6.
    const rawRotation = useTransform(scrollYProgress, [0, 1], [0, -300]);
    const rotation = useSpring(rawRotation, { stiffness: 50, damping: 20 });



    const steps = [
        {
            id: 1,
            title: "単語練習",
            engTitle: "Vocabulary",
            description: "クイズ形式で\n重要単語をマスター",
            icon: Zap,
            color: "text-red-500",
            bg: "bg-red-50",
            border: "border-red-200",
            shadow: "shadow-red-200"
        },
        {
            id: 2,
            title: "キーフレーズ",
            engTitle: "Key Phrase",
            description: "重要フレーズの\n発音と使い方を練習",
            icon: Quote,
            color: "text-orange-500",
            bg: "bg-orange-50",
            border: "border-orange-200",
            shadow: "shadow-orange-200"
        },
        {
            id: 3,
            title: "並べ替え",
            engTitle: "Dictation",
            description: "音声を聞いて\n語順感覚を養う",
            icon: ListOrdered,
            color: "text-teal-500",
            bg: "bg-teal-50",
            border: "border-teal-200",
            shadow: "shadow-teal-200"
        },
        {
            id: 4,
            title: "ダイアログ",
            engTitle: "Dialog",
            description: "実際のシーンで\n会話の流れを掴む",
            icon: MessageCircle,
            color: "text-green-500",
            bg: "bg-green-50",
            border: "border-green-200",
            shadow: "shadow-green-200"
        },
        {
            id: 5,
            title: "応用練習",
            engTitle: "Application",
            description: "自分なりの表現を\n作って発話する",
            icon: Mic,
            color: "text-purple-600",
            bg: "bg-purple-50",
            border: "border-purple-200",
            shadow: "shadow-purple-200"
        },
        {
            id: 6,
            title: "AI実践",
            engTitle: "AI Roleplay",
            description: "AIお客様相手に\nリアルな接客本番",
            icon: Sparkles,
            color: "text-blue-500",
            bg: "bg-blue-50",
            border: "border-blue-200",
            shadow: "shadow-blue-200",
            isSpecial: true
        },
    ];

    // Logic for 3D placement
    const RADIUS = 550; // Tighter radius to bring cards closer
    const ANGLE_STEP = 360 / steps.length;

    return (
        <section ref={targetRef} className="relative h-[400vh] bg-slate-50 overscroll-none">
            <div className="sticky top-0 h-screen flex flex-col justify-start pt-4 md:pt-8 overflow-hidden perspective-container">

                {/* Header Section */}
                <div className="container mx-auto px-4 mb-2 md:mb-4 text-center flex-shrink-0 z-20 relative pointer-events-none">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                    >
                        <span className="text-secondary font-bold tracking-wider uppercase text-sm mb-1 block">The Method</span>
                        <h2 className="text-3xl md:text-4xl font-bold text-slate-800 leading-tight">
                            <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-secondary">6つのステップ</span>で<br className="md:hidden" />
                            完璧な接客英語を。
                        </h2>
                    </motion.div>
                </div>

                {/* 3D Carousel Container */}
                <div className="relative w-full flex justify-center items-center perspective-[2000px] z-10 scale-[0.65] md:scale-90 lg:scale-100">

                    {/* Rotating Stage */}
                    <motion.div
                        className="relative w-[400px] h-[550px] preserve-3d" // Base card size container
                        style={{
                            rotateY: rotation,
                            rotateX: -5 // Slight negative tilt as requested
                        }}
                    >
                        {steps.map((step, index) => {
                            const angle = index * ANGLE_STEP;
                            return (
                                <div
                                    key={step.id}
                                    className="absolute top-0 left-0 w-full h-full backface-visible"
                                    style={{
                                        // Place in circle
                                        transform: `rotateY(${angle}deg) translateZ(${RADIUS}px)`,
                                    }}
                                >
                                    <StepCard step={step} />
                                </div>
                            );
                        })}
                    </motion.div>

                    {/* Mobile Notice (optional) */}
                    <div className="absolute bottom-10 left-0 w-full text-center text-slate-400 text-sm md:hidden animate-pulse pointer-events-none">
                        Scroll to rotate works best on desktop
                    </div>
                </div>

                {/* Gradient Shadow Fade - Transition to Dark */}
                <div className="absolute bottom-0 left-0 right-0 h-64 z-20 bg-gradient-to-b from-transparent via-slate-900/10 to-slate-950 pointer-events-none" />


            </div>

            <style>{`
        .perspective-container {
            perspective: 2000px;
        }
        .preserve-3d {
            transform-style: preserve-3d;
        }
        .backface-visible {
            backface-visibility: hidden; /* HIDDEN to prevent overlap clutter */
        }
      `}</style>
        </section>
    );
};

const StepCard = ({ step }: { step: any }) => {
    return (
        <div
            className={cn(
                "w-full h-full bg-white/95 backdrop-blur-xl rounded-[3rem] p-10 border-[3px] flex flex-col items-center text-center transition-all duration-300",
                step.border,
                // Add a light bevel/3D effect to the card itself
                step.isSpecial ? "shadow-2xl ring-8 ring-blue-100/50" : "shadow-xl",
                step.shadow
            )}
        >
            {/* Step Badge */}
            <div className={cn(
                "absolute -top-6 px-8 py-3 rounded-full text-lg font-bold tracking-widest text-white shadow-lg",
                step.isSpecial ? "bg-gradient-to-r from-blue-500 to-indigo-600" : "bg-slate-800"
            )}>
                STEP {step.id}
            </div>

            {/* Icon Circle */}
            <div className={cn(
                "w-32 h-32 rounded-full flex items-center justify-center mb-10 shadow-inner mt-8",
                step.bg,
                step.color
            )}>
                <step.icon size={56} />
            </div>

            <h3 className={cn("text-3xl font-bold mb-4 text-slate-800")}>
                {step.title}
            </h3>
            <div className={cn("text-xs font-bold uppercase mb-8 opacity-60 tracking-widest", step.color)}>
                {step.engTitle}
            </div>

            <p className="text-slate-500 text-lg leading-relaxed whitespace-pre-line font-medium">
                {step.description}
            </p>
        </div>
    );
}
