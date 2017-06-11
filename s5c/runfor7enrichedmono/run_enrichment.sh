#!/bin/bash

. cmd.sh
. path.sh


# This setup was modified from egs/swbd/s5b, with the following changes:
# 1. added more training data for early stages
# 2. removed SAT system (and later stages) on the 100k utterance training data
# 3. reduced number of LM rescoring, only sw1_tg and sw1_fsh_fg remain
# 4. mapped swbd transcription to fisher style, instead of the other way around

set -e # exit on error
has_fisher=false
# train_cmd="utils/run.pl"
# decode_cmd="utils/run.pl"

#FIRST RUN
utils/prepare_lang.sh data/local/dict_final_enrichment1 \
  "<unk>"  data/local/lang_final_enrichment1 data/lang_final_enrichment1


fisher_dirs="" #"/export/corpora3/LDC/LDC2004T19/fe_03_p1_tran/ /export/corpora3/LDC/LDC2005T19/fe_03_p2_tran/"
# fisher_dirs="/home/dpovey/data/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/data/corpora0/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/exports/work/inf_hcrc_cstr_general/corpora/fisher/transcripts" # Edinburgh,
# fisher_dirs="/mnt/matylda2/data/FISHER/fe_03_p1_tran /mnt/matylda2/data/FISHER/fe_03_p2_tran" # BUT,
local/swbd1_train_lms.sh data/local/train/text \
  data/local/dict_final_enrichment1/lexicon.txt data/local/lm $fisher_dirs

# Compiles G for swbd trigram LM
LM=data/local/lm/sw1.o3g.kn.gz
srilm_opts="-subset -prune-lowprobs -unk -tolower -order 3"
utils/format_lm_sri.sh --srilm-opts "$srilm_opts" \
  data/lang_final_enrichment1 $LM data/local/dict_final_enrichment1/lexicon.txt data/lang_final_enrichment1_sw1_tg

# Compiles const G for swbd+fisher 4gram LM, if it exists.
LM=data/local/lm/sw1_fsh.o4g.kn.gz
[ -f $LM ] || has_fisher=false
if $has_fisher; then
  utils/build_const_arpa_lm.sh $LM data/lang_final_enrichment1 data/lang_final_enrichment1_sw1_fsh_fg
fi
local/eval2000_data_prep.sh ~/Documents/Eval2000/hub5e_00 ~/Documents/Eval2000/2000_hub5_eng_eval_tr

if [ -e data/rt03 ]; then maybe_rt03=rt03; else maybe_rt03= ; fi
mfccdir=mfcc
for x in train eval2000 $maybe_rt03; do
  steps/make_mfcc.sh --nj 50 --cmd "$train_cmd" \
    data/$x exp/make_mfcc/$x $mfccdir
  steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
  utils/fix_data_dir.sh data/$x
done

utils/subset_data_dir.sh --first data/train 4000 data/train_dev # 5hr 6min
n=$[`cat data/train/segments | wc -l` - 4000]
utils/subset_data_dir.sh --last data/train $n data/train_nodev

utils/subset_data_dir.sh --shortest data/train_nodev 100000 data/train_100kshort
utils/subset_data_dir.sh data/train_100kshort 30000 data/train_30kshort

# Take the first 100k utterances (just under half the data); we'll use
# this for later stages of training.
utils/subset_data_dir.sh --first data/train_nodev 100000 data/train_100k
utils/data/remove_dup_utts.sh 200 data/train_100k data/train_100k_nodup  # 110hr

# Finally, the full training set:
utils/data/remove_dup_utts.sh 300 data/train_nodev data/train_nodup  # 286hr
## Starting basic training on MFCC features
steps/train_mono.sh --nj 30 --cmd "$train_cmd" \
  data/train_30kshort data/lang_final_enrichment1 exp/final_enrichment1

steps/align_si.sh --nj 30 --cmd "$train_cmd" \
  data/train_100k_nodup data/lang_final_enrichment1 exp/final_enrichment1 exp/final_ali_enrichment1


