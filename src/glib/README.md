
# GLib (glib)

Add a GLib build to a devcontainer

## Example Usage

```json
"features": {
    "ghcr.io/ridgerun/devenv-features/glib:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| glibVersion | The GLib version to build | string | undefined |
| buildType | The type of build to perform | string | debug |
| extraArgs | Any additional meson args to pass to the configuration step | string | undefined |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/ridgerun/devenv-features/blob/main/src/glib/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
