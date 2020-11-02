locals {
  dashboard_host2          = "k8s.${var.domain_name}"
  kube_dashboard_namespace = "kube-dashboard"
}

resource kubernetes_namespace kube_dashboard {
  metadata {
    name = local.kube_dashboard_namespace
  }
}

resource null_resource kube_dashboard {
  depends_on = [
    null_resource.argo,
    kubernetes_namespace.kube_dashboard,
  ]
  triggers = {
    kubeconfig = var.kubeconfig_path
    sync = data.template_file.kube_dashboard.rendered
  }

  provisioner local-exec {
    command = self.triggers.sync
    environment = {
      METHOD = "apply"
    }
  }

  provisioner local-exec {
    when    = destroy
    command = self.triggers.sync
    environment = {
      METHOD = "delete"
    }
  }
}

data template_file kube_dashboard {
  ## https://argoproj.github.io/argo-cd/operator-manual/application.yaml
  template = <<-EOT
    kubectl --kubeconfig ${var.kubeconfig_path} $METHOD -f - <<EOF
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: kube-dashboard
      namespace: ${local.argo_namespace}
    spec:
      project: default
      source:
        repoURL: ${var.helmchart_url}
        targetRevision: ${var.helmchart_rev}
        path: k3s-basecamp/k8s-apps/helm/kube-dashboard
        helm:
          parameters:
          - name:  dashboard.ingress.hosts[0]
            value: ${local.dashboard_host2}
          #- name:  dashboard.ingress.tls[0].hosts[0]
          #  value: ${local.dashboard_host2}
          - name:  oauth2-proxy.extraEnv[0].value
            value: ${var.github_org}
          - name:  oauth2-proxy.ingress.hosts[0]
            value: ${local.dashboard_host2}
          - name:  oauth2-proxy.ingress.tls[0].hosts[0]
            value: ${local.dashboard_host2}
          valueFiles:
          - values.yaml
          version: v2
      destination:
        server: https://kubernetes.default.svc
        namespace: ${kubernetes_namespace.kube_dashboard.metadata[0].name}
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - Validate=true
        - CreateNamespace=true
    EOF
  EOT
}


################################################################
##
##  Kubernetes Secret
##

resource random_string kube_dashboard_oauth2_cookie_secret {
  length = 32
  upper = false
  special = false
}

resource kubernetes_secret kube_dashboard_oauth2 {
  metadata {
    name = "kube-dashboard-oauth2-secret"
    namespace = kubernetes_namespace.kube_dashboard.metadata[0].name
  }

  data = {
    client-id = var.kibana_github_client.id
    client-secret = var.kibana_github_client.secret
    cookie-secret = random_string.kube_dashboard_oauth2_cookie_secret.result
  }
}
