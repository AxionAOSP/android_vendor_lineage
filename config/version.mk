PRODUCT_VERSION_MAJOR = 2
PRODUCT_VERSION_MINOR = 3
PRODUCT_RELEASE_TYPE = BETA

CURRENT_DEVICE := $(wordlist 2,3,$(subst _, ,$(TARGET_PRODUCT)))
DEVICE_LIST := $(file < vendor/official_devices/OTA/axion.devices)
MAINTAINER_LIST := $(file < vendor/official_devices/OTA/axion.maintainers)

LINEAGE_BUILDTYPE ?= UNOFFICIAL

ifneq ($(filter $(CURRENT_DEVICE),$(DEVICE_LIST)),)
    ifneq ($(AXION_MAINTAINER),)
        ifneq ($(filter $(AXION_MAINTAINER),$(MAINTAINER_LIST)),)
            LINEAGE_BUILDTYPE := OFFICIAL
        endif
    endif
endif

ifeq ($(LINEAGE_VERSION_APPEND_TIME_OF_DAY),true)
    LINEAGE_BUILD_DATE := $(shell date -u +%Y%m%d%H%M%S)
else
    LINEAGE_BUILD_DATE := $(shell date -u +%Y%m%d)
endif

LINEAGE_VERSION_SUFFIX := $(LINEAGE_BUILD_DATE)-$(LINEAGE_BUILDTYPE)-$(AXION_BUILD_VARIANT)-$(LINEAGE_BUILD)

# Internal version
LINEAGE_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(PRODUCT_RELEASE_TYPE)-$(LINEAGE_VERSION_SUFFIX)

# Display version
LINEAGE_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR)-$(LINEAGE_VERSION_SUFFIX)

# LineageOS version properties
PRODUCT_SYSTEM_PROPERTIES += \
    ro.axion.version=$(LINEAGE_VERSION) \
    ro.axion.display.version=$(LINEAGE_DISPLAY_VERSION) \
    ro.axion.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.axion.releasetype=$(LINEAGE_BUILDTYPE)
