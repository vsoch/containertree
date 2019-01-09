workflow "Run container-diff isolated" {
  on = "push"
  resolves = ["list"]
}

action "Run container-diff" {
  uses = "vsoch/container-diff/actions@add/github-actions"
  args = ["container-diff", "analyze", "remote://vanessa/salad", "--type=pip", "type=apt", "--type=history", "--output", "/github/workspace/data.json", "--type=file", "--json", "--quiet", "--verbosity=panic"]
}

action "list" {
  needs = ["Run container-diff"]
  uses = "actions/bin/sh@master"
  runs = "ls"
  args = ["/github/workspace"]
}
