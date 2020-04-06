
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
		../vpkGit.Mod \
		../vpkFsHelper.Mod \
		../vpkConf.Mod \
		../vpkUserDetails.Mod \
		../vpkSettings.Mod \
		../vpkTime.Mod \
		../vpkLogger.Mod \
		../diaspora2hugo/src/lists/Sys.Mod \
		../diaspora2hugo/src/lists/List.Mod \
		../diaspora2hugo/src/lists/strutils.Mod \
		../vpkCharacterStack.Mod \
		../vpkJsonParser.Mod \
		../vpkFileManager.Mod \
		../vpkPackageResolver.Mod \
		../vpkDependencyResolver.Mod \
		../vpkPackageFileParser.Mod \
		../Vipack.Mod -m


run:
	./builds/Vipack install


http: clean
	cd builds && \
		$(VOC) -s ../vpkTime.Mod \
			../vpkLogger.Mod \
			../vpkTypes.Mod \
			../vpkSockets.Mod \
			../vpkNetdb.Mod \
			../vpkInternet.Mod \
			../vpkHttp.Mod

json:
	cd builds && \
		$(VOC) -s \
			../vpkTime.Mod \
			../vpkLogger.Mod \
			../diaspora2hugo/src/lists/Sys.Mod \
			../diaspora2hugo/src/lists/List.Mod \
			../diaspora2hugo/src/lists/strutils.Mod \
			../vpkCharacterStack.Mod \
			../vpkJsonParser.Mod

clean:
		rm -r builds & 


run-http-server:
	cd httpServer && \
	python -m SimpleHTTPServer
