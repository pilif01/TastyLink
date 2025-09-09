# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    yt-dlp \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy function code
COPY src/ ./src/
COPY package.json ./

# Install Node.js dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install

# Set environment variables
ENV PYTHONPATH=/app
ENV NODE_ENV=production

# Expose port
EXPOSE 8080

# Start the function
CMD ["npm", "start"]