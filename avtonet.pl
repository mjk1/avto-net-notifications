#!/usr/bin/perl 
#mulaz

use Data::Dumper;
use LWP::Simple;
use utf8;
use open ':std', ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';
$debug=0;
use MIME::Lite;

open FILE, "<", "last.id" or die $!;
$last=<FILE>;
close FILE;
#print $last;


@ids=gettop100();


foreach(@ids) {
    $id=$_;

    if($id<=$last) {
	next;
    }


#    print "$_ \n";

    eval {%cardata=getcarinfo($id); };
    if($@) {
	print "error $@\n";
	print "oglas http://avto.net/_AVTO/ad.asp?ID=$id \n";
	next;
    }

    
    open FILE, ">", "last.id";
    print FILE $id;
    close FILE;



#daj pogoje sem: (<ID> je anonimiziran)

# $VAR1 = {
#           'ID' => <ID>,
#           'Letnik proizvodnje' => 2008,
#           'Stevilo vrat' => '5 vr.',
#           'Kraj ogleda' => '<a  href="ad.asp?ID=<ID>&show=3" target="_self"><b>Maribor, naslov1</b></a>',
#           'Image1html' => '<img src="http://images.avto.net/<ID>/1.jpg">',
#           'Motor (gorivo)' => 'diesel motor',
#           'Image1' => 'http://images.avto.net/<ID>/1.jpg',
#           'Tehnicni pregled' => '6/2015',
#           'Notranjost' => 'temno siva / blago',
#           'Motor (moc)' => '78 kW        (106 KM)',
#           'URL' => 'http://avto.net/_AVTO/ad.asp?ID=<ID>',
#           'Menjalnik' => 'rocni menjalnik (6 pr.)',
#           'Ohranjenost' => 'odlicno ohranjeno',
#           'Oblika karoserije' => 'kombilimuzina / hatchback',
#           'Starost vozila' => 'rabljeno',
#           'Barva vozila' => 'srebrna metalik',
#           'Motor (prostornina)' => '1461 ccm',
#           'Cena' => 4499,
#           'Ime' => 'Renault Megane 1.5 dCi ',
#           'Prevozeni km' => '158400',
#           'Lokacija' => '02'
#         };



    if($cardata{Ime}=~/alfa romeo/i) {
        print "nocemo alfe, skippaj oglas $i \n";
        next;
    }





    if($cardata{Cena}<5101) {
        if($cardata{'Letnik proizvodnje'}>2006) {
            sendemail(\%cardata,"USER\@gmail.com");
            print Dumper(\%cardata); #debug
        }
    }



   
}






