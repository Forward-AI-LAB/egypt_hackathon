# 🔵 Data Analysis Team — Python Skill Extraction Service

This directory contains the **Flask** microservice responsible for fetching job data and extracting in-demand skills using **KeyBERT** (NLP).

## Quick Start

```bash
# 1. Create a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run the service
python data_service.py
```

The service starts on **http://localhost:5001** by default.

## Architecture

```
Node.js Backend  →  Python Data Service (this)  →  Adzuna API (live jobs)
                              ↓
                     KeyBERT NLP Model
```

## Key Files

| File                | Purpose                                |
| ------------------- | -------------------------------------- |
| `data_service.py`   | Flask app — routes, service, NLP logic |
| `requirements.txt`  | Python dependencies                    |

## API Endpoints

| Method | Endpoint          | Description                          |
| ------ | ----------------- | ------------------------------------ |
| POST   | `/extract-skills` | Extract market skills for a job title|
| GET    | `/health`         | Health check                         |
