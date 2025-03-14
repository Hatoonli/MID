## for each group
# no imputation as my sample is not represented in a reference
# no pruning for now as the number of SNPs is low
# --maf 0.01, >=1% MAF
# --hwe 1e-06 (reduces SNPs in Almarri, excluded)
# -max-alleles 2, biallelic

cohort=~/midProject/data/reference/cohorts/harmonization/targetcohort
cohort=~/midProject/data/reference/cohorts/harmonization/allcohort

while read file; do
/storage/atkinson/shared_software/software/plink2/plink2 \
-bfile ${file} -max-alleles 2 --maf 0.01 --hwe 1e-6 --geno 0.05 --mind 0.05 \
--set-all-var-ids @:# --rm-dup force-first \
--make-pgen --allow-extra-chr --chr 1-22 XY --out ${file}qc;
/storage/atkinson/shared_software/software/plink2/plink2 \
-pfile ${file}qc --make-bed --out ${file}qc \
; done < ${cohort}.txt
