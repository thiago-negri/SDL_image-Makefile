SDL_MAJOR := 3
SDL_MINOR := 2
SDL_PATCH := 4
SHA256 := a725bd6d04261fdda0dd8d950659e1dc15a8065d025275ef460d32ae7dcfc182
SDL3_DIR := ../SDL-Makefile/SDL3-3.2.22/install/lib/cmake/SDL3

CMAKE := cmake
TAR := tar
CURL := curl
SHA256SUM := sha256sum

ifeq (, $(shell $(CMAKE) --version 2>/dev/null))
$(error "Need 'cmake' to build SDL")
endif

ifeq (, $(shell $(TAR) --version 2>/dev/null))
$(error "Need 'tar' to build SDL")
endif

ifeq (, $(shell $(CURL) --version 2>/dev/null))
$(error "Need 'curl' to build SDL")
endif

ifeq (, $(shell $(SHA256SUM) --version 2>/dev/null))
$(error "Need 'sha256sum' to build SDL")
endif

SDL_IMAGE_VERSION := $(SDL_MAJOR).$(SDL_MINOR).$(SDL_PATCH)
SDL_IMAGE_FULLNAME := SDL$(SDL_MAJOR)_image-$(SDL_IMAGE_VERSION)
PACKAGE_FILENAME := $(SDL_IMAGE_FULLNAME).tar.gz
URL := https://github.com/libsdl-org/SDL_image/releases/download/release-$(SDL_IMAGE_VERSION)/$(PACKAGE_FILENAME)
SDL_IMAGE_FOLDER := $(SDL_IMAGE_FULLNAME)
SDL_IMAGE_CMAKELISTS := $(SDL_IMAGE_FOLDER)/CMakeLists.txt
SDL_IMAGE_BUILD_FOLDER := $(SDL_IMAGE_FOLDER)/build
SDL_IMAGE_MAKEFILE := $(SDL_IMAGE_BUILD_FOLDER)/Makefile
SDL_IMAGE_SHARED := $(SDL_IMAGE_BUILD_FOLDER)/libSDL$(SDL_MAJOR).so
INSTALL_FOLDER := $(SDL_IMAGE_FOLDER)/install
SDL_IMAGE_SHARED_INSTALL := $(INSTALL_FOLDER)/lib/libSDL$(SDL_MAJOR).so

.PHONY: all
all: $(SDL_IMAGE_SHARED_INSTALL)

.PHONY: clean
clean:
	rm -rf $(SDL_IMAGE_FOLDER) $(INSTALL_FOLDER)
	rm -f $(PACKAGE_FILENAME)

$(INSTALL_FOLDER):
	mkdir -p $@

$(SDL_IMAGE_SHARED_INSTALL): $(SDL_IMAGE_SHARED) | $(INSTALL_FOLDER)
	$(CMAKE) --install $(SDL_IMAGE_BUILD_FOLDER) --prefix $(INSTALL_FOLDER)

$(SDL_IMAGE_SHARED): $(SDL_IMAGE_MAKEFILE)
	$(CMAKE) --build $(SDL_IMAGE_BUILD_FOLDER) --parallel

$(SDL_IMAGE_MAKEFILE): $(SDL_IMAGE_CMAKELISTS)
	$(CMAKE) -DSDL3_DIR=../$(SDL3_DIR) -S $(SDL_IMAGE_FOLDER) -B $(SDL_IMAGE_BUILD_FOLDER)

$(SDL_IMAGE_CMAKELISTS):
	$(CURL) -fsLo $(PACKAGE_FILENAME) $(URL)
	echo "$(SHA256)  $(PACKAGE_FILENAME)" | $(SHA256SUM) -c
	$(TAR) xzf $(PACKAGE_FILENAME)
	rm -f $(PACKAGE_FILENAME)
