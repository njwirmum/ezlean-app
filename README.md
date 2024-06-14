# Valavaxyconsultancyapi

# Follow these steps to setup and deploy java app to k8s
Make sure you use the user-data.sh script when creating the jenkins master now. After the instance is up and running, run the folowing commands on ther terminal to confirm installation;

```bash
aws --version

kubectl version --client

eksctl version

eksctl version
```

# Step 1  Creating and Attaching an IAM Role to the Jenkins Instance
To attach an IAM role to an EC2 instance for EKS management:

Create the IAM Role:

Navigate to the IAM service in the AWS Management Console.
Create a new role and select AWS service as the type of trusted entity, choosing EC2 as the service that will use this role.

Attach policies that grant permissions needed to manage EKS. 
just give admin access 
Attach the Role to the EC2 Instance:
Go to the EC2 dashboard in the AWS Management Console.
Find the EC2 instance that you use as your management node.
Select the instance, then click on Actions > Security > Modify IAM role.
Select the IAM role you created from the drop-down menu and apply the changes.
Configuring the Instance
Once the IAM role is attached:

Any AWS CLI or SDK tool running on the instance will automatically use the credentials provided by the IAM role.
You won’t need to manually configure AWS credentials on the instance, enhancing security by not storing sensitive information on the instance.

# Now create the cluster with the following command

```bash
eksctl create cluster --name ezlearn-cluster --region us-east-1 --node-type t3.medium --nodes 2
```


First, ensure your EKS cluster is ready.







# Step 2: Configure Jenkins


Install Necessary Plugins:

Navigate to Manage Jenkins > Manage Plugins > Available and install these plugins:

Maven Integration plugin – for building Java applications.
Docker Pipeline – for Docker operations.
Kubernetes CLI Plugin – to interact with your Kubernetes cluster.

Configure Jenkins Tools:
Go to Manage Jenkins > Global Tool Configuration.
Select JDK and click to install automatically

Set up Maven, give it a name maven. do not select automatic install, just give the path of maven
maven path will be /opt/maven

Apply and save

# Step 3: Add Required Credentials in Jenkins
Add Credentials:
Go to Manage Jenkins > Manage Credentials > Jenkins > Global credentials (unrestricted) > Add Credentials.
Add credentials for Docker Hub, and a kubeconfig for Kubernetes:

Docker Hub credentials select Username and password, then input you actuall docker account user-name and password
give it any ID of your choice

Add credentials for kubernetes

Go to jenkins terminal and run the command 

```bash
sudo cat .kube/config
```
copy the out and save in your local computer with name config

Add Credentials:
Go to Manage Jenkins > Manage Credentials > Jenkins > Global credentials (unrestricted) > Add Credentials.
Add credentials for Kubernetes:

Select secret file, click browse and upload the config file you saved in your local pc


Assign any ID of your choice that you can refer to in your Jenkins jobs.

# Step 4: Create a Jenkins Job

Create a New Freestyle Project:

Go to Jenkins main dashboard.
Click New Item, select Freestyle project, and enter a name for the project.
Configure Source Code Management:
Select Git and enter the Repository URL 

In your job configuration, go to the Build Environment section.
Check the Use secret text(s) or file(s) option.
Add a new binding for each of the username and password:
Type: Secret text.
Variable: DOCKER_USERNAME for the username, DOCKER_PASSWORD for the password.
Credentials: Select the credentials you added previously.
These variables (DOCKER_USERNAME and DOCKER_PASSWORD) will now be available as environment variables in your build steps.

Add Build Steps:

Invoke top-level Maven targets: Set Goals as clean install to build your Java application.

Build / Publish Docker Image:

Use a shell step to log in to Docker, build the Docker image, and push it to Docker Hub.

```bash
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

docker build -t yourdockerhubuser/tomcatmavenapp:latest .

docker push yourdockerhubuser/tomcatmavenapp:latest 
```

# Deploy to Kubernetes:

Use another shell step to apply Kubernetes deployment manifests.

Go to your job configuration and scroll down to the Build Environment section.
Check the box Use secret text(s) or file(s).
Add a new Secret file binding:
Variable: Give it a name, like KUBECONFIG.
Credential: Select the kubeconfig credential you stored earlier.
This setup will expose the path to the kubeconfig file as an environment variable ($KUBECONFIG) within the job.

Use the $KUBECONFIG environment variable in your shell commands to reference the kubeconfig file:

```bash
kubectl --kubeconfig $KUBECONFIG apply -f deployment.yml
kubectl --kubeconfig $KUBECONFIG apply -f service.yml
```

# Run the Job:
Click Build Now to start the Jenkins job.
Verify Deployment:
Check the deployment in Jenkins console output.
Use kubectl commands to verify the deployment on your EKS cluster:

```bash
kubectl get deployments
kubectl get services
