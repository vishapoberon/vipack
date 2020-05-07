
VOC = voc
VERSION_FILE = ./VersionFile.json
BUILDDIR = build
VIPACK = vipack


test: clean create_builds_dir all copy-version-file-to-build-dir run


create_builds_dir:
	mkdir -p $(BUILDDIR)


copy-version-file-to-build-dir:
	cp ./$(VERSION_FILE) ./$(BUILDDIR)/$(VERSION_FILE)

all: http
	cd $(BUILDDIR) && \
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
		../vipack.Mod -m


run:
	$(BUILDDIR)/vipack install


http: clean
	cd $(BUILDDIR) && \
		$(VOC) -s ../vpkTime.Mod \
			../vpkLogger.Mod \
			../vpkTypes.Mod \
			../vpkSockets.Mod \
			../vpkNetdb.Mod \
			../vpkInternet.Mod \
			../vpkHttp.Mod

json:
	cd $(BUILDDIR) && \
		$(VOC) -s \
			../vpkTime.Mod \
			../vpkLogger.Mod \
			../diaspora2hugo/src/lists/Sys.Mod \
			../diaspora2hugo/src/lists/List.Mod \
			../diaspora2hugo/src/lists/strutils.Mod \
			../vpkCharacterStack.Mod \
			../vpkJsonParser.Mod

clean:
	if [ -d "$(BUILDDIR)" ]; then rm -rf $(BUILDDIR); fi


run-http-server:
	cd httpServer && \
	python -m SimpleHTTPServer
