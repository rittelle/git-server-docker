FROM alpine:3.17.0

# "--no-cache" is new in Alpine 3.3 and it avoid using
# "--update + rm -rf /var/cache/apk/*" (to remove cache)
RUN apk add --no-cache \
  openssh \
  git \
  git-annex

WORKDIR /git-server/

# -D flag avoids password generation
# -s flag changes user's shell
# an installation without git-annex would use git-shell instead
RUN mkdir /git-server/keys \
  && adduser -D -s /usr/bin/git-annex-shell git \
  && echo git:12345 | chpasswd \
  && mkdir /home/git/.ssh

# set global git config for git-annex
USER git
RUN git config --global user.name "git" \
  && git config --global user.email "git@example.com"

USER root

# This is a login shell for SSH accounts to provide restricted Git access.
# It permits execution only of server-side Git commands implementing the
# pull/push functionality, plus custom commands present in a subdirectory
# named git-shell-commands in the user’s home directory.
# More info: https://git-scm.com/docs/git-shell
COPY git-shell-commands /home/git/git-shell-commands

# sshd_config file is edited for enable access key and disable access password
COPY sshd_config /etc/ssh/sshd_config
COPY start.sh start.sh

EXPOSE 22

CMD ["sh", "start.sh"]
