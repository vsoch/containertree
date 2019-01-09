workflow "Deploy ContainerTree Extraction" {
  on = "push"
  resolves = ["deploy"]
}

action "login" {
  uses = "actions/docker/login@master"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "extract" {
  needs = ["login"]
  uses = "docker://singularityhub/container-tree"
  args = ["--quiet generate --output=/github/workspace vanessa/salad"]
}

action "deploy" {
  needs = ["login", "extract"]
  uses = "actions/bin/sh@master"
  secrets = ["GITHUB_TOKEN"]
  runs = "/bin/bash"
  args = ["/github/workspace/deploy.sh"]
}
