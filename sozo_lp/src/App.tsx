
import { Hero } from './components/Hero';
import { AppOverview } from './components/AppOverview';
import { Features } from './components/Features';
import { LearningFlow } from './components/LearningFlow';
import { HowItWorks } from './components/HowItWorks';
import { Footer } from './components/Footer';

function App() {
  return (
    <div className="font-sans antialiased text-slate-800 bg-background min-h-screen">
      <Hero />
      <AppOverview />
      <LearningFlow />
      <Features />
      <HowItWorks />
      <Footer />
    </div>
  );
}

export default App;
