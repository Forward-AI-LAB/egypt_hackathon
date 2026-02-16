# 🟢 Backend Team — Node.js Orchestration Server

This directory contains the **Node.js Express** server that acts as the gateway API between the Flutter app and all backend services.

## Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Copy the environment file and fill in your API keys
cp .env.example .env

# 3. Run the server
node server.js
```

The server starts on **http://localhost:3000** by default.

## Architecture

```
Flutter App  →  Node.js Backend (this)  →  Python Data Service
                     ↓
               Google Gemini AI
```

## Key Files

| File             | Purpose                                     |
| ---------------- | ------------------------------------------- |
| `server.js`      | Main server — routes, services, controllers |
| `package.json`   | Node.js dependencies                        |
| `.env.example`   | Environment variable template               |

## API Endpoints

| Method | Endpoint        | Description                    |
| ------ | --------------- | ------------------------------ |
| POST   | `/api/analyze`  | Main career analysis endpoint  |
| GET    | `/health`       | Health check                   |
