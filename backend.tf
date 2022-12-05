terraform{
    backend "s3"{
        bucket = "terraform-state-bootcamp-fd"
        key = "terraform-state-osticket-bootcamp-fd.tfstate"
        region = "us-east-1"
    }
}