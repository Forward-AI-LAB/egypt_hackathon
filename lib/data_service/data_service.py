"""
==========================================================================
Forward AI — Data Analysis Microservice
==========================================================================
This microservice is responsible for:
  1. Accepting a job title via a POST request.
  2. Fetching real job descriptions from the Adzuna API (country: Egypt).
  3. Extracting the most relevant market skills using KeyBERT (NLP).
  4. Returning a ranked JSON list of in-demand skills.

Architecture & Design Patterns Used:
  - Blueprint Pattern:  Routes are registered via Flask Blueprints for
                        modularity, allowing easy addition of new endpoints.
  - Service Layer:      Business logic is encapsulated in a dedicated
                        SkillExtractorService class, decoupled from routes.
  - Singleton Pattern:  The KeyBERT model is loaded once at startup and
                        reused across requests for peak performance.
  - Strategy Pattern:   Data fetching uses a fallback strategy — if the
                        live Adzuna API fails, mock data is used seamlessly.
  - Factory Pattern:    The Flask app is created via `create_app()` factory
                        function, ready for testing and scaling.

Author:  Forward AI Team
Version: 1.0.0 (Hackathon MVP)
==========================================================================
"""

import os
import logging
from typing import List, Dict, Optional

from flask import Flask, request, jsonify, Blueprint
from flask_cors import CORS

# ---------------------------------------------------------------------------
# Logging Configuration
# ---------------------------------------------------------------------------
# Structured logging helps with debugging in production and monitoring.
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("ForwardAI.DataService")


# ===========================================================================
# Mock Data — Fallback Strategy
# ===========================================================================
# If the Adzuna API is unreachable, rate-limited, or API keys are missing,
# we fall back to curated mock job descriptions. This guarantees the demo
# always works (critical for hackathon presentations).

MOCK_JOB_DESCRIPTIONS: Dict[str, List[str]] = {
    "default": [
        (
            "We are looking for a skilled developer with experience in "
            "Python, JavaScript, React, Node.js, SQL, Docker, Git, REST APIs, "
            "Agile methodologies, and CI/CD pipelines. Strong problem-solving "
            "skills and teamwork required. Experience with cloud platforms "
            "like AWS or Azure is a plus."
        ),
        (
            "The ideal candidate should have proficiency in data structures, "
            "algorithms, system design, microservices architecture, and "
            "database management. Knowledge of TypeScript, GraphQL, Redis, "
            "and Kubernetes is highly desirable."
        ),
    ],
    "flutter developer": [
        (
            "We need a Flutter Developer proficient in Dart, Flutter SDK, "
            "Firebase, Bloc/Cubit state management, REST API integration, "
            "Git version control, and responsive UI design. Experience with "
            "provider pattern, clean architecture, and CI/CD for mobile apps."
        ),
        (
            "Looking for a mobile developer experienced in Flutter, Dart, "
            "Firebase Authentication, Cloud Firestore, Push Notifications, "
            "GetX or Riverpod state management, unit testing, integration "
            "testing, and publishing to Google Play & App Store."
        ),
        (
            "Flutter engineer needed with skills in Dart, Material Design, "
            "Cupertino widgets, platform channels, Hive/SQLite local storage, "
            "Dio HTTP client, WebSocket, Git, and Agile development."
        ),
    ],
    "data scientist": [
        (
            "Seeking a Data Scientist with expertise in Python, Pandas, "
            "NumPy, Scikit-learn, TensorFlow, SQL, data visualization "
            "with Matplotlib and Seaborn, statistical analysis, A/B testing, "
            "and machine learning model deployment."
        ),
        (
            "Data Scientist role requiring knowledge of deep learning, NLP, "
            "PyTorch, feature engineering, data pipelines, Apache Spark, "
            "Jupyter notebooks, Git, and cloud ML services (AWS SageMaker)."
        ),
    ],
    "backend developer": [
        (
            "Backend Developer needed with experience in Node.js, Express, "
            "Python, Django, PostgreSQL, MongoDB, Redis, Docker, Kubernetes, "
            "REST API design, GraphQL, authentication (JWT/OAuth), and "
            "microservices architecture."
        ),
        (
            "We are hiring a backend engineer skilled in Java, Spring Boot, "
            "SQL databases, message queues (RabbitMQ/Kafka), CI/CD, "
            "unit testing, system design, and cloud infrastructure (AWS/GCP)."
        ),
    ],
    "frontend developer": [
        (
            "Frontend Developer with expertise in React.js, TypeScript, "
            "HTML5, CSS3, Tailwind CSS, Next.js, Redux, Webpack, responsive "
            "design, cross-browser compatibility, and accessibility (WCAG)."
        ),
        (
            "Looking for a front-end engineer experienced in Vue.js or React, "
            "JavaScript ES6+, SASS/LESS, component libraries, state management, "
            "RESTful API consumption, Git, and performance optimization."
        ),
    ],
    "devops engineer": [
        (
            "DevOps Engineer with experience in Docker, Kubernetes, Terraform, "
            "CI/CD (Jenkins/GitHub Actions), AWS/GCP/Azure, Linux, Bash "
            "scripting, monitoring (Prometheus/Grafana), and Infrastructure "
            "as Code."
        ),
        (
            "Seeking a site reliability engineer skilled in containerization, "
            "orchestration, networking, security best practices, log "
            "aggregation (ELK stack), and incident response management."
        ),
    ],
}


