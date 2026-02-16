/**
 * ===========================================================================
 * Forward AI — Orchestration Backend (Gateway API)
 * ===========================================================================
 *
 * This is the central orchestration server that acts as the Gateway API
 * between the Flutter mobile app and all backend services.
 *
 * Responsibilities:
 *   1. Accept user input (job title + existing skills) from the mobile app.
 *   2. Call the Python Data Analysis Service to fetch market-required skills.
 *   3. Calculate the skill gap (market skills minus user's existing skills).
 *   4. Send a structured prompt to Google Gemini 1.5 Flash to generate
 *      a personalized learning roadmap in strict JSON format.
 *   5. Return the combined analysis (market skills, gaps, roadmap) to the app.
 *
 * Architecture & Design Patterns:
 *   - Service Layer Pattern:   Business logic separated into dedicated service
 *                              classes (SkillAnalysisService, GeminiService).
 *   - Controller Pattern:      Express routes delegate to controllers that
 *                              orchestrate service calls.
 *   - Error Handling Middleware: Centralized error handling for clean responses.
 *   - Configuration Module:    All environment variables accessed through a
 *                              single config object for easy management.
 *   - Dependency Injection:    Services are instantiated once and injected
 *                              where needed, enabling testability.
 *
 * Author:  Forward AI Team
 * Version: 1.0.0 (Hackathon MVP)
 * ===========================================================================
 */

// ---------------------------------------------------------------------------
// 1. IMPORTS & ENVIRONMENT SETUP
// ---------------------------------------------------------------------------

// Load environment variables from .env file BEFORE any other imports
// that might depend on them. This must be the very first thing we do.
require("dotenv").config();

const express = require("express");
const cors = require("cors");
const axios = require("axios");
const { GoogleGenerativeAI } = require("@google/generative-ai");

// ---------------------------------------------------------------------------
// 2. CONFIGURATION MODULE
// ---------------------------------------------------------------------------
// Centralizing all configuration in one place makes it easy to manage
// environment-specific settings and provides clear documentation of
// what each setting controls.

const config = {
    /** Port the server will listen on */
    port: process.env.PORT || 3000,

    /** URL of the Python Data Analysis microservice */
    pythonServiceUrl: process.env.PYTHON_SERVICE_URL || "http://localhost:5001",

    /** Google Gemini API key for AI roadmap generation */
    geminiApiKey: process.env.GEMINI_API_KEY || "",

    /** Adzuna API credentials (passed to Python service via env) */
    adzunaAppId: process.env.ADZUNA_APP_ID || "",
    adzunaAppKey: process.env.ADZUNA_APP_KEY || "",
};

// ---------------------------------------------------------------------------
// 3. SERVICE LAYER — SkillAnalysisService
// ---------------------------------------------------------------------------
// This service handles communication with the Python microservice
// and the skill gap calculation logic.

class SkillAnalysisService {
    /**
     * Creates a new SkillAnalysisService instance.
     *
     * @param {string} pythonServiceUrl - Base URL of the Python data service.
     */
    constructor(pythonServiceUrl) {
        this.pythonServiceUrl = pythonServiceUrl;
    }

    /**
     * Fetches market-required skills from the Python Data Analysis Service.
     *
     * Makes a POST request to the Python /extract-skills endpoint with the
     * provided job title. The Python service handles Adzuna API calls and
     * KeyBERT extraction internally.
     *
     * @param {string} jobTitle - The job title to analyze (e.g., "Flutter Developer").
     * @returns {Promise<string[]>} Array of market skill strings.
     * @throws {Error} If the Python service is unreachable or returns an error.
     */
    async getMarketSkills(jobTitle) {
        console.log(
            `📊 [SkillAnalysisService] Fetching market skills for: "${jobTitle}"`
        );

        try {
            // Call the Python service with a generous timeout (KeyBERT may be slow)
            const response = await axios.post(
                `${this.pythonServiceUrl}/extract-skills`,
                { job_title: jobTitle },
                {
                    headers: { "Content-Type": "application/json" },
                    timeout: 30000, // 30 second timeout for NLP processing
                }
            );

            const skills = response.data.skills || [];
            console.log(
                `✅ [SkillAnalysisService] Received ${skills.length} market skills.`
            );
            return skills;
        } catch (error) {
            // Log the specific error for debugging
            const errorMsg =
                error.response?.data?.error || error.message || "Unknown error";
            console.error(
                `❌ [SkillAnalysisService] Python service error: ${errorMsg}`
            );
            throw new Error(`Failed to fetch market skills: ${errorMsg}`);
        }
    }

