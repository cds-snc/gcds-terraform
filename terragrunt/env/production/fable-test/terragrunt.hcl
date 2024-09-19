terraform {
  source = "../../../aws//fable-test"
}

include {
  path = find_in_parent_folders()
}
