steps/align_si.sh --nj 30 --cmd queue.pl data/train_100k_nodup data/lang_nosp exp/mono exp/mono_ali

steps/train_deltas.sh --cmd queue.pl 3200 30000 data/train_100k_nodup data/lang_nosp exp/mono_ali exp/tri1

steps/align_si.sh --nj 30 --cmd "queue.pl" data/train_100k_nodup data/lang_nosp exp/tri1 exp/tri1_ali

steps/train_deltas.sh --cmd "queue.pl" 4000 70000 data/train_100k_nodup data/lang_nosp exp/tri1_ali exp/tri2

