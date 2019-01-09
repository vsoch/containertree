workflow "Deploy ContainerTree Extraction" {
  on = "push"
  resolves = ["deploy"]
}

action "login" {
  uses = "actions/docker/login@master"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "extract" {
  uses = "docker://singularityhub/container-tree"
  args = ["--quiet generate --output=/github/workspace vanessa/salad"]
}

action "list" {
  needs = ["extract"]
  uses = "actions/bin/sh@master"
  runs = "ls"
  args = ["/github/workspace"]
}

action "deploy" {
  needs = ["login", "extract", "list"]
  uses = "docker://singularityhub/container-tree"
  secrets = ["GITHUB_TOKEN"]
  runs = "/github/workspace/deploy.sh"
  args = ["index.html data.json"]
}
