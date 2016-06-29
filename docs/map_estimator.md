# MapEstimator

Estimates relative coil sensitivity maps from a set of coil images
using the eigenvector method described by Walsh et al. (Magn Reson Med
2000;43:682-90.)

Just give it the 3D multi-coil image to estimate from, and optionally a smoothing block size (default is 5) via the opts:

```matlab
estimator = SenseMapper.MapEstimator(imageInput)
% or
Opts.smoothing = 4;
estimator = SenseMapper.MapEstimator(imageInput, Opts);
```

Then you can call the `get_maps` method to compute the complex coil sensitivity maps for each coil

```matlab
senseMaps = estimator.get_maps;
```


### Credits
Code is based on an original implementation by Peter Kellman, NHLBI,
NIH (kellman@nih.gov).

Code made available for the ISMRM 2013 Sunrise Educational Course
by Michael S. Hansen (michael.hansen@nih.gov)
