#Second provider needed to replicate bucket to another region
provider "aws" {
    access_key                                  = var.access_key
    secret_key                                  = var.secret_key
    alias                                       = "west"
    region                                      = "us-west-2"
}

resource "aws_iam_role" "pritunl_replication_role" {
  name                                          = "pritunl_replication"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "pritunl_replication_policy" {
  name                                          = "pritunl_replication_role"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.pritunl_bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.pritunl_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.pritunl_destination.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "pritunl_replication_attachment" {
  name                                              = "pritunl_replication_attachment"
  roles                                             = [aws_iam_role.pritunl_replication_role.name]
  policy_arn                                        = aws_iam_policy.pritunl_replication_policy.arn
}

resource "aws_s3_bucket" "pritunl_bucket" {
  bucket                                            = "${var.pritunl_bucket_prefix}-us-east-1"
  acl                                               = "private"
  region                                            = "us-east-1"

  versioning {
    enabled                                         = true
  }

  replication_configuration {
    role                                            = aws_iam_role.pritunl_replication_role.arn

    rules {
      id                                            = "replication_rule"
      prefix                                        = "" #leave as an empty string to replicate the whole bucket
      status                                        = "Enabled"

      destination {
        bucket                                      = aws_s3_bucket.pritunl_destination.arn
        storage_class                               = "STANDARD_IA"
      }
    }
  }
}

resource "aws_s3_bucket" "pritunl_destination" {
  provider                                          = aws.west
  bucket                                            = "${var.pritunl_bucket_prefix}-us-west-2"
  region                                            = "us-west-2"

  versioning {
    enabled                                         = true
  }
}
