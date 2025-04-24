load("@bazel_gazelle//:def.bzl", "gazelle")
load("@fhir_npm//:defs.bzl", "npm_link_all_packages")

exports_files(["LICENSE"])

gazelle(
    name = "gazelle",
    prefix = "github.com/google/fhir/go",
)

npm_link_all_packages(name = "node_modules")
