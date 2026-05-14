classdef WindStreakWavelengths_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        LeftPanel                       matlab.ui.container.Panel
        ClearSavedFrequenciesButton     matlab.ui.control.Button
        DisplaySavedFrequenciesButton   matlab.ui.control.Button
        AutoDetectSavePeaksButton       matlab.ui.control.Button
        ThresholdSlider                 matlab.ui.control.Slider
        ThresholdSliderLabel            matlab.ui.control.Label
        FourierTransformButton          matlab.ui.control.Button
        PreProcessButton                matlab.ui.control.Button
        UploadImageButton               matlab.ui.control.Button
        CenterPanel                     matlab.ui.container.Panel
        ImageResYkmEditField            matlab.ui.control.NumericEditField
        ImageResYkmEditFieldLabel       matlab.ui.control.Label
        ImageResXkmEditField            matlab.ui.control.NumericEditField
        ImageResXkmEditFieldLabel       matlab.ui.control.Label
        ShowFilteredImageDropDown       matlab.ui.control.DropDown
        ShowFilteredImageDropDownLabel  matlab.ui.control.Label
        PixelResEditField               matlab.ui.control.EditField
        PixelResEditFieldLabel          matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
        RightPanel                      matlab.ui.container.Panel
        FindPeakFrequencyButton         matlab.ui.control.Button
        SaveFrequencyCheckBox           matlab.ui.control.CheckBox
        IntensityEditField              matlab.ui.control.NumericEditField
        IntensityEditFieldLabel         matlab.ui.control.Label
        DirectiondegreesEditField       matlab.ui.control.NumericEditField
        DirectiondegreesEditFieldLabel  matlab.ui.control.Label
        PeakFreqY1mEditField            matlab.ui.control.NumericEditField
        PeakFreqY1mEditFieldLabel       matlab.ui.control.Label
        WavelengthmEditField            matlab.ui.control.NumericEditField
        WavelengthmEditFieldLabel       matlab.ui.control.Label
        PeakFreqX1mEditField            matlab.ui.control.NumericEditField
        PeakFreqX1mEditFieldLabel       matlab.ui.control.Label
        HeightEditField                 matlab.ui.control.NumericEditField
        HeightEditFieldLabel            matlab.ui.control.Label
        WidthEditField                  matlab.ui.control.NumericEditField
        WidthEditFieldLabel             matlab.ui.control.Label
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
        twoPanelWidth = 768;
    end


  properties (Access = private)
      % Initialize variables
      img = 0;                         % Original image placeholder
      height = 0;                      % Height of the original image
      width = 0;                       % Width of the original image
      cropped_img = 0;                 % Cropped version of the image placeholder
      new_height = 0;                  % Height of the cropped image
      new_width = 0;                   % Width of the cropped image
      magnitude_spectrum = 0;          % Magnitude spectrum of the Fourier transform of the image
      imageXRes = 20000;               % Image resolution in the x-direction (meters)
      imageYRes = 20000;               % Image resolution in the y-direction (meters)
      xRes = 0;                        % Pixel resolution in the x-direction (meters per pixel)
      yRes = 0;                        % Pixel resolution in the y-direction (meters per pixel)
      thresholded_magnitude = 0;       % Thresholded magnitude spectrum for peak detection
      wavelengths = [];                % Array to store calculated wavelengths
      directions = [];                 % Array to store calculated directions of wave vectors
      intensities = [];                % Array to store intensity values of detected peaks
      index = 0;                       % Index for tracking the number of saved entries
      HighPassImage = 0;               % Image after applying high-pass filter
      LowPassImage = 0;                % Image after applying low-pass filter
