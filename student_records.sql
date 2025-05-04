-- Create the database
CREATE DATABASE IF NOT EXISTS student_records;
USE student_records;

CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    department_code VARCHAR(10) NOT NULL UNIQUE,
    building VARCHAR(50) NOT NULL,
    office_number VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE programs (
    program_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    program_name VARCHAR(100) NOT NULL,
    program_code VARCHAR(10) NOT NULL UNIQUE,
    degree_level ENUM('Certificate', 'Associate', 'Bachelor', 'Master', 'Doctorate') NOT NULL,
    total_credits_required INT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_program_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE RESTRICT
);

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other', 'Prefer not to say') NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    country VARCHAR(50),
    enrollment_date DATE NOT NULL,
    graduation_date DATE,
    status ENUM('Active', 'Inactive', 'Graduated', 'Suspended', 'Withdrawn') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_student_program FOREIGN KEY (program_id) 
        REFERENCES programs(program_id) ON DELETE RESTRICT,
    CONSTRAINT chk_dates CHECK (graduation_date IS NULL OR graduation_date > enrollment_date)
);

CREATE TABLE student_contacts (
    contact_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL UNIQUE,
    emergency_contact_name VARCHAR(100) NOT NULL,
    emergency_contact_phone VARCHAR(20) NOT NULL,
    emergency_contact_relation VARCHAR(50) NOT NULL,
    parent_guardian_name VARCHAR(100),
    parent_guardian_phone VARCHAR(20),
    parent_guardian_email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_contact_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE TABLE faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    office_number VARCHAR(20),
    position VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,
    status ENUM('Active', 'Inactive', 'On Leave', 'Retired') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_faculty_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE RESTRICT
);

CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(100) NOT NULL,
    description TEXT,
    credits INT NOT NULL,
    prerequisites TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_course_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE RESTRICT,
    CONSTRAINT chk_credits CHECK (credits > 0 AND credits <= 6)
);

CREATE TABLE sections (
    section_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    faculty_id INT NOT NULL,
    semester ENUM('Fall', 'Spring', 'Summer', 'Winter') NOT NULL,
    year INT NOT NULL,
    section_number VARCHAR(10) NOT NULL,
    classroom VARCHAR(20),
    schedule VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    max_capacity INT NOT NULL,
    current_enrollment INT NOT NULL DEFAULT 0,
    status ENUM('Open', 'Closed', 'Cancelled') NOT NULL DEFAULT 'Open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_section_course FOREIGN KEY (course_id) 
        REFERENCES courses(course_id) ON DELETE RESTRICT,
    CONSTRAINT fk_section_faculty FOREIGN KEY (faculty_id) 
        REFERENCES faculty(faculty_id) ON DELETE RESTRICT,
    CONSTRAINT chk_section_dates CHECK (end_date > start_date),
    CONSTRAINT chk_enrollment CHECK (current_enrollment <= max_capacity),
    CONSTRAINT unq_section UNIQUE (course_id, semester, year, section_number)
);

CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    section_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    grade DECIMAL(4,2),
    status ENUM('Registered', 'Dropped', 'Withdrawn', 'Completed') NOT NULL DEFAULT 'Registered',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_enrollment_section FOREIGN KEY (section_id) 
        REFERENCES sections(section_id) ON DELETE RESTRICT,
    CONSTRAINT chk_grade CHECK (grade IS NULL OR (grade >= 0 AND grade <= 100)),
    CONSTRAINT unq_student_section UNIQUE (student_id, section_id)
);

CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    assignment_name VARCHAR(100) NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    max_score DECIMAL(5,2) NOT NULL,
    weight DECIMAL(5,2) NOT NULL,
    due_date DATE NOT NULL,
    submitted_date DATE,
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_grade_enrollment FOREIGN KEY (enrollment_id) 
        REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    CONSTRAINT chk_score CHECK (score >= 0 AND score <= max_score),
    CONSTRAINT chk_weight CHECK (weight > 0 AND weight <= 100)
);

