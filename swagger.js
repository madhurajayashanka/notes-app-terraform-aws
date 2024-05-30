const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'CRUD Express.js API with Swagger',
            version: '1.0.0',
            description: 'Documentation for the CRUD Express.js API with Swagger',
        },
        servers: [
            {
                url: 'http://localhost:3000', // Update with your actual server URL
                description: 'Development server',
            },
        ],
    },
    apis: ['./index.js'], // Specify the file(s) where your API routes are defined
};

const specs = swaggerJsdoc(options);

module.exports = (app) => {
    app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));
};
