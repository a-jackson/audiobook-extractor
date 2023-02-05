FROM ubuntu:latest

ENV AUDIBLE_CONFIG_DIR="/config"
ENV AUDIBLE_DEST="/dest"
ENV AUDIBLE_COMPLETE="/complete"
ENV TEMP_DOWNLOAD="/tmp/audible"

VOLUME /dest /complete /config /tmp/audible

RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        mediainfo \
        ffmpeg \
        x264 \
        x265 \
        bc \
        jq

COPY AAXtoMP3 /aaxtomp3

RUN pip install audible-cli

ADD entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "download" ]
