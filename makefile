
VOC = voc

all:
	cd builds && \
	$(VOC) -s \
		../time.Mod \
		../logger.Mod \
		../diaspora2hugo/src/lists/Sys.Mod \
		../diaspora2hugo/src/lists/List.Mod \
		../CharacterStack.Mod \
		../JsonParser.Mod \
		../PackageFileParser.Mod \
		../opium.Mod -m

clean:
		cd builds && rm * &

run:
	./builds/opium install

test: clean all run
	