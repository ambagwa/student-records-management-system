// app.js
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const db = require('./db');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

app.get('/', (req, res) => {
    res.json({
      message: 'Welcome to the Student Records Management System API',
      endpoints: {
        students: '/students',
        programs: '/programs',
        enrollments: '/enrollments'
      }
    });
  });

// Students CRUD Endpoints
app.get('/students', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM students');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/students/:id', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM students WHERE student_id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Student not found' });
    }
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/students', async (req, res) => {
  try {
    const { program_id, first_name, last_name, date_of_birth, gender, email, phone, address, city, state, zip_code, country, enrollment_date } = req.body;
    
    const [result] = await db.query(
      'INSERT INTO students (program_id, first_name, last_name, date_of_birth, gender, email, phone, address, city, state, zip_code, country, enrollment_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [program_id, first_name, last_name, date_of_birth, gender, email, phone, address, city, state, zip_code, country, enrollment_date]
    );
    
    const [newStudent] = await db.query('SELECT * FROM students WHERE student_id = ?', [result.insertId]);
    res.status(201).json(newStudent[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/students/:id', async (req, res) => {
  try {
    const { program_id, first_name, last_name, date_of_birth, gender, email, phone, address, city, state, zip_code, country, enrollment_date, status } = req.body;
    
    await db.query(
      'UPDATE students SET program_id = ?, first_name = ?, last_name = ?, date_of_birth = ?, gender = ?, email = ?, phone = ?, address = ?, city = ?, state = ?, zip_code = ?, country = ?, enrollment_date = ?, status = ? WHERE student_id = ?',
      [program_id, first_name, last_name, date_of_birth, gender, email, phone, address, city, state, zip_code, country, enrollment_date, status, req.params.id]
    );
    
    const [updatedStudent] = await db.query('SELECT * FROM students WHERE student_id = ?', [req.params.id]);
    res.json(updatedStudent[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/students/:id', async (req, res) => {
  try {
    await db.query('DELETE FROM students WHERE student_id = ?', [req.params.id]);
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Programs Endpoints
app.get('/programs', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM programs');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Enrollments Endpoints
app.get('/enrollments', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT e.enrollment_id, s.student_id, s.first_name, s.last_name, 
             c.course_code, c.course_name, sec.section_number, 
             e.grade, e.status
      FROM enrollments e
      JOIN students s ON e.student_id = s.student_id
      JOIN sections sec ON e.section_id = sec.section_id
      JOIN courses c ON sec.course_id = c.course_id
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/enrollments', async (req, res) => {
  try {
    const { student_id, section_id } = req.body;
    
    const [result] = await db.query(
      'INSERT INTO enrollments (student_id, section_id, enrollment_date) VALUES (?, ?, CURDATE())',
      [student_id, section_id]
    );
    
    // Update section enrollment count
    await db.query(
      'UPDATE sections SET current_enrollment = current_enrollment + 1 WHERE section_id = ?',
      [section_id]
    );
    
    const [newEnrollment] = await db.query(`
      SELECT e.*, s.first_name, s.last_name, c.course_code, c.course_name
      FROM enrollments e
      JOIN students s ON e.student_id = s.student_id
      JOIN sections sec ON e.section_id = sec.section_id
      JOIN courses c ON sec.course_id = c.course_id
      WHERE e.enrollment_id = ?
    `, [result.insertId]);
    
    res.status(201).json(newEnrollment[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
}); 