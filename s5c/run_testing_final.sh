#!/bin/bash

#VERY IMPORTANT: RUN THIS FROM THE s5c DIRECTORY!!!!
. cmd.sh
. path.sh

mfccdir=mfcc

#Change this to dictate which model you want to use (mono, tri2, ...)
for j in `seq 0 8`; do

name=tri2_
model="$name"final_enrichment$j
align="$model"_icsi_ali
#Make MFCC features
for x in icsi_set; do
  steps/make_mfcc.sh --cmd run.pl data/$x exp/make_mfcc/$x $mfccdir
  steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
  utils/fix_data_dir.sh data/$x
done

#Align data and generate ali.*.gz in exp/icsi_set_ali
steps/align_si.sh --cmd run.pl data/icsi_set data/lang_final_enrichment$j exp/$model exp/$align || exit 1;

#Generate pronunciations in prons.*.gz in exp/icsi_set_ali
steps/get_prons.sh --cmd run.pl data/icsi_set data/lang_final_enrichment$j exp/$align

#Generate CTM output
for i in exp/$align/ali.*.gz; do 
/farmshare/user_data/rdsilva/kaldi-trunk/src/bin/ali-to-phones --ctm-output exp/$model/final.mdl ark:"gunzip -c $i|" -> ${i%.gz}.ctm;
done;

#Concatenate them together
touch exp/$align/merged_alignment.txt
cat exp/$align/*.ctm > exp/$align/merged_alignment.txt
#echo "All alignments stored in exp/icsi_set_ali/merged_alignment.txt"

#Translate from phone ids to phones + strip '_B, _I, etc'
rm -rf exp/$align/final_alignment
mkdir exp/$align/final_alignment
python data/icsi_set/export_prons.py exp/$align/merged_alignment.txt exp/$align/phones.txt exp/$align/final_alignment
#echo "Wrote file-individual alignments to exp/icsi_set_ali/final_alignment"

#Run comparison scripts
python data/icsi_set/get_accuracies_phn_counts.py exp/$align/final_alignment

done
