const express = require('express');
const pg = require('pg');
const bodyParser = require('body-parser');

// Connect to PostgreSQL database using environment variables or default credentials
const pool = new pg.Pool({
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'ECYLQKMJS71c2GUu13lY',
    database: process.env.DB_DATABASE || 'postgres',
    host: process.env.DB_HOST || 'database-1.cluster-cbfibzwafy6o.us-west-2.rds.amazonaws.com',
    port: process.env.DB_PORT || 5432,
});

// Create `data` table if it doesn't exist
(async () => {
    try {
        await pool.query(`CREATE TABLE IF NOT EXISTS data (
            id SERIAL PRIMARY KEY,
            value TEXT
        )`);
    } catch (error) {
        console.error(error);
    }
})();

const app = express();
app.use(bodyParser.json());

// GET /status
app.get('/status', (req, res) => {
    res.json({ status: 'OK' });
});

// POST /data
app.post('/data', async (req, res) => {
    const { data } = req.body;

    try {
        await pool.query('INSERT INTO data (value) VALUES ($1)', [data]);   
        res.json({ message: 'Data stored successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Failed to store data' });
    }
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server listening on port ${port}`);
});