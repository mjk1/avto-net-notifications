avto-net-notifications
======================

Sends emails when chosen car appears on avto.net 

Beta, verjetno v nasprotju z TOS-om, ne odgovarjam, ce skripta kaj unici, bla bla bla, standard

Koda je zelo slampasto skucana, precej na hitro, ne preverjam skoraj nobenega faila, ker itak ni bilo misljeno za produkcijo. 

======================

Skripta pogleda zadnjih sto oglasov na avto.net, in loopa cez vsakega. zadnji ogledan oglas (ID) shrani v last.id, tako da oglasov ne pregleduje veckrat (IDji grejo sekvencno, autoincrement pri oglasih).


Iz vsakega oglasa pobere del podatkov, in shrani v hash. Primer:

# $VAR1 = {
#           'ID' => <ID>,
#           'Letnik' => 2008,
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



Na oznacenem mestu v kodi, dodas poljubne pogoje s temi podatki, in ce matcha poslje mail na poljuben naslov (ps: popravi naslov iz USER@gmail.com na nekaj svojega). Uporabljam se http://code.google.com/p/wkhtmltopdf/issues/list?q=label:wkhtmltoimage za generiranje screenshota pagea. Ce noces, zakomentiraj tistih par vrstic, kjer generiram image, in pri posiljanju maila tist blok, kjer attacham sliko zraven. 