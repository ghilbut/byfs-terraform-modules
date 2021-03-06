##--------------------------------------------------------------
##  Docker-Registry

resource aws_s3_bucket docker {
  bucket = "${var.unique_name}-docker-registry"
  acl    = "private"

  tags = {
    Name = "Docker Registry"
  }
}

resource aws_iam_user docker {
  name = "${var.unique_name}-docker-registry"
}

resource aws_iam_access_key docker {
  user = aws_iam_user.docker.name
}

resource aws_iam_user_policy docker {
  name = "${var.unique_name}-docker-registry"
  user = aws_iam_user.docker.name

  policy = <<-EOP
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect":"Allow",
          "Action":[
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:ListBucketMultipartUploads"
          ],
          "Resource": "${aws_s3_bucket.docker.arn}"
        },
        {
          "Effect":"Allow",
          "Action":[
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:ListMultipartUploadParts",
            "s3:AbortMultipartUpload"
          ],
          "Resource": "${aws_s3_bucket.docker.arn}/*"
        }
      ]
    }
  EOP
}
