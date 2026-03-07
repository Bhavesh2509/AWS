# Architecture Notes

The pipeline consists of:
1. **EC2 Instance** running Docker.
2. **Nginx Container** serving a custom HTML page.
3. **CloudWatch Agent** collecting container logs.
4. **CloudWatch Logs** storing logs centrally.
5. **Export Task** moving logs into S3.
6. **S3 Lifecycle Policy** expiring logs after 90 days.

This ensures monitoring + archival in a fully automated way.
