Manuscript: "Infectious Severe Acute Respiratory Syndrome Coronavirus 2 (SARS-CoV-2) in Exhaled Aerosols and Efficacy of Masks During Early Mild Infection"
Oluwasanmi O Adenaiye, Jianyu Lai, P Jacob Bueno de Mesquita, Filbert Hong, Somayeh Youssefi, Jennifer German, S-H Sheldon Tai, Barbara Albert, Maria Schanz, Stuart Weston, Jun Hang, Christian Fung, Hye Kyung Chung, Kristen K Coleman, Nicolae Sapoval, Todd Treangen, Irina Maljkovic Berry, Kristin Mullins, Matthew Frieman, Tianzhou Ma, Donald K Milton, University of Maryland StopCOVID Research Group
Clinical Infectious Diseases, 2021
ciab797
https://doi.org/10.1093/cid/ciab797

This repository is being used to store source data and R scripts that will be used to merge and clean files in order to create the tables and plots for the manuscript.

## OVERVIEW:

Sources consist of:
1. The de-identified StopCOVID REDCap projects ("nCoV Surveillance 2.2 with arms", "Daily Surveys COVID-19 Surveillance","G-II COVID project")
2. LIMS sample information and PCR experiment information (merged with some clinical data: temp, sx, masks)
3. Thermo Cloud qPCR experiment information
4. Serology results from UMB UMMC
5. Culture results from UMB Frieman Lab
6. Sequencing results from UMB IGS and WRAIR 

Most of this lives in source_data and its subfolders. Some things live in OBJbox and some are part of StopCOVID operations (separate repositories, still live).

Primary merging:

7. Merger_file2 assembles all the source files (except the sequencing variant results) and outputs cov_pcr_sera_YYYYMMDD.RDS

8. cov_pcr_subsets.Rmd identifies which samples sets are "complete" per study-id/sample-day and which are "paired" complete sets. It also identifies yesmask and nomask sets. It outputs copies of the cov_pcr_sera subsetted/restricted to yesmask, nomask, paired sets.

Secondary merging:

9. cov_pcr_sera then gets further subsetted by Data_Analysis/scripts/fig_S1_flowchart.Rmd, which describes what the cohort is and determines which participants are actually included in the figures and tables. The results are stored in working_files/s1_datasets, and the official list of participants (and their serological status) is in working_files/keysubjectsplus.csv.

10. s1_cov_pcr_sera files then are processed by comb_then_split.Rmd. The qpcr replicate data frame is merged with the pcr_screen, demohist, and serology datasubsets to create so-called rpr (replicate-per-row) files in the working_files subdirectory for nomask, paired, and nonpaired (union of yesmask and nomask) instances. The spr (sample-per-row) files are created from rpr via distinct(sample_id). Keysubjects_varseq (key subjects with their variant designation) is created here.

Tables and figures:  
The majority of the tables and figures use the sets in working_files, although some draw on cov_pcr_sera still.

11. fig_S1_flowchart.Rmd is run first because it is part of secondary merging.

12. figs_1_2_s7_s8_s11_correlation_violin.Rmd, figs_s3_s4_s5_temp_sx_barplot.Rmd, fig_s6_sxonset_to_enrollment.Rmd, fig_s12_probability_culture.Rmd, table_1_demo_sx.Rmd, table_2_seroneg_viral_quant.Rmd, table_3_part1_pred_nonpaired.Rmd, table_3_part2_pred_paired.Rmd, table_s1_seropos_viral_quant.Rmd, table_s2_subanalysis_for_table_3.Rmd, table_s3_mask_type.Rmd, table_s4_paired_mask_regression.Rmd, table_s5_variants.Rmd, table_s7a_alpha_only_viral_quant.Rmd, table_s7b_non_alpha_viral_quant.Rmd, table_s7ab_merge.Rmd are run after comb_then_split in secondary merging (step 10) have created the working_files.

