# Arch Linux PKGBUILDs

- **`camlp5-lk`**: see `ocaml-lk`
- **`ffmpeg-lk`**: adds `--enable-libfdk-aac` and `--enable-nonfree`
- **`handbrake-lk`**: adds `--enable-fdk-aac`
- **`httptoolkit-lk`**: adds `electron<version>` to `depends` and removes large
  Electron binary
- **`lablgtk2-lk`**: see `ocaml-lk`
- **`nvm`**: applies a [patch][nvm-patch] required for some nvm-dependent
  packages to build
- **`ocaml-lk`**: builds OCaml 4.12.x for compatibility with Homebrew's `unison`
  package on macOS (Homebrew is not yet packaging OCaml 4.13.x 🙄)
- **`unison-lk`**: see `ocaml-lk`
- **`xfce4-power-manager-lk`**: applies a patch not yet upstreamed

[nvm-patch]: https://github.com/nvm-sh/nvm/pull/2698
