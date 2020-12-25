
rule tableview_SE:
    input: 
        read_count="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/SE_{nucleotide}/stage8/readcount.tsv",
        trimmed_read_count="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/stats_SE_{nucleotide}/stage1/trimming/count_bbduk_trimmed_reads.txt"
    output: 
        tableview="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/SE_{nucleotide}/stage8/tableview/readcount_tableview.tsv",
        classified_reads_mincount="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/SE_{nucleotide}/stage8/tableview/classified_reads_mincount.tsv",
        organism_dir=directory("{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/SE_{nucleotide}/stage8/tableview/organism_dir"),
        kingdom_dir=directory("{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/SE_{nucleotide}/stage8/tableview/kingdom_dir")
    params:
        SE_or_PE="SE",
        mincount=config['tableview_min_count']
    conda: "../../conda/R_env.yaml"
    script: "../../scripts/reformat_results/tableview_splitting.R"

rule tableview_PE:
    input: 
        read_count="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/PE_{nucleotide}/stage8/readcount.tsv",
        trimmed_read_count_unmerged="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/stats_PE_{nucleotide}/stage1/trimming/count_bbduk_unmerged_reads_trimmed_raw.txt",
        trimmed_read_count_merged="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/stats_PE_{nucleotide}/stage1/trimming/count_bbduk_merged_reads_trimmed.txt"
    output: 
        tableview="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/PE_{nucleotide}/stage8/tableview/readcount_tableview.tsv",
        classified_reads_mincount="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/PE_{nucleotide}/stage8/tableview/classified_reads_mincount.tsv",
        organism_dir=directory("{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/PE_{nucleotide}/stage8/tableview/organism_dir"),
        kingdom_dir=directory("{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/PE_{nucleotide}/stage8/tableview/kingdom_dir")
    params:
        SE_or_PE="PE",
        mincount=config['tableview_min_count']
    conda: "../../conda/R_env.yaml"
    script: "../../scripts/reformat_results/tableview_splitting.R"

# rule filter_fastq_SE:
#     input: 
#         organism_tableview="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/SE_{nucleotide}/stage8/tableview/{rank}_dir/{rank}_{taxid}.tsv",
#         reads="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/SE_{nucleotide}/stage1/trimming/trimmed_reads.fq",
#     output: 
#         fastq_out="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/SE_{nucleotide}/stage8/tableview/{rank}_fastq/{taxid}.fastq"
#     params:
#         SE_or_PE="SE",
#         negate_query="FALSE"
#     conda: "../../conda/R_env.yaml"
#     script: "../../scripts/reformat_results/filter_fastq.R"

# rule filter_fastq_PE:
#     input: 
#         organism_tableview="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/PE_{nucleotide}/stage8/tableview/{rank}_dir/{rank}_{taxid}.tsv",
#         unmerged_reads="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/PE_{nucleotide}/stage1/trimming/unmerged_reads_trimmed.fq",
#         merged_reads="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/PE_{nucleotide}/stage1/trimming/merged_reads_trimmed.fq"
#     output: 
#         fastq_out="{outdir}/{start_date}_{run_id}/snakemake_results_{sample}/PE_{nucleotide}/stage8/tableview/{rank}_fastq/{taxid}.fastq"
#     params:
#         SE_or_PE="PE",
#         negate_query="FALSE"
#     conda: "../../conda/R_env.yaml"
#     script: "../../scripts/reformat_results/filter_fastq.R"

