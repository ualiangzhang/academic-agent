import * as cdk from "aws-cdk-lib";
import { UploadBucketStack } from "../lib/upload-bucket-stack";

const app = new cdk.App();
new UploadBucketStack(app, "AcademicAgentUploadBucket", {
  env: { account: process.env.CDK_DEFAULT_ACCOUNT, region: process.env.CDK_DEFAULT_REGION }
});
