# SAR Wind Streak Analysis

A MATLAB tool for analyzing wind streaks in Synthetic Aperture Radar (SAR) imagery from the Sentinel-1 satellite mission. The tool uses 2D Fourier analysis to extract the dominant wavelengths and propagation directions of ocean waves associated with wind streaks, with an interactive GUI for streamlined exploration.

Developed as the final project for the Image Processing course (Ruppin Academic Center, 2024–2025).

## Overview

Wind streaks are wind-driven features visible on the ocean surface, with wavelengths ranging from hundreds of meters to a few kilometers. They carry information about near-surface wind fields and atmospheric–ocean interactions. This project processes 25 km × 25 km Sentinel-1 SAR vignettes (≈5 m × 5 m resolution) to identify both:

- **Low-frequency wavelengths** (≈900 m – 2.6 km) — associated with wind streaks themselves
- **High-frequency wavelengths** (≈100 – 300 m) — typical of open-ocean wave patterns

## Methodology

### Preprocessing
- Loading Sentinel-1 SAR vignettes into MATLAB
- Extracting image metadata and computing pixel resolution
- Grayscale conversion and cropping to even dimensions for FFT compatibility

### Frequency-Domain Analysis
- 2D Fast Fourier Transform (FFT) with `fftshift` to center the DC component
- Logarithmic magnitude spectrum for improved peak visibility

### Peak Detection
Two complementary algorithms:

**Manual peak detection** — user selects a region of interest on the magnitude spectrum; the algorithm locates the dominant peak in that region and computes the corresponding wavelength and direction from its (fx, fy) coordinates.

**Automatic peak detection** — applies a low-pass Gaussian filter to separate low- and high-frequency components, suppresses DC leakage with an additional very-low-pass mask, divides each filtered image into windows, and identifies dominant peaks across the spectrum.

### Visualization
Detected wave components are rendered as direction-and-magnitude arrows overlaid on the magnitude spectrum, the original image, or the filtered images — with arrow length scaled to peak intensity.

## GUI Features

The included graphical interface allows users to:

- Upload and display SAR images
- Run 2D FFT and view the magnitude spectrum
- Apply binary thresholding to assist peak identification
- View low-pass and high-pass filtered images
- Overlay detected wavelengths and directions on multiple views
- Adjust image resolution and inspect pixel-level dimensions

## Results

Detected wavelengths matched theoretical predictions for wind streaks. Low-frequency wavelengths (900 m – 2.6 km) were consistent with wind-driven surface patterns, while high-frequency wavelengths (100 – 300 m) aligned with typical open-ocean wave behavior. Lower-resolution PNG inputs and DC leakage were the main sources of error in low-frequency estimation.

## Tech Stack

- **MATLAB** — image processing, FFT, GUI development
- **Sentinel-1 Wave Mode Level 2 data** ([SEANOE dataset](https://www.seanoe.org/data/00456/56796/))

## Limitations & Future Work

- Low-frequency analysis is sensitive to DC leakage; more advanced filtering would improve stability
- Higher-resolution inputs would sharpen wavelength estimates
- The automatic peak detection could be extended with adaptive windowing

## References

1. Sentinel-1 Wave Mode Level 2 data — [SEANOE](https://www.seanoe.org/data/00456/56796/)
2. NASA Earthdata — [SAR: Synthetic Aperture Radar Basics](https://www.earthdata.nasa.gov/learn/earth-observation-data-basics/sar)
3. Copernicus SentiWiki — [Sentinel-1 Mission Overview](https://sentiwiki.copernicus.eu/web/s1-mission)
4. Horstmann, J., Koch, W., & Lehner, S. — *Ocean Wind Fields from SAR*, ESA EOQ 59
5. Earle, S. — *Shorelines: Waves*, LibreTexts Geosciences

## Author

**Hadassah Faur** — B.Sc. Electrical and Electronics Engineering, Ruppin Academic Center