#SECOND RUN
utils/prepare_lang.sh data/local/dict_final_enrichment2 \
  "<unk>"  data/local/lang_final_enrichment2 data/lang_final_enrichment2


fisher_dirs="" #"/export/corpora3/LDC/LDC2004T19/fe_03_p1_tran/ /export/corpora3/LDC/LDC2005T19/fe_03_p2_tran/"
# fisher_dirs="/home/dpovey/data/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/data/corpora0/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/exports/work/inf_hcrc_cstr_general/corpora/fisher/transcripts" # Edinburgh,
# fisher_dirs="/mnt/matylda2/data/FISHER/fe_03_p1_tran /mnt/matylda2/data/FISHER/fe_03_p2_tran" # BUT,
local/swbd1_train_lms.sh data/local/train/text \
  data/local/dict_final_enrichment2/lexicon.txt data/local/lm $fisher_dirs

# Compiles G for swbd trigram LM
LM=data/local/lm/sw1.o3g.kn.gz
srilm_opts="-subset -prune-lowprobs -unk -tolower -order 3"
utils/format_lm_sri.sh --srilm-opts "$srilm_opts" \
  data/lang_final_enrichment2 $LM data/local/dict_final_enrichment2/lexicon.txt data/lang_final_enrichment2_sw1_tg

# Compiles const G for swbd+fisher 4gram LM, if it exists.
LM=data/local/lm/sw1_fsh.o4g.kn.gz
[ -f $LM ] || has_fisher=false
if $has_fisher; then
  utils/build_const_arpa_lm.sh $LM data/lang_final_enrichment2 data/lang_final_enrichment2_sw1_fsh_fg
fi
local/eval2000_data_prep.sh ~/Documents/Eval2000/hub5e_00 ~/Documents/Eval2000/2000_hub5_eng_eval_tr

if [ -e data/rt03 ]; then maybe_rt03=rt03; else maybe_rt03= ; fi
mfccdir=mfcc
for x in train eval2000 $maybe_rt03; do
  steps/make_mfcc.sh --nj 50 --cmd "$train_cmd" \
    data/$x exp/make_mfcc/$x $mfccdir
  steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
  utils/fix_data_dir.sh data/$x
done

utils/subset_data_dir.sh --first data/train 4000 data/train_dev # 5hr 6min
n=$[`cat data/train/segments | wc -l` - 4000]
utils/subset_data_dir.sh --last data/train $n data/train_nodev

utils/subset_data_dir.sh --shortest data/train_nodev 100000 data/train_100kshort
utils/subset_data_dir.sh data/train_100kshort 30000 data/train_30kshort

# Take the first 100k utterances (just under half the data); we'll use
# this for later stages of training.
utils/subset_data_dir.sh --first data/train_nodev 100000 data/train_100k
utils/data/remove_dup_utts.sh 200 data/train_100k data/train_100k_nodup  # 110hr

# Finally, the full training set:
utils/data/remove_dup_utts.sh 300 data/train_nodev data/train_nodup  # 286hr
## Starting basic training on MFCC features
steps/train_mono.sh --nj 30 --cmd "$train_cmd" \
  data/train_30kshort data/lang_final_enrichment2 exp/final_enrichment2

steps/align_si.sh --nj 30 --cmd "$train_cmd" \
  data/train_100k_nodup data/lang_final_enrichment2 exp/final_enrichment2 exp/final_ali_enrichment2

#THIRD RUN
utils/prepare_lang.sh data/local/dict_final_enrichment3 \
  "<unk>"  data/local/lang_final_enrichment3 data/lang_final_enrichment3


fisher_dirs="" #"/export/corpora3/LDC/LDC2004T19/fe_03_p1_tran/ /export/corpora3/LDC/LDC2005T19/fe_03_p2_tran/"
# fisher_dirs="/home/dpovey/data/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/data/corpora0/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/exports/work/inf_hcrc_cstr_general/corpora/fisher/transcripts" # Edinburgh,
# fisher_dirs="/mnt/matylda2/data/FISHER/fe_03_p1_tran /mnt/matylda2/data/FISHER/fe_03_p2_tran" # BUT,
local/swbd1_train_lms.sh data/local/train/text \
  data/local/dict_final_enrichment3/lexicon.txt data/local/lm $fisher_dirs

