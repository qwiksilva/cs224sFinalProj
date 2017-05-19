#!/usr/bin/perl -w

$Version = "0.5"; 

### Revision History
# Version 0.1, Release Sep 19, 1997
#    - initial release
# Version 0.2, Release Oct 29, 1997
#    - added support for sc_stats
#    - modified the csrfilt call for German and Spanish to is use the -e option
#      which tells it to upcase extended ASCII as well as 7-bit ASCII.
# Version 0.3, 
#    - Modified the filter proceedure to ALWAYS tell the user if it skipped the 
#      filtering stage.
# Version 0.4, Release April 6, 1998
#    - added access to the RESULTS Server
#    - added -M and -w options
# Version 0.5, Released March 5, 2000
#    - Modifed to require updated tranfilt package

$Usage="hubscr05.pl [ -R -v -L LEX ] [ -M LM | -w WWL ] -g glm -l LANGOPT -h HUBOPT -r ref hyp1 hyp2 ...\n".
"Version: $Version\n".
"Desc: Score a Hub-4E/NE or Hub-5E/NE evaluation using the established\n".
"      guidelines.  There are a set of language dependent options that this\n".
"      script requires, they are listed below with their dependencies.\n".
"      If more than one hyp is present, the set of hyps are viewed as an\n".
"      'ensemble' of ruesult that can be statistically compared with sc_stats.\n".
"      The output reports are written with a root filename specified by '-n'\n".
"      and optionally described with the '-e' flag.\n".
"General Options:\n".
"      -R         ->  Submit the scoring run to the NIST RESULTS Server\n".
"      -g glm     ->  'glm' specifies the filename of the Global Mapping Rules\n".
"      -v         ->  Verbosely tell the user what is being executed\n". 
"      -h [ hub4 | hub5 ]\n".
"                 ->  Use scoring rules for hub4 or hub5.  Currently there is no\n".
"                     difference in scoring\n".
"      -l [ arabic | english | german | mandarin | spanish ]\n".
"                 ->  Set the input language.\n".
"      -L LDC_Lex ->  Filename of an LDC Lexicon.  The option is required only to\n".
"                     score a German or Arabic test.\n".
"      -M SLM_lm  ->  Use the CMU-Cambridge SLM V2.0 binary language model 'LM'\n".
"                     to perform Weighted-Word Scoring.  May not be used with -w\n".
"      -w WWL     ->  Use the Word-Weight List File to perform Weighted-Word\n".
"                     scoring.  May not be used with -M\n".
"Other Options:\n".
"      -n str     ->  Root filename to write the ensemble reports to.  Default\n".
"                     is 'Ensemble'\n".
"      -e 'desc'  ->  Use the description 'desc' as a sub-header in all reportsk.\n".

"\n";


