PRODUCT_VERSION_MAJOR = 2
PRODUCT_VERSION_MINOR = 5
PRODUCT_RELEASE_TYPE = REVERIE

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
PRODUCT_PRODUCT_PROPERTIES += \
    ro.axion.version=$(LINEAGE_VERSION) \
    ro.axion.display.version=$(LINEAGE_DISPLAY_VERSION) \
    ro.axion.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.axion.releasetype=$(LINEAGE_BUILDTYPE)

# Feature
BYPASS_CHARGE_SUPPORTED ?= false
PERF_GOV_SUPPORTED ?= false
PERF_DEFAULT_GOV ?= schedutil
HBM_SUPPORTED ?= false
HBM_NODE ?= /sys/class/backlight/panel0-backlight/hbm_mode
TORCH_STR_SUPPORTED ?= false
TARGET_ENABLES_IMS_OVERRIDES ?= false
TARGET_TOUCH_BOOST_SUPPORTED ?= false

# optional
TARGET_DISABLES_LIBPERF ?= false

# flags
PERF_ANIM_OVERRIDE ?= false
TARGET_NEEDS_DOZE_FIX ?= false
TARGET_DOZE_TAP_PULSE_SUPPORTED ?= false
TARGET_DOZE_DOUBLE_TAP_PULSE_SUPPORTED ?= false
TARGET_DOZE_PICKUP_PULSE_SUPPORTED ?= false
TARGET_DOZE_SIDE_FPS_PULSE_SUPPORTED ?= false

# AxionOS properties - Build info
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.device_camera_info_rear=$(AXION_CAMERA_REAR_INFO) \
    persist.sys.device_camera_info_front=$(AXION_CAMERA_FRONT_INFO) \
    persist.sys.axion_maintainer=$(AXION_MAINTAINER) \
    persist.sys.axion_processor_info=$(AXION_PROCESSOR)

# FEATURES
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.battery_bypass_supported=$(BYPASS_CHARGE_SUPPORTED) \
    persist.sys.dev_supports_perf_gov=$(PERF_GOV_SUPPORTED) \
    persist.sys.default_scaling_gov=$(PERF_DEFAULT_GOV) \
    persist.sys.hbmservice_support=$(HBM_SUPPORTED) \
    persist.sys.hbmservice_file=$(HBM_NODE) \
    persist.sys.torch_str_support=$(TORCH_STR_SUPPORTED) \
    persist.sys.axion_gpu_freqs_path=$(GPU_FREQS_PATH) \
    persist.sys.axion_gpu_minfreq_file=$(GPU_MIN_FREQ_PATH) \
    persist.sys.axion_gpu_opp_index_file=$(GPU_OPP_INDEX_PATH) \
    persist.sys.axion_gpu_opp_table_file=$(GPU_OPP_TABLE_PATH) \
    persist.sys.target_enables_ims_override=$(TARGET_ENABLES_IMS_OVERRIDES) \
    persist.sys.target_supports_touch_boost=$(TARGET_TOUCH_BOOST_SUPPORTED) \
    persist.sys.display_refresh_rates_list=$(TARGET_SUPPORTED_REFRESH_RATES)

    
ifeq ($(PERF_ANIM_OVERRIDE),true)
PRODUCT_PRODUCT_PROPERTIES += \
    debug.sf.predict_hwc_composition_strategy=0
endif

# optional (rmp accessibility)
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.target_disables_libperf=$(TARGET_DISABLES_LIBPERF)
    
# flags
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.activity_anim_perf_override=$(PERF_ANIM_OVERRIDE) \
    persist.sys.enable_doze_fix=$(TARGET_NEEDS_DOZE_FIX) \
    persist.sys.ax_doze_tap_pulse_supported=$(TARGET_DOZE_TAP_PULSE_SUPPORTED) \
    persist.sys.ax_doze_double_tap_pulse_supported=$(TARGET_DOZE_DOUBLE_TAP_PULSE_SUPPORTED) \
    persist.sys.ax_doze_pickup_pulse_supported=$(TARGET_DOZE_PICKUP_PULSE_SUPPORTED) \
    persist.sys.ax_doze_side_fps_pulse_supported=$(TARGET_DOZE_SIDE_FPS_PULSE_SUPPORTED)
