function compressedKSpace = compress_rays(kSpaceData, maxRays)
  % Reshape data into readout x rays x coils
  [nReadout, nRay, nTime, nCoil] = size(kSpaceData);
  totalRays = nRay * nTime;
  kSpaceData = reshape(kSpaceData, [nReadout, totalRays, nCoil]);

  % Determine desired max rays and time based on the given maximum
  if totalRays > maxRays
    totalRays = maxRays;
    totalTime = floor(nRay * nTime / maxRays);
  else
    totalTime = 1;
  end

  % Loop through max time frames, and all coils to create output kSpace
  compressedKSpace = zeros(nReadout, totalRays, totalTime, nCoil);
  for iCoil = 1:nCoil
    for iTime = 1:totalTime
      firstRay = (iTime - 1) * totalRays + 1;
      lastRay = iTime * totalRays;
      rayIndices = firstRay:lastRay;
      compressedKSpace(:,:,iTime,iCoil) = kSpaceData(:,rayIndices,iCoil);
    end
  end

  compressedKSpace = squeeze(compressedKSpace);
end
