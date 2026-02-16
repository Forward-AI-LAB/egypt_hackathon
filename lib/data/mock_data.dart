/// ====================================================================
/// Forward AI — Mock Data
/// ====================================================================
/// All hardcoded data for the MVP. This allows the app to run entirely
/// offline without any API calls or backend services.
/// ====================================================================

import '../models/personality_question.dart';
import '../models/track_info.dart';
import '../models/analysis_result.dart';

/// Personality quiz questions designed to identify frontend dev traits.
///
/// Traits measured: creative, analytical, visual, collaborative, detail
const List<PersonalityQuestion> mockQuizQuestions = [
  PersonalityQuestion(
    question: 'When you visit a website, what catches your eye first?',
    emoji: '👀',
    options: [
      QuizOption(label: 'The visual design and colors', trait: 'visual'),
      QuizOption(label: 'How fast it loads', trait: 'analytical'),
      QuizOption(label: 'The overall user experience', trait: 'creative'),
      QuizOption(label: 'Whether the info is well-organized', trait: 'detail'),
    ],
  ),
  PersonalityQuestion(
    question: 'How do you prefer to solve problems?',
    emoji: '🧩',
    options: [
      QuizOption(label: 'Sketch or draw out ideas', trait: 'visual'),
      QuizOption(label: 'Break it into logical steps', trait: 'analytical'),
      QuizOption(label: 'Brainstorm creative solutions', trait: 'creative'),
      QuizOption(label: 'Discuss with others for input', trait: 'collaborative'),
    ],
  ),
  PersonalityQuestion(
    question: 'What type of project excites you the most?',
    emoji: '🚀',
    options: [
      QuizOption(label: 'Building beautiful interfaces', trait: 'visual'),
      QuizOption(label: 'Making things work smoothly', trait: 'analytical'),
      QuizOption(label: 'Creating something people love', trait: 'creative'),
      QuizOption(label: 'Polishing every tiny detail', trait: 'detail'),
    ],
  ),
  PersonalityQuestion(
    question: 'Pick your ideal work environment:',
    emoji: '🏢',
    options: [
      QuizOption(label: 'A creative studio with whiteboards', trait: 'creative'),
      QuizOption(label: 'A quiet, focused workspace', trait: 'analytical'),
      QuizOption(label: 'A collaborative open office', trait: 'collaborative'),
      QuizOption(label: 'Remote with design tools at hand', trait: 'visual'),
    ],
  ),
  PersonalityQuestion(
    question: 'Which school subject did you enjoy most?',
    emoji: '📚',
    options: [
      QuizOption(label: 'Art or Design', trait: 'visual'),
      QuizOption(label: 'Math or Science', trait: 'analytical'),
      QuizOption(label: 'Creative Writing', trait: 'creative'),
      QuizOption(label: 'Group Projects', trait: 'collaborative'),
    ],
  ),
  PersonalityQuestion(
    question: 'What matters most when you create something?',
    emoji: '✨',
    options: [
      QuizOption(label: 'It looks stunning', trait: 'visual'),
      QuizOption(label: 'It works perfectly', trait: 'analytical'),
      QuizOption(label: 'It\'s unique and original', trait: 'creative'),
      QuizOption(label: 'Every edge case is handled', trait: 'detail'),
    ],
  ),
  PersonalityQuestion(
    question: 'How do you feel about pixel-perfect design?',
    emoji: '🎯',
    options: [
      QuizOption(label: 'Love it — details matter!', trait: 'detail'),
      QuizOption(label: 'It\'s satisfying to get right', trait: 'visual'),
      QuizOption(label: 'I care more about functionality', trait: 'analytical'),
      QuizOption(label: 'I prefer big-picture thinking', trait: 'creative'),
    ],
  ),
  PersonalityQuestion(
    question: 'Pick a superpower for your career:',
    emoji: '⚡',
    options: [
      QuizOption(label: 'Turn any idea into a visual reality', trait: 'visual'),
      QuizOption(label: 'Debug any problem in seconds', trait: 'analytical'),
      QuizOption(label: 'Design experiences people remember', trait: 'creative'),
      QuizOption(label: 'Make teams work better together', trait: 'collaborative'),
    ],
  ),
];