CREATE TABLE program_courses (
    program_course_id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT NOT NULL,
    course_id INT NOT NULL,
    is_core BOOLEAN NOT NULL DEFAULT TRUE,
    recommended_semester INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_programcourse_program FOREIGN KEY (program_id) 
        REFERENCES programs(program_id) ON DELETE CASCADE,
    CONSTRAINT fk_programcourse_course FOREIGN KEY (course_id) 
        REFERENCES courses(course_id) ON DELETE CASCADE,
    CONSTRAINT unq_program_course UNIQUE (program_id, course_id)
);

CREATE TABLE student_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method ENUM('Credit Card', 'Debit Card', 'Bank Transfer', 'Check', 'Cash') NOT NULL,
    transaction_id VARCHAR(100),
    semester ENUM('Fall', 'Spring', 'Summer', 'Winter') NOT NULL,
    year INT NOT NULL,
    purpose VARCHAR(100) NOT NULL,
    status ENUM('Pending', 'Completed', 'Failed', 'Refunded') NOT NULL DEFAULT 'Completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT chk_amount CHECK (amount > 0)
);

CREATE TABLE student_documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    document_type ENUM('Transcript', 'ID', 'Application', 'Recommendation', 'Other') NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    upload_date DATE NOT NULL,
    description TEXT,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    verified_by INT,
    verified_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_document_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_document_verifier FOREIGN KEY (verified_by) 
        REFERENCES faculty(faculty_id) ON DELETE SET NULL
);

show tables;

-- 1. Insert into departments
INSERT INTO departments (department_name, department_code, building, office_number, phone, email)
VALUES 
('Computer Science', 'CS', 'Science Building', 'SB-201', '555-1001', 'cs@university.edu'),
('Mathematics', 'MATH', 'Science Building', 'SB-102', '555-1002', 'math@university.edu'),
('Physics', 'PHY', 'Science Building', 'SB-301', '555-1003', 'physics@university.edu'),
('English', 'ENG', 'Humanities Building', 'HB-101', '555-1004', 'english@university.edu'),
('History', 'HIST', 'Humanities Building', 'HB-202', '555-1005', 'history@university.edu'),
('Biology', 'BIO', 'Science Building', 'SB-401', '555-1006', 'biology@university.edu'),
('Chemistry', 'CHEM', 'Science Building', 'SB-302', '555-1007', 'chemistry@university.edu'),
('Psychology', 'PSY', 'Social Sciences Building', 'SSB-101', '555-1008', 'psychology@university.edu'),
('Economics', 'ECON', 'Social Sciences Building', 'SSB-201', '555-1009', 'economics@university.edu'),
('Business Administration', 'BUS', 'Business Building', 'BB-101', '555-1010', 'business@university.edu');

-- 2. Insert into programs
INSERT INTO programs (department_id, program_name, program_code, degree_level, total_credits_required, description)
VALUES
(1, 'Computer Science BS', 'CS-BS', 'Bachelor', 120, 'Bachelor of Science in Computer Science'),
(1, 'Computer Science MS', 'CS-MS', 'Master', 36, 'Master of Science in Computer Science'),
(2, 'Mathematics BS', 'MATH-BS', 'Bachelor', 120, 'Bachelor of Science in Mathematics'),
(3, 'Physics BS', 'PHY-BS', 'Bachelor', 120, 'Bachelor of Science in Physics'),
(4, 'English BA', 'ENG-BA', 'Bachelor', 120, 'Bachelor of Arts in English'),
(5, 'History BA', 'HIST-BA', 'Bachelor', 120, 'Bachelor of Arts in History'),
(6, 'Biology BS', 'BIO-BS', 'Bachelor', 120, 'Bachelor of Science in Biology'),
(7, 'Chemistry BS', 'CHEM-BS', 'Bachelor', 120, 'Bachelor of Science in Chemistry'),
(8, 'Psychology BA', 'PSY-BA', 'Bachelor', 120, 'Bachelor of Arts in Psychology'),
(10, 'Business Administration BBA', 'BUS-BBA', 'Bachelor', 120, 'Bachelor of Business Administration');

