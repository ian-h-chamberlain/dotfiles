function rdbazel --wraps=bazel
    rdsh -- bazel $argv
end
