BLD = build
VOC = /opt/voc/bin/voc

all:
		mkdir -p $(BLD)
		cd $(BLD) && $(VOC) -s ../../src/vpkFsHelper.Mod ../testFsHelper.Mod -m

run:
		mkfifo /tmp/fifo
		$(BLD)/testFsHelper
		rm /tmp/fifo


clean:
		rm -rf $(BLD)