end



    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: UploadImageButton
        function UploadImageButtonPushed(app, event)

    % Open a file dialog to select an image
    [filename, pathname] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tiff', 'Image Files'}, 'Select an Image');

    % Clear the contents and reset properties of the UIAxes
    cla(app.UIAxes, 'reset');

    % Check if the user selects a file
    if filename ~= 0
        % Read the selected image
        app.img = imread(fullfile(pathname, filename));

        % Display the image on the UIAxes
        imshow(app.img, 'Parent', app.UIAxes);

        % Set the title of the UIAxes to 'Wind Streaks Image'
        title(app.UIAxes, 'Wind Streaks Image');

        % Get the dimensions of the image (height, width, and number of channels)
        [app.height, app.width, ~] = size(app.img);

        % Update the UI fields with the image dimensions
        app.HeightEditField.Value = app.height;
        app.WidthEditField.Value = app.width;

        % Calculate image resolution in the x and y directions in meters
        app.imageXRes = app.ImageResXkmEditField.Value * 1000; % Convert km to meters
        app.xRes = app.imageXRes / app.width;                  % Calculate pixel resolution in x-direction
        app.imageYRes = app.ImageResYkmEditField.Value * 1000; % Convert km to meters
        app.yRes = app.imageYRes / app.height;                 % Calculate pixel resolution in y-direction

        % Update the pixel resolution field in the UI
        app.PixelResEditField.Value = sprintf('%.2fm X %.2fm', app.xRes, app.yRes);

        % Enable the pre-processing button for further actions
        app.PreProcessButton.Enable = 'on';
    else
        % Display a message if no image is selected
        disp('No image selected');
    end
        end

        % Button pushed function: PreProcessButton
        function PreProcessButtonPushed(app, event)
            % Check if the image is RGB and convert to grayscale if needed
            if size(app.img, 3) == 3
                img_gray = rgb2gray(app.img);  % Convert RGB image to grayscale
            else
                img_gray = app.img;            % Use the image as is if already grayscale
            end

            % Initialize new dimensions for cropping
            app.new_height = app.height;
            app.new_width = app.width;

            % Adjust dimensions to be even 

            if mod(app.height, 2) ~= 0
                app.new_height = app.height - 1;  % Make height even if it's odd
            end

            if mod(app.width, 2) ~= 0
                app.new_width = app.width - 1;    % Make width even if it's odd
            end

            % Crop the image to the new even dimensions
            app.cropped_img = img_gray(1:app.new_height, 1:app.new_width);

            % Display the cropped image on the UIAxes
            imshow(app.cropped_img, 'Parent', app.UIAxes);

            % Update the title of the UIAxes to 'Pre-Processed Image'
            title(app.UIAxes, 'Pre-Processed Image');

            % Update the UI fields with the new cropped image dimensions
            app.HeightEditField.Value = app.new_height;
            app.WidthEditField.Value = app.new_width;

            % Enable the Fourier Transform button for further processing
            app.FourierTransformButton.Enable = 'on';

        end

        % Button pushed function: FourierTransformButton
        function FourierTransformButtonPushed(app, event)
            % Perform 2D FFT on the cropped grayscale image
            fft_result = fft2(double(app.cropped_img));

            % Shift the zero-frequency component to the center of the spectrum
            fft_shifted = fftshift(fft_result);

            % Compute the magnitude spectrum for visualization
            app.magnitude_spectrum = 5 * log(abs(fft_shifted) + 1);

            % Determine the range of values in the magnitude spectrum for display scaling
            min_val = min(app.magnitude_spectrum(:));
            max_val = max(app.magnitude_spectrum(:));

            % Display the magnitude spectrum on the UIAxes with specified range
            imshow(app.magnitude_spectrum, [min_val, max_val], 'Parent', app.UIAxes);

            % Update the title of the UIAxes to reflect the displayed content
            title(app.UIAxes, 'Fourier Transform of Image');

            % Enable and make visible the controls for further interaction
            app.FindPeakFrequencyButton.Enable = 'on';
            app.FindPeakFrequencyButton.Visible = 'on';
            app.ThresholdSlider.Enable = 'on';
            app.ThresholdSlider.Visible = 'on';
            app.AutoDetectSavePeaksButton.Enable = 'on';
            app.AutoDetectSavePeaksButton.Visible = 'on';
        end

        % Button pushed function: FindPeakFrequencyButton
        function FindPeakFrequencyButtonPushed(app, event)

            % Crop the image and return the selected region and rectangle coordinates
            [J, rect] = imcrop(app.UIAxes);

            % Convert the rectangle coordinates to pixel values
            x1 = round(rect(1));                % Starting x coordinate
            y1 = round(rect(2));                % Starting y coordinate
            x2 = round(rect(1) + rect(3));      % Ending x coordinate
            y2 = round(rect(2) + rect(4));      % Ending y coordinate

            % Extract the selected region from the DC-removed magnitude spectrum
            selected_region = app.magnitude_spectrum(y1:y2, x1:x2);

            % Find the maximum value and its location within the selected region
            [max_value, max_idx] = max(selected_region(:));
            [row, col] = ind2sub(size(selected_region), max_idx);

            % Convert the indices to the original image pixel coordinates
            original_row = row + y1 - 1;
            original_col = col + x1 - 1;

            % Display the magnitude spectrum with the peak indicated
            hold(app.UIAxes, 'on');
            scatter(app.UIAxes, original_col, original_row, 'ro', 'MarkerFaceColor', 'r', 'LineWidth', 1);
            hold(app.UIAxes, 'off');

            % Calculate the frequency components from the selected peak
            fx = (original_col - app.new_width / 2) / (app.new_width * app.xRes);
            fy = (original_row - app.new_height / 2) / (app.new_height * app.yRes);

            % Calculate the wavelength and direction from the frequency components
            lambda = 1 / sqrt(fx^2 + fy^2);      % Wavelength
            theta = rad2deg(atan2(fy, fx));      % Direction in degrees

            % Update the UI with the calculated values
            app.PeakFreqX1mEditField.Value = fx;
            app.PeakFreqY1mEditField.Value = fy;
            app.WavelengthmEditField.Value = lambda;
            app.DirectiondegreesEditField.Value = theta;
            app.IntensityEditField.Value = max_value;

            % Enable and show UI elements for saved frequencies
            app.SaveFrequencyCheckBox.Enable = 'on';
            app.SaveFrequencyCheckBox.Visible = 'on';
            app.DisplaySavedFrequenciesButton.Enable = 'on';
            app.DisplaySavedFrequenciesButton.Visible = 'on';
            app.ClearSavedFrequenciesButton.Enable = 'on';
            app.ClearSavedFrequenciesButton.Visible = 'on';


        end

        % Value changed function: ThresholdSlider
        function ThresholdSliderValueChanged(app, event)
            % Get the current value from the Threshold Slider
            value = app.ThresholdSlider.Value;

            % Set the threshold based on the slider value
            threshold = value;  % Direct assignment; adjust the calculation if needed

            % Apply the threshold to the magnitude spectrum to create a binary image
            app.thresholded_magnitude = app.magnitude_spectrum > threshold;

            % Display the thresholded magnitude spectrum on the UIAxes
            imshow(app.thresholded_magnitude, [0, 1], 'Parent', app.UIAxes);

        end

        % Value changed function: SaveFrequencyCheckBox
        function SaveFrequencyCheckBoxValueChanged(app, event)
            % Check if the Save Frequency CheckBox is selected
            if app.SaveFrequencyCheckBox.Value == 1
                % Check if the wavelength and direction values are already in their respective arrays
                if ~ismember(app.WavelengthmEditField.Value, app.wavelengths) || ~ismember(app.DirectiondegreesEditField.Value, app.directions)
                    % Increment the index and save the new wavelength, direction, and intensity values if not present
                    app.index = app.index + 1;
                    app.wavelengths(app.index) = app.WavelengthmEditField.Value;
                    app.directions(app.index) = app.DirectiondegreesEditField.Value;
                    app.intensities(app.index) = app.IntensityEditField.Value;
                else
                    % Display a message indicating the values are already saved
                    disp('This wavelength and direction value pair has already been saved.');
                end
                % Reset the Save Frequency CheckBox to its default state
                app.SaveFrequencyCheckBox.Value = 0;
            end
        end

        % Button pushed function: DisplaySavedFrequenciesButton
        function DisplaySavedFrequenciesButtonPushed(app, event)
            % Display the image on app.UIAxes
            %imshow(app.img, 'Parent', app.UIAxes);  % Display the image on the UIAxes
            hold(app.UIAxes, 'on');  % Retain the image for overlaying arrows

            % Get the center coordinates of the image
            center_x = size(app.img, 2) / 2;  % X-coordinate of the image center
            center_y = size(app.img, 1) / 2;  % Y-coordinate of the image center

            % Convert directions from degrees to radians for trigonometric functions
            directions_rad = deg2rad(app.directions);

            % Calculate the X and Y components of the arrows based on intensity and direction
            arrow_x = 2*app.intensities .* cos(directions_rad);  % X-component of the arrows
            arrow_y = 2*app.intensities .* sin(directions_rad);  % Y-component of the arrows

            % Loop through each direction and draw arrows on the image
            for i = 1:length(app.directions)
                % Arrows originate from the image center
                start_x = center_x;
                start_y = center_y;

                % Draw arrows using quiver with specified properties
                quiver(start_x, start_y, arrow_x(i), arrow_y(i), 0, 'LineWidth', 2, ...
                    'Color', [1, 0, 0], 'MaxHeadSize', 1, 'Parent', app.UIAxes);

                % Calculate offsets to position text labels near the arrow tips
                text_offset_x = 10 * cos(directions_rad(i));  % X-direction offset
                text_offset_y = 10 * sin(directions_rad(i));  % Y-direction offset

                % Calculate the text label position
                text_x = start_x + arrow_x(i) + text_offset_x;  % X-coordinate for text
                text_y = start_y + arrow_y(i) + text_offset_y;  % Y-coordinate for text

                % Draw a background rectangle behind the text for better readability
                rectangle('Position', [text_x - 20, text_y - 10, 40, 20], ...  % Rectangle size and position
                    'FaceColor', [0, 0, 0, 1], ...  % Semi-transparent black background
                    'EdgeColor', 'none', 'Parent', app.UIAxes);  % No border around the rectangle

                % Add text labels with wavelength values near the arrow tips
                text(text_x, text_y, sprintf('%.0f', app.wavelengths(i)), ...
                    'Color', [1, 1, 1], 'FontSize', 12, 'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'center', 'Parent', app.UIAxes);
            end

            % Set the title for the UIAxes to describe the overlay
            title(app.UIAxes, 'Overlayed Wavelength Directions on Image');
        end

        % Button pushed function: ClearSavedFrequenciesButton
        function ClearSavedFrequenciesButtonPushed(app, event)
            app.wavelengths=0;
            app.directions=0;
            app.intensities=0;
            app.index=0;
        end

        % Button pushed function: AutoDetectSavePeaksButton
        function AutoDetectSavePeaksButtonPushed(app, event)

            % Set window sizes for low and high frequency components
            windowSizeLow = round(min(app.new_width, app.new_height));  % Low frequency window size (must be even)
            windowSizeHigh = 50;  % High frequency window size (must be even)
            sigma = 20;  % Standard deviation for Gaussian filter (controls filter width)
            radius = 7;  % Radius for circular mask on low frequency image (zeros DC leakage)

            % Create the Gaussian filter in the frequency domain
            Gaussian = zeros(app.new_height, app.new_width);
            for i = 1:app.new_height
                for j = 1:app.new_width
                    % Calculate distance from the center (frequency space) for Gaussian
                    D = (i - app.new_height / 2)^2 + (j - app.new_width / 2)^2;
                    Gaussian(i, j) = exp(-D / (2 * sigma^2));  % Gaussian function
                end
            end

            Fourier_Transform = fft2(app.cropped_img);  % Perform 2D FFT on cropped image

            % Normalize the Gaussian filter
            GaussianFilt = Gaussian / max(Gaussian, [], 'all');

            % Apply low-pass and high-pass filters in frequency domain
            LowPassFourier_Transform = Fourier_Transform .* fftshift(GaussianFilt);  % Low-pass filter (Gaussian)
            HighPassFourier_Transform = Fourier_Transform .* fftshift(1 - GaussianFilt);  % High-pass filter (inverse of Gaussian)

            % Reconstruct filtered images using inverse FFT
            app.LowPassImage = real(ifft2(LowPassFourier_Transform));  % Low-pass filtered image
            app.HighPassImage = real(ifft2(HighPassFourier_Transform));  % High-pass filtered image

            % Calculate the number of windows for splitting image into regions
            numWindowsRowLow = app.new_height / windowSizeLow;  % Rows for low-frequency windows
            numWindowsColLow = app.new_width / windowSizeLow;   % Columns for low-frequency windows
            numWindowsRowHigh = app.new_height / windowSizeHigh; % Rows for high-frequency windows
            numWindowsColHigh = app.new_width / windowSizeHigh;  % Columns for high-frequency windows

            % Initialize arrays to store peak coordinates and frequency values
            peakRowsHigh = []; peakColsHigh = []; frequenciesXHigh = []; frequenciesYHigh = []; intensityHigh = [];
            peakRowsLow = []; peakColsLow = []; frequenciesXLow = []; frequenciesYLow = []; intensityLow = [];

            % High-frequency windows loop
            for i = 1:numWindowsRowHigh
                for j = 1:numWindowsColHigh
                    % Define window boundaries for high-frequency region
                    rowStartHigh = (i - 1) * windowSizeHigh + 1;
                    rowEndHigh = i * windowSizeHigh;
                    colStartHigh = (j - 1) * windowSizeHigh + 1;
                    colEndHigh = j * windowSizeHigh;

                    % Extract window from the high-pass filtered image
                    windowHigh = app.HighPassImage(rowStartHigh:rowEndHigh, colStartHigh:colEndHigh);

                    % Compute 2D FFT of the window and shift zero-frequency component to center
                    windowHighFFT = fft2(windowHigh);
                    windowHighFFTShifted = fftshift(windowHighFFT);

                    % Compute magnitude spectrum for better visualization
                    magnitudeSpectrumHigh = 5 * log(abs(windowHighFFTShifted) + 1);

                    % Find peak in the magnitude spectrum (coordinates and value)
                    [maxValHigh, linearIdxHigh] = max(magnitudeSpectrumHigh(:));
                    [peakRowHigh, peakColHigh] = ind2sub(size(magnitudeSpectrumHigh), linearIdxHigh);

                    % Store peak information
                    peakRowsHigh = [peakRowsHigh; peakRowHigh];
                    peakColsHigh = [peakColsHigh; peakColHigh];
                    intensityHigh = [intensityHigh; maxValHigh];

                    % Calculate frequency components based on window size
                    fxHigh = (peakColHigh - windowSizeHigh / 2) / (windowSizeHigh * app.xRes);
                    fyHigh = (peakRowHigh - windowSizeHigh / 2) / (windowSizeHigh * app.yRes);
                    frequenciesXHigh = [frequenciesXHigh; fxHigh];
                    frequenciesYHigh = [frequenciesYHigh; fyHigh];
                end
            end

            % Low-frequency windows loop
            for i = 1:numWindowsRowLow
                for j = 1:numWindowsColLow
                    % Define window boundaries for low-frequency region
                    rowStartLow = (i - 1) * windowSizeLow + 1;
                    rowEndLow = i * windowSizeLow;
                    colStartLow = (j - 1) * windowSizeLow + 1;
                    colEndLow = j * windowSizeLow;

                    % Extract window from the low-pass filtered image
                    windowLow = app.LowPassImage(rowStartLow:rowEndLow, colStartLow:colEndLow);

                    % Compute 2D FFT and shift zero-frequency component to center
                    windowLowFFT = fft2(windowLow);
                    windowLowFFTShifted = fftshift(windowLowFFT);

                    % Create circular mask to focus on low frequencies (radius-based mask)
                    [x, y] = meshgrid(1:windowSizeLow, 1:windowSizeLow);
                    distance = sqrt((x - windowSizeLow / 2).^2 + (y - windowSizeLow / 2).^2);
                    mask = distance <= radius;  % Mask to zero out low-frequency components

                    % Apply mask to remove low-frequency components
                    windowLowFFTShifted = windowLowFFTShifted .* ~mask;

                    % Compute magnitude spectrum for visualization
                    magnitudeSpectrumLow = 5 * log(abs(windowLowFFTShifted) + 1);

                    % Find peak in the magnitude spectrum (coordinates and value)
                    [maxValLow, linearIdxLow] = max(magnitudeSpectrumLow(:));
                    [peakRowLow, peakColLow] = ind2sub(size(magnitudeSpectrumLow), linearIdxLow);

                    % Store peak information
                    peakRowsLow = [peakRowsLow; peakRowLow];
                    peakColsLow = [peakColsLow; peakColLow];
                    intensityLow = [intensityLow; maxValLow];

                    % Calculate frequency components (X and Y) based on window size
                    fxLow = (peakColLow - windowSizeLow / 2) / (windowSizeLow * app.xRes);
                    fyLow = (peakRowLow - windowSizeLow / 2) / (windowSizeLow * app.yRes);
                    frequenciesXLow = [frequenciesXLow; fxLow];
                    frequenciesYLow = [frequenciesYLow; fyLow];
                end
            end

            % Calculate the average frequency for high-pass and low-pass images
            avgFreqXHigh = mean(frequenciesXHigh);
            avgFreqYHigh = mean(frequenciesYHigh);
            avgFreqXLow = mean(frequenciesXLow);
            avgFreqYLow = mean(frequenciesYLow);

            % Calculate wavelengths and directions from average frequencies
            app.index=app.index+1;
            app.wavelengths(app.index) = 1 / sqrt(avgFreqXHigh^2 + avgFreqYHigh^2);  % High-pass wavelength
            app.directions(app.index) = rad2deg(atan2(avgFreqYHigh, avgFreqXHigh));   % High-pass direction
            app.intensities(app.index) = mean(intensityHigh);

            app.index=app.index+1;
            app.wavelengths(app.index) = 1 / sqrt(avgFreqXLow^2 + avgFreqYLow^2);  % Low-pass wavelength
            app.directions(app.index) = rad2deg(atan2(avgFreqYLow, avgFreqXLow));   % Low-pass direction
            app.intensities(app.index) = mean(intensityLow);

            % Print results for both high and low frequencies
            fprintf('High Frequency Average Peak:\n');
            fprintf('Frequency X: %.4f Hz, Frequency Y: %.4f Hz\n', avgFreqXHigh, avgFreqYHigh);
            fprintf('Wavelength: %.4f m\n', app.wavelengths(1));
            fprintf('Direction: %.4f degrees\n', app.directions(1));
            fprintf('Intensity: %.4f\n', app.intensities(1));

            fprintf('\nLow Frequency Average Peak:\n');
            fprintf('Frequency X: %.4f Hz, Frequency Y: %.4f Hz\n', avgFreqXLow, avgFreqYLow);
            fprintf('Wavelength: %.4f m\n', app.wavelengths(2));
            fprintf('Direction: %.4f degrees\n', app.directions(2));
            fprintf('Intensity: %.4f\n', app.intensities(2));

            % Display peaks on the image for both high and low frequencies
            fourierColIndexHigh = avgFreqXHigh * (app.new_width * app.xRes) + (app.new_width / 2);
            fourierRowIndexHigh = avgFreqYHigh * (app.new_height * app.yRes) + (app.new_height / 2);
            fourierColIndexLow = avgFreqXLow * (app.new_width * app.xRes) + (app.new_width / 2);
            fourierRowIndexLow = avgFreqYLow * (app.new_height * app.yRes) + (app.new_height /2);

            % Overlay the peaks on the displayed image
            hold(app.UIAxes, 'on');
            scatter(app.UIAxes, fourierColIndexHigh, fourierRowIndexHigh, 'ro', 'MarkerFaceColor', 'r', 'LineWidth', 1);
            scatter(app.UIAxes, fourierColIndexLow, fourierRowIndexLow, 'ro', 'MarkerFaceColor', 'r', 'LineWidth', 1);
            hold(app.UIAxes, 'off');

            % Enable buttons for displaying and clearing saved frequencies
            app.DisplaySavedFrequenciesButton.Enable = "on";
            app.DisplaySavedFrequenciesButton.Visible = "on";
            app.ClearSavedFrequenciesButton.Enable = "on";
            app.ClearSavedFrequenciesButton.Visible = "on";
            app.ShowFilteredImageDropDown.Enable = 'on';
            app.ShowFilteredImageDropDown.Visible = 'on';
            app.ShowFilteredImageDropDownLabel.Visible = 'on';

        end

        % Value changed function: ShowFilteredImageDropDown
        function ShowFilteredImageDropDownValueChanged(app, event)
            % Get the selected filter type from the dropdown menu
            value = app.ShowFilteredImageDropDown.Value;

            % Display the appropriate filtered image based on the selection
            if strcmp(value, 'High Frequency')
                imshow(app.HighPassImage, 'Parent', app.UIAxes);
                title(app.UIAxes, 'High Frequency Filtered Image');
            else
                % Display low-pass image with dynamic scaling for better visibility
                imshow(app.LowPassImage, [min(app.LowPassImage(:)), max(app.LowPassImage(:))], 'Parent', app.UIAxes);
                title(app.UIAxes, 'Low Frequency Filtered Image');
            end

        end

        % Value changed function: ImageResXkmEditField
        function ImageResXkmEditFieldValueChanged(app, event)

            app.imageXRes = app.ImageResXkmEditField.Value*1000;
            app.xRes = app.imageXRes / app.width;
            % Update the pixel resolution field in the UI
            app.PixelResEditField.Value = sprintf('%.2fm X %.2fm', app.xRes, app.yRes);

        end

        % Value changed function: ImageResYkmEditField
        function ImageResYkmEditFieldValueChanged(app, event)
            app.imageYRes = app.ImageResYkmEditField.Value*1000;
            app.yRes =  app.imageYRes / app.height;
            % Update the pixel resolution field in the UI
            app.PixelResEditField.Value = sprintf('%.2fm X %.2fm', app.xRes, app.yRes);

        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 3x1 grid
                app.GridLayout.RowHeight = {528, 528, 528};
                app.GridLayout.ColumnWidth = {'1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 1;
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 3;
                app.RightPanel.Layout.Column = 1;
            elseif (currentFigureWidth > app.onePanelWidth && currentFigureWidth <= app.twoPanelWidth)
                % Change to a 2x2 grid
                app.GridLayout.RowHeight = {528, 528};
                app.GridLayout.ColumnWidth = {'1x', '1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = [1,2];
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 2;
            else
                % Change to a 1x3 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {179, '1x', 229};
                app.LeftPanel.Layout.Row = 1;
                app.LeftPanel.Layout.Column = 1;
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 2;
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 3;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 862 528];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {179, '1x', 229};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create UploadImageButton
            app.UploadImageButton = uibutton(app.LeftPanel, 'push');
            app.UploadImageButton.ButtonPushedFcn = createCallbackFcn(app, @UploadImageButtonPushed, true);
            app.UploadImageButton.Position = [31 446 100 23];
            app.UploadImageButton.Text = 'Upload Image';

            % Create PreProcessButton
            app.PreProcessButton = uibutton(app.LeftPanel, 'push');
            app.PreProcessButton.ButtonPushedFcn = createCallbackFcn(app, @PreProcessButtonPushed, true);
            app.PreProcessButton.Enable = 'off';
            app.PreProcessButton.Position = [31 395 100 23];
            app.PreProcessButton.Text = 'Pre-Process';

            % Create FourierTransformButton
            app.FourierTransformButton = uibutton(app.LeftPanel, 'push');
            app.FourierTransformButton.ButtonPushedFcn = createCallbackFcn(app, @FourierTransformButtonPushed, true);
            app.FourierTransformButton.Enable = 'off';
            app.FourierTransformButton.Position = [26 341 110 23];
            app.FourierTransformButton.Text = 'Fourier Transform';

            % Create ThresholdSliderLabel
            app.ThresholdSliderLabel = uilabel(app.LeftPanel);
            app.ThresholdSliderLabel.HorizontalAlignment = 'right';
            app.ThresholdSliderLabel.Enable = 'off';
            app.ThresholdSliderLabel.Visible = 'off';
            app.ThresholdSliderLabel.Position = [48 299 58 22];
            app.ThresholdSliderLabel.Text = 'Threshold';

            % Create ThresholdSlider
            app.ThresholdSlider = uislider(app.LeftPanel);
            app.ThresholdSlider.Limits = [25 75];
            app.ThresholdSlider.MajorTicks = [25 50 75];
            app.ThresholdSlider.ValueChangedFcn = createCallbackFcn(app, @ThresholdSliderValueChanged, true);
            app.ThresholdSlider.MinorTicks = [25 30 35 40 45 50 55 60 65 70 75];
            app.ThresholdSlider.Enable = 'off';
            app.ThresholdSlider.Visible = 'off';
            app.ThresholdSlider.Position = [18 297 118 3];
            app.ThresholdSlider.Value = 25;

            % Create AutoDetectSavePeaksButton
            app.AutoDetectSavePeaksButton = uibutton(app.LeftPanel, 'push');
            app.AutoDetectSavePeaksButton.ButtonPushedFcn = createCallbackFcn(app, @AutoDetectSavePeaksButtonPushed, true);
            app.AutoDetectSavePeaksButton.Enable = 'off';
            app.AutoDetectSavePeaksButton.Visible = 'off';
            app.AutoDetectSavePeaksButton.Position = [10 228 148 23];
            app.AutoDetectSavePeaksButton.Text = 'Auto Detect/ Save Peaks';

            % Create DisplaySavedFrequenciesButton
            app.DisplaySavedFrequenciesButton = uibutton(app.LeftPanel, 'push');
            app.DisplaySavedFrequenciesButton.ButtonPushedFcn = createCallbackFcn(app, @DisplaySavedFrequenciesButtonPushed, true);
            app.DisplaySavedFrequenciesButton.Enable = 'off';
            app.DisplaySavedFrequenciesButton.Visible = 'off';
            app.DisplaySavedFrequenciesButton.Position = [8 180 161 23];
            app.DisplaySavedFrequenciesButton.Text = 'Display Saved Frequencies';

            % Create ClearSavedFrequenciesButton
            app.ClearSavedFrequenciesButton = uibutton(app.LeftPanel, 'push');
            app.ClearSavedFrequenciesButton.ButtonPushedFcn = createCallbackFcn(app, @ClearSavedFrequenciesButtonPushed, true);
            app.ClearSavedFrequenciesButton.Enable = 'off';
            app.ClearSavedFrequenciesButton.Visible = 'off';
            app.ClearSavedFrequenciesButton.Position = [14 133 150 23];
            app.ClearSavedFrequenciesButton.Text = 'Clear Saved Frequencies';

            % Create CenterPanel
            app.CenterPanel = uipanel(app.GridLayout);
            app.CenterPanel.Layout.Row = 1;
            app.CenterPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.CenterPanel);
            title(app.UIAxes, 'Title')
            app.UIAxes.Position = [7 59 442 359];

            % Create PixelResEditFieldLabel
            app.PixelResEditFieldLabel = uilabel(app.CenterPanel);
            app.PixelResEditFieldLabel.HorizontalAlignment = 'right';
            app.PixelResEditFieldLabel.Position = [23 431 59 22];
            app.PixelResEditFieldLabel.Text = 'Pixel Res.';

            % Create PixelResEditField
            app.PixelResEditField = uieditfield(app.CenterPanel, 'text');
            app.PixelResEditField.Editable = 'off';
            app.PixelResEditField.Position = [97 431 335 22];

            % Create ShowFilteredImageDropDownLabel
            app.ShowFilteredImageDropDownLabel = uilabel(app.CenterPanel);
            app.ShowFilteredImageDropDownLabel.HorizontalAlignment = 'right';
            app.ShowFilteredImageDropDownLabel.Enable = 'off';
            app.ShowFilteredImageDropDownLabel.Visible = 'off';
            app.ShowFilteredImageDropDownLabel.Position = [113 20 115 22];
            app.ShowFilteredImageDropDownLabel.Text = 'Show Filtered Image';

            % Create ShowFilteredImageDropDown
            app.ShowFilteredImageDropDown = uidropdown(app.CenterPanel);
            app.ShowFilteredImageDropDown.Items = {'High Frequency', 'Low Frequency'};
            app.ShowFilteredImageDropDown.ValueChangedFcn = createCallbackFcn(app, @ShowFilteredImageDropDownValueChanged, true);
            app.ShowFilteredImageDropDown.Enable = 'off';
            app.ShowFilteredImageDropDown.Visible = 'off';
            app.ShowFilteredImageDropDown.Position = [243 20 100 22];
            app.ShowFilteredImageDropDown.Value = 'High Frequency';

            % Create ImageResXkmEditFieldLabel
            app.ImageResXkmEditFieldLabel = uilabel(app.CenterPanel);
            app.ImageResXkmEditFieldLabel.HorizontalAlignment = 'right';
            app.ImageResXkmEditFieldLabel.Position = [1 477 104 22];
            app.ImageResXkmEditFieldLabel.Text = 'Image Res. X [km]';

            % Create ImageResXkmEditField
            app.ImageResXkmEditField = uieditfield(app.CenterPanel, 'numeric');
            app.ImageResXkmEditField.ValueChangedFcn = createCallbackFcn(app, @ImageResXkmEditFieldValueChanged, true);
            app.ImageResXkmEditField.Position = [112 477 100 22];
            app.ImageResXkmEditField.Value = 20;

            % Create ImageResYkmEditFieldLabel
            app.ImageResYkmEditFieldLabel = uilabel(app.CenterPanel);
            app.ImageResYkmEditFieldLabel.HorizontalAlignment = 'right';
            app.ImageResYkmEditFieldLabel.Position = [222 477 103 22];
            app.ImageResYkmEditFieldLabel.Text = 'Image Res. Y [km]';

            % Create ImageResYkmEditField
            app.ImageResYkmEditField = uieditfield(app.CenterPanel, 'numeric');
            app.ImageResYkmEditField.ValueChangedFcn = createCallbackFcn(app, @ImageResYkmEditFieldValueChanged, true);
            app.ImageResYkmEditField.Position = [332 477 100 22];
            app.ImageResYkmEditField.Value = 20;

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 3;

            % Create WidthEditFieldLabel
            app.WidthEditFieldLabel = uilabel(app.RightPanel);
            app.WidthEditFieldLabel.HorizontalAlignment = 'right';
            app.WidthEditFieldLabel.Position = [43 487 36 22];
            app.WidthEditFieldLabel.Text = 'Width';

            % Create WidthEditField
            app.WidthEditField = uieditfield(app.RightPanel, 'numeric');
            app.WidthEditField.Editable = 'off';
            app.WidthEditField.Position = [94 487 100 22];

            % Create HeightEditFieldLabel
            app.HeightEditFieldLabel = uilabel(app.RightPanel);
            app.HeightEditFieldLabel.HorizontalAlignment = 'right';
            app.HeightEditFieldLabel.Position = [41 446 40 22];
            app.HeightEditFieldLabel.Text = 'Height';

            % Create HeightEditField
            app.HeightEditField = uieditfield(app.RightPanel, 'numeric');
            app.HeightEditField.Editable = 'off';
            app.HeightEditField.Position = [96 446 100 22];

            % Create PeakFreqX1mEditFieldLabel
            app.PeakFreqX1mEditFieldLabel = uilabel(app.RightPanel);
            app.PeakFreqX1mEditFieldLabel.HorizontalAlignment = 'right';
            app.PeakFreqX1mEditFieldLabel.Position = [9 341 113 22];
            app.PeakFreqX1mEditFieldLabel.Text = 'Peak Freq X [1/m]';

            % Create PeakFreqX1mEditField
            app.PeakFreqX1mEditField = uieditfield(app.RightPanel, 'numeric');
            app.PeakFreqX1mEditField.Editable = 'off';
            app.PeakFreqX1mEditField.Position = [137 341 78 22];

            % Create WavelengthmEditFieldLabel
            app.WavelengthmEditFieldLabel = uilabel(app.RightPanel);
            app.WavelengthmEditFieldLabel.HorizontalAlignment = 'right';
            app.WavelengthmEditFieldLabel.Position = [17 278 88 22];
            app.WavelengthmEditFieldLabel.Text = 'Wavelength [m]';

            % Create WavelengthmEditField
            app.WavelengthmEditField = uieditfield(app.RightPanel, 'numeric');
            app.WavelengthmEditField.Editable = 'off';
            app.WavelengthmEditField.Position = [120 278 100 22];

            % Create PeakFreqY1mEditFieldLabel
            app.PeakFreqY1mEditFieldLabel = uilabel(app.RightPanel);
            app.PeakFreqY1mEditFieldLabel.HorizontalAlignment = 'right';
            app.PeakFreqY1mEditFieldLabel.Position = [17 310 113 22];
            app.PeakFreqY1mEditFieldLabel.Text = 'Peak Freq Y [1/m]';

            % Create PeakFreqY1mEditField
            app.PeakFreqY1mEditField = uieditfield(app.RightPanel, 'numeric');
            app.PeakFreqY1mEditField.Editable = 'off';
            app.PeakFreqY1mEditField.Position = [137 310 78 22];

            % Create DirectiondegreesEditFieldLabel
            app.DirectiondegreesEditFieldLabel = uilabel(app.RightPanel);
            app.DirectiondegreesEditFieldLabel.HorizontalAlignment = 'right';
            app.DirectiondegreesEditFieldLabel.Position = [23 245 106 22];
            app.DirectiondegreesEditFieldLabel.Text = 'Direction [degrees]';

            % Create DirectiondegreesEditField
            app.DirectiondegreesEditField = uieditfield(app.RightPanel, 'numeric');
            app.DirectiondegreesEditField.Editable = 'off';
            app.DirectiondegreesEditField.Position = [160 245 55 22];

            % Create IntensityEditFieldLabel
            app.IntensityEditFieldLabel = uilabel(app.RightPanel);
            app.IntensityEditFieldLabel.HorizontalAlignment = 'right';
            app.IntensityEditFieldLabel.Position = [43 203 50 22];
            app.IntensityEditFieldLabel.Text = 'Intensity';

            % Create IntensityEditField
            app.IntensityEditField = uieditfield(app.RightPanel, 'numeric');
            app.IntensityEditField.Limits = [0 100];
            app.IntensityEditField.Position = [108 203 100 22];

            % Create SaveFrequencyCheckBox
            app.SaveFrequencyCheckBox = uicheckbox(app.RightPanel);
            app.SaveFrequencyCheckBox.ValueChangedFcn = createCallbackFcn(app, @SaveFrequencyCheckBoxValueChanged, true);
            app.SaveFrequencyCheckBox.Enable = 'off';
            app.SaveFrequencyCheckBox.Visible = 'off';
            app.SaveFrequencyCheckBox.Text = 'Save Frequency?';
            app.SaveFrequencyCheckBox.Position = [59 167 116 22];

            % Create FindPeakFrequencyButton
            app.FindPeakFrequencyButton = uibutton(app.RightPanel, 'push');
            app.FindPeakFrequencyButton.ButtonPushedFcn = createCallbackFcn(app, @FindPeakFrequencyButtonPushed, true);
            app.FindPeakFrequencyButton.Interruptible = 'off';
            app.FindPeakFrequencyButton.Enable = 'off';
            app.FindPeakFrequencyButton.Position = [51 384 129 23];
            app.FindPeakFrequencyButton.Text = 'Find Peak Frequency';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = WindStreakWavelengths_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end