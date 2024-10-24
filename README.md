Hi, this project let's you get started with using AWS Role Anywhere authentication without creating a pricey ACM PCA. Please ensure you setup your aws provider accordingly before starting. 

Feel free to fork and tailor this configuration to your hearts content, preface; rolling your own CA on your local machine for production applications is probably not the best idea. 

The terraform will create a CA Key and self signed certificate this is what we give to the trust anchor in IAM. Then we also create a server key and certificate this is what we'll use to get some credentials. 

You'll need to grab the aws_signing_helper from https://github.com/aws/rolesanywhere-credential-helper
  - git clone ^^^ 
  - run `make release` 
  - move the binary into this path 

terraform apply 
source ./command.sh 

Use your aws creds :)
