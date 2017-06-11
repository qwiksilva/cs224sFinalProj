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



for i in `seq 1 10`;
do
    echo $i

    local/swbd1_prepare_dict.sh --dir data/local/dict_final_enrichment$i

    cp runfor7enrichedmono/lexicon"$i".txt data/local/dict_final_enrichment$i/lexicon.txt

    utils/prepare_lang.sh data/local/dict_final_enrichment$i \
      "<unk>"  data/local/lang_final_enrichment$i data/lang_final_enrichment$i

    fisher_dirs="" #"/export/corpora3/LDC/LDC2004T19/fe_03_p1_tran/ /export/corpora3/LDC/LDC2005T19/fe_03_p2_tran/"
    # fisher_dirs="/home/dpovey/data/LDC2004T19/fe_03_p1_tran/"
    # fisher_dirs="/data/corpora0/LDC2004T19/fe_03_p1_tran/"
    # fisher_dirs="/exports/work/inf_hcrc_cstr_general/corpora/fisher/transcripts" # Edinburgh,
    # fisher_dirs="/mnt/matylda2/data/FISHER/fe_03_p1_tran /mnt/matylda2/data/FISHER/fe_03_p2_tran" # BUT,
    local/swbd1_train_lms.sh data/local/train/text \
      data/local/dict_final_enrichment$i/lexicon.txt data/local/lm $fisher_dirs

    # Compiles G for swbd trigram LM
    LM=data/local/lm/sw1.o3g.kn.gz
    srilm_opts="-subset -prune-lowprobs -unk -tolower -order 3"
    utils/format_lm_sri.sh --srilm-opts "$srilm_opts" \
      data/lang_final_enrichment$i $LM data/local/dict_final_enrichment$i/lexicon.txt data/lang_final_enrichment$i_sw1_tg

    ## Starting basic training on MFCC features
    steps/train_mono.sh --nj 30 --cmd "$train_cmd" \
      data/train_30kshort data/lang_final_enrichment$i exp/final_enrichment$i &

done
