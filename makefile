
VOC = voc
VERSION_FILE = ./VersionFile.json
BUILDDIR = build
VIPACK = vipack


test: clean create_build_dir all copy-version-file-to-build-dir run


create_build_dir:
	mkdir -p $(BUILDDIR)


copy-version-file-to-build-dir:
	cp ./$(VERSION_FILE) ./$(BUILDDIR)/$(VERSION_FILE)

all: http
	cd $(BUILDDIR) && \
	$(VOC) -s \
		../src/vpkGit.Mod \
		../src/vpkFsHelper.Mod \
		../src/vpkSettings.Mod \
		../src/vpkConf.Mod \
		../src/vpkFileManager.Mod \
		../lists/src/Sys.Mod \
		../lists/src/List.Mod \
		../lists/src/strutils.Mod \
	  ../src/vpkCharacterStack.Mod \
		../src/vpkJsonParser.Mod \
	  ../src/vpkSyncer.Mod \
		../src/vpkUserDetails.Mod \
		../src/vpkTime.Mod \
		../src/vpkLogger.Mod \
		../src/vpkPackageResolver.Mod \
		../src/vpkDependencyResolver.Mod \
		../src/vpkPackageFileParser.Mod \
		../src/vipack.Mod -m


run:
	$(BUILDDIR)/vipack install


http: clean
	cd $(BUILDDIR) && \
		$(VOC) -s ../src/vpkTime.Mod \
			../src/vpkLogger.Mod \
			../Internet/src/types.Mod \
			../Internet/src/sockets.Mod \
			../Internet/src/netdb.Mod \
			../Internet/src/Internet.Mod \
			../src/vpkHttp.Mod

clean:
	if [ -d "$(BUILDDIR)" ]; then rm -rf $(BUILDDIR); fi


run-http-server:
	cd httpServer && \
	python -m SimpleHTTPServer
