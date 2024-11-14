---
layout: tutorial_hands_on

title: Tracking of mitochondria and capturing mitoflashes
zenodo_link: https://zenodo.org/records/14071552
questions:
- What are mitoflashes, and why are they relevant for understanding mitochondrial function?
- How can bioinformatics and image analysis tools help in tracking and analyzing mitochondrial dynamics?
objectives:
- Understand the biological significance of mitoflashes and their implications for cellular health.
- Learn to track mitochondrial movements in live-cell imaging data.
- Use image analysis tools to detect and quantify mitoflashes.
time_estimation: 1H
key_points:
- Mitoflashes are superoxide events in mitochondria that signal functional states and stress responses.
- Bioinformatics tools can facilitate the visualization, tracking, and quantitative analysis of these events.
- Proper tracking and analysis of mitoflashes contribute to understanding mitochondrial behavior and health in cells.

contributions:
  authorship:
    - dianichj
    - kostrykin
tags:
  - bioimaging
  - mitoflash
  - mitochondria
    
---

# Introduction

Mitochondria act like fuel stations for the cell, supplying the energy needed to keep it functioning and healthy. During certain activities, they can produce bursts of **superoxide**, known as '**mitoflashes**.' These short, intense events occur in individual mitochondria and can be observed in cardiomyocytes, skeletal muscle, hippocampal neurons, chondrocytes, isolated mitochondria, and among other types of eukaryotic cells using confocal microscopy. Commonly detected with a mitochondria-targeted circularly permuted fluorescent protein (mt-cpYFP), mitoflashes provide real-time insights into mitochondrial respiration function _in situ_ and act as a biosensor for superoxide levels, reflecting the activity of the mitochondrial electron transport chain.

Mitoflashes are triggered by elevated **reactive oxygen species (ROS)** levels, and various physiological and stress-related signals including fluctuations in mitochondrial membrane potential, transient openings of the mitochondrial permeability transition pore (mPTP), calcium level changes, and bioenergetic stress (like nutrient deprivation or high metabolic demand).{% raw %}`{% cite Wang2022 %}`{% endraw %} Additionally, they can be induced during specific cellular processes, like differentiation and certain developmental stages, where mitochondrial function is tightly regulated. This burst event activates the mPTP, causing a depolarization of the mitochondrial membrane potential (ΔΨm) and a mild alkalization of the matrix.{% raw %}`{% cite Feng2019 %}`{% endraw %} While mitoflashes signal mitochondrial activity and ROS changes, they do not precisely quantify ROS levels or other cellular signatures. These events, however, are able to distinguish active from static mitochondria, making them valuable biomarkers for tracking mitochondrial health and function.

Importantly, the frequency and kinetics of mitoflashes hold physiological and pathophysiological implications. They correlate with key processes such as muscle contraction, cell differentiation, neuron development, wound healing, and lifespan prediction. The frequency and characteristics of mitoflashes vary by cell type; for example, adult cardiomyocytes display approximately 3.8 ± 0.5 mitoflashes, while primary cultured hippocampal neurons show around 31 ± 4 per cell.{% raw %}`{% cite Li2020 %}`{% endraw %}

In this tutorial, you will learn to track mitochondria in live-cell imaging data and detect mitoflashes using general Galaxy tools for image analysis. You will work with time-lapse microscopy data, often stored as TIFF files with image stacks, to observe and analyze mitochondrial events across multiple time points. By identifying these events and quantifying their frequency through intensity measurements fitted to a curve, you'll gain insights into mitochondrial behavior and activity over time.

> <agenda-title></agenda-title>
>
> In this tutorial, we will cover:
>
> 1. Understanding the concept and biological relevance of mitoflashes.
> 2. Processing live-cell imaging data for mitochondrial tracking.
> 3. Detecting and analyzing mitoflashes with Galaxy tools.
>
{: .agenda}

# Preparing Your Data

First, we need to upload the data we'll work with. Ensure that you have the necessary files prepared from Zenodo or a shared data library within Galaxy.

## Data Upload