# ===========================================================================
# Service Layer — SkillExtractorService
# ===========================================================================
# This class encapsulates ALL business logic for skill extraction.
# Routes simply delegate to this service. This separation makes the code:
#   - Testable: You can unit-test the service without spinning up Flask.
#   - Reusable: Other parts of the system can import and use this service.
#   - Scalable: Swap implementations (e.g., different NLP models) easily.

class SkillExtractorService:
    """
    Service responsible for fetching job data and extracting skills.

    The KeyBERT model is loaded once in __init__ (Singleton-style) so that
    subsequent requests reuse the same model — avoiding repeated 2–3 second
    load times.
    """

    def __init__(self):
        """
        Initialize the service and pre-load the KeyBERT model.
        This runs once when the application starts.
        """
        logger.info("🔄 Loading KeyBERT model (this may take a moment)...")
        try:
            from keybert import KeyBERT
            # Using the default 'all-MiniLM-L6-v2' model — small, fast,
            # and effective for keyword extraction tasks.
            self._kw_model = KeyBERT(model="all-MiniLM-L6-v2")
            logger.info("✅ KeyBERT model loaded successfully.")
        except Exception as e:
            logger.error(f"❌ Failed to load KeyBERT model: {e}")
            self._kw_model = None

    # -----------------------------------------------------------------------
    # Public API
    # -----------------------------------------------------------------------

    def extract_skills(self, job_title: str, top_n: int = 10) -> List[str]:
        """
        Main method: Fetches job descriptions and extracts top skills.

        Args:
            job_title: The job title to search for (e.g., "Flutter Developer").
            top_n:     Number of top skills to return (default: 10).

        Returns:
            A list of skill strings ranked by relevance.
        """
        logger.info(f"📊 Starting skill extraction for: '{job_title}'")

        # Step 1: Fetch job descriptions (live API or mock fallback)
        descriptions = self._fetch_job_descriptions(job_title)

        if not descriptions:
            logger.warning("⚠️ No job descriptions found. Returning empty list.")
            return []

        # Step 2: Aggregate all descriptions into one text block
        # This gives KeyBERT more context for better keyword extraction.
        aggregated_text = " ".join(descriptions)
        logger.info(
            f"📝 Aggregated {len(descriptions)} descriptions "
            f"({len(aggregated_text)} characters)."
        )

        # Step 3: Extract keywords using KeyBERT
        skills = self._extract_keywords(aggregated_text, top_n)

        logger.info(f"✅ Extracted {len(skills)} skills: {skills}")
        return skills

    # -----------------------------------------------------------------------
    # Private Methods — Data Fetching
    # -----------------------------------------------------------------------

    def _fetch_job_descriptions(self, job_title: str) -> List[str]:
        """
        Fetches job descriptions from the Adzuna API.
        Falls back to mock data if the API call fails for any reason.

        Strategy Pattern: The fetching strategy (live vs mock) is selected
        at runtime based on environment configuration and API availability.

        Args:
            job_title: The job role to search for.

        Returns:
            A list of job description strings.
        """
        # Check if Adzuna API credentials are available in environment
        adzuna_app_id = os.environ.get("ADZUNA_APP_ID")
        adzuna_app_key = os.environ.get("ADZUNA_APP_KEY")

        # If API keys are not set, go directly to mock data
        if not adzuna_app_id or not adzuna_app_key:
            logger.info(
                "🔑 Adzuna API keys not found in environment. "
                "Using mock data fallback."
            )
            return self._get_mock_descriptions(job_title)

        # Attempt live API call
        try:
            return self._fetch_from_adzuna(
                job_title, adzuna_app_id, adzuna_app_key
            )
        except Exception as e:
            logger.error(f"❌ Adzuna API call failed: {e}")
            logger.info("🔄 Falling back to mock data.")
            return self._get_mock_descriptions(job_title)

    def _fetch_from_adzuna(
        self,
        job_title: str,
        app_id: str,
        app_key: str,
        results_per_page: int = 10,
    ) -> List[str]:
        """
        Makes a live HTTP request to the Adzuna API to fetch job listings.

        Adzuna API docs: https://developer.adzuna.com/overview

        Args:
            job_title:        Search query (e.g., "Flutter Developer").
            app_id:           Adzuna application ID.
            app_key:          Adzuna application key.
            results_per_page: Number of job results to fetch (default: 10).

        Returns:
            A list of cleaned job description strings.
        """
        import requests
        from bs4 import BeautifulSoup

        # Adzuna API endpoint — targeting Egypt (country code: eg)
        url = (
            f"https://api.adzuna.com/v1/api/jobs/eg/search/1"
            f"?app_id={app_id}"
            f"&app_key={app_key}"
            f"&results_per_page={results_per_page}"
            f"&what={job_title}"
            f"&content-type=application/json"
        )

        logger.info(f"🌐 Fetching jobs from Adzuna API for: '{job_title}'")

        # Make the HTTP request with a 10-second timeout to avoid hanging
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # Raises HTTPError for 4xx/5xx responses

        data = response.json()
        results = data.get("results", [])

        if not results:
            logger.warning("⚠️ Adzuna returned 0 results.")
            return self._get_mock_descriptions(job_title)

        logger.info(f"✅ Adzuna returned {len(results)} job listings.")

        # Extract and clean the description field from each result
        descriptions = []
        for job in results:
            raw_description = job.get("description", "")
            if raw_description:
                # Use BeautifulSoup to strip any HTML tags from descriptions
                clean_text = BeautifulSoup(
                    raw_description, "html.parser"
                ).get_text(separator=" ", strip=True)
                descriptions.append(clean_text)

        return descriptions

    def _get_mock_descriptions(self, job_title: str) -> List[str]:
        """
        Returns pre-defined mock job descriptions as a fallback.

        The mock data is keyed by lowercase job title. If the exact title is
        not found, we fall back to the "default" category.

        Args:
            job_title: The job title to look up in the mock database.

        Returns:
            A list of mock job description strings.
        """
        key = job_title.strip().lower()
        descriptions = MOCK_JOB_DESCRIPTIONS.get(
            key, MOCK_JOB_DESCRIPTIONS["default"]
        )
        logger.info(
            f"📦 Using mock data for '{job_title}' "
            f"({len(descriptions)} descriptions)."
        )
        return descriptions

    # -----------------------------------------------------------------------
    # Private Methods — NLP Extraction
    # -----------------------------------------------------------------------

    def _extract_keywords(
        self, text: str, top_n: int = 10
    ) -> List[str]:
        """
        Uses KeyBERT to extract the most relevant keywords/skills from text.

        KeyBERT leverages BERT sentence embeddings to find the sub-phrases
        in a document that are most similar to the document itself, making
        it excellent for extracting domain-specific skills.

        Performance Notes:
          - We use n-gram range (1, 3) to capture multi-word skills
            like "REST API" or "state management".
          - Diversity is set to 0.5 using MMR (Maximal Marginal Relevance)
            to balance relevance with variety in extracted skills.
          - The model is pre-loaded (singleton), so extraction is fast.

        Args:
            text:  The aggregated job descriptions text.
            top_n: Number of top keywords to extract.

        Returns:
            A list of skill/keyword strings.
        """
        # If the model failed to load, return an empty list
        if self._kw_model is None:
            logger.error("❌ KeyBERT model is not available. Cannot extract.")
            return []

        try:
            # extract_keywords returns a list of (keyword, score) tuples
            keywords_with_scores = self._kw_model.extract_keywords(
                text,
                keyphrase_ngram_range=(1, 3),  # Unigrams to trigrams
                stop_words="english",           # Remove common English words
                top_n=top_n,                    # Number of results
                use_mmr=True,                   # Enable diversity algorithm
                diversity=0.5,                  # Balance relevance & variety
            )

            # Extract just the keyword strings (discard scores)
            skills = [kw for kw, score in keywords_with_scores]

            return skills

        except Exception as e:
            logger.error(f"❌ Keyword extraction failed: {e}")
            return []


