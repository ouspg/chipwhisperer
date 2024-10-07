# Base debian Image
FROM alpine:edge

LABEL org.opencontainers.image.description "Docker image for ChipWhisperer platform on Alpine Linux with CW303 and CWNANO support."
LABEL org.opencontainers.image.source "https://github.com/ouspg/chipwhisperer"

ENV USER="appuser"
ENV VIRTUAL_ENV=/opt/chipwhisperer
# ENV PATH="/root/.cargo/bin:$PATH"

# System setup
RUN echo "chipwhisperer" > /etc/hostname && \
    apk update && \
    apk add --no-cache python3  python3-dev py3-pip git build-base gcc-avr avr-libc gcc-arm-none-eabi libc-dev musl-dev newlib-arm-none-eabi make nano vim udev bash libusb mpfr-dev gmp-dev mpc1-dev libffi-dev usbutils uv

RUN addgroup -S $USER && \
    adduser -s /sbin/nologin --disabled-password -G $USER $USER &&  \
    addgroup -S plugdev && addgroup -g 1999 chipwhisperer && \
    addgroup "$USER" plugdev && \
    addgroup "$USER" chipwhisperer && \
    addgroup "$USER" dialout && \
    mkdir -p "$VIRTUAL_ENV" && \
    chown "$USER:$USER" "$VIRTUAL_ENV"

COPY --chown=$USER jupyter_notebook_config.py /home/$USER/.jupyter/
# USB setup
COPY *-newae.rules /etc/udev/rules.d/

USER appuser
COPY requirements.txt requirements.txt
RUN git config --global user.name "example" && \
    git config --global user.email "example@example.com" && \
    uv venv "$VIRTUAL_ENV" && \
    uv pip install nbstripout wheel matplotlib scipy numpy panda psutil jupyter notebook && \
    uv pip install -r requirements.txt

# Jupyter password setup
ARG NOTEBOOK_PASS
RUN echo "import os;from jupyter_server.auth import passwd; print('\nc.ServerApp.password=\'' + passwd(os.getenv('NOTEBOOK_PASS')) + '\'')" | uv run - >> /home/$USER/.jupyter/jupyter_notebook_config.py

WORKDIR /home/appuser/jupyter

# Expose Jupyter port
EXPOSE 8888

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Command to start the container
CMD ["uv", "run", "jupyter", "notebook", "--no-browser"]