# Compiles G for swbd trigram LM
LM=data/local/lm/sw1.o3g.kn.gz
srilm_opts="-subset -prune-lowprobs -unk -tolower -order 3"
utils/format_lm_sri.sh --srilm-opts "$srilm_opts" \
  data/lang_final_enrichment3 $LM data/local/dict_final_enrichment3/lexicon.txt data/lang_final_enrichment3_sw1_tg

# Compiles const G for swbd+fisher 4gram LM, if it exists.
LM=data/local/lm/sw1_fsh.o4g.kn.gz
[ -f $LM ] || has_fisher=false
if $has_fisher; then
  utils/build_const_arpa_lm.sh $LM data/lang_final_enrichment3 data/lang_final_enrichment3_sw1_fsh_fg
fi
local/eval2000_data_prep.sh ~/Documents/Eval2000/hub5e_00 ~/Documents/Eval2000/2000_hub5_eng_eval_tr

if [ -e data/rt03 ]; then maybe_rt03=rt03; else maybe_rt03= ; fi
mfccdir=mfcc
for x in train eval2000 $maybe_rt03; do
  steps/make_mfcc.sh --nj 50 --cmd "$train_cmd" \
    data/$x exp/make_mfcc/$x $mfccdir
  steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
  utils/fix_data_dir.sh data/$x
done

utils/subset_data_dir.sh --first data/train 4000 data/train_dev # 5hr 6min
n=$[`cat data/train/segments | wc -l` - 4000]
utils/subset_data_dir.sh --last data/train $n data/train_nodev

utils/subset_data_dir.sh --shortest data/train_nodev 100000 data/train_100kshort
utils/subset_data_dir.sh data/train_100kshort 30000 data/train_30kshort

# Take the first 100k utterances (just under half the data); we'll use
# this for later stages of training.
utils/subset_data_dir.sh --first data/train_nodev 100000 data/train_100k
utils/data/remove_dup_utts.sh 200 data/train_100k data/train_100k_nodup  # 110hr

# Finally, the full training set:
utils/data/remove_dup_utts.sh 300 data/train_nodev data/train_nodup  # 286hr
## Starting basic training on MFCC features
steps/train_mono.sh --nj 30 --cmd "$train_cmd" \
  data/train_30kshort data/lang_final_enrichment3 exp/final_enrichment3

steps/align_si.sh --nj 30 --cmd "$train_cmd" \
  data/train_100k_nodup data/lang_final_enrichment3 exp/final_enrichment3 exp/final_ali_enrichment3
#FOURTH RUN
utils/prepare_lang.sh data/local/dict_final_enrichment4 \
  "<unk>"  data/local/lang_final_enrichment4 data/lang_final_enrichment4


fisher_dirs="" #"/export/corpora3/LDC/LDC2004T19/fe_03_p1_tran/ /export/corpora3/LDC/LDC2005T19/fe_03_p2_tran/"
# fisher_dirs="/home/dpovey/data/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/data/corpora0/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/exports/work/inf_hcrc_cstr_general/corpora/fisher/transcripts" # Edinburgh,
# fisher_dirs="/mnt/matylda2/data/FISHER/fe_03_p1_tran /mnt/matylda2/data/FISHER/fe_03_p2_tran" # BUT,
local/swbd1_train_lms.sh data/local/train/text \
  data/local/dict_final_enrichment4/lexicon.txt data/local/lm $fisher_dirs

# Compiles G for swbd trigram LM
LM=data/local/lm/sw1.o3g.kn.gz
srilm_opts="-subset -prune-lowprobs -unk -tolower -order 3"
utils/format_lm_sri.sh --srilm-opts "$srilm_opts" \
  data/lang_final_enrichment4 $LM data/local/dict_final_enrichment4/lexicon.txt data/lang_final_enrichment4_sw1_tg

