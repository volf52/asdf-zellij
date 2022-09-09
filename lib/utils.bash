#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/zellij-org/zellij"
TOOL_NAME="zellij"
TOOL_TEST="zellij --version"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

# Will be active only in CI
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//'
}

list_all_versions() {
  list_github_tags
}

get_latest_version() {
  local latest_version
  echo "Checking latest version for zellij..." >&2

  latest_version=$(curl -L --silent "${curl_opts[@]}" "https://api.github.com/repos/zellij-org/zellij/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/')
  echo "Latest version for zellij is $latest_version" >&2

  echo "$latest_version"
}

download_release() {
  local version filename url
  version="$1"
  filename="$2"

  if [ "$version" = "latest" ]; then
    version=$(get_latest_version)
  else
    version="v$version"
  fi

  url="$GH_REPO/releases/download/${version}/${filename}"

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$release_file" -C - "$url" || fail "Could not download $url"
}

get_arch() {
  arch=$(uname -m | tr '[:upper:]' '[:lower:]')

  case "$arch" in
  arm64)
    arch=aarch64
    ;;
  x86_64) ;;
  *) fail "Platform $arch not supported for Zellij" ;;
  esac

  echo "$arch"
}

get_platform() {
  plat=$(uname | tr '[:upper:]' '[:lower:]')

  case $plat in
  darwin)
    plat='apple-darwin'
    ;;
  linux)
    plat='unknown-linux-musl'
    ;;
    # windows)
    # plat='pc-windows-msvc'
    # ;;
  *)
    fail "Zellij not supported on Windows"
    ;;
  esac

  echo "$plat"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}/bin"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  arch="$(get_arch)"
  platform="$(get_platform)"
  local release_file="zellij-$arch-$platform.tar.gz"

  (
    mkdir -p "$install_path"
    # cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"
    download_release "$version" "$release_file"
    tar -xzf "$release_file" -C "$install_path" || fail Could not extract "$release_file"
    rm "$release_file"

    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
