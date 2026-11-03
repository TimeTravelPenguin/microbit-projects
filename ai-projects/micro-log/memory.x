MEMORY
{
  FLASH : ORIGIN = 0x00000000, LENGTH = 448K
  LOG   : ORIGIN = 0x00070000, LENGTH = 64K
  RAM   : ORIGIN = 0x20000000, LENGTH = 128K
}

/* No loadable section occupies LOG: flashing this ELF must not supply log bytes. */
_log_start = ORIGIN(LOG);
_log_end = ORIGIN(LOG) + LENGTH(LOG);

ASSERT(ORIGIN(FLASH) + LENGTH(FLASH) == ORIGIN(LOG), "Firmware overlaps log");
ASSERT(ORIGIN(LOG) % 4096 == 0, "Log must begin on a flash page");
