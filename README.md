# Student Records Database System

![Database Schema](https://img.shields.io/badge/Database-MySQL-blue)
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