13. table_s2_subanalysis_for_table_3.Rmd needs to be run before table_3_part1_pred_nonpaired.Rmd and table_3_part1_pred_nonpaired.Rmd needs to be run before table_3_part2_pred_paired.Rmd. In particular, the table S2 script creates IQR/adjustment parameters that are saved in working_files/IQRadjustlist.RDS and applied in table_3_part1_pred_nonpaired.Rmd. table_3_part2_pre_paired.Rmd takes the table_3_part1_pred_nonpaired.Rmd output and adds to it to create the final repo_table3_pred_combined.csv.

14. table_s7a_alpha_only_viral_quant.Rmd and table_s7b_non_alpha_viral_quant.Rmd need to be run before table_s7ab_merge.Rmd.

15. table_s7_probability_culture.Rmd needs to be run after table_2_seroneg_viral_quant.Rmd, table_s7a_alpha_only_viral_quant.Rmd, and table_s7b_non_alpha_viral_quant.Rmd, as it takes RNA copy GM values from all three tables as input.

16. z_create_matrix.R is a function that creates the random effects matrix used for lmec in tables 2,3,s1,s2,s7a,s7b. It is sourced within scripts.

17. fixRNAscientific.R contains two formatting function. The primary one fixRNAscientific() converts A+eB scientific notation to A x 10^B if the number is greater than or equal to 1e+03. The second one GMCIparse_fixsci() deals with columns that have GM and confidence intervals so that fixRNAscientific() can be applied to them. These are used with tables 2,3,s1,s2,s7a,s7b.

A data flow diagram is in the root-level image file Data Analysis Flowchart for SARS-CoV-2 Shedding Manuscript (final).svg.  

## Detailed notes on sources:

1. Script: source_data/ncovrcmain-deident.Rmd
Inputs: REDCap projects direct API pull every 15 minutes; stored in OBJbox folder ncov-rc (restricted)  
Outputs: source_data/ncovrcmain-deid.RData (the main REDCap project) and source_data/ncovrcdt-deid.RData (the Daily Survey REDCap project).  
Notes: This script de-identifies the clinical data stored in REDCap, by stripping out those fields marked as containing PII.
 
2. LIMS samples  
    a. Script: https://gitlab.umiacs.umd.edu/prometheus/freqcheck/-/blob/master/LIMSreadspec1.Rmd (not in this repository; part of StopCOVID operations)  
Inputs: LIMS direct API pull; manual download  
Outputs: source_data/StopCOVIDsamples.csv  
"StopCOVIDsamples.csv" contains sample IDs with metadata subject id, date of collection (date_collected_sg), sample type.  
Notes: The source script runs on CI at 12am daily, and the output is stored at https://obj.umiacs.umd.edu/obj/bucket/stopcovid-samples-listing/view/.

    b. Script: https://gitlab.umiacs.umd.edu/prometheus/ncov/-/blob/master/nCoVPCRwebreport.Rmd (not in this repository; part of StopCOVID operations)  
Inputs: LIMS direct API pull; manual download  
Outputs: source_data/ncovPCRtempsxresults1.csv  
Notes: The PCR experiment data stored in LIMS is merged with the screening PCR data with temperature and Sx from REDCap main and daily survey projects. The source script is run by metascript whenever new PCR results are uploaded, and the output is stored at https://obj.umiacs.umd.edu/obj/bucket/ncov-secure-reports/view/.

    c. Script: https://gitlab.umiacs.umd.edu/prometheus/ncov/-/blob/master/nCoVG2mask.Rmd (not in this repository; part of StopCOVID operations)  
Inputs: StopCOVIDsamples.csv in OBJBox, REDCap G-II project stored in ncov-rc; manual download  
Outputs: source_data/ncovg2samplesmasksyn.csv  
Notes: The source script is runs on CI at 3am daily, and the output is stored at https://obj.umiacs.umd.edu/obj/bucket/stopcovid-samples-listing/view/.  

