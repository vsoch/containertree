# ContainerTree Actions

This Github repository will deploy (and show) example Github Actions workflows
for interacting with Google's Container Diff, along with the python
module (containertree) that uses it.

> What does this mean, in layman's terms?

This action will deploy a containertree to your Github pages after deploying
a Docker container.

# Usage

First, set up your `.github/main.workflow` in your repository to look like this:

```bash
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
```

If you have a Dockerfile in your repository, then you can build and deploy it,
and then generate its tree for Github pages!

```
workflow "Deploy ContainerTree Extraction" {
  on = "push"
  resolves = ["Extract ContainerTree"]
}

action "login" {
  uses = "actions/docker/login@master"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "build" {
  uses = "actions/docker/cli@master"
  args = "build -t vanessa/salad ."
}

action "push" {
  needs = ["login", "build"]
  uses = "actions/docker/cli@master"
  args = "push vanessa/salad"
}

action "Extract ContainerTree" {
  needs = ["build", "list"]
  uses = "docker://openschemas/extractors:ContainerTree"
  secrets = ["GITHUB_TOKEN"]
  env = {
    IMAGE_THUMBNAIL = "https://vsoch.github.io/datasets/assets/img/avocado.png"
    IMAGE_ABOUT = "Generate ascii art for a fork or spoon, along with a pun."
    IMAGE_DESCRIPTION = "alpine base with GoLang and PUNS."
  }
  args = ["extract", "--name", "vanessa/salad", "--contact", "@vsoch", "--filename", "/github/workspace/Dockerfile", "--deploy"]
}
```
When you deploy to Github pages for the first time, you
need to switch Github Pages to deploy from master and then back to the `gh-pages`
branch on deploy. There is a known issue with Permissions if you deploy
to the brain without activating it (as an admin) from the respository first.

## Other Examples

If you just want to generate the data.json for Container Diff (and roll
your own visualization) here is an example main.workflow to get you started:

```
workflow "Run container-diff isolated" {
  on = "push"
  resolves = ["list"]
}

action "Run container-diff" {
  uses = "vsoch/container-diff/actions@add/github-actions"
  args = ["analyze vanessa/salad --type=file --output=/github/workspace/data.json --json"]
}

action "list" {
  needs = ["Run container-diff"]
  uses = "actions/bin/sh@master"
  runs = "ls"
  args = ["/github/workspace"]
}
```

If you have any questions, please [open up an issue](https://www.github.com/vsoch/containertree)
