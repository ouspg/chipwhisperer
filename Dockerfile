# Base debian Image
FROM debian:12-slim

LABEL org.opencontainers.image.description "Docker image for ChipWhisperer platform on Alpine Linux with CW303 and CWNANO support."
LABEL org.opencontainers.image.source "https://github.com/ouspg/chipwhisperer"

ENV USER="appuser"
ENV VIRTUAL_ENV=/opt/chipwhisperer

# System setup

RUN echo "chipwhisperer" > /etc/hostname && \
    apt-get update && \
    apt-get install -y \
    uuid-dev curl \
    libusb-dev make git avr-libc gcc-avr \
    gcc-arm-none-eabi libusb-1.0-0-dev usbutils

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/" sh && \
    chmod 755 /usr/bin/uv

ENV PATH="/root/.cargo/bin:$PATH"

RUN groupadd --system "$USER" && \
    useradd -s /usr/sbin/nologin --no-create-home -g "$USER" "$USER" && \
    groupadd --gid 1999 chipwhisperer && \
    usermod -aG plugdev "$USER" && \
    usermod -aG chipwhisperer "$USER" && \
    usermod -aG dialout "$USER" && \
    mkdir -p "$VIRTUAL_ENV" && \
    chown "$USER:$USER" "$VIRTUAL_ENV"


COPY --chown=$USER jupyter_notebook_config.py /home/$USER/.jupyter/
# USB setup
COPY *-newae.rules /etc/udev/rules.d/

USER appuser
COPY requirements.txt requirements.txt
RUN git config --global user.name "example" && \
    git config --global user.email "example@example.com" && \
    uv venv --python 3.8 "$VIRTUAL_ENV" && \
    uv pip install -r requirements.txt

# Jupyter password setup
ARG NOTEBOOK_PASS
# 'jupyter' password in hashed format
RUN echo "\nc.ServerApp.password='argon2:\$argon2id\$v=19\$m=10240,t=10,p=8\$DTTIwTEnDbEOyNokTlBUFQ\$noFWTuC3jabiEhivkK0tcJ/RkDu4xLy0GE3qJKckL1g'" >> /home/$USER/.jupyter/jupyter_notebook_config.py


WORKDIR /home/appuser/jupyter

# Expose Jupyter port
EXPOSE 8888

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Command to start the container
CMD ["uv", "run", "jupyter", "nbclassic", "--no-browser"]
