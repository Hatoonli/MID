srun --time=04:00:00 --mem=4G --pty bash -i

cohort=<list of files to be merged in a txt file>
plink1=/storage/atkinson/shared_software/software/plink_v19/plink
plink=/storage/atkinson/shared_software/software/plink2/plink2

#create merge list paths of plink files
> ${cohort}_mergelist.txt
while read file; do
echo ${file}qc >> ${cohort}_mergelist.txt; #will merge the QCed files
done < ${cohort}.txt


#check the number of variants after QC
while read file; do wc -l $file.bim; done < ${cohort}_mergelist.txt
#remove files with no samples after QC from ${cohort}_mergelist.txt

#merge
$plink1 \
--merge-list ${cohort}_mergelist.txt --make-bed --out ${cohort}

#exclude missnp (if number of SNPs is not too large < 500, otherwise try --flip)
while read file; do
$plink1 \
--bfile ${file} --exclude ${cohort}-merge.missnp --make-bed --out ${file}; done < ${cohort}_mergelist.txt
# then merge again

#sort file
$plink \
--bfile ${cohort} --sort-vars \
--make-pgen --out ${cohort}_sorted

$plink \
--pfile ${cohort}_sorted \
--make-bed --out ${cohort}_sorted
