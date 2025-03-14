## For joined cohort

cohort=<name of cohort>
plink1=/storage/atkinson/shared_software/software/plink_v19/plink
plink=/storage/atkinson/shared_software/software/plink2/plink2

# --mind  and --geno default is 0.1
# used higher values as QC has already been performed individually and the number of merged studies is large 
-bfile ${cohort}_sorted --geno 0.5 --mind 0.99 \  
--make-bed --out ${cohort}_sortedqc

# related samples
# calculate KING kinship coefficients
$plink \
-bfile ${cohort}_sortedqc --make-king triangle bin -out ${cohort}_sortedqc

# prune related indivdiduals
$plink \
-bfile ${cohort}_sortedqc --king-cutoff ${cohort}_sortedqc 0.177

#exclude related samples
$plink1 \
--bfile ${cohort}_sortedqc --remove allcohort_sortedqcKing.king.cutoff.out.id --make-bed --out ${cohort}_sortedqc

#exclude outliers (determined by pca)
$plink1 \
--bfile ${cohort} --remove pca/outliers.txt --make-bed --out ${cohort}
