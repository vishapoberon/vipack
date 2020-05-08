
VOC = voc
VERSION_FILE = ./VersionFile.json
BUILDDIR = build
VIPACK = vipack


test: clean create_build_dir all copy-version-file-to-build-dir run


create_build_dir:
	mkdir -p $(BUILDDIR)


copy-version-file-to-build-dir:
	cp ./$(VERSION_FILE) ./$(BUILDDIR)/$(VERSION_FILE)

all:
	cd $(BUILDDIR) && \
	$(VOC) -s \
		../Internet/src/types.Mod \
		../Internet/src/sockets.Mod \
		../Internet/src/netdb.Mod \
		../Internet/src/Internet.Mod \
		../src/vpkSettings.Mod \
		../src/unix/vpkFiles.Mod \
		../src/unix/vpkTime.Mod \
		../src/vpkLogger.Mod \
		../src/vpkHttp.Mod \
		../src/unix/vpkEnv.Mod \
		../src/unix/vpkGit.Mod \
		../lists/src/Sys.Mod \
		../lists/src/List.Mod \
		../lists/src/strutils.Mod \
		../src/vpkCharacterStack.Mod \
		../src/vpkJsonParser.Mod \
	  ../src/vpkConf.Mod \
		../src/vpkFileManager.Mod \
	  ../src/vpkSyncer.Mod \
		../src/vpkPackageResolver.Mod \
		../src/vpkDependencyResolver.Mod \
		../src/vpkPackageFileParser.Mod \
		../src/vipack.Mod -m


run:
	$(BUILDDIR)/vipack install

clean:
	if [ -d "$(BUILDDIR)" ]; then rm -rf $(BUILDDIR); fi


run-http-server:
	cd httpServer && \
	python -m SimpleHTTPServer
