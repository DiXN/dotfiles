FROM archlinux

RUN curl -L https://raw.githubusercontent.com/DiXN/dotfiles/minimal/ci.sh | INST_USER=mk bash

RUN curl -L https://raw.githubusercontent.com/DiXN/dotfiles/minimal/src/scripts/init.sh | sudo -u mk CI=true INSTALL_TYPE="min" bash
RUN chezmoi update -k --force --exclude=encrypted -S /home/mk/Documents/repos/dotfiles

USER mk

RUN curl -L https://raw.githubusercontent.com/DiXN/dotfiles/minimal/linux/scripts/essentials.sh | sudo -u mk bash

ENTRYPOINT [ "awesome" ]

