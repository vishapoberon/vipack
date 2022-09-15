.POSIX:

CFLAGS   =

# The following order is important, do not alphabetise
DEPS     = 	norayr/lists      \
		norayr/Internet   \
     		norayr/opts       \
    		 norayr/time

GITHUB   = https://github.com/

ROOTDIR  = $$PWD

CFLAGS =

all: ${DEPS}
	@if [ ! -d build ]; then \
		mkdir build;     \
	fi
	@for i in $?; do                                  \
		cp -r   ${ROOTDIR}/build                  \
		${ROOTDIR}/deps/$${i#*/}/build;           \
		make -C ${ROOTDIR}/deps/$${i#*/};         \
		cp -r   ${ROOTDIR}/deps/$${i#*/}/build/*  \
		${ROOTDIR}/build/;                        \
	done

	@cd build; voc -s  ${ROOTDIR}/../src/vpkSettings.Mod     \
		${ROOTDIR}/../src/unix/vpkLinuxFiles.Mod         \
		${ROOTDIR}/../src/unix/vpkTime.Mod               \
		${ROOTDIR}/../src/vpkLogger.Mod                  \
		${ROOTDIR}/../src/vpkHttp.Mod                    \
      		${ROOTDIR}/../src/unix/vpkEnv.Mod                \
		${ROOTDIR}/../src/unix/vpkGit.Mod                \
		${ROOTDIR}/../src/vpkCharacterStack.Mod          \
		${ROOTDIR}/../src/vpkJsonParser.Mod              \
		${ROOTDIR}/../src/vpkConf.Mod                    \
		${ROOTDIR}/../src/vpkStorage.Mod                 \
		${ROOTDIR}/../src/vpkSyncer.Mod                  \
		${ROOTDIR}/../src/vpkdepTree.Mod                 \
		${ROOTDIR}/../src/vpkDot.Mod                     \
		${ROOTDIR}/../src/vpkResolver.Mod                \
		${ROOTDIR}/../src/vpkJsonDepRetriever.Mod        \
		${ROOTDIR}/../src/vpkInstaller.Mod               \
		${ROOTDIR}/../src/vipack.Mod -m

${DEPS}:
	@for i in $@; do                                         \
		if [ -d deps/$${i#*/} ]; then                    \
			printf "Updating %s: " $${i#*/};         \
			git -C deps/$${i#*/} pull --ff-only      \
			${GITHUB}$$i > /dev/null 2>&1            \
			&& echo done                             \
			|| (echo failed && exit 1);              \
		else                                             \
			printf "Fetching %s: " $${i#*/};         \
			git clone ${GITHUB}$$i deps/$${i#*/}     \
			> /dev/null 2>&1                         \
			&& echo done                             \
			|| (echo failed && exit 1);              \
		fi                                               \
	done

clean:
	rm -rf build deps

