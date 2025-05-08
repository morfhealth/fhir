load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

def workspace_dependencies():
    """External non-bazel dependencies"""

    http_file(
        name = "hl7.fhir.r4.core_4.0.1",
        downloaded_file_path = "hl7.fhir.r4.core@4.0.1.tgz",
        sha256 = "b090bf929e1f665cf2c91583720849695bc38d2892a7c5037c56cb00817fb091",
        url = "https://hl7.org/fhir/R4/hl7.fhir.r4.core.tgz",
    )

    http_file(
        name = "hl7.fhir.r5.core_5.0.0",
        downloaded_file_path = "hl7.fhir.r5.core@5.0.0.tgz",
        sha256 = "74b27cd1bfce9e80eaceac431edf230b0945a443564fbf5512f82e5fa50a80d4",
        url = "https://hl7.org/fhir/R5/hl7.fhir.r5.core.tgz",
    )

    http_archive(
        name = "com_github_buildbuddy_io_protoc_gen_protobufjs",
        sha256 = "c930a02ddf44d93a2c3caca4eda3c7029b2bebb2899f047cae36e81a724c343d",
        strip_prefix = "protoc-gen-protobufjs-0.0.3",
        urls = ["https://github.com/morfhealth/protoc-gen-protobufjs/archive/v0.0.3.tar.gz"],
    )

    http_archive(
        name = "com_github_buildbuddy_io_protoc_gen_protobufjs_2",
        sha256 = "c0eca85eef366a259d37cd4310dacc3d72b4eba54025c4a3a6473037c860f716",
        strip_prefix = "protoc-gen-protobufjs-0.0.9",
        urls = ["https://github.com/morfhealth/protoc-gen-protobufjs/archive/v0.0.9.tar.gz"],
    )
