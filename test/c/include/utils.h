#ifndef _UTILS_H_
#define _UTILS_H_

#ifdef SIMULATION
#define set_test_pass() asm("li x27, 0x01")
#define set_test_fail() asm("li x27, 0x02")
#endif

#endif
