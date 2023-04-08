# builder
FROM alpine:latest as builder

WORKDIR /opt
RUN apk update && \
    apk add --no-cache git git-lfs && \
    rm -rf /var/cache/apk/* && \
    git clone https://huggingface.co/stanfordnlp/corenlp && \
    cd corenlp && \
    rm -rf README.md .gitattributes .git/ && \
    unzip stanford-corenlp-latest.zip && \
    rm stanford-corenlp-latest.zip && \
    mv $(ls -d stanford-corenlp-*/)* ./

# runner
FROM alpine:latest

LABEL org.opencontainers.image.authors="Sultan Achmad <sultanaqmn.gmail.com>"

RUN apk update && \
    apk add --no-cache openjdk8-jre-base && \
    rm -rf /var/cache/apk/*

WORKDIR /opt/corenlp
COPY --from=builder /opt/corenlp .

# default env value
ENV JAVA_XMX 4g
ENV ANNOTATORS tokenize,ssplit,parse
ENV TIMEOUT_MILLISECONDS 15000
ENV PORT 9000

EXPOSE $PORT

CMD java -Xmx$JAVA_XMX -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer -annotators "$ANNOTATORS" -port $PORT -timeout $TIMEOUT_MILLISECONDS