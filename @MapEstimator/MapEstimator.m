classdef MapEstimator < handle
  properties (Constant)
    SMOOTHING = 5;
  end
  properties
    imageInput
    correlationMatrix
    nRows
    nCols
    nCoils
    smoothing
  end
  methods
    function self = MapEstimator(imageInput, Opts)
      % Check arg in
      if ndims(imageInput) ~= 3
        error('MapEstimator expects a 3D image, rows x columns x coils.')
      end

      % Initialize object
      self.imageInput = imageInput;
      [self.nRows, self.nCols, self.nCoils] = size(self.imageInput);

      % Handle Opts
      if nargin == 1
        Opts = struct;
      end
      if isfield(Opts, 'smoothing')
        self.smoothing = Opts.smoothing;
      else
        self.smoothing = self.SMOOTHING;
      end
    end

    function maps = get_maps(self)
      self.normalize_image_input;
      self.get_correlation_matrix;
      maps = self.get_sense_maps;
    end

    function normalize_image_input(self)
      % normalize by root sum of squares magnitude
      squaredImage = self.imageInput .* conj(self.imageInput);
      sumOfSquares = sum(squaredImage, 3);
      magnitude = sqrt(sumOfSquares);
      preciseMagnitude = repmat(magnitude + eps, [1 1 self.nCoils]);
      self.imageInput = self.imageInput ./ preciseMagnitude;
    end

    function get_correlation_matrix(self)
      % compute sample correlation estimates at each pixel location
      self.correlationMatrix = zeros(self.nRows, self.nCols, self.nCoils, self.nCoils);

      % Iterate through each coil and neighboring coil
      for iCoil = 1:self.nCoils
        iCoilImage = self.imageInput(:,:,iCoil);
        for jCoil = 1:iCoil - 1
          jCoilImage = self.imageInput(:,:,jCoil);
          ijProduct = iCoilImage .* conj(jCoilImage);
		      self.correlationMatrix(:,:,iCoil,jCoil) = ijProduct;
          % using conjugate symmetry of self.correlationMatrix
          correlationMatrixFrame = self.correlationMatrix(:,:,iCoil,jCoil);
		      self.correlationMatrix(:,:,jCoil,iCoil) = conj(correlationMatrixFrame);
        end
        iiProduct = iCoilImage .* conj(iCoilImage);
	      self.correlationMatrix(:,:,iCoil,iCoil) = iiProduct;
      end

      % Smooth the result
      self.smooth_correlation_matrices;
    end

    function smooth_correlation_matrices(self)
      % apply spatial smoothing to sample correlation estimates (NxN convolution)
      if self.smoothing > 1
        % uniform self.smoothing kernel
      	smoothMatrix = ones(self.smoothing) / (self.smoothing^2);
      	for iCoil = 1:self.nCoils
      		for jCoil = 1:self.nCoils
            correlationMatrixFrame = self.correlationMatrix(:,:,iCoil,jCoil);
            smoothedMatrix = conv2(correlationMatrixFrame, smoothMatrix, 'same');
      		  self.correlationMatrix(:,:,iCoil,jCoil) = smoothedMatrix;
      		end
      	end
      end
    end

    function senseMaps = get_sense_maps(self)
      % vectorized method for calculating the dominant eigenvector based on
      % power method.
      %
      % senseMaps is the dominant eigenvector
      % eigenValueImage is the dominant (maximum) eigenvalue
      nIterations = 2;
      senseMaps = ones(self.nRows,self.nCols,self.nCoils);
      eigenvalueImage = zeros(self.nRows,self.nCols);

      % loop
      for i=1:nIterations
        senseMaps4D = repmat(senseMaps, [1 1 1 self.nCoils]);
        correlatedVector = self.correlationMatrix .* senseMaps4D;
        senseMaps = squeeze(sum(correlatedVector, 3));

	      eigenvalueImage = self.root_sum_of_squares(senseMaps);
        eigenvalueImage(eigenvalueImage <= eps) = eps;
        evImage3D = repmat(eigenvalueImage, [1 1 self.nCoils]);
	      senseMaps = senseMaps ./ evImage3D;
      end

      senseMaps = self.normalize_phase(senseMaps);
    end

    function result = root_sum_of_squares(self, inputMatrix)
      squaredImage = real(inputMatrix).^2 + imag(inputMatrix).^2;
      sumOfSquares = sum(squaredImage, 3);
      result = sqrt(sumOfSquares);
    end

    function senseMaps = normalize_phase(self, senseMaps)
      % normalize output to coil 1 phase
      phaseCoil1 = angle(conj(senseMaps(:,:,1)));
      expPhase = exp(sqrt(-1) * phaseCoil1);
      repPhase = repmat(expPhase, [1 1 self.nCoils]);
      senseMaps = senseMaps .* repPhase;
      senseMaps = conj(senseMaps);
    end
  end
end