-- 3. Insert into students
INSERT INTO students (program_id, first_name, last_name, date_of_birth, gender, email, phone, address, city, state, zip_code, country, enrollment_date, graduation_date, status)
VALUES
(1, 'John', 'Smith', '2000-05-15', 'Male', 'john.smith@student.edu', '555-2001', '123 Main St', 'Anytown', 'CA', '90210', 'USA', '2019-08-20', '2023-05-15', 'Graduated'),
(1, 'Emily', 'Johnson', '2001-07-22', 'Female', 'emily.johnson@student.edu', '555-2002', '456 Oak Ave', 'Anytown', 'CA', '90210', 'USA', '2020-08-18', NULL, 'Active'),
(3, 'Michael', 'Williams', '1999-11-30', 'Male', 'michael.williams@student.edu', '555-2003', '789 Pine Rd', 'Othertown', 'CA', '90211', 'USA', '2018-08-20', '2022-05-15', 'Graduated'),
(5, 'Sarah', 'Brown', '2000-03-10', 'Female', 'sarah.brown@student.edu', '555-2004', '321 Elm St', 'Anytown', 'CA', '90210', 'USA', '2019-08-20', NULL, 'Active'),
(7, 'David', 'Jones', '2001-09-05', 'Male', 'david.jones@student.edu', '555-2005', '654 Maple Dr', 'Othertown', 'CA', '90211', 'USA', '2020-08-18', NULL, 'Active'),
(2, 'Jessica', 'Garcia', '1998-12-25', 'Female', 'jessica.garcia@student.edu', '555-2006', '987 Cedar Ln', 'Anytown', 'CA', '90210', 'USA', '2018-08-20', '2022-05-15', 'Graduated'),
(4, 'Daniel', 'Miller', '2000-02-14', 'Male', 'daniel.miller@student.edu', '555-2007', '135 Birch Blvd', 'Othertown', 'CA', '90211', 'USA', '2019-08-20', NULL, 'Active'),
(6, 'Olivia', 'Davis', '2001-06-18', 'Female', 'olivia.davis@student.edu', '555-2008', '246 Walnut Way', 'Anytown', 'CA', '90210', 'USA', '2020-08-18', NULL, 'Active'),
(8, 'Matthew', 'Rodriguez', '1999-04-30', 'Male', 'matthew.rodriguez@student.edu', '555-2009', '369 Spruce St', 'Othertown', 'CA', '90211', 'USA', '2018-08-20', '2022-05-15', 'Graduated'),
(10, 'Sophia', 'Martinez', '2000-08-12', 'Female', 'sophia.martinez@student.edu', '555-2010', '482 Redwood Rd', 'Anytown', 'CA', '90210', 'USA', '2019-08-20', NULL, 'Active');

-- 4. Insert into student_contacts
INSERT INTO student_contacts (student_id, emergency_contact_name, emergency_contact_phone, emergency_contact_relation, parent_guardian_name, parent_guardian_phone, parent_guardian_email)
VALUES
(1, 'Robert Smith', '555-3001', 'Father', 'Robert & Mary Smith', '555-3001', 'smith.family@email.com'),
(2, 'Susan Johnson', '555-3002', 'Mother', 'Susan Johnson', '555-3002', 'susan.johnson@email.com'),
(3, 'James Williams', '555-3003', 'Father', 'James & Lisa Williams', '555-3003', 'williams.family@email.com'),
(4, 'Patricia Brown', '555-3004', 'Mother', 'Patricia Brown', '555-3004', 'patricia.brown@email.com'),
(5, 'Thomas Jones', '555-3005', 'Father', 'Thomas & Karen Jones', '555-3005', 'jones.family@email.com'),
(6, 'Nancy Garcia', '555-3006', 'Mother', 'Nancy Garcia', '555-3006', 'nancy.garcia@email.com'),
(7, 'Charles Miller', '555-3007', 'Father', 'Charles & Elizabeth Miller', '555-3007', 'miller.family@email.com'),
(8, 'Karen Davis', '555-3008', 'Mother', 'Karen Davis', '555-3008', 'karen.davis@email.com'),
(9, 'Joseph Rodriguez', '555-3009', 'Father', 'Joseph & Maria Rodriguez', '555-3009', 'rodriguez.family@email.com'),
(10, 'Lisa Martinez', '555-3010', 'Mother', 'Lisa Martinez', '555-3010', 'lisa.martinez@email.com');