3. Script: source_data/qPCR fits and sample quants.Rmd  
Inputs: ThermoCloud PCR results, manually moved to OBJBox folder https://obj.umiacs.umd.edu/obj/bucket/stopcovid-samples-listing/qpcr-results/view/; source_data/qPCR fitting key.csv  
Outputs: source_data/RT-qPCR_results_YYYYMMDD.csv, source/StopCOVIDqPCRexperimentsummary.html, source/std3_allfits.csv, source/std3_multifits.csv  
Notes: ThermoCloud PCR (eds well result) files were downloaded and moved to the OBJbox folder. Fits are calculated from standard curves present in the thermo files and rxn_quant & sample_quant values are generated and outputted as RT-qPCR_results_YYYYMMDD.csv. The source script uses `qPCR fitting key.csv` as manual input to decide which standard points are to be excluded. A report StopCOVIDqPCRexperimentsummary.html is part of the output, as well as the fitting coefficients for all the qPCR experiments std3_allfits.csv and std3_multifits.csv.

4. Script: source_data/serology results processing.Rmd  
Inputs: source_data/serology files  
Outputs: source_data/serology_results_latest.csv  
Notes: Serology results (as emailed to us by Kristin at UMMC) are stored in the serology files subdirectory, and processed to yield serology_results_latest.csv.

5. Script: source_data/serology results processing.Rmd  
Inputs: source_data/culture files  
Outputs: source_data/culture_results_merged_latest.csv  
Notes: Culture results are emailed to us or comminucated to us by Stuart in Matt's lab, are stored in the culture files subdirectory, and processed to yield culture_results_merged_latest.csv.

6. Script: analytical_data_sets/variant_seq_process_1.Rmd  
Inputs: source_data/variant seq files, source_data/StopCOVIDsamples.csv  
Outputs: source_data/allseqs.csv  
Notes: merges IGS and WRAIR sequencing data. Fixes an error in IGS set.
---
Detailed notes on primary merging:

7. Script: analytical_cleaned_datasets/Merger_file2.Rmd  
Inputs: source_data files generated in steps 1-6.  
Outputs: analytical_cleaned_datasets/cov_pcr_sera_YYYYMMDD.RDS  
Notes: The main data set cov_pcr_sera_YYYYMMDD.RDS with all data is created by Merger_file2.Rmd.  
cov_pcr_sera objects (and its descendants) are generally each a list of 4 data frames as follows:
    * cov_pcr_sera[["demohist"]]: participant demographic, medical history, and other variables that only vary by study_id. One study_id per row.
    * cov_pcr_sera[["pcrscreen"]]: screening pcr from case and contact visits and weekly screening samples. One study_id-sample_date-sample_type per row. Sample types are generally MTs and saliva.
    * cov_pcr_sera[["qpcr_allsamples"]]: quantitative, calibrated pcr assays. One replicate per row.
    * cov_pcr_sera[["sero1"]]: serology. This is a relatively unaltered set.  
&nbsp;  
8. Script: analytical_cleaned_datasets/cov_pcr_sera_subsets.Rmd  
Inputs: analytical_cleaned_datasets/cov_pcr_sera_YYYYMMDD.RDS  
Outputs: analytical_cleaned_datasets/cov_pcr_sera_YYYYMMDD_{yesmask/nomask/paired}{./_complete/_complete_culture}.RDS, and cov_pcr_sera_YYYYMMDD_allsets.RDS  
Notes: cov_pcr_sera_subsets.Rmd identifies complete qpcr sets (nomask, yesmask, paired) and subsets the component data frames in cov_pcr_sera accordingly (generally by study ID). The most useful outputs are cov_pcr_sera_nomask_complete.RDS, cov_pcr_sera_yesmask_complete.RDS, and cov_pcr_sera_paired_complete.RDS.  Noncomplete RDS sets and complete_culture RDS sets are also outputted.
In creating complete sets, some missing saliva replicates are imputed in the qpcr_allsamples data frames, in this script.

    a. Script: analytical_cleaned_datasets/cov_pcr_meta.Rmd  
Inputs: analytical_cleaned_datasets/cov_pcr_sera_YYYYMMDD.RDS  
Outputs: analytical_cleaned_datasets/cov_pcr_meta_report.html  
Notes: This is file creates an HTML/javascript metadata report for cov_pcr_sera_YYYYMMDD.RDS.

## Detailed notes on secondary merging:

