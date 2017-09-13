#!/bin/bash

if [ $# != 2 ]
then
	echo 'Passar o diretorio de entrada com txt para normalizar e o diretorio de saida'
	exit 255
fi

# Configuracao
TOKENIZER=$PWD/tokenizer/webtok
SPELLER_DIR=$PWD/speller
SPELLER_ARGS=
INPUT_DIR=$1
OUTPUT_DIR=$2
export PERL5LIB=$SPELLER_DIR
export PYTHONPATH=$SPELLER_DIR

# get absolute path of input and output dirs
INPUT_DIR=`readlink -f $INPUT_DIR`
OUTPUT_DIR=`readlink -f $OUTPUT_DIR`

# Processamento
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

# tokenizador
##################################################
echo
echo "###"
echo
echo "Aplicando tokenizador em $INPUT_DIR/"
rm -rf $OUTPUT_DIR/tok
mkdir $OUTPUT_DIR/tok
for f in `find $INPUT_DIR/ -name "*.txt"`
do
	$TOKENIZER < $f > $OUTPUT_DIR/tok/`basename $f`
done

# speller
##################################################
echo
echo "###"
echo
echo "Aplicando speller em $OUTPUT_DIR/tok"
rm -rf $OUTPUT_DIR/tok/checked
mkdir $OUTPUT_DIR/tok/checked
perl $SPELLER_DIR/spell.pl -stat $SPELLER_DIR/lexicos/regra+cb_freq.txt -d $OUTPUT_DIR/tok


# normalizador de siglas
##################################################
echo
echo "###"
echo
echo "Normalizando siglas em $OUTPUT_DIR/tok/checked/"
rm -rf $OUTPUT_DIR/tok/checked/siglas
mkdir $OUTPUT_DIR/tok/checked/siglas
for f in `find $OUTPUT_DIR/tok/checked -type f`
do
    perl ./siglas_map.pl ./resources/lexico_siglas.txt $f > $OUTPUT_DIR/tok/checked/siglas/`basename $f`
done


# normalizador de Internetes
##################################################
echo
echo "###"
echo
echo "Normalizando internetes em $OUTPUT_DIR/tok/checked/siglas"
rm -rf $OUTPUT_DIR/tok/checked/siglas/internetes
mkdir $OUTPUT_DIR/tok/checked/siglas/internetes
for f in `find $OUTPUT_DIR/tok/checked/siglas -type f`
do
    perl ./internetes_map.pl ./resources/lexico_internetes.txt ./resources/lexico_internetes_sigl_abrv.txt $f > $OUTPUT_DIR/tok/checked/siglas/internetes/`basename $f`
done

# normalizador de Nome Proprio
##################################################
echo
echo "###"
echo
echo "Normalizando nomes proprios em $OUTPUT_DIR/tok/checked/siglas/internetes"
rm -rf $OUTPUT_DIR/tok/checked/siglas/internetes/nomes
mkdir $OUTPUT_DIR/tok/checked/siglas/internetes/nomes
for f in `find $OUTPUT_DIR/tok/checked/siglas/internetes -type f`
do
    perl ./np_map.pl ./resources/lexico_nome_proprio.txt $f > $OUTPUT_DIR/tok/checked/siglas/internetes/nomes/`basename $f`
done

# caixa alta para palavras precedidas por ponto final
##################################################
for f in `find $OUTPUT_DIR/tok/checked/siglas/internetes/nomes -type f`
do
	python ./upper_periods.py $f
done

IFS=$SAVEIFS