################################################
#######          MAIN PROGRAM          #########
&SetGlobals();
&ProcessCommandLine();
if (! $UseResults) {
    local($h); 
    &VerifyResources();
    
    &FilterFile($Ref, $Ref.".filt", $Lang, "stm");
    for ($h=0; $h<=$#Hyps; $h++){
	&FilterFile($Hyps[$h], $Hyps_oname[$h], $Lang, "ctm");
	&RunScoring($Ref,$Hyps[$h],$Hyps_iname[$h],$Hyps_oname[$h],$Lang);
    }
    
    &RunStatisticalTests(@Hyps_oname) if ($#Hyps > 0);
} else {
    &SubmitToResults();
}

exit 0;

#######          END OF MAIN           #########
################################################


################################################################
#############     Set all Global variables         #############
sub SetGlobals{
    $Vb = 0;
    $email = "jonathan.fiscus\@nist.gov";
    $Lang = "Undeterm";
    $Hub = "Undeterm";
    $Ref = "Undeterm";
    @Hyps = ();
    @Hyps_iname = ();
    @Hyps_oname = ();
    ### Installation directory for the SCTK package.  If the package's
    ### executables are accessible via your path, this variable may remain 
    ### empty.
    $SCTK = "../sctk-1.2";
    $SCLITE = "";
    $SC_STATS = "";
    ### Installation directory for the tranfilt package.   If the package's
    ### executables are accessible via your path, this variable may remain 
    ### empty.
    $TRANFILT="../tranfilt-1.10";
    $CSRFILT="";
    $DEF_ART="";
    $GLM = "";
    $ACOMP = "";
    $LDCLEX = "";
    ### Defaults for SC_stats
    $EnsembleRoot = "";
    $EnsembleDesc = "";
    ### Set up the RESULTS Server
    $RESULTS_host = "jaguar.ncsl.nist.gov";
    $UseResults = 0;
    ###
    $SLM_LM = "";
    $WWL = "";
}

################################################################
################ Get the command line arguments ################
sub ProcessCommandLine{
    require "getopts.pl";
    local($hyp);
    &Getopts('l:h:r:vg:L:n:e:RM:w:');
    if (defined($opt_l)) {	$Lang = $opt_l; $Lang =~ tr/A-Z/a-z/; }
    if (defined($opt_h)) {	$Hub = $opt_h; $Hub =~ tr/A-Z/a-z/; }
    if (defined($opt_r)) {	$Ref = $opt_r; }
    if (defined($opt_v)) {	$Vb = 1; $opt_v = 1; }
    if (defined($opt_L)) {	$LDCLEX = $opt_L; }
    if (defined($opt_n)) {	$EnsembleRoot = $opt_n; }
    if (defined($opt_e)) {	$EnsembleDesc = $opt_e; }
    if (defined($opt_R)) {	$UseResults = $opt_R; }
    if (defined($opt_M)) {	$SLM_LM = $opt_M; }
    if (defined($opt_w)) {	$WWL = $opt_w; }
    if (defined($opt_g)) {	
	$GLM = $opt_g; 
	die("$Usage\nError: Unable to stat GLM file '$GLM'") if (! -f $GLM);
    } else {
	die("$Usage\nError: GLM file required via -g option");
    }

    #### Language checks/Verification
    die("$Usage\nError: Language defintion required via -l") if ($Lang eq "Undeterm"); 
    die("$Usage\nError: Undefined language '$Lang'") 
	if ($Lang !~ /^(english|german|spanish|mandarin|arabic)$/);

    #### Hub Check/Verification
    die("$Usage\nError: Hub defintion required via -h") if ($Hub eq "Undeterm"); 
    die("$Usage\nError: Undefined Hub '$Hub'") if ($Hub !~ /^(hub4|hub5)$/);

    #### Reference File Check/Verification
    die("$Usage\nError: Reference file defintion required via -r") if ($Ref eq "Undeterm"); 
    die("$Usage\nError: Unable to access reference file '$Ref'\n") if (! -f $Ref);

    #### extract the hypothesis files
    die("$Usage\nError: Hypothesis files required") if ($#ARGV < 0);
    @Hyps_DEFS = @ARGV;
    foreach $hyp(@Hyps_DEFS){
	local(@Arr) = split(/\\#/,$hyp);
        if ($#Arr < 1) { $Arr[1] = $Arr[0]; } elsif ($Arr[1] =~ /^$/) { $Arr[1] = $Arr[0]; }
        if ($#Arr < 2) { $Arr[2] = $Arr[0]; } elsif ($Arr[2] =~ /^$/) { $Arr[2] = $Arr[0]; }
	push(@Hyps,$Arr[0]);
        push(@Hyps_iname,$Arr[1]);
        push(@Hyps_oname,$Arr[2].".filt");
    }
    foreach $hyp(@Hyps){
	die("$Usage\nError: Unable to access hypothesis file '$hyp'\n") if (! -f $hyp);
    }

    print STDERR "Warning: LDC lexicon option '-L $LDCLEX' ignored!!!!\n"
	if (($Lang ne "german" && ($Lang ne "arabic")) && $LDCLEX ne "");

    die("$Usage\nError: Unable to access LDC Lexicon file '$LDCLEX'\n") 
	if ((($Lang eq "german") || ($Lang eq "arabic")) && (! -f $LDCLEX));

    #### Check the LM and WWL files
    die("$Usage\nError: Unable to use both -M and -w\n") 
	if (defined($opt_M) && defined($opt_w));
    die("$Usage\nError: SLM language model '$opt_M' not found\n") 
	if (defined($opt_M) && (! -f $opt_M));
    die("$Usage\nError: WWL file '$opt_w' not found\n") 
	if (defined($opt_w) && (! -f $opt_w));
}

################################################################
###########  Make sure sclite, tranfilt, and other  ############
###########  resources are available.               ############
sub get_version{
    local($exe, $name) = @_;
    local($ver) = "foo";

    open(IN,"$exe 2>&1 |") ||
	die("Error: unable to exec $name with the command '$exe'");
    while (<IN>){
	if ($_ =~ /Version: (\d+\.\d+)[a-z]*/){
	    $ver = $1;
	}
    }
    close(IN);
    die "Error: unable to exec $name with the command '$exe'"
	if ($ver eq "foo");
    $ver;
}

sub VerifyResources{
    local($ver);

    #### 
    #### look for sctk
    if ($SCTK ne ""){
	die("$Usage\nError: variable \$SCTK does not defined a valid\n".
	    "       directory.  This package ls available from the URL\n".
	    "       http://www.nist.gov/speech/software.htm") if (! -d $SCTK);
	$SCLITE = "$SCTK/src/sclite";
	$SC_STATS = "$SCTK/src/sc_stats";
    } else {
	if ($Vb){
	    print("Advisement: using SCTK executables via \$PATH environment variable\n");
	}
	$SCLITE = "sclite";
	$SC_STATS = "sc_stats";
    }
    ### Check the version of sclite
    $ver = "";
    open(IN,"$SCLITE 2>&1 |") ||
	die("Error: unable to exec sclite with the command '$SCLITE'");
    while (<IN>){
	if ($_ =~ /sclite Version: (\d+\.\d+)[a-z]*,/){
	    $ver = $1;
	}
    }
    close(IN);
    die ("SCLITE executed by the command '$SCLITE' is too old. \n".
	 "       Version 2.0 or better is needed.  This package ls available\n".
	 "       from the URL http://www.nist.gov/speech/software.htm") if ($ver < 2.0);

    ### Check the version of sclite
    $ver = "";
    open(IN,"$SC_STATS 2>&1 |") ||
	die("Error: unable to exec sc_stats with the command '$SC_STATS'");
    while (<IN>){
	if ($_ =~ /sc_stats Version: (\d+\.\d+)[a-z]*,/){
	    $ver = $1;
	}
    }
    close(IN);
    die ("SC_STATS executed by the command '$SC_STATS' is too old. \n".
	 "       Version 1.1 or better is needed.  This package ls available\n".
	 "       from the URL http://www.nist.gov/speech/software.htm") if ($ver < 1.1);

    ##### 
    #####  Look for tranfilt
    if ($TRANFILT ne ""){
	die("$Usage\nError: variable \$TRANFILT does not defined a valid\n".
	    "       directory.  This package ls available from the URL\n".
	    "       http1://www.nist.gov/speech/software.htm") if (! -d $TRANFILT);
	$CSRFILT = "$TRANFILT/csrfilt.sh";
	$DEF_ART = "$TRANFILT/def_art.pl";
	$ACOMP =   "$TRANFILT/acomp.pl";
    } else {
	if ($Vb){
	    print("Advisement: using TRANFILT executables via ".
		  "\$PATH environment variable\n");
	}
	$CSRFILT = "csrfilt.sh";
	$DEF_ART = "def_art.pl";
	$ACOMP =   "acomp.pl";
    }
    #### Check for CSRFILT
    $ver = &get_version($CSRFILT,"csrfilt.sh");
    die ("CSRFILT executed by the command '$CSRFILT' is too old. \n".
	 "       Version 1.10 or better is needed.  This package ls available\n".
	 "       from the URL http://www.nist.gov/speech/software.htm") if ($ver < 1.10 || $ver >= 1.2);

    $ver = &get_version($DEF_ART,"def_art.pl");
    die ("def_art.pl executed by the command '$DEF_ART' is too old. \n".
	 "       Version 1.0 or better is needed.  This package ls available\n".
	 "       from the URL http://www.nist.gov/speech/software.htm") if ($ver < 1.0);

    $ver = &get_version($ACOMP,"acomp.sh");
    die ("acomp.pl executed by the command '$ACOMP' is too old. \n".
	 "       Version 1.0 or better is needed.  This package ls available\n".
	 "       from the URL http://www.nist.gov/speech/software.htm") if ($ver < 1.0);


}

sub FilterFile{
    local($file, $outfile, $lang, $format) = @_;
    local($rtn);
    local($csrfilt_com);
#    local($def_art_com);
    local($acomp_com);
    local($com);

    print "Filtering $lang file '$file', $format format\n";
    if (! -f $outfile){

	if ($Lang =~ /^(arabic)$/){ 
	    $csrfilt_com = "$CSRFILT -s -i $format -dh $GLM";
	    $def_art_com = "$DEF_ART -s $LDCLEX -i $format - -";
	    $com = "cat $file | $def_art_com | $csrfilt_com > $outfile";
	} elsif ($Lang =~ /^(mandarin)$/){ 
	    $csrfilt_com = "$CSRFILT -i $format -dh $GLM";

	    $com = "cat $file | $csrfilt_com > $outfile";
	} elsif ($Lang =~ /^(spanish)$/){ 
	    $csrfilt_com = "$CSRFILT -e -i $format -dh $GLM";

	    $com = "cat $file | $csrfilt_com > $outfile";
	} elsif ($Lang =~ /^(german)$/){ 
	    $csrfilt_com = "$CSRFILT -e -i $format -dh $GLM";
	    $acomp_com =   "$ACOMP -f -m 2 -l $LDCLEX -i $format - -";

	    $com = "cat $file | $csrfilt_com | $acomp_com > $outfile";
	} elsif ($Lang =~ /^(english)$/){ 
	    $csrfilt_com = "$CSRFILT -i $format -dh $GLM";

	    $com = "cat $file | $csrfilt_com > $outfile";
	} else {
	    die "Undefined language: '$lang'";
	}

#	    $com = "cat $file > $outfile";
	
	print "   Exec: $com\n" if ($Vb);
	$rtn = system $com;
	if ($rtn != 0) {
	    system("rm -f $outfile");
	    die("Error: Unable to filter file: $file with command:\n   $com\n");
	}
    } else {
	print "   ....Already filtered.  Delete $outfile to re-filter\n"
    }
}

sub RunScoring{
    local($ref, $hyp, $hyp_iname, $hyp_oname, $lang) = @_;
    local($reff) = ($ref.".filt");
    local($rtn);
    local($outname);

    ($outname = "-n $hyp_oname") =~ s:^-n (\S+)/([^/]+)$:-O $1 -n $2:;
    print "Scoring $lang Hyp '$hyp_oname' against ref '$reff'\n";

    $command = "$SCLITE -r $reff stm -h $hyp_oname ctm $hyp_iname -F -D -o sum rsum sgml lur dtl -C det sbhist hist $outname";
    if ($Lang =~ /^(mandarin)$/){ 
	$command .= " -c NOASCII DH -e gb";
    }
    if ($Lang =~ /^(arabic)$/){ 
	$command .= " -s";
    }
    if ($Lang =~ /^(spanish)$/){ 
	;
    }
    if ($SLM_LM !~ /^$/ || $WWL !~ /^$/){ 
	$command .= " -L $SLM_LM" if ($SLM_LM !~ /^$/);
	$command .= " -w $WWL" if ($WWL !~ /^$/);
	$command .= " -o wws";
    }

    print "   Exec: $command\n" if ($Vb);
    $rtn = system($command);
    die("Error: SCLITE execution failed\n      Command: $command") if ($rtn != 0);
}

sub RunStatisticalTests{
    local(@Hy) = @_;
    local($hyp);
    local($sgml);
    local($command) = "";
    local($rtn);

    print "Running Statistical Comparison Tests\n";
    
    $command = "cat";
    ## verify the sgml files were made, and add to the cat list;
    print "    Checking for sclite's sgml files\n" if ($Vb);
    foreach $hyp(@Hy){
	$sgml = $hyp.".sgml";
	die "Error: Unable to local sgml file '$sgml'" if (! -f $sgml);
	$command .= " $sgml";
    }
    $command .= " | $SC_STATS -p -r sum rsum es res lur -t std4 -u -g grange2 det";
    $command .= " -n $EnsembleRoot" if ($EnsembleRoot ne "");
    $command .= " -e \"$EnsembleDesc\"" if ($EnsembleDesc ne "");

    print "    Exec: $command\n" if ($Vb);
    $rtn = system($command);
    die("Error: SC_STATS execution failed\n      Command: $command") if ($rtn != 0);
}

################################################################################
################################################################################
################################################################################
#####
#####             RESULTS SERVER CLIENT
#####
sub absolute_path{
    local($pwd,$file) = @_;
    if ($file =~ /^\//){ $file; }
    else { $pwd."/".$file; }
}

sub report_err{
    local($mesg) = @_;

    print "Error: $mesg\n";
    print "       Contact Jon Fiscus, $email.  Refer to Job '$JOB'.\n";
}

sub exit_message{
    local($mesg) = @_;
    &report_err($mesg);
    print "       ****** Delete $TMPDIR By hand  ******\n";
    exit 1;
} 

sub DumpFile{
    local($file,$pre,$errmesg) = @_;

    open(FILE,$file) || &exit_message($errmesg);
    while(<FILE>){ print $pre.$_;} 
    close(FILE);
}

sub BuildResultsSubmission{
    local($pid, $user, $host, $TMPDIR, $OUT_TARFILE, $CTLFILE, $SERVER_version, $SERVER_dir) = @_;
    local($pwd) = `pwd`; chop($pwd);
    local($transfer_list) = "ctlfile"; 

    local($n) = 1;
    local($hyp);

    if (-d $TMPDIR) {
	print "    Removing previous temporary directory $TMPDIR\n";
	system("rm -rf $TMPDIR");
    }
    system("mkdir $TMPDIR");
 
    print "    Building Control File\n" if ($Vb);
    open(CTL,">$TMPDIR/$CTLFILE") || &exit_message("Failed to open controlfile $TMPDIR/$CTLFILE");

    print CTL "RESULTS $SERVER_version Control File:\n";
    print CTL "Program:hubscr05.pl\n";
    print CTL "Submission_Date:".`date`;
    print CTL "Submission_ID:$host.$user.$pid";
    print CTL "USER:$user\n";
    print CTL "HOST:$host\n";
    print CTL "GLM:glm:$GLM\n";   
    system("ln -s ".&absolute_path($pwd,$GLM)." $TMPDIR/glm"); $transfer_list .= " glm";
    print CTL "HUB:$Hub\n";
    print CTL "LANGUAGE:$Lang\n";
    print CTL "LDCLEX:$LDCLEX\n";
    if ($LDCLEX !~ /^$/){
	system("ln -s ".&absolute_path($pwd,$LDCLEX)." $TMPDIR/ldclex");
	$transfer_list .= " ldclex";
    }
    print CTL "Ensemble_Root:$EnsembleRoot\n" if (defined($opt_n));
    print CTL "Ensemble_Desc:$EnsembleDesc\n" if (defined($opt_e));
    if (defined($opt_M)) {
	print CTL "SLM_LM:slm_lm:$SLM_LM\n" ;
	system("ln -s ".&absolute_path($pwd,$SLM_LM)." $TMPDIR/slm_lm");
	$transfer_list .= " slm_lm";
    }
    if (defined($opt_w)) {
	print CTL "WWL:wwl:$WWL\n" ;
	system("ln -s ".&absolute_path($pwd,$WWL)." $TMPDIR/wwl");
	$transfer_list .= " wwl";
    }
    print CTL "REF:ref:$Ref\n";
    system("ln -s ".&absolute_path($pwd,$Ref)." $TMPDIR/ref"); 	$transfer_list .= " ref";
    foreach $hyp(@Hyps){
	print CTL  "HYP:hyp$n:$hyp\n"; 
	system("ln -s ".&absolute_path($pwd,$hyp)." $TMPDIR/hyp$n");
	$transfer_list .= " hyp$n";
	$n++;
    }
    print CTL "TRANSFER_LIST:$transfer_list\n";
    close(CTL);
    system("cp $TMPDIR/$CTLFILE $TMPDIR/ctlfile");    

    if ($Vb) {
	print "        Controlfile Contents:\n";
	&DumpFile("$TMPDIR/$CTLFILE","            ",
		  "Unable to open Control file $TMPDIR/$CTLFILE to read");
    }

    print "    Building Submission Tar File\n" if ($Vb);
    system("(cd $TMPDIR; tar chf - $transfer_list | compress > $TMPDIR/$OUT_TARFILE)");

    print "    Building FTP command file\n";
    open(FTP,">$TMPDIR/ftpcom") || &exit_message("Failure to open ftp command file '$TMPDIR/ftpcom'");
    print FTP "user ftp $user\@\n";
    print FTP "cd $SERVER_dir/submissions\n";
    print FTP "binary\n";
    print FTP "put $OUT_TARFILE\n";
    print FTP "put $CTLFILE\n";
    print FTP "bye\n";
    close(FTP);
    
    if ($Vb) {
	print "        FTP Command File Contents:\n";
	&DumpFile("$TMPDIR/ftpcom","            ","Unable to open FTP Command file $TMPDIR/ftpcom to read");
    }
}

sub TransmitToRESULTS_server{
    local($TMPDIR, $OUT_TARFILE, $CTLFILE) = @_;
    local(@log) = ();
    local($s, $mb);
    
    local(@st) = stat("$TMPDIR/$OUT_TARFILE");
    $mb = sprintf("%.3f",$st[7]/1048576);
    print "    Transmitting $mb Mb. to RESULTS Server\n";
    open(FTPPUT,"( cd $TMPDIR ; ftp -n $RESULTS_host < $TMPDIR/ftpcom 2>&1 ) |") 
	|| &exit_message("FTP upload failed to open");
    @log = <FTPPUT>;
    close(FTPPUT);
    
    if ($Vb || $#log >= 0){ 
	if ($#log >= 0) { print "    FTP log:  ***** An error occurred ****\n"; }
	else {	print "    FTP Log:  (and empty log indicates success.)\n"; }
	foreach $s(@log){ print "        $s"; }
    }
    &exit_message("") if ($#log >= 0);

    print "        **** Upload Complete ****\n";

}

sub CheckResultsStatus{
    local($STATUSFILE, $LOGFILE, $TMPDIR, $SERVER_dir) = @_;
    local(@log) = ();
    local($s);

    open(FTP,">$TMPDIR/ftpcom") || &exit_message("Failure to open ftp command file '$TMPDIR/ftpcom'");
    print FTP "user ftp $user\@\n";
    print FTP "cd $SERVER_dir/responses\n";
    print FTP "binary\n";
    print FTP "get $STATUSFILE\n";
    print FTP "get $LOGFILE\n";
    print FTP "bye\n";
    close(FTP);
    
    if ($Vb) {
	print "        FTP Command File Contents:\n";
	&DumpFile("$TMPDIR/ftpcom","            ",
		  "Unable to open FTP Command file $TMPDIR/ftpcom to read");
	print "    Querying RESULTS Server\n";
    }
    
    open(FTPPUT,"( cd $TMPDIR ; ftp -n $RESULTS_host < $TMPDIR/ftpcom 2>&1 ) |") 
	|| &exit_message("FTP upload failed to open");
    @log = <FTPPUT>;
    close(FTPPUT);

    if ($#log < 0){ 
	open(STAT,"$TMPDIR/$STATUSFILE") || &report_err("Unable to read status file, even though it was downloaded\n");
	$_ = <STAT>; close(STAT);
	$_;
    } else {
	"Nothing Yet"; 
    }
}

sub RetrieveResults{
    local($RESULTSFILE, $TMPDIR, $SERVER_dir) = @_;

    open(FTP,">$TMPDIR/ftpcom") || &exit_message("Failure to open ftp command file '$TMPDIR/ftpcom'");
    print FTP "user ftp $user\@\n";
    print FTP "cd $SERVER_dir/responses\n";
    print FTP "binary\n";
    print FTP "get $RESULTSFILE\n";
    print FTP "bye\n";
    close(FTP);
    
    if ($Vb) {
	print "        FTP Command File Contents:\n";
	&DumpFile("$TMPDIR/ftpcom","            ",
		  "Unable to open FTP Command file $TMPDIR/ftpcom to read");
	print "    Downloading from RESULTS Server\n";
    }
    open(FTPPUT,"( cd $TMPDIR ; ftp -n $RESULTS_host < $TMPDIR/ftpcom 2>&1 ) |") 
	|| &exit_message("FTP upload failed to open");
    @log = <FTPPUT>;
    close(FTPPUT);

    if ($Vb || $#log >= 0){ 
	if ($#log >= 0) { print "    FTP log:  ***** An error occurred ****\n"; }
	else {	print "    FTP Log:  (and empty log indicates success.)\n"; }
	foreach $s(@log){ print "        $s"; }
    }
    &exit_message("") if ($#log >= 0);

    local(@st) = stat("$TMPDIR/$RESULTSFILE");
    $mb = sprintf("%.3f",$st[7]/1048576);
    print "    **** Download of $mb Mb. Complete ****\n";
}

sub DistributeResults{
    local($TMPDIR, $RESULTSFILE) = @_;
    local($h); 

    print "Extracting Results\n";
    system("mkdir $TMPDIR/results");
    system("(cd $TMPDIR/results ; zcat $TMPDIR/$RESULTSFILE | tar xf -)");
    if ($Vb) { system("(cd $TMPDIR/results ; zcat $TMPDIR/$RESULTSFILE | tar tf - | sed 's/^/    /')"); }

    for ($h=0; $h<=$#Hyps; $h++){
	local($hdir) = $Hyps[$h]; $hdir =~ s:/[^/]*$::;
	$hdir = "." if ($hdir eq $Hyps[$h]);
	local($hname) = $Hyps[$h]; $hname =~ s:^.*/::;
	system("cp $TMPDIR/results/$hname.* $hdir");
    }
    if (defined($opt_n) || $#Hyps > 0){
	local ($efile) = "Ensemble";
	$efile = $EnsembleRoot if (defined($opt_n));
	system("cp $TMPDIR/results/$efile.* .");
    }
    system("cp $TMPDIR/results/ref.filt $Ref.filt");
}

sub AcknowledgeCompletion{
    local($TMPDIR, $ACKFILE) = @_;

    print "Acknowledging Receipt\n";
    open(FTP,">$TMPDIR/ftpcom") || &exit_message("Failure to open ftp command file '$TMPDIR/ftpcom'");
    print FTP "user ftp $user\@\n";
    print FTP "cd $SERVER_dir/responses\n";
    print FTP "binary\n";
    print FTP "put $ACKFILE\n";
    print FTP "bye\n";
    close(FTP);

    open(ACK,">$TMPDIR/$ACKFILE") || &exit_message("Failure to open ack command file '$TMPDIR/$ACKFILE'");
    print ACK "ACK\n";
    close(ACK);

    open(FTPPUT,"( cd $TMPDIR ; ftp -n $RESULTS_host < $TMPDIR/ftpcom 2>&1 ) |") 
	|| &exit_message("FTP of ACK upload failed to open");
    @log = <FTPPUT>;
    close(FTPPUT);

    #### So What!
    if ($#log >= 0) { 
	print "    FTP of ACK Failed,  log:  ***** An error occurred ****\n"; 
	foreach $s(@log){ print "        $s"; }
	&exit_message("FTP of ACT Failed");
    }

    print "    **** Acknowledgment Complete ****\n";    
}

sub SubmitToResults{
    print "Submitting scoring run to RESULTS Server\n";
    local($host) = `uname -n`;    chop($host);
    local($user) = $ENV{'USER'};
    local($pid) = $$;
    local($TMPDIR) = "/tmp/hubscr.$user.$pid";
    local($JOB) = "$host.$user.$pid";
    local($OUT_TARFILE) = "$host.$user.$pid.tar.Z";
    local($CTLFILE) = "$host.$user.$pid.ctlfile";
    local($STATUSFILE) = "$host.$user.$pid.status";
    local($RESULTSFILE) = "$host.$user.$pid.results.tar.Z";
    local($LOGFILE) = "$host.$user.$pid.log";
    local($ACKFILE) = "$host.$user.$pid.ack";
    local($NotDone) = 1;
    local($FirstStart) = 1;
    local($FirstNothing) = 1;
    local($sleeptime) = 5;
    local($SERVER_version) = "V0.1";
    local($SERVER_dir) = "RESULTS_server/$SERVER_version";

    &BuildResultsSubmission($pid, $user, $host, $TMPDIR, $OUT_TARFILE, $CTLFILE, $SERVER_version, $SERVER_dir);
    &TransmitToRESULTS_server($TMPDIR, $OUT_TARFILE, $CTLFILE);

    print "    Waiting for Status messages\n";
    while($NotDone){
	system("sleep $sleeptime");
	$status = &CheckResultsStatus($STATUSFILE, $LOGFILE, $TMPDIR, $SERVER_dir);
	if ($status =~ /Processing Started/) {
	    print "        $status" if ($FirstStart || $Vb);
	    $FirstStart = 0;
	} elsif ($status =~ /Processing Aborted/) {
	    print "        $status";
	    &exit_message("    Please consult the Logfile: $TMPDIR/$LOGFILE\n");
	} elsif ($status =~ /Processing Complete/) {
	    $NotDone = 0;
	    print "        $status";
	    &RetrieveResults($RESULTSFILE, $TMPDIR, $SERVER_dir);
	    &DistributeResults($TMPDIR, $RESULTSFILE);
	    &AcknowledgeCompletion($TMPDIR, $ACKFILE);
	    print "Successful Completion of Scoring, Removing temporary files.\n";
	    system("rm -fr $TMPDIR");
	    exit 0;
	} else {
	    print "        $status\n" if ($FirstNothing == 1);
	    print "        $status after $FirstNothing checks every $sleeptime seconds.\n" if (($FirstNothing) % 10 == 0);	    
	    $FirstNothing ++;
	}
    }
}


