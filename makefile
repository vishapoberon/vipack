
VOC = voc
VERSION_FILE = ./VersionFile.json
BUILDDIR = build
VIPACK = vipack

all:
	mkdir -p $(BUILDDIR)
	#later like this:
	#cd Internet && make
	#cd lists && make
	cd $(BUILDDIR) && \
	$(VOC) -s \
		../Internet/src/netTypes.Mod \
		../Internet/src/netdb.Mod \
		../Internet/src/netSockets.Mod \
		../Internet/src/Internet.Mod \
		../lists/src/lDefs.Mod \
		../lists/src/strutils.Mod \
		../lists/src/List.Mod \
		../lists/src/StringList.Mod \
		../src/vpkSettings.Mod \
		../src/unix/vpkFiles.Mod \
		../src/unix/vpkTime.Mod \
		../src/vpkLogger.Mod \
		../src/vpkHttp.Mod \
		../src/unix/vpkEnv.Mod \
		../src/unix/vpkGit.Mod \
		../src/vpkCharacterStack.Mod \
		../src/vpkJsonParser.Mod \
	  ../src/vpkConf.Mod \
		../src/vpkStorage.Mod \
	  ../src/vpkSyncer.Mod \
		../src/vpkdepTree.Mod \
		../src/vpkJsonDepRetriever.Mod \
		../src/vpkDot.Mod \
		../src/vpkResolver.Mod \
		../src/vpkInstaller.Mod \
		../src/vipack.Mod -m

tests:
			mkdir -p $(BUILDDIR)
			cd $(BUILDDIR) && $(VOC) -s ../src/unix/vpkFiles.Mod ../tst/testFiles.Mod -m
			cd $(BUILDDIR) && $(VOC) -s ../src/vpkJsonParser.Mod ../tst/testJsonParser.Mod -m
			mkfifo /tmp/fifo
			$(BUILDDIR)/testFiles
			rm /tmp/fifo
			$(BUILDDIR)/testJsonParser

clean:
	if [ -d "$(BUILDDIR)" ]; then rm -rf $(BUILDDIR); fi
