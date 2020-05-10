/*
Copyright 2018 Sekigon

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef CONFIG_H
#define CONFIG_H

#define ENABLE_STARTUP_ADV_NOLIST

/* USB Device descriptor parameter */
#define VENDOR_ID       0x3D92
#define PRODUCT_ID      0x8A42
#define DEVICE_VER      0x0001
/* in python2: list(u"whatever".encode('utf-16-le')) */
/*   at most 32 characters or the ugly hack in usb_main.c borks */
#define MANUFACTURER LUANTY
#define PRODUCT Candy BLE
#define DESCRIPTION QMK based keyboard

#define BLE_NUS_MIN_INTERVAL 50
#define BLE_NUS_MAX_INTERVAL 60
#define BLE_HID_MAX_INTERVAL 80
#define BLE_HID_SLAVE_LATENCY 3

/* key matrix size */
#define MATRIX_ROWS 4
#define MATRIX_COLS 12

#define DIODE_DIRECTION COL2ROW

/* define if matrix has ghost */
//#define MATRIX_HAS_GHOST

/* Set 0 if debouncing isn't needed */
#define DEBOUNCE    1

/* Mechanical locking support. Use KC_LCAP, KC_LNUM or KC_LSCR instead in keymap */
#define LOCKING_SUPPORT_ENABLE
/* Locking resynchronize hack */
#define LOCKING_RESYNC_ENABLE

/* key combination for command */
#define IS_COMMAND() ( \
    keyboard_report->mods == (MOD_BIT(KC_LSHIFT) | MOD_BIT(KC_RSHIFT)) \
)
#define ENCODER_ENABLE

// #define WPM_ENABLE

#define PROGMEM // arm-gcc does not interpret PROGMEM
#define RGB_DI_PIN PIN15 // The pin the LED strip is connected to

#define RGBLED_NUM 12// undershoots 3 leds, bad timings probably

#define PREVENT_STUCK_MODIFIERS

// #undef RGB_DISABLE_WHEN_USB_SUSPENDED
// #define RGBLIGHT_SPLIT

/*
 * Feature disable options
 *  These options are also useful to firmware size reduction.
 */

/* disable debug print */
// #define NO_DEBUG

/* disable print */
// #define NO_PRINT

/* disable action features */
//#define NO_ACTION_LAYER
//#define NO_ACTION_TAPPING
//#define NO_ACTION_ONESHOT
//#define NO_ACTION_MACRO
//#define NO_ACTION_FUNCTION

#endif