# ===========================================================================
# Flask Blueprint — API Routes
# ===========================================================================
# Using Blueprints allows us to modularize routes. In a larger system,
# each feature area would have its own Blueprint (e.g., auth_bp, skills_bp).

skills_bp = Blueprint("skills", __name__)

# The service is initialized once and reused (Singleton via module scope).
# This ensures the KeyBERT model is only loaded one time.
skill_service: Optional[SkillExtractorService] = None


def get_skill_service() -> SkillExtractorService:
    """
    Lazy singleton accessor for the SkillExtractorService.
    Ensures the model is loaded once, even across multiple requests.
    """
    global skill_service
    if skill_service is None:
        skill_service = SkillExtractorService()
    return skill_service


@skills_bp.route("/extract-skills", methods=["POST"])
def extract_skills_route():
    """
    POST /extract-skills
    --------------------
    Accepts a JSON body with a 'job_title' field and returns extracted skills.

    Request Body:
        {
            "job_title": "Flutter Developer"
        }

    Response (200):
        {
            "success": true,
            "job_title": "Flutter Developer",
            "skills": ["Dart", "Flutter", "Firebase", "Bloc", "Git", ...],
            "count": 10
        }

    Error Response (400):
        {
            "success": false,
            "error": "Missing 'job_title' in request body."
        }
    """
    # --- Input Validation ---
    # Ensure the request has a JSON content type
    if not request.is_json:
        logger.warning("⚠️ Request is not JSON.")
        return jsonify({
            "success": False,
            "error": "Request must be JSON. Set Content-Type: application/json."
        }), 400

    data = request.get_json()
    job_title = data.get("job_title", "").strip()

    # Validate that job_title is provided and not empty
    if not job_title:
        logger.warning("⚠️ Missing 'job_title' in request body.")
        return jsonify({
            "success": False,
            "error": "Missing 'job_title' in request body."
        }), 400

    # --- Business Logic (delegated to Service Layer) ---
    service = get_skill_service()
    skills = service.extract_skills(job_title)

    # --- Response ---
    return jsonify({
        "success": True,
        "job_title": job_title,
        "skills": skills,
        "count": len(skills),
    }), 200


