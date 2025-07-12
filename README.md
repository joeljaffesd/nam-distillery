# nam-distillery
Quick 'n dirty tool for distilling [NAM](https://www.neuralampmodeler.com/) models. 

<div align=center>
<img src=./media/nam-distillery.jpg>
</div>

## Using:

### Native Build:

Make sure you're in a Python environment that has `neural-amp-modeler` installed.

- Run `./init.sh`
- Then `./build.sh`
- Then `./distill.sh <model.nam>`

That easy!

### Docker Build:
- Run `docker build -t nam-distillery .`
- Then `docker run -it --rm nam-distillery `

**Note**: If you have an NVIDIA GPU, add the `--gpus all` flag to the above `docker run` command.

This will drop you into the shell of your container. You can use `curl <web.address>` to grab a model, or `scp` or something to grab it from your local filesystem.

Once you have your desired model in your container, you can run `./distill.sh <model.nam>`

## Config
Currently configured to use [Edward Payne's](https://github.com/EdwardPayne) reamping CLI to distill arbitrary NAM models to the "[pico](https://github.com/GuitarML/Mercury/blob/main/training/README.md)" model definition designed by [GuitarML](https://github.com/guitarml).

You can provide your own model definition in `nam_full_configs/model.json`.

You can modify training parameters in `nam_full_configs/learn.json`

By default, [NeuralAmpModelerReamping](https://github.com/EdwardPayne/NeuralAmpModelerReamping) uses `fast_tanh`, for better accuracy you can comment this line out in the source code before building.