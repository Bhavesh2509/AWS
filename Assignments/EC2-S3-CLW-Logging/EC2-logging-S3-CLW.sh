#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -e

REGION=us-east-1
CONFIG_BUCKET=bhavesh-config-$(date +%s)
LOG_BUCKET=bhavesh-logs-$(date +%s)


dnf update -y
dnf install -y docker awscli amazon-cloudwatch-agent

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

aws s3api create-bucket --bucket $CONFIG_BUCKET --region $REGION
aws s3api create-bucket --bucket $LOG_BUCKET --region $REGION

cat <<EOF > /tmp/s3-log-policy.json
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "logs.$REGION.amazonaws.com"
   },
   "Action": [
    "s3:PutObject",
    "s3:GetBucketAcl"
   ],
   "Resource": [
     "arn:aws:s3:::$LOG_BUCKET",
     "arn:aws:s3:::$LOG_BUCKET/*"
   ]
  }
 ]
}
EOF

aws s3api put-bucket-policy \
--bucket $LOG_BUCKET \
--policy file:///tmp/s3-log-policy.json

cat <<EOF > /tmp/index.html
<html>
<head>
<title>Bhavesh DevOps Project</title>
</head>
<body style="background:black;color:white;text-align:center;margin-top:100px;">
<h1>🚀 Containerized Web App Running on EC2</h1>
<h2>Logs → CloudWatch → S3</h2>
<p>DevOps Monitoring Pipeline</p>
</body>
</html>
EOF

aws s3 cp /tmp/index.html s3://$CONFIG_BUCKET/config/index.html

mkdir -p /home/ec2-user/nginx

aws s3 cp \
s3://$CONFIG_BUCKET/config/index.html \
/home/ec2-user/nginx/index.html

docker pull nginx

docker run -d \
--name nginx-webapp \
--restart always \
-p 80:80 \
-v /home/ec2-user/nginx/index.html:/usr/share/nginx/html/index.html \
nginx

aws logs create-log-group \
--log-group-name docker-nginx-logs \
--region $REGION || true

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
 "logs": {
  "logs_collected": {
   "files": {
    "collect_list": [
     {
      "file_path": "/var/lib/docker/containers/*/*.log",
      "log_group_name": "docker-nginx-logs",
      "log_stream_name": "{instance_id}"
     }
    ]
   }
  }
 }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
-s

sleep 180

aws logs create-export-task \
--task-name nginx-logs-to-s3 \
--log-group-name docker-nginx-logs \
--from 0 \
--to $(date +%s)000 \
--destination $LOG_BUCKET \
--destination-prefix nginx-logs || true

cat <<EOF > /tmp/lifecycle.json
{
 "Rules": [
  {
   "ID": "DeleteLogsAfter90Days",
   "Status": "Enabled",
   "Filter": {},
   "Expiration": { "Days": 90 }
  }
 ]
}
EOF

aws s3api put-bucket-lifecycle-configuration \
--bucket $LOG_BUCKET \
--lifecycle-configuration file:///tmp/lifecycle.json

echo "Setup Complete: EC2 → Docker → CloudWatch → S3"
