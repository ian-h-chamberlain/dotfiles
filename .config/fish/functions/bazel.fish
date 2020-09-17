function bazel
    pyenv shell bazel-py3 bazel-py3-beta bazel-py2
    command bazel $argv
    pyenv shell -
end
