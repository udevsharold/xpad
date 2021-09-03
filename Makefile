export ARCHS = arm64 arm64e

export DEBUG = 1
export FINALPACKAGE = 0

export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/

TARGET = iphone:latest:13.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = XPad

XPad_FILES = $(wildcard *.xm) $(wildcard *.x) $(wildcard *.m)
XPad_CFLAGS = -fobjc-arc
XPad_LIBRARIES = rocketbootstrap sparkcolourpicker
XPad_PRIVATE_FRAMEWORKS = AppSupport Preferences
XPad_FRAMEWORKS = UIKit CoreGraphics QuartzCore CoreImage
XPad_LDFLAGS = -Wl,-U,_showCopypastaWithNotification -Wl,-U,_flipLoupeEnableSwitch -Wl,-U,_loupeSwitchState

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += xpadprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
