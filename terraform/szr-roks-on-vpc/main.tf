data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.token}-${var.cos_service_name}"
  service           = "cloud-object-storage"
  plan              = var.cos_service_plan
  resource_group_id = data.ibm_resource_group.resource_group.id
  location          = "global"
  depends_on        = [data.ibm_resource_group.resource_group]
}

resource "random_id" "name1" {
  byte_length = 2
}

resource "random_id" "name2" {
  byte_length = 2
}

resource "random_id" "name3" {
  byte_length = 2
}

locals {
  ZONE1 = "${var.region}-1"
  ZONE2 = "${var.region}-2"
  ZONE3 = "${var.region}-3"
}

resource "ibm_is_vpc" "vpc1" {
  name = "vpc-${random_id.name1.hex}"
  resource_group = data.ibm_resource_group.resource_group.id
  classic_access = var.classic_access
}

resource "ibm_is_public_gateway" "testacc_gateway1" {
    name = "public-gateway1"
    vpc = ibm_is_vpc.vpc1.id
    zone = local.ZONE1
}

resource "ibm_is_public_gateway" "testacc_gateway2" {
    name = "public-gateway2"
    vpc = ibm_is_vpc.vpc1.id
    zone = local.ZONE2
}

resource "ibm_is_public_gateway" "testacc_gateway3" {
    name = "public-gateway3"
    vpc = ibm_is_vpc.vpc1.id
    zone = local.ZONE3
}

resource "ibm_is_subnet" "subnet1" {
  name                     = "subnet-${random_id.name1.hex}"
  vpc                      = ibm_is_vpc.vpc1.id
  zone                     = local.ZONE1
  total_ipv4_address_count = 256
  resource_group           = data.ibm_resource_group.resource_group.id
  public_gateway           = ibm_is_public_gateway.testacc_gateway1.id
}

resource "ibm_is_subnet" "subnet2" {
  name                     = "subnet-${random_id.name2.hex}"
  vpc                      = ibm_is_vpc.vpc1.id
  zone                     = local.ZONE2
  total_ipv4_address_count = 256
  resource_group           = data.ibm_resource_group.resource_group.id
  public_gateway           = ibm_is_public_gateway.testacc_gateway2.id
}

resource "ibm_is_subnet" "subnet3" {
  name                     = "subnet-${random_id.name3.hex}"
  vpc                      = ibm_is_vpc.vpc1.id
  zone                     = local.ZONE3
  total_ipv4_address_count = 256
  resource_group           = data.ibm_resource_group.resource_group.id
  public_gateway           = ibm_is_public_gateway.testacc_gateway3.id
}

resource "ibm_container_vpc_cluster" "cluster" {
  name                 = "${var.cluster_name}-${random_id.name1.hex}"
  vpc_id               = ibm_is_vpc.vpc1.id
  kube_version         = var.cluster_kube_version
  flavor               = var.cluster_node_flavor
  worker_count         = var.worker_count
  resource_group_id    = data.ibm_resource_group.resource_group.id
  entitlement          = var.entitlement
  cos_instance_crn     = ibm_resource_instance.cos_instance.id
  force_delete_storage = true
  wait_till            = "OneWorkerNodeReady"
  depends_on         = [ibm_is_subnet.subnet1]

  zones {
    subnet_id = ibm_is_subnet.subnet1.id
    name      = local.ZONE1
  }


}

