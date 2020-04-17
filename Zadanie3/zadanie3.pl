#!/usr/bin/perl
use Data::Dumper;

printf("Podaj nazwę pliku:");
$filename = <STDIN>;
#$filename = "strona2.html";

$argvSize = scalar(@ARGV);

@users;

if($argvSize >= 1)
{
	$filenameUsers = $ARGV[0];
	open FILE, $filenameUsers;
	while(defined($line=<FILE>))
	{
		chomp($line);
		#$line =~ s/\R//g;
		push(@users, $line);
	}
}

sub ReplaceDot($)
{
	$value = $_[0];

	$value =~ s/\./,/g;
	return $value;
}

sub GetNonEmptyValue($$)
{
	$param1 = $_[0];
	$param2 = $_[1];
	$returnParam = 0;
	if($param1 eq "")
	{
		$returnParam = ReplaceDot($param2);
	}
	else
	{
		$returnParam = ReplaceDot($param1);
	}

	if($returnParam == "-")
	{
		$returnParam = "0,0";
	}
	return $returnParam;
}

open FILE, $filename;
$i = 1;

$strCsv = "";
my %map = map { $_ => 1 } @users;
while(defined($line=<FILE>))
{
	while ($line =~ /(<td class="mini">(.*?)<\/td>)/g)
	{
		if($1 =~ /<a href="(?:.*?\/users\/(.*?))">(.*?)<\/a>/)
		{
			#login, imie i nazwisko osoby
			$nick = $1;

			if(exists($map{$nick})) 
			{ 
				next;
			}
			else
			{
				$strCsv .= "\"$nick\"" . ",\"". $2 . "\",";
			}	
		}

		if($1 =~ /<td class="mini">(?:(-)|<font title=".*?">(\d+.\d+)<\/font> \(\d+\)(?:&nbsp;)*)<\/td>/)
		{
			if(exists($map{$nick})) 
			{ 
				next;
			}
			else
			{
				$result = GetNonEmptyValue($1,$2);
				$strCsv .= "\"" . $result . "\",";
			}	
		}

		if($1 =~ /<td class="mini">(\d+.\d+.)<\/td>/)
		{
			if(exists($map{$nick})) 
			{ 
				next;
			}
			else
			{
				#wartość SCORE
				$strCsv .= "\"" . $1 . "\"\n";
			}	
			
		}
		
    }
	
}
my $filenameCsv = 'output.csv';
open(my $csv, '>', $filenameCsv) or die "Nie mozna otworzyc pliku '$filenameCsv' $!";
print $csv $strCsv;
close $csv;
