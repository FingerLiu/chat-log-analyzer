use utf8;
use strict;
use warnings;
use Text::CSV_XS qw( csv );
use Getopt::Long;
#TODO add parser for mht file
#TODO add param TYPE which indicate whether the log is a txt file or mht file

binmode(STDIN, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');
binmode(STDERR, ':encoding(utf8)');

our ($help,$input,$output,$oe);
&main();
exit 0;

sub main{
	GetOptions(
		"help!"			=>	\$help,
		"input=s"		=>	\$input,
		"output=s"		=>	\$output,
		"oe=s"			=>	\$oe
	);
	if($help){
		$help="Usage: perl qq_log_parser.pl -input INPUT_FILE -output OUTPUT_FILE -oe OUTPUT_ENCODING\n";
		print $help;
		exit 0;
	}
	unless ($input){
		print "please set input parameter." ;
		exit 0;
	}
	unless ($output){
		print "please set output parameter." ;
		exit 0;
	}
	
	unless ($oe){
		print "Output encoding not set,use utf8 as default." ;
		$oe = "UTF-8";
	}
	open CHAT_LOG,'<',$input
	                or die "Can't open $input: $!";                 
	binmode(CHAT_LOG, ':encoding(utf8)');

	my ($date,$title,$name,$id,$message)=("","","","","");
	my $data_arr=[[qw(date title name id message)]];
	
	while(my $line = <CHAT_LOG>){
	    if($line =~ /^\s*$/){next;}
	    elsif($line =~ /^(\d{4}-\d{2}-\d{2}\s\d{1,2}:\d{2}:\d{2})\s*【(.*)】(.*)\((\d*)\)$/ 
	    		||$line =~ /^(\d{4}-\d{2}-\d{2}\s\d{1,2}:\d{2}:\d{2})\s*【(.*)】(.*)<(\S*)>$/
	    		||$line =~ /^(\d{4}-\d{2}-\d{2}\s\d{1,2}:\d{2}:\d{2})(\s*)(.*)\((\d*)\)$/ 
	    		||$line =~ /^(\d{4}-\d{2}-\d{2}\s\d{1,2}:\d{2}:\d{2})(\s*)(.*)<(\S*)>$/
	    		){
	        push($data_arr,[$date,$title,$name,$id,$message]) if($date);
	        $date = $1,$title = $2,$name = $3,$id = $4;
	        $message = "";
	    }else{
	        $message .= $line;
	        $message =~ s/\cM\cJ?//g;
	    	$message =~ s/\n/ /g;
	    }
	}
	my $err = csv (in => $data_arr, out => $output,encoding => ":encoding($oe)") 
						or die Text::CSV_XS->error_diag;

	close CHAT_LOG
	                   or die "Can't close $input: $!";
	print "parse over!!!";
}