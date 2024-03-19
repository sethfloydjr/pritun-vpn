resource "aws_iam_instance_profile" "pritunl_instance_profile" {
  name = "pritunl_instance_profile"
  role = aws_iam_role.pritunl_role.name
}

resource "aws_iam_role" "pritunl_role" {
  name = "pritunl_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
            "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name          = "pritunl_role"
  }
}



resource "aws_iam_role_policy_attachment" "pritunl_role_attach" {
  role       = aws_iam_role.pritunl_role.name
  policy_arn = aws_iam_policy.pritunl_iam_policy.arn
}

resource "aws_iam_policy" "pritunl_iam_policy" {
  name   = "pritunl_iam_policy"
  policy = data.aws_iam_policy_document.pritunl_policy_doc.json
}

data "aws_iam_policy_document" "pritunl_policy_doc" {
  statement {
    sid    = "BucketAccess"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "${aws_s3_bucket.pritunl_bucket.arn}",
      "${aws_s3_bucket.pritunl_bucket.arn}/*"
    ]
  }
}
