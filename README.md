
<h1 align="center" >
  P a R C A
</h1>

## Pathogen detection for Research and Clinical Applications

---
## Info
**This pipeline is under development, a first version will be released at the end of January 2021**

A snakemake pipeline to further develop the previous inhouse perl pipeline [Pathfinder](https://github.com/ClinicalGenomicsGBG/pathfinder_43b_perl) used for classifying metagenomic samples.

## Usage

```
module load anaconda3;
source activate /home/xerpey/.conda/envs/pernilla_general/envs/smk_tidy

# Dryrun demo
python3 parca/parca_cli.py run -m /apps/bio/dev_repos/parca/demo/runinfo/metadata.csv -r /apps/bio/dev_repos/parca/demo/runinfo/runinfo.csv -o /medstore/logs/pipeline_logfiles/parca -w /medstore/logs/pipeline_logfiles/parca/webinterface --dryrun


# Run demo
python3 parca/parca_cli.py run -m /apps/bio/dev_repos/parca/demo/runinfo/metadata.csv -r /apps/bio/dev_repos/parca/demo/runinfo/runinfo.csv -o /medstore/logs/pipeline_logfiles/parca -w /medstore/logs/pipeline_logfiles/parca/webinterface
```

## **The pipeline**
The pipeline is made for assigning sequencing reads to taxonomic identifiers.
It handles four cases, see steps in `parca/dag/dag_all.png`:
* SE RNA
* PE RNA
* SE DNA
* PE DNA

### Stage 1: Quality control and error correction
* `workflows/snakemake_rules/stage1_qc_trim_ec/setup/setup.smk`
  * For future update: Check if it is possible to skip interleaving files and instead work directly on PE reads.
* `workflows/snakemake_rules/stage1_qc_trim_ec/quality_control/fastqc.smk`
* `workflows/snakemake_rules/stage1_qc_trim_ec/trimming/bbduk_trimming.smk`
  * Adapters should be input as a path or as NA in meta dataframe
* `workflows/snakemake_rules/stage1_qc_trim_ec/ec_pollux/ec_pollux.smk`
* `workflows/snakemake_rules/stage1_qc_trim_ec/ec_fiona/ec_fiona.smk`

### Stage 2: Assembly
* `workflows/snakemake_rules/stage2_assembly/megahit/megahit.smk`
* `workflows/snakemake_rules/stage2_assembly/bbwrap_alignment/bbwrap_alignment.smk`
  * For future updates: 
    * PE RNA: merged and unmerged bbmap coverage is added to the same file. The header for both files is included which starts with "#", check if this is handled correctly in latter steps! 
    * PE/SE RNA: Maybe remove the contigs that nothing was mapped back to?
* `workflows/snakemake_rules/stage2_assembly/merge_contigs_unmapped/merge_contigs_unmapped.smk`

### Stage 3: Kraken and Kaiju
* `workflows/snakemake_rules/stage3_kraken_kaiju/kraken_rules/kraken.smk`
* `workflows/snakemake_rules/stage3_kraken_kaiju/kaiju_rules/kaiju.smk`

### Stage 4: Parse hits
* `workflows/snakemake_rules/stage4_parse_hits/parse_hits.smk`
* `workflows/snakemake_rules/stage4_parse_hits/taxonomy_processing.smk` 
  * For future updates: 
    * rule filter_SGF_empty: 
      * Doublets that had either species OR genus OR family was not added to a file. *Revisit this*
	  * Revisit comparison between kraken and kaiju for SGF empty.
	    * Matching length (kaiju) is compared with (length-30)*(C/Q)+0.5 where C is the number of kmers matching the LCA and Q corresponds to the number of kmers that where queried agains the db (kraken)
  
### Stage 5: Blast processing
* `workflows/snakemake_rules/stage5_blast_processing/blast_processing.smk`

### Stage 6: Blast sliced database
* `workflows/snakemake_rules/stage6_blast_sliced_db/blast_above_species_classed.smk`

### Stage 7: Blast remaining reads
* `workflows/snakemake_rules/stage7_blast_remaining_reads/blast_remaining.smk`

### Stage 8: Format results
* `workflows/snakemake_rules/stage8_format_results/format_results.smk`
* `workflows/snakemake_rules/stage8_format_results/krona_plot.smk`
  * For future update: 
    * The krona plot is filtered to show organisms with more than nine reads. This can be modified in the `config/config.yaml`.
* `workflows/snakemake_rules/stage8_format_results/generate_files_for_download.smk`


### Pipeline overview
![Parca flow chart](./parca_flow_chart_png.png)


## **Pipeline wrapper**

Note:
- the snakemake API could not import a nested dictionary and had to be converted to a list of dictionaries. The pipeline will then convert this list into a nested dictionary where the keys will be <start_date>_<run_id> encoded from the runinfo.

## Prerequisites:
* Databases for Kraken and Kaiju are currently manually downloaded 
* Pollux and Fiona are not available from conda and has to be manually downloaded
* The workflow uses the singularity definition file in workflows/containers/parca_v1.def which should be built prior to running the pipeline.

## Installation
```
singularity pull docker://pericsson/bbmap_env:latest
singularity pull docker://pericsson/biopython_env:latest
singularity pull docker://pericsson/blast_env:latest
singularity pull docker://pericsson/kaiju_env:latest
singularity pull docker://pericsson/krona_env:latest
singularity pull docker://pericsson/r_env:latest
singularity pull docker://pericsson/taxonkit_env:latest
```

### To-Do
* Comments on what to add to future updates are added to the previous section "The pipeline" with specifications for certain rules and snakemake files. All documented things to add to a future update can be found on [jira](https://clinicalgenomics.atlassian.net/secure/RapidBoard.jspa?rapidView=83&projectKey=PR&view=planning.nodetail&selectedIssue=PR-3&issueLimit=100&assignee=5d19d97386b1040ce2815bc6) (issues in jira are to the most part replicated on the github issues and github projects but the most updated issues are on Jira)

* Note that the last rules of the pipeline call_case and call_case_control appends a run summary to an untracked file. During development I created a rule that take each run summary for all runs in a directory and concatenates these into a summary of all runs. This rule was supposed to be called in the parca cli directly after a run of the pipeline with a finished status, see [Github](https://github.com/ClinicalGenomicsGBG/PARCA/blob/1c334338312a4d9d42479dba0faecb179cc87582/parca/concat_main_page_stats.smk). I cancelled this implementation though since it should be tested further. Due to locking of the directory when snakemake runs in a certain directory this might cause errors on the rule but maybe one can find a nice way to fix this. The current solution of appending the sumamry to an untracked file works however.
