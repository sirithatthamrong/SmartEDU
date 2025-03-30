# SmartEDU

SmartEDU is a modern school check-in and management system built with Ruby on Rails. It supports multiple schools, a
streamlined student/teacher registration process, approval workflows, QR code check-in, and role-based dashboards.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [System Requirements](#system-requirements)
- [Setup Instructions](#setup-instructions)
- [How to Run the Test Suite](#how-to-run-the-test-suite)

---

## Features

- Admin and teacher registration with approval workflow
- Role-based dashboard navigation (Admins, Teachers, Students and Principals)
- Grade and classroom management
- Bulk CSV import for students with validation and rollback on failure
- Manual and QR code-based check-in/out for students
- Attendance tracking with timezone-aware timestamps
- Multi-tenancy support for managing multiple schools
- Admin interface for both school-level and system-level management
- Attendance reports with in/out logs for parents

---

## Tech Stack

- **Ruby version:** 3.3.6
- **Database:** SQLite 3.8.0+ (for development)
- **Frontend:** Tailwind CSS (via `app/assets/builds/tailwind.css`)
- **Deployment:** Kamal
- **Others:** Hotwire (Turbo/Stimulus), Devise (authentication), RSpec (testing)

---

## System Requirements

Make sure the following dependencies are installed:

- Ruby 3.3.6
- Rails 7+
- SQLite 3.8.0+ (or PostgreSQL in production)
- Node.js & Yarn (for JS bundling)
- Kamal (for deployment)
- Git, SSH access (for deployment)

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/sirithatthamrong/SmartEDU.git
cd SmartEDU
```

### 2. Install dependencies

```bash
bundle install
yarn install
```

### 3. Setup database

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed  # Optional: Seed initial data
```

### 4. Start the server

```bash
bin/rails server
```

Visit `http://localhost:3000` in your browser to access the application.

---

## How to Run the Test Suite

### 1. Run the unit tests

```bash
bin/rails test
```

### 2. Run the system tests

```bash
bin/rails test:system
```
