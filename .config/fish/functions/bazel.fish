function bazel
    if command -qs pyenv
        pyenv shell bazel-py3 bazel-py3-beta bazel-py2
    end

    command bazel $argv

    if command -qs pyenv
        pyenv shell -
    end
end