# Compiles const G for swbd+fisher 4gram LM, if it exists.
LM=data/local/lm/sw1_fsh.o4g.kn.gz
[ -f $LM ] || has_fisher=false
if $has_fisher; then
  utils/build_const_arpa_lm.sh $LM data/lang_final_enrichment4 data/lang_final_enrichment4_sw1_fsh_fg
fi
local/eval2000_data_prep.sh ~/Documents/Eval2000/hub5e_00 ~/Documents/Eval2000/2000_hub5_eng_eval_tr

if [ -e data/rt03 ]; then maybe_rt03=rt03; else maybe_rt03= ; fi
mfccdir=mfcc
for x in train eval2000 $maybe_rt03; do
  steps/make_mfcc.sh --nj 50 --cmd "$train_cmd" \
    data/$x exp/make_mfcc/$x $mfccdir
  steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
  utils/fix_data_dir.sh data/$x
done

utils/subset_data_dir.sh --first data/train 4000 data/train_dev # 5hr 6min
n=$[`cat data/train/segments | wc -l` - 4000]
utils/subset_data_dir.sh --last data/train $n data/train_nodev

utils/subset_data_dir.sh --shortest data/train_nodev 100000 data/train_100kshort
utils/subset_data_dir.sh data/train_100kshort 30000 data/train_30kshort

# Take the first 100k utterances (just under half the data); we'll use
# this for later stages of training.
utils/subset_data_dir.sh --first data/train_nodev 100000 data/train_100k
utils/data/remove_dup_utts.sh 200 data/train_100k data/train_100k_nodup  # 110hr

# Finally, the full training set:
utils/data/remove_dup_utts.sh 300 data/train_nodev data/train_nodup  # 286hr
## Starting basic training on MFCC features
steps/train_mono.sh --nj 30 --cmd "$train_cmd" \
  data/train_30kshort data/lang_final_enrichment4 exp/final_enrichment4

steps/align_si.sh --nj 30 --cmd "$train_cmd" \
  data/train_100k_nodup data/lang_final_enrichment4 exp/final_enrichment4 exp/final_ali_enrichment4

#FIFTH RUN
utils/prepare_lang.sh data/local/dict_final_enrichment5 \
  "<unk>"  data/local/lang_final_enrichment5 data/lang_final_enrichment5


fisher_dirs="" #"/export/corpora3/LDC/LDC2004T19/fe_03_p1_tran/ /export/corpora3/LDC/LDC2005T19/fe_03_p2_tran/"
# fisher_dirs="/home/dpovey/data/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/data/corpora0/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/exports/work/inf_hcrc_cstr_general/corpora/fisher/transcripts" # Edinburgh,
# fisher_dirs="/mnt/matylda2/data/FISHER/fe_03_p1_tran /mnt/matylda2/data/FISHER/fe_03_p2_tran" # BUT,
local/swbd1_train_lms.sh data/local/train/text \
  data/local/dict_final_enrichment5/lexicon.txt data/local/lm $fisher_dirs

# Compiles G for swbd trigram LM
LM=data/local/lm/sw1.o3g.kn.gz
srilm_opts="-subset -prune-lowprobs -unk -tolower -order 3"
utils/format_lm_sri.sh --srilm-opts "$srilm_opts" \
  data/lang_final_enrichment5 $LM data/local/dict_final_enrichment5/lexicon.txt data/lang_final_enrichment5_sw1_tg

# Compiles const G for swbd+fisher 4gram LM, if it exists.
LM=data/local/lm/sw1_fsh.o4g.kn.gz
[ -f $LM ] || has_fisher=false
if $has_fisher; then
  utils/build_const_arpa_lm.sh $LM data/lang_final_enrichment5 data/lang_final_enrichment5_sw1_fsh_fg
fi
local/eval2000_data_prep.sh ~/Documents/Eval2000/hub5e_00 ~/Documents/Eval2000/2000_hub5_eng_eval_tr

if [ -e data/rt03 ]; then maybe_rt03=rt03; else maybe_rt03= ; fi
mfccdir=mfcc
for x in train eval2000 $maybe_rt03; do
  steps/make_mfcc.sh --nj 50 --cmd "$train_cmd" \
    data/$x exp/make_mfcc/$x $mfccdir
  steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
  utils/fix_data_dir.sh data/$x
