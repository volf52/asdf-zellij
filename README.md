<div align="center">

# asdf-zellij [![Build](https://github.com/volf52/asdf-zellij/actions/workflows/build.yml/badge.svg)](https://github.com/volf52/asdf-zellij/actions/workflows/build.yml) [![Lint](https://github.com/volf52/asdf-zellij/actions/workflows/lint.yml/badge.svg)](https://github.com/volf52/asdf-zellij/actions/workflows/lint.yml)

[zellij](https://github.com/zellij-org/zellij) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities

# Install

Plugin:

```shell
asdf plugin add zellij

# or

asdf plugin add zellij https://github.com/volf52/asdf-zellij.git
```

zellij:

```shell
# Show all installable versions
asdf list-all zellij

# Install specific version
asdf install zellij latest

# Set a version globally (on your ~/.tool-versions file)
asdf global zellij latest

# Now zellij commands are available
zellij --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/volf52/asdf-zellij/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Arslan](https://github.com/volf52/)
