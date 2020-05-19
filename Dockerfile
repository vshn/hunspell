# 1. Builder image
FROM ubuntu:20.04 AS builder

# Clone latest dictionaries
WORKDIR /root
RUN apt-get update && apt-get install -y git
RUN git clone --depth 1 -o 5ede45bb705d3f9f525ea779f7b487f9fc062013 https://github.com/wooorm/dictionaries.git

# 2. Runtime image
FROM alpine:3.11

WORKDIR /spell
RUN apk add --no-cache hunspell

# Copy only required dictionaries
RUN sh -c 'mkdir -pv /usr/share/hunspell'
COPY --from=builder /root/dictionaries/dictionaries/en/index.aff /usr/share/hunspell/en.aff
COPY --from=builder /root/dictionaries/dictionaries/en/index.dic /usr/share/hunspell/en.dic
COPY --from=builder /root/dictionaries/dictionaries/de-CH/index.aff /usr/share/hunspell/de.aff
COPY --from=builder /root/dictionaries/dictionaries/de-CH/index.dic /usr/share/hunspell/de.dic
COPY --from=builder /root/dictionaries/dictionaries/fr/index.aff /usr/share/hunspell/fr.aff
COPY --from=builder /root/dictionaries/dictionaries/fr/index.dic /usr/share/hunspell/fr.dic

# Copy exclusion file as custom "vshn" dictionary as explained here:
# https://www.suares.com/?page_id=25&news_id=233
COPY hunspell_exclude .
RUN wc -l hunspell_exclude > /usr/share/hunspell/vshn.dic
RUN sort hunspell_exclude | uniq >> /usr/share/hunspell/vshn.dic
RUN touch /usr/share/hunspell/vshn.aff

# Check version and available dictionaries
RUN hunspell -v && hunspell -D

ENTRYPOINT ["/usr/bin/hunspell"]

