# nrfmicro方案n52840双模指南

编辑：2020/4/30

---

* 一些概述
    * 目前已知的问题、BUG

* 硬件
    * nrfmicro
    * 引脚说明
    * 电源管理
    * 焊接
    * PCB
        * 布线规则
    * 模块烧录固件前的准备工作
        * 解锁nrf52840模块
        * 烧录Bootloader
* 软件
    * 环境安装
        * 安装官方版本的QMK
        * 安装 Sekigon gonnoc 所修改的QMK（nrf52 fork）
        * 下载nrf SDK
    * 固件编译及烧录
    * 自定义配列修改说明
    * 蓝牙配对
    * 校准电量
    * RGB底灯
    * 编码器（旋钮）配置
    * OLED显示屏配置
    * 打字速度

---

## 一些概述

这篇文章指导的是如何使用QMK固件驱动亿百特nRF52840（以下简称n52840）。硬件部分基于Joric所设计的nrfmicro，但由于nrfmicro并非处于板载目的，没有引出部分IO引脚，所以要先修改他的原理图使得亿百特n52840上的引脚都可以使用。固件使用Sekigon gonnoc所创建的QMK nrf52分支。

其他蓝牙5.0方案：

chie4（QMK固件）：https://github.com/chie4hao/qmk_firmware_nrf52840

nRF52832和nRF52810（TMK固件）：https://github.com/Lotlab/nrf52-keyboard


### 目前已知的问题、BUG

注意在这里使用的QMK固件并非官方发布的版本，并且因为与Nordic具有双重协议的问题，不可能会被合并进QMK主分支，因此想要使用n52840以及QMK固件的话，可能会经历固件不稳定或者存在BUG的情况，如果希望固件稳定运行，可以使用官方所支持的蓝牙4.0（nRF51822）。

BUG列表：

