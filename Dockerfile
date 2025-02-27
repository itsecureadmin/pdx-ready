FROM python:3.9-slim-bullseye

# Update C env vars so compiler can find gdal
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# Install GDAL dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    binutils          \
    libproj-dev       \
    gdal-bin          \
    libjpeg-dev       \
    g++               \
    libgdal-dev       \
    nodejs            \
    npm               \
    postgresql-client \
    unzip             \
    zip               \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r django && useradd --no-log-init -r -g django django
RUN mkdir /home/django && chown -R django:django /home/django
RUN mkdir /app

# Run the application:
COPY . /app
RUN chown -R django:django /app
WORKDIR /app

USER django

# Install dependencies:
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# verify pip install
RUN pip list

WORKDIR /app/disasterinfosite
RUN unzip data.zip

RUN npm install && npm run webpack

WORKDIR /app

EXPOSE 8000

ENTRYPOINT ["python"]
CMD ["manage.py", "runserver", "0.0.0.0:8000"]
