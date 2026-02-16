<![CDATA[<div align="center">

# 🚀 Forward AI

### AI-Powered Career Intelligence Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)](https://python.org)
[![Gemini AI](https://img.shields.io/badge/Gemini_1.5_Flash-4285F4?logo=google&logoColor=white)](https://ai.google.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Forward AI** analyzes real-time job market data, identifies your skill gaps, and generates a personalized, week-by-week learning roadmap using AI — all in seconds.

---

</div>

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [API Reference](#-api-reference)
- [Design Patterns](#-design-patterns)
- [Screenshots](#-screenshots)
- [Team](#-team)
- [License](#-license)

---

## 🧭 Overview

Forward AI is a data-driven career pathing platform built as a **microservices architecture** for the Egypt Hackathon. It solves a common problem: *"I want to become a [job title] — what skills do I need to learn, and in what order?"*

### How It Works

1. **User Input** — Enter your target job title (e.g., "Flutter Developer") and your existing skills.
2. **Market Analysis** — The Python Data Service fetches real job listings from the [Adzuna API](https://www.adzuna.com/) (Egypt market) and uses **KeyBERT** (BERT-based NLP) to extract the most in-demand skills.
3. **Skill Gap Calculation** — The Node.js backend compares market-required skills against your existing skills to find what's missing.
4. **AI Roadmap Generation** — **Google Gemini 1.5 Flash** generates a personalized, week-by-week learning roadmap with curated resources and links.
5. **Results Display** — The Flutter mobile app presents the analysis with animated visualizations, skill gap breakdowns, and an interactive timeline.

---

## 🏗 Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App (Dart)                        │
│  ┌────────────┐   ┌──────────────┐   ┌────────────┐   ┌──────────┐  │
│  │ HomeScreen  │──▶│AnalysisProvider│──▶│ ApiService │──▶│  Models  │ │
│  │ResultScreen │   │(ChangeNotifier)│   │  (Dio)     │   │          │ │
│  └────────────┘   └──────────────┘   └─────┬──────┘   └──────────┘  │
└──────────────────────────────────────────────┼───────────────────────┘
                                               │ HTTP POST
                                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│             Node.js Orchestration Backend (Express)                   │
│  ┌───────────────────┐   ┌───────────────┐   ┌─────────────────┐    │
│  │ AnalyzeController │──▶│SkillAnalysis  │   │  GeminiService  │    │
│  │  POST /api/analyze│   │   Service      │   │ (Gemini 1.5     │    │
│  └───────────────────┘   └──────┬────────┘   │   Flash)         │    │
│                                  │            └─────────────────┘    │
└──────────────────────────────────┼──────────────────────────────────┘
                                   │ HTTP POST
                                   ▼
┌──────────────────────────────────────────────────────────────────────┐
│              Python Data Service (Flask)                              │
│  ┌──────────────────────┐   ┌─────────────────┐   ┌──────────────┐  │
│  │ /extract-skills      │──▶│SkillExtractor   │──▶│  KeyBERT     │  │
│  │  Blueprint Route     │   │   Service        │   │  NLP Model   │  │
│  └──────────────────────┘   └────────┬────────┘   └──────────────┘  │
│                                       │                              │
│                                       ▼                              │
│                              ┌─────────────────┐                     │
│                              │  Adzuna API     │                     │
│                              │ (Job Listings)  │                     │
│                              └─────────────────┘                     │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🛠 Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Mobile App** | Flutter 3.10+, Dart | Cross-platform UI |
| **State Management** | Provider (ChangeNotifier) | Reactive UI updates |
| **HTTP Client** | Dio | API calls with interceptors & timeouts |
| **UI Animations** | flutter_animate | Micro-animations & transitions |
| **Typography** | Google Fonts (Inter) | Modern, clean typography |
| **Backend Gateway** | Node.js, Express | API orchestration & routing |
| **AI Generation** | Google Gemini 1.5 Flash | Learning roadmap generation |
| **Data Service** | Python, Flask | NLP-based skill extraction |
| **NLP Engine** | KeyBERT (MiniLM-L6-v2) | Keyword extraction from job descriptions |
| **Job Data** | Adzuna API | Real-time job listings (Egypt market) |
| **HTML Parsing** | BeautifulSoup4 | Clean job description text |

---

## 👥 Team Directory Guide

| Team | Directory | Tech | Quick Start |
|------|-----------|------|-------------|
| 🟢 **Backend** | [`backend/`](backend/) | Node.js, Express | `cd backend && npm install && node server.js` |
| 🔵 **Data Analysis** | [`data_analysis/`](data_analysis/) | Python, Flask, KeyBERT | `cd data_analysis && pip install -r requirements.txt && python data_service.py` |
| 🟠 **Frontend** | [`lib/`](lib/) | Flutter, Dart | `flutter pub get && flutter run` |

> Each team directory has its own **README.md** with detailed setup instructions.

---

## 📁 Project Structure

```
egypt_hackathon/
├── backend/                           # 🟢 BACKEND TEAM
│   ├── server.js                      #    Node.js Express orchestration server
│   ├── package.json                   #    Node.js dependencies
│   ├── .env.example                   #    Environment variable template
│   └── README.md                      #    Backend setup guide
│
├── data_analysis/                     # 🔵 DATA ANALYSIS TEAM
│   ├── data_service.py                #    Python Flask NLP microservice
│   ├── requirements.txt               #    Python dependencies
│   └── README.md                      #    Data analysis setup guide
│
├── lib/                               # 🟠 FRONTEND TEAM (Flutter/Dart)
│   ├── main.dart                      #    App entry point & Provider setup
│   ├── config/
│   │   └── theme.dart                 #    Material 3 dark theme & color palette
│   ├── models/
│   │   └── analysis_result.dart       #    Data models (AnalysisResult, RoadmapWeek)
│   ├── providers/
│   │   └── analysis_provider.dart     #    State management (ChangeNotifier)
│   ├── services/
│   │   └── api_service.dart           #    HTTP client (Dio) for backend calls
│   └── screens/
│       ├── home_screen.dart           #    Input screen (job title + skills)
│       └── result_screen.dart         #    Results display (gaps + roadmap)
│
├── test/                              #    Flutter widget tests
├── pubspec.yaml                       #    Flutter project configuration
├── analysis_options.yaml              #    Dart linting rules
└── README.md                          #    This file
```

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version | Installation |
|------|---------|-------------|
| Flutter SDK | 3.10+ | [flutter.dev/get-started](https://docs.flutter.dev/get-started/install) |
| Node.js | 18+ | [nodejs.org](https://nodejs.org/) |
| Python | 3.10+ | [python.org](https://www.python.org/downloads/) |
| Android Studio / Xcode | Latest | For mobile emulators |

### 1. Clone the Repository

```bash
git clone https://github.com/Forward-AI-LAB/egypt_hackathon.git
cd egypt_hackathon
```

### 2. Set Up Environment Variables

Create a `.env` file inside `backend/`:

```bash
cp backend/.env.example backend/.env
```

Fill in your API keys:

```env
# Google Gemini API Key (get one at https://aistudio.google.com/apikey)
GEMINI_API_KEY=your_gemini_api_key_here

# Adzuna API Credentials (get them at https://developer.adzuna.com/)
ADZUNA_APP_ID=your_adzuna_app_id
ADZUNA_APP_KEY=your_adzuna_app_key

# Server Configuration
PORT=3000
PYTHON_SERVICE_URL=http://localhost:5001
```

> **Note:** The app works without Adzuna keys — it falls back to curated mock job data. The Gemini key is recommended but also has a fallback roadmap.

### 3. Start the Python Data Service

```bash
cd data_analysis

# Create a virtual environment (recommended)
python -m venv venv
source venv/bin/activate    # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the service
python data_service.py
```

The Python service starts on `http://localhost:5001`.

### 4. Start the Node.js Backend

```bash
cd backend

# Install dependencies
npm install

# Start the server
node server.js
```

The Node.js backend starts on `http://localhost:3000`.

### 5. Run the Flutter App

```bash
# From the project root directory
flutter pub get
flutter run
```

> **Tip:** For Android Emulator, the API base URL is already set to `10.0.2.2:3000` (which maps to your host machine's localhost). For physical devices, update `_baseUrl` in `lib/services/api_service.dart` to your machine's local IP address.

---

## 📡 API Reference

### Python Data Service (`localhost:5001`)

#### `POST /extract-skills`

Extracts market-required skills from job listings.

**Request:**
```json
{
  "job_title": "Flutter Developer"
}
```

**Response:**
```json
{
  "success": true,
  "job_title": "Flutter Developer",
  "skills": ["Dart", "Flutter SDK", "Firebase", "Bloc", "REST APIs", "Git", ...],
  "count": 10
}
```

#### `GET /health`

Health check endpoint.

---

### Node.js Backend (`localhost:3000`)

#### `POST /api/analyze`

Full career analysis — market skills, gap analysis, and AI roadmap.

**Request:**
```json
{
  "jobTitle": "Flutter Developer",
  "userSkills": ["Dart", "Git", "Firebase"]
}
```

**Response:**
```json
{
  "success": true,
  "job_title": "Flutter Developer",
  "market_skills": ["Dart", "Flutter SDK", "Firebase", "Bloc", "REST APIs", ...],
  "matched_skills": ["Dart", "Firebase"],
  "missing_skills": ["Flutter SDK", "Bloc", "REST APIs", ...],
  "roadmap": [
    {
      "week": 1,
      "topic": "Flutter SDK Fundamentals",
      "description": "Learn the core Flutter framework...",
      "resources": ["Official Flutter docs", "Flutter Codelabs", ...],
      "link": "https://flutter.dev/docs"
    }
  ],
  "metadata": {
    "total_market_skills": 10,
    "total_matched": 2,
    "total_missing": 8,
    "roadmap_weeks": 5,
    "processing_time_ms": 4523
  }
}
```

#### `GET /health`

Health check with service status.

---

## 🎨 Design Patterns

| Pattern | Where | Why |
|---------|-------|-----|
| **Microservices** | Overall architecture | Independent scaling, language-optimal services |
| **Service Layer** | Python & Node.js | Separates business logic from routes |
| **Repository** | `api_service.dart` | Abstracts HTTP details from app logic |
| **ChangeNotifier** | `analysis_provider.dart` | Reactive state management for Flutter |
| **Factory** | `create_app()` in both backends | Testable app creation |
| **Singleton** | KeyBERT model loading | Load NLP model once, reuse across requests |
| **Strategy** | Data fetching fallback | Live API → Mock data seamless switch |
| **Controller** | `AnalyzeController` | Orchestrates service calls in Node.js |
| **Dependency Injection** | Provider & constructors | Testable, loosely coupled components |
| **State Machine** | `AnalysisState` enum | Prevents impossible UI states |

---

## 📱 Screenshots

> *The app features a premium dark theme with gradient backgrounds, animated skill chips, a timeline-based roadmap, and smooth page transitions.*

| Home Screen | Analysis Loading | Results & Roadmap |
|:-----------:|:----------------:|:-----------------:|
| Enter job title & skills | AI-powered processing | Skill gaps + weekly plan |

---

## 👥 Team

**Forward AI Team** — Egypt Hackathon 2026

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

<div align="center">

**Built with ❤️ for the Egypt Hackathon**

*Powered by Google Gemini AI, KeyBERT NLP, and Flutter*

</div>
]]>
