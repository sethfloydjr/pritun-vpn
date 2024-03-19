# Pritunl VPN

This project is pretty out of date. It was also originally created to run in GitLab CI/CD. Use and modify at your own risk.

### Pritunl VPN built in Terraform in its own VPC.

Pritunl Homepage: [https://pritunl.com/](https://pritunl.com/)

"Pritunl is the best open source alternative to proprietary commercial vpn products such as Aviatrix and Pulse Secure. Create larger cloud vpn networks supporting thousands of concurrent users and get more control over your vpn server without any per-user pricing"

Free Pritunl Client can be found here. I prefer it over Viscosity [https://client.pritunl.com/](https://client.pritunl.com/)

---

# OVERVIEW

This is a basic install of a VPC in AWS and an instance that sits in an ASG that runs Pritunl VPN behind a load balancer.

Pritunl documentation can be found here: [https://docs.pritunl.com/docs](https://docs.pritunl.com/docs)

The general idea is that the instance is spun up and by using the user_data the install and backup scripts are created. Pritunl uses MongoDB to store the data for the vpn so a cron job runs hourly that backs up the mongodb files to the S3 bucket that is created. If the instance goes down the data is pulled out of the bucket and loaded as part of the install script.

---

# VARIABLES

You can add the AWS keys to the project Environment variables by going to `YourProject > Settings> CI/CD > Variables`. From here you will want to add the following for this project:
* `TF_VAR_AWS_ACCESS_KEY_ID`
* `TF_VAR_AWS_SECRET_ACCESS_KEY`
* `TERRAFORM_VERSION`
* You will also want to check variables that are supplied in the `pritunl-vpn.tf` file.

You put `TF_VAR_` on the front of any variables that Terraform will need to pass into the stack. `TERRAFORM_VERSION` is only used in the Gitlab CI file so no `TF_VAR_` needed

---

# INSTALL AND BACKUP SCRIPT
* Located at `pritunl-vpn/pritunl-instance.tpl` Comments are in-line and echo out what is happening. You can follow along by looking at the live system log that you can access through the AWS Console > EC2 > right click instance > System Log
* MongoDB version 4.2 - Look here for the latest version to use with Pritunl: [https://repo.mongodb.org/yum/amazon/2/mongodb-org](https://repo.mongodb.org/yum/amazon/2/mongodb-org) You can set this as a variable in `pritunl-vpn.tf`

---

# FILES TO EDIT
* `backend-state.tf` - Pretty obvious if you look at it.
* `outputs.tf` - Replace all of the `VPC_PRITUNL` entries with the name of your VPC that you also put in `vpc.tf` Should be an easy copy and replace.
* `variables.tf` - Main setting for REGION is found here.
* `vpc.tf` - Be sure to change the options with comments
* `gitlab-ci.yml` - Rename this file to `.gitlab-ci.yml`. I added a DESTROY option at the end of the pipeline. If you plan on using this in any sort of "production" environment where you dont want anyone to accidentally rip the VPC out from under your stuff...delete this section. Dont just comment it out, DELETE it.

---

# ACM CERT
* A cert is needed for the ALB. The easiest way to do this is through Terraform using ACM. You will need to either create a cert through Terraform or import a cert into AWS and add its arn. If you wish to create the cert yourself refer to this URL for more info. It is out of the scope of this project.
* A starting point for you can be found in ACM.tf. Refer to this page for further help:[https://www.terraform.io/docs/providers/aws/r/acm_certificate_validation.html](https://www.terraform.io/docs/providers/aws/r/acm_certificate_validation.html)
The var for the Cert ARN needs to be added in the pritunl-vpn.tf file.

---

# DEPLOYING
* Gitlab will run the Init and Plan pipelines on push to a branch. Once this passes and you merge to master you will be able to see the Init and Plan pipelines run again. Once the Plan job is done you will need to manually run the Apply job. Gitlab offers you a chance to supply some variables here before you run the job but you wont need to do this for this project.
* A couple of things to remember...since you are creating a new Route53 Zone Record its will take time before the new DNS entry for the Pritunl instance resolves to the ALB DNS entry. If you wanted you can go directly to the ALB DNS url to verify that the instance was setup...it generaly takes about 5-10 minutes depending on what configs you add on to what I have here in the install. Read the Docs at the link above for more about that.
* You will need to SSH into the instance and run the command to reset the admin password so you can get into the UI. This command is given if you go to the ALB DNS url.

---

# UPDATING
* If you can stand the 10-15 mins of down time you can SSH to the box and manually run the backup script. Then terminate the instance. After a few minutes the ASG will see that instance is missing and spin up a new one with the latest version of Pritunl installed.
* Another option would be to SSH in and manually run the backup script. Then up the count in the ASG to 2. Let the instance spin up and finish then scale the ASG back down to 1. The ASG will automatically kill off the oldest instance in the group.
* Depending on your configurations you will need to boot all the users off the old instance before the ASG will terminate it because of connection draining.

---

# DESTROY
* If you wish to destroy all of the resources found in this stack you will need to run the `BucketCleaner.py` script for each bucket (`pritunl-us-east-1` and `pritunl-us-west-2`) before you run the detroy pipeline.
