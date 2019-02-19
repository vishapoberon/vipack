
VOC = /opt/voc/bin/voc

all:
	$(VOC) -s types.Mod sockets.Mod netdb.Mod Internet.Mod stringHelpers.Mod time.Mod IRC.Mod test.Mod -m

http:
	$(VOC) -s types.Mod sockets.Mod netdb.Mod Internet.Mod http.Mod -m

clean:
	rm *.h
	rm *.c
	rm *.o
	rm *.sym

test: http
	./http