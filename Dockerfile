# Base Alpine Image
FROM alpine:latest
LABEL description="Docker image for ChipWhisperer platform on Alpine Linux" \
      url="https://github.com/ouspg/chipwhisperer"

ENV USER="appuser"

# System setup
RUN echo "chipwhisperer" > /etc/hostname && \
    apk update && \
    apk add python3 py3-pip git gcc-avr avr-libc gcc-arm-none-eabi newlib-arm-none-eabi make nano udev sudo bash py3-wheel py3-matplotlib py3-scipy py3-numpy py3-pandas py3-psutil libusb mpfr-dev gmp-dev mpc1-dev

# Clone ChipWhisperer repository
# ARG REPO_URL=https://github.com/newaetech/chipwhisperer.git
# RUN git clone --depth=1 $REPO_URL chipwhisperer

RUN addgroup -S appuser && \
adduser -s /sbin/nologin --disabled-password -G appuser appuser


# COPY run.sh /home/appuser/run.sh
COPY --chown=$USER jupyter_notebook_config.py /home/$USER/.jupyter/

# USB setup
COPY *-newae.rules /etc/udev/rules.d/
RUN addgroup -S plugdev && addgroup -g 1001 chipwhisperer && \
    addgroup "$USER" plugdev && \
    addgroup "$USER" chipwhisperer && \
    addgroup "$USER" dialout 

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
# --device=/dev/bus/usb/001/007
