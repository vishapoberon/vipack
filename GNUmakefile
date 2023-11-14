VOC = /opt/voc/bin/voc
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir_path := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ifndef BUILD
BUILD="build"
endif
build_dir_path := $(mkfile_dir_path)/$(BUILD)
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
BLD := $(mkfile_dir_path)/build
DPD  =  deps
ifndef DPS
DPS := $(mkfile_dir_path)/$(DPD)
endif
all: get_deps build_deps buildThis

get_deps:
	mkdir -p $(DPS)
	if [ -d $(DPS)/lists ]; then cd $(DPS)/lists; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/lists; cd -; fi
	if [ -d $(DPS)/Internet ]; then cd $(DPS)/Internet; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/Internet; cd -; fi
	if [ -d $(DPS)/opts ]; then cd $(DPS)/opts; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/opts; cd -; fi
	if [ -d $(DPS)/skprLogger ]; then cd $(DPS)/skprLogger; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/skprLogger; cd -; fi
	if [ -d $(DPS)/skprJson ]; then cd $(DPS)/skprJson; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/skprJson; cd -; fi

build_deps:
	mkdir -p $(BUILD)
	cd $(BUILD)
	make -f $(DPS)/lists/GNUmakefile BUILD=$(BUILD)
	make -f $(DPS)/Internet/GNUmakefile BUILD=$(BUILD)
	make -f $(DPS)/opts/GNUmakefile BUILD=$(BUILD)
	make -f $(DPS)/skprLogger/GNUmakefile BUILD=$(BUILD)
	make -f $(DPS)/skprJson/GNUmakefile BUILD=$(BUILD)

buildThis:
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vkpSettings.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/unix/vpkLinuxFiles.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/unix/vpkTime.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkLogger.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkHttp.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/unix/vpkEnv.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/unix/vpkGit.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkCharacterStack.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkJsonParser.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkConf.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkStorage.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkSyncer.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkdepTree.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkDot.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkResolver.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkJsonDepRetriever.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkInstaller.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vipack.Mod

tests:
	#cd $(BUILD) && $(VOC) $(mkfile_dir_path)/test/testList.Mod -m
	#build/testList

clean:
	if [ -d "$(BUILD)" ]; then rm -rf $(BLD); fi