sub getcarinfo {
    my $car1id=shift;

    my $car1url="http://avto.net/_AVTO/ad.asp?ID=$car1id";
    print $car1url ."\n" if $verbose>1;
    my $carhtml=get $car1url;
    print $carhtml if $verbose>2;
    my %cardata;

	print $car1url + "\n" if $debug;
	print $carhtml if $debug;

    $cardata{URL}=$car1url;
    $cardata{ID}=$car1id;


    if($carhtml=~/<div class="OglasPrice">\n*\s*?(.*?)\n*\s*<\/div>/) {
	print "matcha cena $1\n" if $debug;
	$cena=$1;
	chomp $cena;
	$cena=~s/\D//g;

	print "cena: $cena\n" if $debug;
	


	$cardata{Cena}=$cena;
    }
    else {
	die("ni cene");
    }

	if($carhtml=~/<meta name="description" content="(.*):: www.Avto.net ::">/) {
	print "matcha title $1 \n" if $debug;
	$ime=$1;
	$ime=~s/ :: www.Avto.net :://g;
	chomp($ime);

	print "ime: $ime\n" if $debug;
	



        $ime=~s/č/c/g;
        $ime=~s/Č/C/g;
        $ime=~s/Š/S/g;
        $ime=~s/š/s/g;
        $ime=~s/Ž/Z/g;
        $ime=~s/ž/z/g;



	$cardata{Ime}=$ime;





    }

#    $carhtml=~s/\n//g;
    $carhtml=~s/\r//g;
    $carhtml=~s/&nbsp;/ /g;
    while($carhtml=~/<div class="OglasData"[^>]*?>\n\s*<div class="OglasDataLeft">(.+?)<\/div>\n\s*<div class="OglasDataRight">(.+?)<\/div>\n\s*\n?\s*<\/div>/g) {
	print "$1 $2\n" if $debug;
	$cardatakey=$1;
	$cardatavalue=$2;
	$cardatakey=~s/://g;
	$cardatakey=~s/č/c/g;
	$cardatakey=~s/Č/C/g;
	$cardatakey=~s/Š/S/g;
	$cardatakey=~s/š/s/g;
	$cardatakey=~s/Ž/Z/g;
	$cardatakey=~s/ž/z/g;

	$cardatavalue=~s/č/c/g;
	$cardatavalue=~s/Č/C/g;
	$cardatavalue=~s/Š/S/g;
	$cardatavalue=~s/š/s/g;
	$cardatavalue=~s/Ž/Z/g;
	$cardatavalue=~s/ž/z/g;

	$cardata{$cardatakey}=$cardatavalue;
    }

while($carhtml=~/<div class="OglasEQRight"[^>]*?>- \s*(.+?)<\/div>/g) {
	print "$1\n" if $debug;
	$cardatakey=$1;
	$cardatavalue=$1;
	$cardatakey=~s/://g;
	$cardatakey=~s/č/c/g;
	$cardatakey=~s/Č/C/g;
	$cardatakey=~s/Š/S/g;
	$cardatakey=~s/š/s/g;
	$cardatakey=~s/Ž/Z/g;
	$cardatakey=~s/ž/z/g;

	$cardatavalue=~s/č/c/g;
	$cardatavalue=~s/Č/C/g;
	$cardatavalue=~s/Š/S/g;
	$cardatavalue=~s/š/s/g;
	$cardatavalue=~s/Ž/Z/g;
	$cardatavalue=~s/ž/z/g;

	$cardata{$cardatakey}=$cardatavalue;
    }


#lokacija


    print $carhtml if $debug;

    if($carhtml=~/graphics\/slo(..)\.gif/s) {#
	$lokacija=$1;

	print "lokacija $lokacija\n" if $debug;
	


	$cardata{Lokacija}=$lokacija;
   }

    $imgurl="http://images.avto.net/$car1id/1.jpg";

    if($carhtml=~/$imgurl/) {

	$cardata{Image1}=$imgurl;
	$cardata{Image1html}="<img src=\"$imgurl\">";

	print "Ima sliko" if $debug;
    }






    print Dumper(\%cardata) if $debug;

    return %cardata;

}





sub gettop100 {

#print "get top 100\n";    

$top100url="http://www.avto.net/Ads/results_100.asp";
$top100html=get $top100url;


@ids=$top100html=~/Ads\/details\.asp\?id=(\d+)&display=.*\">/g;

@ids=uniq(@ids);
@ids=sort(@ids);
#print Dumper(@ids);


return @ids;


}


sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}


sub sendemail {
    my $cardata=shift;
    my $email = shift;
    my $msg = MIME::Lite->new(
        From    => 'Avto.net tracker <user@server.org>',
	To      => $email,
	Subject => "$cardata{Ime} - $cardata{'Letnik proizvodnje'} letnik - $cardata{Cena} EUR",
	Type    => 'multipart/mixed'
	);	
    
    $msg->attach(
	Type     => 'TEXT',
	Data     => "$cardata{URL}\n\n\n" .Dumper(\%cardata)
	);



#zgenerira screesnhot celega oglasa http://code.google.com/p/wkhtmltopdf/issues/list?q=label:wkhtmltoimage
#ce hoces headless, vzemi binary z linka
#ce ne rabis zakomentiraj
    if ($cardata{ID}=~/^\d+$/) {
	$filename="tmp/".$cardata{ID}.".jpg";
	`wkhtmltoimage --quality 40 $cardata{URL} $filename 2>/dev/null`;

    }
#zakomentiraj do tukaj ce ne rabis    
    
    
    
    $msg->attach(
	Type     => 'image/jpeg',
     	Filename => $id.".1.jpg",
	Data => get($cardata{Image1}),
     	);
    

#attacha se screenshot pagea, ce ne rabis, zakomentiraj
    $msg->attach(
        Type     => 'image/jpeg',
        Filename => $id.".jpg",
	Path => $filename,
        );
#do tukaj




    $msg->send();
    
    


}
