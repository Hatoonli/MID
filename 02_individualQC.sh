## for each group
# no imputation as my sample is not represented in a reference
# no pruning for now as the number of SNPs is low (do pruning after plotting PCs by position)
# --maf 0.01, >=1% MAF
# --hwe 1e-06
# -max-alleles 2, biallelic

cohort=<paths of files to be merged written in a txt file>
plink=/storage/atkinson/shared_software/software/plink2/plink2

while read file; do
 $plink\
-bfile ${file} -max-alleles 2 --maf 0.01 --hwe 1e-6 --geno 0.05 --mind 0.05 \
--set-all-var-ids @:# --rm-dup force-first \
--make-pgen --allow-extra-chr --chr 1-22 XY --out ${file}qc;
 $plink \
-pfile ${file}qc --make-bed --out ${file}qc \
; done < ${cohort}.txt
