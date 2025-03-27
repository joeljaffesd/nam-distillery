# nam-distillery
Quick 'n dirty tool for distilling [NAM](https://www.neuralampmodeler.com/) models. 

<div align=center>
<img src=./media/nam-distillery.jpg>
</div>

## Using:
- Run `./init.sh`
- Then `./build.sh`
- Then `./distill.sh <model.nam>`

That easy!

## Config
Currently configured to use [Edward Payne's](https://github.com/EdwardPayne) reamping CLI to distill arbitrary NAM models to the "[pico](https://github.com/GuitarML/Mercury/blob/main/training/README.md)" model definition designed by [GuitarML](https://github.com/guitarml).

You can provide your own model definition in `nam_full_configs/model.json`.

You can modify training parameters in `nam_full_configs/learn.json`

By default, [NeuralAmpModelerReamping](https://github.com/EdwardPayne/NeuralAmpModelerReamping) uses `fast_tanh`, for better accuracy you can comment this line out in the source code before building.