# This code performs LiftOver on a list of plink files to hg38 reference
# will face an issue when the directory name is the same as the file name
# command: liftover.sh <list of paths to the plink files to be converted>

# Start session on Taco server and load the Java module
srun --time=04:00:00 --mem=4G --pty bash -i
module load java/jdk-22

#specify hg18 or hg19 of the original files
hg=19

# paths to required files
plink=/storage/atkinson/shared_software/software/plink2/plink2
picard=/storage/atkinson/shared_software/software/picard/picard_v3.1.1.jar 
fasta=/storage/atkinson/shared_resources/reference/reference_genomes/b38/Homo_sapiens_assembly38.fasta
chain=/storage/atkinson/shared_resources/reference/genetic_maps/liftover/hg${hg}ToHg38.over.chain.gz
chr=/storage/atkinson/home/u250489/cohort/chr_name_conv.txt

#define input and output
list=$1
cohort=${list}hg38

# Iteration
while read plink; do
name=$(echo $plink | sed "s/.*\///g"); 
path=$(echo $plink | sed "s/\/$name$//g"); 
vcf=$plink.vcf;

# (1) convert to VCF
$plink \
--bfile $plink --snps-only 'just-acgt' --keep-allele-order --recode vcf --out $plink; 

# add chr notation to match the chain file
bcftools annotate --rename-chrs $chr $vcf > ${vcf}.tmp; 
mv ${vcf}.tmp $vcf; 

# (2) LiftOver
java -jar $picard \
LiftoverVcf --CHAIN $chain \
--INPUT $vcf \
--OUTPUT ${path}/hg38_${name}.vcf.gz \
--REFERENCE_SEQUENCE $fasta \
--RECOVER_SWAPPED_REF_ALT \
--REJECT ${path}/unlifted_${name}.vcf \
--WARN_ON_MISSING_CONTIG \
--DISABLE_SORT; 

# (3) Convert to plink
$plink \
--vcf ${path}/hg38_${name}.vcf.gz \
--set-all-var-ids @:# --sort-vars \
--make-pgen --allow-extra-chr --chr 1-22 XY \
--out ${path}/hg38_${name};

# fix ID after conversion from VCF
less ${path}/${name}.fam | awk -v OFS="\t" '{print "0", $1"_"$2, $1, $2}' > ${path}/id_${name}.txt

/storage/atkinson/shared_software/software/plink2/plink2 \
--pfile ${path}/hg38_$name \
--update-ids ${path}/id_${name}.txt --make-bed --out ${path}/hg38_$name; 

# add file to cohort list
echo ${path}/hg38_${name} >> $cohort; 
done < $list

echo "files are converted to hg38 and their paths are saved to "$cohort
