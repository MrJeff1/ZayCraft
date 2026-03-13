LOVE := bin/love.x86_64

RELEASE := release
GAME := ZayCraftLegends
LOVEFILE := $(RELEASE)/ZayCraft Legends.love
BIN := $(RELEASE)/$(GAME)-linux.x86_64

.PHONY: run build-all win macos linux clean dev all

run:
	$(LOVE) .

dev:
	$(LOVE) . --console

win:
	boon build . --target windows
macos:
	boon build . --target macos
linux:
	mkdir -p release
	zip -9 -r "$(LOVEFILE)" . -x "Boon.toml" -x "release/*" -x "bin/*" -x "Makefile" -x ".zed/*" -x ".zed"
	cat $(LOVE) "$(LOVEFILE)" > $(BIN)
	chmod +x $(BIN)

build-all: linux
	boon build . --target all

release: build-all
	cd $(RELEASE) && zip -9 -r "ZayCraft Legends.app.zip" "ZayCraft Legends.app"

clean:
	rm -rf $(RELEASE)

all: clean build-all run
