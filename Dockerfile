FROM perl:latest

ENV WORKDIR /usr/src/app
ENV PERL5LIB ${WORKDIR}/lib
ENV TODO_APP_ROOT ${WORKDIR}
ENV DANCER_PORT 3000

WORKDIR ${WORKDIR}

RUN wget --quiet -O /usr/bin/wait-for-it https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
    &&  chmod 755 /usr/bin/wait-for-it

## installs tools, libraries and bootstraps Perl CPAN packages
RUN apt-get -qq update -y \
    &&  apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        libgd-dev \
        carton \
        libdbd-sqlite3-perl \
        libtool \
        libevent-dev \
        make \
        patch \
    &&  rm -rf /var/lib/{apt,dpkg,cache,log}/ /usr/share/doc/

RUN wget --quiet -O /usr/bin/cpm https://git.io/cpm \
    &&  chmod 755 /usr/bin/cpm

RUN cpm install --no-show-progress --workers=10 --retry --global Module::Install CPAN::Meta::Prereqs Carton::Snapshot \
    &&  rm -rf ~/.perl-cpm

## minimum we need to install CPAN packages deps, so that we can cache them
COPY cpanfile cpanfile.snapshot ${WORKDIR}/

## cleans up apt cache & log files
RUN cpm install --with-develop --no-show-progress --workers=10 --retry --global \
    &&  rm -rf ~/.perl-cpm \
    &&  find /usr -name '*.pod' -delete

## copies app files as the last step so that every step above is cached
COPY . ${WORKDIR}

RUN ["prove", "-rv", "t/"]

EXPOSE ${DANCER_PORT}

CMD ["bin/cmd-www.sh"]