# make-bootstrap

Here is a _good old_ `Makefile` to download, configure and build [Bootstrap](https://getbootstrap.com).
For us the old-timers who have a hard time reinventing the wheel with the _gulps_ and _grunts_ of the Javascript world :smile:

*Note*: To be honest, Bootstrap doesn't make use of the aforementioned tools; and their is a use case for `npm`. Nonetheless, our
preference goes for _make(1)_.

Getting your distribution ready is as simple as:

``` {.sh}
make init
make dist
```

All `npm run` command are available as `make` (e.g. `make dist` in lieu of `npm run dist`).

Additional targets:

| Target | Purpose |
| :----- | :------ |
| `clean` | Remove temporary files and `dist` directory. |
| `realclean` | Remove build environment, in particular `node_modules`. |
| `distclean` | Purge directory except this repositorїes files. |

Enjoy!

