.POSIX:
DEPEND = github.com/norayr/lists github.com/norayr/Internet github.com/norayr/opts github.com/norayr/skprLogger github.com/norayr/skprJson

VOC = voc
#mkfile_path = $(abspath $(lastword $(MAKEFILE_LIST)))
#mkfile_dir_path = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
#mkfile_path = $(abspath $(lastword $(MAKEFILE_LIST)))
#mkfile_dir_path = $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

#mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
##mkfile_dir_path := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST)))
#mkfile_dir_path = $(dir $(firstword $(MAKEFILE_LIST)))

#$(info $$mkfile_path is [${mkfile_path}])
#$(info $$mkfile_dir_path is [${mkfile_dir_path}])
mkfile_dir_path = $(shell pwd)
mkfile_path = $(mkfile_dir_path)/Makefile
$(info $(mkfile_path))

BUILD ?= build
build_dir_path = $(mkfile_dir_path)/$(BUILD)
current_dir = $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
BLD = $(mkfile_dir_path)/build
DPD = deps
DPS ?= $(mkfile_dir_path)/$(DPD)

all: get_deps build_deps buildThis

get_deps:
	@for i in $(DEPEND); do \
			if [ -d "$(DPS)/$${i}" ]; then \
				 cd "$(DPS)/$${i}"; \
				 git pull; \
				 cd - ;    \
				 else \
				 mkdir -p "$(DPS)/$${i}"; \
				 cd "$(DPS)/$${i}"; \
				 cd .. ; \
				 git clone "https://$${i}"; \
				 cd - ; \
			fi; \
	done

build_deps:
	mkdir -p $(BUILD)
	cd $(BUILD);
	@for i in $(DEPEND); do \
		#make -f "$(DPS)/$${i}/Makefile" BUILD=$(BUILD); \
		cd $(DPS)/$${i}" && make BUILD=$(BUILD); \
	done

buildThis:
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkSettings.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/unix/vpkLinuxFiles.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/unix/vpkTime.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkLogger.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkHttp.Mod
	cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/vpkHtts.Mod
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
	cd $(BUILD) && $(VOC) $(mkfile_dir_path)/src/vipack.Mod -m

tests:
	#cd $(BUILD) && $(VOC) $(mkfile_dir_path)/test/testList.Mod -m
	#build/testList

clean:
	if [ -d "$(BUILD)" ]; then rm -rf $(BLD); fi

print-%  : ; @echo $* = $($*)
