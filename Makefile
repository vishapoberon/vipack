
VOC = /opt/voc/bin/voc

all:
	$(VOC) -s types.Mod sockets.Mod netdb.Mod Internet.Mod IRC.Mod test.Mod -m

clean:
	rm *.h
	rm *.c
	rm *.o
	rm *.sym
