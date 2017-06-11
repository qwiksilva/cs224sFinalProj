#!/bin/bash

#VERY IMPORTANT: RUN THIS FROM THE s5c DIRECTORY!!!!
. cmd.sh
. path.sh

mfccdir=mfcc

#Change this to dictate which model you want to use (mono, tri2, ...)
model=nnet2_5_1

#Make MFCC features
for x in icsi_set; do
  steps/make_mfcc.sh --cmd run.pl data/$x exp/make_mfcc/$x $mfccdir
  steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
  utils/fix_data_dir.sh data/$x
done

#Align data and generate ali.*.gz in exp/icsi_set_ali
steps/nnet2/align.sh --cmd run.pl data/icsi_set data/lang_nosp exp/$model exp/icsi_set_ali || exit 1;

#Generate pronunciations in prons.*.gz in exp/icsi_set_ali
steps/get_prons.sh --cmd run.pl data/icsi_set data/lang_nosp exp/icsi_set_ali

#Generate CTM output
for i in exp/icsi_set_ali/ali.*.gz; do 
/farmshare/user_data/rdsilva/kaldi-trunk/src/bin/ali-to-phones --ctm-output exp/$model/final.mdl ark:"gunzip -c $i|" -> ${i%.gz}.ctm;
done;

#Concatenate them together
touch exp/icsi_set_ali/merged_alignment.txt
cat exp/icsi_set_ali/*.ctm > exp/icsi_set_ali/merged_alignment.txt
echo "All alignments stored in exp/icsi_set_ali/merged_alignment.txt"

#Translate from phone ids to phones + strip '_B, _I, etc'
rm -rf exp/icsi_set_ali/final_alignment
mkdir exp/icsi_set_ali/final_alignment
python data/icsi_set/export_prons.py exp/icsi_set_ali/merged_alignment.txt exp/icsi_set_ali/phones.txt exp/icsi_set_ali/final_alignment
echo "Wrote file-individual alignments to exp/icsi_set_ali/final_alignment"

#Run comparison scripts
python data/icsi_set/get_accuracies_phn_counts.py

