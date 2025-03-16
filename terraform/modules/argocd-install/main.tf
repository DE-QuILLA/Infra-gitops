# provider "helm" {
#   kubernetes {
#     host                   = google_container_cluster.primary.endpoint
#     token                  = data.google_client_config.default.access_token
#     cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
#   }
# }

# resource "helm_release" "argocd" {
#   name       = "argocd"
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"
#   namespace  = "argocd"
#   version    = "5.17.0"

#   create_namespace = true

#   values = [
#     file("${path.module}/values.yaml")
#   ]
# }

# resource "kubernetes_manifest" "argocd_root_app" {
#   manifest = yamldecode(file("${path.module}/root-app.yaml"))
# }
