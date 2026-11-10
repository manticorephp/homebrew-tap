# manticorephp/homebrew-tap

```bash
brew install manticorephp/tap/manticore
```

macOS arm64 (15+). The formula installs the published build of [Manticore](https://github.com/manticorephp/compiler) with `openssl@4`, `pcre2`, `icu4c` and `pkgconf`. A scheduled workflow here (every 6 h, or `gh workflow run bump -R manticorephp/homebrew-tap`) points it at the latest release. Linux: use `install.sh` or the container image.
