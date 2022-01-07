#include <stdint.h>
#include <stddef.h>

/* From RM0008: */
/* 0x4002 1000 - 0x4002 13FF Reset and clock control RCC */
#define RCC      (0x40021000)

/* APB2 peripheral clock enable register (RCC_APB2ENR) */
/* Address: 0x18 */
#define RCC_APB2ENR   (RCC + 0x18)

/* 0x4001 1000 - 0x4001 13FF GPIO Port C */
#define GPIOC    (0x40011000)

/* GPIO and AFIO register maps */
/* CRH: Control Register High */
/* 0x04 GPIOx_CRH */
#define GPIOC_CRH     (GPIOC + 0x04)

/* ODR: Output Data Register */
/* 0x0C GPIOx_ODR */
#define GPIOC_ODR     (GPIOC + 0x0C)

/* Low-, medium-, high- and XL-density reset and clock control (RCC) */
/* Bit 4 IOPCEN: IO port C clock enable */
#define RCC_IOPCEN   (1UL << 4)

/* STM32-Bluepill-schematic */
/* LED on PC13 */
#define GPIOC13      (1UL << 13)

void init(void);
void set_led(int on);
int set_led_for_loop(unsigned loop_count);

int main(void)
{
	init();

	/* i can be inspected from gdb */
	for (unsigned i = 0; 1; ++i) {
		set_led_for_loop(i);
	}
}

void init(void)
{
	*(volatile uint32_t *)RCC_APB2ENR |= RCC_IOPCEN;
	*(volatile uint32_t *)GPIOC_CRH &= 0xFF0FFFFF;
	*(volatile uint32_t *)GPIOC_CRH |= 0x00200000;
	set_led(0);
}

void set_led(int on)
{
	if (on) {
		/* Output Data Register set PC13/LED */
		*(volatile uint32_t *)GPIOC_ODR |= GPIOC13;
	} else {
		/* Output Data Register NOT PC13/LED */
		*(volatile uint32_t *)GPIOC_ODR &= ~GPIOC13;
	}
}

/*
 * toggle off and back on approx every million loops (2^20 == 1048576)
 * (power of two so that division will be a right shit)
 * but if the loop takes a long time, this will be a very slow blink
 */
#ifndef LOOPS_PER_LED_TOGGLE
#define LOOPS_PER_LED_TOGGLE (1048576/2)
#endif
int set_led_for_loop(unsigned loop_count)
{
	static int led_state = 0;
	int state = (((loop_count / LOOPS_PER_LED_TOGGLE) % 2) == 0) ? 1 : 0;
	if (state != led_state) {
		led_state = state;
		set_led(led_state);
		return 1;	/* set a breakpoint here (b 80) */
	}
	return 0;
}
