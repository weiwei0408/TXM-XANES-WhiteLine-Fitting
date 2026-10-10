**ImgViewer\_peak — TXM-XANES White-Line Peak Fitting GUI**

\[!\[MATLAB](https://img.shields.io/badge/MATLAB-R2022a-blue.svg)](https://www.mathworks.com/products/matlab.html)

ImgViewer\_peak is a MATLAB graphical user interface for processing and analyzing TXM-XANES (Transmission X-ray Microscopy – X-ray Absorption Near-Edge Structure) image stacks. It enables nanoscale chemical state imaging of transition metal oxides (e.g., Ni90 cathodes) by performing white-line peak fitting on a per-pixel basis.

This code is the companion software for the manuscript:

Efficient Chemical State Imaging of Ni90 Cathodes by In Situ TXM-XANES White-Line Peak Fitting

DOI: 10.1039/D6AN00925E



**Features**

* Import image stacks from .mat files or TIF/TIFF sequences.
* Apply spatial smoothing (Savitzky-Golay, average, median, Gaussian) to each pixel spectrum.
* Interactive ROI selection for data reduction.
* Automatic parameter estimation for skewed Gaussian peak fitting.
* Parallelized per-pixel fitting using lsqcurvefit (requires Parallel Computing Toolbox).
* Visualize fitted parameters (e.g., peak center xc, R²) as 2D maps and histograms.
* Area normalization with baseline subtraction.
* Extract reference spectra from user-defined regions.
* Save fitting results (.mat) and normalized stacks.



**System Requirements**

MATLAB R2022a (or later; earlier versions may work but have not been tested).

Required toolboxes:

1. Image Processing Toolbox (for imgaussfilt, imshow, roipoly, etc.)
2. Parallel Computing Toolbox (recommended for fast fitting; otherwise parfor runs serially)
3. Statistics and Machine Learning Toolbox (for prctile, smooth, etc.)



**Dependencies**

The following files must be present in the same folder (or on the MATLAB path):

|File	|Description|
|-|-|
|ImgViewer\_peak.m|Main GUI code (this file).|
|disp\_img\_in\_ImgViewer.m|Helper function to display 2D images with thresholds and colormaps.|
|ROI\_selection\_for\_QTXMXANES.m|Interactive ROI selection tool.|
|skewgauss.m	|Skewed Gaussian function used for fitting.|
|WriteFile.m	|Export image data to various formats.|
|writeBIN.m, writeBINfile.m	(Optional)| Only needed if you export .bin/.bim files.|

If any of these are missing, the GUI will report an error when the corresponding feature is used.



**Getting Started**

1. Clone or download this repository to your local machine.
2. Open MATLAB and navigate to the project folder.
3. Run the GUI by typing in the Command Window: *ImgViewer\_peak*，or double-click ImgViewer\_peak.fig.
4. Use the interface buttons in the following recommended order:

**Step 1** – Import Data

Click Browse → choose Import MAT File or Import TIF/TIFF Sequence.

For MAT files, the file must contain a 3D array Imgstack (height × width × energy) and a 1D array Es (energy axis, same length as the third dimension).

For TIF sequences, the filenames should contain energy values (e.g., \_7120.00\_eV.tif) for automatic energy extraction; otherwise, indices are used.

**Step 2** – Optional Smoothing

Choose a filter method and window size, then click Apply Smooth.

**Step 3** – ROI Selection (Optional)

Click ROI Selection to draw a polygon on the white-line image. This removes background pixels and speeds up fitting.

**Step 4** – Parameter Estimation

Enter the white-line energy (E\_white) and a fit window (Fit\_min, Fit\_max).

Click Estimate to compute initial guesses for all pixels.

**Step 5** – Gaussian Fitting

Click Gaussian Fitting. The fitting runs in parallel (if available) and saves the results in handles.GS\_Result.

**Step 6** – Visualize Results

Click Show xcmapping to view the fitted peak-center map.

Click Show R2 mapping to view the R² goodness-of-fit map.

**Step 7** – Area Normalization (Optional)

Set Pre\_min, Pre\_max (baseline region) and Integral\_min, Integral\_max (integration region).

Click Area integral to compute area-normalized stacks.

Click Show Area map to visualize the integrated area.

**Step 8** – Reference Spectra

After area normalization, click Extract Ref Spec to extract an average reference spectrum from a user-defined threshold range.

Use Plot Refs and Save Ref Specs to inspect and export reference spectra.

**Step 9** – Save Results

Click Save Fit Result to export the full fitting structure (GaussianFittingResult.mat).

Click SaveNormStack to export the normalized image stack.



**Data Format**

* Input .mat file

*matlab*

*Imgstack   % 3D array: height × width × nEnergy*

*Es         % 1D array: energy values (eV), length = nEnergy*

Optionally, you may also include filenames (cell array of strings) for reference.

* TIF/TIFF sequence

All images must have the same spatial dimensions.

Energy values are extracted from filenames using a regular expression (e.g., \_7120.00\_eV or 7120).

Files are sorted alphabetically before extraction; if energy order is not monotonic, you will be prompted to re-sort.



**Note on Language**

The GUI interface and all console messages are in English. Some code comments remain in Chinese; they do not affect functionality. If you need a fully English-commented version, please feel free to open an issue or submit a pull request.



**Data Availability**

To facilitate testing the GUI, two small cropped sample datasets (*data/Sample\_data1.rar and Sample\_data2.rar*) is included in this repository. 

The complete raw experimental datasets generated and analyzed during the current study are not publicly available due to their large file size, but are available from the corresponding author on reasonable request.  Please refer to the Data Availability Statement in the published paper for more details.



**Citation**

If you use this code in your research, please cite:

Efficient Chemical State Imaging of Ni90 Cathodes by In Situ TXM-XANES White-Line Peak Fitting

DOI: 10.1039/D6AN00925E



&#x20;**License**

This project is released under the MIT License. See the LICENSE file for details.



**Contact**

For questions or bug reports, please contact:

Yangwei Huang

Shanghai Institute of Applied Physics, Chinese Academy of Sciences

Email: *huangyanwei0408@163.com*



**Acknowledgements**

This work was financially supported by the National Key Research and Development Program of China (*Grant No. 2021YFA1600700*) and the National Natural Science Foundation of China (*Grant No. 12275343*).









