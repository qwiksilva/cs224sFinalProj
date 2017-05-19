mfccdir=mfcc_icsi
for x in data/icsi-alignme; do
    steps/make_mfcc.sh --cmd "run.pl" --nj 16 $x exp/make_mfcc/$x $mfccdir
    utils/fix_data_dir.sh data/icsi-alignme
    steps/compute_cmvn_stats.sh $x exp/make_mfcc/$x $mfccdir
    utils/fix_data_dir.sh data/icsi-alignme
done

steps/align_si.sh --cmd "run.pl" data/icsi-alignme data/lang_nosp exp/mono exp/mono_ali || exit 1;

for i in exp/tri4a_alignme/ali.*.gz;
do src/bin/ali-to-phones --ctm-output exp/mono/final.mdl ark:"gunzip -c $i|" -> ${i%.gz}.ctm;
done;