9. Script: Data_Analysis/scripts/fig_s1_flowchart.Rmd  
Inputs: analytical_cleaned_datasets/cov_pcr_sera_YYYYMMDD.RDS, analytical_cleaned_datasets/cov_pcr_sera_YYYYMMDD_{nomask/yesmask/paired}_complete.RDS source_data/StopCOVIDsamples.csv, Data_Analysis/working_files/order_of_repo_fig_s1_flowchart.csv  
Outputs: Data_Analysis/working_files/keysubjectsplus.csv; Data_Analysis/figure_output/repo_fig_s1_flowchart.csv; Data_Analysis/working_files/s1_datasets/s1_cov_pcr_sera_YYYYMMDD_{nomask/yesmask/paired}_complete.RDS  
Notes: Figure S1 is created first because it identifies the study IDs that are used in the other figures and tables of the paper. It uses the unsubsetted cov_pcr_sera RDS.
"order_of_repo_fig_s1_flowchart.csv" is used strictly for convenience in creating repo_fig_s1_flowchart.csv

10. Script: Data_Analysis/scripts/comb_then_split.Rmd  
Inputs: Data_Analysis/working_files/s1_datasets/s1_cov_pcr_sera_YYYYMMDD_nomask_complete.RDS, Data_Analysis/working_files/s1_datasets/s1_cov_pcr_sera_YYYYMMDD_yesmask_complete.RDS, Data_Analysis/working_files/s1_datasets/s1_cov_pcr_sera_YYYYMMDD_paired_complete.RDS, Data_Analysis/working_files/keysubjectsplus.csv, analytical_cleaned_datasets/allseqs.csv  
Outputs: in Data_Analysis/working_files: nonpaired_pcr_sx_rpr.csv, nonpaired_pcr_sx_spr.csv, nonpaired_demohist.RDS, paired_pcr_sx_rpr.csv, paired_pcr_sx_spr.csv, nomask_pcr_sx_rpr.csv, nomask_pcr_sx_spr.csv, keysubjects_varseq.csv  
    - nonpaired = yesmask and nomask complete sets, merged and deduped  
    - rpr files are based on qpcr_allscreen (replicate-per-row), merged with selected elements of pcr_screen, demohist, and sero1  
    - spr files are rpr files %>% distinct(sample_id,.keep_all=T) (turns rpr into sample-per-row)  
    - Originally rpr and spr files were further split via pos_enrollment (seropositive or seronegative at earliest blood draw timepoint), but this was moved to the individual scripts.  
    - Keysubjectsplus is joined to the variant sequencing clade data and a separate table keysubjects_varseq.csv is created.  
&nbsp;  
11. Script: analytical_cleaned_datasets/variant_seq_process1.Rmd  
Inputs: source_data/variant seq files, Data_Analysis/working_files/keysubjectsplus.csv  
Outputs: analytical_cleaned_datasets/allseqs.csv, analytical_cleaned_datasets/keysubjects_varseq.csv  
Notes: Sequencing results are emailed to us by Luke at IGS and Ina at WRAIR, are stored in the subfolder "variant seq file", and processed to yield allseqs.csv.

## Table and Figure scripts
All files are in Data_Analysis; all scripts are in Data_Analysis/scripts.
The numbering of tables and figures is different in the manuscript compared to the scripts. The key that matches them is in Data_Analysis/repo_manu_fig_key.csv.

---
Script: fig_1_2_s7_s8_s11_correlation_violin.Rmd  
Inputs: working_files/paired_pcr_sx_rpr.csv, working_files/nonpaired_pcr_sx_rpr.csv  
Outputs: figure_output/repo_fig_2_mtsalbreath_logcopies_corr.png, figure_output/repo_fig_s7_mtsalbreath_ct_corr.png, figure_output/repo_fig_s8_mt_saliva_corr.png, figure_output/repo_fig_1_violin_shedding_paired.png, figure_output/repo_fig_s11_violin_culture.png  

Five figures come out of this script.  
Two violin plots: viral copy number by sample type from paired_complete set (repo_fig_1); and viral copy number number by culture status and sample type from the nonpaired set (repo_fig_s11).  
Three sets of correlation plots: all based on the paired_complete set: MTS vs saliva in copy numbers and in Cts (repo_fig_s8); MTS & saliva vs breath in Cts (repo_fig_s7); MTS & saliva vs breath in viral copy number (repo_fig_2).  

