# Base Alpine Image
FROM alpine:latest
LABEL description="Docker image for ChipWhisperer platform on Alpine Linux" \
      url="https://github.com/ouspg/chipwhisperer"
LABEL org.opencontainers.image.source https://github.com/ouspg/chipwhisperer

ENV USER="appuser"

# System setup
RUN echo "chipwhisperer" > /etc/hostname && \
    apk update && \
    apk add --no-cache python3 py3-pip git gcc-avr avr-libc gcc-arm-none-eabi libc-dev musl-dev newlib-arm-none-eabi make nano vim udev bash py3-wheel py3-matplotlib py3-scipy py3-numpy py3-pandas py3-psutil libusb mpfr-dev gmp-dev mpc1-dev libffi-dev

RUN addgroup -S $USER && \
    adduser -s /sbin/nologin --disabled-password -G $USER $USER &&  \
    addgroup -S plugdev && addgroup -g 1999 chipwhisperer && \
    addgroup "$USER" plugdev && \
    addgroup "$USER" chipwhisperer && \
    addgroup "$USER" dialout 


# COPY run.sh /home/appuser/run.sh
COPY --chown=$USER jupyter_notebook_config.py /home/$USER/.jupyter/

# USB setup
COPY *-newae.rules /etc/udev/rules.d/

USER appuser
COPY requirements.txt requirements.txt
RUN git config --global user.name "example" && \
    git config --global user.email "example@example.com" && \
    python3 -m pip install --upgrade pip && \
    pip3 install --no-warn-script-location -r requirements.txt

# Jupyter password setup
ARG NOTEBOOK_PASS
RUN python3 -c "import os;from jupyter_server.auth import passwd; print('\nc.ServerApp.password=\'' + passwd(os.getenv('NOTEBOOK_PASS')) + '\'')" >> /home/$USER/.jupyter/jupyter_notebook_config.py

COPY  --chown=$USER firmware /home/appuser/firmware
COPY --chown=$USER jupyter /home/appuser/jupyter

WORKDIR /home/appuser

# Expose Jupyter port
EXPOSE 8888

ENV PATH="/home/appuser/.local/bin:$PATH"

# Command to start the container
CMD ["jupyter", "notebook", "--no-browser"]
