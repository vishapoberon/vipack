
VOC = /opt/voc/bin/voc

all:
	$(VOC) -s types.Mod sockets.Mod netdb.Mod irc.Mod test.Mod -m

clean:
	rm *.h
	rm *.c
	rm *.o
	rm *.sym
