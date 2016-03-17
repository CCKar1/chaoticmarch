GCC_BIN=`xcrun --sdk iphoneos --find clang`
GCC=$(GCC_BASE) -arch arm64 -arch armv7 -arch armv7s
SDK=`xcrun --sdk iphoneos --show-sdk-path`

CFLAGS = -Iincludes/ -Llibs/ -llua -lpthread -lsimulatekeyboard -lsimulatetouch -lobjc -lstdc++ -framework Foundation -framework UIKit -framework CoreGraphics
GCC_BASE = $(GCC_BIN) -Os $(CFLAGS) -isysroot $(SDK) -F$(SDK)/System/Library/Frameworks -F$(SDK)/System/Library/PrivateFrameworks

all: libchaoticmarch

libchaoticmarch: lua_support.mm logging.m ui-kit.m cycrypt_helper.m
	$(GCC) -shared -o $@.dylib $^
	ldid -Sent.xml $@.dylib

clean:
	rm -f *.o libchaoticmarch.dylib
