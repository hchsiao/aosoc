volatile void * const uart_base = (void *) 0x40000000;

void main(void) {
  for (;;)
    *((char*)uart_base) = 'a';
}