    /**
     * Calculates the skill gap between market requirements and user skills.
     *
     * The comparison is case-insensitive and trims whitespace to avoid
     * false mismatches (e.g., "Git" should match "git" and " Git ").
     *
     * @param {string[]} marketSkills - Skills required by the market.
     * @param {string[]} userSkills   - Skills the user already has.
     * @returns {{ matchedSkills: string[], missingSkills: string[] }}
     *          Object containing matched and missing skill arrays.
     */
    calculateSkillGap(marketSkills, userSkills) {
        console.log(`🔍 [SkillAnalysisService] Calculating skill gap...`);
        console.log(`   Market requires: [${marketSkills.join(", ")}]`);
        console.log(`   User has:        [${userSkills.join(", ")}]`);

        // Normalize user skills to lowercase for case-insensitive comparison
        const normalizedUserSkills = new Set(
            userSkills.map((skill) => skill.trim().toLowerCase())
        );

        // Separate market skills into matched (user has) and missing (user lacks)
        const matchedSkills = [];
        const missingSkills = [];

        for (const skill of marketSkills) {
            if (normalizedUserSkills.has(skill.trim().toLowerCase())) {
                matchedSkills.push(skill);
            } else {
                missingSkills.push(skill);
            }
        }

        console.log(`   ✅ Matched: [${matchedSkills.join(", ")}]`);
        console.log(`   ❌ Missing: [${missingSkills.join(", ")}]`);

        return { matchedSkills, missingSkills };
    }
}

// ---------------------------------------------------------------------------
// 4. SERVICE LAYER — GeminiService
// ---------------------------------------------------------------------------
// This service encapsulates all interaction with Google Gemini AI.
// It constructs prompts, calls the API, and parses the JSON response.

class GeminiService {
    /**
     * Creates a new GeminiService instance.
     *
     * @param {string} apiKey - Google Gemini API key.
     */
    constructor(apiKey) {
        if (!apiKey) {
            console.warn(
                "⚠️ [GeminiService] No API key provided. AI roadmap generation will fail."
            );
            this.model = null;
            return;
        }

        // Initialize the Gemini SDK with the provided API key
        const genAI = new GoogleGenerativeAI(apiKey);

        // Using Gemini 1.5 Flash — optimized for speed while maintaining quality.
        // Perfect for hackathon demos where response time matters.
        this.model = genAI.getGenerativeModel({
            model: "gemini-1.5-flash",
            // Configure generation parameters for consistent JSON output
            generationConfig: {
                temperature: 0.7, // Balanced creativity vs consistency
                topP: 0.9, // Nucleus sampling for natural language
                topK: 40, // Top-K sampling for diversity
                maxOutputTokens: 4096, // Allow detailed roadmaps
            },
        });

        console.log("✅ [GeminiService] Gemini 1.5 Flash model initialized.");
    }

