# nRF52840双模键盘指南
## 警告
由于此仓库的原有内容（2020年编写）已严重过期，因此它们已被已经迁移到deprecated分支下。

要制作无线蓝牙键盘，请考虑使用[ZMK](https://zmk.dev/)。

若有特殊原因必须基于QMK制作无线键盘，请考虑使用[Blueism](https://github.com/object-blueism)，Blueism是一种通过UART让Blackpill F411（运行QMK固件）和Seeed XIAO nRF52840（运行Blueism固件）通信的方案，因此它兼容更多QMK特性，但需要自行优化功耗。你可以制作[nrfpill](https://github.com/object-blueism/nrfpill)并烧录[Onekey](https://github.com/object-blueism/blueism_firmware/blob/main/docs/Use%20with%20qmk_firmware.md)样例来测试其功能。

