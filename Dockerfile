# Build and run with docker_run.sh
# e.g., ./docker_run.sh -q example.com
#
# Thank you to Ilya Glotov (https://github.com/andripwn) for help with
# this minimal alpine image

FROM python:3-alpine

ENV SSDEEP_VERSION="release-2.14.1" \
    BUILD_DEPS="build-base \
                automake \
                autoconf \
                libtool"

ADD requirements.txt .
RUN apk --update --no-cache add $BUILD_DEPS \
                                git \
                                libffi-dev \
    && git clone --depth=1 --branch=$SSDEEP_VERSION https://github.com/ssdeep-project/ssdeep.git \
    && cd ssdeep \
    && autoreconf -i \
    && ./configure \
    && make \
    && make install \
    && cd / \
    && rm -rf /ssdeep \
    \
    && pip3 install -r requirements.txt \
    \
    && apk del $BUILD_DEPS \
    \
    && adduser -D pwngit

VOLUME ["/pwngit/logs", "/pwngit/states"]

WORKDIR /pwngit
USER pwngit

ADD checks /pwngit/checks
ADD pwngit.py .
ENTRYPOINT ["python3", "pwngit.py"]
CMD [ "-h" ]
