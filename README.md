# sc-as-utils
Sven Co-op AngelScript utility files for using in various projects.

## Using this repository as a Git submodule

From the root of the repository that will contain this project, add it as a
submodule and specify `mikk155` as the destination path.

This places the
contents of this repository inside that directory (for example,
`mikk155/README.md`):

```sh
git submodule add https://github.com/Mikk155/sc-as-utils mikk155
```

If your repository has a `scripts/maps` or `scripts/plugins` directory, you can
run `cd scripts` before adding the submodule.

This places it at `scripts/mikk155`,
so you can include its scripts with `#include "../mikk155/main.as"`.

To initialize the submodule in a fresh clone, fetch this project’s latest
changes, and record the updated reference in the containing repository, run:

```sh
git submodule update --init --recursive
git submodule update --remote --merge mikk155
git add mikk155
git commit -m "Update mikk155 submodule"
```

The first command initializes submodules in a fresh clone. The second updates
`mikk155` from its configured remote branch, and the final commands record the new commit reference in the containing repository.

You can skip all that if you don't want the scripts to be up-to-date.

Simply pick whatever script you need and place it in your own map/plugin folder to avoid issues with ours. respecting the MIT license.
