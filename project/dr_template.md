# Infrastructure

## AWS Zones
Identify your zones here
zone1: us-east-2 ["us-east-2a","us-east-2b","us-east-2c"],
zone2: us-west-1 ["us-west-1a","us-west-1b"]
## Servers and Clusters

### Table 1.1 Summary
| Asset        | Purpose                                                                                                               | Size                                                                   | Qty                                                             | DR                                                                                                           |
|--------------|-----------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|-----------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| Asset name   | Brief description                                                                                                     | AWS size eg. t3.micro (if applicable, not all assets will have a size) | Number of nodes/replicas or just how many of a particular asset | Identify if this asset is deployed to DR, replicated, created in multiple locations or just stored elsewhere |
| EC2 instance | enables you to scale up or down to handle changes in requirements                                                     | t3.micro                                                               | 3                                                               | it is specified in both east and west lcations to implement DR                                               |
| RDS          | provides a selection of instance types optimized to fit different relational database use cases                       | db.t2.small                                                            | 2(reader and writer instance perzone)                           | rds primary and rds secondary will be DR                                                                     |
| EKS cluster  | to run Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane or nodes | 2 nodes                                                                | 1                                                               | In bot us-east and us-west-1                                                                                 |
| EKS nodes    |  Amazon EC2 Auto Scaling group and associated Amazon EC2 instances that are managed by AWS for an Amazon EKS cluster  | t3.meduim                                                              | 2 nodes per cluster                                             | In both the regions                                                                                          |
| VPC          | enables you to launch AWS resources into a virtual network that you've defined                                        | CIDR range                                                             | multiple vpc across azs                                         | If one vpc craashes so that traffic changes to other ones                                                    |
| ALBs         | route and load balance gRPC traffic between microservices or between gRPC enabled clients and services                | no particular size                                                     | 1(grafana)                                                      | in both us-east-1 and west-1 regions                                                                         |


### Descriptions
More detailed descriptions of each asset identified above.
EC2 instane:
   An Amazon EC2 instance is a virtual server in Amazon's Elastic Compute Cloud (EC2) for running applications on the Amazon Web Services (AWS) infrastructure.
VPC:
   Amazon Virtual Private Cloud (Amazon VPC) enables you to launch AWS resources into a virtual network that you've defined. This virtual network closely resembles a traditional network that you'd operate in your own data center, with the benefits of using the scalable infrastructure of AWS.
EKS Node Groups:
   With Amazon EKS managed node groups, you don’t need to separately provision or register the Amazon EC2 instances that provide compute capacity to run your Kubernetes applications. You can create, automatically update, or terminate nodes for your cluster with a single operation.
Key Pairs:
   A key pair, consisting of a public key and a private key, is a set of security credentials that you use to prove your identity when connecting to an Amazon EC2 instance. Amazon EC2 stores the public key on your instance, and you store the private key.
AWS AMI images:
   An Amazon Machine Image (AMI) is a supported and maintained image provided by AWS that provides the information required to launch an instance. You must specify an AMI when you launch an instance. You can launch multiple instances from a single AMI when you require multiple instances with the same configuration.
Elastic Load Balancers:
   Elastic Load Balancing automatically distributes your incoming traffic across multiple targets, such as EC2 instances, containers, and IP addresses, in one or more Availability Zones. It monitors the health of its registered targets, and routes traffic only to the healthy targets. Elastic Load Balancing scales your load balancer capacity automatically in response to changes in incoming traffic.

## DR Plan
### Pre-Steps:
List steps you would perform to setup the infrastructure in the other region. It doesn't have to be super detailed, but high-level should suffice.

1. Ensure both sites are configured the same.
2. You can use infrastructure as code (IaC) to do this.
3. Ensure the infrastructure is set up and working in the DR site.


## Steps:
You won't actually perform these steps, but write out what you would do to "fail-over" your application and database cluster to the other region. Think about all the pieces that were setup and how you would use those in the other region

1. Point your DNS to your secondary region
      This can be done with a name provider like Amazon route 53
2. Failover your database replication instances to another region
      Manually force the secondary region to become primary at the database level, or
      Automatically failover the database by health checks
Steps:
   1) Create a cloud load balancer and point DNS to the load balancer. This way you can have multiple instances behind 1 IP in a region. During a failover scenario, you would fail over the single DNS entry at your DNS provider to point to the DR site. This is much more intelligent than pointing to a single instance of a web server.
   2) Have a replicated database and perform a failover on the database. While a backup is good and necessary, it is time-consuming to restore from backup. In this DR step, you would have already configured replication and would perform the database failover. Ideally, your application would be using a generic CNAME DNS record and would just connect to the DR instance of the database.


Detailed view:
  You can copy and paste all from the zone1 folder into your zone2 folder and modify as needed. You'll then deploy this to zone2 using Terraform. A few areas to keep in mind:

You'll need to modify the aws provider to point to another zone
You'll need to provision an S3 bucket in us-west-1 AND point your Terraform bucket to us-west-1
You'll modify the VPC module in the main.tf file with the appropriate availability zones. Keep in mind you'll need to look up what zones are valid for us-west-1.
You'll need to look up the AWS documentation for this. Or use this command from AWS Cloudshell and note the ZoneName in the output: ec2 describe-availability-zones --region us-west-1
Modify your region local variable in main.tf to point to us-west-1
Modify your aws_ami value in your ec2.tf file under your zone2 folder.


You will need to modify the rds-p and rds-s modules and add the appropriate availability zones for the databases. You'll need to look these up.
You will need to modify the rds-s module to add the appropriate Terraform bits to add it as a target for rds-p zone. Please see the Terraform registry documentation here
You will need to add the appropriate availability zones for the vpc and vpc_west modules in main.tf
You will need to add the Terraform provider block we discussed in the main.tf and rds.tf file in the root folder to tell Terraform to deploy the VPC and RDS cluster in the usw1 region 