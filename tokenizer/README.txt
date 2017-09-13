
WebTok

***********************************

Author: Lucas Avanço
Date: 02/04/2014
Version: alpha

************************************

WebTok é um tokenizador desenvolvido para textos da Web, embora também possa
ser utilizado para textos de outra natureza.

************************************

- No diretório 'data' há alguns arquivos textos que você pode utilizar para
  testar o tokenizador WebTok.

************************************

- PASSOS PARA UTILIZAR O WebTok:
1. Em um terminal simplesmente rode o comando 'make' para compilar e gerar o
executável:
	$ make

2. O executável gerado espera uma entrada vinda da entrada padrão. Para
tokenizar um arquivo texto, rode assim:
	$ ./webtok < entrada.txt
O resultado é mostrado na saída padrão, no próprio terminal.
Para produzir um arquivo com o resultado da tokenização, faça:
	$ ./webtok < entrada.txt > saida.txt

************************************

Características:
- Desenvolvido utilizando a ferramenta geradora de analisadores léxicos GNU
  Flex 2.5
- Código gerado em C
- Trata espaços extras ou ausentes
- Identifica pontuação
- Não separa multi-words (i.e: 'custo-benefício')
- Não separa valores numéricos (i.e: '1.2', '3,99')
- Identifica Emoticons ( ':)', 'Xp', etc....)
- Independe de encoding do arquivo de entrada (latin1, utf-8, etc...)
- Identifica e separa os seguintes casos comuns em textos de web (512MB, 1024kb, etc...)
- Feito em GNU/Linux e para GNU/Linux, mas deve funcionar sem problemas em
  MS-Windows e MAC-OS :)

************************************

Mais:
Bugs encontrados podem ser reportados para avanco89@gmail.com
Fico muito grato a quem puder reportar os problemas encontrados :)
