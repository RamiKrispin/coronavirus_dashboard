FROM rkrispin/baser4:v4.0.0

LABEL maintainer="Rami Krispin <rami.krispin@gmail.com>"

# installing R packages
RUN mkdir packages
COPY install_packages.R packages/
RUN Rscript packages/install_packages.R

RUN sudo apt-get update && sudo apt-get install pandoc -y

RUN git --version