done

utils/subset_data_dir.sh --first data/train 4000 data/train_dev # 5hr 6min
n=$[`cat data/train/segments | wc -l` - 4000]
utils/subset_data_dir.sh --last data/train $n data/train_nodev

utils/subset_data_dir.sh --shortest data/train_nodev 100000 data/train_100kshort
utils/subset_data_dir.sh data/train_100kshort 30000 data/train_30kshort

# Take the first 100k utterances (just under half the data); we'll use
# this for later stages of training.
utils/subset_data_dir.sh --first data/train_nodev 100000 data/train_100k
utils/data/remove_dup_utts.sh 200 data/train_100k data/train_100k_nodup  # 110hr

# Finally, the full training set:
utils/data/remove_dup_utts.sh 300 data/train_nodev data/train_nodup  # 286hr
## Starting basic training on MFCC features
steps/train_mono.sh --nj 30 --cmd "$train_cmd" \
  data/train_30kshort data/lang_final_enrichment5 exp/final_enrichment5

steps/align_si.sh --nj 30 --cmd "$train_cmd" \
  data/train_100k_nodup data/lang_final_enrichment5 exp/final_enrichment5 exp/final_ali_enrichment5

#SIXTH RUN
utils/prepare_lang.sh data/local/dict_final_enrichment6 \
  "<unk>"  data/local/lang_final_enrichment6 data/lang_final_enrichment6


fisher_dirs="" #"/export/corpora3/LDC/LDC2004T19/fe_03_p1_tran/ /export/corpora3/LDC/LDC2005T19/fe_03_p2_tran/"
# fisher_dirs="/home/dpovey/data/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/data/corpora0/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/exports/work/inf_hcrc_cstr_general/corpora/fisher/transcripts" # Edinburgh,
# fisher_dirs="/mnt/matylda2/data/FISHER/fe_03_p1_tran /mnt/matylda2/data/FISHER/fe_03_p2_tran" # BUT,
local/swbd1_train_lms.sh data/local/train/text \
  data/local/dict_final_enrichment6/lexicon.txt data/local/lm $fisher_dirs

# Compiles G for swbd trigram LM
LM=data/local/lm/sw1.o3g.kn.gz
srilm_opts="-subset -prune-lowprobs -unk -tolower -order 3"
utils/format_lm_sri.sh --srilm-opts "$srilm_opts" \
  data/lang_final_enrichment6 $LM data/local/dict_final_enrichment6/lexicon.txt data/lang_final_enrichment6_sw1_tg

# Compiles const G for swbd+fisher 4gram LM, if it exists.
LM=data/local/lm/sw1_fsh.o4g.kn.gz
[ -f $LM ] || has_fisher=false
if $has_fisher; then
  utils/build_const_arpa_lm.sh $LM data/lang_final_enrichment6 data/lang_final_enrichment6_sw1_fsh_fg
fi
local/eval2000_data_prep.sh ~/Documents/Eval2000/hub5e_00 ~/Documents/Eval2000/2000_hub5_eng_eval_tr

if [ -e data/rt03 ]; then maybe_rt03=rt03; else maybe_rt03= ; fi
mfccdir=mfcc
for x in train eval2000 $maybe_rt03; do
  steps/make_mfcc.sh --nj 50 --cmd "$train_cmd" \
    data/$x exp/make_mfcc/$x $mfccdir
  steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
  utils/fix_data_dir.sh data/$x
done

utils/subset_data_dir.sh --first data/train 4000 data/train_dev # 5hr 6min
n=$[`cat data/train/segments | wc -l` - 4000]
utils/subset_data_dir.sh --last data/train $n data/train_nodev

utils/subset_data_dir.sh --shortest data/train_nodev 100000 data/train_100kshort
utils/subset_data_dir.sh data/train_100kshort 30000 data/train_30kshort

# Take the first 100k utterances (just under half the data); we'll use
# this for later stages of training.
utils/subset_data_dir.sh --first data/train_nodev 100000 data/train_100k
utils/data/remove_dup_utts.sh 200 data/train_100k data/train_100k_nodup  # 110hr

