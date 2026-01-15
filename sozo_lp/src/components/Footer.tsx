
import { motion } from 'framer-motion';

export const Footer = () => {
    return (
        <footer className="bg-primary text-white py-20 relative overflow-hidden z-10">
            {/* Background decoration */}
            <div className="absolute top-[-50%] right-[-10%] w-[500px] h-[500px] bg-white/10 rounded-full blur-3xl pointer-events-none" />

            {/* Top Wave - Animated Transition */}
            <div className="absolute top-[-1px] left-0 w-full overflow-hidden leading-none z-10">
                <motion.div
                    animate={{ x: ["0%", "-50%"] }}
                    transition={{ duration: 14, repeat: Infinity, ease: "linear" }}
                    className="flex w-[200%]"
                >
                    <svg data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="relative block w-[50.5%] h-[60px] md:h-[100px] fill-slate-50">
                        <path d="M0,60 C400,160 800,-40 1200,60 V0 H0 Z"></path>
                    </svg>
                    <svg data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="relative block w-[50.5%] h-[60px] md:h-[100px] fill-slate-50 ml-[-1px]">
                        <path d="M0,60 C400,160 800,-40 1200,60 V0 H0 Z"></path>
                    </svg>
                </motion.div>
            </div>

            <div className="container mx-auto px-4 text-center relative z-10">
                <motion.div
                    initial={{ opacity: 0, scale: 0.9 }}
                    whileInView={{ opacity: 1, scale: 1 }}
                    viewport={{ once: true }}
                    className="max-w-2xl mx-auto mb-12"
                >
                    <h2 className="text-4xl font-bold mb-6">英語の世界への扉を開こう</h2>
                    <p className="text-white/80 mb-10 text-lg">
                        SOZOの英会話なら、楽しみながら確実に力がつく。<br />
                        まずは無料で体験してみてください。
                    </p>

                    <button className="bg-white text-primary font-bold py-4 px-12 rounded-full shadow-lg hover:shadow-xl hover:bg-slate-50 transform hover:scale-105 transition-all text-xl">
                        アプリをダウンロード
                    </button>
                </motion.div>

                <div className="border-t border-white/20 pt-8 flex flex-col md:flex-row justify-between items-center text-sm text-white/60">
                    <p>© 2024 SOZO. All rights reserved.</p>
                    <div className="flex gap-6 mt-4 md:mt-0">
                        <a href="#" className="hover:text-white transition-colors">プライバシーポリシー</a>
                        <a href="#" className="hover:text-white transition-colors">利用規約</a>
                        <a href="#" className="hover:text-white transition-colors">お問い合わせ</a>
                    </div>
                </div>
            </div>
        </footer>
    );
};
