## Compress Rays

If you have multiple undersampled time frames (say 30 frames of 24 rays each) it may be advantageous to combine rays when estimating coil sensitivities. The `compress_rays` function is a convenient way to do this.

Let's say I have 25 time frames of 30 rays each. I could easily combine them into 1 frame of 750 frames, but that would give very large matrices in the coil estimation software and be time consuming. To save time, let's estimate the coil sensitivity profiles from 3 frame of 250 rays like so.

```matlab
maxRays = 250;
compressedKSpace = SenseMapper.compress_rays(kSpace, maxRays);
% Convert k-space to cartesian Nx x Ny x 3 x NCoils
image4D = fftObj' * compressedKSpace;
image3D = squeeze(sum(image4D, 3));
estimator = SenseMapper.MapEstimator(image3D)
```

Note that in the above we summed over the time frames in image space. That's just one approach to condensing a large dataset for use with the MapEstimator.

## Edge Cases

The algorithm here rearranges things so that rays from different time frames are
put together into the same time frame. As long as the total number of
rays (nRay * nTime) is less than maxRays they'll all end up in the same
time point. But if it's greater than ray max, then it will truncate the input to make them fit nicely into the maximum number of time frames.
