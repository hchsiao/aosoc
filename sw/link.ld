OUTPUT_ARCH( "riscv" )
ENTRY( _start )
SECTIONS
{
  /* text: test code section */
  . = 0x10000004;
  .text :
  {
    *(.text)
}
/* data: Initialized data segment */
.data :
{
  *(.data)
}
/* End of uninitalized data segement */
_end = .;
}
