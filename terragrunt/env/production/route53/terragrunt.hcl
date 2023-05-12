terraform {
  source = "../../../aws//route53"
}

include {
  path = find_in_parent_folders()
}