-- 5. Insert into faculty
INSERT INTO faculty (department_id, first_name, last_name, email, phone, office_number, position, hire_date, status)
VALUES
(1, 'Robert', 'Wilson', 'robert.wilson@faculty.edu', '555-4001', 'SB-201A', 'Professor', '2010-08-15', 'Active'),
(1, 'Jennifer', 'Taylor', 'jennifer.taylor@faculty.edu', '555-4002', 'SB-201B', 'Associate Professor', '2015-01-10', 'Active'),
(2, 'Thomas', 'Anderson', 'thomas.anderson@faculty.edu', '555-4003', 'SB-102A', 'Professor', '2008-08-20', 'Active'),
(3, 'Elizabeth', 'Thomas', 'elizabeth.thomas@faculty.edu', '555-4004', 'SB-301A', 'Professor', '2012-03-15', 'Active'),
(4, 'Richard', 'Jackson', 'richard.jackson@faculty.edu', '555-4005', 'HB-101A', 'Associate Professor', '2016-08-15', 'Active'),
(5, 'Susan', 'White', 'susan.white@faculty.edu', '555-4006', 'HB-202A', 'Professor', '2005-01-10', 'Active'),
(6, 'Joseph', 'Harris', 'joseph.harris@faculty.edu', '555-4007', 'SB-401A', 'Professor', '2011-08-20', 'Active'),
(7, 'Margaret', 'Martin', 'margaret.martin@faculty.edu', '555-4008', 'SB-302A', 'Associate Professor', '2017-03-15', 'Active'),
(8, 'Daniel', 'Thompson', 'daniel.thompson@faculty.edu', '555-4009', 'SSB-101A', 'Professor', '2009-08-15', 'Active'),
(10, 'Patricia', 'Garcia', 'patricia.garcia@faculty.edu', '555-4010', 'BB-101A', 'Professor', '2014-01-10', 'Active');

-- 6. Insert into courses
INSERT INTO courses (department_id, course_code, course_name, description, credits, prerequisites, is_active)
VALUES
(1, 'CS101', 'Introduction to Computer Science', 'Fundamentals of computer science and programming', 4, NULL, TRUE),
(1, 'CS201', 'Data Structures', 'Study of fundamental data structures and algorithms', 4, 'CS101', TRUE),
(1, 'CS301', 'Database Systems', 'Design and implementation of database systems', 4, 'CS201', TRUE),
(2, 'MATH101', 'Calculus I', 'Introduction to differential and integral calculus', 4, NULL, TRUE),
(2, 'MATH201', 'Linear Algebra', 'Vector spaces, matrices, and linear transformations', 4, 'MATH101', TRUE),
(4, 'ENG101', 'Composition I', 'Introduction to academic writing', 3, NULL, TRUE),
(4, 'ENG201', 'World Literature', 'Survey of world literature from ancient to modern times', 3, 'ENG101', TRUE),
(10, 'BUS101', 'Introduction to Business', 'Overview of business concepts and practices', 3, NULL, TRUE),
(10, 'BUS201', 'Principles of Marketing', 'Fundamentals of marketing theory and practice', 3, 'BUS101', TRUE),
(8, 'PSY101', 'Introduction to Psychology', 'Survey of major psychological concepts and theories', 3, NULL, TRUE);

