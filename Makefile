ARCHS = arm64 arm64e

DEBUG=0
FINALPACKAGE=1

export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/

TARGET = iphone:latest:13.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = XPad

XPad_FILES = $(wildcard *.xm) $(wildcard *.x) $(wildcard *.m)
XPad_CFLAGS = -fobjc-arc
XPad_LIBRARIES = rocketbootstrap sparkcolourpicker
XPad_PRIVATE_FRAMEWORKS = AppSupport Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += xpadprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
