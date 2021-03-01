function pdb_bazel --wraps=bazel
    command cat | bazel run --test_output=streamed $argv[1..-1] -- -vvv -s --pdb
end
