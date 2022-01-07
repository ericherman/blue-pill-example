bluepill-example is a very simple example of how to program
a 'bluepill' STM32F103C8T6 development board.


Dependencies
------------

The Makefile assumes an ST-LINK V2 programmer, and the packages
stlink-tools, gcc-arm-none-eabi, openocd, and GNU make installed.


Flashing and debugging
----------------------

Connect the 'blue pill' to the `st-link-v2` usb dongle.
	ST-LINK V2	Blue Pill
	PIN 2 SWCLK	SWCLK
	PIN 4 SWDIO	SWDIO
	PIN 6 GND	GND
	PIN 8 3.3V	3.3V

Plug in the st-link-v2 to a USB port.

In a terminal type `make probe` and look for `Found 1 stlink programmers`

Compile the firmware with `make`

Flash the firmware to the device with `make flash`

Start Open On Chip Debugger with `make ocd` and look for the gdb port number:
	Info : Listening on port 3333 for gdb connections

In a different terminal, start gdb with `make gdb`

In gdb, type `target extended-remote :3333`

Set a breakpoint with `b 80` and type `continue`


ST References
-------------

RM0008
* Reference manual: STM32F101xx, STM32F102xx, STM32F103xx, STM32F105xx and
  STM32F107xx advanced Arm(R)-based 32-bit MCUs
https://www.st.com/resource/en/reference_manual/cd00171190-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf


AN2606
* Application note: STM32 microcontroller system memory boot mode
https://www.st.com/resource/en/application_note/cd00167594-stm32-microcontroller-system-memory-boot-mode-stmicroelectronics.pdf


License
-------

SPDX-License-Identifier: LGPL-3.0-or-later

Licensed under the terms of the GNU Lesser General Public License
(LGPL), version 3 or later.

See COPYING and COPYING.LESSER for details.
