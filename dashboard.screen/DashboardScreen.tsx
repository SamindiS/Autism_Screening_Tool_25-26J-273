import React from 'react';
import { Assessment, AssessmentType } from '../src/types';

// FIX: Changed JSX.Element to React.ReactNode to resolve namespace error.
const OverviewCard: React.FC<{ icon: React.ReactNode; value: number; label: string; }> = ({ icon, value, label }) => (
    <div className="bg-white p-4 rounded-lg shadow-md flex items-center space-x-4">
        <div className="bg-slate-100 p-3 rounded-full text-purple-600">
            {icon}
        </div>
        <div>
            <p className="text-2xl font-bold text-slate-800">{value}</p>
            <p className="text-sm text-slate-500">{label}</p>
        </div>
    </div>
);

// FIX: Changed JSX.Element to React.ReactNode to resolve namespace error.
const AssessmentCard: React.FC<{ icon: React.ReactNode; title: string; description: string; color: string; onClick: () => void; }> = ({ icon, title, description, color, onClick }) => (
    <button onClick={onClick} className={`p-6 rounded-xl text-white text-left flex flex-col h-full ${color} hover:opacity-90 transition-opacity`}>
        <div className="mb-4">{icon}</div>
        <h3 className="text-xl font-bold">{title}</h3>
        <p className="text-white/80 mt-1 flex-grow">{description}</p>
        <div className="mt-4 self-end">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
        </div>
    </button>
);

// FIX: Changed JSX.Element to React.ReactNode to resolve namespace error.
const assessmentIcons: { [key in AssessmentType]: React.ReactNode } = {
    COGNITIVE_FLEXIBILITY: <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 20v-8m0-4V4m8 8h-8m-4 0H4"/></svg>,
    REPETITIVE_BEHAVIORS: <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 12a9 9 0 1 0 18 0a9 9 0 0 0-18 0"/><path d="M12 8v8"/><path d="M8.5 14.5 12 11l3.5 3.5"/></svg>,
    MOTOR_SKILLS: <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 10h4v4h-4v-4Z"/><path d="M18 18h4v4h-4v-4Z"/><path d="M2 10h12v4H2v-4Z"/><path d="M2 18h12v4H2v-4Z"/><path d="M2 2h4v4H2V2Z"/><path d="M10 2h12v4H10V2Z"/></svg>
};

const assessments: Assessment[] = [
    {
        type: 'COGNITIVE_FLEXIBILITY',
        title: "Cognitive Flexibility & Rule-Switching",
        description: "Assesses executive functioning and rule switching abilities",
        color: "bg-indigo-500",
    },
    {
        type: 'REPETITIVE_BEHAVIORS',
        title: "Restricted & Repetitive Behaviors",
        description: "Evaluates repetitive behaviors and restricted interests",
        color: "bg-purple-500",
    },
    {
        type: 'MOTOR_SKILLS',
        title: "Motor Skills & Coordination",
        description: "Analyzes gross and fine motor skill performance",
        color: "bg-teal-500",
    },
];

interface DashboardScreenProps {
  onSelectAssessment: (assessment: Assessment) => void;
}

const DashboardScreen: React.FC<DashboardScreenProps> = ({ onSelectAssessment }) => {
    return (
        <div className="min-h-screen bg-slate-100 p-4 sm:p-8">
            <div className="w-full max-w-6xl mx-auto bg-white rounded-2xl shadow-xl overflow-hidden">
                <header className="bg-gradient-to-r from-[#6B72FF] to-[#9333EA] p-4 sm:p-6 flex flex-wrap justify-between items-center text-white">
                    <div>
                        <p className="text-sm text-white/80">Welcome,</p>
                        <h1 className="text-2xl font-bold">Test Doctor</h1>
                    </div>
                    <div className="flex items-center space-x-4 mt-2 sm:mt-0">
                         <button className="flex items-center space-x-2 bg-white/20 text-white px-3 py-2 rounded-lg text-sm">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z"/><path d="M2 12h20"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                            <span>English</span>
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m6 9 6 6 6-6"/></svg>
                        </button>
                        <button className="relative p-2 bg-white/20 rounded-full">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></svg>
                             <span className="absolute top-0 right-0 block h-2 w-2 rounded-full bg-red-500 ring-2 ring-white"></span>
                        </button>
                        <button className="p-2 bg-white/20 rounded-full">
                           <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </button>
                    </div>
                </header>

                <main className="p-6 sm:p-8">
                    <section>
                        <h2 className="text-xl font-bold text-slate-700 mb-4">Overview</h2>
                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                            <OverviewCard icon={<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>} value={16} label="Total Children" />
                            <OverviewCard icon={<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>} value={0} label="Completed" />
                            <OverviewCard icon={<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>} value={16} label="Pending" />
                            <OverviewCard icon={<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>} value={0} label="Today" />
                        </div>
                    </section>
                    
                    <section className="mt-10">
                        <h2 className="text-xl font-bold text-slate-700 mb-2">Assessment Components</h2>
                        <p className="text-slate-500 mb-6">Choose a component to begin assessment</p>
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            {assessments.map((assessment) => (
                                <AssessmentCard
                                    key={assessment.type}
                                    onClick={() => onSelectAssessment(assessment)}
                                    icon={assessmentIcons[assessment.type]}
                                    title={assessment.title}
                                    description={assessment.description}
                                    color={assessment.color}
                                />
                            ))}
                        </div>
                    </section>
                </main>
            </div>
        </div>
    );
};

export default DashboardScreen;