FROM node:18-alpine as stage

WORKDIR /app/web

COPY web/package.json /app/web/package.json

RUN yarn

COPY web /app/web

RUN ls -lah && yarn build

FROM python:3.11-slim-buster

RUN \
    apt-get update \
    && pip install --no-cache-dir --upgrade pip \
    && apt-get install -y vim curl default-libmysqlclient-dev pkg-config build-essential libcurl4-openssl-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

COPY --from=stage /app/ui /app/ui

EXPOSE 8080

CMD ["python" , "search_with_lepton.py"]
