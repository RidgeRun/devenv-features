## Compatibility

This feature builds shared libraries for NVIDIA DeepStream and is only useful for devcontainers that run on a host machine with an NVIDIA GPU. Within your devcontainer, use the `nvidia-smi` command to ensure that your GPU is available for CUDA.

> An image with CUDA and TensorRT is required for this feature.

For example, `nvcr.io/nvidia/tensorrt:25.03-py3` from NVIDIA NGC is available.

### Enable GPU passthrough

Enable GPU passthrough to your devcontainer by using `hostRequirements`. Here's an example of a devcontainer with this property:

```json
{
  "hostRequirements": {
    "gpu": "optional" 
  }
}
```

> Note: Setting `gpu` property's value to `true` will work with GPU machine types, but fail with CPUs. Hence, setting it to `optional` works in both cases. See [schema](https://containers.dev/implementors/json_schema/#base-schema) for more configuration details.



## OS Support

This Feature should work on recent versions of Debian/Ubuntu-based distributions with the `apt` package manager installed.

`bash` is required to execute the `install.sh` script.
