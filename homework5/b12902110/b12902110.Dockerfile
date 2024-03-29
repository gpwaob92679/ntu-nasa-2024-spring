FROM alpine:latest
RUN apk update && apk add build-base git ncurses-dev
RUN git clone https://github.com/mtoyoda/sl.git
WORKDIR /sl
RUN make
CMD [ "/sl/sl" ]
