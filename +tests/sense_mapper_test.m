function sense_mapper_test(Tester)
  % Load test data, test compression
  load('test_sense_mapper_data.mat')
  maxRays = 100;
  KSpaceData.kSpace = SenseMapper.compress_rays(KSpaceData.kSpace, maxRays);
  KSpaceData.trajectory = SenseMapper.compress_rays(KSpaceData.trajectory, maxRays);

  % Load test result `testKSpace` and compare
  load('test_compress_rays_result.mat')
  Tester.test(testKSpace, KSpaceData.kSpace, 'Test compress_rays')

  % obtain cartesian image for sensitivity map estimation
  [nReadout, nRay, nTime, nCoil] = size(KSpaceData.kSpace);
  KSpaceData.cartesianSize = [nReadout, nReadout, nTime, nCoil];
  KSpaceData = Gridder.use_griddata(KSpaceData);
  fftObj = FftTools.MaskFft(KSpaceData.cartesianMask);
  multiCoilImage = fftObj' * KSpaceData.cartesianKSpace;
  multiCoilImage = squeeze(sum(multiCoilImage, 3));

  % fetch sensitivity maps
  estimator = SenseMapper.MapEstimator(multiCoilImage);
  senseMaps = estimator.get_maps;

  % Load and compare result
  load('test_sense_maps_result.mat')
  Tester.test(testSenseMaps, senseMaps, 'Test MapEstimator.get_maps')
end