    /**
     * Generates a personalized learning roadmap using Gemini AI.
     *
     * The prompt is carefully engineered to:
     *   1. Provide context about the user's goal and current skills.
     *   2. Highlight the specific skills they need to learn.
     *   3. Request a strictly structured JSON response (no markdown).
     *   4. Include actionable resources with real links.
     *
     * @param {string}   jobTitle      - Target job title (e.g., "Flutter Developer").
     * @param {string[]} missingSkills - Skills the user needs to learn.
     * @param {string[]} userSkills    - Skills the user already has (for context).
     * @returns {Promise<Object[]>} Array of roadmap week objects.
     * @throws {Error} If Gemini API call fails or response parsing fails.
     */
    async generateRoadmap(jobTitle, missingSkills, userSkills) {
        console.log(
            `🤖 [GeminiService] Generating roadmap for: "${jobTitle}"`
        );
        console.log(
            `   Missing skills to cover: [${missingSkills.join(", ")}]`
        );

        // If no model is available (missing API key), return a helpful fallback
        if (!this.model) {
            console.warn(
                "⚠️ [GeminiService] Model not available. Returning fallback roadmap."
            );
            return this._getFallbackRoadmap(missingSkills);
        }

        // If there are no missing skills, congratulate the user
        if (missingSkills.length === 0) {
            return [
                {
                    week: 1,
                    topic: "Advanced Practice & Portfolio Building",
                    description:
                        "You already have all the required skills! Focus on building impressive portfolio projects.",
                    resources: [
                        "Build a full-stack project showcasing your skills",
                        "Contribute to open-source projects in your field",
                    ],
                    link: "https://github.com/explore",
                },
            ];
        }

        // -----------------------------------------------------------------------
        // Prompt Engineering
        // -----------------------------------------------------------------------
        // The prompt is structured to force Gemini to return ONLY valid JSON.
        // We explicitly tell it: NO markdown, NO explanations, JUST JSON.
        const prompt = `You are an expert career coach and technical educator.

A user wants to become a "${jobTitle}".
They currently know: [${userSkills.join(", ")}].
The market analysis shows they are missing these skills: [${missingSkills.join(", ")}].

Create a structured, week-by-week learning roadmap to help them acquire the missing skills.

CRITICAL INSTRUCTIONS:
1. Respond with ONLY a valid JSON array. No markdown, no code fences, no explanations.
2. Each element in the array must be an object with these exact fields:
   - "week" (number): The week number (starting from 1)
   - "topic" (string): The main skill or topic to learn that week
   - "description" (string): A 2-3 sentence explanation of what to learn and why
   - "resources" (string array): 2-3 specific, actionable learning resources
   - "link" (string): A real, working URL to the best free resource for this topic

3. Cover ALL missing skills across the weeks (aim for 4-6 weeks total).
4. Order topics logically (prerequisites first).
5. Include practical project suggestions in the resources.
6. Only output the JSON array, nothing else.

Generate the roadmap now:`;

        try {
            // Call Gemini API
            const result = await this.model.generateContent(prompt);
            const response = await result.response;
            const text = response.text();

            console.log(
                `📝 [GeminiService] Raw Gemini response (${text.length} chars).`
            );

            // Parse the JSON response from Gemini
            const roadmap = this._parseGeminiResponse(text);

            console.log(
                `✅ [GeminiService] Successfully parsed ${roadmap.length} week(s) in roadmap.`
            );
            return roadmap;
        } catch (error) {
            console.error(`❌ [GeminiService] Gemini API error: ${error.message}`);
            // Fallback to a basic roadmap if Gemini fails
            return this._getFallbackRoadmap(missingSkills);
        }
    }

