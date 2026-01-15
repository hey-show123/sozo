import { motion, useInView } from 'framer-motion';
import { useRef, useEffect } from 'react';
import { Sparkles, Brain, MessageSquare, Mic, Volume2, FileCheck, Zap } from 'lucide-react';

export const Features = () => {
    const containerRef = useRef(null);
    const canvasRef = useRef<HTMLCanvasElement>(null);

    const isInView = useInView(containerRef, { amount: 0.15, once: true });

    // ============================================
    // WAVE ANIMATION
    // ============================================
    useEffect(() => {
        const canvas = canvasRef.current;
        if (!canvas || !isInView) return;

        const ctx = canvas.getContext('2d');
        if (!ctx) return;

        let animationId: number;
        let time = 0;

        const resize = () => {
            canvas.width = canvas.offsetWidth * window.devicePixelRatio;
            canvas.height = canvas.offsetHeight * window.devicePixelRatio;
            ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
        };

        resize();
        window.addEventListener('resize', resize);

        const draw = () => {
            const w = canvas.offsetWidth;
            const h = canvas.offsetHeight;

            ctx.clearRect(0, 0, w, h);

            const waveCount = 12;
            const baseY = h * 0.5;

            for (let i = 0; i < waveCount; i++) {
                const amplitude = 40 + i * 10;
                const numCycles = 2 + i * 0.3;
                const frequency = (2 * Math.PI * numCycles) / w;
                const speed = 0.015 + i * 0.003;
                const yOffset = (i - waveCount / 2) * 35;

                const gradient = ctx.createLinearGradient(0, 0, w, 0);
                const alpha = 0.4 - i * 0.025;
                const hue = 260 + i * 12;

                gradient.addColorStop(0, `hsla(${hue}, 80%, 65%, ${alpha * 0.3})`);
                gradient.addColorStop(0.15, `hsla(${hue}, 80%, 65%, ${alpha})`);
                gradient.addColorStop(0.5, `hsla(${hue + 25}, 80%, 70%, ${alpha * 1.3})`);
                gradient.addColorStop(0.85, `hsla(${hue}, 80%, 65%, ${alpha})`);
                gradient.addColorStop(1, `hsla(${hue}, 80%, 65%, ${alpha * 0.3})`);

                ctx.strokeStyle = gradient;
                ctx.lineWidth = 2.5 + i * 0.6;
                ctx.lineCap = 'round';
                ctx.beginPath();

                for (let x = 0; x <= w; x += 2) {
                    const phase = time * speed;
                    const y = baseY + yOffset +
                        Math.sin(x * frequency + phase) * amplitude +
                        Math.sin(x * frequency * 2.5 + phase * 1.4) * (amplitude * 0.25);

                    if (x === 0) {
                        ctx.moveTo(x, y);
                    } else {
                        ctx.lineTo(x, y);
                    }
                }

                ctx.stroke();
            }

            time += 1;
            animationId = requestAnimationFrame(draw);
        };

        draw();

        return () => {
            cancelAnimationFrame(animationId);
            window.removeEventListener('resize', resize);
        };
    }, [isInView]);

    // Animation variants for staggered entrance
    const containerVariants = {
        hidden: { opacity: 0 },
        visible: {
            opacity: 1,
            transition: {
                staggerChildren: 0.15,
                delayChildren: 0.2
            }
        }
    };

    const itemVariants = {
        hidden: { opacity: 0, y: 40 },
        visible: {
            opacity: 1,
            y: 0,
            transition: {
                duration: 0.6,
                ease: [0.25, 0.1, 0.25, 1]
            }
        }
    };

    return (
        <section ref={containerRef} className="py-32 md:py-40 relative overflow-hidden bg-slate-950">
            {/* Section Background */}
            <div className="absolute inset-0 z-0 bg-slate-950" />

            {/* Radial gradient background */}
            <div className="absolute inset-0 z-[1] bg-[radial-gradient(ellipse_at_center,_var(--tw-gradient-stops))] from-slate-900 via-slate-950 to-slate-950" />

            {/* Wave Canvas Background */}
            <canvas
                ref={canvasRef}
                className="absolute inset-0 w-full h-full z-[2] pointer-events-none"
            />

            {/* Glowing Ambient Light - Enhanced */}
            <motion.div
                initial={{ opacity: 0 }}
                animate={{
                    opacity: isInView ? [0.3, 0.6, 0.3] : 0,
                    scale: isInView ? [1, 1.25, 1] : 1
                }}
                transition={{ duration: 7, repeat: Infinity, delay: 0.8 }}
                className="absolute top-0 left-1/4 w-[800px] h-[800px] bg-purple-600/15 rounded-full blur-[120px] mix-blend-screen"
            />
            <motion.div
                initial={{ opacity: 0 }}
                animate={{
                    opacity: isInView ? [0.2, 0.5, 0.2] : 0,
                    scale: isInView ? [1.25, 1, 1.25] : 1.25
                }}
                transition={{ duration: 9, repeat: Infinity, delay: 1.5 }}
                className="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-cyan-600/15 rounded-full blur-[100px] mix-blend-screen"
            />

            {/* Main Content with staggered animation */}
            <motion.div
                className="max-w-6xl mx-auto px-4 relative z-10"
                variants={containerVariants}
                initial="hidden"
                animate={isInView ? "visible" : "hidden"}
            >
                {/* Header */}
                <div className="text-center mb-16">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true, amount: 0.8, margin: "-100px" }}
                        transition={{ duration: 0.6 }}
                        className="inline-flex items-center gap-2 px-5 py-2.5 bg-white/5 border border-white/10 rounded-full mb-8 backdrop-blur-md"
                    >
                        <motion.div
                            animate={{ rotate: 360 }}
                            transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                        >
                            <Sparkles className="w-4 h-4 text-purple-400" />
                        </motion.div>
                        <span className="text-sm font-medium text-purple-300">Powered by OpenAI</span>
                        <motion.div
                            animate={{ scale: [1, 1.2, 1] }}
                            transition={{ duration: 1.5, repeat: Infinity }}
                            className="w-2 h-2 bg-green-400 rounded-full shadow-[0_0_10px_rgba(74,222,128,0.8)]"
                        />
                    </motion.div>

                    <motion.h2
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true, amount: 0.8, margin: "-100px" }}
                        transition={{ duration: 0.6, delay: 0.1 }}
                        className="text-5xl md:text-7xl font-black text-white mb-6 relative"
                    >
                        <motion.span
                            animate={{
                                backgroundPosition: ['0% 50%', '100% 50%', '0% 50%'],
                            }}
                            transition={{ duration: 5, repeat: Infinity }}
                            className="bg-gradient-to-r from-purple-400 via-pink-400 via-cyan-400 to-purple-400 bg-[size:200%_auto] bg-clip-text text-transparent"
                        >
                            GPT-5
                        </motion.span>
                        <span className="text-white"> 搭載</span>

                        {/* Floating sparkles around title */}
                        <motion.div
                            animate={{ y: [-10, 10, -10], rotate: [0, 180, 360] }}
                            transition={{ duration: 4, repeat: Infinity }}
                            className="absolute -top-4 -right-4 text-yellow-400"
                        >
                            <Sparkles size={24} />
                        </motion.div>
                    </motion.h2>

                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true, amount: 0.8, margin: "-100px" }}
                        transition={{ duration: 0.6, delay: 0.2 }}
                        className="text-slate-400 text-lg md:text-xl max-w-2xl mx-auto leading-relaxed"
                    >
                        最先端のAI技術があなたの英語学習を革新。
                        <br />
                        <span className="text-purple-300">人間のような自然な会話</span>と<span className="text-cyan-300">的確なフィードバック</span>を実現します。
                    </motion.p>
                </div>

                {/* GPT-5 Usage Cards */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
                    {/* AI会話練習 */}
                    <motion.div
                        initial={{ opacity: 0, x: -50, rotateY: -10 }}
                        whileInView={{ opacity: 1, x: 0, rotateY: 0 }}
                        viewport={{ once: true, amount: 0.4, margin: "-50px" }}
                        transition={{ duration: 0.8, delay: 0.3 }}
                        whileHover={{ scale: 1.02, rotateY: 5 }}
                        className="relative group"
                        style={{ perspective: 1000 }}
                    >
                        {/* Glow effect on hover */}
                        <div className="absolute -inset-1 bg-gradient-to-r from-purple-600 to-pink-600 rounded-3xl opacity-0 group-hover:opacity-50 blur-xl transition-opacity duration-500" />

                        <div className="relative bg-gradient-to-br from-purple-500/20 via-purple-500/10 to-pink-500/20 rounded-3xl border border-purple-500/30 p-8 backdrop-blur-xl overflow-hidden">
                            {/* Animated border */}
                            <div className="absolute inset-0 rounded-3xl">
                                <motion.div
                                    animate={{ rotate: 360 }}
                                    transition={{ duration: 8, repeat: Infinity, ease: "linear" }}
                                    className="absolute inset-0 bg-gradient-conic from-purple-500 via-transparent to-purple-500 opacity-20"
                                    style={{ clipPath: 'inset(0 round 1.5rem)' }}
                                />
                            </div>

                            {/* Floating particles inside card */}
                            {[...Array(5)].map((_, i) => (
                                <motion.div
                                    key={i}
                                    animate={{
                                        y: [0, -30, 0],
                                        x: [0, Math.random() * 20 - 10, 0],
                                        opacity: [0.3, 0.8, 0.3],
                                    }}
                                    transition={{
                                        duration: 3 + i,
                                        repeat: Infinity,
                                        delay: i * 0.5,
                                    }}
                                    className="absolute w-1 h-1 bg-purple-400 rounded-full"
                                    style={{ left: `${20 + i * 15}%`, bottom: '20%' }}
                                />
                            ))}

                            <div className="relative z-10">
                                <div className="flex items-center gap-4 mb-6">
                                    <motion.div
                                        animate={{
                                            boxShadow: [
                                                '0 0 20px rgba(168,85,247,0.3)',
                                                '0 0 40px rgba(168,85,247,0.6)',
                                                '0 0 20px rgba(168,85,247,0.3)',
                                            ]
                                        }}
                                        transition={{ duration: 2, repeat: Infinity }}
                                        className="w-16 h-16 rounded-2xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center"
                                    >
                                        <motion.div
                                            animate={{ rotate: [0, 10, -10, 0] }}
                                            transition={{ duration: 4, repeat: Infinity }}
                                        >
                                            <MessageSquare className="w-8 h-8 text-white" />
                                        </motion.div>
                                    </motion.div>
                                    <div>
                                        <h3 className="text-2xl font-bold text-white">AI会話練習</h3>
                                        <p className="text-purple-300 text-sm">リアルタイム会話シミュレーション</p>
                                    </div>
                                </div>

                                <p className="text-slate-300 mb-6 leading-relaxed text-lg">
                                    お客様役のAIとリアルタイムで英会話。
                                    サロンの接客シーンを想定した自然な対話で、
                                    <span className="text-purple-300 font-semibold">実践的なスピーキング力</span>を養います。
                                </p>

                                <div className="space-y-4">
                                    {[
                                        { icon: Mic, text: "音声認識でハンズフリー会話", color: "purple" },
                                        { icon: Volume2, text: "AIの声を聞いてリスニング強化", color: "pink" },
                                        { icon: Brain, text: "文脈を理解した自然な返答", color: "violet" },
                                    ].map((item, i) => (
                                        <motion.div
                                            key={i}
                                            initial={{ opacity: 0, x: -20 }}
                                            whileInView={{ opacity: 1, x: 0 }}
                                            transition={{ delay: 0.5 + i * 0.1 }}
                                            className="flex items-center gap-3 text-slate-300"
                                        >
                                            <div className={`w-8 h-8 rounded-lg bg-${item.color}-500/20 flex items-center justify-center`}>
                                                <item.icon className={`w-4 h-4 text-${item.color}-400`} />
                                            </div>
                                            <span>{item.text}</span>
                                        </motion.div>
                                    ))}
                                </div>
                            </div>
                        </div>
                    </motion.div>

                    {/* 応用練習 */}
                    <motion.div
                        initial={{ opacity: 0, x: 50, rotateY: 10 }}
                        whileInView={{ opacity: 1, x: 0, rotateY: 0 }}
                        viewport={{ once: true, amount: 0.4, margin: "-50px" }}
                        transition={{ duration: 0.8, delay: 0.4 }}
                        whileHover={{ scale: 1.02, rotateY: -5 }}
                        className="relative group"
                        style={{ perspective: 1000 }}
                    >
                        {/* Glow effect on hover */}
                        <div className="absolute -inset-1 bg-gradient-to-r from-cyan-600 to-blue-600 rounded-3xl opacity-0 group-hover:opacity-50 blur-xl transition-opacity duration-500" />

                        <div className="relative bg-gradient-to-br from-cyan-500/20 via-cyan-500/10 to-blue-500/20 rounded-3xl border border-cyan-500/30 p-8 backdrop-blur-xl overflow-hidden">
                            {/* Animated border */}
                            <div className="absolute inset-0 rounded-3xl">
                                <motion.div
                                    animate={{ rotate: -360 }}
                                    transition={{ duration: 8, repeat: Infinity, ease: "linear" }}
                                    className="absolute inset-0 bg-gradient-conic from-cyan-500 via-transparent to-cyan-500 opacity-20"
                                    style={{ clipPath: 'inset(0 round 1.5rem)' }}
                                />
                            </div>

                            {/* Score animation */}
                            <motion.div
                                animate={{ scale: [1, 1.1, 1], opacity: [0.1, 0.2, 0.1] }}
                                transition={{ duration: 3, repeat: Infinity }}
                                className="absolute top-4 right-4 text-6xl font-black text-cyan-500/20"
                            >
                                100
                            </motion.div>

                            <div className="relative z-10">
                                <div className="flex items-center gap-4 mb-6">
                                    <motion.div
                                        animate={{
                                            boxShadow: [
                                                '0 0 20px rgba(34,211,238,0.3)',
                                                '0 0 40px rgba(34,211,238,0.6)',
                                                '0 0 20px rgba(34,211,238,0.3)',
                                            ]
                                        }}
                                        transition={{ duration: 2, repeat: Infinity }}
                                        className="w-16 h-16 rounded-2xl bg-gradient-to-br from-cyan-500 to-blue-500 flex items-center justify-center"
                                    >
                                        <motion.div
                                            animate={{ scale: [1, 1.1, 1] }}
                                            transition={{ duration: 2, repeat: Infinity }}
                                        >
                                            <FileCheck className="w-8 h-8 text-white" />
                                        </motion.div>
                                    </motion.div>
                                    <div>
                                        <h3 className="text-2xl font-bold text-white">応用練習</h3>
                                        <p className="text-cyan-300 text-sm">AIによる精密スコアリング</p>
                                    </div>
                                </div>

                                <p className="text-slate-300 mb-6 leading-relaxed text-lg">
                                    状況に応じた英語表現をアウトプット。
                                    AIが<span className="text-cyan-300 font-semibold">100点満点で厳格に採点</span>し、
                                    具体的な改善点をフィードバックします。
                                </p>

                                <div className="space-y-4">
                                    {[
                                        { icon: Mic, text: "音声入力で回答を録音", color: "cyan" },
                                        { icon: FileCheck, text: "文法・語彙・状況適切性を評価", color: "blue" },
                                        { icon: Zap, text: "具体的な改善アドバイス", color: "teal" },
                                    ].map((item, i) => (
                                        <motion.div
                                            key={i}
                                            initial={{ opacity: 0, x: 20 }}
                                            whileInView={{ opacity: 1, x: 0 }}
                                            transition={{ delay: 0.6 + i * 0.1 }}
                                            className="flex items-center gap-3 text-slate-300"
                                        >
                                            <div className={`w-8 h-8 rounded-lg bg-${item.color}-500/20 flex items-center justify-center`}>
                                                <item.icon className={`w-4 h-4 text-${item.color}-400`} />
                                            </div>
                                            <span>{item.text}</span>
                                        </motion.div>
                                    ))}
                                </div>
                            </div>
                        </div>
                    </motion.div>
                </div>

                {/* Technology Stack */}
                <motion.div
                    initial={{ opacity: 0, y: 40 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true, amount: 0.5, margin: "-100px" }}
                    transition={{ duration: 0.8, delay: 0.5 }}
                    className="relative"
                >
                    {/* Animated border glow */}
                    <div className="absolute -inset-px bg-gradient-to-r from-purple-500 via-cyan-500 to-purple-500 rounded-3xl opacity-30 blur-sm animate-pulse" />

                    <div className="relative bg-slate-900/80 border border-white/10 rounded-3xl p-8 md:p-10 backdrop-blur-xl">
                        <div className="flex flex-col md:flex-row items-center justify-between gap-8">
                            <div className="flex items-center gap-6">
                                {/* Animated Brain Icon */}
                                <div className="relative">
                                    <motion.div
                                        animate={{ rotate: 360 }}
                                        transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                                        className="w-20 h-20 rounded-full border-2 border-purple-500/30 flex items-center justify-center"
                                    >
                                        <motion.div
                                            animate={{ rotate: -360 }}
                                            transition={{ duration: 15, repeat: Infinity, ease: "linear" }}
                                            className="w-14 h-14 rounded-full border-2 border-pink-500/30 flex items-center justify-center"
                                        >
                                            <motion.div
                                                animate={{
                                                    scale: [1, 1.15, 1],
                                                    boxShadow: [
                                                        '0 0 30px rgba(168,85,247,0.4)',
                                                        '0 0 60px rgba(168,85,247,0.7)',
                                                        '0 0 30px rgba(168,85,247,0.4)',
                                                    ]
                                                }}
                                                transition={{ duration: 2, repeat: Infinity }}
                                                className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center"
                                            >
                                                <Brain className="w-5 h-5 text-white" />
                                            </motion.div>
                                        </motion.div>
                                    </motion.div>

                                    {/* Orbiting dots */}
                                    {[0, 1, 2].map((i) => (
                                        <motion.div
                                            key={i}
                                            animate={{ rotate: 360 }}
                                            transition={{ duration: 4 + i, repeat: Infinity, ease: "linear" }}
                                            className="absolute inset-0"
                                            style={{ transformOrigin: 'center' }}
                                        >
                                            <div
                                                className="absolute w-2 h-2 bg-purple-400 rounded-full shadow-[0_0_10px_rgba(168,85,247,0.8)]"
                                                style={{
                                                    top: '0%',
                                                    left: '50%',
                                                    transform: 'translateX(-50%)'
                                                }}
                                            />
                                        </motion.div>
                                    ))}
                                </div>

                                <div>
                                    <h4 className="text-xl md:text-2xl font-bold text-white mb-1">OpenAI GPT-5 シリーズ</h4>
                                    <p className="text-slate-400">次世代の言語モデルで英語学習を加速</p>
                                </div>
                            </div>

                            <div className="flex flex-wrap justify-center gap-3">
                                {[
                                    { emoji: "🧠", text: "高度な文脈理解", color: "purple" },
                                    { emoji: "⚡", text: "超高速レスポンス", color: "pink" },
                                    { emoji: "🎯", text: "的確なフィードバック", color: "cyan" },
                                ].map((tag, i) => (
                                    <motion.span
                                        key={i}
                                        whileHover={{ scale: 1.05, y: -2 }}
                                        className={`px-4 py-2 bg-${tag.color}-500/10 text-${tag.color}-300 text-sm font-medium rounded-full border border-${tag.color}-500/20 cursor-default`}
                                    >
                                        {tag.emoji} {tag.text}
                                    </motion.span>
                                ))}
                            </div>
                        </div>
                    </div>
                </motion.div>
            </motion.div>

            {/* Bottom gradient - Transition to InteractiveDemo (slate-900) */}
            <div className="absolute bottom-0 left-0 right-0 h-32 z-30 bg-gradient-to-b from-transparent to-slate-900 pointer-events-none" />
        </section>
    );
};
