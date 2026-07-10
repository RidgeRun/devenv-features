
# GStreamer Daemon (gstd)

Add GStreamer Daemon (gstd) to a devcontainer

## Example Usage

```json
"features": {
    "ghcr.io/ridgerun/devcontainer-features/gstd:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| buildType | The type of build to perform | string | debug |
| version | The gstreamer daemon version or git ref to build | string | master |
| extraArgs | Any additional meson args to pass to the configuration step | string | undefined |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/ridgerun/devcontainer-features/blob/main/src/gstd/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
