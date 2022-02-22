mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir_path := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
build_dir_path := $(mkfile_dir_path)/build
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
BLD := $(mkfile_dir_path)/build

VOC = voc
VERSION_FILE = ./VersionFile.json
BLD = build
DPS = dps
VIPACK = vipack


all: fetch_deps
	#git submodule init
	#git submodule update
	mkdir -p $(build_dir_path)
	cd $(build_dir_path)
	make -f $(mkfile_dir_path)/dps/lists/makefile BUILD=$(build_dir_path)
	make -f $(mkfile_dir_path)/dps/Internet/makefile BUILD=$(build_dir_path)
	make -f $(mkfile_dir_path)/dps/time/makefile BUILD=$(build_dir_path)
	make -f $(mkfile_dir_path)/dps/opts/makefile BUILD=$(build_dir_path)
	cd $(build_dir_path) && \
	$(VOC) -s \
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
		../src/vpkDot.Mod \
		../src/vpkResolver.Mod \
		../src/vpkJsonDepRetriever.Mod \
		../src/vpkInstaller.Mod \
		../src/vipack.Mod -m

fetch_deps:
		mkdir -p $(DPS)
		cd $(DPS) && git clone https://github.com/norayr/Internet
		cd $(DPS) && git clone https://github.com/norayr/lists
		cd $(DPS) && git clone https://github.com/norayr/opts
		cd $(DPS) && git clone https://github.com/norayr/time

tests:
			mkdir -p $(BLD)
			cd $(BLD) && $(VOC) -s ../src/unix/vpkFiles.Mod ../tst/testFiles.Mod -m
			cd $(BLD) && $(VOC) -s ../src/vpkJsonParser.Mod ../tst/testJsonParser.Mod -m
			mkfifo /tmp/fifo
			$(BLD)/testFiles
			rm /tmp/fifo
			$(BLD)/testJsonParser

clean:
	if [ -d "$(BLD)" ]; then rm -rf $(BLD); fi