# Finally, the full training set:
utils/data/remove_dup_utts.sh 300 data/train_nodev data/train_nodup  # 286hr
## Starting basic training on MFCC features
steps/train_mono.sh --nj 30 --cmd "$train_cmd" \
  data/train_30kshort data/lang_final_enrichment6 exp/final_enrichment6

steps/align_si.sh --nj 30 --cmd "$train_cmd" \
  data/train_100k_nodup data/lang_final_enrichment6 exp/final_enrichment6 exp/final_ali_enrichment6

#SEVENTH RUN
utils/prepare_lang.sh data/local/dict_final_enrichment7 \
  "<unk>"  data/local/lang_final_enrichment7 data/lang_final_enrichment7


fisher_dirs="" #"/export/corpora3/LDC/LDC2004T19/fe_03_p1_tran/ /export/corpora3/LDC/LDC2005T19/fe_03_p2_tran/"
# fisher_dirs="/home/dpovey/data/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/data/corpora0/LDC2004T19/fe_03_p1_tran/"
# fisher_dirs="/exports/work/inf_hcrc_cstr_general/corpora/fisher/transcripts" # Edinburgh,
# fisher_dirs="/mnt/matylda2/data/FISHER/fe_03_p1_tran /mnt/matylda2/data/FISHER/fe_03_p2_tran" # BUT,
local/swbd1_train_lms.sh data/local/train/text \
  data/local/dict_final_enrichment7/lexicon.txt data/local/lm $fisher_dirs

# Compiles G for swbd trigram LM
LM=data/local/lm/sw1.o3g.kn.gz
srilm_opts="-subset -prune-lowprobs -unk -tolower -order 3"
utils/format_lm_sri.sh --srilm-opts "$srilm_opts" \
  data/lang_final_enrichment7 $LM data/local/dict_final_enrichment7/lexicon.txt data/lang_final_enrichment7_sw1_tg

# Compiles const G for swbd+fisher 4gram LM, if it exists.
LM=data/local/lm/sw1_fsh.o4g.kn.gz
[ -f $LM ] || has_fisher=false
if $has_fisher; then
  utils/build_const_arpa_lm.sh $LM data/lang_final_enrichment7 data/lang_final_enrichment7_sw1_fsh_fg
fi
local/eval2000_data_prep.sh ~/Documents/Eval2000/hub5e_00 ~/Documents/Eval2000/2000_hub5_eng_eval_tr

if [ -e data/rt03 ]; then maybe_rt03=rt03; else maybe_rt03= ; fi
mfccdir=mfcc
for x in train eval2000 $maybe_rt03; do
  steps/make_mfcc.sh --nj 50 --cmd "$train_cmd" \
    data/$x exp/make_mfcc/$x $mfccdir
  steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
  utils/fix_data_dir.sh data/$x
done

utils/subset_data_dir.sh --first data/train 4000 data/train_dev # 5hr 6min
n=$[`cat data/train/segments | wc -l` - 4000]
utils/subset_data_dir.sh --last data/train $n data/train_nodev

utils/subset_data_dir.sh --shortest data/train_nodev 100000 data/train_100kshort
utils/subset_data_dir.sh data/train_100kshort 30000 data/train_30kshort

# Take the first 100k utterances (just under half the data); we'll use
# this for later stages of training.
utils/subset_data_dir.sh --first data/train_nodev 100000 data/train_100k
utils/data/remove_dup_utts.sh 200 data/train_100k data/train_100k_nodup  # 110hr

# Finally, the full training set:
utils/data/remove_dup_utts.sh 300 data/train_nodev data/train_nodup  # 286hr
## Starting basic training on MFCC features
steps/train_mono.sh --nj 30 --cmd "$train_cmd" \
  data/train_30kshort data/lang_final_enrichment7 exp/final_enrichment7

steps/align_si.sh --nj 30 --cmd "$train_cmd" \
  data/train_100k_nodup data/lang_final_enrichment7 exp/final_enrichment7 exp/final_ali_enrichment7