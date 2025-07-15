FROM python:3.9-slim
# Set working directory
WORKDIR /app
 
# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt
 
# Copy application code and HTML
COPY app.py .
COPY templates/ ./templates/
 
# Expose the Flask port
EXPOSE 5002
 
# Run the app
CMD ["python", "app.py"]
