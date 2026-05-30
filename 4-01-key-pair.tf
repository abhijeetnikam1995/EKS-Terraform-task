resource "tls_private_key" "eks_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "eks_key" {
  key_name   = "eks-terraform-key"
  public_key = tls_private_key.eks_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.eks_key.private_key_pem
  filename        = "private-key/eks-terraform-key.pem"
  file_permission = "0400"

}
