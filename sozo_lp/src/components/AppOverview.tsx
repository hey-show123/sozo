import React from 'react';
import { motion } from 'framer-motion';
import { Scissors, Globe, MessageCircle, Sparkles, Heart, Star } from 'lucide-react';
import { cn } from '../lib/utils';

export const AppOverview: React.FC = () => {
    return (
        <section className="relative py-32 overflow-hidden bg-background z-10">
            {/* Decorative Background Blobs - Animated */}
            <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none opacity-40">
                <motion.div
                    animate={{
                        scale: [1, 1.2, 1],
                        rotate: [0, 90, 0],
                        x: [0, 50, 0],
                        y: [0, 30, 0]
                    }}
                    transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                    className="absolute top-[-10%] left-[-10%] w-96 h-96 bg-pop-pink/30 rounded-full blur-[100px]"
                />
                <motion.div
                    animate={{
                        scale: [1, 1.1, 1],
                        rotate: [0, -60, 0],
                        x: [0, -30, 0],
                        y: [0, 50, 0]
                    }}
                    transition={{ duration: 25, repeat: Infinity, ease: "linear" }}
                    className="absolute bottom-[-10%] right-[-10%] w-[500px] h-[500px] bg-pop-yellow/20 rounded-full blur-[120px]"
                />
                <motion.div
                    animate={{
                        scale: [1, 1.3, 1],
                        x: [0, -40, 0],
                        y: [0, -40, 0]
                    }}
                    transition={{ duration: 18, repeat: Infinity, ease: "linear" }}
                    className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-pop-mint/10 rounded-full blur-[100px]"
                />
            </div>

            {/* Bottom Wave - Animated Transition */}
            <div className="absolute bottom-[-1px] left-0 w-full overflow-hidden leading-none z-20">
                <motion.div
                    animate={{ x: ["0%", "-50%"] }}
                    transition={{ duration: 12, repeat: Infinity, ease: "linear" }}
                    className="flex w-[200%]"
                >
                    <svg data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="relative block w-[50.5%] h-[60px] md:h-[100px] fill-slate-50">
                        <path d="M0,60 C400,160 800,-40 1200,60 V120 H0 Z"></path>
                    </svg>
                    <svg data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="relative block w-[50.5%] h-[60px] md:h-[100px] fill-slate-50 ml-[-1px]">
                        <path d="M0,60 C400,160 800,-40 1200,60 V120 H0 Z"></path>
                    </svg>
                </motion.div>
            </div>

            <div className="container mx-auto px-4 relative z-10">
                <div className="flex flex-col items-center justify-center text-center mb-20">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        className="inline-flex items-center gap-2 px-6 py-2.5 rounded-full bg-white/60 backdrop-blur-md shadow-sm border border-pop-pink/30 mb-8"
                    >
                        <Sparkles className="w-4 h-4 text-pop-pink animate-pulse" />
                        <span className="text-sm font-bold text-pop-pink tracking-wider">ABOUT SOZO</span>
                        <Sparkles className="w-4 h-4 text-pop-pink animate-pulse" />
                    </motion.div>

                    <motion.h2
                        initial={{ opacity: 0, scale: 0.9 }}
                        whileInView={{ opacity: 1, scale: 1 }}
                        viewport={{ once: true }}
                        transition={{ delay: 0.1 }}
                        className="text-4xl md:text-6xl font-bold mb-8 leading-tight tracking-tight"
                    >
                        <span className="text-transparent bg-clip-text bg-gradient-to-r from-pop-pink via-pop-purple to-pop-blue inline-block">
                            美容専門
                        </span>
                        <span className="text-slate-800">
                            の英会話で
                            <br />
                            <span className="relative inline-block mt-2">
                                世界へとびだそう！
                                <motion.span
                                    className="absolute bottom-2 left-0 w-full h-4 bg-pop-yellow/30 -z-10 rounded-full"
                                    initial={{ width: 0 }}
                                    whileInView={{ width: "100%" }}
                                    transition={{ delay: 0.5, duration: 0.8 }}
                                />
                            </span>
                        </span>
                    </motion.h2>


                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        transition={{ delay: 0.2 }}
                        className="text-lg md:text-2xl text-slate-600 max-w-3xl mx-auto leading-relaxed"
                    >
                        SOZOの英会話は、
                        <span className="font-bold text-slate-800 bg-white/50 px-2 rounded-md mx-1 shadow-sm">美容師のための英語学習アプリ</span>
                        です。
                        <br className="hidden md:block" />
                        <span className="mt-2 block">難しい文法は後回し。現場ですぐに使える会話から始めましょう。</span>
                    </motion.p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto px-4">
                    <FeatureCard
                        icon={<Scissors className="w-8 h-8 text-white" />}
                        color="bg-pop-pink"
                        title="サロンワーク特化"
                        description="接客、カウンセリング、技術説明など、実際のサロンワークで使うフレーズだけを厳選しました。"
                        delay={0.3}
                    />
                    <FeatureCard
                        icon={<MessageCircle className="w-8 h-8 text-white" />}
                        color="bg-pop-yellow"
                        title="リアルな会話練習"
                        description="AIキャラクターとのロールプレイングで、失敗を恐れずに何度でも会話の練習ができます。"
                        delay={0.4}
                    />
                    <FeatureCard
                        icon={<Globe className="w-8 h-8 text-white" />}
                        color="bg-pop-blue"
                        title="世界で活躍する夢"
                        description="言葉の壁を超えて、あなたの技術を世界中の人へ。海外就職や留学の夢をサポートします。"
                        delay={0.5}
                    />
                </div>
            </div>

            {/* Floating Elements Animation */}
            <FloatingIcon icon={Heart} color="text-pop-pink" size={32} top="15%" left="8%" delay={0} />
            <FloatingIcon icon={Star} color="text-pop-yellow" size={40} bottom="25%" left="12%" delay={1} />
            <FloatingIcon icon={MessageCircle} color="text-pop-blue" size={36} top="20%" right="8%" delay={2} />
            <FloatingIcon icon={Scissors} color="text-pop-purple" size={48} bottom="20%" right="12%" delay={0.5} />

        </section>
    );
};