> <hands-on-title>Data Upload</hands-on-title>
>
> 1. Create a new history for this tutorial in Galaxy.
>
>    {% snippet faqs/galaxy/histories_create_new.md %}
>
> 2. Import the mitoflash imaging data from [Zenodo](https://zenodo.org/records/14071552) or from the shared data library:
>    - **Important:** Choose the correct data type if prompted.
>
>    ```
>    https://zenodo.org/records/14071552/files/mitoflashes_8bit.tiff
>    ```
>
>    {% snippet faqs/galaxy/datasets_import_via_link.md %}
>    
>    {% snippet faqs/galaxy/datasets_import_from_data_library.md %}
>
> 3. Rename the datasets to keep track of them easily, e.g., "Mitoflash."
> 4. Confirm that the datatypes are correct for each file:
>    - `mitoflashes_8bit.tiff` should be an image in **tiff** file format.
>
>    {% snippet faqs/galaxy/datasets_change_datatype.md datatype="datatypes" %}
> 5. Tag each dataset with a label like "mitoflash_1" for easy identification later if you are working with multiple images.
>
{: .hands_on}

# Analyzing Mitochondrial Movement

In this section, we will focus on identifying mitochondrial regions in a time-lapse sequence by detecting spots based on local intensity maxima. This step provides insights into mitochondrial energy production and cellular health dynamics.

## Step 1: Detecting Mitochondrial Regions

> <hands-on-title>Detecting Mitochondrial Regions</hands-on-title>
>
> 1. {% tool [Spot Detection](toolshed.g2.bx.psu.edu/repos/imgteam/spot_detection_2d/ip_spot_detection_2d/0.0.1) %} with the following recommended parameters:
>    - {% icon param-file %} *"Image input"*: `mitoflashes_8bit.tiff`
>    - **Starting time point**: `1` (first frame in the stack)
>    - **Ending time point**: `0` (use `0` to process until the last frame)
>    - **Intensity measurement method**: Set to `Smoothed` for a more averaged intensity or `Robust` for resilience to outliers.
>    - **Threshold**: Start at 10%; lower to 5-8% to catch weaker signals, or raise to 15-20% to focus on the strongest signals.
>    - **Gaussian filter sigma**: Use a value around `1` to suppress noise; increase to `1.5` if noise is high.
>    - **Boundary pixels**: Set to `10` to ignore spots within the image edges, adjusting as needed for image size.
>
>    This tool detects mitochondria as spots or 'mitoflashes' based on intensity maxima, identifying them as distinct regions. Adjusting the threshold parameter can improve the accuracy of spot detection, allowing for better identification of mitoflash events.
>
{: .hands_on}


## Step 2: Tracking Mitochondrial Movement

Mitochondria are dynamic organelles, constantly moving, and changing position within the cell. Without tracking, intensity measurements could be inconsistent or misleading, as they might reflect overlapping signals from different mitochondria rather than continuous changes in a single organelle. 

By linking each mitochondrion’s position across frames, we ensure that intensity fluctuations represent true changes within the same mitochondrial structure, enabling precise analysis of events like mitoflashes.

> <hands-on-title>Tracking Mitochondrial Movement</hands-on-title>
>
> 1. {% tool [Perform linking in time series (nearest neighbors)](toolshed.g2.bx.psu.edu/repos/imgteam/points_association_nn/ip_points_association_nn/0.0.3-2) %} with the following recommended parameters:
>    - {% icon param-file %} *"Coordinates (and intensities) of input points"*: Output from the **Spot Detection** tool.
>    - **Neighborhood size**: Set to `6` pixels as a starting value. Adjust within `1-10` pixels based on the density of points and proximity between spots across frames.
>    - **Intensity threshold**: A recommended starting value is `25%` of the global maximum intensity. Increase to `30-40%` for stricter filtering if spots have low intensity.
>    - **Minimum track length**: Use `50%` of the sequence length as a baseline. Adjust based on the expected duration of mitoflash events.
>    
>    This tool links detected spots across frames to track movement. The **Neighborhood size** parameter controls the pixel range for associating points between frames. Reducing the **Intensity threshold** filters out weaker signals, reducing the number of spurious tracks.
>
{: .hands_on}

# Detecting Mitoflashes

Mitoflashes are identified based on sudden changes in fluorescence intensity in mitochondria, signifying superoxide bursts. We will use a curve-fitting tool to capture these fluctuations and measure their characteristics.

## Step 3: Curve Fitting for Mitoflash Detection

> <hands-on-title>Mitoflash Detection</hands-on-title>
>
> 1. {% tool [Perform curve fitting](toolshed.g2.bx.psu.edu/repos/imgteam/curve_fitting/ip_curve_fitting/0.0.3-2) %} with the following parameters:
>    - {% icon param-file %} *"File name of input data points (xlsx)"*: Output from the **Perform linking in time series (nearest neighbors)** tool.
>    - **Degree of the polynomial function**: Set to `2nd degree` to capture intensity peaks that characterize mitoflash events.
>    - **Penalty**: Choose *Least absolute deviations (LAD)* for robust fitting to intensity fluctuations.
>    - **Alpha**: Set a significance level, such as `0.01`, to generate assistive curves if needed.
>
>    This step applies polynomial curve fitting to model intensity fluctuations over time, identifying mitoflash events when intensity values exceed the fitted curve by the given significance level. Key parameters to analyze are **Amplitude** (peak intensity), **Tpk** (time to peak), and **T50** (duration). These values provide initial insights into mitochondrial function, with further interpretation outlined in the following section.
>
{: .hands_on}

## Analysis and Interpretation of Results

Finally, now you have your results table ready for analysis! The output is an Excel file containing the columns **FRAME**, **POS_X**, **POS_Y**, **INTENSITY**, **CURVE**, and **CURVE_A**. This information is available for all detected spots in your image stack. 

With our data results, we can analyze their frequency, duration, and intensity. This data helps us understand the physiological significance of mitoflashes in processes like muscle contraction, neuron development, and wound healing.

![Curve fitting results mitoflash](../../images/detection-of-mitoflashes/Curve_fitting_results_mitoflash.png "Mitoflash Curve Fitting Results: Data for plotting.")

### Key Parameters for Analysis and Plotting

1. **FRAME**: Represents time points in the data, with each row corresponding to a frame in the time-lapse sequence. Use **FRAME** as the x-axis for time-based plotting.

2. **POS_X** and **POS_Y**: These columns provide positional coordinates of each detected mitoflash, allowing visualization of mitochondrial movement and spatial distribution within the cell.

3. **INTENSITY**: Shows the raw intensity values for each mitochondrion at each time point. Plotting **INTENSITY** against **FRAME** reveals fluctuations over time, with peaks indicating mitoflash events.

4. **CURVE** and **CURVE_A**: Contain fitted curve data that smooths out noise to highlight true intensity peaks. **CURVE** is the main fit, while **CURVE_A** may show adjusted fits if available.
   
   - **Amplitude (F/F0)**: The peak value in **CURVE** or **CURVE_A**, representing the magnitude of each mitoflash. Higher amplitudes indicate stronger bursts, which can have biological significance.
   - **Tpk (Time to Peak)**: The frame where **CURVE** or **CURVE_A** reaches maximum intensity, indicating the speed of each mitoflash.
   - **T50 (Duration)**: The frames where the curve values are at least half of the peak value, representing the mitoflash duration. Longer durations may reflect sustained mitochondrial activity.

### Suggested Plots

- **Mitoflash Intensity Over Time**: Plot **FRAME** (x-axis) against **INTENSITY** or **CURVE** (y-axis) to observe intensity fluctuations over time, with peaks marking mitoflash events.
  
- **Amplitude and Duration Analysis**: Create a histogram or scatter plot of **Amplitude** (from **CURVE** peaks) and **T50** to explore the distribution of mitoflash magnitudes and durations.

- **Spatial Mapping of Mitoflashes**: Use **POS_X** and **POS_Y** for a 2D plot, with each point representing a mitoflash location. Color-code points by **Amplitude** to show intensity distribution across the cell.

> <details-title>More details about mitoflash dynamics</details-title>
>
> Mitoflashes represent brief but significant superoxide burst events. They provide insight into mitochondrial responses to energy demands and stress, acting as indicators of mitochondrial health. The kinetics of mitoflashes, including frequency and parameters like amplitude, Tpk, and T50, are influenced by cellular conditions, such as bioenergetics, starvation, oxidative stress, aging, and metabolic diseases.
>
{: .details}

These analyses and visualizations provide an understanding of mitochondrial activity and responses to cellular conditions, enabling insights into mitochondrial health and function in various states.

![Image of the workflow](../../images/detection-of-mitoflashes/Workflow_mitoflash.png "Overview of the workflow for detecting mitoflash using Galaxy tools.")

# Conclusion

In this tutorial, we have covered key techniques for tracking mitochondria and detecting mitoflashes. By processing and analyzing live-cell imaging data, you can gain valuable insights into mitochondrial behavior and health in cells. Tracking mitoflashes can contribute to studies in metabolism, aging, and diseases linked to mitochondrial dysfunction in verious cell types and eukaryotic organisms.
