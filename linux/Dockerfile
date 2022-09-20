FROM archlinux

RUN curl -L https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/ci.sh | INST_USER=mk bash

RUN curl -L https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/src/scripts/init.sh | sudo -u mk CI=true INSTALL_TYPE="min" bash

USER mk

RUN chezmoi update -k --force --exclude=encrypted -S /home/mk/Documents/repos/dotfiles

RUN curl -L https://raw.githubusercontent.com/DiXN/dotfiles/chezmoi/linux/scripts/essentials.sh | bash

ENTRYPOINT [ "awesome" ]

