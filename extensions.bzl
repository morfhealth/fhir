load("//:workspace_deps.bzl", "workspace_dependencies")

def _non_module_dependencies_impl(_ctx):
    workspace_dependencies()

non_module_dependencies = module_extension(
    implementation = _non_module_dependencies_impl,
)