---
Script: figs_s3_s4_s5_temp_sx_barplot.Rmd  
Inputs: working_files/keysubjectsplus.csv, analytical_cleaned_datasets/cov_pcr_sera_20210805.RDS, working_files/nonpaired_pcr_sx_spr.csv  
Outputs: figure_output/repo_fig_s3_boxplot_temp.png, figure_output/repo_fig_s4_boxplot_sx.png, figure_output/repo_fig_s5_histogram_sample_count.png  

Three figures come out of this script.  
Temperature and symptom boxplots are drawn from all visits.  
The histogram of samples draws from the nonpaired sample-per-row data set.  

---
Script: fig_s6_sxonset_to_enrollment.Rmd  
Inputs: working_files/s1_datasets/s1_cov_pcr_sera_20210805_nomask_complete.RDS, source_data/StopCOVIDsamples.csv  
Outputs: figure_output/repo_fig_s6_histogram_onset.png, figure_output/repo_fig_s6_sero_g2date_enrolldate_notsame_sids.csv, figure_output/repo_fig_s6_subdemo_g2date_enrolldate_notsame_sids.csv, figure_output/repo_fig_s6_dpog2_means_sds.csv  
Histogram showing number of days from onset of sx to enrollment date.

---
Script: fig_s12_probability_culture.Rmd  
Inputs: working_files/nonpaired_pcr_sx_spr.csv  
Outputs: figure_output/repo_fig_s12_culture_prob_log10RNA.png  
This is the probability of culture positive for saliva and MTS copy number.  

---
Script: manu_results_culture_yesmask_dates.Rmd  
Inputs: working_files/s1_datasets/s1_cov_pcr_sera_20210805_yesmask_complete.RDS, analytical_cleaned_datasets/allseqs.csv  
Outputs: table_output/manu_results_culture_yesmask_dates.txt  
Generates the sentence “Two (3%) of the 66 fine-aerosol samples collected from participants while wearing face masks were culture-positive.”  

---
Script: table_1_demo_sx.Rmd  
Inputs: working_files/nonpaired_demohist.RDS, source_data/StopCOVIDsamples.csv, working_files/nonpaired_pcr_sx_rpr.csv, working_files/nonpaired_pcr_sx_spr.csv  
Outputs: table_output/repo_table_1_demo_sx.csv, table_output/repo_table_1_antibody_compare.csv, table_output/repo_table_1_fisher_pvalues.csv, table_output/repo_table_1_footnote.txt  
This is the basic characteristics table of the study population. This was done in two parts; the first part calculates simple means and standard deviations on demographic and medical history data. The second part looks at the compound symptom scores to calculate interquartile ranges.  
The footnote is "Days since start of symptoms or first positive test if asymptomatic or presymptomatic to first breath sample; 3 subjects reported no symptoms."  

---
Script: table_2_seroneg_viral_quant.Rmd  
Inputs: working_files/nonpaired_pcr_sx_rpr.csv  
Outputs: table_output/repo_table_2_fine_below_lod_not_cultured.txt, working_files/repo_table_2_semiformatted.csv, table_output/repo_table_2_seroneg_viral_quant.csv, table_output/repo_table_2_fine_coarse_compare.txt  
This computes geometric means and standard deviations for viral copy number using LMEC (method="ML") on the nonpaired set, filtered for all seronegative participants.  
The repo_table_2_fine_below_lod_not_cultured text reads "The other culture-positive aerosol sample was one of 98 aerosol samples below the 75-copy limit of detection for RNA."  
The repo_table_2_fine_coarse_compare.txt text reads "The quantity of viral RNA in the fine-aerosol fraction was 1.9-fold (95% CI 1.2 to 2.9-fold)."  

---
Script: table_3_part1_pred_nonpaired.Rmd  
Inputs: working_files/nomask_pcr_sx_rpr.csv, working_files/nomask_pcr_sx_spr.csv, working_files/IQRadjustlist.RDS  
Outputs: table_output/repo_table_3_part1_temp.csv  
Nomask rpr filtered for seronegative participants. This is separate from table_3_part_2 because each script takes a while to run.  
Bivariate analysis of aerosol viral copy numbers against MT, saliva, cough, S-gene dropout, age, and compound sx scores. This uses the IQR adjustment values computed in table_s2 script.  

