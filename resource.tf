resource "aws_iam_role_policy" "otterize_visibility_integration_role_inline_policy" {
  name = "otterize-${var.external_id}-EksViewOnlyAccess"
  role = aws_iam_role.otterize_visibility_integration_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:ListClusters", "eks:DescribeCluster"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "otterize_visibility_integration_role" {
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::353146681200:root"
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {
            "StringEquals" : {
              "sts:ExternalId" : var.external_id
            }
          }
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::353146681200:root"
          },
          "Action" : ["sts:SetSourceIdentity", "sts:TagSession"]
        }
      ]
  })
  path = "/"
  name = "otterize-${var.external_id}-VisibilityCollectorRole"
  tags = {
    "otterize/system" = "true"
  }
}

resource "aws_iam_role_policy_attachment" "visibility_role_viewonly_policy_attachment" {
  role       = aws_iam_role.otterize_visibility_integration_role.name
  policy_arn = data.aws_iam_policy.ViewOnlyAccess.arn
}

resource "aws_iam_role_policy_attachment" "visibility_role_ec2_readonly_policy_attachment" {
  role       = aws_iam_role.otterize_visibility_integration_role.name
  policy_arn = data.aws_iam_policy.EC2ReadOnlyAccess.arn
}