-- 7. Insert into sections
INSERT INTO sections (course_id, faculty_id, semester, year, section_number, classroom, schedule, start_date, end_date, max_capacity, current_enrollment, status)
VALUES
(1, 1, 'Fall', 2023, '01', 'SB-101', 'MWF 10:00-10:50', '2023-08-28', '2023-12-15', 30, 25, 'Open'),
(1, 2, 'Fall', 2023, '02', 'SB-102', 'TTH 11:00-12:15', '2023-08-28', '2023-12-15', 30, 30, 'Closed'),
(2, 1, 'Fall', 2023, '01', 'SB-201', 'MWF 11:00-11:50', '2023-08-28', '2023-12-15', 25, 22, 'Open'),
(3, 2, 'Spring', 2023, '01', 'SB-202', 'TTH 13:00-14:15', '2023-01-17', '2023-05-12', 25, 18, 'Closed'),
(4, 3, 'Fall', 2023, '01', 'SB-103', 'MWF 09:00-09:50', '2023-08-28', '2023-12-15', 35, 35, 'Closed'),
(5, 3, 'Spring', 2023, '01', 'SB-104', 'TTH 10:00-11:15', '2023-01-17', '2023-05-12', 30, 28, 'Closed'),
(6, 5, 'Fall', 2023, '01', 'HB-101', 'MWF 13:00-13:50', '2023-08-28', '2023-12-15', 25, 20, 'Open'),
(7, 5, 'Spring', 2023, '01', 'HB-102', 'TTH 14:00-15:15', '2023-01-17', '2023-05-12', 25, 22, 'Closed'),
(8, 10, 'Fall', 2023, '01', 'BB-101', 'MWF 14:00-14:50', '2023-08-28', '2023-12-15', 30, 25, 'Open'),
(9, 10, 'Spring', 2023, '01', 'BB-102', 'TTH 15:00-16:15', '2023-01-17', '2023-05-12', 30, 30, 'Closed');

-- 8. Insert into enrollments
INSERT INTO enrollments (student_id, section_id, enrollment_date, grade, status)
VALUES
(1, 1, '2023-08-01', 92.5, 'Completed'),
(1, 3, '2023-08-01', 88.0, 'Completed'),
(2, 1, '2023-08-02', NULL, 'Registered'),
(2, 7, '2023-08-02', NULL, 'Registered'),
(3, 4, '2023-01-05', 95.0, 'Completed'),
(3, 6, '2023-01-05', 91.5, 'Completed'),
(4, 7, '2023-08-03', NULL, 'Registered'),
(4, 9, '2023-08-03', NULL, 'Registered'),
(5, 1, '2023-08-04', NULL, 'Registered'),
(5, 4, '2023-01-06', 87.5, 'Completed');

-- 9. Insert into grades
INSERT INTO grades (enrollment_id, assignment_name, score, max_score, weight, due_date, submitted_date, feedback)
VALUES
(1, 'Midterm Exam', 90, 100, 30, '2023-10-15', '2023-10-15', 'Excellent work'),
(1, 'Final Exam', 95, 100, 40, '2023-12-10', '2023-12-10', 'Great job on the final'),
(1, 'Project', 92, 100, 30, '2023-12-01', '2023-11-30', 'Well-researched project'),
(2, 'Midterm Exam', 85, 100, 30, '2023-10-17', '2023-10-17', 'Good effort'),
(2, 'Final Exam', 91, 100, 40, '2023-12-12', '2023-12-12', 'Improved significantly'),
(2, 'Project', 88, 100, 30, '2023-12-03', '2023-12-02', 'Creative approach'),
(3, 'Midterm Exam', 97, 100, 30, '2023-03-15', '2023-03-15', 'Perfect score'),
(3, 'Final Exam', 93, 100, 40, '2023-05-05', '2023-05-05', 'Excellent understanding'),
(4, 'Midterm Exam', 89, 100, 30, '2023-03-17', '2023-03-17', 'Very good'),
(4, 'Final Exam', 86, 100, 40, '2023-05-07', '2023-05-07', 'Solid performance');

