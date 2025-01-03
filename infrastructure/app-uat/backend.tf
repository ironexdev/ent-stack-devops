terraform {
  cloud {
    organization = "ent-organization"

    workspaces {
      name = "ent-app-uat"
    }
  }
}