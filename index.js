const redis = require('redis');
const express = require('express');
const pg = require('pg');
const bodyParser = require('body-parser');

// Connect to Redis server
const client = redis.createClient({
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379,
    auth_pass: process.env.REDIS_PASSWORD || 'your_redis_password',
});

// Connect to PostgreSQL database using environment variables
const pool = new pg.Pool({
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'password',
    database: process.env.DB_DATABASE || 'mydb',
    host: process.env.DB_HOST || 'localhost',
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

// GET /data
app.get('/data', async (req, res) => {
    const cachedData = await client.get('data');

    if (cachedData) {
        res.json({ message: 'Data retrieved from cache', data: cachedData });
        return;
    }

    try {
        const dataResult = await pool.query('SELECT value FROM data ORDER BY id DESC LIMIT 1');
        const data = dataResult.rows[0].value;

        await client.setex('data', 60, data); // Cache data for 60 seconds
        res.json({ message: 'Data retrieved from database', data });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Failed to retrieve data' });
    }
});

// POST /data
app.post('/data', async (req, res) => {
    const { data } = req.body;

    try {
        await pool.query('INSERT INTO data (value) VALUES ($1)', [data]);
        await client.del('data'); // Clear cache since data has changed
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