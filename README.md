# CadQuery and CQ-editor flake

## What is this

Concepts:

1. [nix package manager](https://nixos.org/guides/nix-pills/why-you-should-give-it-a-try.html) and [the NixOS Linux distribution](https://nixos.org/)
2. [nix flakes](https://www.tweag.io/blog/2020-05-25-flakes/)
3. [CadQuery and CQ-editor](https://cadquery.readthedocs.io/en/latest/intro.html)
4. [Cachix](https://docs.cachix.org/)

This repo is a nix flake that allows you to reproduce a CadQuery and CQ-editor installation anywhere that has nix. Well, a version of nix with flake support, which is currently only in unstable but should be merged soon. Also, it probably won't work outside of NixOS, because graphic drivers are super difficult to make reproducible. But anyway.

This means that you can create a model in CadQuery and note down the commit to this repo you used to build it (or fork it and take control yourself). At any point in the future you can use the same command to run CQ-editor and due to the flake describing all the sources of every package used by CQ-editor it will still work, regardless of:

* changes to the CadQuery API breaking backwards compatibility
* new Python versions
* nixpkgs dropping support for Sphinx ~~2.4~~ 3.0.2 or whatever other version it gets pinned to next
* etc., you get the idea, breaking changes anywhere in the chain of packages.

While nix is a source based package manager, I publish binaries to to [Cachix](https://docs.cachix.org/). This flake now includes the configuration required to automatically download binaries from my Cachix (thanks [thomaslepoix](https://github.com/thomaslepoix) and [EdenEast](https://github.com/EdenEast)).

Now also includes [cq-kit](https://github.com/michaelgale/cq-kit).

## Commands

To run CQ-editor:

```sh
nix run github:marcus7070/cq-flake
```

Note that I currently set `QT_QPA_PLATFORM=xcb` in the CQ-editor wrapper. I need to do this to get it to work under Wayland, and I think it should work for most X based window managers as well, but YMMV.

To create an environment with CadQuery and python-language-server (where hopefully your IDE will pick up python-language-server and supply autocomplete, docs, etc.):
```sh
nix shell github:marcus7070/cq-flake#cadquery-env
```

To create an environment with [yacv-server](https://github.com/yeicor-3d/yet-another-cad-viewer):
```sh
nix shell github:marcus7070/cq-flake#yacv-env
```
This does not include the front end, follow the official
[example](https://github.com/yeicor-3d/yet-another-cad-viewer/tree/master/example)
for how to use it.

To get the most out of this flake you should specify a commit along with those commands and note it down so you are always using the same CadQuery, eg.
```sh
nix run github:marcus7070/cq-flake/14d05cee591dccf5d64fa0e502e6e381a531c718
```

You can also generate the docs with:
```
nix build github:marcus7070/cq-flake#cq-docs
```
which will leave a symlink called `result` pointing to the HTML docs.

## Local dev

Should you wish to do dev work with CadQuery check out the `dev` branch of this repo. `flake.nix` shows how to reference a local copy (must be a Git repo) of CadQuery instead of a GitHub copy. Then use a command like:

```sh
nix flake update --update-input cadquery . && nix build -L .#cadquery-docs && qutebrowser ./result-doc/share/doc/index.html
```

~~I've also added some debug stuff for debugging with `gdb`. Debugging symbols for Python have come and gone from nixpkgs, if the debugging attributes don't have all the symbols you need look into setting overriding `separateDebugInfo = true;` in the Python expression. The most likely method you need for debugging is to run `nix develop github:marcus7070/cq-flake#cadquery-env-debug`, start python, switch to a second terminal, `gdb python <PID>`, `continue`, switch back to python, make it crash, switch back to gdb, `bt`. gdb can't run scripts so it's difficult to start Python (which under nix is usually a script wrapper around the actual Python binary) from within gdb, easier just to attach it to a running instance.~~
Debugging currently removed from nixpkgs.
