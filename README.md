
chat log analyzer
==========================
Intro
------------------------------
A chat log analyzer,log parsed by perl, and analyzed by R. Only QQ supported now.
Useage
-----------------------------
####qq_log_parser.pl
`perl qq_log_parser.pl -input INPUT_FILE -output OUTPUT_FILE`

*qq_log_parser.pl* is a command line tool.It get a input file and parse it to a output file.
The **INPUT_FILE** is a log exported from QQ in format txt.
The **OUTPUT_FILE** is a the file to stored the parsed result.
**OUTPUT_FILE** is a file in format csv that cotains the following columns:
- date
- title
- name
- id
- mesage

*All encodings are UTF8.*

*Only test on windows 7,with perl5.16.3.*

*We used a perl package Text::CSV_XS to manifest csv files,so you should install this package to your perl(e.g. install it from cpan).*
