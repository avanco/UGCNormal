#!/bin/bash

echo "Building tokenizer..."
make --directory=./tokenizer

if [ $? -ne 0 ]
then
    echo; echo "WARNING:"
    echo "If you are using debian-like system, like ubuntu, try to install flex using apt-get"
    exit 255
fi

echo "Checking dependencies..."

perl -e 'use Text::LevenshteinXS'
if [ $? -ne 0 ]
then
    echo; echo "WARNING:"
    echo "You need install this perl CPAN pkg: Text::LevenshteinXS. Try to run:"
    echo -e "\tcpanp -i Text::LevenshteinXS"
    exit 255
fi

perl -e 'use List::MoreUtils'
if [ $? -ne 0 ]
then
    echo; echo "WARNING:"
    echo "You need install this perl CPAN pkg: List::MoreUtils. Try to run:"
    echo -e "\tcpanp -i List::MoreUtils"
    exit 255
fi

perl -e 'use Parallel::Loops'
if [ $? -ne 0 ]
then
    echo; echo "WARNING:"
    echo "You need install this perl CPAN pkg: Parallel::Loops Try to run:"
    echo -e "\tcpanp -i Parallel::Loops"
    exit 255
fi

python -c 'import sklearn'
if [ $? -ne 0 ]
then
    echo "You need install this python module: scikit-learn"
    echo
    echo "Try to run:"
    echo -e "\tsudo apt-get install build-essential python-dev python-setuptools python-numpy python-scipy libatlas-dev libatlas3gf-base"
    echo
    echo -e "\tsudo pip install -U scikit-learn"
    exit 255
fi

python -c 'import multiprocessing'
if [ $? -ne 0 ]
then
    echo "You need install this python module: multiprocessing"
    echo
    echo -e "\tsudo pip install -U multiprocessing"
    exit 255
fi

python -c 'import nltk'
if [ $? -ne 0 ]
then
    echo
    echo "You need install this python module: nltk"
    echo "Try to run:"
    echo
    echo -e "\tsudo pip install -U nltk"
    echo
    echo "YOU MUST DOWNLOAD SOME NLTK DATA !!!"
    echo
    echo "run it in a python interpreter:"
    echo "import nltk"
    echo "nltk.download('stopwords')"
    exit 255
fi

echo
echo "Config. complete !"
echo "You can run UGC normalization system by running:"
echo -e "\t./ugc_norm.sh INPUT_DIR OUTPUT_DIR"
exit 0
