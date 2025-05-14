locals {
  iam_permissions = {
    creator = [
      "iam:PassRole"
    ]
    manager = [
      "iam:PassRole"
    ]
    reader = [
      "iam:Get*",
      "iam:List*",
    ]
  }
}
