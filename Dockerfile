FROM ubuntu:18.04

RUN apt update

RUN apt install -y wget python libnss3 libfontconfig1 libx11-6 libgl1-mesa-glx gcc git golang

RUN wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin

ADD . /go/src/github.com/lifei6671/mindoc

WORKDIR /go/src/github.com/lifei6671/mindoc

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

RUN	 go get -u github.com/golang/dep/cmd/dep && dep ensure  && \
	CGO_ENABLE=1 go build -v -a -o mindoc_linux_amd64 -ldflags="-w -s -X main.VERSION=$TAG -X 'main.BUILD_TIME=`date`' -X 'main.GO_VERSION=`go version`'" && \
    rm -rf commands controllers models modules routers tasks vendor docs search data utils graphics .git Godeps uploads/* .gitignore .travis.yml Dockerfile gide.yaml LICENSE main.go README.md conf/enumerate.go conf/mail.go install.lock simsun.ttc

ADD start.sh /go/src/github.com/lifei6671/mindoc
ADD simsun.ttc /usr/share/fonts/win/

RUN cp -r /go/src/github.com/lifei6671/mindoc /mindoc

WORKDIR /mindoc

RUN chmod +x start.sh

RUN groupadd -r mindoc && useradd -r -g mindoc mindoc
RUN chown -R mindoc:mindoc /mindoc
USER mindoc

CMD ["./start.sh"]