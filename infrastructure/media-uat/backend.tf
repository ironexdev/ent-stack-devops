terraform {
  cloud {
    organization = "ent-organization"

    workspaces {
      name = "ent-media-uat"
    }
  }
}