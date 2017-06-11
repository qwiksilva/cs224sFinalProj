explode_lex.py
    Script adapted from previous CS224s (Simon Todd and Guan Wang and Jingrui Zhang) to create different lexicons with phonetic rules.

s5c/data/icsi_set/
    Contains the ICSI evaluation set and files so that kaldi can read these files. Also contains scripts to calculate phone       and alignment accuracy.

s5c/run_testing.sh and s5c/run_testing_nnet.sh
    scripts to evaluate GMM and NNet models on ICSI

s5c/run_*.sh
    scripts to train a series of models with different lexicons

s5c/steps/train_mono.sh
    tuned monophone training script