/// Frontend Development track information for the vibe screen.
const TrackInfo frontendTrackInfo = TrackInfo(
  name: 'Frontend Development',
  tagline: 'Craft beautiful, interactive digital experiences',
  description:
      'Frontend developers are the architects of what users see and interact with. '
      'You\'ll transform designs into living, breathing web applications using '
      'HTML, CSS, JavaScript, and modern frameworks. It\'s where creativity meets code.',
  emoji: '🎨',
  tools: [
    TrackTool(name: 'React', category: 'Framework'),
    TrackTool(name: 'Next.js', category: 'Framework'),
    TrackTool(name: 'TypeScript', category: 'Language'),
    TrackTool(name: 'JavaScript', category: 'Language'),
    TrackTool(name: 'HTML/CSS', category: 'Core'),
    TrackTool(name: 'Tailwind CSS', category: 'Styling'),
    TrackTool(name: 'Figma', category: 'Design'),
    TrackTool(name: 'Git', category: 'Tool'),
    TrackTool(name: 'VS Code', category: 'Tool'),
    TrackTool(name: 'Chrome DevTools', category: 'Tool'),
    TrackTool(name: 'npm', category: 'Tool'),
    TrackTool(name: 'Vercel', category: 'Deployment'),
  ],
  salaryRange: '\$50K – \$120K / year',
  dayInTheLife: [
    DayActivity(time: '9:00 AM', activity: 'Check Slack, review PRs over coffee', emoji: '☕'),
    DayActivity(time: '9:30 AM', activity: 'Daily standup with the team', emoji: '🗣️'),
    DayActivity(time: '10:00 AM', activity: 'Implement new UI components in React', emoji: '⚛️'),
    DayActivity(time: '12:00 PM', activity: 'Lunch break & tech Twitter scroll', emoji: '🍕'),
    DayActivity(time: '1:00 PM', activity: 'Collaborate with designers on Figma', emoji: '🎨'),
    DayActivity(time: '2:30 PM', activity: 'Fix responsive layout bugs', emoji: '🐛'),
    DayActivity(time: '4:00 PM', activity: 'Write unit tests & accessibility audit', emoji: '✅'),
    DayActivity(time: '5:00 PM', activity: 'Deploy to staging & wrap up', emoji: '🚀'),
  ],
  fittingTraits: [
    'Creative & visually-minded',
    'Attention to detail',
    'Love for clean, elegant UI',
    'Curious about design trends',
    'Collaborative team player',
    'Patient with pixel-perfect work',
  ],
  sampleProjects: [
    SampleProject(
      name: 'Personal Portfolio Website',
      description: 'Build a stunning portfolio to showcase your work with animations and dark mode.',
      difficulty: 'Beginner',
    ),
    SampleProject(
      name: 'Weather Dashboard',
      description: 'A real-time weather app with charts, maps, and dynamic backgrounds.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'E-Commerce Product Page',
      description: 'A fully responsive product page with image gallery, reviews, and cart.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'Social Media Feed Clone',
      description: 'Recreate a Twitter/Instagram feed with infinite scroll and animations.',
      difficulty: 'Advanced',
    ),
  ],
  vibeStats: [
    '🎨 95% Visual & Creative',
    '🏠 Remote-Friendly',
    '📈 High Demand in 2026',
    '🌍 Global Opportunities',
    '⚡ Fast-Paced & Ever-Evolving',
    '🤝 Design + Engineering Hybrid',
  ],
);

/// Mock analysis result so the career analysis works without a backend.
AnalysisResult getMockAnalysisResult({
  required String jobTitle,
  required List<String> userSkills,
}) {
  final marketSkills = [
    'HTML',
    'CSS',
    'JavaScript',
    'TypeScript',
    'React',
    'Next.js',
    'Tailwind CSS',
    'Git',
    'Responsive Design',
    'REST APIs',
    'Testing (Jest)',
    'Figma',
  ];

  final matchedSkills = userSkills
      .where((s) => marketSkills.any(
          (m) => m.toLowerCase() == s.toLowerCase()))
      .toList();

  final missingSkills = marketSkills
      .where((m) => !userSkills.any(
          (s) => s.toLowerCase() == m.toLowerCase()))
      .toList();

  return AnalysisResult(
    success: true,
    jobTitle: jobTitle.isEmpty ? 'Frontend Developer' : jobTitle,
    marketSkills: marketSkills,
    matchedSkills: matchedSkills,
    missingSkills: missingSkills,
    roadmap: [
      const RoadmapWeek(
        week: 1,
        topic: 'HTML & CSS Mastery',
        description:
            'Build a strong foundation with semantic HTML5 and modern CSS including Flexbox, Grid, and responsive design patterns.',
        resources: [
          'MDN Web Docs — HTML & CSS',
          'freeCodeCamp Responsive Web Design',
          'CSS-Tricks: A Complete Guide to Flexbox',
        ],
        link: 'https://developer.mozilla.org/en-US/docs/Learn',
      ),
      const RoadmapWeek(
        week: 2,
        topic: 'JavaScript Fundamentals',
        description:
            'Master core JS concepts: variables, functions, arrays, objects, DOM manipulation, async/await, and ES6+ features.',
        resources: [
          'JavaScript.info — Modern JS Tutorial',
          'Eloquent JavaScript (free book)',
          'freeCodeCamp JavaScript Algorithms',
        ],
        link: 'https://javascript.info/',
      ),
      const RoadmapWeek(
        week: 3,
        topic: 'React Framework',
        description:
            'Learn component-based architecture, JSX, state management with hooks, props, and lifecycle methods.',
        resources: [
          'Official React Docs (react.dev)',
          'React Tutorial — Tic-Tac-Toe',
          'Scrimba — Learn React for Free',
        ],
        link: 'https://react.dev/learn',
      ),
      const RoadmapWeek(
        week: 4,
        topic: 'TypeScript & Tailwind CSS',
        description:
            'Add type safety with TypeScript and utility-first styling with Tailwind CSS for rapid UI development.',
        resources: [
          'TypeScript Handbook',
          'Tailwind CSS Documentation',
          'Build a project with React + TS + Tailwind',
        ],
        link: 'https://www.typescriptlang.org/docs/',
      ),
      const RoadmapWeek(
        week: 5,
        topic: 'Next.js & Deployment',
        description:
            'Build production-ready apps with Next.js: routing, SSR, API routes, and deploy to Vercel.',
        resources: [
          'Next.js Learn Course',
          'Vercel Deployment Guide',
          'Build a full-stack app with Next.js',
        ],
        link: 'https://nextjs.org/learn',
      ),
    ],
    metadata: AnalysisMetadata(
      totalMarketSkills: marketSkills.length,
      totalMatched: matchedSkills.length,
      totalMissing: missingSkills.length,
      roadmapWeeks: 5,
      processingTimeMs: 1547,
    ),
  );
}
