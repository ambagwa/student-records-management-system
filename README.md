# Student Records Database System

![Database Schema](https://img.shields.io/badge/Database-MySQL-blue)
![Node.js](https://img.shields.io/badge/Node.js-18.x-green)
![Express](https://img.shields.io/badge/Express-5.x-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Overview

A comprehensive MySQL database system for managing student records in an educational institution. This system tracks students, programs, courses, enrollments, grades, payments, and related academic information.

## Features

- **Complete Academic Tracking**: Manage students from enrollment to graduation
- **Multi-department Structure**: Organize programs by academic departments
- **Course Management**: Track courses, sections, and faculty assignments
- **Gradebook System**: Record assignments and calculate final grades
- **Financial Records**: Track student payments and transactions
- **Document Management**: Store and verify student documents

## Database Schema

### Core Tables

| Table | Description | Key Relationships |
|-------|-------------|-------------------|
| `departments` | Academic departments | Parent to programs |
| `programs` | Degree programs | Links departments to students |
| `students` | Student information | Linked to programs and enrollments |
| `courses` | Course catalog | Organized by department |
| `sections` | Course offerings | Links courses to faculty and students |
| `enrollments` | Student course registrations | Connects students to sections |

### Supporting Tables

| Table | Description |
|-------|-------------|
| `student_contacts` | Emergency contact information |
| `faculty` | Instructor records |
| `grades` | Assignment grades |
| `program_courses` | Program requirements |
| `student_payments` | Financial transactions |
| `student_documents` | Academic documents |

# Student Records Management System API

A RESTful API for managing student records, programs, and enrollments built with Node.js, Express, and MySQL.

## Prerequisites

- Node.js 18.x or higher
- MySQL 8.0+ or compatible database
- npm 9.x or yarn
## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/student-records-api.git
   cd student-records-api
   ```

2. Install dependencies
    ```bash
    npm install
    ```

3.Set up database:
    ```bash
    mysql -u root -p < database_schema.sql
    ```

4. Configure environment variables
    ```
    # Database Configuration
    DB_HOST=localhost
    DB_PORT=3306
    DB_USER=your_db_username
    DB_PASSWORD=your_db_password
    DB_NAME=student_records

    # Server Configuration
    PORT=3000
    JWT_SECRET=your_jwt_secret_here
    NODE_ENV=development
    ```

5. Start the server 
    ```bash
    npm run dev
    ```