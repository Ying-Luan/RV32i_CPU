#ifndef _TIMER_H_
#define _TIMER_H_

#define TIMER_BASE (0x20000000)
#define TIMER_CTRL (TIMER_BASE + (0x00))
#define TIMER_COUNT (TIMER_BASE + (0x04))
#define TIMER_VALUE (TIMER_BASE + (0x08))

#define TIMER_REG(addr) (*((volatile uint32_t *)addr))

#endif
