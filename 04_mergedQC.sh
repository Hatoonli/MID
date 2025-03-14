## For joined cohort

# --mind  and --geno default is 0.1
# used higher values as QC has already been performed individually and the number of merged studies is large 
-bfile ${cohort}_sorted --geno 0.5 --mind 0.99 \  
--make-bed --out ${cohort}_sortedqc

# related samples
# calculate KING kinship coefficients
/storage/atkinson/shared_software/software/plink2/plink2 \
-bfile ${cohort}_sortedqc --make-king triangle bin -out ${cohort}_sortedqc

# prune related indivdiduals
/storage/atkinson/shared_software/software/plink2/plink2 \
-bfile ${cohort}_sortedqc --king-cutoff ${cohort}_sortedqc 0.177

#exclude related samples
cohort=~/midProject/data/reference/cohorts/harmonization/allcohort
/storage/atkinson/shared_software/software/plink_v19/plink \
--bfile ${cohort}_sortedqc --remove allcohort_sortedqcKing.king.cutoff.out.id --make-bed --out ${cohort}_sortedqc

#exclude outliers (determined by pca)
#cohort=~/midProject/data/reference/cohorts/harmonization/allcohort
cohort=~/midProject/data/reference/cohorts/harmonization/targetcohort
/storage/atkinson/shared_software/software/plink_v19/plink \
--bfile ${cohort} --remove pca/outliers.txt --make-bed --out ${cohort}