const FeatureCard = ({ icon, color, title, description, delay }: { icon: React.ReactNode, color: string, title: string, description: string, delay: number }) => {
    return (
        <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            whileHover={{ y: -12, scale: 1.02 }}
            transition={{ delay, type: "spring", stiffness: 300, damping: 20 }}
            className="bg-white/80 backdrop-blur-sm rounded-[2rem] p-10 shadow-xl shadow-slate-200/50 border border-white/50 relative overflow-hidden group hover:shadow-2xl hover:shadow-pop-purple/10 transition-all duration-300"
        >
            <div className={cn("absolute top-0 right-0 w-40 h-40 rounded-bl-[100px] opacity-10 transition-all duration-500 group-hover:scale-125 group-hover:opacity-20", color)} />

            <div className={cn("w-20 h-20 rounded-2xl flex items-center justify-center mb-8 shadow-lg shadow-gray-200 rotate-3 group-hover:rotate-12 transition-transform duration-300", color)}>
                {icon}
            </div>

            <h3 className="text-2xl font-bold text-slate-800 mb-4">{title}</h3>
            <p className="text-slate-600 leading-relaxed text-lg">
                {description}
            </p>
        </motion.div>
    );
};

const FloatingIcon = ({ icon: Icon, color, size, top, left, right, bottom, delay }: any) => {
    return (
        <motion.div
            className={cn("absolute opacity-40 blur-[1px]", color)}
            style={{ top, left, right, bottom }}
            animate={{
                y: [0, -20, 0],
                rotate: [0, 15, -15, 0],
                scale: [1, 1.1, 1]
            }}
            transition={{
                duration: 5,
                repeat: Infinity,
                ease: "easeInOut",
                delay: delay
            }}
        >
            <Icon size={size} />
        </motion.div>
    )
}
