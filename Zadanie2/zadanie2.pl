#!/usr/bin/perl
use Data::Dumper;
use List::MoreUtils qw(uniq);

@minutes;

sub ObliczanieGodzinLekcyjnych($$$$)
{
	my $break = 0; #przerwa w minutach;
	my $lesson_length = 45; #długość jednej godziny lekcyjnej w minutach
	my $start_hour = $_[0];
	my $start_minute = $_[1];

	my $end_hour = $_[2];
	my $end_minute = $_[3];

	my $hours = $end_hour - $start_hour;
	my $minutes = $end_minute - $start_minute;
	
	my $val = $hours * 60 + $minutes;
	push(@minutes, $val);
	$val -= (($hours - 1) * $break);
	return $val/$lesson_length; 
};

sub WyswietlenieGodziny($$$$)
{
	my $start_hour = $_[0];
	my $start_minute = $_[1];

	my $end_hour = $_[2];
	my $end_minute = $_[3];
 
	my $str = sprintf("$start_hour:$start_minute - $end_hour:$end_minute");
	return $str;
};

#printf("Podaj nazwę pliku:");
#$filename = <STDIN>;
$filename = "plan_zajec.ics";

open FILE, $filename;

%przedmioty;

$suma_godzin = 0;

my $skrot = "";
my $start_hour;
my $start_minute;

my $end_hour;
my $end_minute;

my $przedmiot;
my $semestr;
my $forma_studiow;
my $forma_zajec;

while(defined($line=<FILE>))
{
	if($line =~ /DTSTART;TZID=[A-Za-z]+\/[A-Za-z]+:[0-9]{4}[0-9]{2}[0-9]{2}T*([0-9]{2})*([0-9]{2})[0-9]{2}/)
	{
		$przedmioty{$skrot}{"PoczatekGodz"} = $1;
		$przedmioty{$skrot}{"PoczatekMin"} = $2;
	}

	if($line =~ /DTEND;TZID=[A-Za-z]+\/[A-Za-z]+:[0-9]{4}[0-9]{2}[0-9]{2}T*([0-9]{2})*([0-9]{2})[0-9]{2}/)
	{	
		$przedmioty{$skrot}{"KoniecGodz"} = $1;
		$przedmioty{$skrot}{"KoniecMin"} = $2;
		
		$start_hour = $przedmioty{$skrot}{"PoczatekGodz"};
		$start_minute = $przedmioty{$skrot}{"PoczatekMin"};
		$end_hour = $przedmioty{$skrot}{"KoniecGodz"};
		$end_minute = $przedmioty{$skrot}{"KoniecMin"};			
	}

	#S1_I|N1_I|lato_HSPO1|HSPO1|SP_PK|PO IV_Pkg|BP1_PWJS|lato_S2_I
	if($line =~ /SUMMARY:*([A-Za-z0-9 -ąćęłńóśźż]+) - Nazwa sem.: semestr [0-9a-zA-z]+, Nr sem.: ([0-9]), Grupa: (.*),/)
	{
		$przedmiot = $1;
		$semestr = $2;
		if($3 =~ /(?:lato_|zima_)*(S1|S2|N1|N2)?.*(L|W)/)
		{
			$forma_studiow = $1;
			$forma_zajec = $2;
		}

		if($forma_studiow eq "")
		{
			$forma_studiow = "unknown";
		}

		if($forma_zajec eq "")
		{
			$forma_zajec = "unknown";
		}

		$skrot = sprintf("%s_%s_%s",$przedmiot,$forma_studiow, $forma_zajec);

		$przedmioty{$skrot}{"Godziny"};
		$przedmioty{$skrot}{"Nazwa"} = $przedmiot;
		$przedmioty{$skrot}{"FormaStudiow"} = $forma_studiow;
		$przedmioty{$skrot}{"FormaZajec"} = $forma_zajec;
		
		$godziny_lekcyjne = ObliczanieGodzinLekcyjnych($start_hour, $start_minute, $end_hour, $end_minute);
		$s = WyswietlenieGodziny($start_hour, $start_minute, $end_hour, $end_minute);
		$suma_godzin += $godziny_lekcyjne;
		$przedmioty{$skrot}{"Godziny"} += $godziny_lekcyjne;

		#printf("%s: %s -> %.2f\n",$przedmiot , $s, $godziny_lekcyjne);
		#printf("%.2f\n", $godziny_lekcyjne);

		$przedmiot = "";
	}
}

printf("Suma godzin: %.2f\n",  $suma_godzin );
my $filenameOut = "output.csv";
open(my $fileOut, '>', $filenameOut) or die "Nie mozna otworzyc pliku '$filenameOut' $!";

foreach $key (keys %przedmioty)
{
	$prze = $przedmioty{$key}{"Nazwa"};
	$godz = $przedmioty{$key}{'Godziny'};
	$fz = $przedmioty{$key}{'FormaZajec'};
	$fs = $przedmioty{$key}{'FormaStudiow'};
	$csvOut = sprintf("\"%s\",\"%s\",\"%s\",\"%.2f\"\n", $prze,$fz,$fs,$godz);
	if($prze ne "")
	{
		print $fileOut "$csvOut";
	}
}
close $fileOut;
