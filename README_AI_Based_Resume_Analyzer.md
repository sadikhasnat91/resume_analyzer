# AI-Based Resume Analyzer

An AI-powered resume analysis application designed to help students, fresh graduates, and job seekers review their resumes and identify areas for improvement.

The application uses a Flutter mobile interface, Supabase services with PostgreSQL for data storage, and Google Gemini for AI-assisted resume feedback.

> **Project status:** Update the implementation details and screenshots below to match the current state of your repository before submission. The ATS-oriented score and recommendations are advisory; they are not an official ATS result or a guarantee of shortlisting.

## Table of Contents

- [Project Overview](#project-overview)
- [Problem Statement](#problem-statement)
- [Objectives](#objectives)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [System Architecture](#system-architecture)
- [How It Works](#how-it-works)
- [Database Design](#database-design)
- [Prerequisites](#prerequisites)
- [Setup and Installation](#setup-and-installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Testing Checklist](#testing-checklist)
- [Security and Privacy](#security-and-privacy)
- [Known Limitations](#known-limitations)
- [Future Improvements](#future-improvements)
- [Team Members](#team-members)
- [License](#license)

## Project Overview

Many applicants find it difficult to determine whether their resumes clearly communicate their skills and experience. This project aims to make resume review more accessible by providing AI-assisted feedback in a beginner-friendly application.

Users can submit a resume for analysis and review the generated score, strengths, weaknesses, and suggestions, depending on the features implemented in the current build.

## Problem Statement

Students and job seekers—especially fresh graduates—may have limited access to professional resume reviews. They may not know which skills are missing, which sections need improvement, or how to make a resume more relevant to a target role. Manual review can also take time, while some existing tools have limited free functionality or complicated interfaces.

## Objectives

- Provide an accessible mobile interface for resume analysis.
- Extract and review relevant resume information where supported by the implementation.
- Generate an ATS-oriented score or assessment where implemented.
- Identify strengths and possible weaknesses in a resume.
- Provide practical, AI-generated improvement suggestions.
- Help users understand how their resume could be improved for a target role.

## Key Features

The following describes the intended feature set. Keep only features that are implemented and working in the submitted version.

- **User authentication:** Account registration and login through Supabase Auth, if enabled in the current build.
- **Resume submission:** Upload or select a resume for analysis, according to the supported file formats.
- **AI-assisted feedback:** Use Google Gemini to generate resume-related feedback.
- **Score and review:** Display an ATS-oriented score or assessment if implemented.
- **Strengths and weaknesses:** Summarize positive points and areas that may need improvement.
- **Improvement suggestions:** Offer actionable recommendations based on the resume.
- **Analysis history:** Store and display previous analyses if the history feature is implemented.

## Technology Stack

| Component | Technology | Purpose |
|---|---|---|
| Mobile application | Flutter / Dart | User interface and client-side application |
| Backend services | Supabase | Authentication and database access, as configured |
| Database | PostgreSQL through Supabase | Store application records |
| AI service | Google Gemini API | AI-assisted resume feedback |
| API/data access | Supabase client and/or configured service endpoints | Communicate with backend services |

**Important:** This project may use Supabase client/SDK operations instead of a separate custom REST server. Document custom endpoints only if they exist in the repository.

## System Architecture

```text
+---------------------------+
|       User / Applicant    |
+-------------+-------------+
              |
              v
+---------------------------+
|     Flutter Mobile App    |
|  Screens, forms, results  |
+-------------+-------------+
              |
              v
+---------------------------+
|   Supabase Services       |
| Auth and database access  |
+-------------+-------------+
              |
              v
+---------------------------+
| PostgreSQL Database       |
| User and analysis records |
+---------------------------+

Flutter / configured backend service
              |
              v
+---------------------------+
| Google Gemini API         |
| AI-generated feedback     |
+---------------------------+
```

The exact request flow depends on the current implementation. For production, calls requiring a secret Gemini API key should be made through a trusted server-side function or backend service rather than exposing the secret in the mobile application.

## How It Works

1. The user opens the application and signs in or registers, if authentication is enabled.
2. The user selects or uploads a resume using the supported input method.
3. The application processes the resume according to its implemented extraction workflow.
4. The configured AI integration generates resume-related feedback.
5. The application displays the returned assessment and recommendations.
6. If analysis history is implemented, the application saves and displays the result for later review.

The steps above describe the intended workflow. Confirm each step against the code before presenting it as a completed feature.

## Database Design

The following is a **logical outline**, not a guarantee of the exact live schema. Update table and column names to match the SQL migrations or Supabase database.

### `users`

| Field | Purpose |
|---|---|
| `id` | User identifier; commonly associated with the Supabase Auth user ID |
| `email` | User email address |
| `full_name` | User's display name, if collected |
| `created_at` | Record creation time |

### `resumes`

| Field | Purpose |
|---|---|
| `id` | Resume record identifier |
| `user_id` | Owner of the resume |
| `file_name` | Original or displayed file name |
| `file_path` | Storage path or reference, if stored |
| `category` | Resume category, if supported |
| `seniority` | Experience level, if supported |
| `uploaded_at` | Upload or record creation time |

### `analyses`

| Field | Purpose |
|---|---|
| `id` | Analysis record identifier |
| `resume_id` | Resume associated with the analysis |
| `user_id` | User associated with the analysis |
| `ats_score` | Score or assessment, if implemented |
| `strengths` | Positive points returned by the analysis |
| `weaknesses` | Areas for improvement |
| `suggestions` | Recommended changes |
| `created_at` | Analysis creation time |

**Schema note:** Use the actual schema from your Supabase project for the final submission. Do not create or document columns that the application does not use.

## Prerequisites

Install the following before running the project:

- Flutter SDK compatible with the project's `pubspec.yaml`
- Dart SDK included with the compatible Flutter SDK
- Android Studio, VS Code, or another Flutter-supported IDE
- An Android emulator or a connected device
- Access to the configured Supabase project
- A Google Gemini API configuration, if AI analysis is enabled

Verify the required SDK version in `pubspec.yaml` and the Flutter environment before installing dependencies.

## Setup and Installation

### 1. Clone the repository

Replace `<repository-url>` with the actual Git repository URL.

```bash
git clone <repository-url>
cd <repository-folder>
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure the application

Set the Supabase URL, Supabase public/anonymous client key, and any other required configuration using the method already supported by the project. For example, if the app uses Dart compile-time environment variables, pass them through the existing `--dart-define` configuration.

Do not commit real secrets or private keys to the repository. See [Configuration](#configuration).

### 4. Check the Flutter environment

```bash
flutter doctor
```

Resolve any environment issues reported by Flutter before launching the application.

## Configuration

Configuration names vary by implementation. Check the project's configuration service and startup code for the exact variable names.

If the project uses Dart compile-time variables, the command may follow this pattern:

```bash
flutter run \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

This is an example pattern, **not a guarantee that these exact variable names match your code**. Use the names expected by the repository. Never put a Supabase service-role key or a private Gemini API key in a client application.

If Gemini is called directly by the mobile app in the current prototype, treat that as a development limitation and move secret-key usage to a trusted server-side component before production release.

## Running the Application

After configuration, run:

```bash
flutter run
```

To list available devices:

```bash
flutter devices
```

For a release build, use the Flutter build command appropriate to the target platform and verify the release configuration first.

## Testing Checklist

Record actual outcomes before submission. Do not mark a test as passed unless it has been performed.

| Test area | What to verify | Result |
|---|---|---|
| App launch | App opens without a startup error | Not recorded |
| Registration | Valid input creates an account, if enabled | Not recorded |
| Login | Valid credentials sign in; invalid credentials are rejected | Not recorded |
| Resume input | Supported files or input are accepted; unsupported input is handled | Not recorded |
| AI analysis | Analysis returns a useful response or a clear error | Not recorded |
| Results screen | Score and feedback are displayed correctly, if implemented | Not recorded |
| History | Previous results load for the correct user, if implemented | Not recorded |
| Access control | A user cannot read another user's private records | Not recorded |
| Network failure | The app handles unavailable services gracefully | Not recorded |

Replace “Not recorded” with the actual result and add evidence or screenshots where required by the course.

## Security and Privacy

- Enable appropriate Row Level Security (RLS) policies for tables containing user data.
- Restrict database reads and writes so users can access only records they are authorized to use.
- Never expose a Supabase service-role key or private AI API key in Flutter source code or a public repository.
- Avoid committing `.env` files, credentials, access tokens, or real user resumes.
- Collect only the resume data required by the application and explain how uploaded data is handled.
- Validate inputs and handle API errors without displaying private credentials or sensitive server details.
- Before public release, review data retention, file storage permissions, and applicable privacy requirements.

## Known Limitations

The actual limitations depend on the current build. Review and edit this list before submission.

- AI-generated feedback can be inaccurate or incomplete and should be reviewed by the user.
- An ATS-oriented score is an estimate, not a score issued by a specific employer or recruitment platform.
- Results depend on resume text quality, the extraction method, and the AI service response.
- Job-specific matching should not be claimed unless the app actually accepts and uses a job description or target role.
- Availability of analysis history, file storage, and supported file formats depends on the implemented features.

## Future Improvements

- Add job-description matching and role-specific feedback.
- Improve resume text extraction and file-format validation.
- Add clearer progress, retry, and error states during analysis.
- Improve the analysis-history interface and export options.
- Add automated tests for authentication, data access, and analysis workflows.
- Improve accessibility, responsive layouts, and usability.
- Move sensitive AI requests to a secure server-side function if not already implemented.

## Team Members

**Course:** CSE 4104 — Software Development III  
**Section:** 7B  
**Team:** CSE4104-7B-T02

| Name | Student ID | Role |
|---|---:|---|
| Sadik Hasnat | 11220321020 | Team Leader |
| Shahed Ahmed | 11220320129 | Team Member |
| Mohesena Zarin | 11220321035 | Team Member |
| Soumik Mondol | 11220321111 | Team Member |

Verify student IDs and roles before submitting.

## License

No license has been specified in this README. Add a license file only after the project team has chosen an appropriate license.
