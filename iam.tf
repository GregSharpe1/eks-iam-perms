resource aws_s3_bucket bucket {
  bucket = "${local.stack}-tehe"
  acl = "private"

  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

data aws_iam_policy_document policy {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource aws_iam_policy policy {
  name        = "${local.stack}-read-s3"
  policy = data.aws_iam_policy_document.policy.json
}

resource aws_iam_role role {
  name = "${local.stack}-read-s3"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource aws_iam_role_policy_attachment role_attachment {
  role = aws_iam_role.role.id
  policy_arn = aws_iam_policy.policy.arn
}

data aws_iam_policy_document assume_role {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.cluster.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = trimprefix("${data.aws_arn.oidc-provider.resource}:sub", "oidc-provider/")

      # Allow in any namespace, with the app1 serviceaccount
      values = ["system:serviceaccount:*:app1"]
    }
  }
}
