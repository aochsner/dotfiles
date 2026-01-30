# for Apple M1 macs
#export DOCKER_BUILDKIT=0
#export COMPOSE_DOCKER_CLI_BUILD=0
#export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Link Homebrew-installed docker plugins (macOS)
if command -v brew &>/dev/null; then
  mkdir -p ~/.docker/cli-plugins
  local brew_prefix=$(brew --prefix)
  [[ -f "$brew_prefix/opt/docker-compose/bin/docker-compose" ]] && \
    ln -sfn "$brew_prefix/opt/docker-compose/bin/docker-compose" ~/.docker/cli-plugins/docker-compose
  [[ -f "$brew_prefix/opt/docker-buildx/bin/docker-buildx" ]] && \
    ln -sfn "$brew_prefix/opt/docker-buildx/bin/docker-buildx" ~/.docker/cli-plugins/docker-buildx
fi
#docker buildx install
