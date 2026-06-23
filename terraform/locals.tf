locals {
  frontend_domain = var.frontend_subdomain == "" ? var.domain_name : "${var.frontend_subdomain}.${var.domain_name}"

  # www is only added automatically when serving from the bare apex.
  frontend_aliases = (
    local.frontend_domain == var.domain_name && var.include_www
    ? [var.domain_name, "www.${var.domain_name}"]
    : [local.frontend_domain]
  )

  cors_origin = join(",", [for a in local.frontend_aliases : "https://${a}"])
}
