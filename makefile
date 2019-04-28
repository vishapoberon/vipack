
VOC = voc

all:
	cd builds && \
	$(VOC) -s \
		../time.Mod \
		../logger.Mod \
		../diaspora2hugo/src/lists/Sys.Mod \
		../diaspora2hugo/src/lists/List.Mod \
		../CharacterStack.Mod \
		../JsonParser.Mod -m

clean:
		cd builds && rm * &

run:
	./builds/JsonParser

test: clean all run
	