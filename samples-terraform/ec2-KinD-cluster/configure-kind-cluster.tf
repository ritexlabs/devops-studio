
resource "null_resource" "upload_and_run_script" {
  depends_on = [module.ec2_instance]

  # Upload scripts folder recursively
  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/tmp/scripts"
  }

  # Upload configs folder recursively (optional)
  provisioner "file" {
    source      = "${path.module}/configs"
    destination = "/tmp/configs"
  }

  # Execute all *.sh in order
  provisioner "remote-exec" {
    inline = [
      # Move configs
      "sudo mkdir -p /home/ubuntu/configs",
      "sudo mv /tmp/configs/* /home/ubuntu/configs/",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/configs",

      # Make scripts executable and run them
      "sudo chmod -R +x /tmp/scripts",
      "ls -1 /tmp/scripts/*.sh | sort | while read f; do echo \"Running $f\"; sudo \"$f\"; done",         

      # Create KinD cluster with sudo
      "sudo kind create cluster --config=/home/ubuntu/configs/kind-config.yml",
      
      # Copy kubeconfig to ubuntu user
      "mkdir -p ~/.kube",
      "sudo cp /root/.kube/config /home/ubuntu/.kube/config",
      "sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config",
      
      # Export KUBECONFIG for current session
      "export KUBECONFIG=/home/ubuntu/.kube/config",
      
      # Validate cluster
      "kubectl cluster-info --context kind-kind",
      "kubectl get nodes",
      "sudo docker ps",
      "kubectl get pods -A",

      # Deploy Kubernetes Dashboard      
      "kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml",
      "kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{\"spec\": {\"type\": \"NodePort\", \"ports\": [{\"port\": 443, \"targetPort\": 8443, \"nodePort\": 32000}]}}'",

      # Deploy Kubernetes Dashboard Admin User
      "kubectl create -f /home/ubuntu/configs/dashboard-adminuser.yml",
      "kubectl -n kubernetes-dashboard create token admin-user >> /home/ubuntu/configs/admin-user-token"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu" # For Ubuntu AMIs
    private_key = file("~/${var.key_pair_name}.pem")
    host        = module.ec2_instance.public_ip
  }
}
