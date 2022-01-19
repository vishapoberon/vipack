![](https://xn--y9azesw6bu.xn--y9a3aq/media/uploads/2022/01/19/4b650ab4-2e97-45f8-8fd3-af1c726399c0.png)

vipack
======

vipack is a language or dependency agnostic package manager.

currently it has a backend to retrieve dependencies from the [vipack tree](https://github.com/vishaps/vipackTree).

that is a list of json files, each containing information about the package dependencies, where to download the packages, and how to build those.

usage
=====

try `vipack --help`.

some examples:

`vipack -s` — syncs the default package tree to `~/.vipack/vipackTree`.

`vipack -d -p irc_bot` — only resolves/shows dependencies of the package `irc_bot`, does not download or build packages.

`vipack -f -p irc_bot` — resolves and fetches required packages.

`vipack -p irc_bot` — will build the package and dependencies in the default prefix: `~/vpkLocal`

`vipack -a -p irc_bot` — ask for confirmation before building the package and dependencies in the default prefix: `~/vpkLocal`

`vipack -p irc_bot -P /tmp/coolprefix` — will do the same in the custom prefix.

`vipack -p irc_bot -P /tmp/coolprefix -t /tmp/myothertree` — the same, but the dependency resolution will be conducted by using custom package description tree.

todo
====

json parser can be improved. it does not contain lists yet.

though we have http module, only git downloads are currently supported by using external git tool.

port to oberon system.

lots of other things.
