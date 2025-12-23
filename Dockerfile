FROM golang:1.25.5-alpine3.23 as builder

ENV GITHUB_ORG otm
ENV PROJECT_NAME cloudwatch-alarm-exporter
ENV BUILD_ORG Quiq
ENV BUILD_TAG master

RUN apk update && \
    apk add ca-certificates git bash gcc musl-dev && \
    git config --global http.https://gopkg.in.followRedirects true && \
    git clone --depth 1 --branch $BUILD_TAG https://github.com/$BUILD_ORG/$PROJECT_NAME.git $GOPATH/src/github.com/$GITHUB_ORG/$PROJECT_NAME && \
    cd $GOPATH/src/github.com/$GITHUB_ORG/$PROJECT_NAME && \
    go build -mod=readonly -o /opt/$PROJECT_NAME github.com/$GITHUB_ORG/$PROJECT_NAME

FROM alpine:3.23

RUN apk upgrade --no-cache && apk add --no-cache --upgrade ca-certificates
COPY --from=builder /opt/cloudwatch-alarm-exporter /opt/

USER nobody
ENTRYPOINT ["/opt/cloudwatch-alarm-exporter"]
