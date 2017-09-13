%option noyywrap

%{
/*
Author: Lucas Avanço
Date: 02/04/2014
Version: alpha
*/
%}

%{
#include <string.h>
#define	EMOTICON_SIZE 50
%}

	int punctuation_match = 0;
	int emoticon_match = 0;

digit [0-9]

%{
/*
punctuation [?!.,;@#%:\(\)\[\]{}"']
*/
%}
punctuation [!?.,;@#%:\(\)\[\]{}"']
punctuation_normalize [!?.]

/* a lot of escapes, omg */
/* Here, in emoticon definition, put special cases like: R$ */
emoticon :\)+|:\(+|:o\)+|:\]|:3|:c\)+|:>|=\]|8\)+|=\)+|:\}|:\^\)+|:\-\)+|;\-\)+|:'\-\)+|:'\)+|\\o\/|\\0\/|:\-D|:D|8\-D|8D|x\-D|xD|X\-D|XD|=\-D|=D|=\-3|=3|B\^D|>:\[|:\-\(|:\(|:\-c|:c|:\-<|:<|:\-\[|:\[|:\{|:\-\||:@|:'\-\(|:'\(|D:<|D:|D8|D;|D=|DX|v\.v|D\-':|\(>_<\)|:\||>:O|:\-O|:\-o|:O|°o°|:O|o_O|o_0|o\.O|8\-0|\|\-O|;\-\)+|;\)+|\*\-\)+|\*\)+|;\-\]|;\]|;D|;\^\)+|:\-,|>:P|:\-P|:P|X\-P|x\-p|:\-p|:p|=p|:\-b|:b|:\-&|:&|>:\\|>:\/|:\-\/|:\-\.|:\/|:\\|=\/|=\\|:L|=L|:S|>\.<|:\-\||<:\-\||:\-X|:X|:\-#|:#|O:\-\)+|0:\-3|0:3|0:\-\)+|0:\)+|0;\^\)+|>:\)+|>;\)+|>:\-\)+|\}:\-\)+|\}:\)+|3:\-\)+|3:\)+|o\/\\o|\^5|>_>\^|\^<_<|<3|R$

%{
/*
:o\)
:\]
:3
:c\)
:>
=\]
8\)
=\)
:}
:\^\)
:-\)
;-\)
:'\-\)
:'\)
\\o/
\\0/
:\-D
:D
8\-D
8D
x\-D
xD
X\-D
XD
=\-D
=D
=\-3
=3
B\^D
>:\[
:\-\(
:\(
:\-c
:c
:\-<
:<
:\-\[
:\[
:{
:\-\|
:@
:'\-\(
:'\(
D:<
D:
D8
D;
D=
DX
v\.v
D\-':
\(>_<\)
:\|
>:O
:\-O
:\-o
:O
°o°
:O
o_O
o_0
o\.O
8\-0
\|\-O
;\-\)
;\)
\*\-\)
\*\)
;\-\]
;\]
;D
;\^\)
:\-,
>:P
:\-P
:P
X\-P
x\-p
xp
XP
:\-p
:p
=p
:\-Þ
:Þ
:\-b
:b
:\-&
:&
>:\\
>:/
:\-/
:\-\.
:/
:\\
=/
=\\
:L
=L
:S
>\.<
:\-\|
<:\-\|
:\-X
:X
:\-#
:#
O:\-\)
0:\-3
0:3
0:\-\)
0:\)
0;\^\)
>:\)
>;\)
>:\-\)
}:\-\)
}:\)
3:\-\)
3:\)
o/\\o
\^5
>_>\^
\^<_<
<3
*/
%}

%%

{digit}+[\.,]{digit}+	printf("%s", yytext);

{digit}+[kKmMgGtT][bB]	{
	int i = 0;
	char *tok = yytext;
	for (i=0; isdigit(tok[i]); i++) {
		printf("%c", tok[i]);
	}
	printf(" ");
	printf("%c", tok[i++]);
	printf("%c", tok[i]);
}

[ \t]*\.{2,}[ \t]*	{
	int i = 0;
	char *tok = yytext;
	//printf("<"); printf("%s", tok); printf(">");
	if (punctuation_match || emoticon_match) {
		printf("... ");
	} else {
		printf(" ... ");
	}
	punctuation_match = 1;
}

[\t]*"http"[^ \t,]+	{
	char *tok = yytext;
	printf("%s", tok);
}

[\t]*"ftp"[^ \t,]+	{
	char *tok = yytext;
	printf("%s", tok);
}

[\t]*"www\."[^ \t,]+	{
	char *tok = yytext;
	printf("%s", tok);
}

%{ /* Normalizing punctuation marks, like ! and ? */ %}
%{ /*
[ \t]*!+[ \t]*	{
	int i = 0;
	char *tok = yytext;
	//printf("<"); printf("%s", tok); printf(">");
	if (punctuation_match || emoticon_match) {
		printf("! ", tok);
	} else {
		printf(" ! ", tok);
	}
	punctuation_match = 1;
}

[ \t]*\?+[ \t]*	{
	int i = 0;
	char *tok = yytext;
	//printf("<"); printf("%s", tok); printf(">");
	if (punctuation_match || emoticon_match) {
		printf("? ", tok);
	} else {
		printf(" ? ", tok);
	}
	punctuation_match = 1;
}
*/ %}

%{ /* Insert spaces before/after punctuation if necessary */ %}
[ \t]*{punctuation}[ \t]*	{
	int i = 0;
	char *tok = yytext;
	/* find punctuation in matched text. ps: many spaces before/after */
	for (i=0;
		tok[i] == ' ' ||
		tok[i] == '\t' ||
		tok[i] == '\n';
		i++
	);
	/* if there were spaces on matched text, i-1 holds the index of punctuation mark */
	if (i) {
		if (punctuation_match || emoticon_match) {
			printf("%c ", tok[i]);
		} else {
			printf(" %c ", tok[i]);
		}
	/* no spaces: 'for' get out with i == 0 */
	} else {
		if (punctuation_match || emoticon_match) {
			printf("%c ", tok[0]);
		} else {
			printf(" %c ", tok[0]);
		}
	}
	/* set flag for the next punctuation match */
	punctuation_match = 1;
}

%{ /* Insert spaces before/after emoticons if necessary. DO NOT split emoticons :) */ %}
[ \t]*{emoticon}[ \t]*	{
	int i = 0;
	/* index to manipulate emoticon string */
	int pos = 0;
	char *tok = yytext;
	char emoticon[EMOTICON_SIZE];
	for (i=0;
		tok[i] == ' ' ||
		tok[i] == '\t' ||
		tok[i] == '\n';
		i++
	);
	while (tok[i] != ' ' &&
		tok[i] != '\t' &&
		tok[i] != '\n' &&
		tok[i] != '\0'
	) {
		emoticon[pos++] = tok[i++];
	}
	emoticon[pos] = '\0';
	if (punctuation_match || emoticon_match) {
		printf("%s ", emoticon);
	} else {
		printf(" %s ", emoticon);
	}
	emoticon_match = 1;
}

%{ /* Do nothing (do not print) when many spaces at begining of file */ %}
^[ \t]

%{ /* Substitue many spaces between tokens */ %}
[ \t]+	printf(" ");

.	printf("%s", yytext); punctuation_match = 0; emoticon_match = 0;
%%

int main()
{
    yylex();
}
