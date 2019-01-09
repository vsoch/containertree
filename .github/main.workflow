workflow "Run container-diff isolated" {
  on = "push"
  resolves = ["list"]
}

action "Run container-diff" {
  uses = "vsoch/container-diff/actions@add/github-actions"
  args = ["container-diff", "analyze", "remote://vanessa/salad"]
}

action "list" {
  needs = ["Run container-diff"]
  uses = "actions/bin/sh@master"
  runs = "ls"
  args = ["/github/workspace"]
}
