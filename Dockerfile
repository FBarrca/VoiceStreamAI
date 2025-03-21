# Use an NVIDIA CUDA base image with Python 3
FROM nvcr.io/nvidia/pytorch:25.02-py3

# Set the working directory in the container
WORKDIR /usr/src/app

# Avoid interactive prompts from apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install any needed packages
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq install \
                   ffmpeg \
                   libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages from requirements.txt
COPY req.txt req.txt
COPY req-sb.txt req-sb.txt
COPY req-pya.txt req-pya.txt

RUN pip3 install --no-cache-dir --pre torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128 \
    && pip3 install --no-cache-dir --pre torchvision --index-url https://download.pytorch.org/whl/nightly/cu128 \
    && pip3 install --no-cache-dir -r req.txt \
    && pip3 install --no-cache-dir -r req-sb.txt \
    && pip3 install --no-cache-dir speechbrain>=1.0.0 \
    && pip3 install --no-cache-dir -r req-pya.txt \
    && pip3 install --no-cache-dir pyannote.audio>=3.2.0 --no-deps


# Copy the rest of your application's code
COPY . .

# Make port 8765 available to the world outside this container
EXPOSE 8765

# Define environment variable
ENV NAME VoiceStreamAI

# # Set the entrypoint to your application
ENTRYPOINT ["python3", "-m", "src.main"]

# Provide a default command (can be overridden at runtime)
CMD ["--host", "0.0.0.0", "--port", "8765"]
