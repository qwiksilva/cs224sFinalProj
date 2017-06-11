mfccdir=mfcc
for x in train; do
      steps/make_mfcc.sh --nj 50 --cmd "queue.pl" \
      data/$x exp/make_mfcc/$x $mfccdir
      steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
      utils/fix_data_dir.sh data/$x
done
