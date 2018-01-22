volatile void * const uart_base = (void *) 0x21000000;
volatile void * const aos_base = (void *) 0x22000000;

void _start() {
  char uart_status;
  char px;
  int aos_data;

  while (1) {
    uart_status = *((char*)uart_base + 20);
    *((char*)uart_base) = uart_status; // TODO
    if (0x01 & uart_status) // poll uart for new data
      px = *((char*)uart_base);
    else
      continue;

    // wait if aos not ready
    while (!(0x80000000 & *((int*)aos_base))) {}

    *((char*)uart_base) = px; // TODO
    // write pixel to aos input
    *((char*)aos_base) = px;

    // wait if aos not ready
    do {
      aos_data = *((int*)aos_base);
    } while (!(0x80000000 & aos_data));

    // write result to uart
    *((char*)uart_base) = aos_data & 0xff;

  }
}
