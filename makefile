
VOC = voc
VERSION_FILE = ./VersionFile.json

test: clean copy-version-file-to-build-dir all run

copy-version-file-to-build-dir:
	cp ./$(VERSION_FILE) ./builds/$(VERSION_FILE)

all:
	cd builds && \
	$(VOC) -s \
		../time.Mod \
		../logger.Mod \
		../diaspora2hugo/src/lists/Sys.Mod \
		../diaspora2hugo/src/lists/List.Mod \
		../CharacterStack.Mod \
		../JsonParser.Mod \
		../FileManager.Mod \
		../PackageFileParser.Mod \
		../opium.Mod -m

clean:
		cd builds && rm * &

run:
	./builds/opium install


http: clean
	cd builds && \
		$(VOC) -s ../time.Mod \
			../logger.Mod \
			../types.Mod \
			../sockets.Mod \
			../netdb.Mod \
			../Internet.Mod \
			../http.Mod -m \
			&& ./http