    /**
     * Parses the raw text response from Gemini into a JSON object.
     *
     * Gemini sometimes wraps its JSON response in markdown code fences
     * (```json ... ```) despite being told not to. This method handles
     * multiple edge cases:
     *   1. Clean JSON array → parse directly
     *   2. Wrapped in ```json ... ``` → strip fences, then parse
     *   3. Wrapped in ``` ... ``` → strip fences, then parse
     *   4. Contains extra text before/after JSON → extract JSON substring
     *
     * @param {string} text - Raw text response from Gemini.
     * @returns {Object[]} Parsed JSON array.
     * @throws {Error} If JSON cannot be extracted from the response.
     * @private
     */
    _parseGeminiResponse(text) {
        // Attempt 1: Try parsing the raw text directly
        try {
            const parsed = JSON.parse(text);
            if (Array.isArray(parsed)) return parsed;
            // If it's an object with a roadmap key, extract it
            if (parsed.roadmap && Array.isArray(parsed.roadmap))
                return parsed.roadmap;
        } catch (e) {
            // Not valid JSON, continue to cleanup attempts
        }

        // Attempt 2: Strip markdown code fences if present
        let cleaned = text
            .replace(/```json\s*/gi, "") // Remove ```json
            .replace(/```\s*/g, "") // Remove closing ```
            .trim();

        try {
            const parsed = JSON.parse(cleaned);
            if (Array.isArray(parsed)) return parsed;
            if (parsed.roadmap && Array.isArray(parsed.roadmap))
                return parsed.roadmap;
        } catch (e) {
            // Still not valid JSON, continue
        }

        // Attempt 3: Extract JSON array substring using bracket matching
        const firstBracket = text.indexOf("[");
        const lastBracket = text.lastIndexOf("]");

        if (firstBracket !== -1 && lastBracket !== -1 && lastBracket > firstBracket) {
            const jsonSubstring = text.substring(firstBracket, lastBracket + 1);
            try {
                const parsed = JSON.parse(jsonSubstring);
                if (Array.isArray(parsed)) return parsed;
            } catch (e) {
                // Final attempt failed
            }
        }

        // All parsing attempts failed — throw an error
        console.error(
            "❌ [GeminiService] Could not parse Gemini response as JSON."
        );
        console.error(`   Raw text: ${text.substring(0, 200)}...`);
        throw new Error("Failed to parse Gemini AI response as valid JSON.");
    }

    /**
     * Returns a fallback roadmap when Gemini API is unavailable.
     *
     * This ensures the app always returns useful data, even without AI.
     * Critical for hackathon demos where API keys might expire or
     * rate limits might be hit.
     *
     * @param {string[]} missingSkills - Skills to create a basic roadmap for.
     * @returns {Object[]} Basic roadmap array.
     * @private
     */
    _getFallbackRoadmap(missingSkills) {
        console.log(
            "📦 [GeminiService] Generating fallback roadmap (no AI)."
        );

        return missingSkills.map((skill, index) => ({
            week: index + 1,
            topic: skill,
            description: `Focus on learning ${skill} through online tutorials, documentation, and hands-on practice. Build a small project to solidify your understanding.`,
            resources: [
                `Search "${skill} tutorial for beginners" on YouTube`,
                `Read the official ${skill} documentation`,
                `Build a mini-project using ${skill}`,
            ],
            link: `https://www.google.com/search?q=${encodeURIComponent(skill + " tutorial")}`,
        }));
    }
}

// ---------------------------------------------------------------------------
// 5. SERVICE LAYER — PersonalityService
// ---------------------------------------------------------------------------
// This service uses Gemini AI to analyze personality quiz answers and
// recommend the best-fit software development track.

class PersonalityService {
    /**
     * Available software development tracks.
     * Each track has traits that map to it, used for both AI prompting
     * and local fallback scoring.
     */
    static TRACKS = [
        {
            name: "Frontend Development",
            emoji: "🎨",
            traits: ["visual", "creative", "detail"],
            description: "Building beautiful, interactive user interfaces",
        },
        {
            name: "Backend Development",
            emoji: "⚙️",
            traits: ["analytical", "detail", "systematic"],
            description: "Designing robust server-side systems and APIs",
        },
        {
            name: "Mobile Development",
            emoji: "📱",
            traits: ["creative", "visual", "analytical"],
            description: "Creating native and cross-platform mobile apps",
        },
        {
            name: "Data Science",
            emoji: "📊",
            traits: ["analytical", "systematic", "curious"],
            description: "Extracting insights from data using ML and statistics",
        },
        {
            name: "DevOps Engineering",
            emoji: "🔧",
            traits: ["systematic", "analytical", "collaborative"],
            description: "Automating infrastructure and deployment pipelines",
        },
        {
            name: "UI/UX Design",
            emoji: "✏️",
            traits: ["visual", "creative", "collaborative"],
            description: "Designing user-centered digital experiences",
        },
    ];

    /**
     * Creates a new PersonalityService.
     * @param {GeminiService} geminiService - The Gemini service for AI calls.
     */
    constructor(geminiService) {
        this.geminiService = geminiService;
    }

    /**
     * Analyzes quiz answers using Gemini AI prompt engineering to
     * recommend the best software development track.
     *
     * @param {Object[]} answers - Array of { question, chosenAnswer, trait } objects.
     * @param {Object}   traitScores - Map of trait name → accumulated score.
     * @returns {Promise<Object>} Track recommendation with match %, description, strengths.
     */
    async analyzePersonality(answers, traitScores) {
        console.log(`\n🧠 [PersonalityService] Analyzing personality...`);
        console.log(`   Answers: ${answers.length}`);
        console.log(`   Trait scores: ${JSON.stringify(traitScores)}`);

        // Try AI-powered analysis first
        if (this.geminiService.model) {
            try {
                return await this._analyzeWithGemini(answers, traitScores);
            } catch (error) {
                console.error(
                    `❌ [PersonalityService] Gemini analysis failed: ${error.message}`
                );
                console.log(`📦 [PersonalityService] Falling back to local scoring.`);
            }
        }

        // Fallback: local trait-based scoring
        return this._analyzeLocally(traitScores);
    }

    /**
     * Uses Gemini AI with a carefully engineered prompt to recommend a track.
     * @private
     */
    async _analyzeWithGemini(answers, traitScores) {
        const trackDescriptions = PersonalityService.TRACKS.map(
            (t) => `- ${t.name} (${t.emoji}): ${t.description}. Key traits: ${t.traits.join(", ")}`
        ).join("\n");

        const answersFormatted = answers
            .map((a, i) => `Q${i + 1}: "${a.question}" → Answer: "${a.chosenAnswer}" (trait: ${a.trait})`)
            .join("\n");

        const traitSummary = Object.entries(traitScores)
            .sort(([, a], [, b]) => b - a)
            .map(([trait, score]) => `${trait}: ${score}`)
            .join(", ");

        // -----------------------------------------------------------------------
        // Prompt Engineering — Track Recommendation
        // -----------------------------------------------------------------------
        const prompt = `You are an expert career counselor specializing in software development careers.

A user completed a personality quiz to discover which software development track suits them best.

Here are the available tracks:
${trackDescriptions}

Here are the user's quiz answers:
${answersFormatted}

Accumulated trait scores: ${traitSummary}

Based on the user's answers and personality traits, determine the BEST matching software development track.

CRITICAL INSTRUCTIONS:
1. Respond with ONLY a valid JSON object. No markdown, no code fences, no explanations.
2. The JSON must have these exact fields:
   - "trackName" (string): Must be exactly one of: "Frontend Development", "Backend Development", "Mobile Development", "Data Science", "DevOps Engineering", "UI/UX Design"
   - "emoji" (string): The emoji for the chosen track
   - "matchPercentage" (number): A percentage between 65 and 97 indicating how well the user fits this track
   - "description" (string): A 2-3 sentence personalized explanation of WHY this track is perfect for this specific user, referencing their actual answers and traits
   - "strengths" (string array): Exactly 3 specific strengths this user has that align with the recommended track, based on their quiz answers
3. Be thoughtful and analytical. Don't just pick the track with the highest trait overlap — consider the COMBINATION and PATTERN of answers.
4. The description should feel personal and specific to THIS user's answers, not generic.
5. Only output the JSON object, nothing else.

Analyze and respond now:`;

        const result = await this.geminiService.model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();

        console.log(
            `📝 [PersonalityService] Raw Gemini response (${text.length} chars).`
        );

        // Parse the response (reuse Gemini parsing logic for robustness)
        const parsed = this._parseResponse(text);

        // Validate the response has required fields
        if (!parsed.trackName || !parsed.matchPercentage || !parsed.strengths) {
            throw new Error("Gemini response missing required fields.");
        }

        // Validate trackName is one of the known tracks
        const validTrackNames = PersonalityService.TRACKS.map((t) => t.name);
        if (!validTrackNames.includes(parsed.trackName)) {
            console.warn(
                `⚠️ [PersonalityService] Unknown track "${parsed.trackName}", correcting...`
            );
            // Find the closest match
            const closest = validTrackNames.find((n) =>
                n.toLowerCase().includes(parsed.trackName.toLowerCase().split(" ")[0])
            );
            if (closest) {
                parsed.trackName = closest;
                parsed.emoji = PersonalityService.TRACKS.find((t) => t.name === closest).emoji;
            }
        }

        console.log(`✅ [PersonalityService] AI recommends: ${parsed.trackName} (${parsed.matchPercentage}%)`);
        return parsed;
    }

    /**
     * Parses Gemini's text response into a JSON object.
     * Handles markdown fences and other edge cases.
     * @private
     */
    _parseResponse(text) {
        // Attempt 1: Direct parse
        try {
            return JSON.parse(text);
        } catch (e) { /* continue */ }

        // Attempt 2: Strip markdown fences
        let cleaned = text
            .replace(/```json\s*/gi, "")
            .replace(/```\s*/g, "")
            .trim();
        try {
            return JSON.parse(cleaned);
        } catch (e) { /* continue */ }

        // Attempt 3: Extract JSON object substring
        const firstBrace = text.indexOf("{");
        const lastBrace = text.lastIndexOf("}");
        if (firstBrace !== -1 && lastBrace !== -1 && lastBrace > firstBrace) {
            try {
                return JSON.parse(text.substring(firstBrace, lastBrace + 1));
            } catch (e) { /* continue */ }
        }

        throw new Error("Failed to parse Gemini personality response as JSON.");
    }

    /**
     * Local fallback: scores each track based on trait overlap.
     * Used when Gemini is unavailable.
     * @private
     */
    _analyzeLocally(traitScores) {
        console.log(`📦 [PersonalityService] Using local trait-based scoring.`);

        let bestTrack = PersonalityService.TRACKS[0];
        let bestScore = 0;

        for (const track of PersonalityService.TRACKS) {
            let score = 0;
            for (const trait of track.traits) {
                score += traitScores[trait] || 0;
            }
            if (score > bestScore) {
                bestScore = score;
                bestTrack = track;
            }
        }

        // Calculate match percentage from score
        const totalAnswers = Object.values(traitScores).reduce((a, b) => a + b, 0);
        const matchPct = totalAnswers > 0
            ? Math.min(97, Math.max(65, Math.round((bestScore / totalAnswers) * 100)))
            : 75;

        // Build strengths from top traits
        const sortedTraits = Object.entries(traitScores)
            .sort(([, a], [, b]) => b - a)
            .slice(0, 3);

        const strengthsMap = {
            visual: "Strong visual & aesthetic sense",
            creative: "Creative problem-solving & innovation",
            analytical: "Logical thinking & optimization",
            collaborative: "Team collaboration & communication",
            detail: "Attention to detail & quality",
            systematic: "Systematic & structured approach",
            curious: "Intellectual curiosity & exploration",
        };

        const strengths = sortedTraits.map(
            ([trait]) => strengthsMap[trait] || trait
        );

        const result = {
            trackName: bestTrack.name,
            emoji: bestTrack.emoji,
            matchPercentage: matchPct,
            description:
                `Your personality aligns well with ${bestTrack.name}! ` +
                `Your strengths in ${sortedTraits.map(([t]) => t).join(", ")} ` +
                `are exactly what makes a great ${bestTrack.name.toLowerCase()} professional.`,
            strengths: strengths,
        };

        console.log(`✅ [PersonalityService] Local result: ${result.trackName} (${result.matchPercentage}%)`);
        return result;
    }
}

// ---------------------------------------------------------------------------
// 6. CONTROLLER — AnalyzeController
// ---------------------------------------------------------------------------
// The Controller orchestrates the flow between services.
// It is the single point of coordination for the /api/analyze endpoint.

class AnalyzeController {
    /**
     * Creates a new AnalyzeController.
     *
     * @param {SkillAnalysisService} skillService  - Service for skill extraction & gap analysis.
     * @param {GeminiService}        geminiService - Service for AI roadmap generation.
     */
    constructor(skillService, geminiService) {
        this.skillService = skillService;
        this.geminiService = geminiService;

        // Bind `this` context for Express route handler
        // Without this, `this` would refer to the Express router, not the controller
        this.analyze = this.analyze.bind(this);
    }

    /**
     * POST /api/analyze — Main analysis endpoint.
     *
     * Orchestration Flow:
     *   1. Validate input (jobTitle, userSkills)
     *   2. Call Python service for market skills
     *   3. Calculate skill gap
     *   4. Generate AI roadmap for missing skills
     *   5. Return combined response
     *
     * @param {import('express').Request}  req - Express request object.
     * @param {import('express').Response} res - Express response object.
     * @param {import('express').NextFunction} next - Express next middleware.
     */
    async analyze(req, res, next) {
        try {
            const startTime = Date.now(); // Track request duration for performance

            // --- Step 1: Input Validation ---
            const { jobTitle, userSkills } = req.body;

            // Validate jobTitle is present and is a non-empty string
            if (!jobTitle || typeof jobTitle !== "string" || !jobTitle.trim()) {
                return res.status(400).json({
                    success: false,
                    error:
                        'Missing or invalid "jobTitle". Must be a non-empty string.',
                    example: {
                        jobTitle: "Flutter Developer",
                        userSkills: ["Dart", "Git"],
                    },
                });
            }

            // Validate userSkills is present and is an array
            if (!userSkills || !Array.isArray(userSkills)) {
                return res.status(400).json({
                    success: false,
                    error:
                        'Missing or invalid "userSkills". Must be an array of strings.',
                    example: {
                        jobTitle: "Flutter Developer",
                        userSkills: ["Dart", "Git"],
                    },
                });
            }

            console.log(`\n${"=".repeat(60)}`);
            console.log(`🚀 [AnalyzeController] New analysis request`);
            console.log(`   Job Title:   "${jobTitle.trim()}"`);
            console.log(`   User Skills: [${userSkills.join(", ")}]`);
            console.log(`${"=".repeat(60)}\n`);

            // --- Step 2: Fetch Market Skills from Python Service ---
            const marketSkills = await this.skillService.getMarketSkills(
                jobTitle.trim()
            );

            // --- Step 3: Calculate Skill Gap ---
            const { matchedSkills, missingSkills } =
                this.skillService.calculateSkillGap(marketSkills, userSkills);

            // --- Step 4: Generate AI Roadmap for Missing Skills ---
            const roadmap = await this.geminiService.generateRoadmap(
                jobTitle.trim(),
                missingSkills,
                userSkills
            );

            // --- Step 5: Build and Return Final Response ---
            const duration = Date.now() - startTime;
            console.log(
                `\n✅ [AnalyzeController] Analysis complete in ${duration}ms.\n`
            );

            return res.status(200).json({
                success: true,
                job_title: jobTitle.trim(),
                market_skills: marketSkills,
                matched_skills: matchedSkills,
                missing_skills: missingSkills,
                roadmap: roadmap,
                metadata: {
                    total_market_skills: marketSkills.length,
                    total_matched: matchedSkills.length,
                    total_missing: missingSkills.length,
                    roadmap_weeks: roadmap.length,
                    processing_time_ms: duration,
                },
            });
        } catch (error) {
            // Pass error to the centralized error handler middleware
            next(error);
        }
    }
}

// ---------------------------------------------------------------------------
// 7. CONTROLLER — PersonalityController
// ---------------------------------------------------------------------------
// Handles the personality quiz evaluation endpoint.

class PersonalityController {
    /**
     * @param {PersonalityService} personalityService - Service for AI personality analysis.
     */
    constructor(personalityService) {
        this.personalityService = personalityService;
        this.evaluate = this.evaluate.bind(this);
    }

    /**
     * POST /api/personality — Personality quiz evaluation endpoint.
     *
     * Request Body:
     *   {
     *     "answers": [
     *       { "question": "...", "chosenAnswer": "...", "trait": "visual" },
     *       ...
     *     ],
     *     "traitScores": { "visual": 3, "analytical": 2, ... }
     *   }
     *
     * Response:
     *   {
     *     "success": true,
     *     "trackName": "Frontend Development",
     *     "emoji": "🎨",
     *     "matchPercentage": 89,
     *     "description": "...",
     *     "strengths": ["...", "...", "..."]
     *   }
     */
    async evaluate(req, res, next) {
        try {
            const startTime = Date.now();

            const { answers, traitScores } = req.body;

            // Validate answers
            if (!answers || !Array.isArray(answers) || answers.length === 0) {
                return res.status(400).json({
                    success: false,
                    error: 'Missing or invalid "answers". Must be a non-empty array.',
                    example: {
                        answers: [
                            { question: "What catches your eye?", chosenAnswer: "The visual design", trait: "visual" },
                        ],
                        traitScores: { visual: 3, analytical: 2 },
                    },
                });
            }

            // Validate traitScores
            if (!traitScores || typeof traitScores !== "object") {
                return res.status(400).json({
                    success: false,
                    error: 'Missing or invalid "traitScores". Must be an object.',
                });
            }

            console.log(`\n${"=".repeat(60)}`);
            console.log(`🧠 [PersonalityController] New personality evaluation`);
            console.log(`   Answers: ${answers.length}`);
            console.log(`   Traits: ${JSON.stringify(traitScores)}`);
            console.log(`${"=".repeat(60)}\n`);

            const result = await this.personalityService.analyzePersonality(
                answers,
                traitScores
            );

            const duration = Date.now() - startTime;
            console.log(
                `\n✅ [PersonalityController] Evaluation complete in ${duration}ms.\n`
            );

            return res.status(200).json({
                success: true,
                ...result,
                metadata: {
                    processing_time_ms: duration,
                    ai_powered: !!this.personalityService.geminiService.model,
                },
            });
        } catch (error) {
            next(error);
        }
    }
}

// ---------------------------------------------------------------------------
// 8. MIDDLEWARE — Error Handler
// ---------------------------------------------------------------------------
// Centralized error handling ensures consistent error responses across
// all endpoints. This is a best practice for production Express apps.

/**
 * Express error-handling middleware.
 *
 * Catches all errors thrown or passed via next(error) in route handlers.
 * Returns a clean, consistent JSON error response.
 *
 * @param {Error} err                          - The error that was thrown.
 * @param {import('express').Request}  req     - Express request.
 * @param {import('express').Response} res     - Express response.
 * @param {import('express').NextFunction} next - Express next.
 */
function errorHandler(err, req, res, next) {
    console.error(`\n❌ [ErrorHandler] ${err.message}`);
    console.error(`   Stack: ${err.stack?.split("\n")[1]?.trim() || "N/A"}\n`);

    // Determine appropriate status code
    const statusCode = err.statusCode || 500;

    res.status(statusCode).json({
        success: false,
        error: err.message || "Internal server error",
        // Only include stack trace in development
        ...(process.env.NODE_ENV !== "production" && { stack: err.stack }),
    });
}

/**
 * Request logging middleware.
 *
 * Logs every incoming HTTP request with method, URL, and timestamp.
 * Essential for debugging and monitoring.
 *
 * @param {import('express').Request}  req  - Express request.
 * @param {import('express').Response} res  - Express response.
 * @param {import('express').NextFunction} next - Express next.
 */
function requestLogger(req, res, next) {
    const timestamp = new Date().toISOString();
    console.log(`📨 [${timestamp}] ${req.method} ${req.url}`);
    next();
}

// ---------------------------------------------------------------------------
// 9. APPLICATION FACTORY — createApp()
// ---------------------------------------------------------------------------
// Factory pattern: Creates and configures the Express app.
// This makes the app testable (you can create isolated instances for testing)
// and follows the same pattern as the Python service.

/**
 * Creates and configures the Express application.
 *
 * Wires up:
 *   - CORS for cross-origin requests (mobile app → backend)
 *   - JSON body parsing with size limits
 *   - Request logging middleware
 *   - Health check endpoint
 *   - Main /api/analyze endpoint
 *   - Centralized error handling
 *
 * @returns {import('express').Application} Configured Express app.
 */
function createApp() {
    const app = express();

    // --- CORS Configuration ---
    // Allow requests from any origin during development.
    // In production, restrict this to your app's domain.
    app.use(
        cors({
            origin: "*", // Allow all origins (restrict in production)
            methods: ["GET", "POST"], // Only allow needed HTTP methods
            allowedHeaders: ["Content-Type", "Authorization"],
        })
    );

    // --- Body Parsing ---
    // Parse incoming JSON request bodies.
    // Limit size to 10MB to prevent abuse.
    app.use(express.json({ limit: "10mb" }));

    // --- Request Logging ---
    app.use(requestLogger);

    // --- Initialize Services (Dependency Injection) ---
    // Services are created once and shared across all requests.
    const skillService = new SkillAnalysisService(config.pythonServiceUrl);
    const geminiService = new GeminiService(config.geminiApiKey);
    const analyzeController = new AnalyzeController(skillService, geminiService);
    const personalityService = new PersonalityService(geminiService);
    const personalityController = new PersonalityController(personalityService);

    // --- Routes ---

    /**
     * GET /health — Health check endpoint.
     * Used by load balancers, Docker health checks, and monitoring tools.
     */
    app.get("/health", (req, res) => {
        res.status(200).json({
            status: "healthy",
            service: "Forward AI Orchestration Backend",
            version: "1.0.0",
            timestamp: new Date().toISOString(),
            services: {
                python_data_service: config.pythonServiceUrl,
                gemini_ai: config.geminiApiKey ? "configured" : "not configured",
            },
        });
    });

    /**
     * POST /api/analyze — Main career analysis endpoint.
     *
     * Request Body:
     *   {
     *     "jobTitle": "Flutter Developer",
     *     "userSkills": ["Dart", "Git"]
     *   }
     *
     * Response:
     *   {
     *     "success": true,
     *     "market_skills": [...],
     *     "matched_skills": [...],
     *     "missing_skills": [...],
     *     "roadmap": [ { week, topic, description, resources, link }, ... ],
     *     "metadata": { ... }
     *   }
     */
    app.post("/api/analyze", analyzeController.analyze);

    /**
     * POST /api/personality — Personality quiz evaluation endpoint.
     *
     * Request Body:
     *   {
     *     "answers": [
     *       { "question": "...", "chosenAnswer": "...", "trait": "visual" }
     *     ],
     *     "traitScores": { "visual": 3, "analytical": 2 }
     *   }
     *
     * Response:
     *   {
     *     "success": true,
     *     "trackName": "Frontend Development",
     *     "matchPercentage": 89,
     *     "description": "...",
     *     "strengths": ["...", ...]
     *   }
     */
    app.post("/api/personality", personalityController.evaluate);

    // --- Error Handling (must be registered LAST) ---
    app.use(errorHandler);

    return app;
}

// ---------------------------------------------------------------------------
// 10. SERVER STARTUP
// ---------------------------------------------------------------------------

const app = createApp();

app.listen(config.port, () => {
    console.log(`\n${"=".repeat(60)}`);
    console.log(`🚀 Forward AI Backend is running!`);
    console.log(`${"=".repeat(60)}`);
    console.log(`   🌐 Server:          http://localhost:${config.port}`);
    console.log(`   🐍 Python Service:  ${config.pythonServiceUrl}`);
    console.log(
        `   🤖 Gemini AI:       ${config.geminiApiKey ? "✅ Configured" : "❌ Not configured"}`
    );
    console.log(`   📊 Health Check:    http://localhost:${config.port}/health`);
    console.log(`   🔗 Analyze API:     POST http://localhost:${config.port}/api/analyze`);
    console.log(`   🧠 Personality API: POST http://localhost:${config.port}/api/personality`);
    console.log(`${"=".repeat(60)}\n`);
});

// ---------------------------------------------------------------------------
// 11. GRACEFUL SHUTDOWN
// ---------------------------------------------------------------------------
// Handle process termination signals to clean up resources.
// This is important for containerized deployments (Docker/Kubernetes).

process.on("SIGTERM", () => {
    console.log("🛑 SIGTERM received. Shutting down gracefully...");
    process.exit(0);
});

process.on("SIGINT", () => {
    console.log("🛑 SIGINT received. Shutting down gracefully...");
    process.exit(0);
});

// Export for testing purposes
module.exports = { createApp };
