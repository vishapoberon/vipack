VOC = /opt/voc/bin/voc
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir_path := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
build_dir_path := $(mkfile_dir_path)/build
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
BLD := $(mkfile_dir_path)/build
DPS := $(mkfile_dir_path)/dps

all: get_deps build_deps vipack
#Internet  lists  opts  skprJson  skprLogger  time
get_deps:
		mkdir -p $(DPS)
		if [ -d $(DPS)/lists ]; then cd $(DPS)/lists; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/lists; cd -; fi
		if [ -d $(DPS)/Internet ]; then cd $(DPS)/Internet; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/Internet; cd -; fi
		if [ -d $(DPS)/time ]; then cd $(DPS)/time; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/time; cd -; fi
		if [ -d $(DPS)/opts ]; then cd $(DPS)/opts; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/opts; cd -; fi
		if [ -d $(DPS)/skprLogger ]; then cd $(DPS)/skprLogger; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/skprLogger; cd -; fi
		if [ -d $(DPS)/skprJson ]; then cd $(DPS)/skprJson; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/skprJson; cd -; fi

build_deps:
	mkdir -p $(BLD)
	cd $(CURDIR)/$(BUILD)
	make -f $(DPS)/lists/GNUmakefile BUILD=$(BLD)
	make -f $(DPS)/Internet/GNUmakefile BUILD=$(BLD)
	make -f $(DPS)/time/GNUmakefile BUILD=$(BLD)
	make -f $(DPS)/opts/GNUmakefile BUILD=$(BLD)
	make -f $(DPS)/skprLogger/GNUmakefile BUILD=$(BLD)
	make -f $(DPS)/skprJson/GNUmakefile BUILD=$(BLD)

vipack:
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkSettings.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/unix/vpkLinuxFiles.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/unix/vpkTime.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkLogger.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkHttp.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/unix/vpkEnv.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/unix/vpkGit.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkCharacterStack.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkJsonParser.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkConf.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkStorage.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkSyncer.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkdepTree.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkDot.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkResolver.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkJsonDepRetriever.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vpkInstaller.Mod
	cd $(BLD) && $(VOC) $(mkfile_dir_path)/src/vipack.Mod -m


clean:
			if [ -d "$(BLD)" ]; then rm -rf $(BLD); fi
