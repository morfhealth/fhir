"""Proto related build rules for fhir.
"""

load("@io_bazel_rules_go//proto:def.bzl", "go_proto_library")
load("@aspect_rules_js//js:defs.bzl", "js_library")
load("@com_github_buildbuddy_io_protoc_gen_protobufjs//:rules.bzl", "protoc_gen_protobufjs")
load("@com_github_buildbuddy_io_protoc_gen_protobufjs_2//:rules.bzl", "protoc_gen_protobufjs_2")
load("@com_google_protobuf//bazel:cc_proto_library.bzl", "cc_proto_library")
load("@rules_proto//proto:defs.bzl", "proto_library")

WELL_KNOWN_PROTOS = [
    "descriptor_proto",
    "any_proto",
    "empty_proto",
    "struct_proto",
]

GO_WELL_KNOWN_PROTOS = {
    "descriptor_proto": "@org_golang_google_protobuf//types/descriptorpb:go_default_library",
    "any_proto": "@org_golang_google_protobuf//types/known/anypb:go_default_library",
    "empty_proto": "@org_golang_google_protobuf//types/known/emptypb:go_default_library",
    "struct_proto": "@org_golang_google_protobuf//types/known/structpb:go_default_library",
}

TS_WELL_KNOWN_PROTOS = {
    "descriptor_proto": "//proto:descriptor_ts_proto",
    "any_proto": "//proto:any_ts_proto",
    "empty_proto": "//proto:empty_ts_proto",
    "struct_proto": "//proto:struct_ts_proto",
}

TS_WELL_KNOWN_PROTOS_2 = {
    "descriptor_proto": "//proto:descriptor_ts_proto_v2",
    "any_proto": "//proto:any_ts_proto_v2",
    "empty_proto": "//proto:empty_ts_proto_v2",
    "struct_proto": "//proto:struct_ts_proto_v2",
}

def fhir_wrapped_ts_proto_library(name, proto, deps = [], **kwargs):
    """Generates .js and .d.ts files from a proto_library target.

    Args:
        name: name of generated js_library target, also used to name the .js/.d.ts output
        proto: label of a single proto_library target to generate code for
        deps: deps for *directly* imported protos only; must be other ts_proto_library targets
        **kwargs: passed through to the underlying rules
    """

    protoc_gen_protobufjs(
        name = name + "__gen_protobufjs",
        out = name,
        proto = proto,
        deps = [dep + "__gen_protobufjs" for dep in deps],
        **kwargs
    )

    js_library(
        name = name,
        srcs = [":" + name + "__gen_protobufjs"],
        deps = [
            "//:node_modules/@types/long",
            "//:node_modules/@types/protobufjs",
            "//:node_modules/long",
            "//:node_modules/protobufjs",
        ] + deps,
        **kwargs
    )

def fhir_wrapped_ts_proto_library_2(name, proto, deps = [], **kwargs):
    """Generates .js and .d.ts files from a proto_library target.

    Args:
        name: name of generated js_library target, also used to name the .js/.d.ts output
        proto: label of a single proto_library target to generate code for
        deps: deps for *directly* imported protos only; must be other ts_proto_library targets
        **kwargs: passed through to the underlying rules
    """

    protoc_gen_protobufjs_2(
        name = name + "__gen_protobufjs_2",
        out = name,
        proto = proto,
        deps = [dep + "__gen_protobufjs_2" for dep in deps],
        **kwargs
    )

    js_library(
        name = name,
        srcs = [":" + name + "__gen_protobufjs_2"],
        deps = [
            "//:node_modules/@types/long",
            "//:node_modules/@types/protobufjs",
            "//:node_modules/long",
            "//:node_modules/protobufjs",
        ] + deps,
        **kwargs
    )

def fhir_proto_library(proto_library_prefix, srcs = [], proto_deps = [], **kwargs):
    """Generates proto_library target, as well as {cc,java,go}_proto_library targets.

    Args:
      proto_library_prefix: Name prefix to be added to various proto libraries.
      srcs: Srcs for the proto library.
      proto_deps: Deps by the proto_library.
      **kwargs: varargs. Passed through to proto rules.
    """
    ts_deps = []
    ts_deps_2 = []
    cc_deps = []
    go_deps = []
    has_well_known_dep = False
    for x in proto_deps:
        tokens = x.split(":")
        if len(tokens) == 2 and tokens[1] in WELL_KNOWN_PROTOS:
            go_deps.append(GO_WELL_KNOWN_PROTOS[tokens[1]])
            ts_deps.append(TS_WELL_KNOWN_PROTOS[tokens[1]])
            ts_deps_2.append(TS_WELL_KNOWN_PROTOS_2[tokens[1]])
            if not has_well_known_dep:
                cc_deps.append(tokens[0] + ":cc_wkt_protos")
                has_well_known_dep = True
        elif x.endswith("_proto"):
            cc_deps.append(x[:-6] + "_cc_proto")
            go_deps.append(x[:-6] + "_go_proto")
            ts_deps.append(x[:-6] + "_ts_proto")
            ts_deps_2.append(x[:-6] + "_ts_proto_v2")

    proto_library(
        name = proto_library_prefix + "_proto",
        srcs = srcs,
        deps = proto_deps,
        **kwargs
    )

    fhir_wrapped_ts_proto_library(
        name = proto_library_prefix + "_ts_proto",
        proto = ":" + proto_library_prefix + "_proto",
        deps = ts_deps,
    )

    fhir_wrapped_ts_proto_library_2(
        name = proto_library_prefix + "_ts_proto_v2",
        proto = ":" + proto_library_prefix + "_proto",
        deps = ts_deps_2,
    )

    cc_proto_library(
        name = proto_library_prefix + "_cc_proto",
        deps = [proto_library_prefix + "_proto"],
    )

    native.java_proto_library(
        name = proto_library_prefix + "_java_proto",
        deps = [
            ":" + proto_library_prefix + "_proto",
        ],
        **kwargs
    )

    importpath_prefix = "github.com/google/fhir/go/"
    if native.package_name().startswith("go/"):
        importpath_prefix = "github.com/google/fhir/"

    go_proto_library(
        name = proto_library_prefix + "_go_proto",
        deps = go_deps,
        proto = ":" + proto_library_prefix + "_proto",
        importpath = importpath_prefix + native.package_name() + "/" + proto_library_prefix + "_go_proto",
        **kwargs
    )

def _fhir_individual_resource_rules(resource_files, deps):
    for resource_file in resource_files:
        fhir_proto_library(
            srcs = [resource_file],
            proto_deps = deps,
            proto_library_prefix = resource_file[:-6],
        )

def fhir_resource_rules(resource_files, deps):
    resource_files.remove("bundle_and_contained_resource.proto")

    _fhir_individual_resource_rules(resource_files, deps)

    resources_as_dep = [":" + file[:-6] + "_proto" for file in resource_files]

    fhir_proto_library(
        srcs = ["bundle_and_contained_resource.proto"],
        proto_deps = deps + resources_as_dep,
        proto_library_prefix = "bundle_and_contained_resource",
    )

def fhir_profile_rules(resource_files, deps):
    _fhir_individual_resource_rules(resource_files, deps)
