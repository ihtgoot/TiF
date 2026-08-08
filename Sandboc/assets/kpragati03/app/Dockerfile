# Use official Python 3.13 slim image
FROM python:3.13-slim

# Set working directory inside container
WORKDIR /app

# Copy application files to container
COPY . /app

# Run application in interactive unbuffered mode
CMD ["python", "-u", "main.py"]
