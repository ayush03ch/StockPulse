$ErrorActionPreference = 'Stop'; $region = 'ap-south-1'; $account = aws sts get-caller-identity --query Account --output text; $bucket = "explo-capstone-$account-20260329"; $stream = 'clickstream'; $firehose = 'clickstream-to-s3'; $roleName = 'FirehoseToS3RoleExploCapstone'; $roleArn = "arn:aws:iam::$account:role/$roleName"; aws s3api create-bucket --bucket $bucket --region $region --create-bucket-configuration LocationConstraint=$region; aws s3api put-bucket-versioning --bucket $bucket --versioning-configuration Status=Enabled; aws kinesis create-stream --stream-name $stream --shard-count 1 --region $region; aws kinesis wait stream-exists --stream-name $stream --region $region; $trustPath = Join-Path $PWD 'firehose-trust-policy.json'; @'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
'@ | Set-Content -Path $trustPath -Encoding ASCII; aws iam create-role --role-name $roleName --assume-role-policy-document file://$trustPath; $policyPath = Join-Path $PWD 'firehose-access-policy.json'; $streamArn = "arn:aws:kinesis:$region:$account:stream/$stream"; @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords",
        "kinesis:ListShards",
        "kinesis:DescribeStreamSummary"
      ],
      "Resource": "$streamArn"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::$bucket",
        "arn:aws:s3:::$bucket/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
"@ | Set-Content -Path $policyPath -Encoding ASCII; aws iam put-role-policy --role-name $roleName --policy-name FirehoseAccessPolicyExploCapstone --policy-document file://$policyPath; Start-Sleep -Seconds 12; aws firehose create-delivery-stream --region $region --delivery-stream-name $firehose --delivery-stream-type KinesisStreamAsSource --kinesis-stream-source-configuration "RoleARN=$roleArn,KinesisStreamARN=$streamArn" --extended-s3-destination-configuration "RoleARN=$roleArn,BucketARN=arn:aws:s3:::$bucket,Prefix=clickstream/,ErrorOutputPrefix=errors/,BufferingHints={SizeInMBs=5,IntervalInSeconds=60},CompressionFormat=GZIP"; aws firehose wait delivery-stream-active --region $region --delivery-stream-name $firehose; "REGION=$region"; "BUCKET=$bucket"; "KINESIS_STREAM=$stream"; "FIREHOSE_STREAM=$firehose"; Remove-Item $trustPath -Force; Remove-Item $policyPath -Force