---
Script: table_3_part2_pred_paired.Rmd  
Inputs: working_files/paired_pcr_sx_rpr.csv, table_output/repo_table_3_part1_temp.csv  
Outputs: table_output/repo_table_3_pred_combined.csv  
Continuation of bivariate analysis using paired set filtered for seronegative participants.  

---
Script: table_s1_seropos_viral_quant.Rmd  
Inputs: working_files/nonpaired_pcr_sx_rpr.csv  
Outputs: table_output/repo_table_s1_seropos_viral_quant.csv  
Like table 2, this computes geometric means and standard deviations for viral copy number using LMEC (method="ML") on the nonpaired set, filtered for all seropositive participants.  

---
Script: table_s2_subanalysis_for_table_3.Rmd  
Inputs: working_files/nonpaired_pcr_sx_rpr.csv, working_files/nonpaired_pcr_sx_spr.csv  
Outputs: working_files/IQRadjustlist.RDS, table_output/repo_table_s2_alpha_variant_effect.csv  
This computes the effect of alpha variant on viral load in MT swabs and saliva, using nonpaired rpr filtered for seronegative participants. IQRadjustlist.RDS is passed on to table_3 inputs.  

---
Script: table_s3_mask_type.Rmd  
Inputs: working_files/paired_pcr_sx_rpr.csv  
Outputs: table_output/repo_table_s3_mask_type.csv  
This summarizes the mask types that participants wore in the G-II sample collection visits.  

---
Script: table_s4_paired_mask_regression.Rmd  
Inputs: working_files/paired_pcr_sx_rpr.csv  
Outputs: table_output/repo_table_s4_paired_mask_regression.csv  
This computes regression coefficients for the effect of masks and mask types on aerosol shedding.  

---
Script: table_s5_variants.Rmd  
Inputs: working_files/keysubjectsplus.csv, analytical_cleaned_datasets/keysubjects_varseq.csv  
Outputs: table_output/repo_table_s5_variants_legend.txt, table_output/repo_table_s5_variants.csv  
This a summary of variant sequencing clade results separated by serology result at the time of the first blood draw.  

---
Script: table_s7_probability_culture.Rmd  
Inputs: working_files/nonpaired_pcr_sx_spr.csv, working_files/repo_table_2_semiformatted.csv, working_files/repo_table_s7a_semiformatted.csv, working_files/repo_table_s7b_semiformatted.csv  
Outputs: table_output/repo_table_s7_50_probability.txt, table_output/repo_table_s7_probability_culture.csv  
This computes the probability of positive culture based on RNA copy number, using the saliva and MT swab data to build models.  

---
Script: table_s7a_alpha_only_viral_quant.Rmd  
Inputs: working_files/nonpaired_pcr_sx_rpr.csv  
Outputs: working_files/repo_table_s7a_semiformatted.csv, table_output/repo_table_s7a_alpha_only_viral_quant.csv  
Like table 2, this computes geometric means and standard deviations for viral copy number using LMEC (method="ML") on the nonpaired set, filtered for alpha-variant seronegative participants.  

---
Script: table_s7b_non_alpha_viral_quant.Rmd  
Inputs: working_files/nonpaired_pcr_sx_rpr.csv  
Outputs: working_files/repo_table_s7b_semiformatted.csv, table_output/repo_table_s7b_non_alpha_viral_quant.csv  
Like table_s7a, this computes geometric means and standard deviations for viral copy number using LMEC (method="ML") on the nonpaired set, but filtered for non-alpha-variant seronegative participants.  

---
Script: table_s7ab_merge.Rmd  
Inputs: table_output/repo_table_s7a_alpha_only_viral_quant.csv, table_output/repo_table_s7b_non_alpha_viral_quant.csv  
Outputs: table_output/repo_table_s7ab_merged.csv  
Simple merge of s7a and s7b.  
