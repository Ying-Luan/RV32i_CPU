#include <stdint.h>

#include "../include/timer.h"
#include "../include/utils.h"

static volatile uint32_t count;

int main()
{
  count = 0;

#ifdef SIMULATION
  TIMER_REG(TIMER_VALUE) = 500;
  TIMER_REG(TIMER_CTRL) = 0x07;

  while (1)
  {
    if (count == 2)
    {
      TIMER_REG(TIMER_CTRL) = 0x00;
      count = 0;
      set_test_pass();
      break;
    }
  }
#endif

  return 0;
}

void timer_irq_handler() // TODO: not called
{
  TIMER_REG(TIMER_CTRL) |= (1 << 2) | (1 << 0);

  count++;
}