* ~~RGB仅在USB模式下工作，切换到蓝牙模式下会使RGB灯效卡住并无法关闭，重新插入USB线后恢复正常~~ RGB BUG已修复。[解决方法](https://github.com/sekigon-gonnoc/qmk_firmware/issues/28)

* Sekigon的分支中有EEPROM问题，RGB在每次键盘电源关闭后无法读取前一次的RGB亮度、饱和度、开关状态等，如果使用Sekigon的分支来做RGB的话则一定会遇到EEPROM不起作用的问题吧。不过，最近这个问题也解决了，但是改动了相当多的内核部分的文件，如果想要使用EEPROM正常工作的话可以克隆我的分支：https://github.com/luantty2/qmk

  要注意的是这个指南仓库下的candy ble源码并不支持EEPROM。但是 https://github.com/luantty2/qmk 下的candy ble源码已经支持EEPROM。因为后者无法在Sekigon的分支下正常编译，所以我将他它们区分了，如果你不需要EEPROM，那么在Sekigon的分支下工作自然没问题。

---

## 硬件

### nrfmicro
原理图克隆地址：https://github.com/joric/nrfmicro

wiki：https://github.com/joric/nrfmicro/wiki

示例所使用原理图来自于我的 candy 40 ble，原理图以及固件源码：https://github.com/luantty2/Candy_40_BLE 仅供参考

*candy 40 ble:*

![PHOTO](https://i.imgur.com/1YVuMmE.png)


![PHOTO](https://i.imgur.com/hHVOpjQ.jpg)

---

### 引脚说明

总共具有23个可用IO引脚（包含两个IIC引脚）。

普通引脚以及定义：

|IO|功能|备注|
|:---|:---|:---|
|P1.11  |普通IO||
|P0.03 |普通IO||
|P0.28  |普通IO||
|P1.13 |普通IO||
|P0.02|普通IO||
|P0.29|普通IO||
|P0.31|普通IO||
|P0.30|普通IO||
|P0.06|普通IO||
|P0.05|普通IO||
|P0.08|普通IO||
|P1.09|普通IO|*注释*|
|P0.12|普通IO||
|P0.10|普通IO||
|P1.06|普通IO|
|P0.09|普通IO||
|P1.04|普通IO||
|P0.24|普通IO||
|P0.22|普通IO||
|P0.13|普通IO||
|P0.20|普通IO||
|P0.17|普通IO,IIC|SCL|
|P0.15|普通IO,IIC|SDA|

*P1.09引脚在nrfmicro 1.1版本中被用作控制一个mosfet以减小某些拥有大量RGB灯的键盘造成的电池泄露（因为RGB在关闭时也会消耗电量），不过这个是可选的功能，可以把P1.09所连接的电路删去，将P1.09作为普通IO使用。*

![PHOTO](https://i.imgur.com/ii1KnTX.png)

nrfmicro系统引脚定义：
|IO|功能|备注|
|:---|:---|:---|
|P0.00  |连接外部32.768K晶振|*注释*|
|P0.01 |连接外部32.768K晶振||
|P1.10  |连接蓝色LED指示灯|蓝牙连接时闪烁两下|
|P0.26 |检测电池开关|电池开关关闭状态下自动进USB模式，否则进蓝牙模式|
|P0.04  |ANALOG引脚用于电池电量检测||
|P0.07 |BOOT、是否可以用作普通IO未测试||
|P1.02|DFU、是否可以用作普通IO未测试||
|SWD|SWD下载口|烧录bootloader使用|
|SWC|SWD下载口|烧录bootloader使用|
|SWO|未知|不使用|
|D+|USB信号||
|D-|USB信号||
|VBUS|USB5V电源||
|VCC|3.3V稳压电源输入口||
|RESET|进入刷机模式|短接reset和gnd两次进入刷机模式|
|GND|公共地||

*外部晶振可以帮助节约电量，也可以省去外部晶振，如果不使用外部晶振，需要在custom_board.h中如此修改：*

```
// NRF_CLOCK_LF_SRC_RC - internal oscillator
// NRF_CLOCK_LF_SRC_XTAL - external crystal
// using E73 internal oscillator (assume there's no external crystal soldered)
#define NRF_CLOCK_LFCLKSRC      {.source        = NRF_CLOCK_LF_SRC_RC,            \
                                 .rc_ctiv       = 16,                                \
                                 .rc_temp_ctiv  = 2,                                \
                                 .xtal_accuracy = 0}
```

在引出所有引脚后，大概可以画成这样：

![PHOTO](https://i.imgur.com/FQHWLr6.png)

### 电源管理

MCP73831电池管理芯片上的Rprog电阻阻值决定充电电流的大小，最好匹配充电电流和电池容量。要确定自己的电池容量应该在多大的电流下充电，可以参考电池厂商给出的数据。

*MCP73831 datasheet*

![PHOTO](https://i.imgur.com/0kDFwOw.png)


### 焊接

n52840主控底下的引脚十分容易虚焊，在把它贴到板子上之前要先用烙铁对底部焊盘上一层薄薄的锡，但不要让它们凸起。

---

## PCB

### 布线规则

充电电路和稳压电路尽可能靠近供电电池和主控，10uf电容必须靠近充电芯片和稳压芯片。
请手动布线，在n52840主控下方设置禁布区，禁止走线和铺铜，天线下方的PCB最好镂空。

![PHOTO](https://i.imgur.com/gAGW261.png)

---

## 模块烧录固件前的准备工作

### 解锁nrf52840模块

模块出厂后是锁定状态，首先需要使用对模块解锁。这里示范的是使用segger j-link ob克隆和segger软件。

*j-link clone:*
![PHOTO](https://i.imgur.com/8wGQ3zO.jpg)

segger jflash软件下载地址（win/mac）：
https://www.segger.com/downloads/jlink/#J-LinkSoftwareAndDocumentationPack

请下载6.70b版本，其他版本未测试。

把j-link上的VCC GND SWC SWD 连接到n52840的VCC GND SWC SWD（禁止给n52840其它供电，例如USB供电)，然后打开下载好的jFlash软件。

依照下图中的顺序，创建新的工程。

![PHOTO](https://i.imgur.com/avVLvHz.png)

Options->Project Settings

![PHOTO](https://i.imgur.com/KxoRSY4.png)

Target Interface -> Auto selection

![PHOTO](https://i.imgur.com/7Rx0ouy.png)

上面的步骤完成后，选择菜单栏上的Target -> Connect, 如果正常的话，JFlash会弹出一个对话框问你是否解锁，选是就可以了。然后Target-> Disconnect 断开连接。

### 烧录Bootloader

打开刚才下载的另一个软件 JFlashLite，此处需要先准备bootloader：

[pca10056_bootloader-0.2.10_s140_6.1.1.hex](https://github.com/joric/nrfmicro/wiki/Software#Bootloader)

然后在JFlashLite中载入下载好的bootloader，然后Program Device, 一秒之后bootloader就烧录好了。

![PHOTO](https://i.imgur.com/Bambryp.png)

在bootloader烧录完成之后就不需要j-link了，可以断开板子和j-link的连接，用USB线连接板子到电脑，如果此时电脑上出现一个新的U盘，就说明bootloader烧录正确。如果没有出现，再次重复bootloader烧录步骤，如果还是没有，检查USB供电以及正负信号线连接是否正常。

---

## 软件

### 环境安装

#### 安装官方版本的QMK

首先安装官方版本的QMK，虽然并不需要使用它，但必须确保电脑上拥有编译工具 https://docs.qmk.fm/#/newbs_getting_started

#### 安装 Sekigon gonnoc 所修改的QMK（nrf52 fork）

Sekigon gonnoc 版本的QMK发布在这里： https://github.com/sekigon-gonnoc/qmk_firmware/tree/nrf52

克隆命令：
```
$ git clone --recurse-submodules -b nrf52 https://github.com/sekigon-gonnoc/qmk_firmware.git
```

值得注意的是该仓库下有多个分支，必须下载nrf52分支。下载之后可以在QMK目录下用 *$ git branch* 命令查看是否处在nrf52分支上。

#### 下载nrf SDK

nrf SDK下载地址： https://developer.nordicsemi.com/nRF5_SDK/nRF5_SDK_v15.x.x/

必须下载15.0.0版本。解压后放在任何文件夹。

---

### 固件编译及烧录

在环境安装完成后可以通过能否编译键盘来看环境是否安装正常。固件编译命令：

*测试：*

```
make NRFSDK15_ROOT=/Users/apple/Downloads/nrf_qmk_firmware/nRF5_SDK_15.0.0_a53641a ble_micro_test
```

*编译candy ble:*

```
make NRFSDK15_ROOT=/Users/apple/Downloads/nrf_qmk_firmware/nRF5_SDK_15.0.0_a53641a candy_ble/pro_v1
```

*之前版本中candy_ble中的编码器代码中有两行tap_code()函数会导致编译错误，是因为我在自己的fork中从QMK近期版本合并了tap_code()的实现，而sekigon的版本中没有该实现，你需要把tap_code()注释掉才能编译。现在tap_code()被改成一组register_code()和unregister_code()，可以正常编译*

编译命令的结构：make nrf_SDK所在文件夹 键盘名/（master/slave/solo）

编译命令和原版的QMK还是不一样的，首先它需要填写nrf SDK所在的文件夹。其次，根据键盘是无线分体（master、slave）还是单体，有不同的文件夹命名，此处以candy 40为例，单体键盘文件放在pro_v1文件夹下，因此是candy_ble/pro_v1。

编译后的hex文件在QMK目录下的.build隐藏文件夹下，需要将它复制出来。如是mac，打开隐藏文件夹的命令是 open .build

hex文件无法直接烧录，需要用python脚本转换为uf2格式，脚本在candy 40文件夹下可以获得，该操作要确保脚本和hex文件处于同一个文件夹下。

```
python uf2conv.py candy_ble_pro_v1_default.hex -c -f 0xADA52840
```

固件烧录必须在USB下进行，按两下复位按钮进入刷机模式（或者用导线短接RESET和GND两下），电脑上会出现一个U盘，不要动里面的东西，直接将flash.uf2拖进去即可，U盘会烧录完成并自动弹出。

### 自定义配列修改说明

Joric所制作的nrfmicro范例都是无线分体键盘，如果你制作无线分体键盘，可以在他的jorne_ble基础上修改，开源地址：https://github.com/joric/qmk/tree/nrf52-jorne/keyboards/jorne_ble

但是Joric没有给出单体键盘的范例，所以以下的配列信息调整方法都是基于我所修改的candy 40。并且这里我只写单体键盘配列修改方法。

对以下文件逐一修改：

* 键盘文件夹名：

![PHOTO](https://i.imgur.com/gxgcBMM.png)

可以改成任何名字

* 键盘文件夹/config.h

```
/*VID PID等*/
#define VENDOR_ID       0xFEED
#define PRODUCT_ID      0x2090
#define DEVICE_VER      0x0001
/*制造商 产品名 描述*/
#define MANUFACTURER LUANTY
#define PRODUCT Candy BLE
#define DESCRIPTION QMK based keyboard

/*蓝牙扫描设置，越小越耗电，越大则会感到延迟*/
#define BLE_NUS_MIN_INTERVAL 30
#define BLE_NUS_MAX_INTERVAL 30
#define BLE_HID_MAX_INTERVAL 50
#define BLE_HID_SLAVE_LATENCY 3

/*行和列的数目*/
#define MATRIX_ROWS 4
#define MATRIX_COLS 12

/*二极管方向*/
#define DIODE_DIRECTION COL2ROW

/*消抖*/
#define DEBOUNCE    1

 /*如果不需要启用编码器（旋钮），删去这一行，并在pro_v1/rules.mk里面删除SRC+=encoder.c*/
#define ENCODER_ENABLE

/*RGB引脚和数量*/
#define PROGMEM
#define RGB_DI_PIN PIN15

#define RGBLED_NUM 12
```

* 键盘文件夹/candy_ble.h 

首先把这个文件改成和你键盘文件夹相同的名称，然后打开修改第一行和第二行，同样改成你自己的键盘名称：

```
#ifndef KEYBOARDS_CANDY_BLE_H_
#define KEYBOARDS_CANDY_BLE_H_
```

此文件存放配列信息，如果不会写的话可以从kbfirmware上在线生成固件后下载源文件，将里面的配列信息复制过来。

```
#define LAYOUT( \
  K000, K001, K002, K003, K004, K005, K006, K007, K008, K009, K010, K011,       \
  K100, K101, K102, K103, K104, K105, K106, K107, K108, K109, K110, K111,       \
  K200, K201, K202, K203, K204, K205, K206, K207, K208, K209, K210,             \
  K300, K301,                   K305,             K308,       K310, K311  \
) { \
  { K000,  K001,  K002,  K003,  K004,  K005,  K006,  K007,  K008,  K009,  K010,  K011 }, \
  { K100,  K101,  K102,  K103,  K104,  K105,  K106,  K107,  K108,  K109,  K110,  K111 }, \
  { K200,  K201,  K202,  K203,  K204,  K205,  K206,  K207,  K208,  K209,  K210,  KC_NO }, \
  { K300,  K301,  KC_NO, KC_NO, KC_NO, K305,  KC_NO, KC_NO, K308,  KC_NO, K310,  K311 }  \
}

```

* 键盘文件夹/candy_ble.c

同样把这个文件改成和你键盘文件夹相同的名称，并且修改首行的#include，把candy_ble.h改成你自己的xxx.h：

```
#include "candy_ble.h"
```

* 键盘文件夹/pro_v1/config.h

在这里分配引脚

```
/*行和列的数目*/
#define THIS_DEVICE_ROWS 4
#define THIS_DEVICE_COLS 12

/*行和列引脚分配，PIN口对应表，可以看board/custom_board.h*/
#define MATRIX_ROW_PINS { PIN13, PIN14, PIN16, PIN17 }
#define MATRIX_COL_PINS { PIN18, PIN19, PIN20, PIN1, PIN2, PIN24, PIN10, PIN11, PIN25, PIN26, PIN8, PIN9 }

/*如果启用编码器，需要配置A和B两个引脚，如果前一个config.h中的 #define ENCODER_ENABLE被删除，可以不管，编译器会自动忽略*/
#ifdef ENCODER_ENABLE
	#define ENCODERS_PAD_A { PIN22 }
	#define ENCODERS_PAD_B { PIN7 }
#endif

#define TAP_CODE_DELAY 50
/*始终为真*/
#define IS_LEFT_HAND  true
#define ENABLE_STARTUP_ADV_NOLIST
```

* 键盘文件夹/keymap/default/kepmap.c

在这个文件夹里分配键值和层，同样，如果你不熟悉的话可以从kbfirmware上在线生成固件后下载源文件，将里面的键值信息复制过来。

```
    [_BASE]=LAYOUT(
    TD(TO_SETTINGS), KC_Q, KC_W, KC_E, KC_R, KC_T, KC_Y, KC_U, KC_I, KC_O, KC_P, KC_BSPC, 
    KC_CAPS, KC_A, KC_S, KC_D, KC_F, KC_G, KC_H, KC_J, KC_K, KC_L, KC_ENT, KC_MUTE, 
    LSFT_T(KC_TAB), KC_Z, KC_X, KC_C, KC_V, KC_B, KC_N, KC_M, KC_COMM, ENT_DFU, KC_UP, 
    MO(_EXTRA), KC_LGUI, KC_SPC, KC_LEFT, KC_DOWN, KC_RGHT),
    [_EXTRA]=LAYOUT(
    KC_GRV, KC_1, KC_2, KC_3, KC_4, KC_5, KC_6, KC_7, KC_8, KC_9, KC_0, KC_BSLS, 
    KC_LCTL, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_LBRC, KC_RBRC, KC_SCLN, KC_QUOT, XXXXXXX, XXXXXXX, 
    KC_LSFT, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_SLSH, KC_VOLU, 
    _______, _______, XXXXXXX, KC_MINS, KC_VOLD, KC_EQL)，
```

以下的蓝牙相关键值建议设置：

|键值|功能|
|:---|:---|
|TOG_HID |切换蓝牙和USB数据发送，如果键盘按键没反应，按这个键|
|DELBNDS|删除所有配对绑定|
|ENT_DFU |进入刷机模式，免去按复位按钮的麻烦|
|ENT_SLP|使主控进入睡眠|
|BATT_LV|在屏幕上发送电量|

---

### 蓝牙配对

如果主机扫描不到键盘，按一下DELBNDS键。

如果主机显示已连接但主机收不到数据，按一下TOG_HID，如果还是不行，就从主机上忘记键盘，按一下DELBNDS键然后重新连接。

---

### 校准电量

电池电量代码需要校准后才能测得相对准确的电量，但由于测电量方式为adc，因此无法获得很精确的电量，并且可能会发生跳变，这都属于正常。

电池检测是由P0.04引脚完成的，串有一个10K电阻，如果你用的10K电阻精度为5%，那么你的另一块键盘可能测得的误差会稍微变大，用1%精度电阻可以使误差变小。

校准步骤：

首先，需要修改qmk/tmk_core/protocol/nrf/nrf52/adc.c中的代码：

```
uint16_t get_vcc() {
  return ((uint32_t)adc_buffer[0]*6*600/255)*453/256;
}
```

我们需要测得没有电量偏移时的电压，因此需要把最后一行修改成如下：
```
return ((uint32_t)adc_buffer[0]*6*600/255);
```

编译固件并烧录，将电池充满，然后按下BATT_LV，测得在满电情况下读到的值（需要将电池开关打开），例如：2470mV，
而充满电的电池电压在4200mV左右，因此需要对结果做一个偏移。

重新打开adc.c，作如下修改：
```
uint16_t get_vcc() {
  return ((uint32_t)adc_buffer[0]*6*600/255)*4200/2470;
}
```
Candy 40将电压转换为百分比，因此你可以在OLED屏幕上读取电池百分比：
```
const char *read_bat_percentage(void) {
  return bat_percentage_str;
}
```

---

### RGB底灯

如果不启用RGB底灯，则将键盘文件夹/keymap/default/rule.mk 中设置为LED_UNDERGLOW_ENABLE = no

RGB在USB下默认会亮，可以修改pro_v1.c 下的matrix_init_user()函数修改它的自动点亮行为。
RGB一定需要设置RGBRST键值，否则RGB_MOD等键值不起作用。

---

### 编码器（旋钮）配置

如果不要编码器，首先删除键盘文件夹/config.h下的#define ENCODER_ENABLE ，然后把pro_v1/rules.mk中的SRC+=encoder.c 删除，编码器相关代码不会被编译。请不要按照QMK文档上的编码器文档来配置。

编码器支持是我从官方版本QMK中移植过来的，seikigon的fork是很早版本的QMK，并不支持编码器。我仅修改了引脚读取部分的代码，以让n52840能读取引脚上的值，但经过我的测试发现读取精度不如aTmega32U4，你可以在编码器周围放置阻容元件来提高编码器的精度（如candy 40），并且使用定位数高的编码器，例如30定位。

要修改编码器引脚，请到pro_v1/config.h下修改。

要修改编码器的行为，请在keymap.c中修改：

```
#ifdef ENCODER_ENABLE
void encoder_update_user(uint8_t index, bool clockwise) {
      if(clockwise){
        tap_code(KC_SLCK);
      }
      else{
        tap_code(KC_PAUS);
      }
}
#endif

```

问题是，编码器目前无论如何都无法输出媒体键键值，例如VOLU，VOLD，而在一般的键位上设置这些键值却有作用，也许是老版本QMK内核的问题。我从新版本移植了类似“tap_code()”等功能，又或者是设置延迟，但依然无解。

---

### OLED显示屏配置

如果不要显示屏，可以把键盘文件夹/keymaps/default/config.h中的#define SSD1306OLED 一行删除，OLED相关代码将不会被编译。

OLED显示屏将会显示电量，双模状态，打字速度。
还有其他功能例如层指示，大小写，实时显示输入的字符等等，RGB设置也可以在显示屏下设置（看lib/rgb_state_reader.c）。

OLED显示屏的行为在keymap.c 下的matrix_render_user()函数中定义。

目前显示屏使用的是老版本QMK提供的api，但文档依然可以在 https://docs.qmk.fm/#/feature_oled_driver 找到

---

### 打字速度

打字速度（WPM）是我从最近版本的QMK中合并进来的，在显示屏上可以实时显示打字速度。如果不用显示屏，也可以通过设置键盘宏来显示打字速度：https://docs.qmk.fm/#/feature_wpm

---













































