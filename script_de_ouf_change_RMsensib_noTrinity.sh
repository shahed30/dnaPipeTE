#!/bin/bash

#$1 = infile 1
#$2 = outfile
#$3 = cpu
#$4 = /path_to/RM_library.fasta
#$5 = second sample (infile 2)
#$6 = blast sample (2x sample 1 ou 2)
#$7 = RM sensitivity to annotate contig (0 to 1)

 echo "   _____________________________________________________"
 echo "  /    _               _____ _         _______ ______   \ "
 echo " /    | |             |  __ (_)       |__   __|  ____|   \ "
echo "|   __| |_ __   __ _  | |__) | _ __   ___| |  | |__       \____________________________________________________________________"
echo "|  / _\` | '_ \ / _\` | |  ___/ | '_ \ / _ \ |  |  __|        De Novo Anssembly and Annotation PIPEline for Transposable Elements\ "
echo "| | (_| | | | | (_| | | |   | | |_) |  __/ |  | |____      ____________________________________________________________________/ "
echo "|  \__,_|_| |_|\__,_| |_|   |_| .__/ \___|_|  |______|    / "
echo " \                            | |                        / "
echo "  \___________________________|_|_______________________/ "



echo '/!\ PARSING ONLY /!\'

echo 'Genomic repeats assembly/annotation/quantification pipeline using TRINITY - version 0.1'

echo ''

source conf_local
echo 'configuration file sourced'
mkdir $2
mkdir $2/Trinity_run1
echo ''
echo 'Let'\''s go...'


echo 'Done'

echo '#########################################'
echo '### Making contigs annotation from RM ###'
echo '#########################################'

# fais une liste de fichier headers pour aller récupérer les contigs
cat $2/Annotation/one_RM_hit_per_Trinity_contigs | grep 'LTR' | awk '{if ($3 >= 0.5) print$1}' > $2/Annotation/LTR.headers ### Ã  utiliser pour trier et faire des fichier de grep par catÃ©gorie pour l'alignement ensuite.
cat $2/Annotation/one_RM_hit_per_Trinity_contigs | grep 'LINE' | awk '{if ($3 >= 0.5) print$1}' > $2/Annotation/LINE.headers ### Ã  utiliser pour trier et faire des fichier de grep par catÃ©gorie pour l'alignement ensuite.
cat $2/Annotation/one_RM_hit_per_Trinity_contigs | grep 'SINE' | awk '{if ($3 >= 0.5) print$1}' > $2/Annotation/SINE.headers ### Ã  utiliser pour trier et faire des fichier de grep par catÃ©gorie pour l'alignement ensuite.
cat $2/Annotation/one_RM_hit_per_Trinity_contigs | grep 'ClassII' | awk '{if ($3 >= 0.5) print$1}' > $2/Annotation/ClassII.headers ### Ã  utiliser pour trier et faire des fichier de grep par catÃ©gorie pour l'alignement ensuite.
cat $2/Annotation/one_RM_hit_per_Trinity_contigs | grep 'Low_complexity' | awk '{if ($3 >= 0.5) print$1}' > $2/Annotation/LowComp.headers ### Ã  utiliser pour trier et faire des fichier de grep par catÃ©gorie pour l'alignement ensuite.
cat $2/Annotation/one_RM_hit_per_Trinity_contigs | grep 'Simple_repeat' | awk '{if ($3 >= 0.5) print$1}' > $2/Annotation/Simple.headers ### Ã  utiliser pour trier et faire des fichier de grep par catÃ©gorie pour l'alignement ensuite.
cat $2/Annotation/one_RM_hit_per_Trinity_contigs | grep 'Satellite' | awk '{if ($3 >= 0.5) print$1}' > $2/Annotation/Satellite.headers ### Ã  utiliser pour trier et faire des fichier de grep par catÃ©gorie pour
# récupère et annote les contigs de Trinity.fasta selon les meilleurs hits RM

perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/Annotation/LTR.headers $2/Trinity.fasta | sed 's/>comp/>LTR_comp/g' > $2/Annotation/LTR_annoted.fasta
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/Annotation/LINE.headers $2/Trinity.fasta | sed 's/>comp/>LINE_comp/g' > $2/Annotation/LINE_annoted.fasta
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/Annotation/SINE.headers $2/Trinity.fasta | sed 's/>comp/>SINE_comp/g' > $2/Annotation/SINE_annoted.fasta
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/Annotation/ClassII.headers $2/Trinity.fasta | sed 's/>comp/>ClassII_comp/g' > $2/Annotation/ClassII_annoted.fasta
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/Annotation/LowComp.headers $2/Trinity.fasta | sed 's/>comp/>LowComp_comp/g' > $2/Annotation/LowComp_annoted.fasta
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/Annotation/Simple.headers $2/Trinity.fasta | sed 's/>comp/>Simple_repeats_comp/g' > $2/Annotation/Simple_repeats_annoted.fasta
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/Annotation/Satellite.headers $2/Trinity.fasta | sed 's/>comp/>Satellite_comp/g' > $2/Annotation/Satellite_annoted.fasta
cat $2/Annotation/*.headers > $2/Annotation/all_annoted.head
perl -ne 'if(/^>(\S+)/){$c=!$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/Annotation/all_annoted.head $2/Trinity.fasta | sed 's/>comp/>na_comp/g' > $2/Annotation/unannoted.fasta

cat $2/Annotation/*_annoted.fasta > $2/Annotation/annoted.fasta

echo 'Done'
date +"%T"
echo ''

####################TRF#################################
                                                       #
                                                       #

echo '######################################'
echo '### TRF to annotate Tandem Repeats ###'
echo '######################################'

trf $2/Annotation/unannoted.fasta 2 7 7 80 10 50 500 -f -d -h

mv ./unannoted.fasta.*.dat $2/unannoted.fasta.*.dat

cat $2/unannoted.fasta.*.dat |  sed '/^$/d' > $2/Annotation/dat_without_jumps
cat $2/Annotation/dat_without_jumps | grep -B 2 '[ACTG]' | grep 'Sequence' | awk '{print $2}' | sed 's/na_//g' > $2/Annotation/found_tandem_repeats.header #sort les headers des tandem repeats détectés et enlève le na_ pour pouvoir les récupérer dans Trinity.fatas
cat $2/Annotation/found_tandem_repeats.header | sed 's/comp/na_comp/g' > $2/Annotation/found_TR_fmtd # rajoute na_ pour les enlever de unanoted.fasta

perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/Annotation/found_tandem_repeats.header $2/Trinity.fasta | sed 's/>comp/>Tandem_Repeat_comp/g' > $2/Annotation/Tandem_Rep_annoted.fasta
perl -ne 'if(/^>(\S+)/){$c=!$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/Annotation/found_TR_fmtd $2/Annotation/unannoted.fasta > $2/Annotation/unannoted_final.fasta


date +"%T"
echo ''

##################BLAST#################################
                                                       #
                                                       #

echo '###################################################'
echo '### Blast 1 : raw reads against annoted repeats ###'
echo '###################################################'

mkdir $2/blast_out

cat $2/Annotation/annoted.fasta $4 > $2/blast_out/blast1_db.fasta
$Blast_folder/makeblastdb -in $2/blast_out/blast1_db.fasta -out $2/blast_out/blast1_db.fasta -dbtype 'nucl'

echo ''
date +"%T"
echo 'blasting...'

#### PARALELISATION DE BLAST : EN TRAVAUX #####
cat $2/renamed.blasting_reads.fasta | $Parallel -j $3 --block 100k --recstart '>' --pipe $Blast_folder/blastn -outfmt 6 -task dc-megablast -db $2/blast_out/blast1_db.fasta -query - > $2/blast_out/reads_vs_annoted.blast.out

#### NORMAL BLAST #############################
#$Blast_folder/blastn -query $1 -db $2/blast_out/blast1_db.fasta -task dc-megablast -out $2/blast_out/reads_vs_annoted.blast.out -outfmt 6 -perc_identity 80 -num_threads $3

echo 'blast1 done'
date +"%T"
echo ''

echo 'Parsing blast1 output...'

cat $2/blast_out/reads_vs_annoted.blast.out | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > $2/blast_out/sorted.reads_vs_annoted.blast.out

echo 'Parsing done'
date +"%T"
echo ''

echo 'Selecting non-matching reads for blast2'

cat $2/blast_out/sorted.reads_vs_annoted.blast.out | awk '{print$1}' > $2/blast_out/matching_reads.headers
perl -ne 'if(/^>(\S+)/){$c=!$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/blast_out/matching_reads.headers $2/renamed.blasting_reads.fasta > $2/blast_out/unmatching_reads1.fasta

echo '#####################################################'
echo '### Blast 2 : raw reads against unannoted repeats ###'
echo '#####################################################'
echo ''

$Blast_folder/makeblastdb -in $2/Annotation/unannoted_final.fasta -out $2/blast_out/blast2_db.fasta -dbtype 'nucl'

echo ''
date +"%T"
echo 'blasting...'

cat $2/blast_out/unmatching_reads1.fasta | $Parallel -j $3 --block 100k --recstart '>' --pipe $Blast_folder/blastn -outfmt 6 -task dc-megablast -db $2/blast_out/blast2_db.fasta -query - > $2/blast_out/reads_vs_unannoted.blast.out

#$Blast_folder/blastn -query  -db $2/blast_out/blast2_db.fasta -task dc-megablast -out $2/blast_out/reads_vs_unannoted.blast.out -outfmt 6 -perc_identity 80 -num_threads $3

echo 'blast2 done'
echo ''
date +"%T"

echo 'Paring blast2 output...'
cat $2/blast_out/reads_vs_unannoted.blast.out | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > $2/blast_out/sorted.reads_vs_unannoted.blast.out

echo 'Parsing done'
echo ''
date +"%T"

##############Estimation of Repeats abundance###########
                                                       #
                                                       #

echo '#######################################################'
echo '### Estimation of Repeat content from blast outputs ###'
echo '#######################################################'
echo ''
date +"%T"

rm $2/Count*.txt

echo "LTR" >> $2/Counts1.txt
cat $2/blast_out/sorted.reads_vs_annoted.blast.out | grep -c 'LTR' >> $2/Counts2.txt
echo "LINE" >> $2/Counts1.txt
cat $2/blast_out/sorted.reads_vs_annoted.blast.out | grep -c 'LINE' >> $2/Counts2.txt
echo "SINE" >> $2/Counts1.txt
cat $2/blast_out/sorted.reads_vs_annoted.blast.out | grep -c 'SINE' >> $2/Counts2.txt
echo "ClassII" >> $2/Counts1.txt
cat $2/blast_out/sorted.reads_vs_annoted.blast.out | grep -c 'ClassII' >> $2/Counts2.txt
echo "Low_Complexity" >> $2/Counts1.txt
cat $2/blast_out/sorted.reads_vs_annoted.blast.out | grep -c 'LowComp' >> $2/Counts2.txt
echo "Simple_repeats" >> $2/Counts1.txt
cat $2/blast_out/sorted.reads_vs_annoted.blast.out | grep -c 'Simple_repeats' >> $2/Counts2.txt
echo "Tandem_repeats" >> $2/Counts1.txt
cat $2/blast_out/sorted.reads_vs_annoted.blast.out | grep -c 'Tandem_\|Satellite_\|MSAT\|\-SAT' >> $2/Counts2.txt
echo "NAs" >> $2/Counts1.txt
cat $2/blast_out/sorted.reads_vs_unannoted.blast.out | wc -l >> $2/Counts2.txt
echo "Total" >> $2/Counts1.txt
cat $2/blast_reads.counts >> $2/Counts2.txt

paste $2/Counts1.txt  $2/Counts2.txt > $2/Counts.txt

echo 'Done'
date +"%T"




###########Building graph of Repeats families###########
                                                       #
                                                       #

echo '#########################################'
echo '### OK, lets build some pretty graphs ###'
echo '#########################################'
echo ''
date +"%T"
echo ''
echo '#######################################################'
echo '### Blast 3 : raw reads against all repeats contigs ###'
echo '#######################################################'
echo ''

$Blast_folder/makeblastdb -in $2/Trinity.fasta -out $2/Trinity.fasta -dbtype 'nucl'

echo ''
date +"%T"
echo 'Blasting...'

cat $2/renamed.blasting_reads.fasta | $Parallel -j $3 --block 100k --recstart '>' --pipe $Blast_folder/blastn -outfmt 6 -task dc-megablast -db $2/Trinity.fasta -query - > $2/blast_out/reads_vs_Trinity.fasta.blast.out

#$Blast_folder/blastn -query $1 -db $2/Trinity.fasta -task dc-megablast -out $2/blast_out/reads_vs_Trinity.fasta.blast.out -outfmt 6 -perc_identity 80 -num_threads $3

echo 'Paring blast3 output...'
date +"%T"

cat $2/blast_out/reads_vs_Trinity.fasta.blast.out | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > $2/blast_out/sorted.reads_vs_Trinity.fasta.blast.out

cat $2/blast_out/sorted.reads_vs_Trinity.fasta.blast.out | awk '{print $2"\t"$3}' | sed 's/_/\t/g' > Reads_to_components_Rtable.txt

echo 'Parsing done'
date +"%T"

echo "Computing reads to contigs (not components) with their annotations"

#extrait les reads qui hit sur les components (blast3) et garde read | comp_c_seq | %id
cat $2/blast_out/sorted.reads_vs_Trinity.fasta.blast.out | awk '{print $1 "\t"$2"\t"$3}' > $2/reads_to_component
#les ordonne par component
cat $2/reads_to_component | sort -k2,2 > $2/reads_to_component.sorted
cat $2/Annotation/one_RM_hit_per_Trinity_contigs | sort -k1,1 | awk '{ print $1 "\t" $3 "\t" $4 "\t" $5}' | awk '/LINE/ { print $0 "\tLINE"; next} /LTR/ {print $0 "\tLTR"; next} /SINE/ {print $0 "\tSINE"; next} /ClassII/ {print $0 "\tClassII"; next} {print $0 "\tOther"}' | awk '{print $1 "\t" $2 "\t" $3 "\t" $5}' > $2/annotations

join -12 -21 $2/reads_to_component.sorted $2/annotations > rtc_annoted


# R #
Rscript annotation.R


mv reads.per.component_annoted $2/blast_out/
mv rtc_annoted $2/blast_out/

echo 'Done, results in: "blast_out/reads.per.component_annoted"'
#Drawing graphs 

echo 'Drawing graphs...'
cp $2/blast_reads.counts .
cp $2/Counts.txt .
Rscript graph.R
Rscript pieChart.R
echo 'Done'

rm single.fa.read_count
mv Reads_to_components_Rtable.txt $2/
mv Reads_to_components.* $2/
mv TEs_piechart.* $2/
mv reads_per_component_sorted.txt $2/

echo ''
echo 'finishing time: '
date +"%T"
echo''
echo '########################'
echo '#   see you soon !!!   #'
echo '########################'






