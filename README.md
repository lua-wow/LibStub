# LibStub (unofficial mirror)

This repository is an **unofficial mirror** of [LibStub](https://www.wowace.com/projects/libstub),
a minimal versioning stub that World of Warcraft libraries use to register themselves and upgrade.

- Upstream source (mirrored): `https://repos.curseforge.com/wow/libstub/trunk` (SVN)
- Project page and documentation: <https://www.wowace.com/projects/libstub>,
  [LibStub on warcraft.wiki.gg](https://warcraft.wiki.gg/wiki/LibStub)
- [Ace3 on GitHub](https://github.com/WoWUIDev/Ace3) ships its own, slightly different copy of
  `LibStub.lua` (same `LIBSTUB_MINOR = 2`). This mirror follows the standalone SVN trunk.

## Disclaimer

This mirror is not affiliated with or endorsed by the LibStub authors. It exists only so the
library can be used as a git submodule. Everything upstream trunk ships (`LibStub.lua`,
`LibStub.toc`, `tests/`, `.pkgmeta`) is mirrored unmodified.

## License and authors

LibStub is in the public domain. The upstream `LibStub.lua` header says:

```lua
-- LibStub is hereby placed in the Public Domain
-- Credits: Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke
```

`LibStub.toc` declares `## X-License: Public Domain` and
`## Credits: Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel`, and the
[project page](https://www.wowace.com/projects/libstub) states "This work is dedicated to the
public domain." This repository makes no claim of ownership over the library.

## Use as a git submodule

```bash
git submodule add https://github.com/lua-wow/LibStub.git libs/LibStub
git commit -m "add LibStub"
```

Load `libs/LibStub/LibStub.lua` from your `.toc` or `embeds.xml` before any library that uses it.

Update the pinned version:

```bash
git submodule update --remote libs/LibStub
git add libs/LibStub
git commit -m "update LibStub"
```

After cloning a project that uses it: `git submodule update --init --recursive`.

## Automatic sync

The [Sync upstream](.github/workflows/sync-upstream.yml) workflow runs weekly (Monday 06:00 UTC)
and can be started manually. It runs [`sync-upstream.sh`](.github/scripts/sync-upstream.sh), which
runs `svn export` on upstream trunk and copies it to the repository root (files deleted upstream
are deleted here as well). The workflow commits only when something changed. Each sync commit is
named `sync: upstream libstub r<N>`. The history is never rewritten, so existing submodule pins
keep working.

The last mirrored upstream revision is recorded in [`UPSTREAM_REVISION`](UPSTREAM_REVISION). The
sync never modifies `README.md`, `docs/` or `.github/`.

To run the sync locally (requires `svn`), from the repository root:

```bash
.github/scripts/sync-upstream.sh
git status   # review the changes; the script does not commit
```

## Contact / removal requests

If you are an author of LibStub and want this mirror changed or removed, please
[open an issue](https://github.com/lua-wow/LibStub/issues).
