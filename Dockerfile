# Use a specific Node.js runtime as a parent image
FROM node:18.20.3-alpine3.20

# Set the working directory
WORKDIR /app

# Copy the package.json file and install dependencies
COPY package.json /app/package.json
RUN npm install

# Copy the rest of the application source code
COPY . /app

# Build-time arguments
ARG AWS_REGION
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG DYNAMODB_TABLE_NAME
ARG RDS_INSTANCE_IDENTIFIER
ARG RDS_DB_NAME
ARG RDS_USERNAME
ARG RDS_PASSWORD
ARG S3_BUCKET_NAME

# Set environment variables
ENV AWS_REGION=$AWS_REGION
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ENV DYNAMODB_TABLE_NAME=$DYNAMODB_TABLE_NAME
ENV RDS_INSTANCE_IDENTIFIER=$RDS_INSTANCE_IDENTIFIER
ENV RDS_DB_NAME=$RDS_DB_NAME
ENV RDS_USERNAME=$RDS_USERNAME
ENV RDS_PASSWORD=$RDS_PASSWORD
ENV S3_BUCKET_NAME=$S3_BUCKET_NAME

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["npm", "run", "start"]
