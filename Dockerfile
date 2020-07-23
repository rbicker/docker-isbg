FROM python:slim-buster
LABEL maintainer="Raphael Bicker"
ENV TRACKFILE="track"
# RUN useradd -m -u 10001 -s /bin/false appuser
RUN apt-get update && apt-get install -y \
    procps \
    spamassassin \
 && rm -rf /var/lib/apt/lists/*
RUN pip install isbg
COPY ./entrypoint.sh /entrypoint.sh
# USER appuser
CMD /entrypoint.sh