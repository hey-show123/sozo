
import { motion } from 'framer-motion';
import { Download, UserPlus, PlayCircle } from 'lucide-react';

const steps = [
    {
        icon: <Download className="w-8 h-8 text-primary" />,
        title: "1. アプリをダウンロード",
        description: "App StoreまたはGoogle Playから無料でダウンロード。"
    },
    {
        icon: <UserPlus className="w-8 h-8 text-secondary" />,
        title: "2. アカウント作成",
        description: "簡単な質問に答えて、あなたに最適なプランを作成。"
    },
    {
        icon: <PlayCircle className="w-8 h-8 text-pop-pink" />,
        title: "3. 学習スタート",
        description: "AIとの会話やレッスンを楽しみましょう！"
    }
];

export const HowItWorks = () => {
    return (
        <section className="py-20 bg-slate-50">
            <div className="container mx-auto px-4">
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    className="text-center mb-16"
                >
                    <span className="text-secondary font-bold tracking-widest uppercase text-sm mb-2 block">Steps</span>
                    <h2 className="text-4xl font-bold text-slate-800">始め方はとても簡単</h2>
                </motion.div>

                <div className="max-w-4xl mx-auto">
                    {steps.map((step, index) => (
                        <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -20 }}
                            whileInView={{ opacity: 1, x: 0 }}
                            viewport={{ once: true }}
                            transition={{ delay: index * 0.2 }}
                            className="flex items-center mb-12 last:mb-0 relative"
                        >
                            {index !== steps.length - 1 && (
                                <div className="absolute left-8 top-20 bottom-[-40px] w-1 bg-slate-200 -z-10" />
                            )}

                            <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center shadow-md border border-slate-100 z-10 shrink-0 mr-8">
                                {step.icon}
                            </div>

                            <div>
                                <h3 className="text-xl font-bold text-slate-800 mb-2">{step.title}</h3>
                                <p className="text-slate-600">{step.description}</p>
                            </div>
                        </motion.div>
                    ))}
                </div>
            </div>
        </section>
    );
};
