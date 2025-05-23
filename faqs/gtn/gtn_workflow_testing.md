---
title: Adding workflow tests with Planemo
area: contributors
layout: faq
box_type: tip
contributors: [hexylena]
---

### Ensuring a Tutorial has a Workflow

1. Find a tutorial that you're interested in, that **doesn't currently have tests.**

   This tutorial has a workflow (`.ga`) and a test, notice the `-tests.yml` that has the same name as the workflow `.ga` file.

   ```
   machinelearning/workflows/machine_learning.ga
   machinelearning/workflows/machine_learning-tests.yml
   ```

   You want to find tutorials without the `-tests.yml` file. The workflow file might also be missing.

2. Check if it has a workflow (if it does, skip to step 5.)
3. Follow the tutorial
4. Extract a workflow from the history
5. Run that workflow in a new history to test

### Extract Tests (Online Version)

If you are on UseGalaxy.org or another server running 24.2 or later, you can use [PWDK](https://pwdk.apps.galaxyproject.eu/), a version of planemo running online to generate the workflow tests.

However if you are on an older version of Galaxy, or a private Galaxy server, then you'll need to do the following:

### Extract Tests (Manual Version)

6. Obtain the workflow invocation ID, and your API key (User → Preferences → Manage API Key)

   ![screenshot of the workflow invocation page. The user drop down shows where to find this page, and a red box circles a field named "Invocation ID"]({% link faqs/gtn/images/invocation.png %})

7. Install the latest version of `planemo`

   ```
   # In a virtualenv
   pip install planemo
   ```

8. Run the command to initialise a workflow test from the `workflows/` subdirectory - if it doesn't exist, you might need to create it first.

   ```
   planemo workflow_test_init --from_invocation <INVOCATION ID> --galaxy_url <GALAXY SERVER URL> --galaxy_user_key <GALAXY API KEY>
   ```

   This will produce a folder of files, for example from a testing workflow:

   ```
   $ tree
   .
   ├── test-data
   │   ├── input dataset(s).shapefile.shp
   │   └── shapefile.shp
   ├── testing-openlayer.ga
   └── testing-openlayer-tests.yml
   ```

### Adding Your Tests to the GTN

9. You will need to check the `-tests.yml` file, it has some automatically generated comparisons. Namely it tests that output data matches the test-data exactly, however, you might want to replace that with assertions that check for e.g. correct file size, or specific text content you expect to see.

10. If the files in test-data are already uploaded to Zenodo, to save disk space, you should delete them from the `test-data` dir and use their URL in the `-tests.yml` file, as in this example:

    ```yaml
    - doc: Test the M. Tuberculosis Variant Analysis workflow
      job:
         'Read 1':
            location: https://zenodo.org/record/3960260/files/004-2_1.fastq.gz
            class: File
            filetype: fastqsanger.gz
    ```

11. Add tests on the outputs! Check the [planemo reference if you need more detail](https://planemo.readthedocs.io/en/latest/test_format.html).

    ```yaml
    - doc: Test the M. Tuberculosis Variant Analysis workflow
      job:
         # Simple explicit Inputs
         'Read 1':
            location: https://zenodo.org/record/3960260/files/004-2_1.fastq.gz
            class: File
            filetype: fastqsanger.gz
      outputs:
        jbrowse_html:
          asserts:
            has_text:
              text: "JBrowseDefaultMainPage"
        snippy_fasta:
          asserts:
            has_line:
              line: '>Wildtype Staphylococcus aureus strain WT.'
        snippy_tabular:
          asserts:
            has_n_columns:
              n: 2
    ```

12. Contribute all of those files to the GTN in a PR, adding them to the `workflows/` folder of your tutorial.
