FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    sudo \
    git \
    # ser2net installation
    ser2net \
    # supervisor installation
    supervisor && \
    # create directory for child images to store configuration in
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor/conf.d

# ser2net base configuration 
COPY data/ser2net.conf /etc/ser2net.conf
# supervisor base configuration 
COPY data/supervisor.conf /etc/supervisor.conf

# Create user
RUN useradd -ms /bin/bash klippy && adduser klippy dialout
USER klippy

#This fixes issues with the volume command setting wrong permissions
RUN mkdir /home/klippy/.config
VOLUME /home/klippy/.config

### Klipper setup ###
WORKDIR /home/klippy

#COPY . klipper/
USER root
RUN echo 'klippy ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/klippy
#chown klippy:klippy -R klipper
# This is to allow the install script to run without error
RUN ln -s /bin/true /bin/systemctl
USER klippy
RUN git clone https://github.com/KevinOConnor/klipper
RUN ./klipper/scripts/install-ubuntu-18.04.sh
# Clean up install script workaround
RUN sudo rm -f /bin/systemctl

# default command
CMD ["supervisord", "-c", "/etc/supervisor.conf"]