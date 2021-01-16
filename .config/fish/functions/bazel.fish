function bazel
    if command -qs pyenv
        pyenv shell bazel-py3 bazel-py3-beta bazel-py2
    end

    command bazel $argv
    set bazel_status $status

    if command -qs pyenv
        pyenv shell -
    end

    return $bazel_status
end
