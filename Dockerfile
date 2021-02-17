FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=nointeractive

RUN apt update && apt install software-properties-common -y && add-apt-repository ppa:lazygit-team/release -y
RUN apt update && apt upgrade --no-install-recommends -y
RUN apt install sudo git curl xsel wget gettext make cmake gcc g++ gperf luajit libluajit-5.1-dev luarocks libuv1-dev\
                libunibilium-dev libtermkey-dev libvterm-dev libmsgpack-dev libutf8proc-dev python3 python3-pip zsh lazygit ripgrep fd-find silversearcher-ag ranger -y

RUN groupadd engineer && useradd -ms /bin/bash -G engineer dev && echo "dev ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /home/dev/workspace

RUN luarocks build mpack && luarocks build lpeg && luarocks build inspect
RUN git clone https://github.com/neovim/neovim 
RUN cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo && make install

RUN curl -sL https://deb.nodesource.com/setup_15.x | bash -

RUN apt install nodejs -y
RUN npm i -g npm && npm i -g @nestjs/cli && npm i -g create-react-app

RUN wget https://golang.org/dl/go1.16.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.16.linux-amd64.tar.gz && rm go1.16.linux-amd64.tar.gz

RUN wget https://raw.githubusercontent.com/ChristianChiarulli/nvim/master/utils/install.sh
RUN chmod +x install.sh 

USER dev

RUN sh ./install.sh

RUN timeout 1m nvim --headless +TSUpdate; exit 0 && timeout 1m nvim --headless +CocInstall; exit 0
RUN sudo ln -s /usr/local/bin/nvim /usr/local/bin/vim && mkdir -p /home/dev/workspace


RUN sudo chsh -s $(which zsh) && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

RUN sudo rm -rf ~/.zshrc ~/workspace/neovim ~/workspace/install.sh
COPY ./zshrc /home/dev/.zshrc
COPY p10k.zsh /home/dev/.p10k.zsh
RUN sudo chown -R dev:engineer ~/workspace ~/.zshrc ~/.p10k.zsh

ENTRYPOINT ["/usr/bin/zsh"]
