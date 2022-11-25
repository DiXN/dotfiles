FROM archlinux

RUN curl -Ls https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/ci.sh | INST_USER=mk bash

RUN curl -Ls -o /tmp/packages https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/src/templates/base/pacman.yaml
RUN curl -Ls https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/linux/scripts/chunk_packages.sh | sudo -u mk FILE_IN="/tmp/packages" bash

RUN curl -Ls https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/src/scripts/init.sh | sudo -u mk INSTALL_TYPE="min" DOCKER="true" bash

RUN curl -Ls https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/linux/scripts/packages.sh | sudo -u mk CI=true INSTALL_TYPE="min" FILE_PATH="/tmp/dotfiles/packages/pacman_1.yaml" bash -x
RUN curl -Ls https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/linux/scripts/packages.sh | sudo -u mk CI=true INSTALL_TYPE="min" FILE_PATH="/tmp/dotfiles/packages/pacman_2.yaml" bash -x
RUN curl -Ls https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/linux/scripts/packages.sh | sudo -u mk CI=true INSTALL_TYPE="min" FILE_PATH="/tmp/dotfiles/packages/pacman_3.yaml" bash -x
RUN curl -Ls https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/linux/scripts/packages.sh | sudo -u mk CI=true INSTALL_TYPE="min" FILE_PATH="/tmp/dotfiles/packages/pacman_4.yaml" bash -x

USER mk

RUN chezmoi update -k --force --exclude=encrypted -S /home/mk/Documents/repos/dotfiles

RUN curl -L https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/linux/scripts/essentials.sh | bash

ENTRYPOINT [ "awesome" ]

