FROM docker.io/rust:1.64-bullseye

RUN DEBIAN_FRONTEND=noninteractive apt update && DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
    libleptonica-dev \
    libtesseract-dev \
    libreofficekit-dev \
    libpoppler-dev \
    libcairo2-dev \
    libclang-11-dev llvm gcc \
    libtiff-dev \
    libjpeg-dev \
    libgif-dev \
    libwebp-dev \
    libjpeg-dev \
    curl libpoppler-glib-dev && apt clean
