/// ====================================================================
/// Forward AI — Mock Data
/// ====================================================================
/// All hardcoded data for the MVP. This allows the app to run entirely
/// offline without any API calls or backend services.
///
/// Tracks supported: Frontend, Backend, Mobile, Data Science, DevOps,
/// UI/UX Design.
/// ====================================================================
library;

import '../models/personality_question.dart';
import '../models/track_info.dart';
import '../models/analysis_result.dart';

/// Personality quiz questions designed to identify developer traits.
///
/// Traits measured: creative, analytical, visual, collaborative, detail,
///                  systematic, curious
///
/// Questions are track-neutral — they probe personality dimensions rather
/// than asking "do you like frontend?".
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
      QuizOption(label: 'Optimizing systems for performance', trait: 'systematic'),
      QuizOption(label: 'Creating something people love', trait: 'creative'),
      QuizOption(label: 'Analyzing data to find patterns', trait: 'curious'),
    ],
  ),
  PersonalityQuestion(
    question: 'Pick your ideal work environment:',
    emoji: '🏢',
    options: [
      QuizOption(label: 'A creative studio with whiteboards', trait: 'creative'),
      QuizOption(label: 'A quiet, focused workspace', trait: 'analytical'),
      QuizOption(label: 'A collaborative open office', trait: 'collaborative'),
      QuizOption(label: 'Remote with powerful hardware', trait: 'systematic'),
    ],
  ),
  PersonalityQuestion(
    question: 'Which school subject did you enjoy most?',
    emoji: '📚',
    options: [
      QuizOption(label: 'Art or Design', trait: 'visual'),
      QuizOption(label: 'Math or Science', trait: 'analytical'),
      QuizOption(label: 'Creative Writing', trait: 'creative'),
      QuizOption(label: 'Statistics or Research', trait: 'curious'),
    ],
  ),
  PersonalityQuestion(
    question: 'What matters most when you create something?',
    emoji: '✨',
    options: [
      QuizOption(label: 'It looks stunning', trait: 'visual'),
      QuizOption(label: 'It works perfectly under the hood', trait: 'analytical'),
      QuizOption(label: "It's unique and original", trait: 'creative'),
      QuizOption(label: 'Every edge case is handled', trait: 'detail'),
    ],
  ),
  PersonalityQuestion(
    question: 'How do you feel about automation and scripting?',
    emoji: '🤖',
    options: [
      QuizOption(label: 'Love automating repetitive tasks', trait: 'systematic'),
      QuizOption(label: 'I prefer hands-on creative work', trait: 'creative'),
      QuizOption(label: 'Great for crunching data faster', trait: 'curious'),
      QuizOption(label: 'Useful for team workflows', trait: 'collaborative'),
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

// =========================================================================
// Track Info Data — All Supported Tracks
// =========================================================================

/// Lookup map: track name → TrackInfo
const Map<String, TrackInfo> allTracks = {
  'Frontend Development': frontendTrackInfo,
  'Backend Development': backendTrackInfo,
  'Mobile Development': mobileTrackInfo,
  'Data Science': dataScienceTrackInfo,
  'DevOps Engineering': devOpsTrackInfo,
  'UI/UX Design': uiUxTrackInfo,
};

/// Frontend Development track information.
const TrackInfo frontendTrackInfo = TrackInfo(
  name: 'Frontend Development',
  tagline: 'Craft beautiful, interactive digital experiences',
  description:
      'Frontend developers are the architects of what users see and interact with. '
      "You'll transform designs into living, breathing web applications using "
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

/// Backend Development track information.
const TrackInfo backendTrackInfo = TrackInfo(
  name: 'Backend Development',
  tagline: 'Build the engines that power the digital world',
  description:
      'Backend developers design the server-side logic, databases, and APIs '
      'that make applications work behind the scenes. You\'ll build scalable, '
      'secure systems that handle millions of requests.',
  emoji: '⚙️',
  tools: [
    TrackTool(name: 'Node.js', category: 'Runtime'),
    TrackTool(name: 'Python', category: 'Language'),
    TrackTool(name: 'Java', category: 'Language'),
    TrackTool(name: 'PostgreSQL', category: 'Database'),
    TrackTool(name: 'MongoDB', category: 'Database'),
    TrackTool(name: 'Redis', category: 'Cache'),
    TrackTool(name: 'Docker', category: 'DevOps'),
    TrackTool(name: 'REST/GraphQL', category: 'API'),
    TrackTool(name: 'Git', category: 'Tool'),
    TrackTool(name: 'Linux', category: 'OS'),
    TrackTool(name: 'AWS', category: 'Cloud'),
    TrackTool(name: 'Express.js', category: 'Framework'),
  ],
  salaryRange: '\$60K – \$140K / year',
  dayInTheLife: [
    DayActivity(time: '9:00 AM', activity: 'Review overnight alerts & logs', emoji: '📋'),
    DayActivity(time: '9:30 AM', activity: 'Daily standup with the team', emoji: '🗣️'),
    DayActivity(time: '10:00 AM', activity: 'Design and implement API endpoints', emoji: '⚙️'),
    DayActivity(time: '12:00 PM', activity: 'Lunch break & tech podcast', emoji: '🎧'),
    DayActivity(time: '1:00 PM', activity: 'Database optimization & query tuning', emoji: '🗃️'),
    DayActivity(time: '2:30 PM', activity: 'Code review & security audit', emoji: '🔒'),
    DayActivity(time: '4:00 PM', activity: 'Write integration tests', emoji: '✅'),
    DayActivity(time: '5:00 PM', activity: 'Deploy to staging & monitor', emoji: '📊'),
  ],
  fittingTraits: [
    'Analytical & logical thinker',
    'Enjoys solving complex puzzles',
    'Detail-oriented & methodical',
    'Comfortable with abstractions',
    'Loves efficiency & optimization',
    'Security-conscious mindset',
  ],
  sampleProjects: [
    SampleProject(
      name: 'REST API for a Blog',
      description: 'Build a full CRUD API with authentication, pagination, and error handling.',
      difficulty: 'Beginner',
    ),
    SampleProject(
      name: 'Real-time Chat Server',
      description: 'A WebSocket-based chat server with rooms, typing indicators, and message history.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'E-Commerce Backend',
      description: 'Payment processing, inventory management, and order tracking system.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'Microservices Architecture',
      description: 'Design a distributed system with message queues, service discovery, and API gateway.',
      difficulty: 'Advanced',
    ),
  ],
  vibeStats: [
    '⚙️ 90% Logic & Architecture',
    '💰 High Salary Potential',
    '📈 Critical in Every Industry',
    '🏠 Remote-Friendly',
    '🔒 Security-Focused',
    '📊 Data-Driven',
  ],
);

/// Mobile Development track information.
const TrackInfo mobileTrackInfo = TrackInfo(
  name: 'Mobile Development',
  tagline: 'Build apps people carry in their pockets',
  description:
      'Mobile developers create native and cross-platform apps for iOS and Android. '
      "You'll blend creative design with performance optimization to deliver "
      'experiences that reach billions of users.',
  emoji: '📱',
  tools: [
    TrackTool(name: 'Flutter', category: 'Framework'),
    TrackTool(name: 'Swift', category: 'Language'),
    TrackTool(name: 'Kotlin', category: 'Language'),
    TrackTool(name: 'Dart', category: 'Language'),
    TrackTool(name: 'React Native', category: 'Framework'),
    TrackTool(name: 'Firebase', category: 'Backend'),
    TrackTool(name: 'Xcode', category: 'IDE'),
    TrackTool(name: 'Android Studio', category: 'IDE'),
    TrackTool(name: 'Git', category: 'Tool'),
    TrackTool(name: 'Figma', category: 'Design'),
    TrackTool(name: 'SQLite', category: 'Database'),
    TrackTool(name: 'App Store Connect', category: 'Deployment'),
  ],
  salaryRange: '\$55K – \$130K / year',
  dayInTheLife: [
    DayActivity(time: '9:00 AM', activity: 'Check crash reports & user feedback', emoji: '📱'),
    DayActivity(time: '9:30 AM', activity: 'Daily standup with the team', emoji: '🗣️'),
    DayActivity(time: '10:00 AM', activity: 'Build new screens & transitions', emoji: '🎨'),
    DayActivity(time: '12:00 PM', activity: 'Lunch break & app store browsing', emoji: '🍜'),
    DayActivity(time: '1:00 PM', activity: 'Test on multiple devices & screen sizes', emoji: '📲'),
    DayActivity(time: '2:30 PM', activity: 'Optimize app performance & battery', emoji: '🔋'),
    DayActivity(time: '4:00 PM', activity: 'Review pull requests & pair program', emoji: '👥'),
    DayActivity(time: '5:00 PM', activity: 'Prepare build for beta testing', emoji: '🚀'),
  ],
  fittingTraits: [
    'Creative & performance-minded',
    'Visual sensibility for UI',
    'Analytical problem-solving',
    'User-empathy & UX awareness',
    'Patient with device testing',
    'Cross-platform thinker',
  ],
  sampleProjects: [
    SampleProject(
      name: 'Todo App with Animations',
      description: 'A sleek task manager with smooth transitions, local storage, and dark mode.',
      difficulty: 'Beginner',
    ),
    SampleProject(
      name: 'Fitness Tracker',
      description: 'Track workouts with charts, GPS routes, and health kit integration.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'Social Photo App',
      description: 'A photo-sharing app with camera, filters, and a feed with infinite scroll.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'Real-time Messaging App',
      description: 'End-to-end encrypted chat with push notifications and media sharing.',
      difficulty: 'Advanced',
    ),
  ],
  vibeStats: [
    '📱 Billions of Users',
    '🎨 Creative + Technical',
    '📈 Growing Market',
    '🌍 Global Reach',
    '⚡ Fast Iteration Cycles',
    '🏠 Remote-Friendly',
  ],
);

/// Data Science track information.
const TrackInfo dataScienceTrackInfo = TrackInfo(
  name: 'Data Science',
  tagline: 'Turn raw data into powerful insights',
  description:
      'Data scientists extract meaning from complex datasets using statistics, '
      'machine learning, and visualization. You\'ll uncover patterns that drive '
      'business decisions and build predictive models.',
  emoji: '📊',
  tools: [
    TrackTool(name: 'Python', category: 'Language'),
    TrackTool(name: 'R', category: 'Language'),
    TrackTool(name: 'SQL', category: 'Language'),
    TrackTool(name: 'TensorFlow', category: 'ML Framework'),
    TrackTool(name: 'PyTorch', category: 'ML Framework'),
    TrackTool(name: 'Pandas', category: 'Library'),
    TrackTool(name: 'Jupyter', category: 'Tool'),
    TrackTool(name: 'Scikit-learn', category: 'Library'),
    TrackTool(name: 'Matplotlib', category: 'Visualization'),
    TrackTool(name: 'Tableau', category: 'Visualization'),
    TrackTool(name: 'Git', category: 'Tool'),
    TrackTool(name: 'AWS/GCP', category: 'Cloud'),
  ],
  salaryRange: '\$65K – \$150K / year',
  dayInTheLife: [
    DayActivity(time: '9:00 AM', activity: 'Review overnight model training results', emoji: '📊'),
    DayActivity(time: '9:30 AM', activity: 'Standup with data engineering team', emoji: '🗣️'),
    DayActivity(time: '10:00 AM', activity: 'Explore & clean new datasets', emoji: '🧹'),
    DayActivity(time: '12:00 PM', activity: 'Lunch break & read research papers', emoji: '📄'),
    DayActivity(time: '1:00 PM', activity: 'Build & train ML models', emoji: '🤖'),
    DayActivity(time: '2:30 PM', activity: 'Create visualizations for stakeholders', emoji: '📈'),
    DayActivity(time: '4:00 PM', activity: 'Document findings & write reports', emoji: '📝'),
    DayActivity(time: '5:00 PM', activity: 'Plan next experiment & wrap up', emoji: '🔬'),
  ],
  fittingTraits: [
    'Intellectually curious',
    'Strong analytical thinking',
    'Comfortable with statistics',
    'Pattern-recognition skills',
    'Enjoys research & exploration',
    'Systematic & methodical',
  ],
  sampleProjects: [
    SampleProject(
      name: 'Exploratory Data Analysis',
      description: 'Analyze a real-world dataset with Pandas and create compelling visualizations.',
      difficulty: 'Beginner',
    ),
    SampleProject(
      name: 'Sentiment Analysis Model',
      description: 'Build an NLP model to classify customer reviews as positive or negative.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'Recommendation Engine',
      description: 'Create a movie/product recommendation system using collaborative filtering.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'Image Classification with CNN',
      description: 'Train a deep learning model to classify images using TensorFlow or PyTorch.',
      difficulty: 'Advanced',
    ),
  ],
  vibeStats: [
    '📊 Data-Driven Decisions',
    '💰 Highest Salary Track',
    '🤖 AI & Machine Learning',
    '🔬 Research-Oriented',
    '📈 Explosive Growth',
    '🏠 Remote-Friendly',
  ],
);

/// DevOps Engineering track information.
const TrackInfo devOpsTrackInfo = TrackInfo(
  name: 'DevOps Engineering',
  tagline: 'Automate everything, deploy with confidence',
  description:
      'DevOps engineers bridge development and operations, automating '
      'infrastructure, CI/CD pipelines, and monitoring. You\'ll ensure apps '
      'are reliable, scalable, and deployed seamlessly.',
  emoji: '🔧',
  tools: [
    TrackTool(name: 'Docker', category: 'Container'),
    TrackTool(name: 'Kubernetes', category: 'Orchestration'),
    TrackTool(name: 'Terraform', category: 'IaC'),
    TrackTool(name: 'AWS/GCP/Azure', category: 'Cloud'),
    TrackTool(name: 'GitHub Actions', category: 'CI/CD'),
    TrackTool(name: 'Jenkins', category: 'CI/CD'),
    TrackTool(name: 'Linux', category: 'OS'),
    TrackTool(name: 'Bash/Python', category: 'Scripting'),
    TrackTool(name: 'Prometheus', category: 'Monitoring'),
    TrackTool(name: 'Grafana', category: 'Monitoring'),
    TrackTool(name: 'Ansible', category: 'Config Mgmt'),
    TrackTool(name: 'Git', category: 'Tool'),
  ],
  salaryRange: '\$70K – \$150K / year',
  dayInTheLife: [
    DayActivity(time: '9:00 AM', activity: 'Check monitoring dashboards & alerts', emoji: '📊'),
    DayActivity(time: '9:30 AM', activity: 'Standup with dev & ops teams', emoji: '🗣️'),
    DayActivity(time: '10:00 AM', activity: 'Write infrastructure-as-code (Terraform)', emoji: '🏗️'),
    DayActivity(time: '12:00 PM', activity: 'Lunch break & cloud computing blog', emoji: '☁️'),
    DayActivity(time: '1:00 PM', activity: 'Optimize CI/CD pipeline speed', emoji: '🚀'),
    DayActivity(time: '2:30 PM', activity: 'Security patching & compliance checks', emoji: '🔒'),
    DayActivity(time: '4:00 PM', activity: 'Automate deployment workflows', emoji: '🤖'),
    DayActivity(time: '5:00 PM', activity: 'On-call handoff & documentation', emoji: '📝'),
  ],
  fittingTraits: [
    'Systematic & structured thinker',
    'Automation-first mindset',
    'Analytical problem-solver',
    'Enjoys scripting & tooling',
    'Team-oriented collaborator',
    'Calm under production pressure',
  ],
  sampleProjects: [
    SampleProject(
      name: 'Dockerize an App',
      description: 'Containerize a web application with Docker and create a docker-compose setup.',
      difficulty: 'Beginner',
    ),
    SampleProject(
      name: 'CI/CD Pipeline',
      description: 'Build an automated testing and deployment pipeline with GitHub Actions.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'Infrastructure as Code',
      description: 'Provision cloud resources on AWS using Terraform with state management.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'Kubernetes Cluster',
      description: 'Deploy a microservices app to Kubernetes with auto-scaling and monitoring.',
      difficulty: 'Advanced',
    ),
  ],
  vibeStats: [
    '🔧 Automation-First',
    '💰 Premium Salaries',
    '☁️ Cloud-Native',
    '📈 Critical Role',
    '🏠 Remote-Friendly',
    '🤝 Cross-Team Impact',
  ],
);

/// UI/UX Design track information.
const TrackInfo uiUxTrackInfo = TrackInfo(
  name: 'UI/UX Design',
  tagline: 'Design experiences that delight users',
  description:
      'UI/UX designers research user needs, create wireframes, and design '
      'intuitive interfaces. You\'ll blend psychology, aesthetics, and usability '
      'to create products people love to use.',
  emoji: '✏️',
  tools: [
    TrackTool(name: 'Figma', category: 'Design'),
    TrackTool(name: 'Adobe XD', category: 'Design'),
    TrackTool(name: 'Sketch', category: 'Design'),
    TrackTool(name: 'Framer', category: 'Prototyping'),
    TrackTool(name: 'InVision', category: 'Prototyping'),
    TrackTool(name: 'Miro', category: 'Collaboration'),
    TrackTool(name: 'Notion', category: 'Documentation'),
    TrackTool(name: 'Maze', category: 'User Testing'),
    TrackTool(name: 'Hotjar', category: 'Analytics'),
    TrackTool(name: 'HTML/CSS', category: 'Handoff'),
    TrackTool(name: 'After Effects', category: 'Motion'),
    TrackTool(name: 'Zeplin', category: 'Handoff'),
  ],
  salaryRange: '\$45K – \$115K / year',
  dayInTheLife: [
    DayActivity(time: '9:00 AM', activity: 'Review user feedback & analytics', emoji: '📊'),
    DayActivity(time: '9:30 AM', activity: 'Design team sync & critique', emoji: '🗣️'),
    DayActivity(time: '10:00 AM', activity: 'Create wireframes & user flows', emoji: '✏️'),
    DayActivity(time: '12:00 PM', activity: 'Lunch break & Dribbble inspiration', emoji: '🎨'),
    DayActivity(time: '1:00 PM', activity: 'User interview & usability testing', emoji: '👥'),
    DayActivity(time: '2:30 PM', activity: 'High-fidelity mockups in Figma', emoji: '🖥️'),
    DayActivity(time: '4:00 PM', activity: 'Prototype interactions & animations', emoji: '✨'),
    DayActivity(time: '5:00 PM', activity: 'Developer handoff & documentation', emoji: '📝'),
  ],
  fittingTraits: [
    'Strong visual & creative sense',
    'Empathy for users',
    'Collaborative communicator',
    'Detail-oriented perfectionist',
    'Research-minded & curious',
    'Storytelling through design',
  ],
  sampleProjects: [
    SampleProject(
      name: 'App Redesign Case Study',
      description: 'Redesign an existing app with research, wireframes, and a polished Figma prototype.',
      difficulty: 'Beginner',
    ),
    SampleProject(
      name: 'Design System',
      description: 'Create a comprehensive design system with components, tokens, and documentation.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'E-Commerce UX Flow',
      description: 'Design the entire checkout experience with user testing and A/B test proposals.',
      difficulty: 'Intermediate',
    ),
    SampleProject(
      name: 'SaaS Dashboard',
      description: 'Design a complex analytics dashboard with data visualization and user onboarding.',
      difficulty: 'Advanced',
    ),
  ],
  vibeStats: [
    '✏️ 100% Creative & Visual',
    '👥 User-Centered',
    '📈 Growing Demand',
    '🌍 Global Opportunities',
    '🏠 Remote-Friendly',
    '🤝 Design + Psychology',
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
