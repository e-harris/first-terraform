# Terraform

Terraform is a orchestration tool, that is part of IaS, Infrastructure as Code.

Where Chef and Packer sit more on the **configuaration** management side and create imutable AMIs.

Terraform **orchestrates** the creation of networks and complex systems and deploys the AMI, making an EC2 instance.

An AMI is a blue print (snapshot) of an instance:
- the operating system
- data and storage
- all the packages and exact state of a machine when AMI was created

#### This Terraform

This terraform uses an AMI that contains the Sparta Node Sample App.

We have used modules to improve our separation of concerns.

A separate module for the App has been used along with the Database having its own module.


**To create the AMI:**

Clone or download this repo:
```
https://github.com/e-harris/NodeCookbook.git
git@github.com:e-harris/NodeCookbook.git
```

Then in the root directory run:

`berks vendor` - This downloads the dependencies of the cookbook for packer to run.

`packer validate packer.json` - This ensures that the packer.json file is ready to run.

`packer build packer.json` - Creates the AMI


**Terraforming**

Once you have your AMI id, you can now change all the variables inside variables.tf to suit your needs.
You should also change the Key/Value pairs that apply to your needs.

Once this is done, run:

`terraform plan` - This will tell you all the changes terraform needs to make from the previous apply.

If you are happy with these changes, run:

`terraform apply` - This creates the EC2 instance using the specified AMI and runs any provisioners. It does require permission to run incase you destroy or replace an instance you are currently using.
