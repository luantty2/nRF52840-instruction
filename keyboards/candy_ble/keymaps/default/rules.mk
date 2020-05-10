
# Helix keyboard customize
# you can edit following Variables
HELIX_ROWS = 5              # Helix Rows is 4 or 5
LED_BACK_ENABLE = no        # LED backlight (Enable WS2812 RGB underlight.)
LED_UNDERGLOW_ENABLE = yes  # LED underglow (Enable WS2812 RGB underlight.)
LED_ANIMATIONS = yes        # LEnoD animations
OLED_ENABLE = yes            # OLED_ENABLE
LOCAL_GLCDFONT = yes        # use each keymaps "helixfont.h" insted of "common/glcdfont.c"

define HELIX_CUSTOMISE_MSG
  $(info Helix customize)
  $(info -  OLED_ENABLE=$(OLED_ENABLE))
  $(info -  LED_BACK_ENABLE=$(LED_BACK_ENABLE))
  $(info -  LED_UNDERGLOW_ENABLE=$(LED_UNDERGLOW_ENABLE))
  $(info -  LED_ANIMATION=$(LED_ANIMATIONS))
  $(info -  IOS_DEVICE_ENABLE=$(IOS_DEVICE_ENABLE))
endef

ifneq ($(strip $(HELIX_ROWS)), 4)
  ifneq ($(strip $(HELIX_ROWS)), 5)
    $(error HELIX_ROWS = $(strip $(HELIX_ROWS)) is unexpected value)
  endif
endif
OPT_DEFS += -DHELIX_ROWS=$(strip $(HELIX_ROWS))

ifeq ($(strip $(LED_BACK_ENABLE)), yes)
  RGBLIGHT_ENABLE = yes
  OPT_DEFS += -DRGBLED_BACK
  ifeq ($(strip $(LED_UNDERGLOW_ENABLE)), yes)
    $(eval $(call HELIX_CUSTOMISE_MSG))
    $(error LED_BACK_ENABLE and LED_UNDERGLOW_ENABLE both 'yes')
  endif
else ifeq ($(strip $(LED_UNDERGLOW_ENABLE)), yes)
  RGBLIGHT_ENABLE = yes
else
  RGBLIGHT_ENABLE = no
endif

ifeq ($(strip $(LED_ANIMATIONS)), yes)
    OPT_DEFS += -DRGBLIGHT_ANIMATIONS
endif

ifeq ($(strip $(LOCAL_GLCDFONT)), yes)
    OPT_DEFS += -DLOCAL_GLCDFONT
endif

ifeq ($(strip $(OLED_ENABLE)), yes)
    OPT_DEFS += -DOLED_ENABLE
endif

# Do not enable SLEEP_LED_ENABLE. it uses the same timer as BACKLIGHT_ENABLE
SLEEP_LED_ENABLE = no    # Breathing sleep LED during USB suspend

ifndef QUANTUM_DIR
	include ../../../../Makefile
endif

# If you want to change the display of OLED, you need to change here
SRC +=  ../../lib/glcdfont.c \
        ../../lib/rgb_state_reader.c \
        ../../lib/layer_state_reader.c \
        ../../lib/logo_reader.c \
        ../../lib/keylogger.c \
        # ./lib/mode_icon_reader.c \
        # ./lib/host_led_state_reader.c \
        ../../lib/timelogger.c \

# enables eeprom for rgblight.c (it checks for || defined(EEPROM_SIZE))
OPT_DEFS += -DEEPROM_SIZE=36