-- 10. Insert into program_courses
INSERT INTO program_courses (program_id, course_id, is_core, recommended_semester)
VALUES
(1, 1, TRUE, 1),
(1, 2, TRUE, 3),
(1, 3, TRUE, 5),
(1, 4, TRUE, 2),
(2, 1, TRUE, 1),
(2, 2, TRUE, 2),
(2, 3, TRUE, 3),
(3, 4, TRUE, 1),
(3, 5, TRUE, 3),
(4, 4, TRUE, 1);

-- 11. Insert into student_payments
INSERT INTO student_payments (student_id, amount, payment_date, payment_method, transaction_id, semester, year, purpose, status)
VALUES
(1, 1500.00, '2023-08-01', 'Credit Card', 'TXN1001', 'Fall', 2023, 'Tuition', 'Completed'),
(2, 1500.00, '2023-08-02', 'Bank Transfer', 'TXN1002', 'Fall', 2023, 'Tuition', 'Completed'),
(3, 1500.00, '2023-01-05', 'Credit Card', 'TXN1003', 'Spring', 2023, 'Tuition', 'Completed'),
(4, 1500.00, '2023-08-03', 'Debit Card', 'TXN1004', 'Fall', 2023, 'Tuition', 'Completed'),
(5, 1500.00, '2023-08-04', 'Credit Card', 'TXN1005', 'Fall', 2023, 'Tuition', 'Completed'),
(6, 1500.00, '2023-01-06', 'Bank Transfer', 'TXN1006', 'Spring', 2023, 'Tuition', 'Completed'),
(7, 1500.00, '2023-08-05', 'Debit Card', 'TXN1007', 'Fall', 2023, 'Tuition', 'Completed'),
(8, 1500.00, '2023-08-06', 'Credit Card', 'TXN1008', 'Fall', 2023, 'Tuition', 'Completed'),
(9, 1500.00, '2023-01-07', 'Bank Transfer', 'TXN1009', 'Spring', 2023, 'Tuition', 'Completed'),
(10, 1500.00, '2023-08-07', 'Debit Card', 'TXN1010', 'Fall', 2023, 'Tuition', 'Completed');

-- 12. Insert into student_documents
INSERT INTO student_documents (student_id, document_type, file_name, file_path, upload_date, description, is_verified, verified_by, verified_date)
VALUES
(1, 'Transcript', 'transcript_john_smith.pdf', '/documents/transcripts/1.pdf', '2019-08-15', 'High school transcript', TRUE, 1, '2019-08-20'),
(2, 'Transcript', 'transcript_emily_johnson.pdf', '/documents/transcripts/2.pdf', '2020-08-10', 'High school transcript', TRUE, 1, '2020-08-18'),
(3, 'Transcript', 'transcript_michael_williams.pdf', '/documents/transcripts/3.pdf', '2018-08-12', 'High school transcript', TRUE, 2, '2018-08-20'),
(4, 'ID', 'id_sarah_brown.jpg', '/documents/ids/4.jpg', '2019-08-15', 'Student ID photo', TRUE, 2, '2019-08-20'),
(5, 'Transcript', 'transcript_david_jones.pdf', '/documents/transcripts/5.pdf', '2020-08-10', 'High school transcript', TRUE, 3, '2020-08-18'),
(6, 'ID', 'id_jessica_garcia.jpg', '/documents/ids/6.jpg', '2018-08-12', 'Student ID photo', TRUE, 3, '2018-08-20'),
(7, 'Application', 'application_daniel_miller.pdf', '/documents/applications/7.pdf', '2019-08-15', 'Original application', TRUE, 4, '2019-08-20'),
(8, 'Transcript', 'transcript_olivia_davis.pdf', '/documents/transcripts/8.pdf', '2020-08-10', 'High school transcript', TRUE, 4, '2020-08-18'),
(9, 'ID', 'id_matthew_rodriguez.jpg', '/documents/ids/9.jpg', '2018-08-12', 'Student ID photo', TRUE, 5, '2018-08-20'),
(10, 'Application', 'application_sophia_martinez.pdf', '/documents/applications/10.pdf', '2019-08-15', 'Original application', TRUE, 5, '2019-08-20');

show tables;