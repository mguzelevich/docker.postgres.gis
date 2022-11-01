FROM postgres:15

LABEL maintainer="mgu"

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.3.1+dfsg-3.pgdg110+1

# pgRouting
ENV PGROUTING_MAJOR 2.5
ENV PGROUTING_VERSION 2.5.2
# H3
ENV H3_VERSION v3.3.0

ENV CXX "g++"
ENV CXXFLAGS "-O3"
ENV CMAKE_VERSION 3.24.3

# ENV PLPYTHON_VERSION 10.6-1.pgdg18.04+1

RUN apt-get update \
  && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
  && apt-get install -y --no-install-recommends \
    # ca-certificates: for accessing remote raster files;
    #   fix: https://github.com/postgis/docker-postgis/issues/307
    ca-certificates

RUN apt-get install -y --no-install-recommends \
  python3 \
  python3-requests \
  python3-numpy \
  python3-pip
RUN pip3 install --upgrade pip setuptools wheel

RUN apt-get install -y --no-install-recommends \
  make gcc g++ libtool git wget libssl-dev

# cmake
# cmake-3.20.0.tar.gz

RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz

RUN tar -zxvf cmake-$CMAKE_VERSION.tar.gz \
  && cd cmake-$CMAKE_VERSION \
  && ./bootstrap \
  && make \
  && make install \
  && cd .. \
  && rm -rf cmake-$CMAKE_VERSION cmake-$CMAKE_VERSION.tar.gz

RUN apt-get install -y --no-install-recommends \
  postgresql-server-dev-$PG_MAJOR \
  postgis=$POSTGIS_VERSION \
  postgresql-$PG_MAJOR-pgrouting \
  postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
  postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
  postgresql-plpython3-$PG_MAJOR \
  postgresql-plpython3-$PG_MAJOR \
  && rm -rf /var/lib/apt/lists/*

# Install H3 C Library
RUN pip install pgxnclient && /usr/local/bin/pgxn install h3

# RUN git clone https://github.com/uber/h3.git h3c \
#    && cd h3c \
#    && git pull origin master --tags \
#    && git checkout "$H3_VERSION" \
#    && cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX:PATH=/usr . \
#    && make install \
#    && cd .. \
#    && rm -rf h3c

# # Install H3 
# RUN git clone https://github.com/dlr-eoc/pgh3.git h3pg \
#    && cd h3pg \
#    && make install \
#    && cd .. \
#    && rm -rf h3pg

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin
RUN mkdir -p /etc/postgresql/15/
COPY ./pg_hba.conf /etc/postgresql/15/pg_hba.conf
