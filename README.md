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
  entrypoint = "/bin/bash"
  args = ["/github/workspace/deploy.sh index.html data.json"]
}
```

In the above, we are:

 1. Logging in to the docker daemon, in case we wanted to push
 2. Using the SingularityHub ContainerTree container to extract static files to the github workspace
 3. For our own debugging, listing the files in the workspace after generation
 4. Deploying back to Github Pages

If you have a Dockerfile in your repository, then you can build and deploy it,
and then generate its tree for Github pages! Notice below we've added
steps to build and push.

```
workflow "Deploy ContainerTree Extraction" {
  on = "push"
  resolves = ["deploy"]
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
  uses = "actions/bin/sh@master"
  secrets = ["GITHUB_TOKEN"]
  args = ["/github/workspace/deploy.sh index.html data.json"]
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
