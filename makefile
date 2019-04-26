
VOC = voc

all:
	cd builds && \
	$(VOC) -s \
		../time.Mod \
		../logger.Mod \
		../diaspora2hugo/src/lists/Sys.Mod \
		../diaspora2hugo/src/lists/List.Mod \
		../CharacterStack.Mod \
		../HashMapString.Mod -m

clean:
		cd builds && rm * &

run:
	./builds/HashMap

test: clean all run
	