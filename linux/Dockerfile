FROM archlinux

RUN curl -L https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/ci.sh | INST_USER=mk bash

RUN curl -L https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/src/scripts/init.sh | sudo -u mk CI=true INSTALL_TYPE="min" bash
RUN sudo -u mk bash -c 'yay -Sy --noconfirm nvidia-470xx-dkms nvidia-470xx-utils nvidia-470xx-settings && yay -Scc --noconfirm'

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all

USER mk

RUN chezmoi update -k --force --exclude=encrypted -S /home/mk/Documents/repos/dotfiles

RUN curl -L https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/linux/scripts/essentials.sh | sudo -u mk bash

ENTRYPOINT [ "awesome" ]

