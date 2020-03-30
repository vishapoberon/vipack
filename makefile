
VOC = voc
VERSION_FILE = ./VersionFile.json

test: clean create_builds_dir all copy-version-file-to-build-dir run


create_builds_dir:
	mkdir ./builds


copy-version-file-to-build-dir:
	cp ./$(VERSION_FILE) ./builds/$(VERSION_FILE)

all: http
	cd builds && \
	$(VOC) -s \
		../Settings.Mod \
		../time.Mod \
		../logger.Mod \
		../diaspora2hugo/src/lists/Sys.Mod \
		../diaspora2hugo/src/lists/List.Mod \
		../diaspora2hugo/src/lists/strutils.Mod \
		../CharacterStack.Mod \
		../JsonParser.Mod \
		../FileManager.Mod \
		../PackageResolver.Mod \
		../DependencyResolver.Mod \
		../PackageFileParser.Mod \
		../opium.Mod -m


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
			../http.Mod

json:
	cd builds && \
		$(VOC) -s \
			../time.Mod \
			../logger.Mod \
			../diaspora2hugo/src/lists/Sys.Mod \
			../diaspora2hugo/src/lists/List.Mod \
			../diaspora2hugo/src/lists/strutils.Mod \
			../CharacterStack.Mod \
			../JsonParser.Mod

clean:
		rm -r builds & 


run-http-server:
	cd httpServer && \
	python -m SimpleHTTPServer
