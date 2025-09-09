PRODUCT_VERSION_MAJOR = 2
PRODUCT_VERSION_MINOR = 0
PRODUCT_RELEASE_TYPE = BETA

CURRENT_DEVICE := $(wordlist 2,3,$(subst _, ,$(TARGET_PRODUCT)))
DEVICE_LIST := $(file < vendor/official_devices/OTA/axion.devices)
MAINTAINER_LIST := $(file < vendor/official_devices/OTA/axion.maintainers)

LINEAGE_BUILDTYPE ?= COMMUNITY

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

ifeq ($(WITH_GMS),true)
AXION_BUILD_VARIANT := GMS
else
AXION_BUILD_VARIANT := VANILLA
endif

LINEAGE_VERSION_SUFFIX := $(LINEAGE_BUILD_DATE)-$(LINEAGE_BUILDTYPE)-$(AXION_BUILD_VARIANT)-$(LINEAGE_BUILD)

# Internal version
LINEAGE_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(PRODUCT_RELEASE_TYPE)-$(LINEAGE_VERSION_SUFFIX)

# Display version
LINEAGE_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR)-$(LINEAGE_VERSION_SUFFIX)

# LineageOS version properties
PRODUCT_SYSTEM_PROPERTIES += \
    ro.lineage.version=$(LINEAGE_VERSION) \
    ro.lineage.display.version=$(LINEAGE_DISPLAY_VERSION) \
    ro.lineage.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.lineage.releasetype=$(LINEAGE_BUILDTYPE)

# CPU
AXION_CPU_SMALL_CORES ?= 0,1,2,3
AXION_CPU_BIG_CORES ?= 4,5,6,7
AXION_ALL_CORES ?= 0-7
AXION_CPU_SYS_BG ?= 0-3
AXION_CPU_BG ?= 0-2
AXION_CPU_FG ?= 0-7
AXION_CPU_LIMIT_BG ?= 0-1
AXION_CPU_LIMIT_UI ?= 0-2
AXION_CPU_DISPLAY ?= 0-5

# Feature
BYPASS_CHARGE_SUPPORTED ?= false
PERF_GOV_SUPPORTED ?= false
PERF_DEFAULT_GOV ?= schedutil
PERF_ANIM_OVERRIDE ?= false
HBM_SUPPORTED ?= false
HBM_NODE ?= /sys/class/backlight/panel0-backlight/hbm_mode

# Dex2oat - recommended: 2 small cores only
DEX2OAT_CORES ?= 0,1
DEX2OAT_THREADS ?= 2

# AxionOS properties - Build info
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.device_camera_info_rear=$(AXION_CAMERA_REAR_INFO) \
    persist.sys.device_camera_info_front=$(AXION_CAMERA_FRONT_INFO) \
    persist.sys.axion_maintainer=$(AXION_MAINTAINER) \
    persist.sys.axion_processor_info=$(AXION_PROCESSOR)\
    ro.axion.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)

# dex2oat
PRODUCT_PRODUCT_PROPERTIES += \
    dalvik.vm.dex2oat-threads=$(DEX2OAT_THREADS) \
    dalvik.vm.restore-dex2oat-threads=$(DEX2OAT_THREADS) \
    dalvik.vm.dex2oat-cpu-set=$(DEX2OAT_CORES) \
    dalvik.vm.restore-dex2oat-cpu-set=$(DEX2OAT_CORES)

# CPU
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.axion_cpu_big=$(AXION_CPU_BIG_CORES) \
    persist.sys.axion_cpu_small=$(AXION_CPU_SMALL_CORES) \
    persist.sys.axion_cpu_bg=$(AXION_CPU_BG) \
    persist.sys.axion_cpu_sys_bg=$(AXION_CPU_SYS_BG) \
    persist.sys.axion_cpu_limit_bg=$(AXION_CPU_LIMIT_BG) \
    persist.sys.axion_cpu_fg=$(AXION_CPU_FG) \
    persist.sys.axion_cpu_limit_ui=$(AXION_CPU_LIMIT_UI) \
    persist.sys.axion_cpu_unlimit_ui=$(AXION_ALL_CORES) \
    persist.sys.axion_cpu_display=$(AXION_CPU_DISPLAY)

# FEATURES
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.battery_bypass_supported=$(BYPASS_CHARGE_SUPPORTED) \
    persist.sys.dev_supports_perf_gov=$(PERF_GOV_SUPPORTED) \
    persist.sys.default_scaling_gov=$(PERF_DEFAULT_GOV) \
    persist.sys.activity_anim_perf_override=$(PERF_ANIM_OVERRIDE) \
    persist.sys.hbmservice_support=$(HBM_SUPPORTED) \
    persist.sys.hbmservice_file=$(HBM_NODE)
