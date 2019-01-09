workflow "Deploy ContainerTree Extraction" {
  on = "push"
  resolves = ["deploy"]
}

action "login" {
  uses = "actions/docker/login@master"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "run" {
  uses = "actions/docker/cli@master"
  args = ["run", "-d", "--entrypoint", "/bin/bash", "--name", "containertree" , "singularityhub/container-tree"]
}

action "extract" {
  needs = ["login", "run"]
  uses = "actions/docker/cli@master"
  args = ["exec containertree --quiet generate --output=/data vanessa/salad"]
}

action "copy" {
  needs = ["login", "run", "extract"]
  uses = "actions/docker/cli@master"
  args = ["cp containertree:/data /github/workspace/docs"]
}

action "deploy" {
  needs = ["login", "run", "extract", "copy"]
  uses = "actions/bin/sh@master"
  secrets = ["GITHUB_TOKEN"]
  runs = "/bin/bash"
  args = ["/github/workspace/deploy.sh"]
}
