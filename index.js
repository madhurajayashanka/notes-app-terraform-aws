require('dotenv').config(); // Load variables from .env file
const express = require('express');
const bodyParser = require('body-parser');
const AWS = require('aws-sdk');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(bodyParser.json());

// Initialize AWS SDK with your credentials from .env
AWS.config.update({
    region: process.env.AWS_REGION,
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
});

// Create AWS DynamoDB and RDS instances
const dynamoDB = new AWS.DynamoDB.DocumentClient();
const rds = new AWS.RDS();

// Define Swagger options
const swaggerOptions = {
    swaggerDefinition: {
        openapi: '3.0.0',
        info: {
            title: 'CRUD Express.js API with Swagger',
            version: '1.0.0',
            description: 'Documentation for the CRUD Express.js API with Swagger',
        },
    },
    apis: ['./index.js'], // Specify the file(s) where your API routes are defined
};

// Initialize Swagger-jsdoc
const swaggerSpec = swaggerJsdoc(swaggerOptions);

// Serve Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

/**
 * @swagger
 * /:
 *   get:
 *     summary: Welcome message
 *     description: Returns a welcome message.
 *     responses:
 *       '200':
 *         description: A welcome message.
 */
app.get('/', (req, res) => {
    res.send('Testing 2 Welcome to the CRUD Express.JS App!');
});

/**
 * @swagger
 * /create-dynamo:
 *   post:
 *     summary: Create item in DynamoDB
 *     description: Creates a new item in DynamoDB.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               // Define your request  body properties here
 *     responses:
 *       '200':
 *         description: Item created successfully.
 *       '500':
 *         description: Error creating item in DynamoDB.
 */
app.post('/create-dynamo', (req, res) => {
    const params = {
        TableName: process.env.DYNAMODB_TABLE_NAME,
        Item: req.body,
    };

    dynamoDB.put(params, (err, data) => {
        if (err) {
            console.error('Unable to add item. Error JSON:', JSON.stringify(err, null, 2));
            res.status(500).send('Error adding item to DynamoDB');
        } else {
            console.log('Added item:', JSON.stringify(data, null, 2));
            res.status(200).send('Item added to DynamoDB');
        }
    });
});

/**
 * @swagger
 * /get-dynamo/{id}:
 *   get:
 *     summary: Get item from DynamoDB
 *     description: Retrieves an item from DynamoDB by ID.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the item to retrieve.
 *         schema:
 *           type: string
 *     responses:
 *       '200':
 *         description: Item retrieved successfully.
 *       '500':
 *         description: Error retrieving item from DynamoDB.
 */
app.get('/get-dynamo/:id', (req, res) => {
    const params = {
        TableName: process.env.DYNAMODB_TABLE_NAME,
        Key: {
            note_id: req.params.id,
        },
    };

    dynamoDB.get(params, (err, data) => {
        if (err) {
            console.error('Unable to read item. Error JSON:', JSON.stringify(err, null, 2));
            res.status(500).send('Error reading item from DynamoDB');
        } else {
            console.log('GetItem succeeded:', JSON.stringify(data, null, 2));
            res.status(200).send(data.Item);
        }
    });
});


// Start the server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
