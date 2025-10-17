import * as cdk from "aws-cdk-lib";
import { Bucket, BlockPublicAccess, BucketEncryption } from "aws-cdk-lib/aws-s3";
import { RemovalPolicy, Duration } from "aws-cdk-lib";

export class UploadBucketStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const bucket = new Bucket(this, "Uploads", {
      blockPublicAccess: BlockPublicAccess.BLOCK_ALL,
      encryption: BucketEncryption.S3_MANAGED,
      enforceSSL: true,
      versioned: false,
      removalPolicy: RemovalPolicy.DESTROY,
      autoDeleteObjects: true
    });

    bucket.addLifecycleRule({
      transitions: [{ storageClass: cdk.aws_s3.StorageClass.INTELLIGENT_TIERING, transitionAfter: Duration.days(30) }],
      expiredObjectDeleteMarker: true
    });

    new cdk.CfnOutput(this, "UploadBucketName", { value: bucket.bucketName });
  }
}
