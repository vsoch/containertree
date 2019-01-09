workflow "Deploy ContainerTree Extraction" {
  on = "push"
  resolves = ["deploy"]
}

action "login" {
  uses = "actions/docker/login@master"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "extract data" {
  needs = ["login"]
  uses = "docker://singularityhub/container-tree"
  args = ["--quiet generate --print data.json vanessa/salad", ">", "data.json"]
}

action "extract index" {
  needs = ["login"]
  uses = "docker://singularityhub/container-tree"
  args = ["--quiet generate --print index.html vanessa/salad", ">", "index.html"]
}

action "deploy" {
  needs = ["login", "extract data", "extract index"]
  uses = "actions/bin/sh@master"
  secrets = ["GITHUB_TOKEN"]
  runs = "/bin/bash"
  args = ["/github/workspace/deploy.sh"]
}
