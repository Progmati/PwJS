#!/usr/bin/perl
use Cwd;
use Data::Dumper;
use Fcntl ':mode';

sub GenerateRWX
{
	$value = $_[0];
	my $str = '';
	@bin = ($value & 4, $value & 2, $value & 1);

	if(@bin[0] > 0) {	$str = $str ."r"; }
	else {	$str = $str ."-"; }
	
	if(@bin[1] > 0) {	$str = $str ."w"; }
	else {	$str = $str ."-"; }

	if(@bin[2] > 0) {	$str = $str ."x"; }
	else {	$str = $str ."-"; }

	return $str;
}

sub DateFormat
{
	$timestamp = $_[0];
	$strDate = '';
	my @date = localtime($timestamp);
	$strDate = sprintf("%04d-%02d-%02d %02d:%02d:%02d",
		$date[5] + 1900,
		$date[4] + 1,
		$date[3],
		$date[2],
		$date[1],
		$date[0]
	);

	return $strDate;
}


my $longMode = 0;
my $ownerMode = 0;
$path = "";
$cnt = scalar(@ARGV);

if($cnt > 0 && $ARGV[0] ne '-l' && $ARGV[0] ne '-L')
{
	$path = $ARGV[0];
	
}
else
{
	$path = getcwd;
}

foreach $param(@ARGV)
{
	if($param eq "-l")
	{
		$longMode = 1;
	}
	if($param eq "-L")
	{
		$ownerMode = 1;
	}
}

opendir(my $directory, $path) || die "Can't opendir $path: $!";
my @files = readdir($directory);
@files = sort(@files);
foreach $filename(@files)
{
	@stat = stat($filename);
	
	$size = @stat[7];
	$mode = @stat[2];
	$mod_time = @stat[9];

	$UID = @stat[4];
	$is_dir = (S_ISDIR($mode)) ? "d" : "-";
	$user_mode = GenerateRWX(($mode & S_IRWXU) >> 6);
	$group_mode = GenerateRWX(($mode & S_IRGRP) >> 3);
	$other_mode = GenerateRWX(($mode & S_IROTH));
	$dateStr = DateFormat($mod_time);
	$owner = getpwuid($UID);
	
	$stringBuilder = "$filename";

	if($longMode == 1)
	{
		$stringBuilder .= " $size $dateStr $is_dir$user_mode$group_mode$other_mode";
	}

	if($ownerMode == 1)
	{
		$stringBuilder .= " $owner";
	}

	printf($stringBuilder . "\n");
}
closedir($directory);