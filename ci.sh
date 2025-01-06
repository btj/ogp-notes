pushd ..

git clone https://github.com/btj/jlearner
export JLEARNERPATH=`pwd`/jlearner

curl --remote-name https://www.tug.org/fonts/getnonfreefonts/install-getnonfreefonts
texlua install-getnonfreefonts
export PATH=/usr/local/texlive/2024/bin/x86_64-linux:$PATH
getnonfreefonts --sys luximono

apt-get update
apt-get install -y pandoc

popd

. ./make-pdf.sh
