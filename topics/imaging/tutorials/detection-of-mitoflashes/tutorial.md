---
layout: tutorial_hands_on

title: Tracking of mitochondria and capturing mitoflashes
zenodo_link: ''
questions:
- What are mitoflashes, and why are they important for understanding mitochondrial function?
- How can bioinformatics and image analysis tools help in tracking and analyzing mitochondrial dynamics?
objectives:
- Understand the biological significance of mitoflashes and their implications for cellular health.
- Learn to track mitochondrial movements in live-cell imaging data.
- Use image analysis tools to detect and quantify mitoflashes.
time_estimation: 1H
key_points:
- Mitoflashes are superoxide burst events in mitochondria that signal functional states and stress responses.
- Bioinformatics tools can facilitate the visualization, tracking, and quantitative analysis of these events.
- Proper tracking and analysis of mitoflashes contribute to understanding mitochondrial behavior and health in cells.
contributors:
- Diana Chiang Jurado
- Leonid Kostrykin

---

# Introduction

Mitochondria act like fuel stations for the cell, supplying the energy required to keep it functioning and healthy. During certain activities, they can produce bursts of superoxide, known as 'mitoflashes.' These short, intense events happen in individual mitochondria and can be observed in live heart cells and other types of cells using a confocal microscope.These events, commonly detected with a mitochondria-targeted circularly permuted fluorescent protein (mt-cpYFP), provide real-time insights into mitochondrial respiration function *in situ* and serve as a biosensor for superoxide levels, which reflect the activity of the mitochondrial electron transport chain.

Mitoflashes are triggered by an increase in basal reactive oxygen species (ROS) levels in mitochondria. This burst event activates the mitochondrial permeability transition pore (mPTP), causing a depolarization of the mitochondrial membrane potential (ΔΨm) and a mild alkalization of the matrix. Although mitoflashes can indicate changes in ROS, they do not precisely quantify ROS levels. These events can reveal active mitochondria from static ones, marking mitoflashes as potent biological markers for tracking mitochondrial health and function.

The frequency and kinetics of mitoflashes hold significant physiological and pathophysiological implications. They correlate with key processes such as muscle contraction, cell differentiation, neuron development, wound healing, and lifespan prediction. The frequency and characteristics of mitoflashes vary by cell type; for example, adult cardiomyocytes display approximately 3.8 ± 0.5 mitoflashes, while primary cultured hippocampal neurons show around 31 ± 4 per cell.

In this tutorial, we will explore the techniques required to track mitochondria in live-cell imaging data and detect mitoflashes, using specialized bioinformatics tools for image analysis. You will learn how to process time-lapse microscopy data, detect mitochondrial events, and quantify their frequency and characteristics.

> In this tutorial, we will cover:
>
> 1. Understanding the concept and biological relevance of mitoflashes.
> 2. Processing live-cell imaging data for mitochondrial tracking.
> 3. Detecting and analyzing mitoflashes with bioinformatics tools.
> {: .agenda}

# Preparing Your Data

First, we need to upload the data we'll work with. Ensure that you have the necessary files prepared from Zenodo or a shared data library within Galaxy.

## Data Upload

> <hands-on-title>Data Upload</hands-on-title>
>
> 1. Create a new history for this tutorial in Galaxy.
> 2. Import the mitoflash imaging data from [Zenodo]({{ page.zenodo_link }}) or from the shared data library:
>
>    ```
>    File1: Mitochondrial_tracking_data.tiff
>    File2: Mitoflash_events.csv
>    ```
>
>    **Tip**: If any extra files are included, remove them to keep the workspace clean.
>
>    {% snippet faqs/galaxy/datasets_import_via_link.md %}
>    {% snippet faqs/galaxy/datasets_import_from_data_library.md %}
>
> 3. Rename the datasets to keep track of them easily, e.g., "Mitochondrial Images" and "Mitoflash Events."
> 4. Confirm that the datatypes are correct for each file:
>    - `Mitochondrial_tracking_data.tiff` should be an image file format.
>    - `Mitoflash_events.csv` should be in tabular format.
>
>    {% snippet faqs/galaxy/datasets_change_datatype.md datatype="datatypes" %}
> 5. Tag each dataset with a label such as "mitoflash" for easy identification later.
>
{: .hands_on}

# Analyzing Mitochondrial Movement

In this section, we will focus on tracking mitochondrial movements across time-lapse images. This step provides insights into mitochondrial dynamics, which are essential for understanding their role in energy production and cellular health.

## Step 1: Detecting Mitochondrial Regions

> <hands-on-title>Detecting Mitochondrial Regions</hands-on-title>
>
> 1. {% tool [Spot Detection](toolshed.g2.bx.psu.edu/repos/imgteam/spot_detection/ip_spot_detection/1.0.0) %} with the following parameters:
>    - {% icon param-file %} *"Image input"*: `Mitochondrial_tracking_data.tiff`
>    - Set parameters such as "Thresholding" to optimize mitochondrial detection.
>
>    This step identifies mitochondria as distinct regions in the images. You may adjust the threshold to improve accuracy in identifying these regions.
>
{: .hands_on}

## Step 2: Tracking Mitochondrial Movement

> <hands-on-title>Tracking Mitochondrial Movement</hands-on-title>
>
> 1. {% tool [Object Tracking](toolshed.g2.bx.psu.edu/repos/imgteam/object_tracking/ip_object_tracking/2.0.1) %} with the following parameters:
>    - {% icon param-file %} *"Input detected objects"*: Output from the **Spot Detection** tool.
>    - Set "Tracking parameters" to follow mitochondrial paths over time.
>
>    **Comment**: Tracking mitochondria helps observe how they move and interact within the cell, which may reflect their functional state and interactions.
>
{: .hands_on}

# Detecting Mitoflashes

Mitoflashes are identified based on sudden changes in fluorescence intensity in mitochondria, signifying superoxide bursts. We will use a curve-fitting tool to capture these fluctuations and measure their characteristics.

## Step 3: Curve Fitting for Mitoflash Detection

> <hands-on-title>Mitoflash Detection</hands-on-title>
>
> 1. {% tool [Curve Fitting](toolshed.g2.bx.psu.edu/repos/imgteam/curve_fitting/ip_curve_fitting/0.0.1) %} with the following parameters:
>    - {% icon param-file %} *"Input data points"*: `Mitoflash_events.csv`
>
>    This step applies curve fitting to detect intensity spikes corresponding to mitoflash events. Relevant parameters include amplitude (F/F0, representing superoxide burst level), Tpk (representing superoxide burst speed), and T50 (representing burst duration).
>
{: .hands_on}

# Analysis and Interpretation

Once mitoflashes have been detected, we can analyze their frequency, duration, and intensity. This information is crucial for understanding the physiological significance of these events in processes like muscle contraction, neuron development, and wound healing.

> <details-title>More details about mitoflash dynamics</details-title>
>
> Mitoflashes represent brief but significant superoxide burst events. They provide insight into mitochondrial responses to energy demands and stress, acting as indicators of mitochondrial health. The kinetics of mitoflashes, including frequency and parameters like amplitude, Tpk, and T50, are influenced by cellular conditions, such as bioenergetics and starvation.
>
{: .details}

# Conclusion

In this tutorial, we have covered key techniques for tracking mitochondria and detecting mitoflashes. By processing and analyzing live-cell imaging data, you can gain valuable insights into mitochondrial behavior and health in cells. Tracking mitoflashes can contribute to studies in metabolism, aging, and diseases linked to mitochondrial dysfunction.