@skills_bp.route("/health", methods=["GET"])
def health_check():
    """
    GET /health
    -----------
    Health check endpoint for monitoring and load balancer probes.

    Returns:
        { "status": "healthy", "service": "Forward AI Data Service" }
    """
    return jsonify({
        "status": "healthy",
        "service": "Forward AI Data Service",
        "version": "1.0.0",
    }), 200


# ===========================================================================
# Application Factory — create_app()
# ===========================================================================
# The Factory Pattern allows us to create multiple app instances (e.g.,
# one for testing, one for production) with different configurations.

def create_app() -> Flask:
    """
    Application factory function.

    Creates and configures the Flask application with:
      - CORS enabled (for cross-origin requests from Node.js backend)
      - Skills blueprint registered
      - JSON configuration for readable responses

    Returns:
        Configured Flask application instance.
    """
    app = Flask(__name__)

    # --- CORS Configuration ---
    # Allow all origins for development. In production, restrict this
    # to specific domains (e.g., the Node.js backend URL).
    CORS(app, resources={r"/*": {"origins": "*"}})

    # --- JSON Configuration ---
    # Disable ASCII-only encoding so Unicode characters display properly
    app.config["JSON_AS_ASCII"] = False
    # Pretty-print JSON responses for easier debugging
    app.config["JSONIFY_PRETTYPRINT_REGULAR"] = True

    # --- Register Blueprints ---
    app.register_blueprint(skills_bp)

    # --- Startup Log ---
    logger.info("🚀 Forward AI Data Service initialized successfully.")

    return app


# ===========================================================================
# Entry Point
# ===========================================================================
# In development, run with Flask's built-in server.
# In production, use Gunicorn: gunicorn -w 4 -b 0.0.0.0:5001 data_service:app

if __name__ == "__main__":
    # Create the application using the factory
    app = create_app()

    # Pre-load the KeyBERT model at startup (not on first request)
    # This ensures the first API call is fast.
    with app.app_context():
        get_skill_service()

    # Run the Flask development server
    # - host 0.0.0.0: accessible from other machines/containers
    # - port 5001: avoid conflict with other services
    # - debug False: disable auto-reloader in production-like runs
    app.run(
        host="0.0.0.0",
        port=5001,
        debug=True,  # Set to False in production
    )

# For Gunicorn / production WSGI entry point
app = create_app()
