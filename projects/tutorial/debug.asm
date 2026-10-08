
tutorial:	file format elf32-littlearm

Disassembly of section .text:

00000100 <__stext>:
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     100:      	bl	0x2cb8 <__pre_init>     @ imm = #0x2bb4
;                 unsafe { self.bits(variant.into()) }
     104:      	ldr	r0, [pc, #0x38]         @ 0x140 <__stext+0x40>
     106:      	ldr	r1, [pc, #0x3c]         @ 0x144 <__stext+0x44>
     108:      	movs	r2, #0x0
     10a:      	cmp	r1, r0
     10c:      	beq	0x112 <__stext+0x12>    @ imm = #0x2
     10e:      	stm	r0!, {r2}
     110:      	b	0x10a <__stext+0xa>     @ imm = #-0xa
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     112:      	ldr	r0, [pc, #0x34]         @ 0x148 <__stext+0x48>
     114:      	ldr	r1, [pc, #0x34]         @ 0x14c <__stext+0x4c>
     116:      	ldr	r2, [pc, #0x38]         @ 0x150 <__stext+0x50>
;                     | ((value.into() & Self::MASK) << { OF });
     118:      	cmp	r1, r0
     11a:      	beq	0x122 <__stext+0x22>    @ imm = #0x4
     11c:      	ldm	r2!, {r3}
     11e:      	stm	r0!, {r3}
     120:      	b	0x118 <__stext+0x18>    @ imm = #-0xc
     122:      	ldr	r0, [pc, #0x30]         @ 0x154 <__stext+0x54>
     124:      	mov.w	r1, #0xf00000
     128:      	ldr	r2, [r0]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     12a:      	orr.w	r2, r2, r1
     12e:      	str	r2, [r0]
     130:      	dsb	sy
;                         });
     134:      	isb	sy
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     138:      	bl	0x316 <main>            @ imm = #0x1da
     13c:      	udf	#0x0
;                         });
     13e:      	movs	r0, r0
     140: 00 00 00 20  	.word	0x20000000
     144: 48 04 00 20  	.word	0x20000448
     148: 00 00 00 20  	.word	0x20000000
     14c: 00 00 00 20  	.word	0x20000000
     150: 88 69 00 00  	.word	0x00006988
     154: 88 ed 00 e0  	.word	0xe000ed88

00000158 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main>:
;                 p1.outclr.write(|w| w.bits(p1_cols_to_clear));
     158:      	push	{r7, lr}
     15a:      	mov	r7, sp
     15c:      	bl	0x31e <_RNvCsajWltFTCrr0_8tutorial4init> @ imm = #0x1be
     160:      	movs	r0, #0x0
     162:      	cbnz	r0, 0x16c <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x14> @ imm = #0x6
     164:      	b	0x166 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0xe> @ imm = #-0x2
;             f(&mut REG::Writer::from(W {
     166:      	movs	r0, #0x1
     168:      	cbnz	r0, 0x182 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x2a> @ imm = #0x16
     16a:      	b	0x188 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x30> @ imm = #0x1a
     16c:      	movw	r2, #0x5af0
     170:      	movt	r2, #0x0
     174:      	movs	r0, #0x4
     176:      	movw	r1, #0x504
     17a:      	movt	r1, #0x5000
     17e:      	bl	0x4808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference> @ imm = #0x4686
     182:      	movs	r0, #0x1
;                 precondition_check($($arg,)*);
     184:      	cbnz	r0, 0x19e <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x46> @ imm = #0x16
     186:      	b	0x1a4 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x4c> @ imm = #0x1a
     188:      	movw	r2, #0x5af0
     18c:      	movt	r2, #0x0
;                 p0.outset.write(|w| w.bits(rows_to_set | p0_cols_to_set));
     190:      	movs	r0, #0x4
     192:      	movw	r1, #0x504
     196:      	movt	r1, #0x5000
     19a:      	bl	0x4808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference> @ imm = #0x466a
     19e:      	movs	r0, #0x1
     1a0:      	cbnz	r0, 0x1b0 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x58> @ imm = #0xc
     1a2:      	b	0x1c6 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x6e> @ imm = #0x20
     1a4:      	movw	r0, #0x5af0
;             f(&mut REG::Writer::from(W {
     1a8:      	movt	r0, #0x0
     1ac:      	bl	0x47e0 <_RNvNtCs6e6HQTixP8o_4core9panicking30panic_null_pointer_dereference> @ imm = #0x4630
     1b0:      	movw	r1, #0x504
     1b4:      	movt	r1, #0x5000
     1b8:      	ldr	r0, [r1]
     1ba:      	orr	r0, r0, #0x200000
     1be:      	str	r0, [r1]
     1c0:      	movs	r0, #0x1
     1c2:      	cbnz	r0, 0x1d2 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x7a> @ imm = #0xc
;                 precondition_check($($arg,)*);
     1c4:      	b	0x1d8 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x80> @ imm = #0x10
     1c6:      	movw	r0, #0x5af0
     1ca:      	movt	r0, #0x0
;     }
     1ce:      	bl	0x47e0 <_RNvNtCs6e6HQTixP8o_4core9panicking30panic_null_pointer_dereference> @ imm = #0x460e
;             let rows_to_set = 1 << pins::P0_ROWS[row];
     1d2:      	movs	r0, #0x1
     1d4:      	cbnz	r0, 0x1ee <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x96> @ imm = #0x16
     1d6:      	b	0x1f4 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x9c> @ imm = #0x1a
     1d8:      	movw	r2, #0x5b00
     1dc:      	movt	r2, #0x0
;                     | ((value.into() & Self::MASK) << { OF });
     1e0:      	movs	r0, #0x4
     1e2:      	movw	r1, #0x504
     1e6:      	movt	r1, #0x5000
     1ea:      	bl	0x4808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference> @ imm = #0x461a
     1ee:      	movs	r0, #0x1
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     1f0:      	cbnz	r0, 0x20a <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0xb2> @ imm = #0x16
     1f2:      	b	0x210 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0xb8> @ imm = #0x1a
     1f4:      	movw	r2, #0x5b00
;                                 DriveConfig::HighDrive0HighDrive1 => w.drive().h0h1(),
     1f8:      	movt	r2, #0x0
     1fc:      	movs	r0, #0x4
     1fe:      	movw	r1, #0x504
     202:      	movt	r1, #0x5000
     206:      	bl	0x4808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference> @ imm = #0x45fe
;                 unsafe { self.bits(variant.into()) }
     20a:      	movs	r0, #0x1
     20c:      	cbnz	r0, 0x21c <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0xc4> @ imm = #0xc
     20e:      	b	0x232 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0xda> @ imm = #0x20
     210:      	movw	r0, #0x5b00
     214:      	movt	r0, #0x0
     218:      	bl	0x47e0 <_RNvNtCs6e6HQTixP8o_4core9panicking30panic_null_pointer_dereference> @ imm = #0x45c4
     21c:      	movw	r1, #0x504
     220:      	movt	r1, #0x5000
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     224:      	ldr	r0, [r1]
     226:      	orr	r0, r0, #0x80000
;                     | ((value.into() & Self::MASK) << { OF });
     22a:      	str	r0, [r1]
     22c:      	movs	r0, #0x1
     22e:      	cbnz	r0, 0x23e <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0xe6> @ imm = #0xc
     230:      	b	0x244 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0xec> @ imm = #0x10
     232:      	movw	r0, #0x5b00
     236:      	movt	r0, #0x0
     23a:      	bl	0x47e0 <_RNvNtCs6e6HQTixP8o_4core9panicking30panic_null_pointer_dereference> @ imm = #0x45a2
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     23e:      	movs	r0, #0x1
     240:      	cbnz	r0, 0x25a <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x102> @ imm = #0x16
     242:      	b	0x260 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x108> @ imm = #0x1a
;                         });
     244:      	movw	r2, #0x5b10
;                 p0.pin_cnf[*ii].write(|w| w.dir().output());
     248:      	movt	r2, #0x0
;         *(PORT_P0_OUT as *mut u32) &= !(1 << 21);
     24c:      	movs	r0, #0x4
     24e:      	movw	r1, #0x504
     252:      	movt	r1, #0x5000
     256:      	bl	0x4808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference> @ imm = #0x45ae
     25a:      	movs	r0, #0x1
     25c:      	cbnz	r0, 0x276 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x11e> @ imm = #0x16
     25e:      	b	0x27c <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x124> @ imm = #0x1a
     260:      	movw	r2, #0x5b10
     264:      	movt	r2, #0x0
     268:      	movs	r0, #0x4
     26a:      	movw	r1, #0x504
     26e:      	movt	r1, #0x5000
     272:      	bl	0x4808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference> @ imm = #0x4592
     276:      	movs	r0, #0x1
     278:      	cbnz	r0, 0x288 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x130> @ imm = #0xc
     27a:      	b	0x29e <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x146> @ imm = #0x20
     27c:      	movw	r0, #0x5b10
     280:      	movt	r0, #0x0
     284:      	bl	0x47e0 <_RNvNtCs6e6HQTixP8o_4core9panicking30panic_null_pointer_dereference> @ imm = #0x4558
     288:      	movw	r1, #0x504
     28c:      	movt	r1, #0x5000
;         *(PORT_P0_OUT as *mut u32) &= !(1 << 21);
     290:      	ldr	r0, [r1]
     292:      	bic	r0, r0, #0x200000
     296:      	str	r0, [r1]
;         *(PORT_P0_OUT as *mut u32) &= !(1 << 19);
     298:      	movs	r0, #0x1
     29a:      	cbnz	r0, 0x2aa <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x152> @ imm = #0xc
     29c:      	b	0x2b0 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x158> @ imm = #0x10
;         *(PORT_P0_OUT as *mut u32) &= !(1 << 21);
     29e:      	movw	r0, #0x5b10
     2a2:      	movt	r0, #0x0
     2a6:      	bl	0x47e0 <_RNvNtCs6e6HQTixP8o_4core9panicking30panic_null_pointer_dereference> @ imm = #0x4536
;         *(PORT_P0_OUT as *mut u32) &= !(1 << 19);
     2aa:      	movs	r0, #0x1
     2ac:      	cbnz	r0, 0x2c6 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x16e> @ imm = #0x16
     2ae:      	b	0x2cc <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x174> @ imm = #0x1a
     2b0:      	movw	r2, #0x5b20
     2b4:      	movt	r2, #0x0
     2b8:      	movs	r0, #0x4
     2ba:      	movw	r1, #0x504
     2be:      	movt	r1, #0x5000
     2c2:      	bl	0x4808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference> @ imm = #0x4542
     2c6:      	movs	r0, #0x1
     2c8:      	cbnz	r0, 0x2e2 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x18a> @ imm = #0x16
     2ca:      	b	0x2e8 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x190> @ imm = #0x1a
     2cc:      	movw	r2, #0x5b20
     2d0:      	movt	r2, #0x0
     2d4:      	movs	r0, #0x4
     2d6:      	movw	r1, #0x504
     2da:      	movt	r1, #0x5000
     2de:      	bl	0x4808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference> @ imm = #0x4526
     2e2:      	movs	r0, #0x1
     2e4:      	cbnz	r0, 0x2f4 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x19c> @ imm = #0xc
     2e6:      	b	0x306 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x1ae> @ imm = #0x1c
     2e8:      	movw	r0, #0x5b20
     2ec:      	movt	r0, #0x0
     2f0:      	bl	0x47e0 <_RNvNtCs6e6HQTixP8o_4core9panicking30panic_null_pointer_dereference> @ imm = #0x44ec
     2f4:      	movw	r1, #0x504
     2f8:      	movt	r1, #0x5000
     2fc:      	ldr	r0, [r1]
     2fe:      	bic	r0, r0, #0x80000
     302:      	str	r0, [r1]
;     loop {
     304:      	b	0x312 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x1ba> @ imm = #0xa
;         *(PORT_P0_OUT as *mut u32) &= !(1 << 19);
     306:      	movw	r0, #0x5b20
     30a:      	movt	r0, #0x0
     30e:      	bl	0x47e0 <_RNvNtCs6e6HQTixP8o_4core9panicking30panic_null_pointer_dereference> @ imm = #0x44ce
;     hint(HINT_YIELD);
     312:      	yield
;         core::hint::spin_loop();
     314:      	b	0x312 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main+0x1ba> @ imm = #-0x6

00000316 <main>:
; #[entry]
     316:      	push	{r7, lr}
     318:      	mov	r7, sp
     31a:      	bl	0x158 <_RNvCs9vXgGfJJP1E_8tutorial18___cortex_m_rt_main> @ imm = #-0x1c6

0000031e <_RNvCsajWltFTCrr0_8tutorial4init>:
; pub fn init() -> (&'static p0::RegisterBlock, &'static p1::RegisterBlock) {
     31e:      	push	{r7, lr}
     320:      	mov	r7, sp
     322:      	sub	sp, #0x70
;     rtt_target::rtt_init_print!();
     324:      	bl	0x522 <_RINvCs6gRl320PnDN_16critical_section4withuNCNvCsajWltFTCrr0_8tutorial4init0EBI_> @ imm = #0x1fa
     328:      	movw	r0, #0x404
     32c:      	movt	r0, #0x2000
     330:      	cbz	r0, 0x370 <_RNvCsajWltFTCrr0_8tutorial4init+0x52> @ imm = #0x3c
     332:      	b	0x334 <_RNvCsajWltFTCrr0_8tutorial4init+0x16> @ imm = #-0x2
     334:      	movw	r0, #0x404
     338:      	movt	r0, #0x2000
     33c:      	str	r0, [sp, #0x28]
     33e:      	str	r0, [sp, #0x6c]
     340:      	str	r0, [sp, #0x44]
     342:      	movs	r1, #0x0
     344:      	strb	r1, [r7, #-37]
     348:      	movs	r2, #0x1
     34a:      	str	r2, [sp, #0x4c]
;                 zero_size: bool = T::IS_ZST || count == 0,
     34c:      	strb	r1, [r7, #-45]
;                 precondition_check($($arg,)*);
     350:      	ldrb	r2, [r7, #-45]
     354:      	movw	r3, #0x5b30
     358:      	movt	r3, #0x0
     35c:      	movs	r1, #0x4
     35e:      	bl	0x5bc <_RNvNvNtCs6e6HQTixP8o_4core3ptr11write_bytes18precondition_checkCsajWltFTCrr0_8tutorial> @ imm = #0x25a
     362:      	ldr	r0, [sp, #0x28]
;         crate::intrinsics::write_bytes(dst, val, count)
     364:      	movs	r1, #0x30
     366:      	bl	0x53ae <__aeabi_memclr4> @ imm = #0x5044
     36a:      	ldr	r0, [sp, #0x28]
;     rtt_target::rtt_init_print!();
     36c:      	cbnz	r0, 0x37c <_RNvCsajWltFTCrr0_8tutorial4init+0x5e> @ imm = #0xc
     36e:      	b	0x390 <_RNvCsajWltFTCrr0_8tutorial4init+0x72> @ imm = #0x1e
     370:      	movw	r0, #0x5b40
     374:      	movt	r0, #0x0
     378:      	bl	0x47f4 <_RNvNtCs6e6HQTixP8o_4core9panicking32panic_null_reference_constructed> @ imm = #0x4478
     37c:      	movw	r0, #0x404
     380:      	movt	r0, #0x2000
     384:      	str	r0, [sp, #0x68]
;     rtt_target::rtt_init_print!();
     386:      	mov	r1, r0
     388:      	str	r1, [sp, #0x24]
     38a:      	lsls	r0, r0, #0x1e
     38c:      	cbz	r0, 0x39c <_RNvCsajWltFTCrr0_8tutorial4init+0x7e> @ imm = #0xc
     38e:      	b	0x3a8 <_RNvCsajWltFTCrr0_8tutorial4init+0x8a> @ imm = #0x16
     390:      	movw	r0, #0x5b40
     394:      	movt	r0, #0x0
     398:      	bl	0x47f4 <_RNvNtCs6e6HQTixP8o_4core9panicking32panic_null_reference_constructed> @ imm = #0x4458
     39c:      	movw	r0, #0x404
     3a0:      	movt	r0, #0x2000
     3a4:      	cbnz	r0, 0x3b8 <_RNvCsajWltFTCrr0_8tutorial4init+0x9a> @ imm = #0x10
     3a6:      	b	0x3f6 <_RNvCsajWltFTCrr0_8tutorial4init+0xd8> @ imm = #0x4c
     3a8:      	ldr	r1, [sp, #0x24]
     3aa:      	movw	r2, #0x5b40
     3ae:      	movt	r2, #0x0
     3b2:      	movs	r0, #0x4
     3b4:      	bl	0x4808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference> @ imm = #0x4450
     3b8:      	movw	r0, #0x404
     3bc:      	movt	r0, #0x2000
     3c0:      	str	r0, [sp, #0x38]
     3c2:      	movs	r1, #0x0
     3c4:      	str	r1, [sp, #0x2c]
     3c6:      	movw	r2, #0x5858
     3ca:      	movt	r2, #0x0
     3ce:      	str	r2, [sp, #0x50]
     3d0:      	movs	r3, #0x9
     3d2:      	str	r3, [sp, #0x54]
     3d4:      	str	r2, [sp, #0x58]
     3d6:      	str	r3, [sp, #0x5c]
     3d8:      	str	r2, [sp, #0x2c]
     3da:      	str	r1, [sp, #0x30]
     3dc:      	str	r1, [sp, #0x30]
     3de:      	adds	r0, #0x18
     3e0:      	str	r0, [sp, #0x18]
     3e2:      	ldr	r0, [sp, #0x2c]
     3e4:      	str	r0, [sp, #0x1c]
     3e6:      	ldr	r0, [sp, #0x30]
     3e8:      	str	r0, [sp, #0x20]
     3ea:      	movw	r0, #0x1
     3ee:      	movt	r0, #0x2000
     3f2:      	cbnz	r0, 0x402 <_RNvCsajWltFTCrr0_8tutorial4init+0xe4> @ imm = #0xc
     3f4:      	b	0x4b2 <_RNvCsajWltFTCrr0_8tutorial4init+0x194> @ imm = #0xba
     3f6:      	movw	r0, #0x5b40
     3fa:      	movt	r0, #0x0
     3fe:      	bl	0x47f4 <_RNvNtCs6e6HQTixP8o_4core9panicking32panic_null_reference_constructed> @ imm = #0x43f2
     402:      	ldr	r2, [sp, #0x20]
     404:      	ldr	r1, [sp, #0x1c]
     406:      	ldr	r0, [sp, #0x18]
     408:      	movw	r3, #0x1
     40c:      	movt	r3, #0x2000
     410:      	str	r3, [sp, #0x64]
;     rtt_target::rtt_init_print!();
     412:      	mov	lr, sp
     414:      	mov.w	r12, #0x400
     418:      	str.w	r12, [lr]
     41c:      	bl	0x373a <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4init> @ imm = #0x331a
     420:      	movw	r0, #0x404
     424:      	movt	r0, #0x2000
     428:      	add.w	r1, r0, #0x18
     42c:      	str	r1, [sp, #0x14]
     42e:      	movs	r1, #0x1
     430:      	movs	r2, #0x0
     432:      	bl	0x3064 <_RNvMNtCs2GpT71Ckjdn_10rtt_target3rttNtB2_9RttHeader4init> @ imm = #0x2c2e
     436:      	ldr	r0, [sp, #0x14]
     438:      	bl	0x3654 <_RNvMs_Cs2GpT71Ckjdn_10rtt_targetNtB4_9UpChannel3new> @ imm = #0x3218
     43c:      	str	r0, [sp, #0x3c]
     43e:      	bl	0x3964 <_RNvNtCs2GpT71Ckjdn_10rtt_target5print17set_print_channel> @ imm = #0x3522
;     let device_periphs = pac::Peripherals::take().unwrap();
     442:      	bl	0x5b2 <_RNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtB6_11Peripherals4takeCsajWltFTCrr0_8tutorial> @ imm = #0x16c
     446:      	strb	r0, [r7, #-13]
;         match self {
     44a:      	ldrb	r0, [r7, #-13]
     44e:      	lsls	r0, r0, #0x1f
     450:      	cbnz	r0, 0x460 <_RNvCsajWltFTCrr0_8tutorial4init+0x142> @ imm = #0xc
     452:      	b	0x454 <_RNvCsajWltFTCrr0_8tutorial4init+0x136> @ imm = #-0x2
;             None => unwrap_failed(),
     454:      	movw	r0, #0x5b50
     458:      	movt	r0, #0x0
     45c:      	bl	0x476c <_RNvNtCs6e6HQTixP8o_4core6option13unwrap_failed> @ imm = #0x430c
;     let port0 = hal::gpio::p0::Parts::new(device_periphs.P0);
     460:      	bl	0x2b82 <_RNvMNtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0NtB2_5Parts3new> @ imm = #0x271e
;     let port1 = hal::gpio::p1::Parts::new(device_periphs.P1);
     464:      	bl	0x2b8c <_RNvMNtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1NtB2_5Parts3new> @ imm = #0x2724
     468:      	movs	r0, #0x0
;     let _display_pins = microbit::display_pins!(port0, port1);
     46a:      	str	r0, [sp, #0xc]
     46c:      	bl	0x21f6 <_RNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common> @ imm = #0x1d86
     470:      	ldr	r0, [sp, #0xc]
     472:      	bl	0x1f6c <_RNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common> @ imm = #0x1af6
     476:      	ldr	r0, [sp, #0xc]
     478:      	bl	0x238e <_RNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common> @ imm = #0x1f12
     47c:      	ldr	r0, [sp, #0xc]
     47e:      	bl	0x2410 <_RNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05NtB7_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common> @ imm = #0x1f8e
     482:      	ldr	r0, [sp, #0xc]
     484:      	bl	0x230c <_RNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common> @ imm = #0x1e84
     488:      	ldr	r0, [sp, #0xc]
     48a:      	bl	0x2070 <_RNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common> @ imm = #0x1be2
     48e:      	ldr	r0, [sp, #0xc]
     490:      	bl	0x20f2 <_RNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common> @ imm = #0x1c5e
     494:      	ldr	r0, [sp, #0xc]
     496:      	bl	0x1fee <_RNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common> @ imm = #0x1b54
     49a:      	ldr	r0, [sp, #0xc]
     49c:      	bl	0x2278 <_RNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common> @ imm = #0x1dd8
     4a0:      	ldr	r0, [sp, #0xc]
     4a2:      	bl	0x2174 <_RNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common> @ imm = #0x1cce
     4a6:      	mov.w	r0, #0x50000000
;     (unsafe { &*pac::P0::ptr() }, unsafe { &*pac::P1::ptr() })
     4aa:      	str	r0, [sp, #0x10]
     4ac:      	movs	r0, #0x1
     4ae:      	cbnz	r0, 0x4be <_RNvCsajWltFTCrr0_8tutorial4init+0x1a0> @ imm = #0xc
     4b0:      	b	0x4c4 <_RNvCsajWltFTCrr0_8tutorial4init+0x1a6> @ imm = #0x10
;     rtt_target::rtt_init_print!();
     4b2:      	movw	r0, #0x5b40
     4b6:      	movt	r0, #0x0
     4ba:      	bl	0x47f4 <_RNvNtCs6e6HQTixP8o_4core9panicking32panic_null_reference_constructed> @ imm = #0x4336
;     (unsafe { &*pac::P0::ptr() }, unsafe { &*pac::P1::ptr() })
     4be:      	movs	r0, #0x1
     4c0:      	cbnz	r0, 0x4d4 <_RNvCsajWltFTCrr0_8tutorial4init+0x1b6> @ imm = #0x10
     4c2:      	b	0x4e4 <_RNvCsajWltFTCrr0_8tutorial4init+0x1c6> @ imm = #0x1e
     4c4:      	ldr	r1, [sp, #0x10]
     4c6:      	movw	r2, #0x5b60
     4ca:      	movt	r2, #0x0
     4ce:      	movs	r0, #0x4
     4d0:      	bl	0x4808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference> @ imm = #0x4334
     4d4:      	movw	r0, #0x300
     4d8:      	movt	r0, #0x5000
;     (unsafe { &*pac::P0::ptr() }, unsafe { &*pac::P1::ptr() })
     4dc:      	str	r0, [sp, #0x8]
     4de:      	movs	r0, #0x1
     4e0:      	cbnz	r0, 0x4f0 <_RNvCsajWltFTCrr0_8tutorial4init+0x1d2> @ imm = #0xc
     4e2:      	b	0x4f6 <_RNvCsajWltFTCrr0_8tutorial4init+0x1d8> @ imm = #0x10
     4e4:      	movw	r0, #0x5b60
     4e8:      	movt	r0, #0x0
     4ec:      	bl	0x47f4 <_RNvNtCs6e6HQTixP8o_4core9panicking32panic_null_reference_constructed> @ imm = #0x4304
     4f0:      	movs	r0, #0x1
     4f2:      	cbnz	r0, 0x506 <_RNvCsajWltFTCrr0_8tutorial4init+0x1e8> @ imm = #0x10
     4f4:      	b	0x516 <_RNvCsajWltFTCrr0_8tutorial4init+0x1f8> @ imm = #0x1e
     4f6:      	ldr	r1, [sp, #0x8]
     4f8:      	movw	r2, #0x5b70
     4fc:      	movt	r2, #0x0
     500:      	movs	r0, #0x4
     502:      	bl	0x4808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference> @ imm = #0x4302
; }
     506:      	mov.w	r0, #0x50000000
     50a:      	movw	r1, #0x300
     50e:      	movt	r1, #0x5000
     512:      	add	sp, #0x70
     514:      	pop	{r7, pc}
;     (unsafe { &*pac::P0::ptr() }, unsafe { &*pac::P1::ptr() })
     516:      	movw	r0, #0x5b70
     51a:      	movt	r0, #0x0
     51e:      	bl	0x47f4 <_RNvNtCs6e6HQTixP8o_4core9panicking32panic_null_reference_constructed> @ imm = #0x42d2

00000522 <_RINvCs6gRl320PnDN_16critical_section4withuNCNvCsajWltFTCrr0_8tutorial4init0EBI_>:
; pub fn with<R>(f: impl FnOnce(CriticalSection) -> R) -> R {
     522:      	push	{r7, lr}
     524:      	mov	r7, sp
     526:      	sub	sp, #0x10
;     RestoreState(_critical_section_1_0_acquire())
     528:      	bl	0x2c90 <_critical_section_1_0_acquire> @ imm = #0x2764
;     let state = unsafe { acquire() };
     52c:      	str	r0, [sp, #0xc]
;     let _guard = Guard { state };
     52e:      	str	r0, [sp, #0x4]
;     unsafe { f(CriticalSection::new()) }
     530:      	bl	0x53e <_RNCNvCsajWltFTCrr0_8tutorial4init0B3_> @ imm = #0xa
     534:      	add	r0, sp, #0x4
; }
     536:      	bl	0x2ef6 <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueNtNvCs6gRl320PnDN_16critical_section4with5GuardECs2GpT71Ckjdn_10rtt_target> @ imm = #0x29bc
     53a:      	add	sp, #0x10
     53c:      	pop	{r7, pc}

0000053e <_RNCNvCsajWltFTCrr0_8tutorial4init0B3_>:
;         critical_section::with(|cs| {
     53e:      	push	{r7, lr}
     540:      	mov	r7, sp
     542:      	sub	sp, #0x8
;             if INITIALIZED.borrow(cs).get() {
     544:      	movw	r0, #0x0
     548:      	movt	r0, #0x2000
     54c:      	bl	0x584 <_RNvMNtCs6gRl320PnDN_16critical_section5mutexINtB2_5MutexINtNtCs6e6HQTixP8o_4core4cell4CellbEE6borrowCsajWltFTCrr0_8tutorial> @ imm = #0x34
     550:      	bl	0x5a4 <_RNvMs8_NtCs6e6HQTixP8o_4core4cellINtB5_4CellbE3getCsajWltFTCrr0_8tutorial> @ imm = #0x50
     554:      	cbnz	r0, 0x56e <_RNCNvCsajWltFTCrr0_8tutorial4init0B3_+0x30> @ imm = #0x16
     556:      	b	0x558 <_RNCNvCsajWltFTCrr0_8tutorial4init0B3_+0x1a> @ imm = #-0x2
;             INITIALIZED.borrow(cs).set(true);
     558:      	movw	r0, #0x0
     55c:      	movt	r0, #0x2000
     560:      	bl	0x584 <_RNvMNtCs6gRl320PnDN_16critical_section5mutexINtB2_5MutexINtNtCs6e6HQTixP8o_4core4cell4CellbEE6borrowCsajWltFTCrr0_8tutorial> @ imm = #0x20
     564:      	movs	r1, #0x1
     566:      	bl	0x592 <_RNvMs7_NtCs6e6HQTixP8o_4core4cellINtB5_4CellbE3setCsajWltFTCrr0_8tutorial> @ imm = #0x28
;         });
     56a:      	add	sp, #0x8
     56c:      	pop	{r7, pc}
;                 panic!("rtt_init! must not be called multiple times");
     56e:      	movw	r0, #0x5b80
     572:      	movt	r0, #0x0
     576:      	movw	r2, #0x5bac
     57a:      	movt	r2, #0x0
     57e:      	movs	r1, #0x2b
     580:      	bl	0x4834 <_RNvNtCs6e6HQTixP8o_4core9panicking5panic> @ imm = #0x42b0

00000584 <_RNvMNtCs6gRl320PnDN_16critical_section5mutexINtB2_5MutexINtNtCs6e6HQTixP8o_4core4cell4CellbEE6borrowCsajWltFTCrr0_8tutorial>:
;     pub fn borrow<'cs>(&'cs self, _cs: CriticalSection<'cs>) -> &'cs T {
     584:      	push	{r7, lr}
     586:      	mov	r7, sp
     588:      	sub	sp, #0xc
     58a:      	str	r0, [sp]
     58c:      	str	r0, [sp, #0x8]
;     }
     58e:      	add	sp, #0xc
     590:      	pop	{r7, pc}

00000592 <_RNvMs7_NtCs6e6HQTixP8o_4core4cellINtB5_4CellbE3setCsajWltFTCrr0_8tutorial>:
;     pub const fn set(&self, val: T)
     592:      	push	{r7, lr}
     594:      	mov	r7, sp
     596:      	sub	sp, #0x8
     598:      	str	r0, [sp]
     59a:      	strb	r1, [r7, #-1]
;         crate::intrinsics::write_via_move(dest, src);
     59e:      	strb	r1, [r0]
;     }
     5a0:      	add	sp, #0x8
     5a2:      	pop	{r7, pc}

000005a4 <_RNvMs8_NtCs6e6HQTixP8o_4core4cellINtB5_4CellbE3getCsajWltFTCrr0_8tutorial>:
;     pub const fn get(&self) -> T {
     5a4:      	push	{r7, lr}
     5a6:      	mov	r7, sp
     5a8:      	sub	sp, #0x4
     5aa:      	str	r0, [sp]
;         unsafe { *self.value.get() }
     5ac:      	ldrb	r0, [r0]
;     }
     5ae:      	add	sp, #0x4
     5b0:      	pop	{r7, pc}

000005b2 <_RNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtB6_11Peripherals4takeCsajWltFTCrr0_8tutorial>:
;     pub fn take() -> Option<Self> {
     5b2:      	push	{r7, lr}
     5b4:      	mov	r7, sp
;         cortex_m::interrupt::free(|_| {
     5b6:      	bl	0x60a <_RINvNtCs87vGccmtUh2_8cortex_m9interrupt4freeNCNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtBP_11Peripherals4take0INtNtCs6e6HQTixP8o_4core6option6OptionB1h_EECslicV2bA46s8_15microbit_common> @ imm = #0x50
;     }
     5ba:      	pop	{r7, pc}

000005bc <_RNvNvNtCs6e6HQTixP8o_4core3ptr11write_bytes18precondition_checkCsajWltFTCrr0_8tutorial>:
;             const fn precondition_check($($name:$ty),*) {
     5bc:      	push	{r7, lr}
     5be:      	mov	r7, sp
     5c0:      	sub	sp, #0x20
     5c2:      	str	r3, [sp]
     5c4:      	str	r0, [sp, #0x4]
     5c6:      	mov	r3, r2
     5c8:      	str	r3, [sp, #0x8]
     5ca:      	str	r0, [sp, #0xc]
     5cc:      	str	r1, [sp, #0x10]
     5ce:      	strb	r2, [r7, #-9]
;             ptr.is_aligned_to(align)
     5d2:      	bl	0x2b96 <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs26dZ7Vetpav_11embedded_io> @ imm = #0x25c0
;     maybe_is_aligned(ptr, align) && (is_zst || !ptr.is_null())
     5d6:      	cbnz	r0, 0x5dc <_RNvNvNtCs6e6HQTixP8o_4core3ptr11write_bytes18precondition_checkCsajWltFTCrr0_8tutorial+0x20> @ imm = #0x2
     5d8:      	b	0x5da <_RNvNvNtCs6e6HQTixP8o_4core3ptr11write_bytes18precondition_checkCsajWltFTCrr0_8tutorial+0x1e> @ imm = #-0x2
;             ) => ub_checks::maybe_is_aligned_and_not_null(addr, align, zero_size)
     5da:      	b	0x5e4 <_RNvNvNtCs6e6HQTixP8o_4core3ptr11write_bytes18precondition_checkCsajWltFTCrr0_8tutorial+0x28> @ imm = #0x6
;     maybe_is_aligned(ptr, align) && (is_zst || !ptr.is_null())
     5dc:      	ldr	r0, [sp, #0x8]
     5de:      	lsls	r0, r0, #0x1f
     5e0:      	cbnz	r0, 0x604 <_RNvNvNtCs6e6HQTixP8o_4core3ptr11write_bytes18precondition_checkCsajWltFTCrr0_8tutorial+0x48> @ imm = #0x20
     5e2:      	b	0x5fe <_RNvNvNtCs6e6HQTixP8o_4core3ptr11write_bytes18precondition_checkCsajWltFTCrr0_8tutorial+0x42> @ imm = #0x18
;                     let msg = concat!("unsafe precondition(s) violated: ", $message,
     5e4:      	ldr	r3, [sp]
     5e6:      	movw	r0, #0x5bbc
     5ea:      	movt	r0, #0x0
     5ee:      	str	r0, [sp, #0x18]
     5f0:      	movs	r1, #0xe4
     5f2:      	str	r1, [sp, #0x1c]
;                     ::core::panicking::panic_nounwind_fmt(::core::fmt::Arguments::from_str(msg), false);
     5f4:      	movw	r1, #0x1c9
     5f8:      	movs	r2, #0x0
     5fa:      	bl	0x47c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt> @ imm = #0x41c2
;             ) => ub_checks::maybe_is_aligned_and_not_null(addr, align, zero_size)
     5fe:      	ldr	r0, [sp, #0x4]
     600:      	cbnz	r0, 0x606 <_RNvNvNtCs6e6HQTixP8o_4core3ptr11write_bytes18precondition_checkCsajWltFTCrr0_8tutorial+0x4a> @ imm = #0x2
     602:      	b	0x5e4 <_RNvNvNtCs6e6HQTixP8o_4core3ptr11write_bytes18precondition_checkCsajWltFTCrr0_8tutorial+0x28> @ imm = #-0x22
     604:      	b	0x606 <_RNvNvNtCs6e6HQTixP8o_4core3ptr11write_bytes18precondition_checkCsajWltFTCrr0_8tutorial+0x4a> @ imm = #-0x2
;             }
     606:      	add	sp, #0x20
     608:      	pop	{r7, pc}

0000060a <_RINvNtCs87vGccmtUh2_8cortex_m9interrupt4freeNCNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtBP_11Peripherals4take0INtNtCs6e6HQTixP8o_4core6option6OptionB1h_EECslicV2bA46s8_15microbit_common>:
; pub fn free<F, R>(f: F) -> R
     60a:      	push	{r7, lr}
     60c:      	mov	r7, sp
     60e:      	sub	sp, #0x18
;     let primask = crate::register::primask::read_raw();
     610:      	bl	0x24e4 <_RNvNtNtCs87vGccmtUh2_8cortex_m8register7primask8read_rawCslicV2bA46s8_15microbit_common> @ imm = #0x1ed0
     614:      	str	r0, [sp, #0x4]
     616:      	str	r0, [sp, #0x10]
;     disable();
     618:      	bl	0x2492 <_RNvNtCs87vGccmtUh2_8cortex_m9interrupt7disableCslicV2bA46s8_15microbit_common> @ imm = #0x1e76
;     let r = f(&unsafe { CriticalSection::new() });
     61c:      	bl	0x2caa <_RNvMs_CsaXqxHTKDkp8_10bare_metalNtB4_15CriticalSection3new> @ imm = #0x268a
     620:      	sub.w	r0, r7, #0xa
     624:      	bl	0x1634 <_RNCNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtB8_11Peripherals4take0CslicV2bA46s8_15microbit_common> @ imm = #0x100c
     628:      	mov	r1, r0
     62a:      	ldr	r0, [sp, #0x4]
     62c:      	str	r1, [sp, #0x8]
     62e:      	strb	r1, [r7, #-1]
;         crate::register::primask::write_raw(primask);
     632:      	bl	0x24f6 <_RNvNtNtCs87vGccmtUh2_8cortex_m8register7primask9write_rawCslicV2bA46s8_15microbit_common> @ imm = #0x1ec0
     636:      	ldr	r0, [sp, #0x8]
; }
     638:      	add	sp, #0x18
     63a:      	pop	{r7, pc}

0000063c <_RNCNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_11NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common>:
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
     63c:      	push	{r7, lr}
     63e:      	mov	r7, sp
     640:      	sub	sp, #0x178
     642:      	str	r1, [sp, #0x38]
     644:      	str	r0, [sp, #0x3c]
     646:      	str	r0, [sp, #0x48]
     648:      	str	r1, [sp, #0x4c]
     64a:      	str	r1, [sp, #0x70]
     64c:      	str	r1, [sp, #0x74]
     64e:      	str	r1, [sp, #0x50]
     650:      	str	r1, [sp, #0x110]
     652:      	movs	r0, #0x1
     654:      	str	r0, [sp, #0x2c]
     656:      	strb	r0, [r7, #-97]
;                 self.bit(variant.into())
     65a:      	movw	r1, #0x5cb0
     65e:      	movt	r1, #0x0
     662:      	str	r1, [sp, #0x30]
     664:      	bl	0x254c <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf5DIR_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1ee4
     668:      	ldr	r1, [sp, #0x30]
     66a:      	ldr	r2, [sp, #0x38]
     66c:      	mov	r12, r0
     66e:      	ldr	r0, [sp, #0x2c]
     670:      	str	r2, [sp, #0x118]
     672:      	strb	r12, [r7, #-89]
     676:      	str	r2, [sp, #0x134]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
     678:      	ldr	r3, [r2]
     67a:      	bic	r3, r3, #0x1
     67e:      	strb	r12, [r7, #-37]
     682:      	str	r2, [sp, #0x158]
     684:      	add	r3, r12
     686:      	str	r3, [r2]
     688:      	str	r2, [sp, #0xa0]
     68a:      	str	r2, [sp, #0xa4]
     68c:      	str	r2, [sp, #0x54]
     68e:      	str	r2, [sp, #0x120]
     690:      	strb	r0, [r7, #-81]
;                 self.bit(variant.into())
     694:      	bl	0x2582 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7INPUT_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1eea
     698:      	ldr	r1, [sp, #0x30]
     69a:      	mov	r3, r0
     69c:      	ldr	r0, [sp, #0x38]
     69e:      	str	r0, [sp, #0x128]
     6a0:      	strb	r3, [r7, #-73]
     6a4:      	str	r0, [sp, #0x130]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
     6a6:      	ldr	r2, [r0]
     6a8:      	bic	r2, r2, #0x2
     6ac:      	strb	r3, [r7, #-38]
     6b0:      	str	r0, [sp, #0x154]
     6b2:      	orr.w	r2, r2, r3, lsl #1
     6b6:      	str	r2, [r0]
     6b8:      	str	r0, [sp, #0x78]
     6ba:      	str	r0, [sp, #0x7c]
     6bc:      	str	r0, [sp, #0x58]
     6be:      	str	r0, [sp, #0xb0]
     6c0:      	movs	r0, #0x0
     6c2:      	strb	r0, [r7, #-193]
;                 unsafe { self.bits(variant.into()) }
     6c6:      	bl	0x255e <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf6PULL_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1e94
     6ca:      	ldr	r1, [sp, #0x30]
     6cc:      	ldr	r2, [sp, #0x38]
     6ce:      	str	r2, [sp, #0xb8]
     6d0:      	strb	r0, [r7, #-185]
     6d4:      	str	r2, [sp, #0x14c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     6d6:      	ldr	r2, [r2]
     6d8:      	bic	r2, r2, #0xc
;                     | ((value.into() & Self::MASK) << { OF });
     6dc:      	str	r2, [sp, #0x34]
     6de:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x248c
     6e2:      	ldr	r1, [sp, #0x34]
     6e4:      	ldr	r2, [sp, #0x38]
     6e6:      	mov	r3, r0
     6e8:      	ldr	r0, [sp, #0x3c]
     6ea:      	and	r3, r3, #0x3
     6ee:      	str	r2, [sp, #0x170]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     6f0:      	orr.w	r1, r1, r3, lsl #2
     6f4:      	str	r1, [r2]
;                             match drive {
     6f6:      	ldrb	r0, [r0]
     6f8:      	str	r0, [sp, #0x40]
     6fa:      	ldr	r1, [sp, #0x40]
     6fc:      	tbb	[pc, r1]
     700: 03 29 4f 75  	.word	0x754f2903
     704:      	trap
     706:      	ldr	r0, [sp, #0x38]
     708:      	str	r0, [sp, #0x98]
     70a:      	str	r0, [sp, #0x9c]
     70c:      	str	r0, [sp, #0x68]
     70e:      	str	r0, [sp, #0xd0]
     710:      	movs	r0, #0x0
     712:      	strb	r0, [r7, #-161]
;                 self.bits(variant.into())
     716:      	movw	r1, #0x5cb0
     71a:      	movt	r1, #0x0
     71e:      	str	r1, [sp, #0x24]
     720:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1e4c
     724:      	ldr	r1, [sp, #0x24]
     726:      	ldr	r2, [sp, #0x38]
     728:      	str	r2, [sp, #0xd8]
     72a:      	strb	r0, [r7, #-153]
     72e:      	str	r2, [sp, #0x144]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     730:      	ldr	r2, [r2]
     732:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     736:      	str	r2, [sp, #0x28]
     738:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x2432
     73c:      	ldr	r1, [sp, #0x28]
     73e:      	mov	r2, r0
     740:      	ldr	r0, [sp, #0x38]
     742:      	and	r2, r2, #0x7
     746:      	str	r0, [sp, #0x168]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     748:      	orr.w	r1, r1, r2, lsl #8
     74c:      	str	r1, [r0]
;                                 DriveConfig::Standard0Standard1 => w.drive().s0s1(),
     74e:      	str	r0, [sp, #0x44]
     750:      	b	0x836 <_RNCNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_11NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0xe2
     752:      	ldr	r0, [sp, #0x38]
     754:      	str	r0, [sp, #0x90]
     756:      	str	r0, [sp, #0x94]
     758:      	str	r0, [sp, #0x64]
     75a:      	str	r0, [sp, #0xe0]
     75c:      	movs	r0, #0x2
     75e:      	strb	r0, [r7, #-145]
;                 self.bits(variant.into())
     762:      	movw	r1, #0x5cb0
     766:      	movt	r1, #0x0
     76a:      	str	r1, [sp, #0x1c]
     76c:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1e00
     770:      	ldr	r1, [sp, #0x1c]
     772:      	ldr	r2, [sp, #0x38]
     774:      	str	r2, [sp, #0xe8]
     776:      	strb	r0, [r7, #-137]
     77a:      	str	r2, [sp, #0x140]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     77c:      	ldr	r2, [r2]
     77e:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     782:      	str	r2, [sp, #0x20]
     784:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x23e6
     788:      	ldr	r1, [sp, #0x20]
     78a:      	mov	r2, r0
     78c:      	ldr	r0, [sp, #0x38]
     78e:      	and	r2, r2, #0x7
     792:      	str	r0, [sp, #0x164]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     794:      	orr.w	r1, r1, r2, lsl #8
     798:      	str	r1, [r0]
;                                 DriveConfig::Standard0HighDrive1 => w.drive().s0h1(),
     79a:      	str	r0, [sp, #0x44]
     79c:      	b	0x836 <_RNCNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_11NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x96
     79e:      	ldr	r0, [sp, #0x38]
     7a0:      	str	r0, [sp, #0x88]
     7a2:      	str	r0, [sp, #0x8c]
     7a4:      	str	r0, [sp, #0x60]
     7a6:      	str	r0, [sp, #0xf0]
     7a8:      	movs	r0, #0x1
     7aa:      	strb	r0, [r7, #-129]
;                 self.bits(variant.into())
     7ae:      	movw	r1, #0x5cb0
     7b2:      	movt	r1, #0x0
     7b6:      	str	r1, [sp, #0x14]
     7b8:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1db4
     7bc:      	ldr	r1, [sp, #0x14]
     7be:      	ldr	r2, [sp, #0x38]
     7c0:      	str	r2, [sp, #0xf8]
     7c2:      	strb	r0, [r7, #-121]
     7c6:      	str	r2, [sp, #0x13c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     7c8:      	ldr	r2, [r2]
     7ca:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     7ce:      	str	r2, [sp, #0x18]
     7d0:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x239a
     7d4:      	ldr	r1, [sp, #0x18]
     7d6:      	mov	r2, r0
     7d8:      	ldr	r0, [sp, #0x38]
     7da:      	and	r2, r2, #0x7
     7de:      	str	r0, [sp, #0x160]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     7e0:      	orr.w	r1, r1, r2, lsl #8
     7e4:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0Standard1 => w.drive().h0s1(),
     7e6:      	str	r0, [sp, #0x44]
     7e8:      	b	0x836 <_RNCNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_11NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x4a
     7ea:      	ldr	r0, [sp, #0x38]
     7ec:      	str	r0, [sp, #0x80]
     7ee:      	str	r0, [sp, #0x84]
     7f0:      	str	r0, [sp, #0x5c]
     7f2:      	str	r0, [sp, #0x100]
     7f4:      	movs	r0, #0x3
     7f6:      	strb	r0, [r7, #-113]
;                 self.bits(variant.into())
     7fa:      	movw	r1, #0x5cb0
     7fe:      	movt	r1, #0x0
     802:      	str	r1, [sp, #0xc]
     804:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1d68
     808:      	ldr	r1, [sp, #0xc]
     80a:      	ldr	r2, [sp, #0x38]
     80c:      	str	r2, [sp, #0x108]
     80e:      	strb	r0, [r7, #-105]
     812:      	str	r2, [sp, #0x138]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     814:      	ldr	r2, [r2]
     816:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     81a:      	str	r2, [sp, #0x10]
     81c:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x234e
     820:      	ldr	r1, [sp, #0x10]
     822:      	mov	r2, r0
     824:      	ldr	r0, [sp, #0x38]
     826:      	and	r2, r2, #0x7
     82a:      	str	r0, [sp, #0x15c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     82c:      	orr.w	r1, r1, r2, lsl #8
     830:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0HighDrive1 => w.drive().h0h1(),
     832:      	str	r0, [sp, #0x44]
     834:      	b	0x836 <_RNCNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_11NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #-0x2
     836:      	ldr	r0, [sp, #0x38]
     838:      	str	r0, [sp, #0xa8]
     83a:      	str	r0, [sp, #0xac]
     83c:      	str	r0, [sp, #0x6c]
     83e:      	str	r0, [sp, #0xc0]
     840:      	movs	r0, #0x0
     842:      	strb	r0, [r7, #-177]
;                 unsafe { self.bits(variant.into()) }
     846:      	movw	r1, #0x5cb0
     84a:      	movt	r1, #0x0
     84e:      	str	r1, [sp, #0x4]
     850:      	bl	0x2594 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7SENSE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1d40
     854:      	ldr	r1, [sp, #0x4]
     856:      	ldr	r2, [sp, #0x38]
     858:      	str	r2, [sp, #0xc8]
     85a:      	strb	r0, [r7, #-169]
     85e:      	str	r2, [sp, #0x148]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     860:      	ldr	r2, [r2]
     862:      	bic	r2, r2, #0x30000
;                     | ((value.into() & Self::MASK) << { OF });
     866:      	str	r2, [sp, #0x8]
     868:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x2302
     86c:      	ldr	r1, [sp, #0x8]
     86e:      	mov	r2, r0
     870:      	ldr	r0, [sp, #0x38]
     872:      	and	r2, r2, #0x3
     876:      	str	r0, [sp, #0x16c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     878:      	orr.w	r1, r1, r2, lsl #16
     87c:      	str	r1, [r0]
     87e:      	str	r0, [sp, #0x174]
;                         });
     880:      	add	sp, #0x178
     882:      	pop	{r7, pc}

00000884 <_RNCNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_15NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common>:
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
     884:      	push	{r7, lr}
     886:      	mov	r7, sp
     888:      	sub	sp, #0x178
     88a:      	str	r1, [sp, #0x38]
     88c:      	str	r0, [sp, #0x3c]
     88e:      	str	r0, [sp, #0x48]
     890:      	str	r1, [sp, #0x4c]
     892:      	str	r1, [sp, #0x70]
     894:      	str	r1, [sp, #0x74]
     896:      	str	r1, [sp, #0x50]
     898:      	str	r1, [sp, #0x110]
     89a:      	movs	r0, #0x1
     89c:      	str	r0, [sp, #0x2c]
     89e:      	strb	r0, [r7, #-97]
;                 self.bit(variant.into())
     8a2:      	movw	r1, #0x5cb0
     8a6:      	movt	r1, #0x0
     8aa:      	str	r1, [sp, #0x30]
     8ac:      	bl	0x254c <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf5DIR_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1c9c
     8b0:      	ldr	r1, [sp, #0x30]
     8b2:      	ldr	r2, [sp, #0x38]
     8b4:      	mov	r12, r0
     8b6:      	ldr	r0, [sp, #0x2c]
     8b8:      	str	r2, [sp, #0x118]
     8ba:      	strb	r12, [r7, #-89]
     8be:      	str	r2, [sp, #0x134]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
     8c0:      	ldr	r3, [r2]
     8c2:      	bic	r3, r3, #0x1
     8c6:      	strb	r12, [r7, #-37]
     8ca:      	str	r2, [sp, #0x158]
     8cc:      	add	r3, r12
     8ce:      	str	r3, [r2]
     8d0:      	str	r2, [sp, #0xa0]
     8d2:      	str	r2, [sp, #0xa4]
     8d4:      	str	r2, [sp, #0x54]
     8d6:      	str	r2, [sp, #0x120]
     8d8:      	strb	r0, [r7, #-81]
;                 self.bit(variant.into())
     8dc:      	bl	0x2582 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7INPUT_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1ca2
     8e0:      	ldr	r1, [sp, #0x30]
     8e2:      	mov	r3, r0
     8e4:      	ldr	r0, [sp, #0x38]
     8e6:      	str	r0, [sp, #0x128]
     8e8:      	strb	r3, [r7, #-73]
     8ec:      	str	r0, [sp, #0x130]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
     8ee:      	ldr	r2, [r0]
     8f0:      	bic	r2, r2, #0x2
     8f4:      	strb	r3, [r7, #-38]
     8f8:      	str	r0, [sp, #0x154]
     8fa:      	orr.w	r2, r2, r3, lsl #1
     8fe:      	str	r2, [r0]
     900:      	str	r0, [sp, #0x78]
     902:      	str	r0, [sp, #0x7c]
     904:      	str	r0, [sp, #0x58]
     906:      	str	r0, [sp, #0xb0]
     908:      	movs	r0, #0x0
     90a:      	strb	r0, [r7, #-193]
;                 unsafe { self.bits(variant.into()) }
     90e:      	bl	0x255e <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf6PULL_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1c4c
     912:      	ldr	r1, [sp, #0x30]
     914:      	ldr	r2, [sp, #0x38]
     916:      	str	r2, [sp, #0xb8]
     918:      	strb	r0, [r7, #-185]
     91c:      	str	r2, [sp, #0x14c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     91e:      	ldr	r2, [r2]
     920:      	bic	r2, r2, #0xc
;                     | ((value.into() & Self::MASK) << { OF });
     924:      	str	r2, [sp, #0x34]
     926:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x2244
     92a:      	ldr	r1, [sp, #0x34]
     92c:      	ldr	r2, [sp, #0x38]
     92e:      	mov	r3, r0
     930:      	ldr	r0, [sp, #0x3c]
     932:      	and	r3, r3, #0x3
     936:      	str	r2, [sp, #0x170]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     938:      	orr.w	r1, r1, r3, lsl #2
     93c:      	str	r1, [r2]
;                             match drive {
     93e:      	ldrb	r0, [r0]
     940:      	str	r0, [sp, #0x40]
     942:      	ldr	r1, [sp, #0x40]
     944:      	tbb	[pc, r1]
     948: 03 29 4f 75  	.word	0x754f2903
     94c:      	trap
     94e:      	ldr	r0, [sp, #0x38]
     950:      	str	r0, [sp, #0x98]
     952:      	str	r0, [sp, #0x9c]
     954:      	str	r0, [sp, #0x68]
     956:      	str	r0, [sp, #0xd0]
     958:      	movs	r0, #0x0
     95a:      	strb	r0, [r7, #-161]
;                 self.bits(variant.into())
     95e:      	movw	r1, #0x5cb0
     962:      	movt	r1, #0x0
     966:      	str	r1, [sp, #0x24]
     968:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1c04
     96c:      	ldr	r1, [sp, #0x24]
     96e:      	ldr	r2, [sp, #0x38]
     970:      	str	r2, [sp, #0xd8]
     972:      	strb	r0, [r7, #-153]
     976:      	str	r2, [sp, #0x144]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     978:      	ldr	r2, [r2]
     97a:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     97e:      	str	r2, [sp, #0x28]
     980:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x21ea
     984:      	ldr	r1, [sp, #0x28]
     986:      	mov	r2, r0
     988:      	ldr	r0, [sp, #0x38]
     98a:      	and	r2, r2, #0x7
     98e:      	str	r0, [sp, #0x168]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     990:      	orr.w	r1, r1, r2, lsl #8
     994:      	str	r1, [r0]
;                                 DriveConfig::Standard0Standard1 => w.drive().s0s1(),
     996:      	str	r0, [sp, #0x44]
     998:      	b	0xa7e <_RNCNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_15NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0xe2
     99a:      	ldr	r0, [sp, #0x38]
     99c:      	str	r0, [sp, #0x90]
     99e:      	str	r0, [sp, #0x94]
     9a0:      	str	r0, [sp, #0x64]
     9a2:      	str	r0, [sp, #0xe0]
     9a4:      	movs	r0, #0x2
     9a6:      	strb	r0, [r7, #-145]
;                 self.bits(variant.into())
     9aa:      	movw	r1, #0x5cb0
     9ae:      	movt	r1, #0x0
     9b2:      	str	r1, [sp, #0x1c]
     9b4:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1bb8
     9b8:      	ldr	r1, [sp, #0x1c]
     9ba:      	ldr	r2, [sp, #0x38]
     9bc:      	str	r2, [sp, #0xe8]
     9be:      	strb	r0, [r7, #-137]
     9c2:      	str	r2, [sp, #0x140]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     9c4:      	ldr	r2, [r2]
     9c6:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     9ca:      	str	r2, [sp, #0x20]
     9cc:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x219e
     9d0:      	ldr	r1, [sp, #0x20]
     9d2:      	mov	r2, r0
     9d4:      	ldr	r0, [sp, #0x38]
     9d6:      	and	r2, r2, #0x7
     9da:      	str	r0, [sp, #0x164]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     9dc:      	orr.w	r1, r1, r2, lsl #8
     9e0:      	str	r1, [r0]
;                                 DriveConfig::Standard0HighDrive1 => w.drive().s0h1(),
     9e2:      	str	r0, [sp, #0x44]
     9e4:      	b	0xa7e <_RNCNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_15NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x96
     9e6:      	ldr	r0, [sp, #0x38]
     9e8:      	str	r0, [sp, #0x88]
     9ea:      	str	r0, [sp, #0x8c]
     9ec:      	str	r0, [sp, #0x60]
     9ee:      	str	r0, [sp, #0xf0]
     9f0:      	movs	r0, #0x1
     9f2:      	strb	r0, [r7, #-129]
;                 self.bits(variant.into())
     9f6:      	movw	r1, #0x5cb0
     9fa:      	movt	r1, #0x0
     9fe:      	str	r1, [sp, #0x14]
     a00:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1b6c
     a04:      	ldr	r1, [sp, #0x14]
     a06:      	ldr	r2, [sp, #0x38]
     a08:      	str	r2, [sp, #0xf8]
     a0a:      	strb	r0, [r7, #-121]
     a0e:      	str	r2, [sp, #0x13c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     a10:      	ldr	r2, [r2]
     a12:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     a16:      	str	r2, [sp, #0x18]
     a18:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x2152
     a1c:      	ldr	r1, [sp, #0x18]
     a1e:      	mov	r2, r0
     a20:      	ldr	r0, [sp, #0x38]
     a22:      	and	r2, r2, #0x7
     a26:      	str	r0, [sp, #0x160]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     a28:      	orr.w	r1, r1, r2, lsl #8
     a2c:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0Standard1 => w.drive().h0s1(),
     a2e:      	str	r0, [sp, #0x44]
     a30:      	b	0xa7e <_RNCNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_15NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x4a
     a32:      	ldr	r0, [sp, #0x38]
     a34:      	str	r0, [sp, #0x80]
     a36:      	str	r0, [sp, #0x84]
     a38:      	str	r0, [sp, #0x5c]
     a3a:      	str	r0, [sp, #0x100]
     a3c:      	movs	r0, #0x3
     a3e:      	strb	r0, [r7, #-113]
;                 self.bits(variant.into())
     a42:      	movw	r1, #0x5cb0
     a46:      	movt	r1, #0x0
     a4a:      	str	r1, [sp, #0xc]
     a4c:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1b20
     a50:      	ldr	r1, [sp, #0xc]
     a52:      	ldr	r2, [sp, #0x38]
     a54:      	str	r2, [sp, #0x108]
     a56:      	strb	r0, [r7, #-105]
     a5a:      	str	r2, [sp, #0x138]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     a5c:      	ldr	r2, [r2]
     a5e:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     a62:      	str	r2, [sp, #0x10]
     a64:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x2106
     a68:      	ldr	r1, [sp, #0x10]
     a6a:      	mov	r2, r0
     a6c:      	ldr	r0, [sp, #0x38]
     a6e:      	and	r2, r2, #0x7
     a72:      	str	r0, [sp, #0x15c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     a74:      	orr.w	r1, r1, r2, lsl #8
     a78:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0HighDrive1 => w.drive().h0h1(),
     a7a:      	str	r0, [sp, #0x44]
     a7c:      	b	0xa7e <_RNCNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_15NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #-0x2
     a7e:      	ldr	r0, [sp, #0x38]
     a80:      	str	r0, [sp, #0xa8]
     a82:      	str	r0, [sp, #0xac]
     a84:      	str	r0, [sp, #0x6c]
     a86:      	str	r0, [sp, #0xc0]
     a88:      	movs	r0, #0x0
     a8a:      	strb	r0, [r7, #-177]
;                 unsafe { self.bits(variant.into()) }
     a8e:      	movw	r1, #0x5cb0
     a92:      	movt	r1, #0x0
     a96:      	str	r1, [sp, #0x4]
     a98:      	bl	0x2594 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7SENSE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1af8
     a9c:      	ldr	r1, [sp, #0x4]
     a9e:      	ldr	r2, [sp, #0x38]
     aa0:      	str	r2, [sp, #0xc8]
     aa2:      	strb	r0, [r7, #-169]
     aa6:      	str	r2, [sp, #0x148]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     aa8:      	ldr	r2, [r2]
     aaa:      	bic	r2, r2, #0x30000
;                     | ((value.into() & Self::MASK) << { OF });
     aae:      	str	r2, [sp, #0x8]
     ab0:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x20ba
     ab4:      	ldr	r1, [sp, #0x8]
     ab6:      	mov	r2, r0
     ab8:      	ldr	r0, [sp, #0x38]
     aba:      	and	r2, r2, #0x3
     abe:      	str	r0, [sp, #0x16c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     ac0:      	orr.w	r1, r1, r2, lsl #16
     ac4:      	str	r1, [r0]
     ac6:      	str	r0, [sp, #0x174]
;                         });
     ac8:      	add	sp, #0x178
     aca:      	pop	{r7, pc}

00000acc <_RNCNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_21NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common>:
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
     acc:      	push	{r7, lr}
     ace:      	mov	r7, sp
     ad0:      	sub	sp, #0x178
     ad2:      	str	r1, [sp, #0x38]
     ad4:      	str	r0, [sp, #0x3c]
     ad6:      	str	r0, [sp, #0x48]
     ad8:      	str	r1, [sp, #0x4c]
     ada:      	str	r1, [sp, #0x70]
     adc:      	str	r1, [sp, #0x74]
     ade:      	str	r1, [sp, #0x50]
     ae0:      	str	r1, [sp, #0x110]
     ae2:      	movs	r0, #0x1
     ae4:      	str	r0, [sp, #0x2c]
     ae6:      	strb	r0, [r7, #-97]
;                 self.bit(variant.into())
     aea:      	movw	r1, #0x5cb0
     aee:      	movt	r1, #0x0
     af2:      	str	r1, [sp, #0x30]
     af4:      	bl	0x254c <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf5DIR_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1a54
     af8:      	ldr	r1, [sp, #0x30]
     afa:      	ldr	r2, [sp, #0x38]
     afc:      	mov	r12, r0
     afe:      	ldr	r0, [sp, #0x2c]
     b00:      	str	r2, [sp, #0x118]
     b02:      	strb	r12, [r7, #-89]
     b06:      	str	r2, [sp, #0x134]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
     b08:      	ldr	r3, [r2]
     b0a:      	bic	r3, r3, #0x1
     b0e:      	strb	r12, [r7, #-37]
     b12:      	str	r2, [sp, #0x158]
     b14:      	add	r3, r12
     b16:      	str	r3, [r2]
     b18:      	str	r2, [sp, #0xa0]
     b1a:      	str	r2, [sp, #0xa4]
     b1c:      	str	r2, [sp, #0x54]
     b1e:      	str	r2, [sp, #0x120]
     b20:      	strb	r0, [r7, #-81]
;                 self.bit(variant.into())
     b24:      	bl	0x2582 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7INPUT_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1a5a
     b28:      	ldr	r1, [sp, #0x30]
     b2a:      	mov	r3, r0
     b2c:      	ldr	r0, [sp, #0x38]
     b2e:      	str	r0, [sp, #0x128]
     b30:      	strb	r3, [r7, #-73]
     b34:      	str	r0, [sp, #0x130]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
     b36:      	ldr	r2, [r0]
     b38:      	bic	r2, r2, #0x2
     b3c:      	strb	r3, [r7, #-38]
     b40:      	str	r0, [sp, #0x154]
     b42:      	orr.w	r2, r2, r3, lsl #1
     b46:      	str	r2, [r0]
     b48:      	str	r0, [sp, #0x78]
     b4a:      	str	r0, [sp, #0x7c]
     b4c:      	str	r0, [sp, #0x58]
     b4e:      	str	r0, [sp, #0xb0]
     b50:      	movs	r0, #0x0
     b52:      	strb	r0, [r7, #-193]
;                 unsafe { self.bits(variant.into()) }
     b56:      	bl	0x255e <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf6PULL_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1a04
     b5a:      	ldr	r1, [sp, #0x30]
     b5c:      	ldr	r2, [sp, #0x38]
     b5e:      	str	r2, [sp, #0xb8]
     b60:      	strb	r0, [r7, #-185]
     b64:      	str	r2, [sp, #0x14c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     b66:      	ldr	r2, [r2]
     b68:      	bic	r2, r2, #0xc
;                     | ((value.into() & Self::MASK) << { OF });
     b6c:      	str	r2, [sp, #0x34]
     b6e:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1ffc
     b72:      	ldr	r1, [sp, #0x34]
     b74:      	ldr	r2, [sp, #0x38]
     b76:      	mov	r3, r0
     b78:      	ldr	r0, [sp, #0x3c]
     b7a:      	and	r3, r3, #0x3
     b7e:      	str	r2, [sp, #0x170]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     b80:      	orr.w	r1, r1, r3, lsl #2
     b84:      	str	r1, [r2]
;                             match drive {
     b86:      	ldrb	r0, [r0]
     b88:      	str	r0, [sp, #0x40]
     b8a:      	ldr	r1, [sp, #0x40]
     b8c:      	tbb	[pc, r1]
     b90: 03 29 4f 75  	.word	0x754f2903
     b94:      	trap
     b96:      	ldr	r0, [sp, #0x38]
     b98:      	str	r0, [sp, #0x98]
     b9a:      	str	r0, [sp, #0x9c]
     b9c:      	str	r0, [sp, #0x68]
     b9e:      	str	r0, [sp, #0xd0]
     ba0:      	movs	r0, #0x0
     ba2:      	strb	r0, [r7, #-161]
;                 self.bits(variant.into())
     ba6:      	movw	r1, #0x5cb0
     baa:      	movt	r1, #0x0
     bae:      	str	r1, [sp, #0x24]
     bb0:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x19bc
     bb4:      	ldr	r1, [sp, #0x24]
     bb6:      	ldr	r2, [sp, #0x38]
     bb8:      	str	r2, [sp, #0xd8]
     bba:      	strb	r0, [r7, #-153]
     bbe:      	str	r2, [sp, #0x144]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     bc0:      	ldr	r2, [r2]
     bc2:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     bc6:      	str	r2, [sp, #0x28]
     bc8:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1fa2
     bcc:      	ldr	r1, [sp, #0x28]
     bce:      	mov	r2, r0
     bd0:      	ldr	r0, [sp, #0x38]
     bd2:      	and	r2, r2, #0x7
     bd6:      	str	r0, [sp, #0x168]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     bd8:      	orr.w	r1, r1, r2, lsl #8
     bdc:      	str	r1, [r0]
;                                 DriveConfig::Standard0Standard1 => w.drive().s0s1(),
     bde:      	str	r0, [sp, #0x44]
     be0:      	b	0xcc6 <_RNCNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_21NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0xe2
     be2:      	ldr	r0, [sp, #0x38]
     be4:      	str	r0, [sp, #0x90]
     be6:      	str	r0, [sp, #0x94]
     be8:      	str	r0, [sp, #0x64]
     bea:      	str	r0, [sp, #0xe0]
     bec:      	movs	r0, #0x2
     bee:      	strb	r0, [r7, #-145]
;                 self.bits(variant.into())
     bf2:      	movw	r1, #0x5cb0
     bf6:      	movt	r1, #0x0
     bfa:      	str	r1, [sp, #0x1c]
     bfc:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1970
     c00:      	ldr	r1, [sp, #0x1c]
     c02:      	ldr	r2, [sp, #0x38]
     c04:      	str	r2, [sp, #0xe8]
     c06:      	strb	r0, [r7, #-137]
     c0a:      	str	r2, [sp, #0x140]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     c0c:      	ldr	r2, [r2]
     c0e:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     c12:      	str	r2, [sp, #0x20]
     c14:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1f56
     c18:      	ldr	r1, [sp, #0x20]
     c1a:      	mov	r2, r0
     c1c:      	ldr	r0, [sp, #0x38]
     c1e:      	and	r2, r2, #0x7
     c22:      	str	r0, [sp, #0x164]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     c24:      	orr.w	r1, r1, r2, lsl #8
     c28:      	str	r1, [r0]
;                                 DriveConfig::Standard0HighDrive1 => w.drive().s0h1(),
     c2a:      	str	r0, [sp, #0x44]
     c2c:      	b	0xcc6 <_RNCNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_21NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x96
     c2e:      	ldr	r0, [sp, #0x38]
     c30:      	str	r0, [sp, #0x88]
     c32:      	str	r0, [sp, #0x8c]
     c34:      	str	r0, [sp, #0x60]
     c36:      	str	r0, [sp, #0xf0]
     c38:      	movs	r0, #0x1
     c3a:      	strb	r0, [r7, #-129]
;                 self.bits(variant.into())
     c3e:      	movw	r1, #0x5cb0
     c42:      	movt	r1, #0x0
     c46:      	str	r1, [sp, #0x14]
     c48:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1924
     c4c:      	ldr	r1, [sp, #0x14]
     c4e:      	ldr	r2, [sp, #0x38]
     c50:      	str	r2, [sp, #0xf8]
     c52:      	strb	r0, [r7, #-121]
     c56:      	str	r2, [sp, #0x13c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     c58:      	ldr	r2, [r2]
     c5a:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     c5e:      	str	r2, [sp, #0x18]
     c60:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1f0a
     c64:      	ldr	r1, [sp, #0x18]
     c66:      	mov	r2, r0
     c68:      	ldr	r0, [sp, #0x38]
     c6a:      	and	r2, r2, #0x7
     c6e:      	str	r0, [sp, #0x160]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     c70:      	orr.w	r1, r1, r2, lsl #8
     c74:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0Standard1 => w.drive().h0s1(),
     c76:      	str	r0, [sp, #0x44]
     c78:      	b	0xcc6 <_RNCNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_21NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x4a
     c7a:      	ldr	r0, [sp, #0x38]
     c7c:      	str	r0, [sp, #0x80]
     c7e:      	str	r0, [sp, #0x84]
     c80:      	str	r0, [sp, #0x5c]
     c82:      	str	r0, [sp, #0x100]
     c84:      	movs	r0, #0x3
     c86:      	strb	r0, [r7, #-113]
;                 self.bits(variant.into())
     c8a:      	movw	r1, #0x5cb0
     c8e:      	movt	r1, #0x0
     c92:      	str	r1, [sp, #0xc]
     c94:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x18d8
     c98:      	ldr	r1, [sp, #0xc]
     c9a:      	ldr	r2, [sp, #0x38]
     c9c:      	str	r2, [sp, #0x108]
     c9e:      	strb	r0, [r7, #-105]
     ca2:      	str	r2, [sp, #0x138]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     ca4:      	ldr	r2, [r2]
     ca6:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     caa:      	str	r2, [sp, #0x10]
     cac:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1ebe
     cb0:      	ldr	r1, [sp, #0x10]
     cb2:      	mov	r2, r0
     cb4:      	ldr	r0, [sp, #0x38]
     cb6:      	and	r2, r2, #0x7
     cba:      	str	r0, [sp, #0x15c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     cbc:      	orr.w	r1, r1, r2, lsl #8
     cc0:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0HighDrive1 => w.drive().h0h1(),
     cc2:      	str	r0, [sp, #0x44]
     cc4:      	b	0xcc6 <_RNCNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_21NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #-0x2
     cc6:      	ldr	r0, [sp, #0x38]
     cc8:      	str	r0, [sp, #0xa8]
     cca:      	str	r0, [sp, #0xac]
     ccc:      	str	r0, [sp, #0x6c]
     cce:      	str	r0, [sp, #0xc0]
     cd0:      	movs	r0, #0x0
     cd2:      	strb	r0, [r7, #-177]
;                 unsafe { self.bits(variant.into()) }
     cd6:      	movw	r1, #0x5cb0
     cda:      	movt	r1, #0x0
     cde:      	str	r1, [sp, #0x4]
     ce0:      	bl	0x2594 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7SENSE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x18b0
     ce4:      	ldr	r1, [sp, #0x4]
     ce6:      	ldr	r2, [sp, #0x38]
     ce8:      	str	r2, [sp, #0xc8]
     cea:      	strb	r0, [r7, #-169]
     cee:      	str	r2, [sp, #0x148]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     cf0:      	ldr	r2, [r2]
     cf2:      	bic	r2, r2, #0x30000
;                     | ((value.into() & Self::MASK) << { OF });
     cf6:      	str	r2, [sp, #0x8]
     cf8:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1e72
     cfc:      	ldr	r1, [sp, #0x8]
     cfe:      	mov	r2, r0
     d00:      	ldr	r0, [sp, #0x38]
     d02:      	and	r2, r2, #0x3
     d06:      	str	r0, [sp, #0x16c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     d08:      	orr.w	r1, r1, r2, lsl #16
     d0c:      	str	r1, [r0]
     d0e:      	str	r0, [sp, #0x174]
;                         });
     d10:      	add	sp, #0x178
     d12:      	pop	{r7, pc}

00000d14 <_RNCNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_22NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common>:
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
     d14:      	push	{r7, lr}
     d16:      	mov	r7, sp
     d18:      	sub	sp, #0x178
     d1a:      	str	r1, [sp, #0x38]
     d1c:      	str	r0, [sp, #0x3c]
     d1e:      	str	r0, [sp, #0x48]
     d20:      	str	r1, [sp, #0x4c]
     d22:      	str	r1, [sp, #0x70]
     d24:      	str	r1, [sp, #0x74]
     d26:      	str	r1, [sp, #0x50]
     d28:      	str	r1, [sp, #0x110]
     d2a:      	movs	r0, #0x1
     d2c:      	str	r0, [sp, #0x2c]
     d2e:      	strb	r0, [r7, #-97]
;                 self.bit(variant.into())
     d32:      	movw	r1, #0x5cb0
     d36:      	movt	r1, #0x0
     d3a:      	str	r1, [sp, #0x30]
     d3c:      	bl	0x254c <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf5DIR_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x180c
     d40:      	ldr	r1, [sp, #0x30]
     d42:      	ldr	r2, [sp, #0x38]
     d44:      	mov	r12, r0
     d46:      	ldr	r0, [sp, #0x2c]
     d48:      	str	r2, [sp, #0x118]
     d4a:      	strb	r12, [r7, #-89]
     d4e:      	str	r2, [sp, #0x134]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
     d50:      	ldr	r3, [r2]
     d52:      	bic	r3, r3, #0x1
     d56:      	strb	r12, [r7, #-37]
     d5a:      	str	r2, [sp, #0x158]
     d5c:      	add	r3, r12
     d5e:      	str	r3, [r2]
     d60:      	str	r2, [sp, #0xa0]
     d62:      	str	r2, [sp, #0xa4]
     d64:      	str	r2, [sp, #0x54]
     d66:      	str	r2, [sp, #0x120]
     d68:      	strb	r0, [r7, #-81]
;                 self.bit(variant.into())
     d6c:      	bl	0x2582 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7INPUT_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1812
     d70:      	ldr	r1, [sp, #0x30]
     d72:      	mov	r3, r0
     d74:      	ldr	r0, [sp, #0x38]
     d76:      	str	r0, [sp, #0x128]
     d78:      	strb	r3, [r7, #-73]
     d7c:      	str	r0, [sp, #0x130]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
     d7e:      	ldr	r2, [r0]
     d80:      	bic	r2, r2, #0x2
     d84:      	strb	r3, [r7, #-38]
     d88:      	str	r0, [sp, #0x154]
     d8a:      	orr.w	r2, r2, r3, lsl #1
     d8e:      	str	r2, [r0]
     d90:      	str	r0, [sp, #0x78]
     d92:      	str	r0, [sp, #0x7c]
     d94:      	str	r0, [sp, #0x58]
     d96:      	str	r0, [sp, #0xb0]
     d98:      	movs	r0, #0x0
     d9a:      	strb	r0, [r7, #-193]
;                 unsafe { self.bits(variant.into()) }
     d9e:      	bl	0x255e <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf6PULL_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x17bc
     da2:      	ldr	r1, [sp, #0x30]
     da4:      	ldr	r2, [sp, #0x38]
     da6:      	str	r2, [sp, #0xb8]
     da8:      	strb	r0, [r7, #-185]
     dac:      	str	r2, [sp, #0x14c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     dae:      	ldr	r2, [r2]
     db0:      	bic	r2, r2, #0xc
;                     | ((value.into() & Self::MASK) << { OF });
     db4:      	str	r2, [sp, #0x34]
     db6:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1db4
     dba:      	ldr	r1, [sp, #0x34]
     dbc:      	ldr	r2, [sp, #0x38]
     dbe:      	mov	r3, r0
     dc0:      	ldr	r0, [sp, #0x3c]
     dc2:      	and	r3, r3, #0x3
     dc6:      	str	r2, [sp, #0x170]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     dc8:      	orr.w	r1, r1, r3, lsl #2
     dcc:      	str	r1, [r2]
;                             match drive {
     dce:      	ldrb	r0, [r0]
     dd0:      	str	r0, [sp, #0x40]
     dd2:      	ldr	r1, [sp, #0x40]
     dd4:      	tbb	[pc, r1]
     dd8: 03 29 4f 75  	.word	0x754f2903
     ddc:      	trap
     dde:      	ldr	r0, [sp, #0x38]
     de0:      	str	r0, [sp, #0x98]
     de2:      	str	r0, [sp, #0x9c]
     de4:      	str	r0, [sp, #0x68]
     de6:      	str	r0, [sp, #0xd0]
     de8:      	movs	r0, #0x0
     dea:      	strb	r0, [r7, #-161]
;                 self.bits(variant.into())
     dee:      	movw	r1, #0x5cb0
     df2:      	movt	r1, #0x0
     df6:      	str	r1, [sp, #0x24]
     df8:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1774
     dfc:      	ldr	r1, [sp, #0x24]
     dfe:      	ldr	r2, [sp, #0x38]
     e00:      	str	r2, [sp, #0xd8]
     e02:      	strb	r0, [r7, #-153]
     e06:      	str	r2, [sp, #0x144]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     e08:      	ldr	r2, [r2]
     e0a:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     e0e:      	str	r2, [sp, #0x28]
     e10:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1d5a
     e14:      	ldr	r1, [sp, #0x28]
     e16:      	mov	r2, r0
     e18:      	ldr	r0, [sp, #0x38]
     e1a:      	and	r2, r2, #0x7
     e1e:      	str	r0, [sp, #0x168]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     e20:      	orr.w	r1, r1, r2, lsl #8
     e24:      	str	r1, [r0]
;                                 DriveConfig::Standard0Standard1 => w.drive().s0s1(),
     e26:      	str	r0, [sp, #0x44]
     e28:      	b	0xf0e <_RNCNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_22NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0xe2
     e2a:      	ldr	r0, [sp, #0x38]
     e2c:      	str	r0, [sp, #0x90]
     e2e:      	str	r0, [sp, #0x94]
     e30:      	str	r0, [sp, #0x64]
     e32:      	str	r0, [sp, #0xe0]
     e34:      	movs	r0, #0x2
     e36:      	strb	r0, [r7, #-145]
;                 self.bits(variant.into())
     e3a:      	movw	r1, #0x5cb0
     e3e:      	movt	r1, #0x0
     e42:      	str	r1, [sp, #0x1c]
     e44:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1728
     e48:      	ldr	r1, [sp, #0x1c]
     e4a:      	ldr	r2, [sp, #0x38]
     e4c:      	str	r2, [sp, #0xe8]
     e4e:      	strb	r0, [r7, #-137]
     e52:      	str	r2, [sp, #0x140]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     e54:      	ldr	r2, [r2]
     e56:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     e5a:      	str	r2, [sp, #0x20]
     e5c:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1d0e
     e60:      	ldr	r1, [sp, #0x20]
     e62:      	mov	r2, r0
     e64:      	ldr	r0, [sp, #0x38]
     e66:      	and	r2, r2, #0x7
     e6a:      	str	r0, [sp, #0x164]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     e6c:      	orr.w	r1, r1, r2, lsl #8
     e70:      	str	r1, [r0]
;                                 DriveConfig::Standard0HighDrive1 => w.drive().s0h1(),
     e72:      	str	r0, [sp, #0x44]
     e74:      	b	0xf0e <_RNCNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_22NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x96
     e76:      	ldr	r0, [sp, #0x38]
     e78:      	str	r0, [sp, #0x88]
     e7a:      	str	r0, [sp, #0x8c]
     e7c:      	str	r0, [sp, #0x60]
     e7e:      	str	r0, [sp, #0xf0]
     e80:      	movs	r0, #0x1
     e82:      	strb	r0, [r7, #-129]
;                 self.bits(variant.into())
     e86:      	movw	r1, #0x5cb0
     e8a:      	movt	r1, #0x0
     e8e:      	str	r1, [sp, #0x14]
     e90:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x16dc
     e94:      	ldr	r1, [sp, #0x14]
     e96:      	ldr	r2, [sp, #0x38]
     e98:      	str	r2, [sp, #0xf8]
     e9a:      	strb	r0, [r7, #-121]
     e9e:      	str	r2, [sp, #0x13c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     ea0:      	ldr	r2, [r2]
     ea2:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     ea6:      	str	r2, [sp, #0x18]
     ea8:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1cc2
     eac:      	ldr	r1, [sp, #0x18]
     eae:      	mov	r2, r0
     eb0:      	ldr	r0, [sp, #0x38]
     eb2:      	and	r2, r2, #0x7
     eb6:      	str	r0, [sp, #0x160]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     eb8:      	orr.w	r1, r1, r2, lsl #8
     ebc:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0Standard1 => w.drive().h0s1(),
     ebe:      	str	r0, [sp, #0x44]
     ec0:      	b	0xf0e <_RNCNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_22NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x4a
     ec2:      	ldr	r0, [sp, #0x38]
     ec4:      	str	r0, [sp, #0x80]
     ec6:      	str	r0, [sp, #0x84]
     ec8:      	str	r0, [sp, #0x5c]
     eca:      	str	r0, [sp, #0x100]
     ecc:      	movs	r0, #0x3
     ece:      	strb	r0, [r7, #-113]
;                 self.bits(variant.into())
     ed2:      	movw	r1, #0x5cb0
     ed6:      	movt	r1, #0x0
     eda:      	str	r1, [sp, #0xc]
     edc:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1690
     ee0:      	ldr	r1, [sp, #0xc]
     ee2:      	ldr	r2, [sp, #0x38]
     ee4:      	str	r2, [sp, #0x108]
     ee6:      	strb	r0, [r7, #-105]
     eea:      	str	r2, [sp, #0x138]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     eec:      	ldr	r2, [r2]
     eee:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
     ef2:      	str	r2, [sp, #0x10]
     ef4:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1c76
     ef8:      	ldr	r1, [sp, #0x10]
     efa:      	mov	r2, r0
     efc:      	ldr	r0, [sp, #0x38]
     efe:      	and	r2, r2, #0x7
     f02:      	str	r0, [sp, #0x15c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     f04:      	orr.w	r1, r1, r2, lsl #8
     f08:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0HighDrive1 => w.drive().h0h1(),
     f0a:      	str	r0, [sp, #0x44]
     f0c:      	b	0xf0e <_RNCNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_22NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #-0x2
     f0e:      	ldr	r0, [sp, #0x38]
     f10:      	str	r0, [sp, #0xa8]
     f12:      	str	r0, [sp, #0xac]
     f14:      	str	r0, [sp, #0x6c]
     f16:      	str	r0, [sp, #0xc0]
     f18:      	movs	r0, #0x0
     f1a:      	strb	r0, [r7, #-177]
;                 unsafe { self.bits(variant.into()) }
     f1e:      	movw	r1, #0x5cb0
     f22:      	movt	r1, #0x0
     f26:      	str	r1, [sp, #0x4]
     f28:      	bl	0x2594 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7SENSE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1668
     f2c:      	ldr	r1, [sp, #0x4]
     f2e:      	ldr	r2, [sp, #0x38]
     f30:      	str	r2, [sp, #0xc8]
     f32:      	strb	r0, [r7, #-169]
     f36:      	str	r2, [sp, #0x148]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     f38:      	ldr	r2, [r2]
     f3a:      	bic	r2, r2, #0x30000
;                     | ((value.into() & Self::MASK) << { OF });
     f3e:      	str	r2, [sp, #0x8]
     f40:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1c2a
     f44:      	ldr	r1, [sp, #0x8]
     f46:      	mov	r2, r0
     f48:      	ldr	r0, [sp, #0x38]
     f4a:      	and	r2, r2, #0x3
     f4e:      	str	r0, [sp, #0x16c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     f50:      	orr.w	r1, r1, r2, lsl #16
     f54:      	str	r1, [r0]
     f56:      	str	r0, [sp, #0x174]
;                         });
     f58:      	add	sp, #0x178
     f5a:      	pop	{r7, pc}

00000f5c <_RNCNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_19NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common>:
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
     f5c:      	push	{r7, lr}
     f5e:      	mov	r7, sp
     f60:      	sub	sp, #0x178
     f62:      	str	r1, [sp, #0x38]
     f64:      	str	r0, [sp, #0x3c]
     f66:      	str	r0, [sp, #0x48]
     f68:      	str	r1, [sp, #0x4c]
     f6a:      	str	r1, [sp, #0x70]
     f6c:      	str	r1, [sp, #0x74]
     f6e:      	str	r1, [sp, #0x50]
     f70:      	str	r1, [sp, #0x110]
     f72:      	movs	r0, #0x1
     f74:      	str	r0, [sp, #0x2c]
     f76:      	strb	r0, [r7, #-97]
;                 self.bit(variant.into())
     f7a:      	movw	r1, #0x5cb0
     f7e:      	movt	r1, #0x0
     f82:      	str	r1, [sp, #0x30]
     f84:      	bl	0x254c <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf5DIR_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x15c4
     f88:      	ldr	r1, [sp, #0x30]
     f8a:      	ldr	r2, [sp, #0x38]
     f8c:      	mov	r12, r0
     f8e:      	ldr	r0, [sp, #0x2c]
     f90:      	str	r2, [sp, #0x118]
     f92:      	strb	r12, [r7, #-89]
     f96:      	str	r2, [sp, #0x134]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
     f98:      	ldr	r3, [r2]
     f9a:      	bic	r3, r3, #0x1
     f9e:      	strb	r12, [r7, #-37]
     fa2:      	str	r2, [sp, #0x158]
     fa4:      	add	r3, r12
     fa6:      	str	r3, [r2]
     fa8:      	str	r2, [sp, #0xa0]
     faa:      	str	r2, [sp, #0xa4]
     fac:      	str	r2, [sp, #0x54]
     fae:      	str	r2, [sp, #0x120]
     fb0:      	strb	r0, [r7, #-81]
;                 self.bit(variant.into())
     fb4:      	bl	0x2582 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7INPUT_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x15ca
     fb8:      	ldr	r1, [sp, #0x30]
     fba:      	mov	r3, r0
     fbc:      	ldr	r0, [sp, #0x38]
     fbe:      	str	r0, [sp, #0x128]
     fc0:      	strb	r3, [r7, #-73]
     fc4:      	str	r0, [sp, #0x130]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
     fc6:      	ldr	r2, [r0]
     fc8:      	bic	r2, r2, #0x2
     fcc:      	strb	r3, [r7, #-38]
     fd0:      	str	r0, [sp, #0x154]
     fd2:      	orr.w	r2, r2, r3, lsl #1
     fd6:      	str	r2, [r0]
     fd8:      	str	r0, [sp, #0x78]
     fda:      	str	r0, [sp, #0x7c]
     fdc:      	str	r0, [sp, #0x58]
     fde:      	str	r0, [sp, #0xb0]
     fe0:      	movs	r0, #0x0
     fe2:      	strb	r0, [r7, #-193]
;                 unsafe { self.bits(variant.into()) }
     fe6:      	bl	0x255e <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf6PULL_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1574
     fea:      	ldr	r1, [sp, #0x30]
     fec:      	ldr	r2, [sp, #0x38]
     fee:      	str	r2, [sp, #0xb8]
     ff0:      	strb	r0, [r7, #-185]
     ff4:      	str	r2, [sp, #0x14c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
     ff6:      	ldr	r2, [r2]
     ff8:      	bic	r2, r2, #0xc
;                     | ((value.into() & Self::MASK) << { OF });
     ffc:      	str	r2, [sp, #0x34]
     ffe:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1b6c
    1002:      	ldr	r1, [sp, #0x34]
    1004:      	ldr	r2, [sp, #0x38]
    1006:      	mov	r3, r0
    1008:      	ldr	r0, [sp, #0x3c]
    100a:      	and	r3, r3, #0x3
    100e:      	str	r2, [sp, #0x170]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1010:      	orr.w	r1, r1, r3, lsl #2
    1014:      	str	r1, [r2]
;                             match drive {
    1016:      	ldrb	r0, [r0]
    1018:      	str	r0, [sp, #0x40]
    101a:      	ldr	r1, [sp, #0x40]
    101c:      	tbb	[pc, r1]
    1020: 03 29 4f 75  	.word	0x754f2903
    1024:      	trap
    1026:      	ldr	r0, [sp, #0x38]
    1028:      	str	r0, [sp, #0x98]
    102a:      	str	r0, [sp, #0x9c]
    102c:      	str	r0, [sp, #0x68]
    102e:      	str	r0, [sp, #0xd0]
    1030:      	movs	r0, #0x0
    1032:      	strb	r0, [r7, #-161]
;                 self.bits(variant.into())
    1036:      	movw	r1, #0x5cb0
    103a:      	movt	r1, #0x0
    103e:      	str	r1, [sp, #0x24]
    1040:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x152c
    1044:      	ldr	r1, [sp, #0x24]
    1046:      	ldr	r2, [sp, #0x38]
    1048:      	str	r2, [sp, #0xd8]
    104a:      	strb	r0, [r7, #-153]
    104e:      	str	r2, [sp, #0x144]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1050:      	ldr	r2, [r2]
    1052:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1056:      	str	r2, [sp, #0x28]
    1058:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1b12
    105c:      	ldr	r1, [sp, #0x28]
    105e:      	mov	r2, r0
    1060:      	ldr	r0, [sp, #0x38]
    1062:      	and	r2, r2, #0x7
    1066:      	str	r0, [sp, #0x168]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1068:      	orr.w	r1, r1, r2, lsl #8
    106c:      	str	r1, [r0]
;                                 DriveConfig::Standard0Standard1 => w.drive().s0s1(),
    106e:      	str	r0, [sp, #0x44]
    1070:      	b	0x1156 <_RNCNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_19NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0xe2
    1072:      	ldr	r0, [sp, #0x38]
    1074:      	str	r0, [sp, #0x90]
    1076:      	str	r0, [sp, #0x94]
    1078:      	str	r0, [sp, #0x64]
    107a:      	str	r0, [sp, #0xe0]
    107c:      	movs	r0, #0x2
    107e:      	strb	r0, [r7, #-145]
;                 self.bits(variant.into())
    1082:      	movw	r1, #0x5cb0
    1086:      	movt	r1, #0x0
    108a:      	str	r1, [sp, #0x1c]
    108c:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x14e0
    1090:      	ldr	r1, [sp, #0x1c]
    1092:      	ldr	r2, [sp, #0x38]
    1094:      	str	r2, [sp, #0xe8]
    1096:      	strb	r0, [r7, #-137]
    109a:      	str	r2, [sp, #0x140]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    109c:      	ldr	r2, [r2]
    109e:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    10a2:      	str	r2, [sp, #0x20]
    10a4:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1ac6
    10a8:      	ldr	r1, [sp, #0x20]
    10aa:      	mov	r2, r0
    10ac:      	ldr	r0, [sp, #0x38]
    10ae:      	and	r2, r2, #0x7
    10b2:      	str	r0, [sp, #0x164]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    10b4:      	orr.w	r1, r1, r2, lsl #8
    10b8:      	str	r1, [r0]
;                                 DriveConfig::Standard0HighDrive1 => w.drive().s0h1(),
    10ba:      	str	r0, [sp, #0x44]
    10bc:      	b	0x1156 <_RNCNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_19NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x96
    10be:      	ldr	r0, [sp, #0x38]
    10c0:      	str	r0, [sp, #0x88]
    10c2:      	str	r0, [sp, #0x8c]
    10c4:      	str	r0, [sp, #0x60]
    10c6:      	str	r0, [sp, #0xf0]
    10c8:      	movs	r0, #0x1
    10ca:      	strb	r0, [r7, #-129]
;                 self.bits(variant.into())
    10ce:      	movw	r1, #0x5cb0
    10d2:      	movt	r1, #0x0
    10d6:      	str	r1, [sp, #0x14]
    10d8:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1494
    10dc:      	ldr	r1, [sp, #0x14]
    10de:      	ldr	r2, [sp, #0x38]
    10e0:      	str	r2, [sp, #0xf8]
    10e2:      	strb	r0, [r7, #-121]
    10e6:      	str	r2, [sp, #0x13c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    10e8:      	ldr	r2, [r2]
    10ea:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    10ee:      	str	r2, [sp, #0x18]
    10f0:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1a7a
    10f4:      	ldr	r1, [sp, #0x18]
    10f6:      	mov	r2, r0
    10f8:      	ldr	r0, [sp, #0x38]
    10fa:      	and	r2, r2, #0x7
    10fe:      	str	r0, [sp, #0x160]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1100:      	orr.w	r1, r1, r2, lsl #8
    1104:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0Standard1 => w.drive().h0s1(),
    1106:      	str	r0, [sp, #0x44]
    1108:      	b	0x1156 <_RNCNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_19NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x4a
    110a:      	ldr	r0, [sp, #0x38]
    110c:      	str	r0, [sp, #0x80]
    110e:      	str	r0, [sp, #0x84]
    1110:      	str	r0, [sp, #0x5c]
    1112:      	str	r0, [sp, #0x100]
    1114:      	movs	r0, #0x3
    1116:      	strb	r0, [r7, #-113]
;                 self.bits(variant.into())
    111a:      	movw	r1, #0x5cb0
    111e:      	movt	r1, #0x0
    1122:      	str	r1, [sp, #0xc]
    1124:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1448
    1128:      	ldr	r1, [sp, #0xc]
    112a:      	ldr	r2, [sp, #0x38]
    112c:      	str	r2, [sp, #0x108]
    112e:      	strb	r0, [r7, #-105]
    1132:      	str	r2, [sp, #0x138]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1134:      	ldr	r2, [r2]
    1136:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    113a:      	str	r2, [sp, #0x10]
    113c:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1a2e
    1140:      	ldr	r1, [sp, #0x10]
    1142:      	mov	r2, r0
    1144:      	ldr	r0, [sp, #0x38]
    1146:      	and	r2, r2, #0x7
    114a:      	str	r0, [sp, #0x15c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    114c:      	orr.w	r1, r1, r2, lsl #8
    1150:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0HighDrive1 => w.drive().h0h1(),
    1152:      	str	r0, [sp, #0x44]
    1154:      	b	0x1156 <_RNCNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_19NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #-0x2
    1156:      	ldr	r0, [sp, #0x38]
    1158:      	str	r0, [sp, #0xa8]
    115a:      	str	r0, [sp, #0xac]
    115c:      	str	r0, [sp, #0x6c]
    115e:      	str	r0, [sp, #0xc0]
    1160:      	movs	r0, #0x0
    1162:      	strb	r0, [r7, #-177]
;                 unsafe { self.bits(variant.into()) }
    1166:      	movw	r1, #0x5cb0
    116a:      	movt	r1, #0x0
    116e:      	str	r1, [sp, #0x4]
    1170:      	bl	0x2594 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7SENSE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1420
    1174:      	ldr	r1, [sp, #0x4]
    1176:      	ldr	r2, [sp, #0x38]
    1178:      	str	r2, [sp, #0xc8]
    117a:      	strb	r0, [r7, #-169]
    117e:      	str	r2, [sp, #0x148]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1180:      	ldr	r2, [r2]
    1182:      	bic	r2, r2, #0x30000
;                     | ((value.into() & Self::MASK) << { OF });
    1186:      	str	r2, [sp, #0x8]
    1188:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x19e2
    118c:      	ldr	r1, [sp, #0x8]
    118e:      	mov	r2, r0
    1190:      	ldr	r0, [sp, #0x38]
    1192:      	and	r2, r2, #0x3
    1196:      	str	r0, [sp, #0x16c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1198:      	orr.w	r1, r1, r2, lsl #16
    119c:      	str	r1, [r0]
    119e:      	str	r0, [sp, #0x174]
;                         });
    11a0:      	add	sp, #0x178
    11a2:      	pop	{r7, pc}

000011a4 <_RNCNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_28NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common>:
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    11a4:      	push	{r7, lr}
    11a6:      	mov	r7, sp
    11a8:      	sub	sp, #0x178
    11aa:      	str	r1, [sp, #0x38]
    11ac:      	str	r0, [sp, #0x3c]
    11ae:      	str	r0, [sp, #0x48]
    11b0:      	str	r1, [sp, #0x4c]
    11b2:      	str	r1, [sp, #0x70]
    11b4:      	str	r1, [sp, #0x74]
    11b6:      	str	r1, [sp, #0x50]
    11b8:      	str	r1, [sp, #0x110]
    11ba:      	movs	r0, #0x1
    11bc:      	str	r0, [sp, #0x2c]
    11be:      	strb	r0, [r7, #-97]
;                 self.bit(variant.into())
    11c2:      	movw	r1, #0x5cb0
    11c6:      	movt	r1, #0x0
    11ca:      	str	r1, [sp, #0x30]
    11cc:      	bl	0x254c <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf5DIR_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x137c
    11d0:      	ldr	r1, [sp, #0x30]
    11d2:      	ldr	r2, [sp, #0x38]
    11d4:      	mov	r12, r0
    11d6:      	ldr	r0, [sp, #0x2c]
    11d8:      	str	r2, [sp, #0x118]
    11da:      	strb	r12, [r7, #-89]
    11de:      	str	r2, [sp, #0x134]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
    11e0:      	ldr	r3, [r2]
    11e2:      	bic	r3, r3, #0x1
    11e6:      	strb	r12, [r7, #-37]
    11ea:      	str	r2, [sp, #0x158]
    11ec:      	add	r3, r12
    11ee:      	str	r3, [r2]
    11f0:      	str	r2, [sp, #0xa0]
    11f2:      	str	r2, [sp, #0xa4]
    11f4:      	str	r2, [sp, #0x54]
    11f6:      	str	r2, [sp, #0x120]
    11f8:      	strb	r0, [r7, #-81]
;                 self.bit(variant.into())
    11fc:      	bl	0x2582 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7INPUT_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1382
    1200:      	ldr	r1, [sp, #0x30]
    1202:      	mov	r3, r0
    1204:      	ldr	r0, [sp, #0x38]
    1206:      	str	r0, [sp, #0x128]
    1208:      	strb	r3, [r7, #-73]
    120c:      	str	r0, [sp, #0x130]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
    120e:      	ldr	r2, [r0]
    1210:      	bic	r2, r2, #0x2
    1214:      	strb	r3, [r7, #-38]
    1218:      	str	r0, [sp, #0x154]
    121a:      	orr.w	r2, r2, r3, lsl #1
    121e:      	str	r2, [r0]
    1220:      	str	r0, [sp, #0x78]
    1222:      	str	r0, [sp, #0x7c]
    1224:      	str	r0, [sp, #0x58]
    1226:      	str	r0, [sp, #0xb0]
    1228:      	movs	r0, #0x0
    122a:      	strb	r0, [r7, #-193]
;                 unsafe { self.bits(variant.into()) }
    122e:      	bl	0x255e <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf6PULL_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x132c
    1232:      	ldr	r1, [sp, #0x30]
    1234:      	ldr	r2, [sp, #0x38]
    1236:      	str	r2, [sp, #0xb8]
    1238:      	strb	r0, [r7, #-185]
    123c:      	str	r2, [sp, #0x14c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    123e:      	ldr	r2, [r2]
    1240:      	bic	r2, r2, #0xc
;                     | ((value.into() & Self::MASK) << { OF });
    1244:      	str	r2, [sp, #0x34]
    1246:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1924
    124a:      	ldr	r1, [sp, #0x34]
    124c:      	ldr	r2, [sp, #0x38]
    124e:      	mov	r3, r0
    1250:      	ldr	r0, [sp, #0x3c]
    1252:      	and	r3, r3, #0x3
    1256:      	str	r2, [sp, #0x170]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1258:      	orr.w	r1, r1, r3, lsl #2
    125c:      	str	r1, [r2]
;                             match drive {
    125e:      	ldrb	r0, [r0]
    1260:      	str	r0, [sp, #0x40]
    1262:      	ldr	r1, [sp, #0x40]
    1264:      	tbb	[pc, r1]
    1268: 03 29 4f 75  	.word	0x754f2903
    126c:      	trap
    126e:      	ldr	r0, [sp, #0x38]
    1270:      	str	r0, [sp, #0x98]
    1272:      	str	r0, [sp, #0x9c]
    1274:      	str	r0, [sp, #0x68]
    1276:      	str	r0, [sp, #0xd0]
    1278:      	movs	r0, #0x0
    127a:      	strb	r0, [r7, #-161]
;                 self.bits(variant.into())
    127e:      	movw	r1, #0x5cb0
    1282:      	movt	r1, #0x0
    1286:      	str	r1, [sp, #0x24]
    1288:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x12e4
    128c:      	ldr	r1, [sp, #0x24]
    128e:      	ldr	r2, [sp, #0x38]
    1290:      	str	r2, [sp, #0xd8]
    1292:      	strb	r0, [r7, #-153]
    1296:      	str	r2, [sp, #0x144]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1298:      	ldr	r2, [r2]
    129a:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    129e:      	str	r2, [sp, #0x28]
    12a0:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x18ca
    12a4:      	ldr	r1, [sp, #0x28]
    12a6:      	mov	r2, r0
    12a8:      	ldr	r0, [sp, #0x38]
    12aa:      	and	r2, r2, #0x7
    12ae:      	str	r0, [sp, #0x168]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    12b0:      	orr.w	r1, r1, r2, lsl #8
    12b4:      	str	r1, [r0]
;                                 DriveConfig::Standard0Standard1 => w.drive().s0s1(),
    12b6:      	str	r0, [sp, #0x44]
    12b8:      	b	0x139e <_RNCNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_28NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0xe2
    12ba:      	ldr	r0, [sp, #0x38]
    12bc:      	str	r0, [sp, #0x90]
    12be:      	str	r0, [sp, #0x94]
    12c0:      	str	r0, [sp, #0x64]
    12c2:      	str	r0, [sp, #0xe0]
    12c4:      	movs	r0, #0x2
    12c6:      	strb	r0, [r7, #-145]
;                 self.bits(variant.into())
    12ca:      	movw	r1, #0x5cb0
    12ce:      	movt	r1, #0x0
    12d2:      	str	r1, [sp, #0x1c]
    12d4:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1298
    12d8:      	ldr	r1, [sp, #0x1c]
    12da:      	ldr	r2, [sp, #0x38]
    12dc:      	str	r2, [sp, #0xe8]
    12de:      	strb	r0, [r7, #-137]
    12e2:      	str	r2, [sp, #0x140]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    12e4:      	ldr	r2, [r2]
    12e6:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    12ea:      	str	r2, [sp, #0x20]
    12ec:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x187e
    12f0:      	ldr	r1, [sp, #0x20]
    12f2:      	mov	r2, r0
    12f4:      	ldr	r0, [sp, #0x38]
    12f6:      	and	r2, r2, #0x7
    12fa:      	str	r0, [sp, #0x164]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    12fc:      	orr.w	r1, r1, r2, lsl #8
    1300:      	str	r1, [r0]
;                                 DriveConfig::Standard0HighDrive1 => w.drive().s0h1(),
    1302:      	str	r0, [sp, #0x44]
    1304:      	b	0x139e <_RNCNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_28NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x96
    1306:      	ldr	r0, [sp, #0x38]
    1308:      	str	r0, [sp, #0x88]
    130a:      	str	r0, [sp, #0x8c]
    130c:      	str	r0, [sp, #0x60]
    130e:      	str	r0, [sp, #0xf0]
    1310:      	movs	r0, #0x1
    1312:      	strb	r0, [r7, #-129]
;                 self.bits(variant.into())
    1316:      	movw	r1, #0x5cb0
    131a:      	movt	r1, #0x0
    131e:      	str	r1, [sp, #0x14]
    1320:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x124c
    1324:      	ldr	r1, [sp, #0x14]
    1326:      	ldr	r2, [sp, #0x38]
    1328:      	str	r2, [sp, #0xf8]
    132a:      	strb	r0, [r7, #-121]
    132e:      	str	r2, [sp, #0x13c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1330:      	ldr	r2, [r2]
    1332:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1336:      	str	r2, [sp, #0x18]
    1338:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1832
    133c:      	ldr	r1, [sp, #0x18]
    133e:      	mov	r2, r0
    1340:      	ldr	r0, [sp, #0x38]
    1342:      	and	r2, r2, #0x7
    1346:      	str	r0, [sp, #0x160]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1348:      	orr.w	r1, r1, r2, lsl #8
    134c:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0Standard1 => w.drive().h0s1(),
    134e:      	str	r0, [sp, #0x44]
    1350:      	b	0x139e <_RNCNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_28NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x4a
    1352:      	ldr	r0, [sp, #0x38]
    1354:      	str	r0, [sp, #0x80]
    1356:      	str	r0, [sp, #0x84]
    1358:      	str	r0, [sp, #0x5c]
    135a:      	str	r0, [sp, #0x100]
    135c:      	movs	r0, #0x3
    135e:      	strb	r0, [r7, #-113]
;                 self.bits(variant.into())
    1362:      	movw	r1, #0x5cb0
    1366:      	movt	r1, #0x0
    136a:      	str	r1, [sp, #0xc]
    136c:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1200
    1370:      	ldr	r1, [sp, #0xc]
    1372:      	ldr	r2, [sp, #0x38]
    1374:      	str	r2, [sp, #0x108]
    1376:      	strb	r0, [r7, #-105]
    137a:      	str	r2, [sp, #0x138]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    137c:      	ldr	r2, [r2]
    137e:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1382:      	str	r2, [sp, #0x10]
    1384:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x17e6
    1388:      	ldr	r1, [sp, #0x10]
    138a:      	mov	r2, r0
    138c:      	ldr	r0, [sp, #0x38]
    138e:      	and	r2, r2, #0x7
    1392:      	str	r0, [sp, #0x15c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1394:      	orr.w	r1, r1, r2, lsl #8
    1398:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0HighDrive1 => w.drive().h0h1(),
    139a:      	str	r0, [sp, #0x44]
    139c:      	b	0x139e <_RNCNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_28NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #-0x2
    139e:      	ldr	r0, [sp, #0x38]
    13a0:      	str	r0, [sp, #0xa8]
    13a2:      	str	r0, [sp, #0xac]
    13a4:      	str	r0, [sp, #0x6c]
    13a6:      	str	r0, [sp, #0xc0]
    13a8:      	movs	r0, #0x0
    13aa:      	strb	r0, [r7, #-177]
;                 unsafe { self.bits(variant.into()) }
    13ae:      	movw	r1, #0x5cb0
    13b2:      	movt	r1, #0x0
    13b6:      	str	r1, [sp, #0x4]
    13b8:      	bl	0x2594 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7SENSE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x11d8
    13bc:      	ldr	r1, [sp, #0x4]
    13be:      	ldr	r2, [sp, #0x38]
    13c0:      	str	r2, [sp, #0xc8]
    13c2:      	strb	r0, [r7, #-169]
    13c6:      	str	r2, [sp, #0x148]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    13c8:      	ldr	r2, [r2]
    13ca:      	bic	r2, r2, #0x30000
;                     | ((value.into() & Self::MASK) << { OF });
    13ce:      	str	r2, [sp, #0x8]
    13d0:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x179a
    13d4:      	ldr	r1, [sp, #0x8]
    13d6:      	mov	r2, r0
    13d8:      	ldr	r0, [sp, #0x38]
    13da:      	and	r2, r2, #0x3
    13de:      	str	r0, [sp, #0x16c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    13e0:      	orr.w	r1, r1, r2, lsl #16
    13e4:      	str	r1, [r0]
    13e6:      	str	r0, [sp, #0x174]
;                         });
    13e8:      	add	sp, #0x178
    13ea:      	pop	{r7, pc}

000013ec <_RNCNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_24NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common>:
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    13ec:      	push	{r7, lr}
    13ee:      	mov	r7, sp
    13f0:      	sub	sp, #0x178
    13f2:      	str	r1, [sp, #0x38]
    13f4:      	str	r0, [sp, #0x3c]
    13f6:      	str	r0, [sp, #0x48]
    13f8:      	str	r1, [sp, #0x4c]
    13fa:      	str	r1, [sp, #0x70]
    13fc:      	str	r1, [sp, #0x74]
    13fe:      	str	r1, [sp, #0x50]
    1400:      	str	r1, [sp, #0x110]
    1402:      	movs	r0, #0x1
    1404:      	str	r0, [sp, #0x2c]
    1406:      	strb	r0, [r7, #-97]
;                 self.bit(variant.into())
    140a:      	movw	r1, #0x5cb0
    140e:      	movt	r1, #0x0
    1412:      	str	r1, [sp, #0x30]
    1414:      	bl	0x254c <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf5DIR_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1134
    1418:      	ldr	r1, [sp, #0x30]
    141a:      	ldr	r2, [sp, #0x38]
    141c:      	mov	r12, r0
    141e:      	ldr	r0, [sp, #0x2c]
    1420:      	str	r2, [sp, #0x118]
    1422:      	strb	r12, [r7, #-89]
    1426:      	str	r2, [sp, #0x134]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
    1428:      	ldr	r3, [r2]
    142a:      	bic	r3, r3, #0x1
    142e:      	strb	r12, [r7, #-37]
    1432:      	str	r2, [sp, #0x158]
    1434:      	add	r3, r12
    1436:      	str	r3, [r2]
    1438:      	str	r2, [sp, #0xa0]
    143a:      	str	r2, [sp, #0xa4]
    143c:      	str	r2, [sp, #0x54]
    143e:      	str	r2, [sp, #0x120]
    1440:      	strb	r0, [r7, #-81]
;                 self.bit(variant.into())
    1444:      	bl	0x2582 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7INPUT_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x113a
    1448:      	ldr	r1, [sp, #0x30]
    144a:      	mov	r3, r0
    144c:      	ldr	r0, [sp, #0x38]
    144e:      	str	r0, [sp, #0x128]
    1450:      	strb	r3, [r7, #-73]
    1454:      	str	r0, [sp, #0x130]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
    1456:      	ldr	r2, [r0]
    1458:      	bic	r2, r2, #0x2
    145c:      	strb	r3, [r7, #-38]
    1460:      	str	r0, [sp, #0x154]
    1462:      	orr.w	r2, r2, r3, lsl #1
    1466:      	str	r2, [r0]
    1468:      	str	r0, [sp, #0x78]
    146a:      	str	r0, [sp, #0x7c]
    146c:      	str	r0, [sp, #0x58]
    146e:      	str	r0, [sp, #0xb0]
    1470:      	movs	r0, #0x0
    1472:      	strb	r0, [r7, #-193]
;                 unsafe { self.bits(variant.into()) }
    1476:      	bl	0x255e <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf6PULL_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x10e4
    147a:      	ldr	r1, [sp, #0x30]
    147c:      	ldr	r2, [sp, #0x38]
    147e:      	str	r2, [sp, #0xb8]
    1480:      	strb	r0, [r7, #-185]
    1484:      	str	r2, [sp, #0x14c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1486:      	ldr	r2, [r2]
    1488:      	bic	r2, r2, #0xc
;                     | ((value.into() & Self::MASK) << { OF });
    148c:      	str	r2, [sp, #0x34]
    148e:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x16dc
    1492:      	ldr	r1, [sp, #0x34]
    1494:      	ldr	r2, [sp, #0x38]
    1496:      	mov	r3, r0
    1498:      	ldr	r0, [sp, #0x3c]
    149a:      	and	r3, r3, #0x3
    149e:      	str	r2, [sp, #0x170]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    14a0:      	orr.w	r1, r1, r3, lsl #2
    14a4:      	str	r1, [r2]
;                             match drive {
    14a6:      	ldrb	r0, [r0]
    14a8:      	str	r0, [sp, #0x40]
    14aa:      	ldr	r1, [sp, #0x40]
    14ac:      	tbb	[pc, r1]
    14b0: 03 29 4f 75  	.word	0x754f2903
    14b4:      	trap
    14b6:      	ldr	r0, [sp, #0x38]
    14b8:      	str	r0, [sp, #0x98]
    14ba:      	str	r0, [sp, #0x9c]
    14bc:      	str	r0, [sp, #0x68]
    14be:      	str	r0, [sp, #0xd0]
    14c0:      	movs	r0, #0x0
    14c2:      	strb	r0, [r7, #-161]
;                 self.bits(variant.into())
    14c6:      	movw	r1, #0x5cb0
    14ca:      	movt	r1, #0x0
    14ce:      	str	r1, [sp, #0x24]
    14d0:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x109c
    14d4:      	ldr	r1, [sp, #0x24]
    14d6:      	ldr	r2, [sp, #0x38]
    14d8:      	str	r2, [sp, #0xd8]
    14da:      	strb	r0, [r7, #-153]
    14de:      	str	r2, [sp, #0x144]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    14e0:      	ldr	r2, [r2]
    14e2:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    14e6:      	str	r2, [sp, #0x28]
    14e8:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1682
    14ec:      	ldr	r1, [sp, #0x28]
    14ee:      	mov	r2, r0
    14f0:      	ldr	r0, [sp, #0x38]
    14f2:      	and	r2, r2, #0x7
    14f6:      	str	r0, [sp, #0x168]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    14f8:      	orr.w	r1, r1, r2, lsl #8
    14fc:      	str	r1, [r0]
;                                 DriveConfig::Standard0Standard1 => w.drive().s0s1(),
    14fe:      	str	r0, [sp, #0x44]
    1500:      	b	0x15e6 <_RNCNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_24NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0xe2
    1502:      	ldr	r0, [sp, #0x38]
    1504:      	str	r0, [sp, #0x90]
    1506:      	str	r0, [sp, #0x94]
    1508:      	str	r0, [sp, #0x64]
    150a:      	str	r0, [sp, #0xe0]
    150c:      	movs	r0, #0x2
    150e:      	strb	r0, [r7, #-145]
;                 self.bits(variant.into())
    1512:      	movw	r1, #0x5cb0
    1516:      	movt	r1, #0x0
    151a:      	str	r1, [sp, #0x1c]
    151c:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1050
    1520:      	ldr	r1, [sp, #0x1c]
    1522:      	ldr	r2, [sp, #0x38]
    1524:      	str	r2, [sp, #0xe8]
    1526:      	strb	r0, [r7, #-137]
    152a:      	str	r2, [sp, #0x140]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    152c:      	ldr	r2, [r2]
    152e:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1532:      	str	r2, [sp, #0x20]
    1534:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1636
    1538:      	ldr	r1, [sp, #0x20]
    153a:      	mov	r2, r0
    153c:      	ldr	r0, [sp, #0x38]
    153e:      	and	r2, r2, #0x7
    1542:      	str	r0, [sp, #0x164]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1544:      	orr.w	r1, r1, r2, lsl #8
    1548:      	str	r1, [r0]
;                                 DriveConfig::Standard0HighDrive1 => w.drive().s0h1(),
    154a:      	str	r0, [sp, #0x44]
    154c:      	b	0x15e6 <_RNCNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_24NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x96
    154e:      	ldr	r0, [sp, #0x38]
    1550:      	str	r0, [sp, #0x88]
    1552:      	str	r0, [sp, #0x8c]
    1554:      	str	r0, [sp, #0x60]
    1556:      	str	r0, [sp, #0xf0]
    1558:      	movs	r0, #0x1
    155a:      	strb	r0, [r7, #-129]
;                 self.bits(variant.into())
    155e:      	movw	r1, #0x5cb0
    1562:      	movt	r1, #0x0
    1566:      	str	r1, [sp, #0x14]
    1568:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x1004
    156c:      	ldr	r1, [sp, #0x14]
    156e:      	ldr	r2, [sp, #0x38]
    1570:      	str	r2, [sp, #0xf8]
    1572:      	strb	r0, [r7, #-121]
    1576:      	str	r2, [sp, #0x13c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1578:      	ldr	r2, [r2]
    157a:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    157e:      	str	r2, [sp, #0x18]
    1580:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x15ea
    1584:      	ldr	r1, [sp, #0x18]
    1586:      	mov	r2, r0
    1588:      	ldr	r0, [sp, #0x38]
    158a:      	and	r2, r2, #0x7
    158e:      	str	r0, [sp, #0x160]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1590:      	orr.w	r1, r1, r2, lsl #8
    1594:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0Standard1 => w.drive().h0s1(),
    1596:      	str	r0, [sp, #0x44]
    1598:      	b	0x15e6 <_RNCNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_24NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x4a
    159a:      	ldr	r0, [sp, #0x38]
    159c:      	str	r0, [sp, #0x80]
    159e:      	str	r0, [sp, #0x84]
    15a0:      	str	r0, [sp, #0x5c]
    15a2:      	str	r0, [sp, #0x100]
    15a4:      	movs	r0, #0x3
    15a6:      	strb	r0, [r7, #-113]
;                 self.bits(variant.into())
    15aa:      	movw	r1, #0x5cb0
    15ae:      	movt	r1, #0x0
    15b2:      	str	r1, [sp, #0xc]
    15b4:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xfb8
    15b8:      	ldr	r1, [sp, #0xc]
    15ba:      	ldr	r2, [sp, #0x38]
    15bc:      	str	r2, [sp, #0x108]
    15be:      	strb	r0, [r7, #-105]
    15c2:      	str	r2, [sp, #0x138]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    15c4:      	ldr	r2, [r2]
    15c6:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    15ca:      	str	r2, [sp, #0x10]
    15cc:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x159e
    15d0:      	ldr	r1, [sp, #0x10]
    15d2:      	mov	r2, r0
    15d4:      	ldr	r0, [sp, #0x38]
    15d6:      	and	r2, r2, #0x7
    15da:      	str	r0, [sp, #0x15c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    15dc:      	orr.w	r1, r1, r2, lsl #8
    15e0:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0HighDrive1 => w.drive().h0h1(),
    15e2:      	str	r0, [sp, #0x44]
    15e4:      	b	0x15e6 <_RNCNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_24NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #-0x2
    15e6:      	ldr	r0, [sp, #0x38]
    15e8:      	str	r0, [sp, #0xa8]
    15ea:      	str	r0, [sp, #0xac]
    15ec:      	str	r0, [sp, #0x6c]
    15ee:      	str	r0, [sp, #0xc0]
    15f0:      	movs	r0, #0x0
    15f2:      	strb	r0, [r7, #-177]
;                 unsafe { self.bits(variant.into()) }
    15f6:      	movw	r1, #0x5cb0
    15fa:      	movt	r1, #0x0
    15fe:      	str	r1, [sp, #0x4]
    1600:      	bl	0x2594 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7SENSE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xf90
    1604:      	ldr	r1, [sp, #0x4]
    1606:      	ldr	r2, [sp, #0x38]
    1608:      	str	r2, [sp, #0xc8]
    160a:      	strb	r0, [r7, #-169]
    160e:      	str	r2, [sp, #0x148]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1610:      	ldr	r2, [r2]
    1612:      	bic	r2, r2, #0x30000
;                     | ((value.into() & Self::MASK) << { OF });
    1616:      	str	r2, [sp, #0x8]
    1618:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1552
    161c:      	ldr	r1, [sp, #0x8]
    161e:      	mov	r2, r0
    1620:      	ldr	r0, [sp, #0x38]
    1622:      	and	r2, r2, #0x3
    1626:      	str	r0, [sp, #0x16c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1628:      	orr.w	r1, r1, r2, lsl #16
    162c:      	str	r1, [r0]
    162e:      	str	r0, [sp, #0x174]
;                         });
    1630:      	add	sp, #0x178
    1632:      	pop	{r7, pc}

00001634 <_RNCNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtB8_11Peripherals4take0CslicV2bA46s8_15microbit_common>:
;         cortex_m::interrupt::free(|_| {
    1634:      	push	{r7, lr}
    1636:      	mov	r7, sp
    1638:      	sub	sp, #0x8
    163a:      	str	r0, [sp, #0x4]
;             if unsafe { DEVICE_PERIPHERALS } {
    163c:      	movw	r0, #0x434
    1640:      	movt	r0, #0x2000
    1644:      	ldrb	r0, [r0]
    1646:      	lsls	r0, r0, #0x1f
    1648:      	cbnz	r0, 0x1658 <_RNCNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtB8_11Peripherals4take0CslicV2bA46s8_15microbit_common+0x24> @ imm = #0xc
    164a:      	b	0x164c <_RNCNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtB8_11Peripherals4take0CslicV2bA46s8_15microbit_common+0x18> @ imm = #-0x2
;                 Some(unsafe { Peripherals::steal() })
    164c:      	bl	0x22fa <_RNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtB6_11Peripherals5stealCslicV2bA46s8_15microbit_common> @ imm = #0xcaa
    1650:      	movs	r0, #0x1
    1652:      	strb	r0, [r7, #-6]
;             if unsafe { DEVICE_PERIPHERALS } {
    1656:      	b	0x1660 <_RNCNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtB8_11Peripherals4take0CslicV2bA46s8_15microbit_common+0x2c> @ imm = #0x6
;                 None
    1658:      	movs	r0, #0x0
    165a:      	strb	r0, [r7, #-6]
;             if unsafe { DEVICE_PERIPHERALS } {
    165e:      	b	0x1660 <_RNCNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtB8_11Peripherals4take0CslicV2bA46s8_15microbit_common+0x2c> @ imm = #-0x2
;         })
    1660:      	ldrb	r0, [r7, #-6]
    1664:      	add	sp, #0x8
    1666:      	pop	{r7, pc}

00001668 <_RNCNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_30NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common>:
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    1668:      	push	{r7, lr}
    166a:      	mov	r7, sp
    166c:      	sub	sp, #0x178
    166e:      	str	r1, [sp, #0x38]
    1670:      	str	r0, [sp, #0x3c]
    1672:      	str	r0, [sp, #0x48]
    1674:      	str	r1, [sp, #0x4c]
    1676:      	str	r1, [sp, #0x70]
    1678:      	str	r1, [sp, #0x74]
    167a:      	str	r1, [sp, #0x50]
    167c:      	str	r1, [sp, #0x110]
    167e:      	movs	r0, #0x1
    1680:      	str	r0, [sp, #0x2c]
    1682:      	strb	r0, [r7, #-97]
;                 self.bit(variant.into())
    1686:      	movw	r1, #0x5cb0
    168a:      	movt	r1, #0x0
    168e:      	str	r1, [sp, #0x30]
    1690:      	bl	0x254c <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf5DIR_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xeb8
    1694:      	ldr	r1, [sp, #0x30]
    1696:      	ldr	r2, [sp, #0x38]
    1698:      	mov	r12, r0
    169a:      	ldr	r0, [sp, #0x2c]
    169c:      	str	r2, [sp, #0x118]
    169e:      	strb	r12, [r7, #-89]
    16a2:      	str	r2, [sp, #0x134]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
    16a4:      	ldr	r3, [r2]
    16a6:      	bic	r3, r3, #0x1
    16aa:      	strb	r12, [r7, #-37]
    16ae:      	str	r2, [sp, #0x158]
    16b0:      	add	r3, r12
    16b2:      	str	r3, [r2]
    16b4:      	str	r2, [sp, #0xa0]
    16b6:      	str	r2, [sp, #0xa4]
    16b8:      	str	r2, [sp, #0x54]
    16ba:      	str	r2, [sp, #0x120]
    16bc:      	strb	r0, [r7, #-81]
;                 self.bit(variant.into())
    16c0:      	bl	0x2582 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7INPUT_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xebe
    16c4:      	ldr	r1, [sp, #0x30]
    16c6:      	mov	r3, r0
    16c8:      	ldr	r0, [sp, #0x38]
    16ca:      	str	r0, [sp, #0x128]
    16cc:      	strb	r3, [r7, #-73]
    16d0:      	str	r0, [sp, #0x130]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
    16d2:      	ldr	r2, [r0]
    16d4:      	bic	r2, r2, #0x2
    16d8:      	strb	r3, [r7, #-38]
    16dc:      	str	r0, [sp, #0x154]
    16de:      	orr.w	r2, r2, r3, lsl #1
    16e2:      	str	r2, [r0]
    16e4:      	str	r0, [sp, #0x78]
    16e6:      	str	r0, [sp, #0x7c]
    16e8:      	str	r0, [sp, #0x58]
    16ea:      	str	r0, [sp, #0xb0]
    16ec:      	movs	r0, #0x0
    16ee:      	strb	r0, [r7, #-193]
;                 unsafe { self.bits(variant.into()) }
    16f2:      	bl	0x255e <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf6PULL_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xe68
    16f6:      	ldr	r1, [sp, #0x30]
    16f8:      	ldr	r2, [sp, #0x38]
    16fa:      	str	r2, [sp, #0xb8]
    16fc:      	strb	r0, [r7, #-185]
    1700:      	str	r2, [sp, #0x14c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1702:      	ldr	r2, [r2]
    1704:      	bic	r2, r2, #0xc
;                     | ((value.into() & Self::MASK) << { OF });
    1708:      	str	r2, [sp, #0x34]
    170a:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1460
    170e:      	ldr	r1, [sp, #0x34]
    1710:      	ldr	r2, [sp, #0x38]
    1712:      	mov	r3, r0
    1714:      	ldr	r0, [sp, #0x3c]
    1716:      	and	r3, r3, #0x3
    171a:      	str	r2, [sp, #0x170]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    171c:      	orr.w	r1, r1, r3, lsl #2
    1720:      	str	r1, [r2]
;                             match drive {
    1722:      	ldrb	r0, [r0]
    1724:      	str	r0, [sp, #0x40]
    1726:      	ldr	r1, [sp, #0x40]
    1728:      	tbb	[pc, r1]
    172c: 03 29 4f 75  	.word	0x754f2903
    1730:      	trap
    1732:      	ldr	r0, [sp, #0x38]
    1734:      	str	r0, [sp, #0x98]
    1736:      	str	r0, [sp, #0x9c]
    1738:      	str	r0, [sp, #0x68]
    173a:      	str	r0, [sp, #0xd0]
    173c:      	movs	r0, #0x0
    173e:      	strb	r0, [r7, #-161]
;                 self.bits(variant.into())
    1742:      	movw	r1, #0x5cb0
    1746:      	movt	r1, #0x0
    174a:      	str	r1, [sp, #0x24]
    174c:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xe20
    1750:      	ldr	r1, [sp, #0x24]
    1752:      	ldr	r2, [sp, #0x38]
    1754:      	str	r2, [sp, #0xd8]
    1756:      	strb	r0, [r7, #-153]
    175a:      	str	r2, [sp, #0x144]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    175c:      	ldr	r2, [r2]
    175e:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1762:      	str	r2, [sp, #0x28]
    1764:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1406
    1768:      	ldr	r1, [sp, #0x28]
    176a:      	mov	r2, r0
    176c:      	ldr	r0, [sp, #0x38]
    176e:      	and	r2, r2, #0x7
    1772:      	str	r0, [sp, #0x168]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1774:      	orr.w	r1, r1, r2, lsl #8
    1778:      	str	r1, [r0]
;                                 DriveConfig::Standard0Standard1 => w.drive().s0s1(),
    177a:      	str	r0, [sp, #0x44]
    177c:      	b	0x1862 <_RNCNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_30NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0xe2
    177e:      	ldr	r0, [sp, #0x38]
    1780:      	str	r0, [sp, #0x90]
    1782:      	str	r0, [sp, #0x94]
    1784:      	str	r0, [sp, #0x64]
    1786:      	str	r0, [sp, #0xe0]
    1788:      	movs	r0, #0x2
    178a:      	strb	r0, [r7, #-145]
;                 self.bits(variant.into())
    178e:      	movw	r1, #0x5cb0
    1792:      	movt	r1, #0x0
    1796:      	str	r1, [sp, #0x1c]
    1798:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xdd4
    179c:      	ldr	r1, [sp, #0x1c]
    179e:      	ldr	r2, [sp, #0x38]
    17a0:      	str	r2, [sp, #0xe8]
    17a2:      	strb	r0, [r7, #-137]
    17a6:      	str	r2, [sp, #0x140]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    17a8:      	ldr	r2, [r2]
    17aa:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    17ae:      	str	r2, [sp, #0x20]
    17b0:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x13ba
    17b4:      	ldr	r1, [sp, #0x20]
    17b6:      	mov	r2, r0
    17b8:      	ldr	r0, [sp, #0x38]
    17ba:      	and	r2, r2, #0x7
    17be:      	str	r0, [sp, #0x164]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    17c0:      	orr.w	r1, r1, r2, lsl #8
    17c4:      	str	r1, [r0]
;                                 DriveConfig::Standard0HighDrive1 => w.drive().s0h1(),
    17c6:      	str	r0, [sp, #0x44]
    17c8:      	b	0x1862 <_RNCNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_30NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x96
    17ca:      	ldr	r0, [sp, #0x38]
    17cc:      	str	r0, [sp, #0x88]
    17ce:      	str	r0, [sp, #0x8c]
    17d0:      	str	r0, [sp, #0x60]
    17d2:      	str	r0, [sp, #0xf0]
    17d4:      	movs	r0, #0x1
    17d6:      	strb	r0, [r7, #-129]
;                 self.bits(variant.into())
    17da:      	movw	r1, #0x5cb0
    17de:      	movt	r1, #0x0
    17e2:      	str	r1, [sp, #0x14]
    17e4:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xd88
    17e8:      	ldr	r1, [sp, #0x14]
    17ea:      	ldr	r2, [sp, #0x38]
    17ec:      	str	r2, [sp, #0xf8]
    17ee:      	strb	r0, [r7, #-121]
    17f2:      	str	r2, [sp, #0x13c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    17f4:      	ldr	r2, [r2]
    17f6:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    17fa:      	str	r2, [sp, #0x18]
    17fc:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x136e
    1800:      	ldr	r1, [sp, #0x18]
    1802:      	mov	r2, r0
    1804:      	ldr	r0, [sp, #0x38]
    1806:      	and	r2, r2, #0x7
    180a:      	str	r0, [sp, #0x160]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    180c:      	orr.w	r1, r1, r2, lsl #8
    1810:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0Standard1 => w.drive().h0s1(),
    1812:      	str	r0, [sp, #0x44]
    1814:      	b	0x1862 <_RNCNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_30NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x4a
    1816:      	ldr	r0, [sp, #0x38]
    1818:      	str	r0, [sp, #0x80]
    181a:      	str	r0, [sp, #0x84]
    181c:      	str	r0, [sp, #0x5c]
    181e:      	str	r0, [sp, #0x100]
    1820:      	movs	r0, #0x3
    1822:      	strb	r0, [r7, #-113]
;                 self.bits(variant.into())
    1826:      	movw	r1, #0x5cb0
    182a:      	movt	r1, #0x0
    182e:      	str	r1, [sp, #0xc]
    1830:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xd3c
    1834:      	ldr	r1, [sp, #0xc]
    1836:      	ldr	r2, [sp, #0x38]
    1838:      	str	r2, [sp, #0x108]
    183a:      	strb	r0, [r7, #-105]
    183e:      	str	r2, [sp, #0x138]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1840:      	ldr	r2, [r2]
    1842:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1846:      	str	r2, [sp, #0x10]
    1848:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1322
    184c:      	ldr	r1, [sp, #0x10]
    184e:      	mov	r2, r0
    1850:      	ldr	r0, [sp, #0x38]
    1852:      	and	r2, r2, #0x7
    1856:      	str	r0, [sp, #0x15c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1858:      	orr.w	r1, r1, r2, lsl #8
    185c:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0HighDrive1 => w.drive().h0h1(),
    185e:      	str	r0, [sp, #0x44]
    1860:      	b	0x1862 <_RNCNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_30NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #-0x2
    1862:      	ldr	r0, [sp, #0x38]
    1864:      	str	r0, [sp, #0xa8]
    1866:      	str	r0, [sp, #0xac]
    1868:      	str	r0, [sp, #0x6c]
    186a:      	str	r0, [sp, #0xc0]
    186c:      	movs	r0, #0x0
    186e:      	strb	r0, [r7, #-177]
;                 unsafe { self.bits(variant.into()) }
    1872:      	movw	r1, #0x5cb0
    1876:      	movt	r1, #0x0
    187a:      	str	r1, [sp, #0x4]
    187c:      	bl	0x2594 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7SENSE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xd14
    1880:      	ldr	r1, [sp, #0x4]
    1882:      	ldr	r2, [sp, #0x38]
    1884:      	str	r2, [sp, #0xc8]
    1886:      	strb	r0, [r7, #-169]
    188a:      	str	r2, [sp, #0x148]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    188c:      	ldr	r2, [r2]
    188e:      	bic	r2, r2, #0x30000
;                     | ((value.into() & Self::MASK) << { OF });
    1892:      	str	r2, [sp, #0x8]
    1894:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x12d6
    1898:      	ldr	r1, [sp, #0x8]
    189a:      	mov	r2, r0
    189c:      	ldr	r0, [sp, #0x38]
    189e:      	and	r2, r2, #0x3
    18a2:      	str	r0, [sp, #0x16c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    18a4:      	orr.w	r1, r1, r2, lsl #16
    18a8:      	str	r1, [r0]
    18aa:      	str	r0, [sp, #0x174]
;                         });
    18ac:      	add	sp, #0x178
    18ae:      	pop	{r7, pc}

000018b0 <_RNCNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_31NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common>:
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    18b0:      	push	{r7, lr}
    18b2:      	mov	r7, sp
    18b4:      	sub	sp, #0x178
    18b6:      	str	r1, [sp, #0x38]
    18b8:      	str	r0, [sp, #0x3c]
    18ba:      	str	r0, [sp, #0x48]
    18bc:      	str	r1, [sp, #0x4c]
    18be:      	str	r1, [sp, #0x70]
    18c0:      	str	r1, [sp, #0x74]
    18c2:      	str	r1, [sp, #0x50]
    18c4:      	str	r1, [sp, #0x110]
    18c6:      	movs	r0, #0x1
    18c8:      	str	r0, [sp, #0x2c]
    18ca:      	strb	r0, [r7, #-97]
;                 self.bit(variant.into())
    18ce:      	movw	r1, #0x5cb0
    18d2:      	movt	r1, #0x0
    18d6:      	str	r1, [sp, #0x30]
    18d8:      	bl	0x254c <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf5DIR_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xc70
    18dc:      	ldr	r1, [sp, #0x30]
    18de:      	ldr	r2, [sp, #0x38]
    18e0:      	mov	r12, r0
    18e2:      	ldr	r0, [sp, #0x2c]
    18e4:      	str	r2, [sp, #0x118]
    18e6:      	strb	r12, [r7, #-89]
    18ea:      	str	r2, [sp, #0x134]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
    18ec:      	ldr	r3, [r2]
    18ee:      	bic	r3, r3, #0x1
    18f2:      	strb	r12, [r7, #-37]
    18f6:      	str	r2, [sp, #0x158]
    18f8:      	add	r3, r12
    18fa:      	str	r3, [r2]
    18fc:      	str	r2, [sp, #0xa0]
    18fe:      	str	r2, [sp, #0xa4]
    1900:      	str	r2, [sp, #0x54]
    1902:      	str	r2, [sp, #0x120]
    1904:      	strb	r0, [r7, #-81]
;                 self.bit(variant.into())
    1908:      	bl	0x2582 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7INPUT_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xc76
    190c:      	ldr	r1, [sp, #0x30]
    190e:      	mov	r3, r0
    1910:      	ldr	r0, [sp, #0x38]
    1912:      	str	r0, [sp, #0x128]
    1914:      	strb	r3, [r7, #-73]
    1918:      	str	r0, [sp, #0x130]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
    191a:      	ldr	r2, [r0]
    191c:      	bic	r2, r2, #0x2
    1920:      	strb	r3, [r7, #-38]
    1924:      	str	r0, [sp, #0x154]
    1926:      	orr.w	r2, r2, r3, lsl #1
    192a:      	str	r2, [r0]
    192c:      	str	r0, [sp, #0x78]
    192e:      	str	r0, [sp, #0x7c]
    1930:      	str	r0, [sp, #0x58]
    1932:      	str	r0, [sp, #0xb0]
    1934:      	movs	r0, #0x0
    1936:      	strb	r0, [r7, #-193]
;                 unsafe { self.bits(variant.into()) }
    193a:      	bl	0x255e <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf6PULL_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xc20
    193e:      	ldr	r1, [sp, #0x30]
    1940:      	ldr	r2, [sp, #0x38]
    1942:      	str	r2, [sp, #0xb8]
    1944:      	strb	r0, [r7, #-185]
    1948:      	str	r2, [sp, #0x14c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    194a:      	ldr	r2, [r2]
    194c:      	bic	r2, r2, #0xc
;                     | ((value.into() & Self::MASK) << { OF });
    1950:      	str	r2, [sp, #0x34]
    1952:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1218
    1956:      	ldr	r1, [sp, #0x34]
    1958:      	ldr	r2, [sp, #0x38]
    195a:      	mov	r3, r0
    195c:      	ldr	r0, [sp, #0x3c]
    195e:      	and	r3, r3, #0x3
    1962:      	str	r2, [sp, #0x170]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1964:      	orr.w	r1, r1, r3, lsl #2
    1968:      	str	r1, [r2]
;                             match drive {
    196a:      	ldrb	r0, [r0]
    196c:      	str	r0, [sp, #0x40]
    196e:      	ldr	r1, [sp, #0x40]
    1970:      	tbb	[pc, r1]
    1974: 03 29 4f 75  	.word	0x754f2903
    1978:      	trap
    197a:      	ldr	r0, [sp, #0x38]
    197c:      	str	r0, [sp, #0x98]
    197e:      	str	r0, [sp, #0x9c]
    1980:      	str	r0, [sp, #0x68]
    1982:      	str	r0, [sp, #0xd0]
    1984:      	movs	r0, #0x0
    1986:      	strb	r0, [r7, #-161]
;                 self.bits(variant.into())
    198a:      	movw	r1, #0x5cb0
    198e:      	movt	r1, #0x0
    1992:      	str	r1, [sp, #0x24]
    1994:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xbd8
    1998:      	ldr	r1, [sp, #0x24]
    199a:      	ldr	r2, [sp, #0x38]
    199c:      	str	r2, [sp, #0xd8]
    199e:      	strb	r0, [r7, #-153]
    19a2:      	str	r2, [sp, #0x144]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    19a4:      	ldr	r2, [r2]
    19a6:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    19aa:      	str	r2, [sp, #0x28]
    19ac:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x11be
    19b0:      	ldr	r1, [sp, #0x28]
    19b2:      	mov	r2, r0
    19b4:      	ldr	r0, [sp, #0x38]
    19b6:      	and	r2, r2, #0x7
    19ba:      	str	r0, [sp, #0x168]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    19bc:      	orr.w	r1, r1, r2, lsl #8
    19c0:      	str	r1, [r0]
;                                 DriveConfig::Standard0Standard1 => w.drive().s0s1(),
    19c2:      	str	r0, [sp, #0x44]
    19c4:      	b	0x1aaa <_RNCNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_31NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0xe2
    19c6:      	ldr	r0, [sp, #0x38]
    19c8:      	str	r0, [sp, #0x90]
    19ca:      	str	r0, [sp, #0x94]
    19cc:      	str	r0, [sp, #0x64]
    19ce:      	str	r0, [sp, #0xe0]
    19d0:      	movs	r0, #0x2
    19d2:      	strb	r0, [r7, #-145]
;                 self.bits(variant.into())
    19d6:      	movw	r1, #0x5cb0
    19da:      	movt	r1, #0x0
    19de:      	str	r1, [sp, #0x1c]
    19e0:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xb8c
    19e4:      	ldr	r1, [sp, #0x1c]
    19e6:      	ldr	r2, [sp, #0x38]
    19e8:      	str	r2, [sp, #0xe8]
    19ea:      	strb	r0, [r7, #-137]
    19ee:      	str	r2, [sp, #0x140]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    19f0:      	ldr	r2, [r2]
    19f2:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    19f6:      	str	r2, [sp, #0x20]
    19f8:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1172
    19fc:      	ldr	r1, [sp, #0x20]
    19fe:      	mov	r2, r0
    1a00:      	ldr	r0, [sp, #0x38]
    1a02:      	and	r2, r2, #0x7
    1a06:      	str	r0, [sp, #0x164]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1a08:      	orr.w	r1, r1, r2, lsl #8
    1a0c:      	str	r1, [r0]
;                                 DriveConfig::Standard0HighDrive1 => w.drive().s0h1(),
    1a0e:      	str	r0, [sp, #0x44]
    1a10:      	b	0x1aaa <_RNCNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_31NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x96
    1a12:      	ldr	r0, [sp, #0x38]
    1a14:      	str	r0, [sp, #0x88]
    1a16:      	str	r0, [sp, #0x8c]
    1a18:      	str	r0, [sp, #0x60]
    1a1a:      	str	r0, [sp, #0xf0]
    1a1c:      	movs	r0, #0x1
    1a1e:      	strb	r0, [r7, #-129]
;                 self.bits(variant.into())
    1a22:      	movw	r1, #0x5cb0
    1a26:      	movt	r1, #0x0
    1a2a:      	str	r1, [sp, #0x14]
    1a2c:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xb40
    1a30:      	ldr	r1, [sp, #0x14]
    1a32:      	ldr	r2, [sp, #0x38]
    1a34:      	str	r2, [sp, #0xf8]
    1a36:      	strb	r0, [r7, #-121]
    1a3a:      	str	r2, [sp, #0x13c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1a3c:      	ldr	r2, [r2]
    1a3e:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1a42:      	str	r2, [sp, #0x18]
    1a44:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x1126
    1a48:      	ldr	r1, [sp, #0x18]
    1a4a:      	mov	r2, r0
    1a4c:      	ldr	r0, [sp, #0x38]
    1a4e:      	and	r2, r2, #0x7
    1a52:      	str	r0, [sp, #0x160]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1a54:      	orr.w	r1, r1, r2, lsl #8
    1a58:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0Standard1 => w.drive().h0s1(),
    1a5a:      	str	r0, [sp, #0x44]
    1a5c:      	b	0x1aaa <_RNCNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_31NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x4a
    1a5e:      	ldr	r0, [sp, #0x38]
    1a60:      	str	r0, [sp, #0x80]
    1a62:      	str	r0, [sp, #0x84]
    1a64:      	str	r0, [sp, #0x5c]
    1a66:      	str	r0, [sp, #0x100]
    1a68:      	movs	r0, #0x3
    1a6a:      	strb	r0, [r7, #-113]
;                 self.bits(variant.into())
    1a6e:      	movw	r1, #0x5cb0
    1a72:      	movt	r1, #0x0
    1a76:      	str	r1, [sp, #0xc]
    1a78:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xaf4
    1a7c:      	ldr	r1, [sp, #0xc]
    1a7e:      	ldr	r2, [sp, #0x38]
    1a80:      	str	r2, [sp, #0x108]
    1a82:      	strb	r0, [r7, #-105]
    1a86:      	str	r2, [sp, #0x138]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1a88:      	ldr	r2, [r2]
    1a8a:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1a8e:      	str	r2, [sp, #0x10]
    1a90:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x10da
    1a94:      	ldr	r1, [sp, #0x10]
    1a96:      	mov	r2, r0
    1a98:      	ldr	r0, [sp, #0x38]
    1a9a:      	and	r2, r2, #0x7
    1a9e:      	str	r0, [sp, #0x15c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1aa0:      	orr.w	r1, r1, r2, lsl #8
    1aa4:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0HighDrive1 => w.drive().h0h1(),
    1aa6:      	str	r0, [sp, #0x44]
    1aa8:      	b	0x1aaa <_RNCNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_31NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #-0x2
    1aaa:      	ldr	r0, [sp, #0x38]
    1aac:      	str	r0, [sp, #0xa8]
    1aae:      	str	r0, [sp, #0xac]
    1ab0:      	str	r0, [sp, #0x6c]
    1ab2:      	str	r0, [sp, #0xc0]
    1ab4:      	movs	r0, #0x0
    1ab6:      	strb	r0, [r7, #-177]
;                 unsafe { self.bits(variant.into()) }
    1aba:      	movw	r1, #0x5cb0
    1abe:      	movt	r1, #0x0
    1ac2:      	str	r1, [sp, #0x4]
    1ac4:      	bl	0x2594 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7SENSE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xacc
    1ac8:      	ldr	r1, [sp, #0x4]
    1aca:      	ldr	r2, [sp, #0x38]
    1acc:      	str	r2, [sp, #0xc8]
    1ace:      	strb	r0, [r7, #-169]
    1ad2:      	str	r2, [sp, #0x148]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1ad4:      	ldr	r2, [r2]
    1ad6:      	bic	r2, r2, #0x30000
;                     | ((value.into() & Self::MASK) << { OF });
    1ada:      	str	r2, [sp, #0x8]
    1adc:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0x108e
    1ae0:      	ldr	r1, [sp, #0x8]
    1ae2:      	mov	r2, r0
    1ae4:      	ldr	r0, [sp, #0x38]
    1ae6:      	and	r2, r2, #0x3
    1aea:      	str	r0, [sp, #0x16c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1aec:      	orr.w	r1, r1, r2, lsl #16
    1af0:      	str	r1, [r0]
    1af2:      	str	r0, [sp, #0x174]
;                         });
    1af4:      	add	sp, #0x178
    1af6:      	pop	{r7, pc}

00001af8 <_RNCNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB7_5P1_05NtB9_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common>:
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    1af8:      	push	{r7, lr}
    1afa:      	mov	r7, sp
    1afc:      	sub	sp, #0x178
    1afe:      	str	r1, [sp, #0x38]
    1b00:      	str	r0, [sp, #0x3c]
    1b02:      	str	r0, [sp, #0x48]
    1b04:      	str	r1, [sp, #0x4c]
    1b06:      	str	r1, [sp, #0x70]
    1b08:      	str	r1, [sp, #0x74]
    1b0a:      	str	r1, [sp, #0x50]
    1b0c:      	str	r1, [sp, #0x110]
    1b0e:      	movs	r0, #0x1
    1b10:      	str	r0, [sp, #0x2c]
    1b12:      	strb	r0, [r7, #-97]
;                 self.bit(variant.into())
    1b16:      	movw	r1, #0x5cb0
    1b1a:      	movt	r1, #0x0
    1b1e:      	str	r1, [sp, #0x30]
    1b20:      	bl	0x254c <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf5DIR_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xa28
    1b24:      	ldr	r1, [sp, #0x30]
    1b26:      	ldr	r2, [sp, #0x38]
    1b28:      	mov	r12, r0
    1b2a:      	ldr	r0, [sp, #0x2c]
    1b2c:      	str	r2, [sp, #0x118]
    1b2e:      	strb	r12, [r7, #-89]
    1b32:      	str	r2, [sp, #0x134]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
    1b34:      	ldr	r3, [r2]
    1b36:      	bic	r3, r3, #0x1
    1b3a:      	strb	r12, [r7, #-37]
    1b3e:      	str	r2, [sp, #0x158]
    1b40:      	add	r3, r12
    1b42:      	str	r3, [r2]
    1b44:      	str	r2, [sp, #0xa0]
    1b46:      	str	r2, [sp, #0xa4]
    1b48:      	str	r2, [sp, #0x54]
    1b4a:      	str	r2, [sp, #0x120]
    1b4c:      	strb	r0, [r7, #-81]
;                 self.bit(variant.into())
    1b50:      	bl	0x2582 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7INPUT_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common> @ imm = #0xa2e
    1b54:      	ldr	r1, [sp, #0x30]
    1b56:      	mov	r3, r0
    1b58:      	ldr	r0, [sp, #0x38]
    1b5a:      	str	r0, [sp, #0x128]
    1b5c:      	strb	r3, [r7, #-73]
    1b60:      	str	r0, [sp, #0x130]
;                 self.w.bits = (self.w.bits & !(1 << { OF })) | ((<$U>::from(value) & 1) << { OF });
    1b62:      	ldr	r2, [r0]
    1b64:      	bic	r2, r2, #0x2
    1b68:      	strb	r3, [r7, #-38]
    1b6c:      	str	r0, [sp, #0x154]
    1b6e:      	orr.w	r2, r2, r3, lsl #1
    1b72:      	str	r2, [r0]
    1b74:      	str	r0, [sp, #0x78]
    1b76:      	str	r0, [sp, #0x7c]
    1b78:      	str	r0, [sp, #0x58]
    1b7a:      	str	r0, [sp, #0xb0]
    1b7c:      	movs	r0, #0x0
    1b7e:      	strb	r0, [r7, #-193]
;                 unsafe { self.bits(variant.into()) }
    1b82:      	bl	0x255e <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf6PULL_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x9d8
    1b86:      	ldr	r1, [sp, #0x30]
    1b88:      	ldr	r2, [sp, #0x38]
    1b8a:      	str	r2, [sp, #0xb8]
    1b8c:      	strb	r0, [r7, #-185]
    1b90:      	str	r2, [sp, #0x14c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1b92:      	ldr	r2, [r2]
    1b94:      	bic	r2, r2, #0xc
;                     | ((value.into() & Self::MASK) << { OF });
    1b98:      	str	r2, [sp, #0x34]
    1b9a:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0xfd0
    1b9e:      	ldr	r1, [sp, #0x34]
    1ba0:      	ldr	r2, [sp, #0x38]
    1ba2:      	mov	r3, r0
    1ba4:      	ldr	r0, [sp, #0x3c]
    1ba6:      	and	r3, r3, #0x3
    1baa:      	str	r2, [sp, #0x170]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1bac:      	orr.w	r1, r1, r3, lsl #2
    1bb0:      	str	r1, [r2]
;                             match drive {
    1bb2:      	ldrb	r0, [r0]
    1bb4:      	str	r0, [sp, #0x40]
    1bb6:      	ldr	r1, [sp, #0x40]
    1bb8:      	tbb	[pc, r1]
    1bbc: 03 29 4f 75  	.word	0x754f2903
    1bc0:      	trap
    1bc2:      	ldr	r0, [sp, #0x38]
    1bc4:      	str	r0, [sp, #0x98]
    1bc6:      	str	r0, [sp, #0x9c]
    1bc8:      	str	r0, [sp, #0x68]
    1bca:      	str	r0, [sp, #0xd0]
    1bcc:      	movs	r0, #0x0
    1bce:      	strb	r0, [r7, #-161]
;                 self.bits(variant.into())
    1bd2:      	movw	r1, #0x5cb0
    1bd6:      	movt	r1, #0x0
    1bda:      	str	r1, [sp, #0x24]
    1bdc:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x990
    1be0:      	ldr	r1, [sp, #0x24]
    1be2:      	ldr	r2, [sp, #0x38]
    1be4:      	str	r2, [sp, #0xd8]
    1be6:      	strb	r0, [r7, #-153]
    1bea:      	str	r2, [sp, #0x144]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1bec:      	ldr	r2, [r2]
    1bee:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1bf2:      	str	r2, [sp, #0x28]
    1bf4:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0xf76
    1bf8:      	ldr	r1, [sp, #0x28]
    1bfa:      	mov	r2, r0
    1bfc:      	ldr	r0, [sp, #0x38]
    1bfe:      	and	r2, r2, #0x7
    1c02:      	str	r0, [sp, #0x168]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1c04:      	orr.w	r1, r1, r2, lsl #8
    1c08:      	str	r1, [r0]
;                                 DriveConfig::Standard0Standard1 => w.drive().s0s1(),
    1c0a:      	str	r0, [sp, #0x44]
    1c0c:      	b	0x1cf2 <_RNCNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB7_5P1_05NtB9_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0xe2
    1c0e:      	ldr	r0, [sp, #0x38]
    1c10:      	str	r0, [sp, #0x90]
    1c12:      	str	r0, [sp, #0x94]
    1c14:      	str	r0, [sp, #0x64]
    1c16:      	str	r0, [sp, #0xe0]
    1c18:      	movs	r0, #0x2
    1c1a:      	strb	r0, [r7, #-145]
;                 self.bits(variant.into())
    1c1e:      	movw	r1, #0x5cb0
    1c22:      	movt	r1, #0x0
    1c26:      	str	r1, [sp, #0x1c]
    1c28:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x944
    1c2c:      	ldr	r1, [sp, #0x1c]
    1c2e:      	ldr	r2, [sp, #0x38]
    1c30:      	str	r2, [sp, #0xe8]
    1c32:      	strb	r0, [r7, #-137]
    1c36:      	str	r2, [sp, #0x140]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1c38:      	ldr	r2, [r2]
    1c3a:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1c3e:      	str	r2, [sp, #0x20]
    1c40:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0xf2a
    1c44:      	ldr	r1, [sp, #0x20]
    1c46:      	mov	r2, r0
    1c48:      	ldr	r0, [sp, #0x38]
    1c4a:      	and	r2, r2, #0x7
    1c4e:      	str	r0, [sp, #0x164]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1c50:      	orr.w	r1, r1, r2, lsl #8
    1c54:      	str	r1, [r0]
;                                 DriveConfig::Standard0HighDrive1 => w.drive().s0h1(),
    1c56:      	str	r0, [sp, #0x44]
    1c58:      	b	0x1cf2 <_RNCNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB7_5P1_05NtB9_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x96
    1c5a:      	ldr	r0, [sp, #0x38]
    1c5c:      	str	r0, [sp, #0x88]
    1c5e:      	str	r0, [sp, #0x8c]
    1c60:      	str	r0, [sp, #0x60]
    1c62:      	str	r0, [sp, #0xf0]
    1c64:      	movs	r0, #0x1
    1c66:      	strb	r0, [r7, #-129]
;                 self.bits(variant.into())
    1c6a:      	movw	r1, #0x5cb0
    1c6e:      	movt	r1, #0x0
    1c72:      	str	r1, [sp, #0x14]
    1c74:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x8f8
    1c78:      	ldr	r1, [sp, #0x14]
    1c7a:      	ldr	r2, [sp, #0x38]
    1c7c:      	str	r2, [sp, #0xf8]
    1c7e:      	strb	r0, [r7, #-121]
    1c82:      	str	r2, [sp, #0x13c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1c84:      	ldr	r2, [r2]
    1c86:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1c8a:      	str	r2, [sp, #0x18]
    1c8c:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0xede
    1c90:      	ldr	r1, [sp, #0x18]
    1c92:      	mov	r2, r0
    1c94:      	ldr	r0, [sp, #0x38]
    1c96:      	and	r2, r2, #0x7
    1c9a:      	str	r0, [sp, #0x160]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1c9c:      	orr.w	r1, r1, r2, lsl #8
    1ca0:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0Standard1 => w.drive().h0s1(),
    1ca2:      	str	r0, [sp, #0x44]
    1ca4:      	b	0x1cf2 <_RNCNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB7_5P1_05NtB9_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #0x4a
    1ca6:      	ldr	r0, [sp, #0x38]
    1ca8:      	str	r0, [sp, #0x80]
    1caa:      	str	r0, [sp, #0x84]
    1cac:      	str	r0, [sp, #0x5c]
    1cae:      	str	r0, [sp, #0x100]
    1cb0:      	movs	r0, #0x3
    1cb2:      	strb	r0, [r7, #-113]
;                 self.bits(variant.into())
    1cb6:      	movw	r1, #0x5cb0
    1cba:      	movt	r1, #0x0
    1cbe:      	str	r1, [sp, #0xc]
    1cc0:      	bl	0x2570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x8ac
    1cc4:      	ldr	r1, [sp, #0xc]
    1cc6:      	ldr	r2, [sp, #0x38]
    1cc8:      	str	r2, [sp, #0x108]
    1cca:      	strb	r0, [r7, #-105]
    1cce:      	str	r2, [sp, #0x138]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1cd0:      	ldr	r2, [r2]
    1cd2:      	bic	r2, r2, #0x700
;                     | ((value.into() & Self::MASK) << { OF });
    1cd6:      	str	r2, [sp, #0x10]
    1cd8:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0xe92
    1cdc:      	ldr	r1, [sp, #0x10]
    1cde:      	mov	r2, r0
    1ce0:      	ldr	r0, [sp, #0x38]
    1ce2:      	and	r2, r2, #0x7
    1ce6:      	str	r0, [sp, #0x15c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1ce8:      	orr.w	r1, r1, r2, lsl #8
    1cec:      	str	r1, [r0]
;                                 DriveConfig::HighDrive0HighDrive1 => w.drive().h0h1(),
    1cee:      	str	r0, [sp, #0x44]
    1cf0:      	b	0x1cf2 <_RNCNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB7_5P1_05NtB9_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common+0x1fa> @ imm = #-0x2
    1cf2:      	ldr	r0, [sp, #0x38]
    1cf4:      	str	r0, [sp, #0xa8]
    1cf6:      	str	r0, [sp, #0xac]
    1cf8:      	str	r0, [sp, #0x6c]
    1cfa:      	str	r0, [sp, #0xc0]
    1cfc:      	movs	r0, #0x0
    1cfe:      	strb	r0, [r7, #-177]
;                 unsafe { self.bits(variant.into()) }
    1d02:      	movw	r1, #0x5cb0
    1d06:      	movt	r1, #0x0
    1d0a:      	str	r1, [sp, #0x4]
    1d0c:      	bl	0x2594 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7SENSE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common> @ imm = #0x884
    1d10:      	ldr	r1, [sp, #0x4]
    1d12:      	ldr	r2, [sp, #0x38]
    1d14:      	str	r2, [sp, #0xc8]
    1d16:      	strb	r0, [r7, #-169]
    1d1a:      	str	r2, [sp, #0x148]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1d1c:      	ldr	r2, [r2]
    1d1e:      	bic	r2, r2, #0x30000
;                     | ((value.into() & Self::MASK) << { OF });
    1d22:      	str	r2, [sp, #0x8]
    1d24:      	bl	0x2b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common> @ imm = #0xe46
    1d28:      	ldr	r1, [sp, #0x8]
    1d2a:      	mov	r2, r0
    1d2c:      	ldr	r0, [sp, #0x38]
    1d2e:      	and	r2, r2, #0x3
    1d32:      	str	r0, [sp, #0x16c]
;                 self.w.bits = (self.w.bits & !(Self::MASK << { OF }))
    1d34:      	orr.w	r1, r1, r2, lsl #16
    1d38:      	str	r1, [r0]
    1d3a:      	str	r0, [sp, #0x174]
;                         });
    1d3c:      	add	sp, #0x178
    1d3e:      	pop	{r7, pc}

00001d40 <_RNCNvXs20_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_11INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1d40:      	push	{r7, lr}
    1d42:      	mov	r7, sp
    1d44:      	sub	sp, #0x1c
    1d46:      	str	r0, [sp, #0x4]
    1d48:      	str	r0, [sp, #0x8]
    1d4a:      	mov.w	r1, #0x800
    1d4e:      	str	r1, [sp, #0xc]
    1d50:      	str	r0, [sp, #0x10]
    1d52:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1d54:      	str	r1, [r0]
    1d56:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1d58:      	add	sp, #0x1c
    1d5a:      	pop	{r7, pc}

00001d5c <_RNCNvXs20_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_11INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1d5c:      	push	{r7, lr}
    1d5e:      	mov	r7, sp
    1d60:      	sub	sp, #0x1c
    1d62:      	str	r0, [sp, #0x4]
    1d64:      	str	r0, [sp, #0x8]
    1d66:      	mov.w	r1, #0x800
    1d6a:      	str	r1, [sp, #0xc]
    1d6c:      	str	r0, [sp, #0x10]
    1d6e:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1d70:      	str	r1, [r0]
    1d72:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1d74:      	add	sp, #0x1c
    1d76:      	pop	{r7, pc}

00001d78 <_RNCNvXs2I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_15INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1d78:      	push	{r7, lr}
    1d7a:      	mov	r7, sp
    1d7c:      	sub	sp, #0x1c
    1d7e:      	str	r0, [sp, #0x4]
    1d80:      	str	r0, [sp, #0x8]
    1d82:      	mov.w	r1, #0x8000
    1d86:      	str	r1, [sp, #0xc]
    1d88:      	str	r0, [sp, #0x10]
    1d8a:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1d8c:      	str	r1, [r0]
    1d8e:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1d90:      	add	sp, #0x1c
    1d92:      	pop	{r7, pc}

00001d94 <_RNCNvXs2I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_15INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1d94:      	push	{r7, lr}
    1d96:      	mov	r7, sp
    1d98:      	sub	sp, #0x1c
    1d9a:      	str	r0, [sp, #0x4]
    1d9c:      	str	r0, [sp, #0x8]
    1d9e:      	mov.w	r1, #0x8000
    1da2:      	str	r1, [sp, #0xc]
    1da4:      	str	r0, [sp, #0x10]
    1da6:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1da8:      	str	r1, [r0]
    1daa:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1dac:      	add	sp, #0x1c
    1dae:      	pop	{r7, pc}

00001db0 <_RNCNvXs3M_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_21INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1db0:      	push	{r7, lr}
    1db2:      	mov	r7, sp
    1db4:      	sub	sp, #0x1c
    1db6:      	str	r0, [sp, #0x4]
    1db8:      	str	r0, [sp, #0x8]
    1dba:      	mov.w	r1, #0x200000
    1dbe:      	str	r1, [sp, #0xc]
    1dc0:      	str	r0, [sp, #0x10]
    1dc2:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1dc4:      	str	r1, [r0]
    1dc6:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1dc8:      	add	sp, #0x1c
    1dca:      	pop	{r7, pc}

00001dcc <_RNCNvXs3M_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_21INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1dcc:      	push	{r7, lr}
    1dce:      	mov	r7, sp
    1dd0:      	sub	sp, #0x1c
    1dd2:      	str	r0, [sp, #0x4]
    1dd4:      	str	r0, [sp, #0x8]
    1dd6:      	mov.w	r1, #0x200000
    1dda:      	str	r1, [sp, #0xc]
    1ddc:      	str	r0, [sp, #0x10]
    1dde:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1de0:      	str	r1, [r0]
    1de2:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1de4:      	add	sp, #0x1c
    1de6:      	pop	{r7, pc}

00001de8 <_RNCNvXs3X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_22INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1de8:      	push	{r7, lr}
    1dea:      	mov	r7, sp
    1dec:      	sub	sp, #0x1c
    1dee:      	str	r0, [sp, #0x4]
    1df0:      	str	r0, [sp, #0x8]
    1df2:      	mov.w	r1, #0x400000
    1df6:      	str	r1, [sp, #0xc]
    1df8:      	str	r0, [sp, #0x10]
    1dfa:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1dfc:      	str	r1, [r0]
    1dfe:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1e00:      	add	sp, #0x1c
    1e02:      	pop	{r7, pc}

00001e04 <_RNCNvXs3X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_22INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1e04:      	push	{r7, lr}
    1e06:      	mov	r7, sp
    1e08:      	sub	sp, #0x1c
    1e0a:      	str	r0, [sp, #0x4]
    1e0c:      	str	r0, [sp, #0x8]
    1e0e:      	mov.w	r1, #0x400000
    1e12:      	str	r1, [sp, #0xc]
    1e14:      	str	r0, [sp, #0x10]
    1e16:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1e18:      	str	r1, [r0]
    1e1a:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1e1c:      	add	sp, #0x1c
    1e1e:      	pop	{r7, pc}

00001e20 <_RNCNvXs3q_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_19INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1e20:      	push	{r7, lr}
    1e22:      	mov	r7, sp
    1e24:      	sub	sp, #0x1c
    1e26:      	str	r0, [sp, #0x4]
    1e28:      	str	r0, [sp, #0x8]
    1e2a:      	mov.w	r1, #0x80000
    1e2e:      	str	r1, [sp, #0xc]
    1e30:      	str	r0, [sp, #0x10]
    1e32:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1e34:      	str	r1, [r0]
    1e36:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1e38:      	add	sp, #0x1c
    1e3a:      	pop	{r7, pc}

00001e3c <_RNCNvXs3q_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_19INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1e3c:      	push	{r7, lr}
    1e3e:      	mov	r7, sp
    1e40:      	sub	sp, #0x1c
    1e42:      	str	r0, [sp, #0x4]
    1e44:      	str	r0, [sp, #0x8]
    1e46:      	mov.w	r1, #0x80000
    1e4a:      	str	r1, [sp, #0xc]
    1e4c:      	str	r0, [sp, #0x10]
    1e4e:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1e50:      	str	r1, [r0]
    1e52:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1e54:      	add	sp, #0x1c
    1e56:      	pop	{r7, pc}

00001e58 <_RNCNvXs4j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_24INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1e58:      	push	{r7, lr}
    1e5a:      	mov	r7, sp
    1e5c:      	sub	sp, #0x1c
    1e5e:      	str	r0, [sp, #0x4]
    1e60:      	str	r0, [sp, #0x8]
    1e62:      	mov.w	r1, #0x1000000
    1e66:      	str	r1, [sp, #0xc]
    1e68:      	str	r0, [sp, #0x10]
    1e6a:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1e6c:      	str	r1, [r0]
    1e6e:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1e70:      	add	sp, #0x1c
    1e72:      	pop	{r7, pc}

00001e74 <_RNCNvXs4j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_24INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1e74:      	push	{r7, lr}
    1e76:      	mov	r7, sp
    1e78:      	sub	sp, #0x1c
    1e7a:      	str	r0, [sp, #0x4]
    1e7c:      	str	r0, [sp, #0x8]
    1e7e:      	mov.w	r1, #0x1000000
    1e82:      	str	r1, [sp, #0xc]
    1e84:      	str	r0, [sp, #0x10]
    1e86:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1e88:      	str	r1, [r0]
    1e8a:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1e8c:      	add	sp, #0x1c
    1e8e:      	pop	{r7, pc}

00001e90 <_RNCNvXs51_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_28INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1e90:      	push	{r7, lr}
    1e92:      	mov	r7, sp
    1e94:      	sub	sp, #0x1c
    1e96:      	str	r0, [sp, #0x4]
    1e98:      	str	r0, [sp, #0x8]
    1e9a:      	mov.w	r1, #0x10000000
    1e9e:      	str	r1, [sp, #0xc]
    1ea0:      	str	r0, [sp, #0x10]
    1ea2:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1ea4:      	str	r1, [r0]
    1ea6:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1ea8:      	add	sp, #0x1c
    1eaa:      	pop	{r7, pc}

00001eac <_RNCNvXs51_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_28INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1eac:      	push	{r7, lr}
    1eae:      	mov	r7, sp
    1eb0:      	sub	sp, #0x1c
    1eb2:      	str	r0, [sp, #0x4]
    1eb4:      	str	r0, [sp, #0x8]
    1eb6:      	mov.w	r1, #0x10000000
    1eba:      	str	r1, [sp, #0xc]
    1ebc:      	str	r0, [sp, #0x10]
    1ebe:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1ec0:      	str	r1, [r0]
    1ec2:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1ec4:      	add	sp, #0x1c
    1ec6:      	pop	{r7, pc}

00001ec8 <_RNCNvXs5n_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_30INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1ec8:      	push	{r7, lr}
    1eca:      	mov	r7, sp
    1ecc:      	sub	sp, #0x1c
    1ece:      	str	r0, [sp, #0x4]
    1ed0:      	str	r0, [sp, #0x8]
    1ed2:      	mov.w	r1, #0x40000000
    1ed6:      	str	r1, [sp, #0xc]
    1ed8:      	str	r0, [sp, #0x10]
    1eda:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1edc:      	str	r1, [r0]
    1ede:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1ee0:      	add	sp, #0x1c
    1ee2:      	pop	{r7, pc}

00001ee4 <_RNCNvXs5n_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_30INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1ee4:      	push	{r7, lr}
    1ee6:      	mov	r7, sp
    1ee8:      	sub	sp, #0x1c
    1eea:      	str	r0, [sp, #0x4]
    1eec:      	str	r0, [sp, #0x8]
    1eee:      	mov.w	r1, #0x40000000
    1ef2:      	str	r1, [sp, #0xc]
    1ef4:      	str	r0, [sp, #0x10]
    1ef6:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1ef8:      	str	r1, [r0]
    1efa:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1efc:      	add	sp, #0x1c
    1efe:      	pop	{r7, pc}

00001f00 <_RNCNvXs5y_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_31INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1f00:      	push	{r7, lr}
    1f02:      	mov	r7, sp
    1f04:      	sub	sp, #0x1c
    1f06:      	str	r0, [sp, #0x4]
    1f08:      	str	r0, [sp, #0x8]
    1f0a:      	mov.w	r1, #0x80000000
    1f0e:      	str	r1, [sp, #0xc]
    1f10:      	str	r0, [sp, #0x10]
    1f12:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1f14:      	str	r1, [r0]
    1f16:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1f18:      	add	sp, #0x1c
    1f1a:      	pop	{r7, pc}

00001f1c <_RNCNvXs5y_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_31INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1f1c:      	push	{r7, lr}
    1f1e:      	mov	r7, sp
    1f20:      	sub	sp, #0x1c
    1f22:      	str	r0, [sp, #0x4]
    1f24:      	str	r0, [sp, #0x8]
    1f26:      	mov.w	r1, #0x80000000
    1f2a:      	str	r1, [sp, #0xc]
    1f2c:      	str	r0, [sp, #0x10]
    1f2e:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1f30:      	str	r1, [r0]
    1f32:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1f34:      	add	sp, #0x1c
    1f36:      	pop	{r7, pc}

00001f38 <_RNCNvXsW_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB7_5P1_05INtB9_6OutputNtB9_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1f38:      	push	{r7, lr}
    1f3a:      	mov	r7, sp
    1f3c:      	sub	sp, #0x1c
    1f3e:      	str	r0, [sp, #0x4]
    1f40:      	str	r0, [sp, #0x8]
    1f42:      	movs	r1, #0x20
    1f44:      	str	r1, [sp, #0xc]
    1f46:      	str	r0, [sp, #0x10]
    1f48:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1f4a:      	str	r1, [r0]
    1f4c:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    1f4e:      	add	sp, #0x1c
    1f50:      	pop	{r7, pc}

00001f52 <_RNCNvXsW_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB7_5P1_05INtB9_6OutputNtB9_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common>:
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1f52:      	push	{r7, lr}
    1f54:      	mov	r7, sp
    1f56:      	sub	sp, #0x1c
    1f58:      	str	r0, [sp, #0x4]
    1f5a:      	str	r0, [sp, #0x8]
    1f5c:      	movs	r1, #0x20
    1f5e:      	str	r1, [sp, #0xc]
    1f60:      	str	r0, [sp, #0x10]
    1f62:      	str	r1, [sp, #0x14]
;         self.bits = bits;
    1f64:      	str	r1, [r0]
    1f66:      	str	r0, [sp, #0x18]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    1f68:      	add	sp, #0x1c
    1f6a:      	pop	{r7, pc}

00001f6c <_RNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output(self, initial_output: Level)
    1f6c:      	push	{r7, lr}
    1f6e:      	mov	r7, sp
    1f70:      	sub	sp, #0x8
    1f72:      	strb	r0, [r7, #-2]
    1f76:      	movs	r1, #0x0
;                         self.into_push_pull_output_drive(initial_output, DriveConfig::Standard0Standard1)
    1f78:      	bl	0x1f80 <_RNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common> @ imm = #0x4
;                     }
    1f7c:      	add	sp, #0x8
    1f7e:      	pop	{r7, pc}

00001f80 <_RNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output_drive(self, initial_output: Level, drive: DriveConfig)
    1f80:      	push	{r7, lr}
    1f82:      	mov	r7, sp
    1f84:      	sub	sp, #0x38
    1f86:      	strb	r1, [r7, #-42]
    1f8a:      	strb	r0, [r7, #-39]
;                         match initial_output {
    1f8e:      	cbz	r0, 0x1f9c <_RNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x1c> @ imm = #0xa
    1f90:      	b	0x1f92 <_RNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x12> @ imm = #-0x2
    1f92:      	sub.w	r0, r7, #0x29
;                             Level::High => pin.set_high().unwrap(),
    1f96:      	bl	0x25f0 <_RNvXs20_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common> @ imm = #0x656
    1f9a:      	b	0x1fa6 <_RNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #0x8
    1f9c:      	sub.w	r0, r7, #0x29
;                             Level::Low  => pin.set_low().unwrap(),
    1fa0:      	bl	0x25a6 <_RNvXs20_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common> @ imm = #0x602
    1fa4:      	b	0x1fa6 <_RNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #-0x2
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    1fa6:      	movw	r0, #0x72c
    1faa:      	movt	r0, #0x5000
    1fae:      	str	r0, [sp, #0x4]
    1fb0:      	str	r0, [sp, #0x18]
    1fb2:      	sub.w	r0, r7, #0x2a
    1fb6:      	str	r0, [sp, #0x1c]
    1fb8:      	movs	r1, #0x2
    1fba:      	str	r1, [sp, #0x34]
;             f(&mut REG::Writer::from(W {
    1fbc:      	str	r1, [sp, #0x14]
    1fbe:      	add	r1, sp, #0x14
    1fc0:      	bl	0x63c <_RNCNvMs1W_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_11NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common> @ imm = #-0x1988
    1fc4:      	mov	r1, r0
    1fc6:      	ldr	r0, [sp, #0x4]
    1fc8:      	ldr	r1, [r1]
    1fca:      	str	r1, [sp, #0x8]
    1fcc:      	str	r0, [sp, #0x20]
    1fce:      	str	r1, [sp, #0x24]
    1fd0:      	str	r0, [sp, #0x30]
    1fd2:      	str	r0, [sp, #0x28]
    1fd4:      	str	r1, [sp, #0x2c]
;                 precondition_check($($arg,)*);
    1fd6:      	movw	r2, #0x5ca0
    1fda:      	movt	r2, #0x0
    1fde:      	movs	r1, #0x4
    1fe0:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #0x534
    1fe4:      	ldr	r1, [sp, #0x4]
    1fe6:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    1fe8:      	str	r0, [r1]
;                     }
    1fea:      	add	sp, #0x38
    1fec:      	pop	{r7, pc}

00001fee <_RNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output(self, initial_output: Level)
    1fee:      	push	{r7, lr}
    1ff0:      	mov	r7, sp
    1ff2:      	sub	sp, #0x8
    1ff4:      	strb	r0, [r7, #-2]
    1ff8:      	movs	r1, #0x0
;                         self.into_push_pull_output_drive(initial_output, DriveConfig::Standard0Standard1)
    1ffa:      	bl	0x2002 <_RNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common> @ imm = #0x4
;                     }
    1ffe:      	add	sp, #0x8
    2000:      	pop	{r7, pc}

00002002 <_RNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output_drive(self, initial_output: Level, drive: DriveConfig)
    2002:      	push	{r7, lr}
    2004:      	mov	r7, sp
    2006:      	sub	sp, #0x38
    2008:      	strb	r1, [r7, #-42]
    200c:      	strb	r0, [r7, #-39]
;                         match initial_output {
    2010:      	cbz	r0, 0x201e <_RNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x1c> @ imm = #0xa
    2012:      	b	0x2014 <_RNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x12> @ imm = #-0x2
    2014:      	sub.w	r0, r7, #0x29
;                             Level::High => pin.set_high().unwrap(),
    2018:      	bl	0x2684 <_RNvXs2I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common> @ imm = #0x668
    201c:      	b	0x2028 <_RNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #0x8
    201e:      	sub.w	r0, r7, #0x29
;                             Level::Low  => pin.set_low().unwrap(),
    2022:      	bl	0x263a <_RNvXs2I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common> @ imm = #0x614
    2026:      	b	0x2028 <_RNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #-0x2
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    2028:      	movw	r0, #0x73c
    202c:      	movt	r0, #0x5000
    2030:      	str	r0, [sp, #0x4]
    2032:      	str	r0, [sp, #0x18]
    2034:      	sub.w	r0, r7, #0x2a
    2038:      	str	r0, [sp, #0x1c]
    203a:      	movs	r1, #0x2
    203c:      	str	r1, [sp, #0x34]
;             f(&mut REG::Writer::from(W {
    203e:      	str	r1, [sp, #0x14]
    2040:      	add	r1, sp, #0x14
    2042:      	bl	0x884 <_RNCNvMs2E_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_15NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common> @ imm = #-0x17c2
    2046:      	mov	r1, r0
    2048:      	ldr	r0, [sp, #0x4]
    204a:      	ldr	r1, [r1]
    204c:      	str	r1, [sp, #0x8]
    204e:      	str	r0, [sp, #0x20]
    2050:      	str	r1, [sp, #0x24]
    2052:      	str	r0, [sp, #0x30]
    2054:      	str	r0, [sp, #0x28]
    2056:      	str	r1, [sp, #0x2c]
;                 precondition_check($($arg,)*);
    2058:      	movw	r2, #0x5ca0
    205c:      	movt	r2, #0x0
    2060:      	movs	r1, #0x4
    2062:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #0x4b2
    2066:      	ldr	r1, [sp, #0x4]
    2068:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    206a:      	str	r0, [r1]
;                     }
    206c:      	add	sp, #0x38
    206e:      	pop	{r7, pc}

00002070 <_RNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output(self, initial_output: Level)
    2070:      	push	{r7, lr}
    2072:      	mov	r7, sp
    2074:      	sub	sp, #0x8
    2076:      	strb	r0, [r7, #-2]
    207a:      	movs	r1, #0x0
;                         self.into_push_pull_output_drive(initial_output, DriveConfig::Standard0Standard1)
    207c:      	bl	0x2084 <_RNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common> @ imm = #0x4
;                     }
    2080:      	add	sp, #0x8
    2082:      	pop	{r7, pc}

00002084 <_RNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output_drive(self, initial_output: Level, drive: DriveConfig)
    2084:      	push	{r7, lr}
    2086:      	mov	r7, sp
    2088:      	sub	sp, #0x38
    208a:      	strb	r1, [r7, #-42]
    208e:      	strb	r0, [r7, #-39]
;                         match initial_output {
    2092:      	cbz	r0, 0x20a0 <_RNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x1c> @ imm = #0xa
    2094:      	b	0x2096 <_RNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x12> @ imm = #-0x2
    2096:      	sub.w	r0, r7, #0x29
;                             Level::High => pin.set_high().unwrap(),
    209a:      	bl	0x2718 <_RNvXs3M_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common> @ imm = #0x67a
    209e:      	b	0x20aa <_RNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #0x8
    20a0:      	sub.w	r0, r7, #0x29
;                             Level::Low  => pin.set_low().unwrap(),
    20a4:      	bl	0x26ce <_RNvXs3M_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common> @ imm = #0x626
    20a8:      	b	0x20aa <_RNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #-0x2
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    20aa:      	movw	r0, #0x754
    20ae:      	movt	r0, #0x5000
    20b2:      	str	r0, [sp, #0x4]
    20b4:      	str	r0, [sp, #0x18]
    20b6:      	sub.w	r0, r7, #0x2a
    20ba:      	str	r0, [sp, #0x1c]
    20bc:      	movs	r1, #0x2
    20be:      	str	r1, [sp, #0x34]
;             f(&mut REG::Writer::from(W {
    20c0:      	str	r1, [sp, #0x14]
    20c2:      	add	r1, sp, #0x14
    20c4:      	bl	0xacc <_RNCNvMs3I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_21NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common> @ imm = #-0x15fc
    20c8:      	mov	r1, r0
    20ca:      	ldr	r0, [sp, #0x4]
    20cc:      	ldr	r1, [r1]
    20ce:      	str	r1, [sp, #0x8]
    20d0:      	str	r0, [sp, #0x20]
    20d2:      	str	r1, [sp, #0x24]
    20d4:      	str	r0, [sp, #0x30]
    20d6:      	str	r0, [sp, #0x28]
    20d8:      	str	r1, [sp, #0x2c]
;                 precondition_check($($arg,)*);
    20da:      	movw	r2, #0x5ca0
    20de:      	movt	r2, #0x0
    20e2:      	movs	r1, #0x4
    20e4:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #0x430
    20e8:      	ldr	r1, [sp, #0x4]
    20ea:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    20ec:      	str	r0, [r1]
;                     }
    20ee:      	add	sp, #0x38
    20f0:      	pop	{r7, pc}

000020f2 <_RNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output(self, initial_output: Level)
    20f2:      	push	{r7, lr}
    20f4:      	mov	r7, sp
    20f6:      	sub	sp, #0x8
    20f8:      	strb	r0, [r7, #-2]
    20fc:      	movs	r1, #0x0
;                         self.into_push_pull_output_drive(initial_output, DriveConfig::Standard0Standard1)
    20fe:      	bl	0x2106 <_RNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common> @ imm = #0x4
;                     }
    2102:      	add	sp, #0x8
    2104:      	pop	{r7, pc}

00002106 <_RNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output_drive(self, initial_output: Level, drive: DriveConfig)
    2106:      	push	{r7, lr}
    2108:      	mov	r7, sp
    210a:      	sub	sp, #0x38
    210c:      	strb	r1, [r7, #-42]
    2110:      	strb	r0, [r7, #-39]
;                         match initial_output {
    2114:      	cbz	r0, 0x2122 <_RNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x1c> @ imm = #0xa
    2116:      	b	0x2118 <_RNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x12> @ imm = #-0x2
    2118:      	sub.w	r0, r7, #0x29
;                             Level::High => pin.set_high().unwrap(),
    211c:      	bl	0x27ac <_RNvXs3X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common> @ imm = #0x68c
    2120:      	b	0x212c <_RNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #0x8
    2122:      	sub.w	r0, r7, #0x29
;                             Level::Low  => pin.set_low().unwrap(),
    2126:      	bl	0x2762 <_RNvXs3X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common> @ imm = #0x638
    212a:      	b	0x212c <_RNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #-0x2
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    212c:      	movw	r0, #0x758
    2130:      	movt	r0, #0x5000
    2134:      	str	r0, [sp, #0x4]
    2136:      	str	r0, [sp, #0x18]
    2138:      	sub.w	r0, r7, #0x2a
    213c:      	str	r0, [sp, #0x1c]
    213e:      	movs	r1, #0x2
    2140:      	str	r1, [sp, #0x34]
;             f(&mut REG::Writer::from(W {
    2142:      	str	r1, [sp, #0x14]
    2144:      	add	r1, sp, #0x14
    2146:      	bl	0xd14 <_RNCNvMs3T_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_22NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common> @ imm = #-0x1436
    214a:      	mov	r1, r0
    214c:      	ldr	r0, [sp, #0x4]
    214e:      	ldr	r1, [r1]
    2150:      	str	r1, [sp, #0x8]
    2152:      	str	r0, [sp, #0x20]
    2154:      	str	r1, [sp, #0x24]
    2156:      	str	r0, [sp, #0x30]
    2158:      	str	r0, [sp, #0x28]
    215a:      	str	r1, [sp, #0x2c]
;                 precondition_check($($arg,)*);
    215c:      	movw	r2, #0x5ca0
    2160:      	movt	r2, #0x0
    2164:      	movs	r1, #0x4
    2166:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #0x3ae
    216a:      	ldr	r1, [sp, #0x4]
    216c:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    216e:      	str	r0, [r1]
;                     }
    2170:      	add	sp, #0x38
    2172:      	pop	{r7, pc}

00002174 <_RNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output(self, initial_output: Level)
    2174:      	push	{r7, lr}
    2176:      	mov	r7, sp
    2178:      	sub	sp, #0x8
    217a:      	strb	r0, [r7, #-2]
    217e:      	movs	r1, #0x0
;                         self.into_push_pull_output_drive(initial_output, DriveConfig::Standard0Standard1)
    2180:      	bl	0x2188 <_RNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common> @ imm = #0x4
;                     }
    2184:      	add	sp, #0x8
    2186:      	pop	{r7, pc}

00002188 <_RNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output_drive(self, initial_output: Level, drive: DriveConfig)
    2188:      	push	{r7, lr}
    218a:      	mov	r7, sp
    218c:      	sub	sp, #0x38
    218e:      	strb	r1, [r7, #-42]
    2192:      	strb	r0, [r7, #-39]
;                         match initial_output {
    2196:      	cbz	r0, 0x21a4 <_RNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x1c> @ imm = #0xa
    2198:      	b	0x219a <_RNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x12> @ imm = #-0x2
    219a:      	sub.w	r0, r7, #0x29
;                             Level::High => pin.set_high().unwrap(),
    219e:      	bl	0x2840 <_RNvXs3q_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common> @ imm = #0x69e
    21a2:      	b	0x21ae <_RNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #0x8
    21a4:      	sub.w	r0, r7, #0x29
;                             Level::Low  => pin.set_low().unwrap(),
    21a8:      	bl	0x27f6 <_RNvXs3q_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common> @ imm = #0x64a
    21ac:      	b	0x21ae <_RNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #-0x2
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    21ae:      	movw	r0, #0x74c
    21b2:      	movt	r0, #0x5000
    21b6:      	str	r0, [sp, #0x4]
    21b8:      	str	r0, [sp, #0x18]
    21ba:      	sub.w	r0, r7, #0x2a
    21be:      	str	r0, [sp, #0x1c]
    21c0:      	movs	r1, #0x2
    21c2:      	str	r1, [sp, #0x34]
;             f(&mut REG::Writer::from(W {
    21c4:      	str	r1, [sp, #0x14]
    21c6:      	add	r1, sp, #0x14
    21c8:      	bl	0xf5c <_RNCNvMs3m_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_19NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common> @ imm = #-0x1270
    21cc:      	mov	r1, r0
    21ce:      	ldr	r0, [sp, #0x4]
    21d0:      	ldr	r1, [r1]
    21d2:      	str	r1, [sp, #0x8]
    21d4:      	str	r0, [sp, #0x20]
    21d6:      	str	r1, [sp, #0x24]
    21d8:      	str	r0, [sp, #0x30]
    21da:      	str	r0, [sp, #0x28]
    21dc:      	str	r1, [sp, #0x2c]
;                 precondition_check($($arg,)*);
    21de:      	movw	r2, #0x5ca0
    21e2:      	movt	r2, #0x0
    21e6:      	movs	r1, #0x4
    21e8:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #0x32c
    21ec:      	ldr	r1, [sp, #0x4]
    21ee:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    21f0:      	str	r0, [r1]
;                     }
    21f2:      	add	sp, #0x38
    21f4:      	pop	{r7, pc}

000021f6 <_RNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output(self, initial_output: Level)
    21f6:      	push	{r7, lr}
    21f8:      	mov	r7, sp
    21fa:      	sub	sp, #0x8
    21fc:      	strb	r0, [r7, #-2]
    2200:      	movs	r1, #0x0
;                         self.into_push_pull_output_drive(initial_output, DriveConfig::Standard0Standard1)
    2202:      	bl	0x220a <_RNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common> @ imm = #0x4
;                     }
    2206:      	add	sp, #0x8
    2208:      	pop	{r7, pc}

0000220a <_RNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output_drive(self, initial_output: Level, drive: DriveConfig)
    220a:      	push	{r7, lr}
    220c:      	mov	r7, sp
    220e:      	sub	sp, #0x38
    2210:      	strb	r1, [r7, #-42]
    2214:      	strb	r0, [r7, #-39]
;                         match initial_output {
    2218:      	cbz	r0, 0x2226 <_RNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x1c> @ imm = #0xa
    221a:      	b	0x221c <_RNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x12> @ imm = #-0x2
    221c:      	sub.w	r0, r7, #0x29
;                             Level::High => pin.set_high().unwrap(),
    2220:      	bl	0x2968 <_RNvXs51_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common> @ imm = #0x744
    2224:      	b	0x2230 <_RNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #0x8
    2226:      	sub.w	r0, r7, #0x29
;                             Level::Low  => pin.set_low().unwrap(),
    222a:      	bl	0x291e <_RNvXs51_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common> @ imm = #0x6f0
    222e:      	b	0x2230 <_RNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #-0x2
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    2230:      	movw	r0, #0x770
    2234:      	movt	r0, #0x5000
    2238:      	str	r0, [sp, #0x4]
    223a:      	str	r0, [sp, #0x18]
    223c:      	sub.w	r0, r7, #0x2a
    2240:      	str	r0, [sp, #0x1c]
    2242:      	movs	r1, #0x2
    2244:      	str	r1, [sp, #0x34]
;             f(&mut REG::Writer::from(W {
    2246:      	str	r1, [sp, #0x14]
    2248:      	add	r1, sp, #0x14
    224a:      	bl	0x11a4 <_RNCNvMs4X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_28NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common> @ imm = #-0x10aa
    224e:      	mov	r1, r0
    2250:      	ldr	r0, [sp, #0x4]
    2252:      	ldr	r1, [r1]
    2254:      	str	r1, [sp, #0x8]
    2256:      	str	r0, [sp, #0x20]
    2258:      	str	r1, [sp, #0x24]
    225a:      	str	r0, [sp, #0x30]
    225c:      	str	r0, [sp, #0x28]
    225e:      	str	r1, [sp, #0x2c]
;                 precondition_check($($arg,)*);
    2260:      	movw	r2, #0x5ca0
    2264:      	movt	r2, #0x0
    2268:      	movs	r1, #0x4
    226a:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #0x2aa
    226e:      	ldr	r1, [sp, #0x4]
    2270:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2272:      	str	r0, [r1]
;                     }
    2274:      	add	sp, #0x38
    2276:      	pop	{r7, pc}

00002278 <_RNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output(self, initial_output: Level)
    2278:      	push	{r7, lr}
    227a:      	mov	r7, sp
    227c:      	sub	sp, #0x8
    227e:      	strb	r0, [r7, #-2]
    2282:      	movs	r1, #0x0
;                         self.into_push_pull_output_drive(initial_output, DriveConfig::Standard0Standard1)
    2284:      	bl	0x228c <_RNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common> @ imm = #0x4
;                     }
    2288:      	add	sp, #0x8
    228a:      	pop	{r7, pc}

0000228c <_RNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output_drive(self, initial_output: Level, drive: DriveConfig)
    228c:      	push	{r7, lr}
    228e:      	mov	r7, sp
    2290:      	sub	sp, #0x38
    2292:      	strb	r1, [r7, #-42]
    2296:      	strb	r0, [r7, #-39]
;                         match initial_output {
    229a:      	cbz	r0, 0x22a8 <_RNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x1c> @ imm = #0xa
    229c:      	b	0x229e <_RNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x12> @ imm = #-0x2
    229e:      	sub.w	r0, r7, #0x29
;                             Level::High => pin.set_high().unwrap(),
    22a2:      	bl	0x28d4 <_RNvXs4j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common> @ imm = #0x62e
    22a6:      	b	0x22b2 <_RNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #0x8
    22a8:      	sub.w	r0, r7, #0x29
;                             Level::Low  => pin.set_low().unwrap(),
    22ac:      	bl	0x288a <_RNvXs4j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common> @ imm = #0x5da
    22b0:      	b	0x22b2 <_RNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #-0x2
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    22b2:      	movw	r0, #0x760
    22b6:      	movt	r0, #0x5000
    22ba:      	str	r0, [sp, #0x4]
    22bc:      	str	r0, [sp, #0x18]
    22be:      	sub.w	r0, r7, #0x2a
    22c2:      	str	r0, [sp, #0x1c]
    22c4:      	movs	r1, #0x2
    22c6:      	str	r1, [sp, #0x34]
;             f(&mut REG::Writer::from(W {
    22c8:      	str	r1, [sp, #0x14]
    22ca:      	add	r1, sp, #0x14
    22cc:      	bl	0x13ec <_RNCNvMs4f_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_24NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common> @ imm = #-0xee4
    22d0:      	mov	r1, r0
    22d2:      	ldr	r0, [sp, #0x4]
    22d4:      	ldr	r1, [r1]
    22d6:      	str	r1, [sp, #0x8]
    22d8:      	str	r0, [sp, #0x20]
    22da:      	str	r1, [sp, #0x24]
    22dc:      	str	r0, [sp, #0x30]
    22de:      	str	r0, [sp, #0x28]
    22e0:      	str	r1, [sp, #0x2c]
;                 precondition_check($($arg,)*);
    22e2:      	movw	r2, #0x5ca0
    22e6:      	movt	r2, #0x0
    22ea:      	movs	r1, #0x4
    22ec:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #0x228
    22f0:      	ldr	r1, [sp, #0x4]
    22f2:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    22f4:      	str	r0, [r1]
;                     }
    22f6:      	add	sp, #0x38
    22f8:      	pop	{r7, pc}

000022fa <_RNvMs4r_Cs9keDkRYv3gL_12nrf52833_pacNtB6_11Peripherals5stealCslicV2bA46s8_15microbit_common>:
;     pub unsafe fn steal() -> Self {
    22fa:      	push	{r7, lr}
    22fc:      	mov	r7, sp
;         DEVICE_PERIPHERALS = true;
    22fe:      	movw	r1, #0x434
    2302:      	movt	r1, #0x2000
    2306:      	movs	r0, #0x1
    2308:      	strb	r0, [r1]
;     }
    230a:      	pop	{r7, pc}

0000230c <_RNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output(self, initial_output: Level)
    230c:      	push	{r7, lr}
    230e:      	mov	r7, sp
    2310:      	sub	sp, #0x8
    2312:      	strb	r0, [r7, #-2]
    2316:      	movs	r1, #0x0
;                         self.into_push_pull_output_drive(initial_output, DriveConfig::Standard0Standard1)
    2318:      	bl	0x2320 <_RNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common> @ imm = #0x4
;                     }
    231c:      	add	sp, #0x8
    231e:      	pop	{r7, pc}

00002320 <_RNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output_drive(self, initial_output: Level, drive: DriveConfig)
    2320:      	push	{r7, lr}
    2322:      	mov	r7, sp
    2324:      	sub	sp, #0x38
    2326:      	strb	r1, [r7, #-42]
    232a:      	strb	r0, [r7, #-39]
;                         match initial_output {
    232e:      	cbz	r0, 0x233c <_RNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x1c> @ imm = #0xa
    2330:      	b	0x2332 <_RNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x12> @ imm = #-0x2
    2332:      	sub.w	r0, r7, #0x29
;                             Level::High => pin.set_high().unwrap(),
    2336:      	bl	0x29fc <_RNvXs5n_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common> @ imm = #0x6c2
    233a:      	b	0x2346 <_RNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #0x8
    233c:      	sub.w	r0, r7, #0x29
;                             Level::Low  => pin.set_low().unwrap(),
    2340:      	bl	0x29b2 <_RNvXs5n_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common> @ imm = #0x66e
    2344:      	b	0x2346 <_RNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #-0x2
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    2346:      	movw	r0, #0x778
    234a:      	movt	r0, #0x5000
    234e:      	str	r0, [sp, #0x4]
    2350:      	str	r0, [sp, #0x18]
    2352:      	sub.w	r0, r7, #0x2a
    2356:      	str	r0, [sp, #0x1c]
    2358:      	movs	r1, #0x2
    235a:      	str	r1, [sp, #0x34]
;             f(&mut REG::Writer::from(W {
    235c:      	str	r1, [sp, #0x14]
    235e:      	add	r1, sp, #0x14
    2360:      	bl	0x1668 <_RNCNvMs5j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_30NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common> @ imm = #-0xcfc
    2364:      	mov	r1, r0
    2366:      	ldr	r0, [sp, #0x4]
    2368:      	ldr	r1, [r1]
    236a:      	str	r1, [sp, #0x8]
    236c:      	str	r0, [sp, #0x20]
    236e:      	str	r1, [sp, #0x24]
    2370:      	str	r0, [sp, #0x30]
    2372:      	str	r0, [sp, #0x28]
    2374:      	str	r1, [sp, #0x2c]
;                 precondition_check($($arg,)*);
    2376:      	movw	r2, #0x5ca0
    237a:      	movt	r2, #0x0
    237e:      	movs	r1, #0x4
    2380:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #0x194
    2384:      	ldr	r1, [sp, #0x4]
    2386:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2388:      	str	r0, [r1]
;                     }
    238a:      	add	sp, #0x38
    238c:      	pop	{r7, pc}

0000238e <_RNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31NtB8_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output(self, initial_output: Level)
    238e:      	push	{r7, lr}
    2390:      	mov	r7, sp
    2392:      	sub	sp, #0x8
    2394:      	strb	r0, [r7, #-2]
    2398:      	movs	r1, #0x0
;                         self.into_push_pull_output_drive(initial_output, DriveConfig::Standard0Standard1)
    239a:      	bl	0x23a2 <_RNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common> @ imm = #0x4
;                     }
    239e:      	add	sp, #0x8
    23a0:      	pop	{r7, pc}

000023a2 <_RNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output_drive(self, initial_output: Level, drive: DriveConfig)
    23a2:      	push	{r7, lr}
    23a4:      	mov	r7, sp
    23a6:      	sub	sp, #0x38
    23a8:      	strb	r1, [r7, #-42]
    23ac:      	strb	r0, [r7, #-39]
;                         match initial_output {
    23b0:      	cbz	r0, 0x23be <_RNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x1c> @ imm = #0xa
    23b2:      	b	0x23b4 <_RNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x12> @ imm = #-0x2
    23b4:      	sub.w	r0, r7, #0x29
;                             Level::High => pin.set_high().unwrap(),
    23b8:      	bl	0x2a90 <_RNvXs5y_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common> @ imm = #0x6d4
    23bc:      	b	0x23c8 <_RNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #0x8
    23be:      	sub.w	r0, r7, #0x29
;                             Level::Low  => pin.set_low().unwrap(),
    23c2:      	bl	0x2a46 <_RNvXs5y_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common> @ imm = #0x680
    23c6:      	b	0x23c8 <_RNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31NtB8_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #-0x2
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    23c8:      	movw	r0, #0x77c
    23cc:      	movt	r0, #0x5000
    23d0:      	str	r0, [sp, #0x4]
    23d2:      	str	r0, [sp, #0x18]
    23d4:      	sub.w	r0, r7, #0x2a
    23d8:      	str	r0, [sp, #0x1c]
    23da:      	movs	r1, #0x2
    23dc:      	str	r1, [sp, #0x34]
;             f(&mut REG::Writer::from(W {
    23de:      	str	r1, [sp, #0x14]
    23e0:      	add	r1, sp, #0x14
    23e2:      	bl	0x18b0 <_RNCNvMs5u_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_31NtBa_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common> @ imm = #-0xb36
    23e6:      	mov	r1, r0
    23e8:      	ldr	r0, [sp, #0x4]
    23ea:      	ldr	r1, [r1]
    23ec:      	str	r1, [sp, #0x8]
    23ee:      	str	r0, [sp, #0x20]
    23f0:      	str	r1, [sp, #0x24]
    23f2:      	str	r0, [sp, #0x30]
    23f4:      	str	r0, [sp, #0x28]
    23f6:      	str	r1, [sp, #0x2c]
;                 precondition_check($($arg,)*);
    23f8:      	movw	r2, #0x5ca0
    23fc:      	movt	r2, #0x0
    2400:      	movs	r1, #0x4
    2402:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #0x112
    2406:      	ldr	r1, [sp, #0x4]
    2408:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    240a:      	str	r0, [r1]
;                     }
    240c:      	add	sp, #0x38
    240e:      	pop	{r7, pc}

00002410 <_RNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05NtB7_12DisconnectedE21into_push_pull_outputCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output(self, initial_output: Level)
    2410:      	push	{r7, lr}
    2412:      	mov	r7, sp
    2414:      	sub	sp, #0x8
    2416:      	strb	r0, [r7, #-2]
    241a:      	movs	r1, #0x0
;                         self.into_push_pull_output_drive(initial_output, DriveConfig::Standard0Standard1)
    241c:      	bl	0x2424 <_RNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05NtB7_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common> @ imm = #0x4
;                     }
    2420:      	add	sp, #0x8
    2422:      	pop	{r7, pc}

00002424 <_RNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05NtB7_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common>:
;                     pub fn into_push_pull_output_drive(self, initial_output: Level, drive: DriveConfig)
    2424:      	push	{r7, lr}
    2426:      	mov	r7, sp
    2428:      	sub	sp, #0x38
    242a:      	strb	r1, [r7, #-42]
    242e:      	strb	r0, [r7, #-39]
;                         match initial_output {
    2432:      	cbz	r0, 0x2440 <_RNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05NtB7_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x1c> @ imm = #0xa
    2434:      	b	0x2436 <_RNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05NtB7_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x12> @ imm = #-0x2
    2436:      	sub.w	r0, r7, #0x29
;                             Level::High => pin.set_high().unwrap(),
    243a:      	bl	0x2b24 <_RNvXsW_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05INtB7_6OutputNtB7_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common> @ imm = #0x6e6
    243e:      	b	0x244a <_RNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05NtB7_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #0x8
    2440:      	sub.w	r0, r7, #0x29
;                             Level::Low  => pin.set_low().unwrap(),
    2444:      	bl	0x2ada <_RNvXsW_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05INtB7_6OutputNtB7_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common> @ imm = #0x692
    2448:      	b	0x244a <_RNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05NtB7_12DisconnectedE27into_push_pull_output_driveCslicV2bA46s8_15microbit_common+0x26> @ imm = #-0x2
;                         unsafe { &(*$PX::ptr()).pin_cnf[$i] }.write(|w| {
    244a:      	movw	r0, #0xa14
    244e:      	movt	r0, #0x5000
    2452:      	str	r0, [sp, #0x4]
    2454:      	str	r0, [sp, #0x18]
    2456:      	sub.w	r0, r7, #0x2a
    245a:      	str	r0, [sp, #0x1c]
    245c:      	movs	r1, #0x2
    245e:      	str	r1, [sp, #0x34]
;             f(&mut REG::Writer::from(W {
    2460:      	str	r1, [sp, #0x14]
    2462:      	add	r1, sp, #0x14
    2464:      	bl	0x1af8 <_RNCNvMsS_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB7_5P1_05NtB9_12DisconnectedE27into_push_pull_output_drive0CslicV2bA46s8_15microbit_common> @ imm = #-0x970
    2468:      	mov	r1, r0
    246a:      	ldr	r0, [sp, #0x4]
    246c:      	ldr	r1, [r1]
    246e:      	str	r1, [sp, #0x8]
    2470:      	str	r0, [sp, #0x20]
    2472:      	str	r1, [sp, #0x24]
    2474:      	str	r0, [sp, #0x30]
    2476:      	str	r0, [sp, #0x28]
    2478:      	str	r1, [sp, #0x2c]
;                 precondition_check($($arg,)*);
    247a:      	movw	r2, #0x5ca0
    247e:      	movt	r2, #0x0
    2482:      	movs	r1, #0x4
    2484:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #0x90
    2488:      	ldr	r1, [sp, #0x4]
    248a:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    248c:      	str	r0, [r1]
;                     }
    248e:      	add	sp, #0x38
    2490:      	pop	{r7, pc}

00002492 <_RNvNtCs87vGccmtUh2_8cortex_m9interrupt7disableCslicV2bA46s8_15microbit_common>:
; #[asm_cfg(cortex_m)]
    2492:      	push	{r7, lr}
    2494:      	mov	r7, sp
;     unsafe { asm!("cpsid i", options(nomem, nostack, preserves_flags)) };
    2496:      	cpsid i
;     compiler_fence(Ordering::SeqCst);
    2498:      	movs	r0, #0x4
    249a:      	bl	0x24a0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCslicV2bA46s8_15microbit_common> @ imm = #0x2
; #[asm_cfg(cortex_m)]
    249e:      	pop	{r7, pc}

000024a0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCslicV2bA46s8_15microbit_common>:
; pub const fn compiler_fence(order: Ordering) {
    24a0:      	push	{r7, lr}
    24a2:      	mov	r7, sp
    24a4:      	sub	sp, #0x10
    24a6:      	strb	r0, [r7, #-9]
;         match order {
    24aa:      	uxtb	r0, r0
    24ac:      	str	r0, [sp]
    24ae:      	ldr	r1, [sp]
    24b0:      	tbb	[pc, r1]
    24b4: 04 12 13 14  	.word	0x14131204
    24b8: 15 00	.short	0x0015
    24ba:      	trap
;             Relaxed => panic!("there is no such thing as a relaxed fence"),
    24bc:      	movw	r0, #0x5cc0
    24c0:      	movt	r0, #0x0
    24c4:      	str	r0, [sp, #0x8]
    24c6:      	movs	r1, #0x29
    24c8:      	str	r1, [sp, #0xc]
    24ca:      	movw	r2, #0x5cec
    24ce:      	movt	r2, #0x0
    24d2:      	movs	r1, #0x53
    24d4:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x2368
;             Release => intrinsics::atomic_singlethreadfence::<{ AO::Release }>(),
    24d8:      	b	0x24e0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCslicV2bA46s8_15microbit_common+0x40> @ imm = #0x4
;             Acquire => intrinsics::atomic_singlethreadfence::<{ AO::Acquire }>(),
    24da:      	b	0x24e0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCslicV2bA46s8_15microbit_common+0x40> @ imm = #0x2
;             AcqRel => intrinsics::atomic_singlethreadfence::<{ AO::AcqRel }>(),
    24dc:      	b	0x24e0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCslicV2bA46s8_15microbit_common+0x40> @ imm = #0x0
;             SeqCst => intrinsics::atomic_singlethreadfence::<{ AO::SeqCst }>(),
    24de:      	b	0x24e0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCslicV2bA46s8_15microbit_common+0x40> @ imm = #-0x2
; }
    24e0:      	add	sp, #0x10
    24e2:      	pop	{r7, pc}

000024e4 <_RNvNtNtCs87vGccmtUh2_8cortex_m8register7primask8read_rawCslicV2bA46s8_15microbit_common>:
; #[asm_cfg(cortex_m)]
    24e4:      	push	{r7, lr}
    24e6:      	mov	r7, sp
    24e8:      	sub	sp, #0x4
;     unsafe { asm!("mrs {}, PRIMASK", out(reg) r, options(nomem, nostack, preserves_flags)) };
    24ea:      	mrs	r0, primask
    24ee:      	str	r0, [sp]
;     r
    24f0:      	ldr	r0, [sp]
; #[asm_cfg(cortex_m)]
    24f2:      	add	sp, #0x4
    24f4:      	pop	{r7, pc}

000024f6 <_RNvNtNtCs87vGccmtUh2_8cortex_m8register7primask9write_rawCslicV2bA46s8_15microbit_common>:
; #[asm_cfg(cortex_m)]
    24f6:      	push	{r7, lr}
    24f8:      	mov	r7, sp
    24fa:      	sub	sp, #0x10
    24fc:      	str	r0, [sp, #0x4]
    24fe:      	str	r0, [sp, #0xc]
    2500:      	movs	r0, #0x4
;     compiler_fence(Ordering::SeqCst);
    2502:      	str	r0, [sp, #0x8]
    2504:      	bl	0x24a0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCslicV2bA46s8_15microbit_common> @ imm = #-0x68
    2508:      	ldr	r1, [sp, #0x4]
    250a:      	ldr	r0, [sp, #0x8]
;     unsafe { asm!("msr PRIMASK, {}", in(reg) r, options(nomem, nostack, preserves_flags)) };
    250c:      	msr	primask, r1
;     compiler_fence(Ordering::SeqCst);
    2510:      	bl	0x24a0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCslicV2bA46s8_15microbit_common> @ imm = #-0x74
; #[asm_cfg(cortex_m)]
    2514:      	add	sp, #0x10
    2516:      	pop	{r7, pc}

00002518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common>:
;             const fn precondition_check($($name:$ty),*) {
    2518:      	push	{r7, lr}
    251a:      	mov	r7, sp
    251c:      	sub	sp, #0x18
    251e:      	str	r2, [sp]
    2520:      	str	r0, [sp, #0x4]
    2522:      	str	r1, [sp, #0x8]
;             ) => ub_checks::maybe_is_aligned(addr, align)
    2524:      	str	r0, [sp, #0xc]
;             ptr.is_aligned_to(align)
    2526:      	bl	0x2b96 <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs26dZ7Vetpav_11embedded_io> @ imm = #0x66c
;             ) => ub_checks::maybe_is_aligned(addr, align)
    252a:      	cbnz	r0, 0x2548 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common+0x30> @ imm = #0x1a
    252c:      	b	0x252e <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common+0x16> @ imm = #-0x2
;                     let msg = concat!("unsafe precondition(s) violated: ", $message,
    252e:      	ldr	r3, [sp]
    2530:      	movw	r0, #0x5cfc
    2534:      	movt	r0, #0x0
    2538:      	str	r0, [sp, #0x10]
    253a:      	movs	r1, #0xd7
    253c:      	str	r1, [sp, #0x14]
;                     ::core::panicking::panic_nounwind_fmt(::core::fmt::Arguments::from_str(msg), false);
    253e:      	movw	r1, #0x1af
    2542:      	movs	r2, #0x0
    2544:      	bl	0x47c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt> @ imm = #0x2278
;             }
    2548:      	add	sp, #0x18
    254a:      	pop	{r7, pc}

0000254c <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf5DIR_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common>:
;     fn into(self) -> U {
    254c:      	push	{r7, lr}
    254e:      	mov	r7, sp
    2550:      	sub	sp, #0x4
    2552:      	strb	r0, [r7, #-2]
    2556:      	strb	r0, [r7, #-1]
;     }
    255a:      	add	sp, #0x4
    255c:      	pop	{r7, pc}

0000255e <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf6PULL_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common>:
;     fn into(self) -> U {
    255e:      	push	{r7, lr}
    2560:      	mov	r7, sp
    2562:      	sub	sp, #0x4
    2564:      	strb	r0, [r7, #-2]
    2568:      	strb	r0, [r7, #-1]
;     }
    256c:      	add	sp, #0x4
    256e:      	pop	{r7, pc}

00002570 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7DRIVE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common>:
;     fn into(self) -> U {
    2570:      	push	{r7, lr}
    2572:      	mov	r7, sp
    2574:      	sub	sp, #0x4
    2576:      	strb	r0, [r7, #-2]
    257a:      	strb	r0, [r7, #-1]
;     }
    257e:      	add	sp, #0x4
    2580:      	pop	{r7, pc}

00002582 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7INPUT_AINtB5_4IntobE4intoCslicV2bA46s8_15microbit_common>:
;     fn into(self) -> U {
    2582:      	push	{r7, lr}
    2584:      	mov	r7, sp
    2586:      	sub	sp, #0x4
    2588:      	strb	r0, [r7, #-2]
    258c:      	strb	r0, [r7, #-1]
;     }
    2590:      	add	sp, #0x4
    2592:      	pop	{r7, pc}

00002594 <_RNvXs1_NtCs6e6HQTixP8o_4core7convertNtNtNtCs9keDkRYv3gL_12nrf52833_pac2p07pin_cnf7SENSE_AINtB5_4IntohE4intoCslicV2bA46s8_15microbit_common>:
;     fn into(self) -> U {
    2594:      	push	{r7, lr}
    2596:      	mov	r7, sp
    2598:      	sub	sp, #0x4
    259a:      	strb	r0, [r7, #-2]
    259e:      	strb	r0, [r7, #-1]
;     }
    25a2:      	add	sp, #0x4
    25a4:      	pop	{r7, pc}

000025a6 <_RNvXs20_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common>:
;                     fn set_low(&mut self) -> Result<(), Self::Error> {
    25a6:      	push	{r7, lr}
    25a8:      	mov	r7, sp
    25aa:      	sub	sp, #0x30
    25ac:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    25ae:      	movw	r0, #0x50c
    25b2:      	movt	r0, #0x5000
    25b6:      	str	r0, [sp, #0x4]
    25b8:      	str	r0, [sp, #0x14]
    25ba:      	movs	r0, #0x0
    25bc:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    25be:      	str	r0, [sp, #0x10]
    25c0:      	add	r0, sp, #0x10
    25c2:      	bl	0x1d40 <_RNCNvXs20_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_11INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common> @ imm = #-0x886
    25c6:      	mov	r1, r0
    25c8:      	ldr	r0, [sp, #0x4]
    25ca:      	ldr	r1, [r1]
    25cc:      	str	r1, [sp, #0x8]
    25ce:      	str	r0, [sp, #0x18]
    25d0:      	str	r1, [sp, #0x1c]
    25d2:      	str	r0, [sp, #0x28]
    25d4:      	str	r0, [sp, #0x20]
    25d6:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    25d8:      	movw	r2, #0x5ca0
    25dc:      	movt	r2, #0x0
    25e0:      	movs	r1, #0x4
    25e2:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0xce
    25e6:      	ldr	r1, [sp, #0x4]
    25e8:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    25ea:      	str	r0, [r1]
;                     }
    25ec:      	add	sp, #0x30
    25ee:      	pop	{r7, pc}

000025f0 <_RNvXs20_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_11INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common>:
;                     fn set_high(&mut self) -> Result<(), Self::Error> {
    25f0:      	push	{r7, lr}
    25f2:      	mov	r7, sp
    25f4:      	sub	sp, #0x30
    25f6:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    25f8:      	movw	r0, #0x508
    25fc:      	movt	r0, #0x5000
    2600:      	str	r0, [sp, #0x4]
    2602:      	str	r0, [sp, #0x14]
    2604:      	movs	r0, #0x0
    2606:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    2608:      	str	r0, [sp, #0x10]
    260a:      	add	r0, sp, #0x10
    260c:      	bl	0x1d5c <_RNCNvXs20_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_11INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common> @ imm = #-0x8b4
    2610:      	mov	r1, r0
    2612:      	ldr	r0, [sp, #0x4]
    2614:      	ldr	r1, [r1]
    2616:      	str	r1, [sp, #0x8]
    2618:      	str	r0, [sp, #0x18]
    261a:      	str	r1, [sp, #0x1c]
    261c:      	str	r0, [sp, #0x28]
    261e:      	str	r0, [sp, #0x20]
    2620:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2622:      	movw	r2, #0x5ca0
    2626:      	movt	r2, #0x0
    262a:      	movs	r1, #0x4
    262c:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x118
    2630:      	ldr	r1, [sp, #0x4]
    2632:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2634:      	str	r0, [r1]
;                     }
    2636:      	add	sp, #0x30
    2638:      	pop	{r7, pc}

0000263a <_RNvXs2I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common>:
;                     fn set_low(&mut self) -> Result<(), Self::Error> {
    263a:      	push	{r7, lr}
    263c:      	mov	r7, sp
    263e:      	sub	sp, #0x30
    2640:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    2642:      	movw	r0, #0x50c
    2646:      	movt	r0, #0x5000
    264a:      	str	r0, [sp, #0x4]
    264c:      	str	r0, [sp, #0x14]
    264e:      	movs	r0, #0x0
    2650:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    2652:      	str	r0, [sp, #0x10]
    2654:      	add	r0, sp, #0x10
    2656:      	bl	0x1d78 <_RNCNvXs2I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_15INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common> @ imm = #-0x8e2
    265a:      	mov	r1, r0
    265c:      	ldr	r0, [sp, #0x4]
    265e:      	ldr	r1, [r1]
    2660:      	str	r1, [sp, #0x8]
    2662:      	str	r0, [sp, #0x18]
    2664:      	str	r1, [sp, #0x1c]
    2666:      	str	r0, [sp, #0x28]
    2668:      	str	r0, [sp, #0x20]
    266a:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    266c:      	movw	r2, #0x5ca0
    2670:      	movt	r2, #0x0
    2674:      	movs	r1, #0x4
    2676:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x162
    267a:      	ldr	r1, [sp, #0x4]
    267c:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    267e:      	str	r0, [r1]
;                     }
    2680:      	add	sp, #0x30
    2682:      	pop	{r7, pc}

00002684 <_RNvXs2I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_15INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common>:
;                     fn set_high(&mut self) -> Result<(), Self::Error> {
    2684:      	push	{r7, lr}
    2686:      	mov	r7, sp
    2688:      	sub	sp, #0x30
    268a:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    268c:      	movw	r0, #0x508
    2690:      	movt	r0, #0x5000
    2694:      	str	r0, [sp, #0x4]
    2696:      	str	r0, [sp, #0x14]
    2698:      	movs	r0, #0x0
    269a:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    269c:      	str	r0, [sp, #0x10]
    269e:      	add	r0, sp, #0x10
    26a0:      	bl	0x1d94 <_RNCNvXs2I_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_15INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common> @ imm = #-0x910
    26a4:      	mov	r1, r0
    26a6:      	ldr	r0, [sp, #0x4]
    26a8:      	ldr	r1, [r1]
    26aa:      	str	r1, [sp, #0x8]
    26ac:      	str	r0, [sp, #0x18]
    26ae:      	str	r1, [sp, #0x1c]
    26b0:      	str	r0, [sp, #0x28]
    26b2:      	str	r0, [sp, #0x20]
    26b4:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    26b6:      	movw	r2, #0x5ca0
    26ba:      	movt	r2, #0x0
    26be:      	movs	r1, #0x4
    26c0:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x1ac
    26c4:      	ldr	r1, [sp, #0x4]
    26c6:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    26c8:      	str	r0, [r1]
;                     }
    26ca:      	add	sp, #0x30
    26cc:      	pop	{r7, pc}

000026ce <_RNvXs3M_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common>:
;                     fn set_low(&mut self) -> Result<(), Self::Error> {
    26ce:      	push	{r7, lr}
    26d0:      	mov	r7, sp
    26d2:      	sub	sp, #0x30
    26d4:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    26d6:      	movw	r0, #0x50c
    26da:      	movt	r0, #0x5000
    26de:      	str	r0, [sp, #0x4]
    26e0:      	str	r0, [sp, #0x14]
    26e2:      	movs	r0, #0x0
    26e4:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    26e6:      	str	r0, [sp, #0x10]
    26e8:      	add	r0, sp, #0x10
    26ea:      	bl	0x1db0 <_RNCNvXs3M_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_21INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common> @ imm = #-0x93e
    26ee:      	mov	r1, r0
    26f0:      	ldr	r0, [sp, #0x4]
    26f2:      	ldr	r1, [r1]
    26f4:      	str	r1, [sp, #0x8]
    26f6:      	str	r0, [sp, #0x18]
    26f8:      	str	r1, [sp, #0x1c]
    26fa:      	str	r0, [sp, #0x28]
    26fc:      	str	r0, [sp, #0x20]
    26fe:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2700:      	movw	r2, #0x5ca0
    2704:      	movt	r2, #0x0
    2708:      	movs	r1, #0x4
    270a:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x1f6
    270e:      	ldr	r1, [sp, #0x4]
    2710:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2712:      	str	r0, [r1]
;                     }
    2714:      	add	sp, #0x30
    2716:      	pop	{r7, pc}

00002718 <_RNvXs3M_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_21INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common>:
;                     fn set_high(&mut self) -> Result<(), Self::Error> {
    2718:      	push	{r7, lr}
    271a:      	mov	r7, sp
    271c:      	sub	sp, #0x30
    271e:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    2720:      	movw	r0, #0x508
    2724:      	movt	r0, #0x5000
    2728:      	str	r0, [sp, #0x4]
    272a:      	str	r0, [sp, #0x14]
    272c:      	movs	r0, #0x0
    272e:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    2730:      	str	r0, [sp, #0x10]
    2732:      	add	r0, sp, #0x10
    2734:      	bl	0x1dcc <_RNCNvXs3M_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_21INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common> @ imm = #-0x96c
    2738:      	mov	r1, r0
    273a:      	ldr	r0, [sp, #0x4]
    273c:      	ldr	r1, [r1]
    273e:      	str	r1, [sp, #0x8]
    2740:      	str	r0, [sp, #0x18]
    2742:      	str	r1, [sp, #0x1c]
    2744:      	str	r0, [sp, #0x28]
    2746:      	str	r0, [sp, #0x20]
    2748:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    274a:      	movw	r2, #0x5ca0
    274e:      	movt	r2, #0x0
    2752:      	movs	r1, #0x4
    2754:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x240
    2758:      	ldr	r1, [sp, #0x4]
    275a:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    275c:      	str	r0, [r1]
;                     }
    275e:      	add	sp, #0x30
    2760:      	pop	{r7, pc}

00002762 <_RNvXs3X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common>:
;                     fn set_low(&mut self) -> Result<(), Self::Error> {
    2762:      	push	{r7, lr}
    2764:      	mov	r7, sp
    2766:      	sub	sp, #0x30
    2768:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    276a:      	movw	r0, #0x50c
    276e:      	movt	r0, #0x5000
    2772:      	str	r0, [sp, #0x4]
    2774:      	str	r0, [sp, #0x14]
    2776:      	movs	r0, #0x0
    2778:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    277a:      	str	r0, [sp, #0x10]
    277c:      	add	r0, sp, #0x10
    277e:      	bl	0x1de8 <_RNCNvXs3X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_22INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common> @ imm = #-0x99a
    2782:      	mov	r1, r0
    2784:      	ldr	r0, [sp, #0x4]
    2786:      	ldr	r1, [r1]
    2788:      	str	r1, [sp, #0x8]
    278a:      	str	r0, [sp, #0x18]
    278c:      	str	r1, [sp, #0x1c]
    278e:      	str	r0, [sp, #0x28]
    2790:      	str	r0, [sp, #0x20]
    2792:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2794:      	movw	r2, #0x5ca0
    2798:      	movt	r2, #0x0
    279c:      	movs	r1, #0x4
    279e:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x28a
    27a2:      	ldr	r1, [sp, #0x4]
    27a4:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    27a6:      	str	r0, [r1]
;                     }
    27a8:      	add	sp, #0x30
    27aa:      	pop	{r7, pc}

000027ac <_RNvXs3X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_22INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common>:
;                     fn set_high(&mut self) -> Result<(), Self::Error> {
    27ac:      	push	{r7, lr}
    27ae:      	mov	r7, sp
    27b0:      	sub	sp, #0x30
    27b2:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    27b4:      	movw	r0, #0x508
    27b8:      	movt	r0, #0x5000
    27bc:      	str	r0, [sp, #0x4]
    27be:      	str	r0, [sp, #0x14]
    27c0:      	movs	r0, #0x0
    27c2:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    27c4:      	str	r0, [sp, #0x10]
    27c6:      	add	r0, sp, #0x10
    27c8:      	bl	0x1e04 <_RNCNvXs3X_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_22INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common> @ imm = #-0x9c8
    27cc:      	mov	r1, r0
    27ce:      	ldr	r0, [sp, #0x4]
    27d0:      	ldr	r1, [r1]
    27d2:      	str	r1, [sp, #0x8]
    27d4:      	str	r0, [sp, #0x18]
    27d6:      	str	r1, [sp, #0x1c]
    27d8:      	str	r0, [sp, #0x28]
    27da:      	str	r0, [sp, #0x20]
    27dc:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    27de:      	movw	r2, #0x5ca0
    27e2:      	movt	r2, #0x0
    27e6:      	movs	r1, #0x4
    27e8:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x2d4
    27ec:      	ldr	r1, [sp, #0x4]
    27ee:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    27f0:      	str	r0, [r1]
;                     }
    27f2:      	add	sp, #0x30
    27f4:      	pop	{r7, pc}

000027f6 <_RNvXs3q_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common>:
;                     fn set_low(&mut self) -> Result<(), Self::Error> {
    27f6:      	push	{r7, lr}
    27f8:      	mov	r7, sp
    27fa:      	sub	sp, #0x30
    27fc:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    27fe:      	movw	r0, #0x50c
    2802:      	movt	r0, #0x5000
    2806:      	str	r0, [sp, #0x4]
    2808:      	str	r0, [sp, #0x14]
    280a:      	movs	r0, #0x0
    280c:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    280e:      	str	r0, [sp, #0x10]
    2810:      	add	r0, sp, #0x10
    2812:      	bl	0x1e20 <_RNCNvXs3q_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_19INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common> @ imm = #-0x9f6
    2816:      	mov	r1, r0
    2818:      	ldr	r0, [sp, #0x4]
    281a:      	ldr	r1, [r1]
    281c:      	str	r1, [sp, #0x8]
    281e:      	str	r0, [sp, #0x18]
    2820:      	str	r1, [sp, #0x1c]
    2822:      	str	r0, [sp, #0x28]
    2824:      	str	r0, [sp, #0x20]
    2826:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2828:      	movw	r2, #0x5ca0
    282c:      	movt	r2, #0x0
    2830:      	movs	r1, #0x4
    2832:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x31e
    2836:      	ldr	r1, [sp, #0x4]
    2838:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    283a:      	str	r0, [r1]
;                     }
    283c:      	add	sp, #0x30
    283e:      	pop	{r7, pc}

00002840 <_RNvXs3q_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_19INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common>:
;                     fn set_high(&mut self) -> Result<(), Self::Error> {
    2840:      	push	{r7, lr}
    2842:      	mov	r7, sp
    2844:      	sub	sp, #0x30
    2846:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    2848:      	movw	r0, #0x508
    284c:      	movt	r0, #0x5000
    2850:      	str	r0, [sp, #0x4]
    2852:      	str	r0, [sp, #0x14]
    2854:      	movs	r0, #0x0
    2856:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    2858:      	str	r0, [sp, #0x10]
    285a:      	add	r0, sp, #0x10
    285c:      	bl	0x1e3c <_RNCNvXs3q_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_19INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common> @ imm = #-0xa24
    2860:      	mov	r1, r0
    2862:      	ldr	r0, [sp, #0x4]
    2864:      	ldr	r1, [r1]
    2866:      	str	r1, [sp, #0x8]
    2868:      	str	r0, [sp, #0x18]
    286a:      	str	r1, [sp, #0x1c]
    286c:      	str	r0, [sp, #0x28]
    286e:      	str	r0, [sp, #0x20]
    2870:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2872:      	movw	r2, #0x5ca0
    2876:      	movt	r2, #0x0
    287a:      	movs	r1, #0x4
    287c:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x368
    2880:      	ldr	r1, [sp, #0x4]
    2882:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2884:      	str	r0, [r1]
;                     }
    2886:      	add	sp, #0x30
    2888:      	pop	{r7, pc}

0000288a <_RNvXs4j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common>:
;                     fn set_low(&mut self) -> Result<(), Self::Error> {
    288a:      	push	{r7, lr}
    288c:      	mov	r7, sp
    288e:      	sub	sp, #0x30
    2890:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    2892:      	movw	r0, #0x50c
    2896:      	movt	r0, #0x5000
    289a:      	str	r0, [sp, #0x4]
    289c:      	str	r0, [sp, #0x14]
    289e:      	movs	r0, #0x0
    28a0:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    28a2:      	str	r0, [sp, #0x10]
    28a4:      	add	r0, sp, #0x10
    28a6:      	bl	0x1e58 <_RNCNvXs4j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_24INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common> @ imm = #-0xa52
    28aa:      	mov	r1, r0
    28ac:      	ldr	r0, [sp, #0x4]
    28ae:      	ldr	r1, [r1]
    28b0:      	str	r1, [sp, #0x8]
    28b2:      	str	r0, [sp, #0x18]
    28b4:      	str	r1, [sp, #0x1c]
    28b6:      	str	r0, [sp, #0x28]
    28b8:      	str	r0, [sp, #0x20]
    28ba:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    28bc:      	movw	r2, #0x5ca0
    28c0:      	movt	r2, #0x0
    28c4:      	movs	r1, #0x4
    28c6:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x3b2
    28ca:      	ldr	r1, [sp, #0x4]
    28cc:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    28ce:      	str	r0, [r1]
;                     }
    28d0:      	add	sp, #0x30
    28d2:      	pop	{r7, pc}

000028d4 <_RNvXs4j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_24INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common>:
;                     fn set_high(&mut self) -> Result<(), Self::Error> {
    28d4:      	push	{r7, lr}
    28d6:      	mov	r7, sp
    28d8:      	sub	sp, #0x30
    28da:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    28dc:      	movw	r0, #0x508
    28e0:      	movt	r0, #0x5000
    28e4:      	str	r0, [sp, #0x4]
    28e6:      	str	r0, [sp, #0x14]
    28e8:      	movs	r0, #0x0
    28ea:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    28ec:      	str	r0, [sp, #0x10]
    28ee:      	add	r0, sp, #0x10
    28f0:      	bl	0x1e74 <_RNCNvXs4j_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_24INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common> @ imm = #-0xa80
    28f4:      	mov	r1, r0
    28f6:      	ldr	r0, [sp, #0x4]
    28f8:      	ldr	r1, [r1]
    28fa:      	str	r1, [sp, #0x8]
    28fc:      	str	r0, [sp, #0x18]
    28fe:      	str	r1, [sp, #0x1c]
    2900:      	str	r0, [sp, #0x28]
    2902:      	str	r0, [sp, #0x20]
    2904:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2906:      	movw	r2, #0x5ca0
    290a:      	movt	r2, #0x0
    290e:      	movs	r1, #0x4
    2910:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x3fc
    2914:      	ldr	r1, [sp, #0x4]
    2916:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2918:      	str	r0, [r1]
;                     }
    291a:      	add	sp, #0x30
    291c:      	pop	{r7, pc}

0000291e <_RNvXs51_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common>:
;                     fn set_low(&mut self) -> Result<(), Self::Error> {
    291e:      	push	{r7, lr}
    2920:      	mov	r7, sp
    2922:      	sub	sp, #0x30
    2924:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    2926:      	movw	r0, #0x50c
    292a:      	movt	r0, #0x5000
    292e:      	str	r0, [sp, #0x4]
    2930:      	str	r0, [sp, #0x14]
    2932:      	movs	r0, #0x0
    2934:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    2936:      	str	r0, [sp, #0x10]
    2938:      	add	r0, sp, #0x10
    293a:      	bl	0x1e90 <_RNCNvXs51_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_28INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common> @ imm = #-0xaae
    293e:      	mov	r1, r0
    2940:      	ldr	r0, [sp, #0x4]
    2942:      	ldr	r1, [r1]
    2944:      	str	r1, [sp, #0x8]
    2946:      	str	r0, [sp, #0x18]
    2948:      	str	r1, [sp, #0x1c]
    294a:      	str	r0, [sp, #0x28]
    294c:      	str	r0, [sp, #0x20]
    294e:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2950:      	movw	r2, #0x5ca0
    2954:      	movt	r2, #0x0
    2958:      	movs	r1, #0x4
    295a:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x446
    295e:      	ldr	r1, [sp, #0x4]
    2960:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2962:      	str	r0, [r1]
;                     }
    2964:      	add	sp, #0x30
    2966:      	pop	{r7, pc}

00002968 <_RNvXs51_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_28INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common>:
;                     fn set_high(&mut self) -> Result<(), Self::Error> {
    2968:      	push	{r7, lr}
    296a:      	mov	r7, sp
    296c:      	sub	sp, #0x30
    296e:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    2970:      	movw	r0, #0x508
    2974:      	movt	r0, #0x5000
    2978:      	str	r0, [sp, #0x4]
    297a:      	str	r0, [sp, #0x14]
    297c:      	movs	r0, #0x0
    297e:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    2980:      	str	r0, [sp, #0x10]
    2982:      	add	r0, sp, #0x10
    2984:      	bl	0x1eac <_RNCNvXs51_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_28INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common> @ imm = #-0xadc
    2988:      	mov	r1, r0
    298a:      	ldr	r0, [sp, #0x4]
    298c:      	ldr	r1, [r1]
    298e:      	str	r1, [sp, #0x8]
    2990:      	str	r0, [sp, #0x18]
    2992:      	str	r1, [sp, #0x1c]
    2994:      	str	r0, [sp, #0x28]
    2996:      	str	r0, [sp, #0x20]
    2998:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    299a:      	movw	r2, #0x5ca0
    299e:      	movt	r2, #0x0
    29a2:      	movs	r1, #0x4
    29a4:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x490
    29a8:      	ldr	r1, [sp, #0x4]
    29aa:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    29ac:      	str	r0, [r1]
;                     }
    29ae:      	add	sp, #0x30
    29b0:      	pop	{r7, pc}

000029b2 <_RNvXs5n_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common>:
;                     fn set_low(&mut self) -> Result<(), Self::Error> {
    29b2:      	push	{r7, lr}
    29b4:      	mov	r7, sp
    29b6:      	sub	sp, #0x30
    29b8:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    29ba:      	movw	r0, #0x50c
    29be:      	movt	r0, #0x5000
    29c2:      	str	r0, [sp, #0x4]
    29c4:      	str	r0, [sp, #0x14]
    29c6:      	movs	r0, #0x0
    29c8:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    29ca:      	str	r0, [sp, #0x10]
    29cc:      	add	r0, sp, #0x10
    29ce:      	bl	0x1ec8 <_RNCNvXs5n_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_30INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common> @ imm = #-0xb0a
    29d2:      	mov	r1, r0
    29d4:      	ldr	r0, [sp, #0x4]
    29d6:      	ldr	r1, [r1]
    29d8:      	str	r1, [sp, #0x8]
    29da:      	str	r0, [sp, #0x18]
    29dc:      	str	r1, [sp, #0x1c]
    29de:      	str	r0, [sp, #0x28]
    29e0:      	str	r0, [sp, #0x20]
    29e2:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    29e4:      	movw	r2, #0x5ca0
    29e8:      	movt	r2, #0x0
    29ec:      	movs	r1, #0x4
    29ee:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x4da
    29f2:      	ldr	r1, [sp, #0x4]
    29f4:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    29f6:      	str	r0, [r1]
;                     }
    29f8:      	add	sp, #0x30
    29fa:      	pop	{r7, pc}

000029fc <_RNvXs5n_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_30INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common>:
;                     fn set_high(&mut self) -> Result<(), Self::Error> {
    29fc:      	push	{r7, lr}
    29fe:      	mov	r7, sp
    2a00:      	sub	sp, #0x30
    2a02:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    2a04:      	movw	r0, #0x508
    2a08:      	movt	r0, #0x5000
    2a0c:      	str	r0, [sp, #0x4]
    2a0e:      	str	r0, [sp, #0x14]
    2a10:      	movs	r0, #0x0
    2a12:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    2a14:      	str	r0, [sp, #0x10]
    2a16:      	add	r0, sp, #0x10
    2a18:      	bl	0x1ee4 <_RNCNvXs5n_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_30INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common> @ imm = #-0xb38
    2a1c:      	mov	r1, r0
    2a1e:      	ldr	r0, [sp, #0x4]
    2a20:      	ldr	r1, [r1]
    2a22:      	str	r1, [sp, #0x8]
    2a24:      	str	r0, [sp, #0x18]
    2a26:      	str	r1, [sp, #0x1c]
    2a28:      	str	r0, [sp, #0x28]
    2a2a:      	str	r0, [sp, #0x20]
    2a2c:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2a2e:      	movw	r2, #0x5ca0
    2a32:      	movt	r2, #0x0
    2a36:      	movs	r1, #0x4
    2a38:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x524
    2a3c:      	ldr	r1, [sp, #0x4]
    2a3e:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2a40:      	str	r0, [r1]
;                     }
    2a42:      	add	sp, #0x30
    2a44:      	pop	{r7, pc}

00002a46 <_RNvXs5y_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common>:
;                     fn set_low(&mut self) -> Result<(), Self::Error> {
    2a46:      	push	{r7, lr}
    2a48:      	mov	r7, sp
    2a4a:      	sub	sp, #0x30
    2a4c:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    2a4e:      	movw	r0, #0x50c
    2a52:      	movt	r0, #0x5000
    2a56:      	str	r0, [sp, #0x4]
    2a58:      	str	r0, [sp, #0x14]
    2a5a:      	movs	r0, #0x0
    2a5c:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    2a5e:      	str	r0, [sp, #0x10]
    2a60:      	add	r0, sp, #0x10
    2a62:      	bl	0x1f00 <_RNCNvXs5y_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_31INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common> @ imm = #-0xb66
    2a66:      	mov	r1, r0
    2a68:      	ldr	r0, [sp, #0x4]
    2a6a:      	ldr	r1, [r1]
    2a6c:      	str	r1, [sp, #0x8]
    2a6e:      	str	r0, [sp, #0x18]
    2a70:      	str	r1, [sp, #0x1c]
    2a72:      	str	r0, [sp, #0x28]
    2a74:      	str	r0, [sp, #0x20]
    2a76:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2a78:      	movw	r2, #0x5ca0
    2a7c:      	movt	r2, #0x0
    2a80:      	movs	r1, #0x4
    2a82:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x56e
    2a86:      	ldr	r1, [sp, #0x4]
    2a88:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2a8a:      	str	r0, [r1]
;                     }
    2a8c:      	add	sp, #0x30
    2a8e:      	pop	{r7, pc}

00002a90 <_RNvXs5y_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB6_5P0_31INtB8_6OutputNtB8_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common>:
;                     fn set_high(&mut self) -> Result<(), Self::Error> {
    2a90:      	push	{r7, lr}
    2a92:      	mov	r7, sp
    2a94:      	sub	sp, #0x30
    2a96:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    2a98:      	movw	r0, #0x508
    2a9c:      	movt	r0, #0x5000
    2aa0:      	str	r0, [sp, #0x4]
    2aa2:      	str	r0, [sp, #0x14]
    2aa4:      	movs	r0, #0x0
    2aa6:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    2aa8:      	str	r0, [sp, #0x10]
    2aaa:      	add	r0, sp, #0x10
    2aac:      	bl	0x1f1c <_RNCNvXs5y_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0INtB8_5P0_31INtBa_6OutputNtBa_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common> @ imm = #-0xb94
    2ab0:      	mov	r1, r0
    2ab2:      	ldr	r0, [sp, #0x4]
    2ab4:      	ldr	r1, [r1]
    2ab6:      	str	r1, [sp, #0x8]
    2ab8:      	str	r0, [sp, #0x18]
    2aba:      	str	r1, [sp, #0x1c]
    2abc:      	str	r0, [sp, #0x28]
    2abe:      	str	r0, [sp, #0x20]
    2ac0:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2ac2:      	movw	r2, #0x5ca0
    2ac6:      	movt	r2, #0x0
    2aca:      	movs	r1, #0x4
    2acc:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x5b8
    2ad0:      	ldr	r1, [sp, #0x4]
    2ad2:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2ad4:      	str	r0, [r1]
;                     }
    2ad6:      	add	sp, #0x30
    2ad8:      	pop	{r7, pc}

00002ada <_RNvXsW_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05INtB7_6OutputNtB7_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_lowCslicV2bA46s8_15microbit_common>:
;                     fn set_low(&mut self) -> Result<(), Self::Error> {
    2ada:      	push	{r7, lr}
    2adc:      	mov	r7, sp
    2ade:      	sub	sp, #0x30
    2ae0:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outclr.write(|w| w.bits(1u32 << $i)); }
    2ae2:      	movw	r0, #0x80c
    2ae6:      	movt	r0, #0x5000
    2aea:      	str	r0, [sp, #0x4]
    2aec:      	str	r0, [sp, #0x14]
    2aee:      	movs	r0, #0x0
    2af0:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    2af2:      	str	r0, [sp, #0x10]
    2af4:      	add	r0, sp, #0x10
    2af6:      	bl	0x1f38 <_RNCNvXsW_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB7_5P1_05INtB9_6OutputNtB9_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin7set_low0CslicV2bA46s8_15microbit_common> @ imm = #-0xbc2
    2afa:      	mov	r1, r0
    2afc:      	ldr	r0, [sp, #0x4]
    2afe:      	ldr	r1, [r1]
    2b00:      	str	r1, [sp, #0x8]
    2b02:      	str	r0, [sp, #0x18]
    2b04:      	str	r1, [sp, #0x1c]
    2b06:      	str	r0, [sp, #0x28]
    2b08:      	str	r0, [sp, #0x20]
    2b0a:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2b0c:      	movw	r2, #0x5ca0
    2b10:      	movt	r2, #0x0
    2b14:      	movs	r1, #0x4
    2b16:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x602
    2b1a:      	ldr	r1, [sp, #0x4]
    2b1c:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2b1e:      	str	r0, [r1]
;                     }
    2b20:      	add	sp, #0x30
    2b22:      	pop	{r7, pc}

00002b24 <_RNvXsW_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB5_5P1_05INtB7_6OutputNtB7_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_highCslicV2bA46s8_15microbit_common>:
;                     fn set_high(&mut self) -> Result<(), Self::Error> {
    2b24:      	push	{r7, lr}
    2b26:      	mov	r7, sp
    2b28:      	sub	sp, #0x30
    2b2a:      	str	r0, [sp, #0xc]
;                         unsafe { (*$PX::ptr()).outset.write(|w| w.bits(1u32 << $i)); }
    2b2c:      	movw	r0, #0x808
    2b30:      	movt	r0, #0x5000
    2b34:      	str	r0, [sp, #0x4]
    2b36:      	str	r0, [sp, #0x14]
    2b38:      	movs	r0, #0x0
    2b3a:      	str	r0, [sp, #0x2c]
;             f(&mut REG::Writer::from(W {
    2b3c:      	str	r0, [sp, #0x10]
    2b3e:      	add	r0, sp, #0x10
    2b40:      	bl	0x1f52 <_RNCNvXsW_NtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1INtB7_5P1_05INtB9_6OutputNtB9_8PushPullEENtNtCsbix0s8zxODG_12embedded_hal7digital9OutputPin8set_high0CslicV2bA46s8_15microbit_common> @ imm = #-0xbf2
    2b44:      	mov	r1, r0
    2b46:      	ldr	r0, [sp, #0x4]
    2b48:      	ldr	r1, [r1]
    2b4a:      	str	r1, [sp, #0x8]
    2b4c:      	str	r0, [sp, #0x18]
    2b4e:      	str	r1, [sp, #0x1c]
    2b50:      	str	r0, [sp, #0x28]
    2b52:      	str	r0, [sp, #0x20]
    2b54:      	str	r1, [sp, #0x24]
;                 precondition_check($($arg,)*);
    2b56:      	movw	r2, #0x5ca0
    2b5a:      	movt	r2, #0x0
    2b5e:      	movs	r1, #0x4
    2b60:      	bl	0x2518 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCslicV2bA46s8_15microbit_common> @ imm = #-0x64c
    2b64:      	ldr	r1, [sp, #0x4]
    2b66:      	ldr	r0, [sp, #0x8]
;         intrinsics::volatile_store(dst, src);
    2b68:      	str	r0, [r1]
;                     }
    2b6a:      	add	sp, #0x30
    2b6c:      	pop	{r7, pc}

00002b6e <_RNvXs1_NtCs6e6HQTixP8o_4core7converthINtB5_4IntomE4intoCskt6MVUVhGnM_14nrf_hal_common>:
;     fn into(self) -> U {
    2b6e:      	push	{r7, lr}
    2b70:      	mov	r7, sp
    2b72:      	sub	sp, #0x4
    2b74:      	strb	r0, [r7, #-2]
    2b78:      	strb	r0, [r7, #-1]
;                 small as Self
    2b7c:      	uxtb	r0, r0
;     }
    2b7e:      	add	sp, #0x4
    2b80:      	pop	{r7, pc}

00002b82 <_RNvMNtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p0NtB2_5Parts3new>:
;                 pub fn new(_gpio: $PX) -> Self {
    2b82:      	push	{r7, lr}
    2b84:      	mov	r7, sp
    2b86:      	sub	sp, #0x4
;                 }
    2b88:      	add	sp, #0x4
    2b8a:      	pop	{r7, pc}

00002b8c <_RNvMNtNtCskt6MVUVhGnM_14nrf_hal_common4gpio2p1NtB2_5Parts3new>:
;                 pub fn new(_gpio: $PX) -> Self {
    2b8c:      	push	{r7, lr}
    2b8e:      	mov	r7, sp
    2b90:      	sub	sp, #0x4
;                 }
    2b92:      	add	sp, #0x4
    2b94:      	pop	{r7, pc}

00002b96 <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs26dZ7Vetpav_11embedded_io>:
;     pub fn is_aligned_to(self, align: usize) -> bool {
    2b96:      	push	{r7, lr}
    2b98:      	mov	r7, sp
    2b9a:      	sub	sp, #0x18
    2b9c:      	str	r1, [sp]
    2b9e:      	mov	r1, r0
    2ba0:      	ldr	r0, [sp]
    2ba2:      	str	r1, [sp, #0x4]
    2ba4:      	str	r1, [sp, #0x8]
    2ba6:      	str	r0, [sp, #0xc]
;         if !align.is_power_of_two() {
    2ba8:      	subs	r1, r0, #0x1
    2baa:      	eors	r0, r1
    2bac:      	cmp	r0, r1
    2bae:      	bhi	0x2bce <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs26dZ7Vetpav_11embedded_io+0x38> @ imm = #0x1c
    2bb0:      	b	0x2bb2 <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs26dZ7Vetpav_11embedded_io+0x1c> @ imm = #-0x2
;             panic!("is_aligned_to: align is not a power-of-two");
    2bb2:      	movw	r0, #0x5dd3
    2bb6:      	movt	r0, #0x0
    2bba:      	str	r0, [sp, #0x10]
    2bbc:      	movs	r1, #0x2a
    2bbe:      	str	r1, [sp, #0x14]
    2bc0:      	movw	r2, #0x5e00
    2bc4:      	movt	r2, #0x0
    2bc8:      	movs	r1, #0x55
    2bca:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x1c72
;         self.addr() & (align - 1) == 0
    2bce:      	ldr	r0, [sp, #0x4]
    2bd0:      	ldr	r1, [sp]
    2bd2:      	subs	r1, #0x1
    2bd4:      	ands	r0, r1
    2bd6:      	clz	r0, r0
    2bda:      	lsrs	r0, r0, #0x5
;     }
    2bdc:      	add	sp, #0x18
    2bde:      	pop	{r7, pc}

00002be0 <_RNvNtCs87vGccmtUh2_8cortex_m9interrupt7disableB3_>:
; #[asm_cfg(cortex_m)]
    2be0:      	push	{r7, lr}
    2be2:      	mov	r7, sp
;     unsafe { asm!("cpsid i", options(nomem, nostack, preserves_flags)) };
    2be4:      	cpsid i
;     compiler_fence(Ordering::SeqCst);
    2be6:      	movs	r0, #0x4
    2be8:      	bl	0x2bf0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCs87vGccmtUh2_8cortex_m> @ imm = #0x4
; #[asm_cfg(cortex_m)]
    2bec:      	pop	{r7, pc}
    2bee:      	bmi	0x2b9a <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs26dZ7Vetpav_11embedded_io+0x4> @ imm = #-0x58

00002bf0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCs87vGccmtUh2_8cortex_m>:
    2bf0:      	push	{r7, lr}
    2bf2:      	mov	r7, sp
    2bf4:      	sub	sp, #0x10
    2bf6:      	strb	r0, [r7, #-9]
    2bfa:      	uxtb	r0, r0
    2bfc:      	str	r0, [sp]
    2bfe:      	ldr	r1, [sp]
    2c00:      	tbb	[pc, r1]
    2c04: 04 12 13 14  	.word	0x14131204
    2c08: 15 00	.short	0x0015
    2c0a:      	trap
    2c0c:      	movw	r0, #0x5e10
    2c10:      	movt	r0, #0x0
    2c14:      	str	r0, [sp, #0x8]
    2c16:      	movs	r1, #0x29
    2c18:      	str	r1, [sp, #0xc]
    2c1a:      	movw	r2, #0x5e3c
    2c1e:      	movt	r2, #0x0
    2c22:      	movs	r1, #0x53
    2c24:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x1c18
    2c28:      	b	0x2c30 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCs87vGccmtUh2_8cortex_m+0x40> @ imm = #0x4
    2c2a:      	b	0x2c30 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCs87vGccmtUh2_8cortex_m+0x40> @ imm = #0x2
    2c2c:      	b	0x2c30 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCs87vGccmtUh2_8cortex_m+0x40> @ imm = #0x0
    2c2e:      	b	0x2c30 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCs87vGccmtUh2_8cortex_m+0x40> @ imm = #-0x2
    2c30:      	add	sp, #0x10
    2c32:      	pop	{r7, pc}

00002c34 <_RNvNtNtCs87vGccmtUh2_8cortex_m8register7primask8read_rawB5_>:
    2c34:      	push	{r7, lr}
    2c36:      	mov	r7, sp
    2c38:      	sub	sp, #0x4
    2c3a:      	mrs	r0, primask
    2c3e:      	str	r0, [sp]
    2c40:      	ldr	r0, [sp]
    2c42:      	add	sp, #0x4
    2c44:      	pop	{r7, pc}

00002c46 <_RNvNtNtCs87vGccmtUh2_8cortex_m8register7primask9write_rawB5_>:
    2c46:      	push	{r7, lr}
    2c48:      	mov	r7, sp
    2c4a:      	sub	sp, #0x10
    2c4c:      	str	r0, [sp, #0x4]
    2c4e:      	str	r0, [sp, #0xc]
    2c50:      	movs	r0, #0x4
    2c52:      	str	r0, [sp, #0x8]
    2c54:      	bl	0x2bf0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCs87vGccmtUh2_8cortex_m> @ imm = #-0x68
    2c58:      	ldr	r1, [sp, #0x4]
    2c5a:      	ldr	r0, [sp, #0x8]
    2c5c:      	msr	primask, r1
    2c60:      	bl	0x2bf0 <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCs87vGccmtUh2_8cortex_m> @ imm = #-0x74
    2c64:      	add	sp, #0x10
    2c66:      	pop	{r7, pc}

00002c68 <_RNvXNtCs87vGccmtUh2_8cortex_m16critical_sectionNtB2_25SingleCoreCriticalSectionNtCs6gRl320PnDN_16critical_section4Impl7acquire>:
    2c68:      	push	{r7, lr}
    2c6a:      	mov	r7, sp
    2c6c:      	sub	sp, #0x8
    2c6e:      	bl	0x2c34 <_RNvNtNtCs87vGccmtUh2_8cortex_m8register7primask8read_rawB5_> @ imm = #-0x3e
    2c72:      	str	r0, [sp]
    2c74:      	str	r0, [sp, #0x4]
    2c76:      	bl	0x2be0 <_RNvNtCs87vGccmtUh2_8cortex_m9interrupt7disableB3_> @ imm = #-0x9a
    2c7a:      	ldr	r0, [sp]
    2c7c:      	add	sp, #0x8
    2c7e:      	pop	{r7, pc}

00002c80 <_RNvXNtCs87vGccmtUh2_8cortex_m16critical_sectionNtB2_25SingleCoreCriticalSectionNtCs6gRl320PnDN_16critical_section4Impl7release>:
    2c80:      	push	{r7, lr}
    2c82:      	mov	r7, sp
    2c84:      	sub	sp, #0x8
    2c86:      	str	r0, [sp, #0x4]
    2c88:      	bl	0x2c46 <_RNvNtNtCs87vGccmtUh2_8cortex_m8register7primask9write_rawB5_> @ imm = #-0x46
    2c8c:      	add	sp, #0x8
    2c8e:      	pop	{r7, pc}

00002c90 <_critical_section_1_0_acquire>:
    2c90:      	push	{r7, lr}
    2c92:      	mov	r7, sp
    2c94:      	bl	0x2c68 <_RNvXNtCs87vGccmtUh2_8cortex_m16critical_sectionNtB2_25SingleCoreCriticalSectionNtCs6gRl320PnDN_16critical_section4Impl7acquire> @ imm = #-0x30
    2c98:      	pop	{r7, pc}

00002c9a <_critical_section_1_0_release>:
    2c9a:      	push	{r7, lr}
    2c9c:      	mov	r7, sp
    2c9e:      	sub	sp, #0x8
    2ca0:      	str	r0, [sp, #0x4]
    2ca2:      	bl	0x2c80 <_RNvXNtCs87vGccmtUh2_8cortex_m16critical_sectionNtB2_25SingleCoreCriticalSectionNtCs6gRl320PnDN_16critical_section4Impl7release> @ imm = #-0x26
    2ca6:      	add	sp, #0x8
    2ca8:      	pop	{r7, pc}

00002caa <_RNvMs_CsaXqxHTKDkp8_10bare_metalNtB4_15CriticalSection3new>:
    2caa:      	push	{r7, lr}
    2cac:      	mov	r7, sp
    2cae:      	pop	{r7, pc}

00002cb0 <WDT>:
    2cb0:      	push	{r7, lr}
    2cb2:      	mov	r7, sp
    2cb4:      	b	0x2cb6 <WDT+0x6>        @ imm = #-0x2
    2cb6:      	b	0x2cb6 <WDT+0x6>        @ imm = #-0x4

00002cb8 <__pre_init>:
    2cb8:      	push	{r7, lr}
    2cba:      	mov	r7, sp
    2cbc:      	pop	{r7, pc}

00002cbe <_RINvCs6gRl320PnDN_16critical_section4withuNCINvNtCs2GpT71Ckjdn_10rtt_target5print21with_terminal_channelNCNCNvCsju8MJypcZ9c_16panic_rtt_target5panic00E0EB1K_>:
    2cbe:      	push	{r7, lr}
    2cc0:      	mov	r7, sp
    2cc2:      	sub	sp, #0x10
    2cc4:      	str	r0, [sp]
    2cc6:      	str	r0, [sp, #0x8]
    2cc8:      	bl	0x2c90 <_critical_section_1_0_acquire> @ imm = #-0x3c
    2ccc:      	mov	r1, r0
    2cce:      	ldr	r0, [sp]
    2cd0:      	str	r1, [sp, #0xc]
    2cd2:      	str	r1, [sp, #0x4]
    2cd4:      	bl	0x2d4a <_RNCINvNtCs2GpT71Ckjdn_10rtt_target5print21with_terminal_channelNCNCNvCsju8MJypcZ9c_16panic_rtt_target5panic00E0B15_> @ imm = #0x72
    2cd8:      	add	r0, sp, #0x4
    2cda:      	bl	0x2ef6 <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueNtNvCs6gRl320PnDN_16critical_section4with5GuardECs2GpT71Ckjdn_10rtt_target> @ imm = #0x218
    2cde:      	add	sp, #0x10
    2ce0:      	pop	{r7, pc}

00002ce2 <_RINvCs6gRl320PnDN_16critical_section4withzNCNvCsju8MJypcZ9c_16panic_rtt_target5panic0EBI_>:
    2ce2:      	push	{r7, lr}
    2ce4:      	mov	r7, sp
    2ce6:      	sub	sp, #0x10
    2ce8:      	str	r0, [sp]
    2cea:      	str	r0, [sp, #0x8]
    2cec:      	bl	0x2c90 <_critical_section_1_0_acquire> @ imm = #-0x60
    2cf0:      	mov	r1, r0
    2cf2:      	ldr	r0, [sp]
    2cf4:      	str	r1, [sp, #0xc]
    2cf6:      	str	r1, [sp, #0x4]
    2cf8:      	bl	0x2df8 <_RNCNvCsju8MJypcZ9c_16panic_rtt_target5panic0B3_> @ imm = #0xfc
    2cfc:      	add	r0, sp, #0x4
    2cfe:      	bl	0x2ef6 <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueNtNvCs6gRl320PnDN_16critical_section4with5GuardECs2GpT71Ckjdn_10rtt_target> @ imm = #0x1f4
    2d02:      	trap

00002d04 <_RINvMNtNtCs6e6HQTixP8o_4core3fmt2rtNtB3_8Argument11new_displayRNtNtNtB7_5panic10panic_info9PanicInfoECsju8MJypcZ9c_16panic_rtt_target>:
    2d04:      	push	{r7, lr}
    2d06:      	mov	r7, sp
    2d08:      	sub	sp, #0x10
    2d0a:      	str	r1, [sp]
    2d0c:      	mov	r1, r0
    2d0e:      	ldr	r0, [sp]
    2d10:      	str	r0, [sp, #0xc]
    2d12:      	str	r0, [sp, #0x4]
    2d14:      	movw	r0, #0x2e61
    2d18:      	movt	r0, #0x0
    2d1c:      	str	r0, [sp, #0x8]
    2d1e:      	ldr	r0, [sp, #0x4]
    2d20:      	ldr	r2, [sp, #0x8]
    2d22:      	str	r2, [r1, #0x4]
    2d24:      	str	r0, [r1]
    2d26:      	add	sp, #0x10
    2d28:      	pop	{r7, pc}

00002d2a <_RINvMs2_NtCs6e6HQTixP8o_4core3fmtNtB6_9Arguments3newKj4_Kj1_ECsju8MJypcZ9c_16panic_rtt_target>:
    2d2a:      	push	{r7, lr}
    2d2c:      	mov	r7, sp
    2d2e:      	sub	sp, #0x8
    2d30:      	str	r0, [sp]
    2d32:      	str	r1, [sp, #0x4]
    2d34:      	add	sp, #0x8
    2d36:      	pop	{r7, pc}

00002d38 <_RINvNtCs2GpT71Ckjdn_10rtt_target5print21with_terminal_channelNCNCNvCsju8MJypcZ9c_16panic_rtt_target5panic00EB13_>:
    2d38:      	push	{r7, lr}
    2d3a:      	mov	r7, sp
    2d3c:      	sub	sp, #0x8
    2d3e:      	str	r0, [sp, #0x4]
    2d40:      	add	r0, sp, #0x4
    2d42:      	bl	0x2cbe <_RINvCs6gRl320PnDN_16critical_section4withuNCINvNtCs2GpT71Ckjdn_10rtt_target5print21with_terminal_channelNCNCNvCsju8MJypcZ9c_16panic_rtt_target5panic00E0EB1K_> @ imm = #-0x88
    2d46:      	add	sp, #0x8
    2d48:      	pop	{r7, pc}

00002d4a <_RNCINvNtCs2GpT71Ckjdn_10rtt_target5print21with_terminal_channelNCNCNvCsju8MJypcZ9c_16panic_rtt_target5panic00E0B15_>:
    2d4a:      	push	{r7, lr}
    2d4c:      	mov	r7, sp
    2d4e:      	sub	sp, #0x20
    2d50:      	str	r0, [sp, #0x4]
    2d52:      	str	r0, [sp, #0x14]
    2d54:      	movw	r0, #0x438
    2d58:      	movt	r0, #0x2000
    2d5c:      	movw	r1, #0x5e4c
    2d60:      	movt	r1, #0x0
    2d64:      	bl	0x386e <_RNvMs_NtCs6gRl320PnDN_16critical_section5mutexINtB4_5MutexINtNtCs6e6HQTixP8o_4core4cell7RefCellINtNtBZ_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEEE14borrow_ref_mutB1T_> @ imm = #0xb06
    2d68:      	str	r0, [sp, #0xc]
    2d6a:      	str	r1, [sp, #0x10]
    2d6c:      	add	r0, sp, #0xc
    2d6e:      	bl	0x3fd2 <_RNvXsR_NtCs6e6HQTixP8o_4core4cellINtB5_6RefMutINtNtB7_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEENtNtNtB7_3ops5deref8DerefMut9deref_mutB16_> @ imm = #0x1260
    2d72:      	mov	r1, r0
    2d74:      	str	r1, [sp, #0x8]
    2d76:      	ldr	r0, [r0]
    2d78:      	cmp	r0, #0x1
    2d7a:      	bne	0x2d8c <_RNCINvNtCs2GpT71Ckjdn_10rtt_target5print21with_terminal_channelNCNCNvCsju8MJypcZ9c_16panic_rtt_target5panic00E0B15_+0x42> @ imm = #0xe
    2d7c:      	b	0x2d7e <_RNCINvNtCs2GpT71Ckjdn_10rtt_target5print21with_terminal_channelNCNCNvCsju8MJypcZ9c_16panic_rtt_target5panic00E0B15_+0x34> @ imm = #-0x2
    2d7e:      	ldr	r0, [sp, #0x4]
    2d80:      	ldr	r1, [sp, #0x8]
    2d82:      	adds	r1, #0x4
    2d84:      	str	r1, [sp, #0x1c]
    2d86:      	bl	0x2d96 <_RNCNCNvCsju8MJypcZ9c_16panic_rtt_target5panic00B5_> @ imm = #0xc
    2d8a:      	b	0x2d8c <_RNCINvNtCs2GpT71Ckjdn_10rtt_target5print21with_terminal_channelNCNCNvCsju8MJypcZ9c_16panic_rtt_target5panic00E0B15_+0x42> @ imm = #-0x2
    2d8c:      	add	r0, sp, #0xc
    2d8e:      	bl	0x2eaa <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueINtNtB4_4cell6RefMutINtNtB4_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEEEB1j_> @ imm = #0x118
    2d92:      	add	sp, #0x20
    2d94:      	pop	{r7, pc}

00002d96 <_RNCNCNvCsju8MJypcZ9c_16panic_rtt_target5panic00B5_>:
    2d96:      	push	{r7, lr}
    2d98:      	mov	r7, sp
    2d9a:      	sub	sp, #0x48
    2d9c:      	str	r1, [sp, #0x4]
    2d9e:      	mov	r1, r0
    2da0:      	ldr	r0, [sp, #0x4]
    2da2:      	str	r1, [sp, #0x8]
    2da4:      	str	r1, [sp, #0x3c]
    2da6:      	str	r0, [sp, #0x40]
    2da8:      	movs	r1, #0x2
    2daa:      	bl	0x3596 <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel8set_mode> @ imm = #0x7e8
    2dae:      	ldr	r1, [sp, #0x4]
    2db0:      	add	r0, sp, #0x14
    2db2:      	str	r0, [sp, #0x10]
    2db4:      	movs	r2, #0x0
    2db6:      	bl	0x348a <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel5write> @ imm = #0x6d0
    2dba:      	ldr	r0, [sp, #0x8]
    2dbc:      	ldr	r1, [r0]
    2dbe:      	str	r1, [sp, #0x44]
    2dc0:      	add	r0, sp, #0x34
    2dc2:      	bl	0x2d04 <_RINvMNtNtCs6e6HQTixP8o_4core3fmt2rtNtB3_8Argument11new_displayRNtNtNtB7_5panic10panic_info9PanicInfoECsju8MJypcZ9c_16panic_rtt_target> @ imm = #-0xc2
    2dc6:      	ldr	r0, [sp, #0x34]
    2dc8:      	ldr	r1, [sp, #0x38]
    2dca:      	str	r1, [sp, #0x30]
    2dcc:      	str	r0, [sp, #0x2c]
    2dce:      	movw	r0, #0x54e1
    2dd2:      	movt	r0, #0x0
    2dd6:      	add	r1, sp, #0x2c
    2dd8:      	bl	0x2d2a <_RINvMs2_NtCs6e6HQTixP8o_4core3fmtNtB6_9Arguments3newKj4_Kj1_ECsju8MJypcZ9c_16panic_rtt_target> @ imm = #-0xb2
    2ddc:      	mov	r2, r0
    2dde:      	ldr	r0, [sp, #0x10]
    2de0:      	str	r2, [sp, #0xc]
    2de2:      	mov	r2, r1
    2de4:      	ldr	r1, [sp, #0xc]
    2de6:      	bl	0x4136 <_RNvYNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterNtNtCs6e6HQTixP8o_4core3fmt5Write9write_fmtB4_> @ imm = #0x134c
    2dea:      	bl	0x316a <_RNvMNtCs6e6HQTixP8o_4core6resultINtB2_6ResultuNtNtB4_3fmt5ErrorE2okCs2GpT71Ckjdn_10rtt_target> @ imm = #0x37c
    2dee:      	ldr	r0, [sp, #0x10]
    2df0:      	bl	0x2ebc <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterEBD_> @ imm = #0xc8
    2df4:      	add	sp, #0x48
    2df6:      	pop	{r7, pc}

00002df8 <_RNCNvCsju8MJypcZ9c_16panic_rtt_target5panic0B3_>:
    2df8:      	push	{r7, lr}
    2dfa:      	mov	r7, sp
    2dfc:      	sub	sp, #0x8
    2dfe:      	str	r0, [sp]
    2e00:      	bl	0x2d38 <_RINvNtCs2GpT71Ckjdn_10rtt_target5print21with_terminal_channelNCNCNvCsju8MJypcZ9c_16panic_rtt_target5panic00EB13_> @ imm = #-0xcc
    2e04:      	b	0x2e06 <_RNCNvCsju8MJypcZ9c_16panic_rtt_target5panic0B3_+0xe> @ imm = #-0x2
    2e06:      	movs	r0, #0x4
    2e08:      	bl	0x2e1c <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCsju8MJypcZ9c_16panic_rtt_target> @ imm = #0x10
    2e0c:      	b	0x2e06 <_RNCNvCsju8MJypcZ9c_16panic_rtt_target5panic0B3_+0xe> @ imm = #-0xa

00002e0e <_RNvCsbj5FHA3exiX_7___rustc17rust_begin_unwind>:
    2e0e:      	push	{r7, lr}
    2e10:      	mov	r7, sp
    2e12:      	sub	sp, #0x8
    2e14:      	str	r0, [sp, #0x4]
    2e16:      	add	r0, sp, #0x4
    2e18:      	bl	0x2ce2 <_RINvCs6gRl320PnDN_16critical_section4withzNCNvCsju8MJypcZ9c_16panic_rtt_target5panic0EBI_> @ imm = #-0x13a

00002e1c <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCsju8MJypcZ9c_16panic_rtt_target>:
    2e1c:      	push	{r7, lr}
    2e1e:      	mov	r7, sp
    2e20:      	sub	sp, #0x10
    2e22:      	strb	r0, [r7, #-9]
    2e26:      	uxtb	r0, r0
    2e28:      	str	r0, [sp]
    2e2a:      	ldr	r1, [sp]
    2e2c:      	tbb	[pc, r1]
    2e30: 04 12 13 14  	.word	0x14131204
    2e34: 15 00	.short	0x0015
    2e36:      	trap
    2e38:      	movw	r0, #0x5e5c
    2e3c:      	movt	r0, #0x0
    2e40:      	str	r0, [sp, #0x8]
    2e42:      	movs	r1, #0x29
    2e44:      	str	r1, [sp, #0xc]
    2e46:      	movw	r2, #0x5e88
    2e4a:      	movt	r2, #0x0
    2e4e:      	movs	r1, #0x53
    2e50:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x19ec
    2e54:      	b	0x2e5c <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCsju8MJypcZ9c_16panic_rtt_target+0x40> @ imm = #0x4
    2e56:      	b	0x2e5c <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCsju8MJypcZ9c_16panic_rtt_target+0x40> @ imm = #0x2
    2e58:      	b	0x2e5c <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCsju8MJypcZ9c_16panic_rtt_target+0x40> @ imm = #0x0
    2e5a:      	b	0x2e5c <_RNvNtNtCs6e6HQTixP8o_4core4sync6atomic14compiler_fenceCsju8MJypcZ9c_16panic_rtt_target+0x40> @ imm = #-0x2
    2e5c:      	add	sp, #0x10
    2e5e:      	pop	{r7, pc}

00002e60 <_RNvXs1i_NtCs6e6HQTixP8o_4core3fmtRNtNtNtB8_5panic10panic_info9PanicInfoNtB6_7Display3fmtCsju8MJypcZ9c_16panic_rtt_target>:
    2e60:      	push	{r7, lr}
    2e62:      	mov	r7, sp
    2e64:      	sub	sp, #0x8
    2e66:      	str	r0, [sp]
    2e68:      	str	r1, [sp, #0x4]
    2e6a:      	ldr	r0, [r0]
    2e6c:      	bl	0x5056 <_RNvXs_NtNtCs6e6HQTixP8o_4core5panic10panic_infoNtB4_9PanicInfoNtNtB8_3fmt7Display3fmt> @ imm = #0x21e6
    2e70:      	add	sp, #0x8
    2e72:      	pop	{r7, pc}

00002e74 <_RINvCs6gRl320PnDN_16critical_section4withuNCNvNtCs2GpT71Ckjdn_10rtt_target5print17set_print_channel0EBK_>:
    2e74:      	push	{r7, lr}
    2e76:      	mov	r7, sp
    2e78:      	sub	sp, #0x10
    2e7a:      	str	r0, [sp]
    2e7c:      	str	r0, [sp, #0x8]
    2e7e:      	bl	0x2c90 <_critical_section_1_0_acquire> @ imm = #-0x1f2
    2e82:      	mov	r1, r0
    2e84:      	ldr	r0, [sp]
    2e86:      	str	r1, [sp, #0xc]
    2e88:      	str	r1, [sp, #0x4]
    2e8a:      	bl	0x3010 <_RNCNvNtCs2GpT71Ckjdn_10rtt_target5print17set_print_channel0B5_> @ imm = #0x182
    2e8e:      	add	r0, sp, #0x4
    2e90:      	bl	0x2ef6 <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueNtNvCs6gRl320PnDN_16critical_section4with5GuardECs2GpT71Ckjdn_10rtt_target> @ imm = #0x62
    2e94:      	add	sp, #0x10
    2e96:      	pop	{r7, pc}

00002e98 <_RINvNtCs6e6HQTixP8o_4core3cmp3minjECs2GpT71Ckjdn_10rtt_target>:
    2e98:      	push	{r7, lr}
    2e9a:      	mov	r7, sp
    2e9c:      	sub	sp, #0x8
    2e9e:      	str	r0, [sp]
    2ea0:      	str	r1, [sp, #0x4]
    2ea2:      	bl	0x4160 <_RNvYjNtNtCs6e6HQTixP8o_4core3cmp3Ord3minCs2GpT71Ckjdn_10rtt_target> @ imm = #0x12ba
    2ea6:      	add	sp, #0x8
    2ea8:      	pop	{r7, pc}

00002eaa <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueINtNtB4_4cell6RefMutINtNtB4_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEEEB1j_>:
    2eaa:      	push	{r7, lr}
    2eac:      	mov	r7, sp
    2eae:      	sub	sp, #0x8
    2eb0:      	str	r0, [sp, #0x4]
    2eb2:      	adds	r0, #0x4
    2eb4:      	bl	0x2ed6 <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueNtNtB4_4cell12BorrowRefMutECs2GpT71Ckjdn_10rtt_target> @ imm = #0x1e
    2eb8:      	add	sp, #0x8
    2eba:      	pop	{r7, pc}

00002ebc <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterEBD_>:
    2ebc:      	push	{r7, lr}
    2ebe:      	mov	r7, sp
    2ec0:      	sub	sp, #0x8
    2ec2:      	str	r0, [sp]
    2ec4:      	str	r0, [sp, #0x4]
    2ec6:      	bl	0x3f9c <_RNvXs7_Cs2GpT71Ckjdn_10rtt_targetNtB5_14TerminalWriterNtNtNtCs6e6HQTixP8o_4core3ops4drop4Drop4drop> @ imm = #0x10d2
    2eca:      	ldr	r0, [sp]
    2ecc:      	adds	r0, #0x4
    2ece:      	bl	0x2ee6 <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueNtNtCs2GpT71Ckjdn_10rtt_target3rtt9RttWriterEBF_> @ imm = #0x14
    2ed2:      	add	sp, #0x8
    2ed4:      	pop	{r7, pc}

00002ed6 <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueNtNtB4_4cell12BorrowRefMutECs2GpT71Ckjdn_10rtt_target>:
    2ed6:      	push	{r7, lr}
    2ed8:      	mov	r7, sp
    2eda:      	sub	sp, #0x8
    2edc:      	str	r0, [sp, #0x4]
    2ede:      	bl	0x3fbe <_RNvXsO_NtCs6e6HQTixP8o_4core4cellNtB5_12BorrowRefMutNtNtNtB7_3ops4drop4Drop4dropCs2GpT71Ckjdn_10rtt_target> @ imm = #0x10dc
    2ee2:      	add	sp, #0x8
    2ee4:      	pop	{r7, pc}

00002ee6 <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueNtNtCs2GpT71Ckjdn_10rtt_target3rtt9RttWriterEBF_>:
    2ee6:      	push	{r7, lr}
    2ee8:      	mov	r7, sp
    2eea:      	sub	sp, #0x8
    2eec:      	str	r0, [sp, #0x4]
    2eee:      	bl	0x3ed4 <_RNvXs1_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriterNtNtNtCs6e6HQTixP8o_4core3ops4drop4Drop4drop> @ imm = #0xfe2
    2ef2:      	add	sp, #0x8
    2ef4:      	pop	{r7, pc}

00002ef6 <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueNtNvCs6gRl320PnDN_16critical_section4with5GuardECs2GpT71Ckjdn_10rtt_target>:
    2ef6:      	push	{r7, lr}
    2ef8:      	mov	r7, sp
    2efa:      	sub	sp, #0x10
    2efc:      	str	r0, [sp, #0x4]
    2efe:      	str	r0, [sp, #0x8]
    2f00:      	ldr	r0, [r0]
    2f02:      	str	r0, [sp, #0xc]
    2f04:      	bl	0x2c9a <_critical_section_1_0_release> @ imm = #-0x26e
    2f08:      	add	sp, #0x10
    2f0a:      	pop	{r7, pc}

00002f0c <_RINvNtNtCs6e6HQTixP8o_4core4sync6atomic11atomic_loadjKb0_ECs2GpT71Ckjdn_10rtt_target>:
    2f0c:      	push	{r7, lr}
    2f0e:      	mov	r7, sp
    2f10:      	sub	sp, #0x28
    2f12:      	str	r0, [sp, #0x4]
    2f14:      	str	r0, [sp, #0x10]
    2f16:      	strb	r1, [r7, #-17]
    2f1a:      	uxtb	r0, r1
    2f1c:      	str	r0, [sp, #0x8]
    2f1e:      	ldr	r1, [sp, #0x8]
    2f20:      	tbb	[pc, r1]
    2f24: 04 08 16 1c  	.word	0x1c160804
    2f28: 2a 00	.short	0x002a
    2f2a:      	trap
    2f2c:      	ldr	r0, [sp, #0x4]
    2f2e:      	ldr	r0, [r0]
    2f30:      	str	r0, [sp, #0xc]
    2f32:      	b	0x2f84 <_RINvNtNtCs6e6HQTixP8o_4core4sync6atomic11atomic_loadjKb0_ECs2GpT71Ckjdn_10rtt_target+0x78> @ imm = #0x4e
    2f34:      	movw	r0, #0x5ea8
    2f38:      	movt	r0, #0x0
    2f3c:      	str	r0, [sp, #0x18]
    2f3e:      	movs	r1, #0x28
    2f40:      	str	r1, [sp, #0x1c]
    2f42:      	movw	r2, #0x5ed0
    2f46:      	movt	r2, #0x0
    2f4a:      	movs	r1, #0x51
    2f4c:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x18f0
    2f50:      	ldr	r0, [sp, #0x4]
    2f52:      	ldr	r0, [r0]
    2f54:      	dmb	sy
    2f58:      	str	r0, [sp, #0xc]
    2f5a:      	b	0x2f84 <_RINvNtNtCs6e6HQTixP8o_4core4sync6atomic11atomic_loadjKb0_ECs2GpT71Ckjdn_10rtt_target+0x78> @ imm = #0x26
    2f5c:      	movw	r0, #0x5ee0
    2f60:      	movt	r0, #0x0
    2f64:      	str	r0, [sp, #0x20]
    2f66:      	movs	r1, #0x31
    2f68:      	str	r1, [sp, #0x24]
    2f6a:      	movw	r2, #0x5f14
    2f6e:      	movt	r2, #0x0
    2f72:      	movs	r1, #0x63
    2f74:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x18c8
    2f78:      	ldr	r0, [sp, #0x4]
    2f7a:      	ldr	r0, [r0]
    2f7c:      	dmb	sy
    2f80:      	str	r0, [sp, #0xc]
    2f82:      	b	0x2f84 <_RINvNtNtCs6e6HQTixP8o_4core4sync6atomic11atomic_loadjKb0_ECs2GpT71Ckjdn_10rtt_target+0x78> @ imm = #-0x2
    2f84:      	ldr	r0, [sp, #0xc]
    2f86:      	add	sp, #0x28
    2f88:      	pop	{r7, pc}
    2f8a:      	bmi	0x2f36 <_RINvNtNtCs6e6HQTixP8o_4core4sync6atomic11atomic_loadjKb0_ECs2GpT71Ckjdn_10rtt_target+0x2a> @ imm = #-0x58

00002f8c <_RINvNtNtCs6e6HQTixP8o_4core4sync6atomic12atomic_storejKb0_ECs2GpT71Ckjdn_10rtt_target>:
    2f8c:      	push	{r7, lr}
    2f8e:      	mov	r7, sp
    2f90:      	sub	sp, #0x28
    2f92:      	str	r1, [sp]
    2f94:      	str	r0, [sp, #0x4]
    2f96:      	str	r0, [sp, #0xc]
    2f98:      	str	r1, [sp, #0x10]
    2f9a:      	strb	r2, [r7, #-17]
    2f9e:      	uxtb	r0, r2
    2fa0:      	str	r0, [sp, #0x8]
    2fa2:      	ldr	r1, [sp, #0x8]
    2fa4:      	tbb	[pc, r1]
    2fa8: 04 08 0e 1c  	.word	0x1c0e0804
    2fac: 2a 00	.short	0x002a
    2fae:      	trap
    2fb0:      	ldr	r0, [sp]
    2fb2:      	ldr	r1, [sp, #0x4]
    2fb4:      	str	r0, [r1]
    2fb6:      	b	0x300c <_RINvNtNtCs6e6HQTixP8o_4core4sync6atomic12atomic_storejKb0_ECs2GpT71Ckjdn_10rtt_target+0x80> @ imm = #0x52
    2fb8:      	ldr	r0, [sp]
    2fba:      	ldr	r1, [sp, #0x4]
    2fbc:      	dmb	sy
    2fc0:      	str	r0, [r1]
    2fc2:      	b	0x300c <_RINvNtNtCs6e6HQTixP8o_4core4sync6atomic12atomic_storejKb0_ECs2GpT71Ckjdn_10rtt_target+0x80> @ imm = #0x46
    2fc4:      	movw	r0, #0x5f24
    2fc8:      	movt	r0, #0x0
    2fcc:      	str	r0, [sp, #0x18]
    2fce:      	movs	r1, #0x2a
    2fd0:      	str	r1, [sp, #0x1c]
    2fd2:      	movw	r2, #0x5f50
    2fd6:      	movt	r2, #0x0
    2fda:      	movs	r1, #0x55
    2fdc:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x1860
    2fe0:      	movw	r0, #0x5f60
    2fe4:      	movt	r0, #0x0
    2fe8:      	str	r0, [sp, #0x20]
    2fea:      	movs	r1, #0x32
    2fec:      	str	r1, [sp, #0x24]
    2fee:      	movw	r2, #0x5f94
    2ff2:      	movt	r2, #0x0
    2ff6:      	movs	r1, #0x65
    2ff8:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x1844
    2ffc:      	ldr	r0, [sp]
    2ffe:      	ldr	r1, [sp, #0x4]
    3000:      	dmb	sy
    3004:      	str	r0, [r1]
    3006:      	dmb	sy
    300a:      	b	0x300c <_RINvNtNtCs6e6HQTixP8o_4core4sync6atomic12atomic_storejKb0_ECs2GpT71Ckjdn_10rtt_target+0x80> @ imm = #-0x2
    300c:      	add	sp, #0x28
    300e:      	pop	{r7, pc}

00003010 <_RNCNvNtCs2GpT71Ckjdn_10rtt_target5print17set_print_channel0B5_>:
    3010:      	push	{r7, lr}
    3012:      	mov	r7, sp
    3014:      	sub	sp, #0x20
    3016:      	str	r0, [sp, #0x18]
    3018:      	ldr	r0, [r0]
    301a:      	bl	0x347c <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel3new> @ imm = #0x45e
    301e:      	str	r0, [sp, #0x8]
    3020:      	strb.w	r1, [sp, #0xc]
    3024:      	movs	r0, #0x1
    3026:      	str	r0, [sp, #0x4]
    3028:      	movw	r0, #0x438
    302c:      	movt	r0, #0x2000
    3030:      	movw	r1, #0x5fa4
    3034:      	movt	r1, #0x0
    3038:      	bl	0x386e <_RNvMs_NtCs6gRl320PnDN_16critical_section5mutexINtB4_5MutexINtNtCs6e6HQTixP8o_4core4cell7RefCellINtNtBZ_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEEE14borrow_ref_mutB1T_> @ imm = #0x832
    303c:      	str	r0, [sp, #0x10]
    303e:      	str	r1, [sp, #0x14]
    3040:      	add	r0, sp, #0x10
    3042:      	str	r0, [sp]
    3044:      	bl	0x3fd2 <_RNvXsR_NtCs6e6HQTixP8o_4core4cellINtB5_6RefMutINtNtB7_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEENtNtNtB7_3ops5deref8DerefMut9deref_mutB16_> @ imm = #0xf8a
    3048:      	mov	r2, r0
    304a:      	ldr	r0, [sp]
    304c:      	ldr	r1, [sp, #0x4]
    304e:      	ldr	r3, [sp, #0x8]
    3050:      	ldr.w	r12, [sp, #0xc]
    3054:      	str.w	r12, [r2, #0x8]
    3058:      	str	r3, [r2, #0x4]
    305a:      	str	r1, [r2]
    305c:      	bl	0x2eaa <_RINvNtCs6e6HQTixP8o_4core3ptr9drop_glueINtNtB4_4cell6RefMutINtNtB4_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEEEB1j_> @ imm = #-0x1b6
    3060:      	add	sp, #0x20
    3062:      	pop	{r7, pc}

00003064 <_RNvMNtCs2GpT71Ckjdn_10rtt_target3rttNtB2_9RttHeader4init>:
    3064:      	push	{r7, lr}
    3066:      	mov	r7, sp
    3068:      	sub	sp, #0x80
    306a:      	str	r2, [sp, #0x1c]
    306c:      	str	r1, [sp, #0x10]
    306e:      	str	r0, [sp, #0x18]
    3070:      	str	r0, [sp, #0x54]
    3072:      	str	r1, [sp, #0x58]
    3074:      	str	r2, [sp, #0x5c]
    3076:      	adds	r0, #0x10
    3078:      	str	r0, [sp, #0x78]
    307a:      	str	r1, [sp, #0x7c]
    307c:      	movw	r2, #0x5fb4
    3080:      	movt	r2, #0x0
    3084:      	movs	r1, #0x4
    3086:      	str	r1, [sp, #0x14]
    3088:      	bl	0x3bac <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCs2GpT71Ckjdn_10rtt_target> @ imm = #0xb20
    308c:      	ldr	r3, [sp, #0x10]
    308e:      	ldr	r1, [sp, #0x14]
    3090:      	ldr	r0, [sp, #0x18]
    3092:      	ldr	r2, [sp, #0x1c]
    3094:      	str	r3, [r0, #0x10]
    3096:      	adds	r0, #0x14
    3098:      	str	r0, [sp, #0x70]
    309a:      	str	r2, [sp, #0x74]
    309c:      	movw	r2, #0x5fc4
    30a0:      	movt	r2, #0x0
    30a4:      	bl	0x3bac <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCs2GpT71Ckjdn_10rtt_target> @ imm = #0xb04
    30a8:      	ldr	r0, [sp, #0x18]
    30aa:      	ldr	r2, [sp, #0x1c]
    30ac:      	str	r2, [r0, #0x14]
    30ae:      	movw	r0, #0x5fe4
    30b2:      	movt	r0, #0x0
    30b6:      	bl	0x40b2 <_RNvXsb_NtCs6e6HQTixP8o_4core5arrayRAhj10_NtNtNtNtB7_4iter6traits7collect12IntoIterator9into_iterCs2GpT71Ckjdn_10rtt_target> @ imm = #0xff8
    30ba:      	str	r0, [sp, #0x20]
    30bc:      	mov	r2, r1
    30be:      	ldr	r1, [sp, #0x20]
    30c0:      	add	r0, sp, #0x34
    30c2:      	str	r0, [sp, #0x24]
    30c4:      	bl	0x40e2 <_RNvYINtNtNtCs6e6HQTixP8o_4core5slice4iter4IterhENtNtNtNtB9_4iter6traits8iterator8Iterator9enumerateCs2GpT71Ckjdn_10rtt_target> @ imm = #0x101a
    30c8:      	ldr	r1, [sp, #0x24]
    30ca:      	add	r0, sp, #0x28
    30cc:      	bl	0x3ebe <_RNvXNtNtNtCs6e6HQTixP8o_4core4iter6traits7collectINtNtNtB6_8adapters9enumerate9EnumerateINtNtNtB8_5slice4iter4IterhEENtB2_12IntoIterator9into_iterCs2GpT71Ckjdn_10rtt_target> @ imm = #0xdee
    30d0:      	ldr	r0, [sp, #0x28]
    30d2:      	ldr	r1, [sp, #0x2c]
    30d4:      	ldr	r2, [sp, #0x30]
    30d6:      	str	r2, [sp, #0x48]
    30d8:      	str	r1, [sp, #0x44]
    30da:      	str	r0, [sp, #0x40]
    30dc:      	b	0x30de <_RNvMNtCs2GpT71Ckjdn_10rtt_target3rttNtB2_9RttHeader4init+0x7a> @ imm = #-0x2
    30de:      	add	r0, sp, #0x40
    30e0:      	bl	0x3fe0 <_RNvXs_NtNtNtCs6e6HQTixP8o_4core4iter8adapters9enumerateINtB4_9EnumerateINtNtNtBa_5slice4iter4IterhEENtNtNtB8_6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target> @ imm = #0xefc
    30e4:      	str	r0, [sp, #0x4c]
    30e6:      	str	r1, [sp, #0x50]
    30e8:      	ldr	r0, [sp, #0x50]
    30ea:      	cbz	r0, 0x3104 <_RNvMNtCs2GpT71Ckjdn_10rtt_target3rttNtB2_9RttHeader4init+0xa0> @ imm = #0x16
    30ec:      	b	0x30ee <_RNvMNtCs2GpT71Ckjdn_10rtt_target3rttNtB2_9RttHeader4init+0x8a> @ imm = #-0x2
    30ee:      	ldr	r0, [sp, #0x4c]
    30f0:      	str	r0, [sp, #0x60]
    30f2:      	ldr	r1, [sp, #0x50]
    30f4:      	str	r1, [sp, #0x8]
    30f6:      	str	r1, [sp, #0x64]
    30f8:      	rsb.w	r1, r0, #0xf
    30fc:      	str	r1, [sp, #0xc]
    30fe:      	cmp	r0, #0xf
    3100:      	bhi	0x3110 <_RNvMNtCs2GpT71Ckjdn_10rtt_target3rttNtB2_9RttHeader4init+0xac> @ imm = #0xc
    3102:      	b	0x3108 <_RNvMNtCs2GpT71Ckjdn_10rtt_target3rttNtB2_9RttHeader4init+0xa4> @ imm = #0x2
    3104:      	add	sp, #0x80
    3106:      	pop	{r7, pc}
    3108:      	ldr	r0, [sp, #0xc]
    310a:      	cmp	r0, #0x10
    310c:      	blo	0x311c <_RNvMNtCs2GpT71Ckjdn_10rtt_target3rttNtB2_9RttHeader4init+0xb8> @ imm = #0xc
    310e:      	b	0x3146 <_RNvMNtCs2GpT71Ckjdn_10rtt_target3rttNtB2_9RttHeader4init+0xe2> @ imm = #0x34
    3110:      	movw	r0, #0x6004
    3114:      	movt	r0, #0x0
    3118:      	bl	0x4de4 <_RNvNtNtCs6e6HQTixP8o_4core9panicking11panic_const24panic_const_sub_overflow> @ imm = #0x1cc8
    311c:      	ldr	r0, [sp, #0x18]
    311e:      	ldr	r2, [sp, #0xc]
    3120:      	ldr	r1, [sp, #0x8]
    3122:      	add	r0, r2
    3124:      	ldrb	r1, [r1]
    3126:      	str	r1, [sp, #0x4]
    3128:      	str	r0, [sp, #0x68]
    312a:      	strb	r1, [r7, #-17]
    312e:      	movw	r2, #0x6024
    3132:      	movt	r2, #0x0
    3136:      	movs	r1, #0x1
    3138:      	bl	0x3bac <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCs2GpT71Ckjdn_10rtt_target> @ imm = #0xa70
    313c:      	ldr	r2, [sp, #0xc]
    313e:      	ldr	r1, [sp, #0x18]
    3140:      	ldr	r0, [sp, #0x4]
    3142:      	strb	r0, [r1, r2]
    3144:      	b	0x30de <_RNvMNtCs2GpT71Ckjdn_10rtt_target3rttNtB2_9RttHeader4init+0x7a> @ imm = #-0x6a
    3146:      	ldr	r0, [sp, #0xc]
    3148:      	movw	r2, #0x6014
    314c:      	movt	r2, #0x0
    3150:      	movs	r1, #0x10
    3152:      	bl	0x4798 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_bounds_check> @ imm = #0x1642

00003156 <_RNvMNtCs6e6HQTixP8o_4core5sliceSh8is_emptyCs2GpT71Ckjdn_10rtt_target>:
    3156:      	push	{r7, lr}
    3158:      	mov	r7, sp
    315a:      	sub	sp, #0x8
    315c:      	str	r0, [sp]
    315e:      	str	r1, [sp, #0x4]
    3160:      	clz	r0, r1
    3164:      	lsrs	r0, r0, #0x5
    3166:      	add	sp, #0x8
    3168:      	pop	{r7, pc}

0000316a <_RNvMNtCs6e6HQTixP8o_4core6resultINtB2_6ResultuNtNtB4_3fmt5ErrorE2okCs2GpT71Ckjdn_10rtt_target>:
    316a:      	push	{r7, lr}
    316c:      	mov	r7, sp
    316e:      	sub	sp, #0x4
    3170:      	strb	r0, [r7, #-3]
    3174:      	ldrb	r0, [r7, #-3]
    3178:      	lsls	r0, r0, #0x1f
    317a:      	cbz	r0, 0x3186 <_RNvMNtCs6e6HQTixP8o_4core6resultINtB2_6ResultuNtNtB4_3fmt5ErrorE2okCs2GpT71Ckjdn_10rtt_target+0x1c> @ imm = #0x8
    317c:      	b	0x317e <_RNvMNtCs6e6HQTixP8o_4core6resultINtB2_6ResultuNtNtB4_3fmt5ErrorE2okCs2GpT71Ckjdn_10rtt_target+0x14> @ imm = #-0x2
    317e:      	movs	r0, #0x0
    3180:      	strb	r0, [r7, #-2]
    3184:      	b	0x318e <_RNvMNtCs6e6HQTixP8o_4core6resultINtB2_6ResultuNtNtB4_3fmt5ErrorE2okCs2GpT71Ckjdn_10rtt_target+0x24> @ imm = #0x6
    3186:      	movs	r0, #0x1
    3188:      	strb	r0, [r7, #-2]
    318c:      	b	0x318e <_RNvMNtCs6e6HQTixP8o_4core6resultINtB2_6ResultuNtNtB4_3fmt5ErrorE2okCs2GpT71Ckjdn_10rtt_target+0x24> @ imm = #-0x2
    318e:      	ldrb	r0, [r7, #-3]
    3192:      	lsls	r0, r0, #0x1f
    3194:      	cbz	r0, 0x319a <_RNvMNtCs6e6HQTixP8o_4core6resultINtB2_6ResultuNtNtB4_3fmt5ErrorE2okCs2GpT71Ckjdn_10rtt_target+0x30> @ imm = #0x2
    3196:      	b	0x3198 <_RNvMNtCs6e6HQTixP8o_4core6resultINtB2_6ResultuNtNtB4_3fmt5ErrorE2okCs2GpT71Ckjdn_10rtt_target+0x2e> @ imm = #-0x2
    3198:      	b	0x319a <_RNvMNtCs6e6HQTixP8o_4core6resultINtB2_6ResultuNtNtB4_3fmt5ErrorE2okCs2GpT71Ckjdn_10rtt_target+0x30> @ imm = #-0x2
    319a:      	ldrb	r0, [r7, #-2]
    319e:      	add	sp, #0x4
    31a0:      	pop	{r7, pc}

000031a2 <_RNvMNtCs6gRl320PnDN_16critical_section5mutexINtB2_5MutexINtNtCs6e6HQTixP8o_4core4cell7RefCellINtNtBX_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEEE6borrowB1R_>:
    31a2:      	push	{r7, lr}
    31a4:      	mov	r7, sp
    31a6:      	sub	sp, #0xc
    31a8:      	str	r0, [sp]
    31aa:      	str	r0, [sp, #0x8]
    31ac:      	add	sp, #0xc
    31ae:      	pop	{r7, pc}

000031b0 <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs2GpT71Ckjdn_10rtt_target>:
    31b0:      	push	{r7, lr}
    31b2:      	mov	r7, sp
    31b4:      	sub	sp, #0x18
    31b6:      	str	r1, [sp]
    31b8:      	mov	r1, r0
    31ba:      	ldr	r0, [sp]
    31bc:      	str	r1, [sp, #0x4]
    31be:      	str	r1, [sp, #0x8]
    31c0:      	str	r0, [sp, #0xc]
    31c2:      	subs	r1, r0, #0x1
    31c4:      	eors	r0, r1
    31c6:      	cmp	r0, r1
    31c8:      	bhi	0x31e8 <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs2GpT71Ckjdn_10rtt_target+0x38> @ imm = #0x1c
    31ca:      	b	0x31cc <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs2GpT71Ckjdn_10rtt_target+0x1c> @ imm = #-0x2
    31cc:      	movw	r0, #0x6034
    31d0:      	movt	r0, #0x0
    31d4:      	str	r0, [sp, #0x10]
    31d6:      	movs	r1, #0x2a
    31d8:      	str	r1, [sp, #0x14]
    31da:      	movw	r2, #0x6060
    31de:      	movt	r2, #0x0
    31e2:      	movs	r1, #0x55
    31e4:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x1658
    31e8:      	ldr	r0, [sp, #0x4]
    31ea:      	ldr	r1, [sp]
    31ec:      	subs	r1, #0x1
    31ee:      	ands	r0, r1
    31f0:      	clz	r0, r0
    31f4:      	lsrs	r0, r0, #0x5
    31f6:      	add	sp, #0x18
    31f8:      	pop	{r7, pc}

000031fa <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter11commit_impl>:
    31fa:      	push	{r7, lr}
    31fc:      	mov	r7, sp
    31fe:      	sub	sp, #0x8
    3200:      	str	r0, [sp]
    3202:      	str	r0, [sp, #0x4]
    3204:      	ldrb	r0, [r0, #0xc]
    3206:      	cmp	r0, #0x2
    3208:      	blo	0x3210 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter11commit_impl+0x16> @ imm = #0x4
    320a:      	b	0x320c <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter11commit_impl+0x12> @ imm = #-0x2
    320c:      	b	0x322e <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter11commit_impl+0x34> @ imm = #0x1e
    320e:      	trap
    3210:      	ldr	r1, [sp]
    3212:      	ldr	r0, [r1]
    3214:      	ldr	r1, [r1, #0x4]
    3216:      	adds	r0, #0xc
    3218:      	movw	r3, #0x6070
    321c:      	movt	r3, #0x0
    3220:      	movs	r2, #0x4
    3222:      	bl	0x38f4 <_RNvMsi_CschsfQPGDbJ4_15portable_atomicNtB5_11AtomicUsize5storeCs2GpT71Ckjdn_10rtt_target> @ imm = #0x6ce
    3226:      	ldr	r1, [sp]
    3228:      	movs	r0, #0x2
    322a:      	strb	r0, [r1, #0xc]
    322c:      	b	0x322e <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter11commit_impl+0x34> @ imm = #-0x2
    322e:      	add	sp, #0x8
    3230:      	pop	{r7, pc}

00003232 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode>:
    3232:      	push	{r7, lr}
    3234:      	mov	r7, sp
    3236:      	sub	sp, #0x60
    3238:      	str	r1, [sp, #0x1c]
    323a:      	str	r0, [sp, #0x20]
    323c:      	str	r2, [sp, #0x24]
    323e:      	str	r3, [sp, #0x28]
    3240:      	str	r0, [sp, #0x2c]
    3242:      	str	r1, [sp, #0x30]
    3244:      	b	0x3246 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x14> @ imm = #-0x2
    3246:      	ldr	r0, [sp, #0x20]
    3248:      	adds	r0, #0xc
    324a:      	movw	r1, #0x561a
    324e:      	movt	r1, #0x0
    3252:      	bl	0x3f46 <_RNvXs5_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_10WriteStateNtNtCs6e6HQTixP8o_4core3cmp9PartialEq2eqB7_> @ imm = #0xcf0
    3256:      	cbnz	r0, 0x325e <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x2c> @ imm = #0x4
    3258:      	b	0x325a <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x28> @ imm = #-0x2
    325a:      	add	sp, #0x60
    325c:      	pop	{r7, pc}
    325e:      	ldr	r0, [sp, #0x24]
    3260:      	ldr	r1, [sp, #0x28]
    3262:      	bl	0x3156 <_RNvMNtCs6e6HQTixP8o_4core5sliceSh8is_emptyCs2GpT71Ckjdn_10rtt_target> @ imm = #-0x110
    3266:      	cmp	r0, #0x0
    3268:      	bne	0x325a <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x28> @ imm = #-0x12
    326a:      	b	0x326c <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x3a> @ imm = #-0x2
    326c:      	ldr	r0, [sp, #0x20]
    326e:      	bl	0x3378 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous> @ imm = #0x106
    3272:      	ldr	r1, [sp, #0x28]
    3274:      	bl	0x2e98 <_RINvNtCs6e6HQTixP8o_4core3cmp3minjECs2GpT71Ckjdn_10rtt_target> @ imm = #-0x3e0
    3278:      	mov	r1, r0
    327a:      	str	r1, [sp, #0x18]
    327c:      	str	r0, [sp, #0x34]
    327e:      	cbz	r0, 0x32d8 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0xa6> @ imm = #0x56
    3280:      	b	0x3282 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x50> @ imm = #-0x2
    3282:      	ldr	r2, [sp, #0x18]
    3284:      	ldr	r3, [sp, #0x20]
    3286:      	ldr	r0, [sp, #0x24]
    3288:      	str	r0, [sp, #0x10]
    328a:      	ldr	r1, [sp, #0x28]
    328c:      	str	r0, [sp, #0x44]
    328e:      	str	r1, [sp, #0x48]
    3290:      	ldr	r1, [r3]
    3292:      	ldr	r3, [r3, #0x4]
    3294:      	ldr	r1, [r1, #0x4]
    3296:      	str	r1, [sp, #0x4c]
    3298:      	str	r3, [sp, #0x50]
    329a:      	add	r1, r3
    329c:      	str	r1, [sp, #0xc]
    329e:      	str	r0, [sp, #0x38]
    32a0:      	str	r1, [sp, #0x3c]
    32a2:      	str	r2, [sp, #0x40]
    32a4:      	movw	r12, #0x5e98
    32a8:      	movt	r12, #0x0
    32ac:      	mov	r3, sp
    32ae:      	str.w	r12, [r3, #0x4]
    32b2:      	str	r2, [r3]
    32b4:      	movs	r3, #0x1
    32b6:      	mov	r2, r3
    32b8:      	bl	0x3be0 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target> @ imm = #0x924
    32bc:      	ldr	r0, [sp, #0xc]
    32be:      	ldr	r1, [sp, #0x10]
    32c0:      	ldr	r2, [sp, #0x18]
    32c2:      	bl	0x5472 <__aeabi_memcpy> @ imm = #0x21ac
    32c6:      	ldr	r1, [sp, #0x20]
    32c8:      	ldr	r0, [sp, #0x18]
    32ca:      	ldr	r1, [r1, #0x4]
    32cc:      	add	r0, r1
    32ce:      	mov	r2, r0
    32d0:      	str	r2, [sp, #0x14]
    32d2:      	cmp	r0, r1
    32d4:      	blo	0x3328 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0xf6> @ imm = #0x50
    32d6:      	b	0x3312 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0xe0> @ imm = #0x38
    32d8:      	ldr	r0, [sp, #0x1c]
    32da:      	cbz	r0, 0x32ea <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0xb8> @ imm = #0xc
    32dc:      	b	0x32de <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0xac> @ imm = #-0x2
    32de:      	ldr	r0, [sp, #0x1c]
    32e0:      	cmp	r0, #0x1
    32e2:      	beq	0x32f2 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0xc0> @ imm = #0xc
    32e4:      	b	0x32e6 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0xb4> @ imm = #-0x2
    32e6:      	b	0x32fa <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0xc8> @ imm = #0x10
    32e8:      	trap
    32ea:      	ldr	r1, [sp, #0x20]
    32ec:      	movs	r0, #0x2
    32ee:      	strb	r0, [r1, #0xc]
    32f0:      	b	0x325a <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x28> @ imm = #-0x9a
    32f2:      	ldr	r1, [sp, #0x20]
    32f4:      	movs	r0, #0x1
    32f6:      	strb	r0, [r1, #0xc]
    32f8:      	b	0x3282 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x50> @ imm = #-0x7a
    32fa:      	ldr	r1, [sp, #0x20]
    32fc:      	ldr	r0, [r1]
    32fe:      	ldr	r1, [r1, #0x4]
    3300:      	adds	r0, #0xc
    3302:      	movw	r3, #0x60b0
    3306:      	movt	r3, #0x0
    330a:      	movs	r2, #0x4
    330c:      	bl	0x38f4 <_RNvMsi_CschsfQPGDbJ4_15portable_atomicNtB5_11AtomicUsize5storeCs2GpT71Ckjdn_10rtt_target> @ imm = #0x5e4
    3310:      	b	0x3246 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x14> @ imm = #-0xce
    3312:      	ldr	r0, [sp, #0x18]
    3314:      	ldr	r1, [sp, #0x20]
    3316:      	ldr	r2, [sp, #0x14]
    3318:      	str	r2, [r1, #0x4]
    331a:      	ldr	r1, [r1, #0x8]
    331c:      	add	r0, r1
    331e:      	mov	r2, r0
    3320:      	str	r2, [sp, #0x8]
    3322:      	cmp	r0, r1
    3324:      	blo	0x3346 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x114> @ imm = #0x1e
    3326:      	b	0x3334 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x102> @ imm = #0xa
    3328:      	movw	r0, #0x6080
    332c:      	movt	r0, #0x0
    3330:      	bl	0x4dd0 <_RNvNtNtCs6e6HQTixP8o_4core9panicking11panic_const24panic_const_add_overflow> @ imm = #0x1a9c
    3334:      	ldr	r0, [sp, #0x20]
    3336:      	ldr	r1, [sp, #0x8]
    3338:      	str	r1, [r0, #0x8]
    333a:      	ldr	r1, [r0]
    333c:      	ldr	r0, [r0, #0x4]
    333e:      	ldr	r1, [r1, #0x8]
    3340:      	cmp	r0, r1
    3342:      	bhs	0x3370 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x13e> @ imm = #0x2a
    3344:      	b	0x3352 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x120> @ imm = #0xa
    3346:      	movw	r0, #0x6090
    334a:      	movt	r0, #0x0
    334e:      	bl	0x4dd0 <_RNvNtNtCs6e6HQTixP8o_4core9panicking11panic_const24panic_const_add_overflow> @ imm = #0x1a7e
    3352:      	ldr	r0, [sp, #0x18]
    3354:      	ldr	r1, [sp, #0x24]
    3356:      	ldr	r2, [sp, #0x28]
    3358:      	str	r1, [sp, #0x54]
    335a:      	str	r2, [sp, #0x58]
    335c:      	str	r0, [sp, #0x5c]
    335e:      	movw	r3, #0x60a0
    3362:      	movt	r3, #0x0
    3366:      	bl	0x3f64 <_RNvXs5_NtNtCs6e6HQTixP8o_4core5slice5indexINtNtNtB9_3ops5range9RangeFromjEINtB5_10SliceIndexShE5indexCs2GpT71Ckjdn_10rtt_target> @ imm = #0xbfa
    336a:      	str	r0, [sp, #0x24]
    336c:      	str	r1, [sp, #0x28]
    336e:      	b	0x3246 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x14> @ imm = #-0x12c
    3370:      	ldr	r1, [sp, #0x20]
    3372:      	movs	r0, #0x0
    3374:      	str	r0, [r1, #0x4]
    3376:      	b	0x3352 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode+0x120> @ imm = #-0x28

00003378 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous>:
    3378:      	push	{r7, lr}
    337a:      	mov	r7, sp
    337c:      	sub	sp, #0x28
    337e:      	str	r0, [sp, #0x14]
    3380:      	str	r0, [sp, #0x20]
    3382:      	ldr	r0, [r0]
    3384:      	bl	0x369c <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel13read_pointers> @ imm = #0x314
    3388:      	ldr	r0, [sp, #0x14]
    338a:      	mov	r2, r1
    338c:      	str	r2, [sp, #0x18]
    338e:      	str	r1, [sp, #0x24]
    3390:      	ldr	r0, [r0, #0x4]
    3392:      	cmp	r1, r0
    3394:      	bhi	0x339e <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x26> @ imm = #0x6
    3396:      	b	0x3398 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x20> @ imm = #-0x2
    3398:      	ldr	r0, [sp, #0x18]
    339a:      	cbz	r0, 0x33c0 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x48> @ imm = #0x22
    339c:      	b	0x33ae <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x36> @ imm = #0xe
    339e:      	ldr	r0, [sp, #0x18]
    33a0:      	ldr	r1, [sp, #0x14]
    33a2:      	ldr	r1, [r1, #0x4]
    33a4:      	subs	r2, r0, r1
    33a6:      	str	r2, [sp, #0x10]
    33a8:      	cmp	r0, r1
    33aa:      	blo	0x341c <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0xa4> @ imm = #0x6e
    33ac:      	b	0x3412 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x9a> @ imm = #0x62
    33ae:      	ldr	r1, [sp, #0x14]
    33b0:      	ldr	r0, [r1]
    33b2:      	ldr	r1, [r1, #0x4]
    33b4:      	ldr	r0, [r0, #0x8]
    33b6:      	subs	r2, r0, r1
    33b8:      	str	r2, [sp, #0xc]
    33ba:      	cmp	r0, r1
    33bc:      	blo	0x33d8 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x60> @ imm = #0x18
    33be:      	b	0x33d2 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x5a> @ imm = #0x10
    33c0:      	ldr	r1, [sp, #0x14]
    33c2:      	ldr	r0, [r1]
    33c4:      	ldr	r1, [r1, #0x4]
    33c6:      	ldr	r0, [r0, #0x8]
    33c8:      	subs	r2, r0, r1
    33ca:      	str	r2, [sp, #0x8]
    33cc:      	cmp	r0, r1
    33ce:      	blo	0x33f4 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x7c> @ imm = #0x22
    33d0:      	b	0x33ea <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x72> @ imm = #0x16
    33d2:      	ldr	r0, [sp, #0xc]
    33d4:      	str	r0, [sp, #0x1c]
    33d6:      	b	0x33e4 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x6c> @ imm = #0xa
    33d8:      	movw	r0, #0x60c0
    33dc:      	movt	r0, #0x0
    33e0:      	bl	0x4de4 <_RNvNtNtCs6e6HQTixP8o_4core9panicking11panic_const24panic_const_sub_overflow> @ imm = #0x1a00
    33e4:      	ldr	r0, [sp, #0x1c]
    33e6:      	add	sp, #0x28
    33e8:      	pop	{r7, pc}
    33ea:      	ldr	r0, [sp, #0x8]
    33ec:      	subs	r1, r0, #0x1
    33ee:      	str	r1, [sp, #0x4]
    33f0:      	cbz	r0, 0x3406 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x8e> @ imm = #0x12
    33f2:      	b	0x3400 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x88> @ imm = #0xa
    33f4:      	movw	r0, #0x60d0
    33f8:      	movt	r0, #0x0
    33fc:      	bl	0x4de4 <_RNvNtNtCs6e6HQTixP8o_4core9panicking11panic_const24panic_const_sub_overflow> @ imm = #0x19e4
    3400:      	ldr	r0, [sp, #0x4]
    3402:      	str	r0, [sp, #0x1c]
    3404:      	b	0x33e4 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x6c> @ imm = #-0x24
    3406:      	movw	r0, #0x60d0
    340a:      	movt	r0, #0x0
    340e:      	bl	0x4de4 <_RNvNtNtCs6e6HQTixP8o_4core9panicking11panic_const24panic_const_sub_overflow> @ imm = #0x19d2
    3412:      	ldr	r0, [sp, #0x10]
    3414:      	subs	r1, r0, #0x1
    3416:      	str	r1, [sp]
    3418:      	cbz	r0, 0x342e <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0xb6> @ imm = #0x12
    341a:      	b	0x3428 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0xb0> @ imm = #0xa
    341c:      	movw	r0, #0x60e0
    3420:      	movt	r0, #0x0
    3424:      	bl	0x4de4 <_RNvNtNtCs6e6HQTixP8o_4core9panicking11panic_const24panic_const_sub_overflow> @ imm = #0x19bc
    3428:      	ldr	r0, [sp]
    342a:      	str	r0, [sp, #0x1c]
    342c:      	b	0x33e4 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter19writable_contiguous+0x6c> @ imm = #-0x4c
    342e:      	movw	r0, #0x60e0
    3432:      	movt	r0, #0x0
    3436:      	bl	0x4de4 <_RNvNtNtCs6e6HQTixP8o_4core9panicking11panic_const24panic_const_sub_overflow> @ imm = #0x19aa

0000343a <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter5write>:
    343a:      	push	{r7, lr}
    343c:      	mov	r7, sp
    343e:      	sub	sp, #0x18
    3440:      	str	r2, [sp, #0x4]
    3442:      	str	r1, [sp]
    3444:      	str	r0, [sp, #0x8]
    3446:      	str	r0, [sp, #0xc]
    3448:      	str	r1, [sp, #0x10]
    344a:      	str	r2, [sp, #0x14]
    344c:      	ldr	r0, [r0]
    344e:      	bl	0x37b6 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode> @ imm = #0x364
    3452:      	ldr	r2, [sp]
    3454:      	ldr	r3, [sp, #0x4]
    3456:      	mov	r1, r0
    3458:      	ldr	r0, [sp, #0x8]
    345a:      	bl	0x3232 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode> @ imm = #-0x22c
    345e:      	add	sp, #0x18
    3460:      	pop	{r7, pc}

00003462 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter9is_failed>:
    3462:      	push	{r7, lr}
    3464:      	mov	r7, sp
    3466:      	sub	sp, #0x8
    3468:      	str	r0, [sp, #0x4]
    346a:      	adds	r0, #0xc
    346c:      	movw	r1, #0x60f0
    3470:      	movt	r1, #0x0
    3474:      	bl	0x414a <_RNvYNtNtCs2GpT71Ckjdn_10rtt_target3rtt10WriteStateNtNtCs6e6HQTixP8o_4core3cmp9PartialEq2neB6_> @ imm = #0xcd2
    3478:      	add	sp, #0x8
    347a:      	pop	{r7, pc}

0000347c <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel3new>:
    347c:      	push	{r7, lr}
    347e:      	mov	r7, sp
    3480:      	sub	sp, #0x4
    3482:      	str	r0, [sp]
    3484:      	movs	r1, #0x0
    3486:      	add	sp, #0x4
    3488:      	pop	{r7, pc}

0000348a <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel5write>:
    348a:      	push	{r4, r6, r7, lr}
    348c:      	add	r7, sp, #0x8
    348e:      	sub	sp, #0x60
    3490:      	str	r1, [sp, #0x14]
    3492:      	mov	r1, r0
    3494:      	ldr	r0, [sp, #0x14]
    3496:      	str	r1, [sp, #0xc]
    3498:      	uxtb	r1, r2
    349a:      	str	r1, [sp, #0x18]
    349c:      	mov	r1, r2
    349e:      	str	r1, [sp, #0x10]
    34a0:      	str	r0, [sp, #0x58]
    34a2:      	strb	r2, [r7, #-9]
    34a6:      	bl	0x3674 <_RNvMs_Cs2GpT71Ckjdn_10rtt_targetNtB4_9UpChannel7channel> @ imm = #0x1ca
    34aa:      	mov	r1, r0
    34ac:      	add	r0, sp, #0x1c
    34ae:      	bl	0x380a <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel6writer> @ imm = #0x358
    34b2:      	ldr	r1, [sp, #0x14]
    34b4:      	ldr	r0, [sp, #0x18]
    34b6:      	ldrb	r1, [r1, #0x4]
    34b8:      	cmp	r0, r1
    34ba:      	bne	0x34fe <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel5write+0x74> @ imm = #0x40
    34bc:      	b	0x34be <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel5write+0x34> @ imm = #-0x2
    34be:      	ldr	r1, [sp, #0xc]
    34c0:      	ldr	r2, [sp, #0x10]
    34c2:      	ldr	r0, [sp, #0x14]
    34c4:      	ldr	r3, [sp, #0x1c]
    34c6:      	ldr.w	r12, [sp, #0x20]
    34ca:      	ldr.w	lr, [sp, #0x24]
    34ce:      	ldr	r4, [sp, #0x28]
    34d0:      	str	r4, [sp, #0x54]
    34d2:      	str.w	lr, [sp, #0x50]
    34d6:      	str.w	r12, [sp, #0x4c]
    34da:      	str	r3, [sp, #0x48]
    34dc:      	adds	r0, #0x4
    34de:      	ldr	r3, [sp, #0x48]
    34e0:      	ldr.w	r12, [sp, #0x4c]
    34e4:      	ldr.w	lr, [sp, #0x50]
    34e8:      	ldr	r4, [sp, #0x54]
    34ea:      	str	r4, [r1, #0x10]
    34ec:      	str.w	lr, [r1, #0xc]
    34f0:      	str.w	r12, [r1, #0x8]
    34f4:      	str	r3, [r1, #0x4]
    34f6:      	strb	r2, [r1, #0x14]
    34f8:      	str	r0, [r1]
    34fa:      	add	sp, #0x60
    34fc:      	pop	{r4, r6, r7, pc}
    34fe:      	ldr	r0, [sp, #0x14]
    3500:      	bl	0x3660 <_RNvMs_Cs2GpT71Ckjdn_10rtt_targetNtB4_9UpChannel4mode> @ imm = #0x15c
    3504:      	str	r0, [sp, #0x2c]
    3506:      	movw	r1, #0x60f4
    350a:      	movt	r1, #0x0
    350e:      	add	r0, sp, #0x2c
    3510:      	bl	0x4094 <_RNvXsa_Cs2GpT71Ckjdn_10rtt_targetNtB5_11ChannelModeNtNtCs6e6HQTixP8o_4core3cmp9PartialEq2eqB5_> @ imm = #0xb80
    3514:      	cbnz	r0, 0x351e <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel5write+0x94> @ imm = #0x6
    3516:      	b	0x3518 <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel5write+0x8e> @ imm = #-0x2
    3518:      	ldr	r0, [sp, #0x2c]
    351a:      	str	r0, [sp, #0x30]
    351c:      	b	0x3524 <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel5write+0x9a> @ imm = #0x4
    351e:      	movs	r0, #0x0
    3520:      	str	r0, [sp, #0x30]
    3522:      	b	0x3524 <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel5write+0x9a> @ imm = #-0x2
    3524:      	ldr	r0, [sp, #0x10]
    3526:      	ldr	r1, [sp, #0x30]
    3528:      	str	r1, [sp, #0x4]
    352a:      	movw	r1, #0x4443
    352e:      	movt	r1, #0x4645
    3532:      	str	r1, [sp, #0x44]
    3534:      	movw	r1, #0x3938
    3538:      	movt	r1, #0x4241
    353c:      	str	r1, [sp, #0x40]
    353e:      	movw	r1, #0x3534
    3542:      	movt	r1, #0x3736
    3546:      	str	r1, [sp, #0x3c]
    3548:      	movw	r1, #0x3130
    354c:      	movt	r1, #0x3332
    3550:      	str	r1, [sp, #0x38]
    3552:      	and	r0, r0, #0xf
    3556:      	mov	r1, r0
    3558:      	str	r1, [sp, #0x8]
    355a:      	cmp	r0, #0xf
    355c:      	bhi	0x3586 <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel5write+0xfc> @ imm = #0x26
    355e:      	b	0x3560 <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel5write+0xd6> @ imm = #-0x2
    3560:      	ldr	r1, [sp, #0x4]
    3562:      	ldr	r2, [sp, #0x8]
    3564:      	add	r0, sp, #0x38
    3566:      	ldrb	r0, [r0, r2]
    3568:      	movs	r2, #0xff
    356a:      	strb	r2, [r7, #-50]
    356e:      	strb	r0, [r7, #-49]
    3572:      	add	r0, sp, #0x1c
    3574:      	sub.w	r2, r7, #0x32
    3578:      	movs	r3, #0x2
    357a:      	bl	0x3232 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter15write_with_mode> @ imm = #-0x34c
    357e:      	ldr	r1, [sp, #0x14]
    3580:      	ldr	r0, [sp, #0x10]
    3582:      	strb	r0, [r1, #0x4]
    3584:      	b	0x34be <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel5write+0x34> @ imm = #-0xca
    3586:      	ldr	r0, [sp, #0x8]
    3588:      	movw	r2, #0x60f8
    358c:      	movt	r2, #0x0
    3590:      	movs	r1, #0x10
    3592:      	bl	0x4798 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_bounds_check> @ imm = #0x1202

00003596 <_RNvMs4_Cs2GpT71Ckjdn_10rtt_targetNtB5_15TerminalChannel8set_mode>:
    3596:      	push	{r7, lr}
    3598:      	mov	r7, sp
    359a:      	sub	sp, #0x8
    359c:      	str	r0, [sp]
    359e:      	str	r1, [sp, #0x4]
    35a0:      	bl	0x3682 <_RNvMs_Cs2GpT71Ckjdn_10rtt_targetNtB4_9UpChannel8set_mode> @ imm = #0xde
    35a4:      	add	sp, #0x8
    35a6:      	pop	{r7, pc}

000035a8 <_RNvMs4_NtCs6e6HQTixP8o_4core3fmtNtB5_9Arguments23as_statically_known_strCs2GpT71Ckjdn_10rtt_target>:
    35a8:      	push	{r7, lr}
    35aa:      	mov	r7, sp
    35ac:      	sub	sp, #0x38
    35ae:      	str	r0, [sp, #0xc]
    35b0:      	str	r0, [sp, #0x1c]
    35b2:      	ldr	r0, [r0, #0x4]
    35b4:      	str	r0, [sp, #0x10]
    35b6:      	str	r0, [sp, #0x20]
    35b8:      	lsls	r0, r0, #0x1f
    35ba:      	cbz	r0, 0x35d4 <_RNvMs4_NtCs6e6HQTixP8o_4core3fmtNtB5_9Arguments23as_statically_known_strCs2GpT71Ckjdn_10rtt_target+0x2c> @ imm = #0x16
    35bc:      	b	0x35be <_RNvMs4_NtCs6e6HQTixP8o_4core3fmtNtB5_9Arguments23as_statically_known_strCs2GpT71Ckjdn_10rtt_target+0x16> @ imm = #-0x2
    35be:      	ldr	r0, [sp, #0x10]
    35c0:      	ldr	r1, [sp, #0xc]
    35c2:      	ldr	r1, [r1]
    35c4:      	str	r1, [sp, #0x4]
    35c6:      	str	r1, [sp, #0x24]
    35c8:      	str	r1, [sp, #0x28]
    35ca:      	lsrs	r0, r0, #0x1
    35cc:      	mov	r1, r0
    35ce:      	str	r1, [sp, #0x8]
    35d0:      	str	r0, [sp, #0x2c]
    35d2:      	b	0x35e6 <_RNvMs4_NtCs6e6HQTixP8o_4core3fmtNtB5_9Arguments23as_statically_known_strCs2GpT71Ckjdn_10rtt_target+0x3e> @ imm = #0x10
    35d4:      	movw	r0, #0x6118
    35d8:      	movt	r0, #0x0
    35dc:      	ldr	r1, [r0]
    35de:      	ldr	r0, [r0, #0x4]
    35e0:      	str	r1, [sp, #0x14]
    35e2:      	str	r0, [sp, #0x18]
    35e4:      	b	0x360e <_RNvMs4_NtCs6e6HQTixP8o_4core3fmtNtB5_9Arguments23as_statically_known_strCs2GpT71Ckjdn_10rtt_target+0x66> @ imm = #0x26
    35e6:      	ldr	r3, [sp, #0x8]
    35e8:      	ldr	r0, [sp, #0x4]
    35ea:      	movw	r1, #0x6108
    35ee:      	movt	r1, #0x0
    35f2:      	mov	r2, sp
    35f4:      	str	r1, [r2]
    35f6:      	movs	r2, #0x1
    35f8:      	mov	r1, r2
    35fa:      	bl	0x3d20 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target> @ imm = #0x722
    35fe:      	b	0x3600 <_RNvMs4_NtCs6e6HQTixP8o_4core3fmtNtB5_9Arguments23as_statically_known_strCs2GpT71Ckjdn_10rtt_target+0x58> @ imm = #-0x2
    3600:      	ldr	r0, [sp, #0x8]
    3602:      	ldr	r1, [sp, #0x4]
    3604:      	str	r1, [sp, #0x30]
    3606:      	str	r0, [sp, #0x34]
    3608:      	str	r1, [sp, #0x14]
    360a:      	str	r0, [sp, #0x18]
    360c:      	b	0x360e <_RNvMs4_NtCs6e6HQTixP8o_4core3fmtNtB5_9Arguments23as_statically_known_strCs2GpT71Ckjdn_10rtt_target+0x66> @ imm = #-0x2
    360e:      	b	0x3610 <_RNvMs4_NtCs6e6HQTixP8o_4core3fmtNtB5_9Arguments23as_statically_known_strCs2GpT71Ckjdn_10rtt_target+0x68> @ imm = #-0x2
    3610:      	movw	r0, #0x6118
    3614:      	movt	r0, #0x0
    3618:      	ldr	r1, [r0]
    361a:      	ldr	r0, [r0, #0x4]
    361c:      	str	r1, [sp, #0x14]
    361e:      	str	r0, [sp, #0x18]
    3620:      	b	0x3622 <_RNvMs4_NtCs6e6HQTixP8o_4core3fmtNtB5_9Arguments23as_statically_known_strCs2GpT71Ckjdn_10rtt_target+0x7a> @ imm = #-0x2
    3622:      	ldr	r0, [sp, #0x14]
    3624:      	ldr	r1, [sp, #0x18]
    3626:      	add	sp, #0x38
    3628:      	pop	{r7, pc}

0000362a <_RNvMsW_NtNtCs6e6HQTixP8o_4core4sync6atomicINtB5_6AtomicjE4loadCs2GpT71Ckjdn_10rtt_target>:
    362a:      	push	{r7, lr}
    362c:      	mov	r7, sp
    362e:      	sub	sp, #0x8
    3630:      	str	r0, [sp]
    3632:      	strb	r1, [r7, #-1]
    3636:      	bl	0x2f0c <_RINvNtNtCs6e6HQTixP8o_4core4sync6atomic11atomic_loadjKb0_ECs2GpT71Ckjdn_10rtt_target> @ imm = #-0x72e
    363a:      	add	sp, #0x8
    363c:      	pop	{r7, pc}

0000363e <_RNvMsW_NtNtCs6e6HQTixP8o_4core4sync6atomicINtB5_6AtomicjE5storeCs2GpT71Ckjdn_10rtt_target>:
    363e:      	push	{r7, lr}
    3640:      	mov	r7, sp
    3642:      	sub	sp, #0x10
    3644:      	str	r0, [sp, #0x4]
    3646:      	str	r1, [sp, #0x8]
    3648:      	strb	r2, [r7, #-1]
    364c:      	bl	0x2f8c <_RINvNtNtCs6e6HQTixP8o_4core4sync6atomic12atomic_storejKb0_ECs2GpT71Ckjdn_10rtt_target> @ imm = #-0x6c4
    3650:      	add	sp, #0x10
    3652:      	pop	{r7, pc}

00003654 <_RNvMs_Cs2GpT71Ckjdn_10rtt_targetNtB4_9UpChannel3new>:
    3654:      	push	{r7, lr}
    3656:      	mov	r7, sp
    3658:      	sub	sp, #0x4
    365a:      	str	r0, [sp]
    365c:      	add	sp, #0x4
    365e:      	pop	{r7, pc}

00003660 <_RNvMs_Cs2GpT71Ckjdn_10rtt_targetNtB4_9UpChannel4mode>:
    3660:      	push	{r7, lr}
    3662:      	mov	r7, sp
    3664:      	sub	sp, #0x8
    3666:      	str	r0, [sp, #0x4]
    3668:      	bl	0x3674 <_RNvMs_Cs2GpT71Ckjdn_10rtt_targetNtB4_9UpChannel7channel> @ imm = #0x8
    366c:      	bl	0x37b6 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode> @ imm = #0x146
    3670:      	add	sp, #0x8
    3672:      	pop	{r7, pc}

00003674 <_RNvMs_Cs2GpT71Ckjdn_10rtt_targetNtB4_9UpChannel7channel>:
    3674:      	push	{r7, lr}
    3676:      	mov	r7, sp
    3678:      	sub	sp, #0x4
    367a:      	str	r0, [sp]
    367c:      	ldr	r0, [r0]
    367e:      	add	sp, #0x4
    3680:      	pop	{r7, pc}

00003682 <_RNvMs_Cs2GpT71Ckjdn_10rtt_targetNtB4_9UpChannel8set_mode>:
    3682:      	push	{r7, lr}
    3684:      	mov	r7, sp
    3686:      	sub	sp, #0x10
    3688:      	str	r1, [sp, #0x4]
    368a:      	str	r0, [sp, #0x8]
    368c:      	str	r1, [sp, #0xc]
    368e:      	bl	0x3674 <_RNvMs_Cs2GpT71Ckjdn_10rtt_targetNtB4_9UpChannel7channel> @ imm = #-0x1e
    3692:      	ldr	r1, [sp, #0x4]
    3694:      	bl	0x3830 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel8set_mode> @ imm = #0x198
    3698:      	add	sp, #0x10
    369a:      	pop	{r7, pc}

0000369c <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel13read_pointers>:
    369c:      	push	{r7, lr}
    369e:      	mov	r7, sp
    36a0:      	sub	sp, #0x30
    36a2:      	str	r0, [sp, #0x10]
    36a4:      	str	r0, [sp, #0x24]
    36a6:      	adds	r0, #0xc
    36a8:      	movw	r2, #0x6120
    36ac:      	movt	r2, #0x0
    36b0:      	movs	r1, #0x4
    36b2:      	str	r1, [sp, #0x8]
    36b4:      	bl	0x38e0 <_RNvMsi_CschsfQPGDbJ4_15portable_atomicNtB5_11AtomicUsize4loadCs2GpT71Ckjdn_10rtt_target> @ imm = #0x228
    36b8:      	ldr	r1, [sp, #0x8]
    36ba:      	mov	r2, r0
    36bc:      	ldr	r0, [sp, #0x10]
    36be:      	str	r2, [sp, #0x14]
    36c0:      	mov	r3, r2
    36c2:      	str	r3, [sp, #0xc]
    36c4:      	str	r2, [sp, #0x28]
    36c6:      	adds	r0, #0x10
    36c8:      	movw	r2, #0x6130
    36cc:      	movt	r2, #0x0
    36d0:      	bl	0x38e0 <_RNvMsi_CschsfQPGDbJ4_15portable_atomicNtB5_11AtomicUsize4loadCs2GpT71Ckjdn_10rtt_target> @ imm = #0x20c
    36d4:      	ldr	r1, [sp, #0x10]
    36d6:      	mov	r2, r0
    36d8:      	ldr	r0, [sp, #0x14]
    36da:      	mov	r3, r2
    36dc:      	str	r3, [sp, #0x18]
    36de:      	str	r2, [sp, #0x2c]
    36e0:      	ldr	r1, [r1, #0x8]
    36e2:      	cmp	r0, r1
    36e4:      	bhs	0x36f4 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel13read_pointers+0x58> @ imm = #0xc
    36e6:      	b	0x36e8 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel13read_pointers+0x4c> @ imm = #-0x2
    36e8:      	ldr	r0, [sp, #0x18]
    36ea:      	ldr	r1, [sp, #0x10]
    36ec:      	ldr	r1, [r1, #0x8]
    36ee:      	cmp	r0, r1
    36f0:      	blo	0x3728 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel13read_pointers+0x8c> @ imm = #0x34
    36f2:      	b	0x36f4 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel13read_pointers+0x58> @ imm = #-0x2
    36f4:      	ldr	r0, [sp, #0x10]
    36f6:      	adds	r0, #0xc
    36f8:      	movw	r3, #0x6140
    36fc:      	movt	r3, #0x0
    3700:      	movs	r1, #0x0
    3702:      	str	r1, [sp, #0x4]
    3704:      	movs	r2, #0x4
    3706:      	str	r2, [sp]
    3708:      	bl	0x38f4 <_RNvMsi_CschsfQPGDbJ4_15portable_atomicNtB5_11AtomicUsize5storeCs2GpT71Ckjdn_10rtt_target> @ imm = #0x1e8
    370c:      	ldr	r0, [sp, #0x10]
    370e:      	ldr	r2, [sp]
    3710:      	ldr	r1, [sp, #0x4]
    3712:      	adds	r0, #0x10
    3714:      	movw	r3, #0x6150
    3718:      	movt	r3, #0x0
    371c:      	bl	0x38f4 <_RNvMsi_CschsfQPGDbJ4_15portable_atomicNtB5_11AtomicUsize5storeCs2GpT71Ckjdn_10rtt_target> @ imm = #0x1d4
    3720:      	ldr	r0, [sp, #0x4]
    3722:      	str	r0, [sp, #0x20]
    3724:      	str	r0, [sp, #0x1c]
    3726:      	b	0x3732 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel13read_pointers+0x96> @ imm = #0x8
    3728:      	ldr	r0, [sp, #0x18]
    372a:      	ldr	r1, [sp, #0xc]
    372c:      	str	r1, [sp, #0x1c]
    372e:      	str	r0, [sp, #0x20]
    3730:      	b	0x3732 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel13read_pointers+0x96> @ imm = #-0x2
    3732:      	ldr	r0, [sp, #0x1c]
    3734:      	ldr	r1, [sp, #0x20]
    3736:      	add	sp, #0x30
    3738:      	pop	{r7, pc}

0000373a <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4init>:
    373a:      	push	{r7, lr}
    373c:      	mov	r7, sp
    373e:      	sub	sp, #0x40
    3740:      	str	r3, [sp, #0x14]
    3742:      	mov	r12, r2
    3744:      	str.w	r12, [sp, #0x8]
    3748:      	str	r1, [sp]
    374a:      	str	r0, [sp, #0x10]
    374c:      	ldr	r2, [r7, #0x8]
    374e:      	str	r2, [sp, #0x4]
    3750:      	str	r0, [sp, #0x18]
    3752:      	str	r1, [sp, #0x1c]
    3754:      	str.w	r12, [sp, #0x20]
    3758:      	str	r3, [sp, #0x24]
    375a:      	str	r2, [sp, #0x28]
    375c:      	str	r0, [sp, #0x34]
    375e:      	str	r1, [sp, #0x38]
    3760:      	movw	r2, #0x6160
    3764:      	movt	r2, #0x0
    3768:      	movs	r1, #0x4
    376a:      	str	r1, [sp, #0xc]
    376c:      	bl	0x3bac <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCs2GpT71Ckjdn_10rtt_target> @ imm = #0x43c
    3770:      	ldr	r2, [sp]
    3772:      	ldr	r1, [sp, #0xc]
    3774:      	ldr	r0, [sp, #0x10]
    3776:      	str	r2, [r0]
    3778:      	adds	r0, #0x8
    377a:      	str	r0, [sp, #0x3c]
    377c:      	movw	r2, #0x6170
    3780:      	movt	r2, #0x0
    3784:      	bl	0x3bac <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCs2GpT71Ckjdn_10rtt_target> @ imm = #0x424
    3788:      	ldr	r2, [sp, #0x4]
    378a:      	ldr	r1, [sp, #0x8]
    378c:      	ldr	r0, [sp, #0x10]
    378e:      	str	r2, [r0, #0x8]
    3790:      	bl	0x3830 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel8set_mode> @ imm = #0x9c
    3794:      	ldr	r1, [sp, #0xc]
    3796:      	ldr	r0, [sp, #0x10]
    3798:      	ldr	r3, [sp, #0x14]
    379a:      	adds	r0, #0x4
    379c:      	str	r0, [sp, #0x2c]
    379e:      	str	r3, [sp, #0x30]
    37a0:      	movw	r2, #0x6180
    37a4:      	movt	r2, #0x0
    37a8:      	bl	0x3bac <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCs2GpT71Ckjdn_10rtt_target> @ imm = #0x400
    37ac:      	ldr	r0, [sp, #0x10]
    37ae:      	ldr	r3, [sp, #0x14]
    37b0:      	str	r3, [r0, #0x4]
    37b2:      	add	sp, #0x40
    37b4:      	pop	{r7, pc}

000037b6 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode>:
    37b6:      	push	{r7, lr}
    37b8:      	mov	r7, sp
    37ba:      	sub	sp, #0x10
    37bc:      	str	r0, [sp, #0x8]
    37be:      	adds	r0, #0x14
    37c0:      	movw	r2, #0x6190
    37c4:      	movt	r2, #0x0
    37c8:      	movs	r1, #0x4
    37ca:      	bl	0x38e0 <_RNvMsi_CschsfQPGDbJ4_15portable_atomicNtB5_11AtomicUsize4loadCs2GpT71Ckjdn_10rtt_target> @ imm = #0x112
    37ce:      	and	r0, r0, #0x3
    37d2:      	str	r0, [sp, #0xc]
    37d4:      	mov	r1, r0
    37d6:      	str	r1, [sp]
    37d8:      	cbz	r0, 0x37f2 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode+0x3c> @ imm = #0x16
    37da:      	b	0x37dc <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode+0x26> @ imm = #-0x2
    37dc:      	ldr	r0, [sp]
    37de:      	cmp	r0, #0x1
    37e0:      	beq	0x37f8 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode+0x42> @ imm = #0x14
    37e2:      	b	0x37e4 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode+0x2e> @ imm = #-0x2
    37e4:      	ldr	r0, [sp]
    37e6:      	cmp	r0, #0x2
    37e8:      	beq	0x37fe <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode+0x48> @ imm = #0x12
    37ea:      	b	0x37ec <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode+0x36> @ imm = #-0x2
    37ec:      	movs	r0, #0x0
    37ee:      	str	r0, [sp, #0x4]
    37f0:      	b	0x3804 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode+0x4e> @ imm = #0x10
    37f2:      	movs	r0, #0x0
    37f4:      	str	r0, [sp, #0x4]
    37f6:      	b	0x3804 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode+0x4e> @ imm = #0xa
    37f8:      	movs	r0, #0x1
    37fa:      	str	r0, [sp, #0x4]
    37fc:      	b	0x3804 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode+0x4e> @ imm = #0x4
    37fe:      	movs	r0, #0x2
    3800:      	str	r0, [sp, #0x4]
    3802:      	b	0x3804 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel4mode+0x4e> @ imm = #-0x2
    3804:      	ldr	r0, [sp, #0x4]
    3806:      	add	sp, #0x10
    3808:      	pop	{r7, pc}

0000380a <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel6writer>:
    380a:      	push	{r7, lr}
    380c:      	mov	r7, sp
    380e:      	sub	sp, #0x10
    3810:      	str	r1, [sp, #0x4]
    3812:      	mov	r1, r0
    3814:      	ldr	r0, [sp, #0x4]
    3816:      	str	r1, [sp, #0x8]
    3818:      	str	r0, [sp, #0xc]
    381a:      	bl	0x369c <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel13read_pointers> @ imm = #-0x182
    381e:      	ldr	r2, [sp, #0x4]
    3820:      	ldr	r1, [sp, #0x8]
    3822:      	str	r2, [r1]
    3824:      	str	r0, [r1, #0x4]
    3826:      	movs	r0, #0x0
    3828:      	str	r0, [r1, #0x8]
    382a:      	strb	r0, [r1, #0xc]
    382c:      	add	sp, #0x10
    382e:      	pop	{r7, pc}

00003830 <_RNvMs_NtCs2GpT71Ckjdn_10rtt_target3rttNtB4_10RttChannel8set_mode>:
    3830:      	push	{r7, lr}
    3832:      	mov	r7, sp
    3834:      	sub	sp, #0x18
    3836:      	str	r1, [sp, #0x4]
    3838:      	str	r0, [sp, #0x10]
    383a:      	str	r1, [sp, #0x14]
    383c:      	adds	r0, #0x14
    383e:      	str	r0, [sp, #0xc]
    3840:      	movw	r2, #0x61a0
    3844:      	movt	r2, #0x0
    3848:      	movs	r1, #0x4
    384a:      	str	r1, [sp, #0x8]
    384c:      	bl	0x38e0 <_RNvMsi_CschsfQPGDbJ4_15portable_atomicNtB5_11AtomicUsize4loadCs2GpT71Ckjdn_10rtt_target> @ imm = #0x90
    3850:      	ldr	r3, [sp, #0x4]
    3852:      	ldr	r2, [sp, #0x8]
    3854:      	mov	r1, r0
    3856:      	ldr	r0, [sp, #0xc]
    3858:      	bic	r1, r1, #0x3
    385c:      	orrs	r1, r3
    385e:      	movw	r3, #0x61b0
    3862:      	movt	r3, #0x0
    3866:      	bl	0x38f4 <_RNvMsi_CschsfQPGDbJ4_15portable_atomicNtB5_11AtomicUsize5storeCs2GpT71Ckjdn_10rtt_target> @ imm = #0x8a
    386a:      	add	sp, #0x18
    386c:      	pop	{r7, pc}

0000386e <_RNvMs_NtCs6gRl320PnDN_16critical_section5mutexINtB4_5MutexINtNtCs6e6HQTixP8o_4core4cell7RefCellINtNtBZ_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEEE14borrow_ref_mutB1T_>:
    386e:      	push	{r7, lr}
    3870:      	mov	r7, sp
    3872:      	sub	sp, #0x10
    3874:      	str	r1, [sp, #0x4]
    3876:      	str	r0, [sp, #0x8]
    3878:      	bl	0x31a2 <_RNvMNtCs6gRl320PnDN_16critical_section5mutexINtB2_5MutexINtNtCs6e6HQTixP8o_4core4cell7RefCellINtNtBX_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEEE6borrowB1R_> @ imm = #-0x6da
    387c:      	ldr	r1, [sp, #0x4]
    387e:      	bl	0x390a <_RNvMst_NtCs6e6HQTixP8o_4core4cellINtB5_7RefCellINtNtB7_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEE10borrow_mutB17_> @ imm = #0x88
    3882:      	add	sp, #0x10
    3884:      	pop	{r7, pc}

00003886 <_RNvMsd_NtNtCschsfQPGDbJ4_15portable_atomic3imp11core_atomicNtB5_11AtomicUsize4loadCs2GpT71Ckjdn_10rtt_target>:
    3886:      	push	{r7, lr}
    3888:      	mov	r7, sp
    388a:      	sub	sp, #0x18
    388c:      	str	r2, [sp, #0x4]
    388e:      	mov	r2, r1
    3890:      	ldr	r1, [sp, #0x4]
    3892:      	str	r2, [sp, #0xc]
    3894:      	mov	r2, r0
    3896:      	ldr	r0, [sp, #0xc]
    3898:      	str	r2, [sp, #0x8]
    389a:      	str	r2, [sp, #0x10]
    389c:      	strb	r0, [r7, #-1]
    38a0:      	bl	0x3978 <_RNvNtCschsfQPGDbJ4_15portable_atomic5utils20assert_load_orderingCs2GpT71Ckjdn_10rtt_target> @ imm = #0xd4
    38a4:      	ldr	r0, [sp, #0x8]
    38a6:      	ldr	r1, [sp, #0xc]
    38a8:      	bl	0x362a <_RNvMsW_NtNtCs6e6HQTixP8o_4core4sync6atomicINtB5_6AtomicjE4loadCs2GpT71Ckjdn_10rtt_target> @ imm = #-0x282
    38ac:      	add	sp, #0x18
    38ae:      	pop	{r7, pc}

000038b0 <_RNvMsd_NtNtCschsfQPGDbJ4_15portable_atomic3imp11core_atomicNtB5_11AtomicUsize5storeCs2GpT71Ckjdn_10rtt_target>:
    38b0:      	push	{r7, lr}
    38b2:      	mov	r7, sp
    38b4:      	sub	sp, #0x20
    38b6:      	str	r3, [sp, #0x4]
    38b8:      	str	r2, [sp, #0x10]
    38ba:      	mov	r2, r1
    38bc:      	ldr	r1, [sp, #0x4]
    38be:      	str	r2, [sp, #0xc]
    38c0:      	mov	r3, r0
    38c2:      	ldr	r0, [sp, #0x10]
    38c4:      	str	r3, [sp, #0x8]
    38c6:      	str	r3, [sp, #0x14]
    38c8:      	str	r2, [sp, #0x18]
    38ca:      	strb	r0, [r7, #-1]
    38ce:      	bl	0x39bc <_RNvNtCschsfQPGDbJ4_15portable_atomic5utils21assert_store_orderingCs2GpT71Ckjdn_10rtt_target> @ imm = #0xea
    38d2:      	ldr	r0, [sp, #0x8]
    38d4:      	ldr	r1, [sp, #0xc]
    38d6:      	ldr	r2, [sp, #0x10]
    38d8:      	bl	0x363e <_RNvMsW_NtNtCs6e6HQTixP8o_4core4sync6atomicINtB5_6AtomicjE5storeCs2GpT71Ckjdn_10rtt_target> @ imm = #-0x29e
    38dc:      	add	sp, #0x20
    38de:      	pop	{r7, pc}

000038e0 <_RNvMsi_CschsfQPGDbJ4_15portable_atomicNtB5_11AtomicUsize4loadCs2GpT71Ckjdn_10rtt_target>:
    38e0:      	push	{r7, lr}
    38e2:      	mov	r7, sp
    38e4:      	sub	sp, #0x8
    38e6:      	str	r0, [sp]
    38e8:      	strb	r1, [r7, #-1]
    38ec:      	bl	0x3886 <_RNvMsd_NtNtCschsfQPGDbJ4_15portable_atomic3imp11core_atomicNtB5_11AtomicUsize4loadCs2GpT71Ckjdn_10rtt_target> @ imm = #-0x6a
    38f0:      	add	sp, #0x8
    38f2:      	pop	{r7, pc}

000038f4 <_RNvMsi_CschsfQPGDbJ4_15portable_atomicNtB5_11AtomicUsize5storeCs2GpT71Ckjdn_10rtt_target>:
    38f4:      	push	{r7, lr}
    38f6:      	mov	r7, sp
    38f8:      	sub	sp, #0x10
    38fa:      	str	r0, [sp, #0x4]
    38fc:      	str	r1, [sp, #0x8]
    38fe:      	strb	r2, [r7, #-1]
    3902:      	bl	0x38b0 <_RNvMsd_NtNtCschsfQPGDbJ4_15portable_atomic3imp11core_atomicNtB5_11AtomicUsize5storeCs2GpT71Ckjdn_10rtt_target> @ imm = #-0x56
    3906:      	add	sp, #0x10
    3908:      	pop	{r7, pc}

0000390a <_RNvMst_NtCs6e6HQTixP8o_4core4cellINtB5_7RefCellINtNtB7_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEE10borrow_mutB17_>:
    390a:      	push	{r7, lr}
    390c:      	mov	r7, sp
    390e:      	sub	sp, #0x38
    3910:      	str	r1, [sp, #0x4]
    3912:      	str	r0, [sp, #0x8]
    3914:      	str	r0, [sp, #0x14]
    3916:      	mov.w	r1, #0xffffffff
    391a:      	str	r1, [sp, #0x1c]
    391c:      	str	r0, [sp, #0x20]
    391e:      	ldr	r0, [r0]
    3920:      	cbnz	r0, 0x3938 <_RNvMst_NtCs6e6HQTixP8o_4core4cellINtB5_7RefCellINtNtB7_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEE10borrow_mutB17_+0x2e> @ imm = #0x14
    3922:      	b	0x3924 <_RNvMst_NtCs6e6HQTixP8o_4core4cellINtB5_7RefCellINtNtB7_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEE10borrow_mutB17_+0x1a> @ imm = #-0x2
    3924:      	ldr	r0, [sp, #0x8]
    3926:      	mov.w	r1, #0xffffffff
    392a:      	str	r1, [r0]
    392c:      	str	r0, [sp, #0x24]
    392e:      	adds	r0, #0x4
    3930:      	mov	r1, r0
    3932:      	str	r1, [sp]
    3934:      	str	r0, [sp, #0x28]
    3936:      	b	0x393e <_RNvMst_NtCs6e6HQTixP8o_4core4cellINtB5_7RefCellINtNtB7_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEE10borrow_mutB17_+0x34> @ imm = #0x4
    3938:      	ldr	r0, [sp, #0x4]
    393a:      	bl	0x4748 <_RNvNtCs6e6HQTixP8o_4core4cell22panic_already_borrowed> @ imm = #0xe0a
    393e:      	ldr	r0, [sp]
    3940:      	movw	r1, #0x61c0
    3944:      	movt	r1, #0x0
    3948:      	bl	0x3b80 <_RNvNvMs1_NtNtCs6e6HQTixP8o_4core3ptr8non_nullINtB7_7NonNullpE13new_unchecked18precondition_checkCs2GpT71Ckjdn_10rtt_target> @ imm = #0x234
    394c:      	b	0x394e <_RNvMst_NtCs6e6HQTixP8o_4core4cellINtB5_7RefCellINtNtB7_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEE10borrow_mutB17_+0x44> @ imm = #-0x2
    394e:      	ldr	r0, [sp, #0x8]
    3950:      	ldr	r1, [sp]
    3952:      	str	r1, [sp, #0x2c]
    3954:      	str	r1, [sp, #0xc]
    3956:      	str	r0, [sp, #0x10]
    3958:      	ldr	r0, [sp, #0xc]
    395a:      	ldr	r1, [sp, #0x10]
    395c:      	str	r0, [sp, #0x30]
    395e:      	str	r1, [sp, #0x34]
    3960:      	add	sp, #0x38
    3962:      	pop	{r7, pc}

00003964 <_RNvNtCs2GpT71Ckjdn_10rtt_target5print17set_print_channel>:
    3964:      	push	{r7, lr}
    3966:      	mov	r7, sp
    3968:      	sub	sp, #0x8
    396a:      	str	r0, [sp, #0x4]
    396c:      	add	r0, sp, #0x4
    396e:      	bl	0x2e74 <_RINvCs6gRl320PnDN_16critical_section4withuNCNvNtCs2GpT71Ckjdn_10rtt_target5print17set_print_channel0EBK_> @ imm = #-0xafe
    3972:      	add	sp, #0x8
    3974:      	pop	{r7, pc}
    3976:      	bmi	0x3922 <_RNvMst_NtCs6e6HQTixP8o_4core4cellINtB5_7RefCellINtNtB7_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEE10borrow_mutB17_+0x18> @ imm = #-0x58

00003978 <_RNvNtCschsfQPGDbJ4_15portable_atomic5utils20assert_load_orderingCs2GpT71Ckjdn_10rtt_target>:
    3978:      	push	{r7, lr}
    397a:      	mov	r7, sp
    397c:      	sub	sp, #0x10
    397e:      	str	r1, [sp, #0x4]
    3980:      	strb	r0, [r7, #-1]
    3984:      	uxtb	r0, r0
    3986:      	str	r0, [sp, #0x8]
    3988:      	ldr	r1, [sp, #0x8]
    398a:      	tbb	[pc, r1]
    398e: 04 06 04 0e  	.word	0x0e040604
    3992: 04 00	.short	0x0004
    3994:      	trap
    3996:      	add	sp, #0x10
    3998:      	pop	{r7, pc}
    399a:      	ldr	r2, [sp, #0x4]
    399c:      	movw	r0, #0x5ea8
    39a0:      	movt	r0, #0x0
    39a4:      	movs	r1, #0x28
    39a6:      	bl	0x4834 <_RNvNtCs6e6HQTixP8o_4core9panicking5panic> @ imm = #0xe8a
    39aa:      	ldr	r2, [sp, #0x4]
    39ac:      	movw	r0, #0x5ee0
    39b0:      	movt	r0, #0x0
    39b4:      	movs	r1, #0x31
    39b6:      	bl	0x4834 <_RNvNtCs6e6HQTixP8o_4core9panicking5panic> @ imm = #0xe7a
    39ba:      	bmi	0x3966 <_RNvNtCs2GpT71Ckjdn_10rtt_target5print17set_print_channel+0x2> @ imm = #-0x58

000039bc <_RNvNtCschsfQPGDbJ4_15portable_atomic5utils21assert_store_orderingCs2GpT71Ckjdn_10rtt_target>:
    39bc:      	push	{r7, lr}
    39be:      	mov	r7, sp
    39c0:      	sub	sp, #0x10
    39c2:      	str	r1, [sp, #0x4]
    39c4:      	strb	r0, [r7, #-1]
;     match order {
    39c8:      	uxtb	r0, r0
    39ca:      	str	r0, [sp, #0x8]
    39cc:      	ldr	r1, [sp, #0x8]
    39ce:      	tbb	[pc, r1]
    39d2: 04 04 06 0e  	.word	0x0e060404
    39d6: 04 00	.short	0x0004
; pub(crate) fn assert_store_ordering(order: Ordering) {
    39d8:      	trap
; }
    39da:      	add	sp, #0x10
    39dc:      	pop	{r7, pc}
;         Ordering::Acquire => panic!("there is no such thing as an acquire store"),
    39de:      	ldr	r2, [sp, #0x4]
    39e0:      	movw	r0, #0x5f24
    39e4:      	movt	r0, #0x0
    39e8:      	movs	r1, #0x2a
    39ea:      	bl	0x4834 <_RNvNtCs6e6HQTixP8o_4core9panicking5panic> @ imm = #0xe46
;         Ordering::AcqRel => panic!("there is no such thing as an acquire-release store"),
    39ee:      	ldr	r2, [sp, #0x4]
    39f0:      	movw	r0, #0x5f60
    39f4:      	movt	r0, #0x0
    39f8:      	movs	r1, #0x32
    39fa:      	bl	0x4834 <_RNvNtCs6e6HQTixP8o_4core9panicking5panic> @ imm = #0xe36

000039fe <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target>:
; pub const fn encode_utf8_raw(code: u32, dst: &mut [u8]) -> &mut [u8] {
    39fe:      	push	{r7, lr}
    3a00:      	mov	r7, sp
    3a02:      	sub	sp, #0x28
    3a04:      	str	r2, [sp, #0x4]
    3a06:      	str	r1, [sp, #0x8]
    3a08:      	str	r0, [sp, #0xc]
    3a0a:      	str	r0, [sp, #0x14]
    3a0c:      	str	r1, [sp, #0x18]
    3a0e:      	str	r2, [sp, #0x1c]
;         ..MAX_ONE_B => 1,
    3a10:      	cmp	r0, #0x80
    3a12:      	blo	0x3a20 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x22> @ imm = #0xa
    3a14:      	b	0x3a16 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x18> @ imm = #-0x2
;         ..MAX_TWO_B => 2,
    3a16:      	ldr	r0, [sp, #0xc]
    3a18:      	cmp.w	r0, #0x800
    3a1c:      	blo	0x3a30 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x32> @ imm = #0x10
    3a1e:      	b	0x3a26 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x28> @ imm = #0x4
;         ..MAX_ONE_B => 1,
    3a20:      	movs	r0, #0x1
    3a22:      	str	r0, [sp, #0x10]
    3a24:      	b	0x3a42 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x44> @ imm = #0x1a
;         ..MAX_THREE_B => 3,
    3a26:      	ldr	r0, [sp, #0xc]
    3a28:      	cmp.w	r0, #0x10000
    3a2c:      	blo	0x3a3c <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x3e> @ imm = #0xc
    3a2e:      	b	0x3a36 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x38> @ imm = #0x4
;         ..MAX_TWO_B => 2,
    3a30:      	movs	r0, #0x2
    3a32:      	str	r0, [sp, #0x10]
    3a34:      	b	0x3a42 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x44> @ imm = #0xa
;         _ => 4,
    3a36:      	movs	r0, #0x4
    3a38:      	str	r0, [sp, #0x10]
    3a3a:      	b	0x3a42 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x44> @ imm = #0x4
;         ..MAX_THREE_B => 3,
    3a3c:      	movs	r0, #0x3
    3a3e:      	str	r0, [sp, #0x10]
    3a40:      	b	0x3a42 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x44> @ imm = #-0x2
;     if dst.len() < len {
    3a42:      	ldr	r0, [sp, #0x4]
    3a44:      	str	r0, [sp, #0x20]
    3a46:      	ldr	r1, [sp, #0x10]
    3a48:      	cmp	r0, r1
    3a4a:      	blo	0x3a5c <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x5e> @ imm = #0xe
    3a4c:      	b	0x3a4e <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x50> @ imm = #-0x2
;     unsafe { encode_utf8_raw_unchecked(code, dst.as_mut_ptr()) };
    3a4e:      	ldr	r1, [sp, #0x8]
    3a50:      	ldr	r0, [sp, #0xc]
    3a52:      	bl	0x3a90 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target> @ imm = #0x3a
    3a56:      	ldr	r0, [sp, #0x8]
;         self as *mut [T] as *mut T
    3a58:      	str	r0, [sp, #0x24]
;             if ::core::ub_checks::$kind() {
    3a5a:      	b	0x3a6e <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x70> @ imm = #0x10
;         const_eval_select(($($val,)*), compiletime, runtime)
    3a5c:      	ldr	r2, [sp, #0x4]
    3a5e:      	ldr	r0, [sp, #0xc]
    3a60:      	ldr	r1, [sp, #0x10]
    3a62:      	movw	r3, #0x61e0
    3a66:      	movt	r3, #0x0
    3a6a:      	bl	0x3e28 <_RNvNvNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_raw8do_panic7runtimeCs2GpT71Ckjdn_10rtt_target> @ imm = #0x3ba
;                 precondition_check($($arg,)*);
    3a6e:      	ldr	r0, [sp, #0x8]
    3a70:      	ldr	r3, [sp, #0x10]
    3a72:      	movw	r1, #0x61d0
    3a76:      	movt	r1, #0x0
    3a7a:      	mov	r2, sp
    3a7c:      	str	r1, [r2]
    3a7e:      	movs	r2, #0x1
    3a80:      	mov	r1, r2
    3a82:      	bl	0x3da4 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target> @ imm = #0x31e
;             if ::core::ub_checks::$kind() {
    3a86:      	b	0x3a88 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target+0x8a> @ imm = #-0x2
;     aggregate_raw_ptr(data_pointer, metadata)
    3a88:      	ldr	r0, [sp, #0x8]
    3a8a:      	ldr	r1, [sp, #0x10]
; }
    3a8c:      	add	sp, #0x28
    3a8e:      	pop	{r7, pc}

00003a90 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target>:
; pub const unsafe fn encode_utf8_raw_unchecked(code: u32, dst: *mut u8) {
    3a90:      	push	{r7, lr}
    3a92:      	mov	r7, sp
    3a94:      	sub	sp, #0x40
    3a96:      	str	r1, [sp, #0x10]
    3a98:      	str	r0, [sp, #0x14]
    3a9a:      	str	r0, [sp, #0x1c]
    3a9c:      	str	r1, [sp, #0x20]
;     pub const unsafe fn add(self, count: usize) -> Self
    3a9e:      	movs	r1, #0x1
    3aa0:      	str	r1, [sp, #0x24]
    3aa2:      	str	r1, [sp, #0x28]
    3aa4:      	str	r1, [sp, #0x2c]
    3aa6:      	movs	r1, #0x2
    3aa8:      	str	r1, [sp, #0x30]
    3aaa:      	str	r1, [sp, #0x34]
    3aac:      	movs	r1, #0x3
    3aae:      	str	r1, [sp, #0x38]
;         ..MAX_ONE_B => 1,
    3ab0:      	cmp	r0, #0x80
    3ab2:      	blo	0x3ac0 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0x30> @ imm = #0xa
    3ab4:      	b	0x3ab6 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0x26> @ imm = #-0x2
;         ..MAX_TWO_B => 2,
    3ab6:      	ldr	r0, [sp, #0x14]
    3ab8:      	cmp.w	r0, #0x800
    3abc:      	blo	0x3ad6 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0x46> @ imm = #0x16
    3abe:      	b	0x3acc <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0x3c> @ imm = #0xa
;         ..MAX_ONE_B => 1,
    3ac0:      	ldr	r0, [sp, #0x14]
    3ac2:      	ldr	r1, [sp, #0x10]
    3ac4:      	movs	r2, #0x1
    3ac6:      	str	r2, [sp, #0x18]
;             *dst = code as u8;
    3ac8:      	strb	r0, [r1]
    3aca:      	b	0x3b7a <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0xea> @ imm = #0xac
;         ..MAX_THREE_B => 3,
    3acc:      	ldr	r0, [sp, #0x14]
    3ace:      	cmp.w	r0, #0x10000
    3ad2:      	blo	0x3ae2 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0x52> @ imm = #0xc
    3ad4:      	b	0x3adc <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0x4c> @ imm = #0x4
;         ..MAX_TWO_B => 2,
    3ad6:      	movs	r0, #0x2
    3ad8:      	str	r0, [sp, #0x18]
    3ada:      	b	0x3ae8 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0x58> @ imm = #0xa
;         _ => 4,
    3adc:      	movs	r0, #0x4
    3ade:      	str	r0, [sp, #0x18]
    3ae0:      	b	0x3ae8 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0x58> @ imm = #0x4
;         ..MAX_THREE_B => 3,
    3ae2:      	movs	r0, #0x3
    3ae4:      	str	r0, [sp, #0x18]
    3ae6:      	b	0x3ae8 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0x58> @ imm = #-0x2
    3ae8:      	ldr	r1, [sp, #0x14]
    3aea:      	movw	r2, #0xfffe
    3aee:      	movt	r2, #0x3ff
;         let last1 = (code >> 0 & 0x3F) as u8 | TAG_CONT;
    3af2:      	mov	r0, r1
    3af4:      	bfi	r0, r2, #6, #26
    3af8:      	mov	r3, r0
    3afa:      	str	r3, [sp]
    3afc:      	strb.w	r0, [sp, #0x3c]
;         let last2 = (code >> 6 & 0x3F) as u8 | TAG_CONT;
    3b00:      	lsrs	r0, r1, #0x6
    3b02:      	bfi	r0, r2, #6, #26
    3b06:      	mov	r3, r0
    3b08:      	str	r3, [sp, #0x4]
    3b0a:      	strb	r0, [r7, #-3]
;         let last3 = (code >> 12 & 0x3F) as u8 | TAG_CONT;
    3b0e:      	lsrs	r0, r1, #0xc
    3b10:      	bfi	r0, r2, #6, #26
    3b14:      	mov	r2, r0
    3b16:      	str	r2, [sp, #0x8]
    3b18:      	strb	r0, [r7, #-2]
;         let last4 = (code >> 18 & 0x3F) as u8 | TAG_FOUR_B;
    3b1c:      	mvn	r0, #0xf
    3b20:      	orr.w	r0, r0, r1, lsr #18
    3b24:      	mov	r1, r0
    3b26:      	str	r1, [sp, #0xc]
    3b28:      	strb	r0, [r7, #-1]
;         if len == 2 {
    3b2c:      	ldr	r0, [sp, #0x18]
    3b2e:      	cmp	r0, #0x2
    3b30:      	bne	0x3b44 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0xb4> @ imm = #0x10
    3b32:      	b	0x3b34 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0xa4> @ imm = #-0x2
;             *dst = last2 | TAG_TWO_B;
    3b34:      	ldr	r0, [sp]
    3b36:      	ldr	r1, [sp, #0x10]
    3b38:      	ldr	r2, [sp, #0x4]
    3b3a:      	orr	r2, r2, #0xc0
    3b3e:      	strb	r2, [r1]
;             *dst.add(1) = last1;
    3b40:      	strb	r0, [r1, #0x1]
    3b42:      	b	0x3b4c <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0xbc> @ imm = #0x6
;         if len == 3 {
    3b44:      	ldr	r0, [sp, #0x18]
    3b46:      	cmp	r0, #0x3
    3b48:      	beq	0x3b4e <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0xbe> @ imm = #0x2
    3b4a:      	b	0x3b62 <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0xd2> @ imm = #0x14
    3b4c:      	b	0x3b7a <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0xea> @ imm = #0x2a
;             *dst = last3 | TAG_THREE_B;
    3b4e:      	ldr	r0, [sp]
    3b50:      	ldr	r1, [sp, #0x10]
    3b52:      	ldr	r2, [sp, #0x4]
    3b54:      	ldr	r3, [sp, #0x8]
    3b56:      	orr	r3, r3, #0xe0
    3b5a:      	strb	r3, [r1]
;             *dst.add(1) = last2;
    3b5c:      	strb	r2, [r1, #0x1]
;             *dst.add(2) = last1;
    3b5e:      	strb	r0, [r1, #0x2]
    3b60:      	b	0x3b4c <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0xbc> @ imm = #-0x18
;         *dst = last4;
    3b62:      	ldr	r0, [sp]
    3b64:      	ldr	r1, [sp, #0x10]
    3b66:      	ldr	r2, [sp, #0x4]
    3b68:      	ldr	r3, [sp, #0x8]
    3b6a:      	ldr.w	r12, [sp, #0xc]
    3b6e:      	strb.w	r12, [r1]
;         *dst.add(1) = last3;
    3b72:      	strb	r3, [r1, #0x1]
;         *dst.add(2) = last2;
    3b74:      	strb	r2, [r1, #0x2]
;         *dst.add(3) = last1;
    3b76:      	strb	r0, [r1, #0x3]
; }
    3b78:      	b	0x3b7c <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0xec> @ imm = #0x0
    3b7a:      	b	0x3b7c <_RNvNtNtCs6e6HQTixP8o_4core4char7methods25encode_utf8_raw_uncheckedCs2GpT71Ckjdn_10rtt_target+0xec> @ imm = #-0x2
    3b7c:      	add	sp, #0x40
    3b7e:      	pop	{r7, pc}

00003b80 <_RNvNvMs1_NtNtCs6e6HQTixP8o_4core3ptr8non_nullINtB7_7NonNullpE13new_unchecked18precondition_checkCs2GpT71Ckjdn_10rtt_target>:
;             const fn precondition_check($($name:$ty),*) {
    3b80:      	push	{r7, lr}
    3b82:      	mov	r7, sp
    3b84:      	sub	sp, #0x10
    3b86:      	str	r1, [sp]
    3b88:      	str	r0, [sp, #0x4]
;                 (ptr: *mut () = ptr as *mut ()) => !ptr.is_null()
    3b8a:      	cbz	r0, 0x3b92 <_RNvNvMs1_NtNtCs6e6HQTixP8o_4core3ptr8non_nullINtB7_7NonNullpE13new_unchecked18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x12> @ imm = #0x4
    3b8c:      	b	0x3b8e <_RNvNvMs1_NtNtCs6e6HQTixP8o_4core3ptr8non_nullINtB7_7NonNullpE13new_unchecked18precondition_checkCs2GpT71Ckjdn_10rtt_target+0xe> @ imm = #-0x2
;             }
    3b8e:      	add	sp, #0x10
    3b90:      	pop	{r7, pc}
;                     let msg = concat!("unsafe precondition(s) violated: ", $message,
    3b92:      	ldr	r3, [sp]
    3b94:      	movw	r0, #0x61f0
    3b98:      	movt	r0, #0x0
    3b9c:      	str	r0, [sp, #0x8]
    3b9e:      	movs	r1, #0xd2
    3ba0:      	str	r1, [sp, #0xc]
;                     ::core::panicking::panic_nounwind_fmt(::core::fmt::Arguments::from_str(msg), false);
    3ba2:      	movw	r1, #0x1a5
    3ba6:      	movs	r2, #0x0
    3ba8:      	bl	0x47c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt> @ imm = #0xc14

00003bac <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCs2GpT71Ckjdn_10rtt_target>:
;             const fn precondition_check($($name:$ty),*) {
    3bac:      	push	{r7, lr}
    3bae:      	mov	r7, sp
    3bb0:      	sub	sp, #0x18
    3bb2:      	str	r2, [sp]
    3bb4:      	str	r0, [sp, #0x4]
    3bb6:      	str	r1, [sp, #0x8]
;             ) => ub_checks::maybe_is_aligned(addr, align)
    3bb8:      	str	r0, [sp, #0xc]
;             ptr.is_aligned_to(align)
    3bba:      	bl	0x31b0 <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs2GpT71Ckjdn_10rtt_target> @ imm = #-0xa0e
;             ) => ub_checks::maybe_is_aligned(addr, align)
    3bbe:      	cbnz	r0, 0x3bdc <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x30> @ imm = #0x1a
    3bc0:      	b	0x3bc2 <_RNvNvNtCs6e6HQTixP8o_4core3ptr14write_volatile18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x16> @ imm = #-0x2
;                     let msg = concat!("unsafe precondition(s) violated: ", $message,
    3bc2:      	ldr	r3, [sp]
    3bc4:      	movw	r0, #0x62c2
    3bc8:      	movt	r0, #0x0
    3bcc:      	str	r0, [sp, #0x10]
    3bce:      	movs	r1, #0xd7
    3bd0:      	str	r1, [sp, #0x14]
;                     ::core::panicking::panic_nounwind_fmt(::core::fmt::Arguments::from_str(msg), false);
    3bd2:      	movw	r1, #0x1af
    3bd6:      	movs	r2, #0x0
    3bd8:      	bl	0x47c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt> @ imm = #0xbe4
;             }
    3bdc:      	add	sp, #0x18
    3bde:      	pop	{r7, pc}

00003be0 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target>:
;             const fn precondition_check($($name:$ty),*) {
    3be0:      	push	{r7, lr}
    3be2:      	mov	r7, sp
    3be4:      	sub	sp, #0x40
    3be6:      	str	r3, [sp, #0x4]
    3be8:      	str	r2, [sp, #0x8]
    3bea:      	str	r1, [sp, #0xc]
    3bec:      	mov	r12, r0
    3bee:      	str.w	r12, [sp, #0x10]
    3bf2:      	ldr	r0, [r7, #0xc]
    3bf4:      	str	r0, [sp, #0x14]
    3bf6:      	ldr	r0, [r7, #0x8]
    3bf8:      	str	r0, [sp, #0x18]
    3bfa:      	str.w	r12, [sp, #0x20]
    3bfe:      	str	r1, [sp, #0x24]
    3c00:      	str	r2, [sp, #0x28]
    3c02:      	str	r3, [sp, #0x2c]
;             let zero_size = count == 0 || size == 0;
    3c04:      	cbnz	r0, 0x3c10 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x30> @ imm = #0x8
    3c06:      	b	0x3c08 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x28> @ imm = #-0x2
    3c08:      	movs	r0, #0x1
    3c0a:      	strb	r0, [r7, #-33]
    3c0e:      	b	0x3c1e <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x3e> @ imm = #0xc
    3c10:      	ldr	r0, [sp, #0x8]
    3c12:      	clz	r0, r0
    3c16:      	lsrs	r0, r0, #0x5
    3c18:      	strb	r0, [r7, #-33]
    3c1c:      	b	0x3c1e <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x3e> @ imm = #-0x2
;             ub_checks::maybe_is_aligned_and_not_null(src, align, zero_size)
    3c1e:      	ldr	r1, [sp, #0x4]
    3c20:      	ldr	r0, [sp, #0x10]
    3c22:      	ldrb	r2, [r7, #-33]
    3c26:      	mov	r3, r2
    3c28:      	str	r3, [sp]
    3c2a:      	strb	r2, [r7, #-13]
;             ptr.is_aligned_to(align)
    3c2e:      	bl	0x31b0 <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs2GpT71Ckjdn_10rtt_target> @ imm = #-0xa82
;     maybe_is_aligned(ptr, align) && (is_zst || !ptr.is_null())
    3c32:      	cbnz	r0, 0x3c38 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x58> @ imm = #0x2
    3c34:      	b	0x3c36 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x56> @ imm = #-0x2
;             ub_checks::maybe_is_aligned_and_not_null(src, align, zero_size)
    3c36:      	b	0x3c40 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x60> @ imm = #0x6
;     maybe_is_aligned(ptr, align) && (is_zst || !ptr.is_null())
    3c38:      	ldr	r0, [sp]
    3c3a:      	lsls	r0, r0, #0x1f
    3c3c:      	cbnz	r0, 0x3c48 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x68> @ imm = #0x8
    3c3e:      	b	0x3c42 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x62> @ imm = #0x0
    3c40:      	b	0x3c58 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x78> @ imm = #0x14
;             ub_checks::maybe_is_aligned_and_not_null(src, align, zero_size)
    3c42:      	ldr	r0, [sp, #0x10]
    3c44:      	cbnz	r0, 0x3c4a <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x6a> @ imm = #0x2
    3c46:      	b	0x3c40 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x60> @ imm = #-0xa
    3c48:      	b	0x3c4a <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x6a> @ imm = #-0x2
;                 && ub_checks::maybe_is_aligned_and_not_null(dst, align, zero_size)
    3c4a:      	ldr	r1, [sp, #0x4]
    3c4c:      	ldr	r0, [sp, #0xc]
    3c4e:      	str	r0, [sp, #0x34]
;             ptr.is_aligned_to(align)
    3c50:      	bl	0x31b0 <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs2GpT71Ckjdn_10rtt_target> @ imm = #-0xaa4
;     maybe_is_aligned(ptr, align) && (is_zst || !ptr.is_null())
    3c54:      	cbnz	r0, 0x3c5c <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x7c> @ imm = #0x4
    3c56:      	b	0x3c5a <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x7a> @ imm = #0x0
;         ) => {
    3c58:      	b	0x3c80 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0xa0> @ imm = #0x24
;                 && ub_checks::maybe_is_aligned_and_not_null(dst, align, zero_size)
    3c5a:      	b	0x3c66 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x86> @ imm = #0x8
;     maybe_is_aligned(ptr, align) && (is_zst || !ptr.is_null())
    3c5c:      	ldrb	r0, [r7, #-33]
    3c60:      	lsls	r0, r0, #0x1f
    3c62:      	cbnz	r0, 0x3c6e <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x8e> @ imm = #0x8
    3c64:      	b	0x3c68 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x88> @ imm = #0x0
    3c66:      	b	0x3c58 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x78> @ imm = #-0x12
;                 && ub_checks::maybe_is_aligned_and_not_null(dst, align, zero_size)
    3c68:      	ldr	r0, [sp, #0xc]
    3c6a:      	cbnz	r0, 0x3c70 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x90> @ imm = #0x2
    3c6c:      	b	0x3c66 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x86> @ imm = #-0xa
    3c6e:      	b	0x3c70 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x90> @ imm = #-0x2
;         const_eval_select(($($val,)*), compiletime, runtime)
    3c70:      	ldr	r3, [sp, #0x18]
    3c72:      	ldr	r2, [sp, #0x8]
    3c74:      	ldr	r1, [sp, #0xc]
    3c76:      	ldr	r0, [sp, #0x10]
    3c78:      	bl	0x3ca0 <_RNvNvNtCs6e6HQTixP8o_4core9ub_checks23maybe_is_nonoverlapping7runtimeCs2GpT71Ckjdn_10rtt_target> @ imm = #0x24
;         ) => {
    3c7c:      	cbnz	r0, 0x3c9c <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0xbc> @ imm = #0x1c
    3c7e:      	b	0x3c80 <_RNvNvNtCs6e6HQTixP8o_4core3ptr19copy_nonoverlapping18precondition_checkCs2GpT71Ckjdn_10rtt_target+0xa0> @ imm = #-0x2
;                     let msg = concat!("unsafe precondition(s) violated: ", $message,
    3c80:      	ldr	r3, [sp, #0x14]
    3c82:      	movw	r0, #0x6399
    3c86:      	movt	r0, #0x0
    3c8a:      	str	r0, [sp, #0x38]
    3c8c:      	movw	r1, #0x11b
    3c90:      	str	r1, [sp, #0x3c]
;                     ::core::panicking::panic_nounwind_fmt(::core::fmt::Arguments::from_str(msg), false);
    3c92:      	movw	r1, #0x237
    3c96:      	movs	r2, #0x0
    3c98:      	bl	0x47c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt> @ imm = #0xb24
;             }
    3c9c:      	add	sp, #0x40
    3c9e:      	pop	{r7, pc}

00003ca0 <_RNvNvNtCs6e6HQTixP8o_4core9ub_checks23maybe_is_nonoverlapping7runtimeCs2GpT71Ckjdn_10rtt_target>:
;         fn runtime$(<$($binders)*>)?($($arg: $ty),*) $( -> $ret )? {
    3ca0:      	push	{r7, lr}
    3ca2:      	mov	r7, sp
    3ca4:      	sub	sp, #0x40
    3ca6:      	str	r0, [sp, #0x1c]
    3ca8:      	str	r1, [sp, #0x20]
    3caa:      	str	r2, [sp, #0x24]
    3cac:      	str	r3, [sp, #0x28]
;         unsafe { mem::transmute(self.cast::<()>()) }
    3cae:      	mov	r12, r0
    3cb0:      	str.w	r12, [sp, #0x4]
    3cb4:      	str	r0, [sp, #0x2c]
    3cb6:      	mov	r0, r1
    3cb8:      	str	r0, [sp, #0x8]
    3cba:      	str	r1, [sp, #0x30]
;             let (a, b) = intrinsics::mul_with_overflow(self as $ActualT, rhs as $ActualT);
    3cbc:      	umull	r0, r1, r2, r3
    3cc0:      	cmp	r1, #0x0
    3cc2:      	it	ne
    3cc4:      	movne	r1, #0x1
    3cc6:      	mov	r2, r0
    3cc8:      	str	r2, [sp, #0xc]
    3cca:      	strb	r1, [r7, #-9]
;             (a as Self, b)
    3cce:      	str	r0, [sp, #0x38]
;     if b {
    3cd0:      	bne	0x3cec <_RNvNvNtCs6e6HQTixP8o_4core9ub_checks23maybe_is_nonoverlapping7runtimeCs2GpT71Ckjdn_10rtt_target+0x4c> @ imm = #0x18
    3cd2:      	b	0x3cd4 <_RNvNvNtCs6e6HQTixP8o_4core9ub_checks23maybe_is_nonoverlapping7runtimeCs2GpT71Ckjdn_10rtt_target+0x34> @ imm = #-0x2
;             if intrinsics::unlikely(b) { None } else { Some(a) }
    3cd4:      	ldr	r0, [sp, #0x4]
    3cd6:      	ldr	r1, [sp, #0x8]
    3cd8:      	ldr	r2, [sp, #0xc]
    3cda:      	str	r2, [sp, #0x14]
    3cdc:      	movs	r2, #0x1
    3cde:      	str	r2, [sp, #0x10]
;             let Some(size) = size.checked_mul(count) else {
    3ce0:      	ldr	r2, [sp, #0x14]
    3ce2:      	str	r2, [sp]
    3ce4:      	str	r2, [sp, #0x3c]
;                 if self < other {
    3ce6:      	cmp	r0, r1
    3ce8:      	blo	0x3d04 <_RNvNvNtCs6e6HQTixP8o_4core9ub_checks23maybe_is_nonoverlapping7runtimeCs2GpT71Ckjdn_10rtt_target+0x64> @ imm = #0x18
    3cea:      	b	0x3cfa <_RNvNvNtCs6e6HQTixP8o_4core9ub_checks23maybe_is_nonoverlapping7runtimeCs2GpT71Ckjdn_10rtt_target+0x5a> @ imm = #0xc
;                 crate::panicking::panic_nounwind(
    3cec:      	movw	r0, #0x64b4
    3cf0:      	movt	r0, #0x0
    3cf4:      	movs	r1, #0x3d
    3cf6:      	bl	0x4780 <_RNvNtCs6e6HQTixP8o_4core9panicking14panic_nounwind> @ imm = #0xa86
;                     self - other
    3cfa:      	ldr	r0, [sp, #0x4]
    3cfc:      	ldr	r1, [sp, #0x8]
    3cfe:      	subs	r0, r0, r1
    3d00:      	str	r0, [sp, #0x18]
;                 if self < other {
    3d02:      	b	0x3d0e <_RNvNvNtCs6e6HQTixP8o_4core9ub_checks23maybe_is_nonoverlapping7runtimeCs2GpT71Ckjdn_10rtt_target+0x6e> @ imm = #0x8
;                     other - self
    3d04:      	ldr	r0, [sp, #0x8]
    3d06:      	ldr	r1, [sp, #0x4]
    3d08:      	subs	r0, r0, r1
    3d0a:      	str	r0, [sp, #0x18]
;                 if self < other {
    3d0c:      	b	0x3d0e <_RNvNvNtCs6e6HQTixP8o_4core9ub_checks23maybe_is_nonoverlapping7runtimeCs2GpT71Ckjdn_10rtt_target+0x6e> @ imm = #-0x2
;             diff >= size
    3d0e:      	ldr	r1, [sp]
    3d10:      	ldr	r0, [sp, #0x18]
    3d12:      	cmp	r0, r1
    3d14:      	mov.w	r0, #0x0
    3d18:      	it	hs
    3d1a:      	movhs	r0, #0x1
;         }
    3d1c:      	add	sp, #0x40
    3d1e:      	pop	{r7, pc}

00003d20 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target>:
;             const fn precondition_check($($name:$ty),*) {
    3d20:      	push	{r7, lr}
    3d22:      	mov	r7, sp
    3d24:      	sub	sp, #0x38
    3d26:      	str	r3, [sp]
    3d28:      	str	r2, [sp, #0x4]
    3d2a:      	mov	r2, r1
    3d2c:      	ldr	r1, [sp, #0x4]
    3d2e:      	str	r2, [sp, #0x8]
    3d30:      	str	r0, [sp, #0xc]
    3d32:      	ldr.w	r12, [r7, #0x8]
    3d36:      	str.w	r12, [sp, #0x10]
    3d3a:      	str	r0, [sp, #0x18]
    3d3c:      	str	r2, [sp, #0x1c]
    3d3e:      	str	r1, [sp, #0x20]
    3d40:      	str	r3, [sp, #0x24]
    3d42:      	movs	r2, #0x0
;     is_zst: bool,
    3d44:      	strb	r2, [r7, #-13]
;             ub_checks::maybe_is_aligned_and_not_null(data, align, false)
    3d48:      	str	r0, [sp, #0x2c]
;             ptr.is_aligned_to(align)
    3d4a:      	bl	0x31b0 <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs2GpT71Ckjdn_10rtt_target> @ imm = #-0xb9e
;     maybe_is_aligned(ptr, align) && (is_zst || !ptr.is_null())
    3d4e:      	cbnz	r0, 0x3d54 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x34> @ imm = #0x2
    3d50:      	b	0x3d52 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x32> @ imm = #-0x2
;             ub_checks::maybe_is_aligned_and_not_null(data, align, false)
    3d52:      	b	0x3d5a <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x3a> @ imm = #0x4
    3d54:      	ldr	r0, [sp, #0xc]
    3d56:      	cbnz	r0, 0x3d5c <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x3c> @ imm = #0x2
    3d58:      	b	0x3d5a <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x3a> @ imm = #-0x2
    3d5a:      	b	0x3d62 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x42> @ imm = #0x4
;     let max_len = if size == 0 { usize::MAX } else { isize::MAX as usize / size };
    3d5c:      	ldr	r0, [sp, #0x8]
    3d5e:      	cbz	r0, 0x3d7e <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x5e> @ imm = #0x1c
    3d60:      	b	0x3d86 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x66> @ imm = #0x22
;                     let msg = concat!("unsafe precondition(s) violated: ", $message,
    3d62:      	ldr	r3, [sp, #0x10]
    3d64:      	movw	r0, #0x64f1
    3d68:      	movt	r0, #0x0
    3d6c:      	str	r0, [sp, #0x30]
    3d6e:      	movw	r1, #0x117
    3d72:      	str	r1, [sp, #0x34]
;                     ::core::panicking::panic_nounwind_fmt(::core::fmt::Arguments::from_str(msg), false);
    3d74:      	movw	r1, #0x22f
    3d78:      	movs	r2, #0x0
    3d7a:      	bl	0x47c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt> @ imm = #0xa42
;     let max_len = if size == 0 { usize::MAX } else { isize::MAX as usize / size };
    3d7e:      	mov.w	r0, #0xffffffff
    3d82:      	str	r0, [sp, #0x14]
    3d84:      	b	0x3d94 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x74> @ imm = #0xc
    3d86:      	ldr	r1, [sp, #0x8]
    3d88:      	mvn	r0, #0x80000000
    3d8c:      	udiv	r0, r0, r1
    3d90:      	str	r0, [sp, #0x14]
    3d92:      	b	0x3d94 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x74> @ imm = #-0x2
;     len <= max_len
    3d94:      	ldr	r0, [sp]
    3d96:      	ldr	r1, [sp, #0x14]
;                 && ub_checks::is_valid_allocation_size(size, len)
    3d98:      	cmp	r0, r1
    3d9a:      	bls	0x3da0 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x80> @ imm = #0x2
    3d9c:      	b	0x3d9e <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x7e> @ imm = #-0x2
    3d9e:      	b	0x3d62 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw14from_raw_parts18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x42> @ imm = #-0x40
;             }
    3da0:      	add	sp, #0x38
    3da2:      	pop	{r7, pc}

00003da4 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target>:
;             const fn precondition_check($($name:$ty),*) {
    3da4:      	push	{r7, lr}
    3da6:      	mov	r7, sp
    3da8:      	sub	sp, #0x38
    3daa:      	str	r3, [sp]
    3dac:      	str	r2, [sp, #0x4]
    3dae:      	mov	r2, r1
    3db0:      	ldr	r1, [sp, #0x4]
    3db2:      	str	r2, [sp, #0x8]
    3db4:      	str	r0, [sp, #0xc]
    3db6:      	ldr.w	r12, [r7, #0x8]
    3dba:      	str.w	r12, [sp, #0x10]
    3dbe:      	str	r0, [sp, #0x18]
    3dc0:      	str	r2, [sp, #0x1c]
    3dc2:      	str	r1, [sp, #0x20]
    3dc4:      	str	r3, [sp, #0x24]
    3dc6:      	movs	r2, #0x0
;     is_zst: bool,
    3dc8:      	strb	r2, [r7, #-13]
;             ub_checks::maybe_is_aligned_and_not_null(data, align, false)
    3dcc:      	str	r0, [sp, #0x2c]
;             ptr.is_aligned_to(align)
    3dce:      	bl	0x31b0 <_RNvMNtNtCs6e6HQTixP8o_4core3ptr9const_ptrPu13is_aligned_toCs2GpT71Ckjdn_10rtt_target> @ imm = #-0xc22
;     maybe_is_aligned(ptr, align) && (is_zst || !ptr.is_null())
    3dd2:      	cbnz	r0, 0x3dd8 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x34> @ imm = #0x2
    3dd4:      	b	0x3dd6 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x32> @ imm = #-0x2
;             ub_checks::maybe_is_aligned_and_not_null(data, align, false)
    3dd6:      	b	0x3dde <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x3a> @ imm = #0x4
    3dd8:      	ldr	r0, [sp, #0xc]
    3dda:      	cbnz	r0, 0x3de0 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x3c> @ imm = #0x2
    3ddc:      	b	0x3dde <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x3a> @ imm = #-0x2
    3dde:      	b	0x3de6 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x42> @ imm = #0x4
;     let max_len = if size == 0 { usize::MAX } else { isize::MAX as usize / size };
    3de0:      	ldr	r0, [sp, #0x8]
    3de2:      	cbz	r0, 0x3e02 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x5e> @ imm = #0x1c
    3de4:      	b	0x3e0a <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x66> @ imm = #0x22
;                     let msg = concat!("unsafe precondition(s) violated: ", $message,
    3de6:      	ldr	r3, [sp, #0x10]
    3de8:      	movw	r0, #0x6608
    3dec:      	movt	r0, #0x0
    3df0:      	str	r0, [sp, #0x30]
    3df2:      	movw	r1, #0x11b
    3df6:      	str	r1, [sp, #0x34]
;                     ::core::panicking::panic_nounwind_fmt(::core::fmt::Arguments::from_str(msg), false);
    3df8:      	movw	r1, #0x237
    3dfc:      	movs	r2, #0x0
    3dfe:      	bl	0x47c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt> @ imm = #0x9be
;     let max_len = if size == 0 { usize::MAX } else { isize::MAX as usize / size };
    3e02:      	mov.w	r0, #0xffffffff
    3e06:      	str	r0, [sp, #0x14]
    3e08:      	b	0x3e18 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x74> @ imm = #0xc
    3e0a:      	ldr	r1, [sp, #0x8]
    3e0c:      	mvn	r0, #0x80000000
    3e10:      	udiv	r0, r0, r1
    3e14:      	str	r0, [sp, #0x14]
    3e16:      	b	0x3e18 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x74> @ imm = #-0x2
;     len <= max_len
    3e18:      	ldr	r0, [sp]
    3e1a:      	ldr	r1, [sp, #0x14]
;                 && ub_checks::is_valid_allocation_size(size, len)
    3e1c:      	cmp	r0, r1
    3e1e:      	bls	0x3e24 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x80> @ imm = #0x2
    3e20:      	b	0x3e22 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x7e> @ imm = #-0x2
    3e22:      	b	0x3de6 <_RNvNvNtNtCs6e6HQTixP8o_4core5slice3raw18from_raw_parts_mut18precondition_checkCs2GpT71Ckjdn_10rtt_target+0x42> @ imm = #-0x40
;             }
    3e24:      	add	sp, #0x38
    3e26:      	pop	{r7, pc}

00003e28 <_RNvNvNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_raw8do_panic7runtimeCs2GpT71Ckjdn_10rtt_target>:
;         fn runtime$(<$($binders)*>)?($($arg: $ty),*) $( -> $ret )? {
    3e28:      	push	{r7, lr}
    3e2a:      	mov	r7, sp
    3e2c:      	sub	sp, #0x70
    3e2e:      	str	r3, [sp]
    3e30:      	mov	r3, r2
    3e32:      	ldr	r2, [sp]
    3e34:      	str	r3, [sp, #0x4]
    3e36:      	mov	r3, r0
    3e38:      	ldr	r0, [sp, #0x4]
    3e3a:      	str	r3, [sp, #0x8]
    3e3c:      	str	r1, [sp, #0xc]
    3e3e:      	str	r0, [sp, #0x10]
;         template: &'a [u8; N],
    3e40:      	movw	r0, #0x6723
    3e44:      	movt	r0, #0x0
    3e48:      	str	r0, [sp, #0x5c]
    3e4a:      	add	r1, sp, #0xc
;                     $crate::panic!($runtime_msg)
    3e4c:      	str	r1, [sp, #0x60]
    3e4e:      	add.w	r12, sp, #0x8
    3e52:      	str.w	r12, [sp, #0x64]
    3e56:      	add	r3, sp, #0x10
    3e58:      	str	r3, [sp, #0x68]
;             ty: ArgumentType::Placeholder {
    3e5a:      	str	r1, [sp, #0x44]
    3e5c:      	movw	r1, #0x4f6d
    3e60:      	movt	r1, #0x0
    3e64:      	str	r1, [sp, #0x48]
;         Argument {
    3e66:      	ldr.w	lr, [sp, #0x44]
    3e6a:      	ldr	r4, [sp, #0x48]
    3e6c:      	str	r4, [sp, #0x30]
    3e6e:      	str.w	lr, [sp, #0x2c]
;             ty: ArgumentType::Placeholder {
    3e72:      	str.w	r12, [sp, #0x4c]
    3e76:      	movw	r12, #0x4edf
    3e7a:      	movt	r12, #0x0
    3e7e:      	str.w	r12, [sp, #0x50]
;         Argument {
    3e82:      	ldr.w	r12, [sp, #0x4c]
    3e86:      	ldr.w	lr, [sp, #0x50]
    3e8a:      	str.w	lr, [sp, #0x38]
    3e8e:      	str.w	r12, [sp, #0x34]
;             ty: ArgumentType::Placeholder {
    3e92:      	str	r3, [sp, #0x54]
    3e94:      	str	r1, [sp, #0x58]
;         Argument {
    3e96:      	ldr	r1, [sp, #0x54]
    3e98:      	ldr	r3, [sp, #0x58]
    3e9a:      	str	r3, [sp, #0x40]
    3e9c:      	str	r1, [sp, #0x3c]
;                     $crate::panic!($runtime_msg)
    3e9e:      	ldr	r1, [sp, #0x2c]
    3ea0:      	ldr	r3, [sp, #0x30]
    3ea2:      	str	r3, [sp, #0x18]
    3ea4:      	str	r1, [sp, #0x14]
    3ea6:      	ldr	r1, [sp, #0x34]
    3ea8:      	ldr	r3, [sp, #0x38]
    3eaa:      	str	r3, [sp, #0x20]
    3eac:      	str	r1, [sp, #0x1c]
    3eae:      	ldr	r1, [sp, #0x3c]
    3eb0:      	ldr	r3, [sp, #0x40]
    3eb2:      	str	r3, [sp, #0x28]
    3eb4:      	str	r1, [sp, #0x24]
    3eb6:      	add	r1, sp, #0x14
    3eb8:      	str	r1, [sp, #0x6c]
    3eba:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x982

00003ebe <_RNvXNtNtNtCs6e6HQTixP8o_4core4iter6traits7collectINtNtNtB6_8adapters9enumerate9EnumerateINtNtNtB8_5slice4iter4IterhEENtB2_12IntoIterator9into_iterCs2GpT71Ckjdn_10rtt_target>:
;     fn into_iter(self) -> I {
    3ebe:      	push	{r7, lr}
    3ec0:      	mov	r7, sp
    3ec2:      	mov	r3, r1
    3ec4:      	mov	r1, r0
;         self
    3ec6:      	ldr	r0, [r3]
    3ec8:      	ldr	r2, [r3, #0x4]
    3eca:      	ldr	r3, [r3, #0x8]
    3ecc:      	str	r3, [r1, #0x8]
    3ece:      	str	r2, [r1, #0x4]
    3ed0:      	str	r0, [r1]
;     }
    3ed2:      	pop	{r7, pc}

00003ed4 <_RNvXs1_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriterNtNtNtCs6e6HQTixP8o_4core3ops4drop4Drop4drop>:
;     fn drop(&mut self) {
    3ed4:      	push	{r7, lr}
    3ed6:      	mov	r7, sp
    3ed8:      	sub	sp, #0x8
    3eda:      	str	r0, [sp, #0x4]
;         self.commit_impl();
    3edc:      	bl	0x31fa <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter11commit_impl> @ imm = #-0xce6
;     }
    3ee0:      	add	sp, #0x8
    3ee2:      	pop	{r7, pc}

00003ee4 <_RNvXs2J_NtNtCs6e6HQTixP8o_4core5slice4iterINtB6_4IterhENtNtNtNtBa_4iter6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target>:
;             fn next(&mut self) -> Option<$elem> {
    3ee4:      	push	{r7, lr}
    3ee6:      	mov	r7, sp
    3ee8:      	sub	sp, #0x24
    3eea:      	str	r0, [sp]
    3eec:      	str	r0, [sp, #0x10]
;         pub const unsafe fn unchecked_sub(self, rhs: Self) -> Self {
    3eee:      	movs	r1, #0x1
    3ef0:      	str	r1, [sp, #0x14]
;     pub const unsafe fn add(self, count: usize) -> Self
    3ef2:      	str	r1, [sp, #0x18]
;                 let ptr = self.ptr;
    3ef4:      	ldr	r1, [r0]
    3ef6:      	str	r1, [sp, #0x4]
    3ef8:      	str	r1, [sp, #0x1c]
;                 let end_or_len = self.end_or_len;
    3efa:      	ldr	r0, [r0, #0x4]
    3efc:      	str	r0, [sp, #0x8]
    3efe:      	str	r0, [sp, #0x20]
;                     if T::IS_ZST {
    3f00:      	b	0x3f02 <_RNvXs2J_NtNtCs6e6HQTixP8o_4core5slice4iterINtB6_4IterhENtNtNtNtBa_4iter6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x1e> @ imm = #-0x2
;     fn eq(&self, other: &Self) -> bool {
    3f02:      	ldr	r0, [sp, #0x4]
    3f04:      	ldr	r1, [sp, #0x8]
;                         if ptr == crate::intrinsics::transmute::<$ptr, NonNull<T>>(end_or_len) {
    3f06:      	cmp	r0, r1
    3f08:      	beq	0x3f16 <_RNvXs2J_NtNtCs6e6HQTixP8o_4core5slice4iterINtB6_4IterhENtNtNtNtBa_4iter6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x32> @ imm = #0xa
    3f0a:      	b	0x3f0c <_RNvXs2J_NtNtCs6e6HQTixP8o_4core5slice4iterINtB6_4IterhENtNtNtNtBa_4iter6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x28> @ imm = #-0x2
;         unsafe { transmute(intrinsics::offset(self.as_ptr(), count)) }
    3f0c:      	ldr	r1, [sp]
    3f0e:      	ldr	r0, [sp, #0x4]
    3f10:      	adds	r0, #0x1
;                         self.ptr = ptr.add(1);
    3f12:      	str	r0, [r1]
;                     if T::IS_ZST {
    3f14:      	b	0x3f1c <_RNvXs2J_NtNtCs6e6HQTixP8o_4core5slice4iterINtB6_4IterhENtNtNtNtBa_4iter6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x38> @ imm = #0x4
;                             return None;
    3f16:      	movs	r0, #0x0
    3f18:      	str	r0, [sp, #0xc]
    3f1a:      	b	0x3f28 <_RNvXs2J_NtNtCs6e6HQTixP8o_4core5slice4iterINtB6_4IterhENtNtNtNtBa_4iter6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x44> @ imm = #0xa
;     pub const unsafe fn as_ref<'a>(&self) -> &'a T {
    3f1c:      	ldr	r0, [sp, #0x4]
;                     Some({ptr}.$into_ref())
    3f1e:      	str	r0, [sp, #0xc]
;             }
    3f20:      	b	0x3f22 <_RNvXs2J_NtNtCs6e6HQTixP8o_4core5slice4iterINtB6_4IterhENtNtNtNtBa_4iter6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x3e> @ imm = #-0x2
    3f22:      	ldr	r0, [sp, #0xc]
    3f24:      	add	sp, #0x24
    3f26:      	pop	{r7, pc}
    3f28:      	b	0x3f22 <_RNvXs2J_NtNtCs6e6HQTixP8o_4core5slice4iterINtB6_4IterhENtNtNtNtBa_4iter6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x3e> @ imm = #-0xa

00003f2a <_RNvXs5_Cs2GpT71Ckjdn_10rtt_targetNtB5_14TerminalWriterNtNtCs6e6HQTixP8o_4core3fmt5Write9write_str>:
;     fn write_str(&mut self, s: &str) -> Result<(), fmt::Error> {
    3f2a:      	push	{r7, lr}
    3f2c:      	mov	r7, sp
    3f2e:      	sub	sp, #0x18
    3f30:      	str	r0, [sp, #0x4]
    3f32:      	str	r1, [sp, #0x8]
    3f34:      	str	r2, [sp, #0xc]
;         self.writer.write(s.as_bytes());
    3f36:      	adds	r0, #0x4
    3f38:      	str	r1, [sp, #0x10]
    3f3a:      	str	r2, [sp, #0x14]
    3f3c:      	bl	0x343a <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter5write> @ imm = #-0xb06
    3f40:      	movs	r0, #0x0
;     }
    3f42:      	add	sp, #0x18
    3f44:      	pop	{r7, pc}

00003f46 <_RNvXs5_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_10WriteStateNtNtCs6e6HQTixP8o_4core3cmp9PartialEq2eqB7_>:
; #[derive(Eq, PartialEq)]
    3f46:      	push	{r7, lr}
    3f48:      	mov	r7, sp
    3f4a:      	sub	sp, #0x10
    3f4c:      	str	r0, [sp]
    3f4e:      	str	r1, [sp, #0x4]
    3f50:      	ldrb	r0, [r0]
    3f52:      	str	r0, [sp, #0x8]
    3f54:      	ldrb	r1, [r1]
    3f56:      	str	r1, [sp, #0xc]
    3f58:      	subs	r0, r0, r1
    3f5a:      	clz	r0, r0
    3f5e:      	lsrs	r0, r0, #0x5
    3f60:      	add	sp, #0x10
    3f62:      	pop	{r7, pc}

00003f64 <_RNvXs5_NtNtCs6e6HQTixP8o_4core5slice5indexINtNtNtB9_3ops5range9RangeFromjEINtB5_10SliceIndexShE5indexCs2GpT71Ckjdn_10rtt_target>:
;     fn index(self, slice: &[T]) -> &[T] {
    3f64:      	push	{r7, lr}
    3f66:      	mov	r7, sp
    3f68:      	sub	sp, #0x28
    3f6a:      	str	r3, [sp, #0x4]
    3f6c:      	str	r2, [sp, #0x8]
    3f6e:      	str	r1, [sp, #0xc]
    3f70:      	str	r0, [sp, #0x10]
    3f72:      	str	r0, [sp, #0x14]
    3f74:      	str	r1, [sp, #0x18]
    3f76:      	str	r2, [sp, #0x1c]
;         if self.start > slice.len() {
    3f78:      	str	r0, [sp, #0x20]
    3f7a:      	cmp	r0, r2
    3f7c:      	bhi	0x3f90 <_RNvXs5_NtNtCs6e6HQTixP8o_4core5slice5indexINtNtNtB9_3ops5range9RangeFromjEINtB5_10SliceIndexShE5indexCs2GpT71Ckjdn_10rtt_target+0x2c> @ imm = #0x10
    3f7e:      	b	0x3f80 <_RNvXs5_NtNtCs6e6HQTixP8o_4core5slice5indexINtNtNtB9_3ops5range9RangeFromjEINtB5_10SliceIndexShE5indexCs2GpT71Ckjdn_10rtt_target+0x1c> @ imm = #-0x2
;             let new_len = crate::intrinsics::unchecked_sub(slice.len(), self.start);
    3f80:      	ldr	r0, [sp, #0xc]
    3f82:      	ldr	r2, [sp, #0x10]
    3f84:      	ldr	r1, [sp, #0x8]
    3f86:      	subs	r1, r1, r2
    3f88:      	str	r1, [sp, #0x24]
;     let ptr = unsafe { crate::intrinsics::offset(ptr, offset) };
    3f8a:      	add	r0, r2
;     }
    3f8c:      	add	sp, #0x28
    3f8e:      	pop	{r7, pc}
;             slice_index_fail(self.start, slice.len(), slice.len())
    3f90:      	ldr	r3, [sp, #0x4]
    3f92:      	ldr	r2, [sp, #0x8]
    3f94:      	ldr	r0, [sp, #0x10]
    3f96:      	mov	r1, r2
    3f98:      	bl	0x4d46 <_RNvNtNtCs6e6HQTixP8o_4core5slice5index16slice_index_fail> @ imm = #0xdaa

00003f9c <_RNvXs7_Cs2GpT71Ckjdn_10rtt_targetNtB5_14TerminalWriterNtNtNtCs6e6HQTixP8o_4core3ops4drop4Drop4drop>:
;     fn drop(&mut self) {
    3f9c:      	push	{r7, lr}
    3f9e:      	mov	r7, sp
    3fa0:      	sub	sp, #0x8
    3fa2:      	str	r0, [sp]
    3fa4:      	str	r0, [sp, #0x4]
;         if !self.writer.is_failed() {
    3fa6:      	adds	r0, #0x4
    3fa8:      	bl	0x3462 <_RNvMs0_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_9RttWriter9is_failed> @ imm = #-0xb4a
    3fac:      	cbnz	r0, 0x3fba <_RNvXs7_Cs2GpT71Ckjdn_10rtt_targetNtB5_14TerminalWriterNtNtNtCs6e6HQTixP8o_4core3ops4drop4Drop4drop+0x1e> @ imm = #0xa
    3fae:      	b	0x3fb0 <_RNvXs7_Cs2GpT71Ckjdn_10rtt_targetNtB5_14TerminalWriterNtNtNtCs6e6HQTixP8o_4core3ops4drop4Drop4drop+0x14> @ imm = #-0x2
;             *self.current = self.number;
    3fb0:      	ldr	r1, [sp]
    3fb2:      	ldrb	r0, [r1, #0x14]
    3fb4:      	ldr	r1, [r1]
    3fb6:      	strb	r0, [r1]
;         if !self.writer.is_failed() {
    3fb8:      	b	0x3fba <_RNvXs7_Cs2GpT71Ckjdn_10rtt_targetNtB5_14TerminalWriterNtNtNtCs6e6HQTixP8o_4core3ops4drop4Drop4drop+0x1e> @ imm = #-0x2
;     }
    3fba:      	add	sp, #0x8
    3fbc:      	pop	{r7, pc}

00003fbe <_RNvXsO_NtCs6e6HQTixP8o_4core4cellNtB5_12BorrowRefMutNtNtNtB7_3ops4drop4Drop4dropCs2GpT71Ckjdn_10rtt_target>:
;     fn drop(&mut self) {
    3fbe:      	push	{r7, lr}
    3fc0:      	mov	r7, sp
    3fc2:      	sub	sp, #0x4
    3fc4:      	str	r0, [sp]
;         let borrow = self.borrow.get();
    3fc6:      	ldr	r1, [r0]
;         unsafe { *self.value.get() }
    3fc8:      	ldr	r0, [r1]
;         self.borrow.replace(borrow + 1);
    3fca:      	adds	r0, #0x1
;         crate::intrinsics::write_via_move(dest, src);
    3fcc:      	str	r0, [r1]
;     }
    3fce:      	add	sp, #0x4
    3fd0:      	pop	{r7, pc}

00003fd2 <_RNvXsR_NtCs6e6HQTixP8o_4core4cellINtB5_6RefMutINtNtB7_6option6OptionNtCs2GpT71Ckjdn_10rtt_target15TerminalChannelEENtNtNtB7_3ops5deref8DerefMut9deref_mutB16_>:
;     fn deref_mut(&mut self) -> &mut T {
    3fd2:      	push	{r7, lr}
    3fd4:      	mov	r7, sp
    3fd6:      	sub	sp, #0x4
    3fd8:      	str	r0, [sp]
;         unsafe { &mut *self.as_ptr() }
    3fda:      	ldr	r0, [r0]
;     }
    3fdc:      	add	sp, #0x4
    3fde:      	pop	{r7, pc}

00003fe0 <_RNvXs_NtNtNtCs6e6HQTixP8o_4core4iter8adapters9enumerateINtB4_9EnumerateINtNtNtBa_5slice4iter4IterhEENtNtNtB8_6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target>:
;     fn next(&mut self) -> Option<(usize, <I as Iterator>::Item)> {
    3fe0:      	push	{r7, lr}
    3fe2:      	mov	r7, sp
    3fe4:      	sub	sp, #0x38
    3fe6:      	str	r0, [sp, #0x10]
    3fe8:      	str	r0, [sp, #0x24]
;         let a = self.iter.next()?;
    3fea:      	bl	0x3ee4 <_RNvXs2J_NtNtCs6e6HQTixP8o_4core5slice4iterINtB6_4IterhENtNtNtNtBa_4iter6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target> @ imm = #-0x10a
    3fee:      	str	r0, [sp, #0x20]
;         match self {
    3ff0:      	ldr	r0, [sp, #0x20]
    3ff2:      	cbz	r0, 0x4018 <_RNvXs_NtNtNtCs6e6HQTixP8o_4core4iter8adapters9enumerateINtB4_9EnumerateINtNtNtBa_5slice4iter4IterhEENtNtNtB8_6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x38> @ imm = #0x22
    3ff4:      	b	0x3ff6 <_RNvXs_NtNtNtCs6e6HQTixP8o_4core4iter8adapters9enumerateINtB4_9EnumerateINtNtNtBa_5slice4iter4IterhEENtNtNtB8_6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x16> @ imm = #-0x2
;             Some(v) => ControlFlow::Continue(v),
    3ff6:      	ldr	r0, [sp, #0x10]
    3ff8:      	ldr	r1, [sp, #0x20]
    3ffa:      	str	r1, [sp, #0x2c]
    3ffc:      	str	r1, [sp, #0x1c]
;         let a = self.iter.next()?;
    3ffe:      	ldr	r1, [sp, #0x1c]
    4000:      	str	r1, [sp, #0x4]
    4002:      	str	r1, [sp, #0x30]
;         let i = self.count;
    4004:      	ldr	r1, [r0, #0x8]
    4006:      	str	r1, [sp, #0x8]
    4008:      	str	r1, [sp, #0x34]
;         self.count += 1;
    400a:      	ldr	r1, [r0, #0x8]
    400c:      	adds	r0, r1, #0x1
    400e:      	mov	r2, r0
    4010:      	str	r2, [sp, #0xc]
    4012:      	cmp	r0, r1
    4014:      	blo	0x4036 <_RNvXs_NtNtNtCs6e6HQTixP8o_4core4iter8adapters9enumerateINtB4_9EnumerateINtNtNtBa_5slice4iter4IterhEENtNtNtB8_6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x56> @ imm = #0x1e
    4016:      	b	0x4026 <_RNvXs_NtNtNtCs6e6HQTixP8o_4core4iter8adapters9enumerateINtB4_9EnumerateINtNtNtBa_5slice4iter4IterhEENtNtNtB8_6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x46> @ imm = #0xc
;             None => None,
    4018:      	movs	r0, #0x0
    401a:      	str	r0, [sp, #0x18]
;     }
    401c:      	b	0x401e <_RNvXs_NtNtNtCs6e6HQTixP8o_4core4iter8adapters9enumerateINtB4_9EnumerateINtNtNtBa_5slice4iter4IterhEENtNtNtB8_6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x3e> @ imm = #-0x2
    401e:      	ldr	r0, [sp, #0x14]
    4020:      	ldr	r1, [sp, #0x18]
    4022:      	add	sp, #0x38
    4024:      	pop	{r7, pc}
;         self.count += 1;
    4026:      	ldr	r0, [sp, #0x4]
    4028:      	ldr	r1, [sp, #0x8]
    402a:      	ldr	r2, [sp, #0xc]
    402c:      	ldr	r3, [sp, #0x10]
    402e:      	str	r2, [r3, #0x8]
;         Some((i, a))
    4030:      	str	r1, [sp, #0x14]
    4032:      	str	r0, [sp, #0x18]
;     }
    4034:      	b	0x401e <_RNvXs_NtNtNtCs6e6HQTixP8o_4core4iter8adapters9enumerateINtB4_9EnumerateINtNtNtBa_5slice4iter4IterhEENtNtNtB8_6traits8iterator8Iterator4nextCs2GpT71Ckjdn_10rtt_target+0x3e> @ imm = #-0x1a
;         self.count += 1;
    4036:      	movw	r0, #0x676c
    403a:      	movt	r0, #0x0
    403e:      	bl	0x4dd0 <_RNvNtNtCs6e6HQTixP8o_4core9panicking11panic_const24panic_const_add_overflow> @ imm = #0xd8e

00004042 <_RNvXs_NvNtNtCs6e6HQTixP8o_4core3fmt5Write9write_fmtQNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterNtB4_12SpecWriteFmt14spec_write_fmtBQ_>:
;             fn spec_write_fmt(self, args: Arguments<'_>) -> Result {
    4042:      	push	{r7, lr}
    4044:      	mov	r7, sp
    4046:      	sub	sp, #0x28
    4048:      	str	r0, [sp, #0x4]
    404a:      	str	r1, [sp, #0x8]
    404c:      	str	r2, [sp, #0xc]
    404e:      	str	r0, [sp, #0x1c]
    4050:      	add	r0, sp, #0x8
;                 if let Some(s) = args.as_statically_known_str() {
    4052:      	bl	0x35a8 <_RNvMs4_NtCs6e6HQTixP8o_4core3fmtNtB5_9Arguments23as_statically_known_strCs2GpT71Ckjdn_10rtt_target> @ imm = #-0xaae
    4056:      	str	r0, [sp, #0x14]
    4058:      	str	r1, [sp, #0x18]
    405a:      	ldr	r0, [sp, #0x14]
    405c:      	cbz	r0, 0x4074 <_RNvXs_NvNtNtCs6e6HQTixP8o_4core3fmt5Write9write_fmtQNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterNtB4_12SpecWriteFmt14spec_write_fmtBQ_+0x32> @ imm = #0x14
    405e:      	b	0x4060 <_RNvXs_NvNtNtCs6e6HQTixP8o_4core3fmt5Write9write_fmtQNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterNtB4_12SpecWriteFmt14spec_write_fmtBQ_+0x1e> @ imm = #-0x2
    4060:      	ldr	r0, [sp, #0x4]
    4062:      	ldr	r1, [sp, #0x14]
    4064:      	ldr	r2, [sp, #0x18]
    4066:      	str	r1, [sp, #0x20]
    4068:      	str	r2, [sp, #0x24]
;                     self.write_str(s)
    406a:      	bl	0x3f2a <_RNvXs5_Cs2GpT71Ckjdn_10rtt_targetNtB5_14TerminalWriterNtNtCs6e6HQTixP8o_4core3fmt5Write9write_str> @ imm = #-0x144
    406e:      	strb	r0, [r7, #-21]
;                 if let Some(s) = args.as_statically_known_str() {
    4072:      	b	0x408c <_RNvXs_NvNtNtCs6e6HQTixP8o_4core3fmt5Write9write_fmtQNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterNtB4_12SpecWriteFmt14spec_write_fmtBQ_+0x4a> @ imm = #0x16
;                     write(self, args)
    4074:      	ldr	r0, [sp, #0x4]
    4076:      	ldr	r2, [sp, #0x8]
    4078:      	ldr	r3, [sp, #0xc]
    407a:      	movw	r1, #0x677c
    407e:      	movt	r1, #0x0
    4082:      	bl	0x463c <_RNvNtCs6e6HQTixP8o_4core3fmt5write> @ imm = #0x5b6
    4086:      	strb	r0, [r7, #-21]
;                 if let Some(s) = args.as_statically_known_str() {
    408a:      	b	0x408c <_RNvXs_NvNtNtCs6e6HQTixP8o_4core3fmt5Write9write_fmtQNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterNtB4_12SpecWriteFmt14spec_write_fmtBQ_+0x4a> @ imm = #-0x2
;             }
    408c:      	ldrb	r0, [r7, #-21]
    4090:      	add	sp, #0x28
    4092:      	pop	{r7, pc}

00004094 <_RNvXsa_Cs2GpT71Ckjdn_10rtt_targetNtB5_11ChannelModeNtNtCs6e6HQTixP8o_4core3cmp9PartialEq2eqB5_>:
; #[derive(Eq, PartialEq)]
    4094:      	push	{r7, lr}
    4096:      	mov	r7, sp
    4098:      	sub	sp, #0x10
    409a:      	str	r0, [sp]
    409c:      	str	r1, [sp, #0x4]
    409e:      	ldr	r0, [r0]
    40a0:      	str	r0, [sp, #0x8]
    40a2:      	ldr	r1, [r1]
    40a4:      	str	r1, [sp, #0xc]
    40a6:      	subs	r0, r0, r1
    40a8:      	clz	r0, r0
    40ac:      	lsrs	r0, r0, #0x5
    40ae:      	add	sp, #0x10
    40b0:      	pop	{r7, pc}

000040b2 <_RNvXsb_NtCs6e6HQTixP8o_4core5arrayRAhj10_NtNtNtNtB7_4iter6traits7collect12IntoIterator9into_iterCs2GpT71Ckjdn_10rtt_target>:
;     fn into_iter(self) -> Iter<'a, T> {
    40b2:      	push	{r7, lr}
    40b4:      	mov	r7, sp
    40b6:      	sub	sp, #0x30
    40b8:      	str	r0, [sp]
    40ba:      	str	r0, [sp, #0x8]
;         let len = slice.len();
    40bc:      	movs	r1, #0x10
    40be:      	str	r1, [sp, #0xc]
; pub const fn without_provenance<T>(addr: usize) -> *const T {
    40c0:      	str	r1, [sp, #0x10]
;     pub const unsafe fn add(self, count: usize) -> Self
    40c2:      	str	r1, [sp, #0x14]
;         self.iter()
    40c4:      	str	r0, [sp, #0x18]
    40c6:      	str	r1, [sp, #0x1c]
;         unsafe { transmute(r as *const T) }
    40c8:      	str	r0, [sp, #0x20]
    40ca:      	str	r1, [sp, #0x24]
;         unsafe { transmute(self.as_ptr() as *mut U) }
    40cc:      	str	r0, [sp, #0x28]
;                 if T::IS_ZST { without_provenance(len) } else { ptr.as_ptr().add(len) };
    40ce:      	b	0x40d0 <_RNvXsb_NtCs6e6HQTixP8o_4core5arrayRAhj10_NtNtNtNtB7_4iter6traits7collect12IntoIterator9into_iterCs2GpT71Ckjdn_10rtt_target+0x1e> @ imm = #-0x2
;         unsafe { mem::transmute::<Self, *mut T>(self) }
    40d0:      	ldr	r0, [sp]
    40d2:      	str	r0, [sp, #0x2c]
;         unsafe { intrinsics::offset(self, count) }
    40d4:      	adds	r0, #0x10
;                 if T::IS_ZST { without_provenance(len) } else { ptr.as_ptr().add(len) };
    40d6:      	str	r0, [sp, #0x4]
    40d8:      	b	0x40da <_RNvXsb_NtCs6e6HQTixP8o_4core5arrayRAhj10_NtNtNtNtB7_4iter6traits7collect12IntoIterator9into_iterCs2GpT71Ckjdn_10rtt_target+0x28> @ imm = #-0x2
;             Self { ptr, end_or_len, _marker: PhantomData }
    40da:      	ldr	r0, [sp]
    40dc:      	ldr	r1, [sp, #0x4]
;     }
    40de:      	add	sp, #0x30
    40e0:      	pop	{r7, pc}

000040e2 <_RNvYINtNtNtCs6e6HQTixP8o_4core5slice4iter4IterhENtNtNtNtB9_4iter6traits8iterator8Iterator9enumerateCs2GpT71Ckjdn_10rtt_target>:
;     fn enumerate(self) -> Enumerate<Self>
    40e2:      	push	{r7, lr}
    40e4:      	mov	r7, sp
    40e6:      	sub	sp, #0xc
    40e8:      	str	r1, [sp]
    40ea:      	mov	r1, r0
    40ec:      	ldr	r0, [sp]
    40ee:      	str	r0, [sp, #0x4]
    40f0:      	str	r2, [sp, #0x8]
;         Enumerate { iter, count: 0 }
    40f2:      	str	r0, [r1]
    40f4:      	str	r2, [r1, #0x4]
    40f6:      	movs	r0, #0x0
    40f8:      	str	r0, [r1, #0x8]
;     }
    40fa:      	add	sp, #0xc
    40fc:      	pop	{r7, pc}

000040fe <_RNvYNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterNtNtCs6e6HQTixP8o_4core3fmt5Write10write_charB4_>:
;     fn write_char(&mut self, c: char) -> Result {
    40fe:      	push	{r7, lr}
    4100:      	mov	r7, sp
    4102:      	sub	sp, #0x28
    4104:      	str	r1, [sp]
    4106:      	mov	r1, r0
    4108:      	ldr	r0, [sp]
    410a:      	str	r1, [sp, #0x4]
    410c:      	str	r1, [sp, #0x10]
    410e:      	str	r0, [sp, #0x14]
    4110:      	movs	r1, #0x0
;         self.write_str(c.encode_utf8(&mut [0; char::MAX_LEN_UTF8]))
    4112:      	str	r1, [sp, #0xc]
    4114:      	add	r1, sp, #0xc
    4116:      	str	r1, [sp, #0x18]
    4118:      	movs	r2, #0x4
    411a:      	str	r2, [sp, #0x1c]
;         unsafe { from_utf8_unchecked_mut(encode_utf8_raw(self as u32, dst)) }
    411c:      	bl	0x39fe <_RNvNtNtCs6e6HQTixP8o_4core4char7methods15encode_utf8_rawCs2GpT71Ckjdn_10rtt_target> @ imm = #-0x722
    4120:      	mov	r2, r0
    4122:      	ldr	r0, [sp, #0x4]
    4124:      	str	r2, [sp, #0x8]
    4126:      	mov	r2, r1
    4128:      	ldr	r1, [sp, #0x8]
    412a:      	str	r1, [sp, #0x20]
    412c:      	str	r2, [sp, #0x24]
;         self.write_str(c.encode_utf8(&mut [0; char::MAX_LEN_UTF8]))
    412e:      	bl	0x3f2a <_RNvXs5_Cs2GpT71Ckjdn_10rtt_targetNtB5_14TerminalWriterNtNtCs6e6HQTixP8o_4core3fmt5Write9write_str> @ imm = #-0x208
;     }
    4132:      	add	sp, #0x28
    4134:      	pop	{r7, pc}

00004136 <_RNvYNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterNtNtCs6e6HQTixP8o_4core3fmt5Write9write_fmtB4_>:
;     fn write_fmt(&mut self, args: Arguments<'_>) -> Result {
    4136:      	push	{r7, lr}
    4138:      	mov	r7, sp
    413a:      	sub	sp, #0x10
    413c:      	str	r0, [sp, #0x4]
    413e:      	str	r1, [sp, #0x8]
    4140:      	str	r2, [sp, #0xc]
;         self.spec_write_fmt(args)
    4142:      	bl	0x4042 <_RNvXs_NvNtNtCs6e6HQTixP8o_4core3fmt5Write9write_fmtQNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterNtB4_12SpecWriteFmt14spec_write_fmtBQ_> @ imm = #-0x104
;     }
    4146:      	add	sp, #0x10
    4148:      	pop	{r7, pc}

0000414a <_RNvYNtNtCs2GpT71Ckjdn_10rtt_target3rtt10WriteStateNtNtCs6e6HQTixP8o_4core3cmp9PartialEq2neB6_>:
;     fn ne(&self, other: &Rhs) -> bool {
    414a:      	push	{r7, lr}
    414c:      	mov	r7, sp
    414e:      	sub	sp, #0x8
    4150:      	str	r0, [sp]
    4152:      	str	r1, [sp, #0x4]
;         !self.eq(other)
    4154:      	bl	0x3f46 <_RNvXs5_NtCs2GpT71Ckjdn_10rtt_target3rttNtB5_10WriteStateNtNtCs6e6HQTixP8o_4core3cmp9PartialEq2eqB7_> @ imm = #-0x212
    4158:      	eor	r0, r0, #0x1
;     }
    415c:      	add	sp, #0x8
    415e:      	pop	{r7, pc}

00004160 <_RNvYjNtNtCs6e6HQTixP8o_4core3cmp3Ord3minCs2GpT71Ckjdn_10rtt_target>:
;     fn min(self, other: Self) -> Self
    4160:      	push	{r7, lr}
    4162:      	mov	r7, sp
    4164:      	sub	sp, #0x14
    4166:      	str	r0, [sp]
    4168:      	str	r1, [sp, #0x4]
    416a:      	add	r0, sp, #0x4
    416c:      	str	r0, [sp, #0xc]
    416e:      	mov	r0, sp
    4170:      	str	r0, [sp, #0x10]
;             fn lt(&self, other: &Self) -> bool { *self <  *other }
    4172:      	ldr	r0, [sp, #0x4]
    4174:      	ldr	r1, [sp]
;         if other < self { other } else { self }
    4176:      	cmp	r0, r1
    4178:      	blo	0x4182 <_RNvYjNtNtCs6e6HQTixP8o_4core3cmp3Ord3minCs2GpT71Ckjdn_10rtt_target+0x22> @ imm = #0x6
    417a:      	b	0x417c <_RNvYjNtNtCs6e6HQTixP8o_4core3cmp3Ord3minCs2GpT71Ckjdn_10rtt_target+0x1c> @ imm = #-0x2
    417c:      	ldr	r0, [sp]
    417e:      	str	r0, [sp, #0x8]
;     }
    4180:      	b	0x4188 <_RNvYjNtNtCs6e6HQTixP8o_4core3cmp3Ord3minCs2GpT71Ckjdn_10rtt_target+0x28> @ imm = #0x4
;         if other < self { other } else { self }
    4182:      	ldr	r0, [sp, #0x4]
    4184:      	str	r0, [sp, #0x8]
;     }
    4186:      	b	0x4188 <_RNvYjNtNtCs6e6HQTixP8o_4core3cmp3Ord3minCs2GpT71Ckjdn_10rtt_target+0x28> @ imm = #-0x2
    4188:      	ldr	r0, [sp, #0x8]
    418a:      	add	sp, #0x14
    418c:      	pop	{r7, pc}
    418e:      	bmi	0x413a <_RNvYNtCs2GpT71Ckjdn_10rtt_target14TerminalWriterNtNtCs6e6HQTixP8o_4core3fmt5Write9write_fmtB4_+0x4> @ imm = #-0x58

00004190 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral>:
    4190:      	push	{r4, r5, r6, r7, lr}
    4192:      	add	r7, sp, #0xc
    4194:      	push.w	{r8, r9, r10, r11}
    4198:      	sub	sp, #0x1c
    419a:      	ldr	r5, [r7, #0xc]
    419c:      	mov	r4, r2
    419e:      	mov	r10, r0
    41a0:      	cmp	r1, #0x0
    41a2:      	beq	0x4240 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0xb0> @ imm = #0x9a
    41a4:      	ldr.w	r11, [r10, #0x8]
    41a8:      	movs	r2, #0x2b
    41aa:      	ands	r0, r11, #0x200000
    41ae:      	it	eq
    41b0:      	moveq.w	r2, #0xffffffff
    41b4:      	add.w	r9, r5, r0, lsr #21
    41b8:      	ldr	r0, [r7, #0x8]
    41ba:      	str	r0, [sp, #0x18]
    41bc:      	lsls.w	r0, r11, #0x8
    41c0:      	bpl	0x4254 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0xc4> @ imm = #0x90
    41c2:      	cmp	r3, #0x10
    41c4:      	bhs	0x427c <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0xec> @ imm = #0xb4
    41c6:      	cmp	r3, #0x0
    41c8:      	beq	0x42a6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x116> @ imm = #0xda
    41ca:      	and	r12, r3, #0x3
    41ce:      	lsrs	r0, r3, #0x2
    41d0:      	mov.w	r1, #0x0
    41d4:      	beq	0x42aa <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x11a> @ imm = #0xd2
    41d6:      	and	r0, r0, #0x3
    41da:      	strd	r3, r2, [sp, #12]
    41de:      	add.w	lr, r4, #0x1
    41e2:      	mov	r8, r4
    41e4:      	sub.w	r3, r1, r0, lsl #2
    41e8:      	mvn	r2, #0x3
    41ec:      	movs	r0, #0x0
    41ee:      	str	r5, [sp, #0x14]
    41f0:      	add.w	r5, lr, r2
    41f4:      	adds	r2, #0x4
    41f6:      	ldrsb.w	r6, [r5, #0x3]
    41fa:      	ldrsb.w	r4, [r5, #0x6]
    41fe:      	ldrsb.w	r1, [r5, #0x5]
    4202:      	cmn.w	r6, #0x41
    4206:      	ldrsb.w	r5, [r5, #0x4]
    420a:      	it	gt
    420c:      	addgt	r0, #0x1
    420e:      	cmn.w	r5, #0x41
    4212:      	it	gt
    4214:      	addgt	r0, #0x1
    4216:      	cmn.w	r1, #0x41
    421a:      	it	gt
    421c:      	addgt	r0, #0x1
    421e:      	cmn.w	r4, #0x41
    4222:      	add.w	r1, r3, r2
    4226:      	it	gt
    4228:      	addgt	r0, #0x1
    422a:      	adds	r1, #0x4
    422c:      	bne	0x41f0 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x60> @ imm = #-0x40
    422e:      	cmp.w	r12, #0x0
    4232:      	beq	0x42de <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x14e> @ imm = #0xa8
    4234:      	adds	r1, r2, #0x4
    4236:      	ldr	r5, [sp, #0x14]
    4238:      	ldrd	r3, r2, [sp, #12]
    423c:      	mov	r4, r8
    423e:      	b	0x42ac <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x11c> @ imm = #0x6a
    4240:      	ldr.w	r11, [r10, #0x8]
    4244:      	add.w	r9, r5, #0x1
    4248:      	movs	r2, #0x2d
    424a:      	ldr	r0, [r7, #0x8]
    424c:      	str	r0, [sp, #0x18]
    424e:      	lsls.w	r0, r11, #0x8
    4252:      	bmi	0x41c2 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x32> @ imm = #-0x94
    4254:      	movs	r4, #0x0
    4256:      	ldrh.w	r8, [r10, #0xc]
    425a:      	cmp	r9, r8
    425c:      	blo	0x42f0 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x160> @ imm = #0x90
    425e:      	mov	r8, r5
    4260:      	ldrd	r5, r6, [r10]
    4264:      	str	r3, [sp]
    4266:      	mov	r1, r6
    4268:      	mov	r3, r4
    426a:      	mov	r0, r5
    426c:      	bl	0x4df8 <_RNvNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB7_9Formatter12pad_integral12write_prefix> @ imm = #0xb88
    4270:      	cbz	r0, 0x4292 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x102> @ imm = #0x1e
    4272:      	movs	r0, #0x1
    4274:      	add	sp, #0x1c
    4276:      	pop.w	{r8, r9, r10, r11}
    427a:      	pop	{r4, r5, r6, r7, pc}
    427c:      	mov	r0, r4
    427e:      	mov	r1, r3
    4280:      	mov	r8, r5
    4282:      	mov	r5, r3
    4284:      	mov	r6, r2
    4286:      	bl	0x485c <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars> @ imm = #0x5d2
    428a:      	mov	r3, r5
    428c:      	mov	r2, r6
    428e:      	mov	r5, r8
    4290:      	b	0x42e6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x156> @ imm = #0x52
    4292:      	ldr	r3, [r6, #0xc]
    4294:      	mov	r0, r5
    4296:      	ldr	r1, [sp, #0x18]
    4298:      	mov	r2, r8
    429a:      	add	sp, #0x1c
    429c:      	pop.w	{r8, r9, r10, r11}
    42a0:      	pop.w	{r4, r5, r6, r7, lr}
    42a4:      	bx	r3
    42a6:      	movs	r0, #0x0
    42a8:      	b	0x42e6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x156> @ imm = #0x3a
    42aa:      	movs	r0, #0x0
    42ac:      	ldrsb	r6, [r4, r1]
    42ae:      	cmn.w	r6, #0x41
    42b2:      	it	gt
    42b4:      	addgt	r0, #0x1
    42b6:      	cmp.w	r12, #0x1
    42ba:      	beq	0x42e6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x156> @ imm = #0x28
    42bc:      	add	r1, r4
    42be:      	ldrsb.w	r6, [r1, #0x1]
    42c2:      	cmn.w	r6, #0x41
    42c6:      	it	gt
    42c8:      	addgt	r0, #0x1
    42ca:      	cmp.w	r12, #0x2
    42ce:      	beq	0x42e6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x156> @ imm = #0x14
    42d0:      	ldrsb.w	r1, [r1, #0x2]
    42d4:      	cmn.w	r1, #0x41
    42d8:      	it	gt
    42da:      	addgt	r0, #0x1
    42dc:      	b	0x42e6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x156> @ imm = #0x6
    42de:      	ldr	r5, [sp, #0x14]
    42e0:      	mov	r4, r8
    42e2:      	ldrd	r3, r2, [sp, #12]
    42e6:      	add	r9, r0
    42e8:      	ldrh.w	r8, [r10, #0xc]
    42ec:      	cmp	r9, r8
    42ee:      	bhs	0x425e <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0xce> @ imm = #-0x94
    42f0:      	lsls.w	r0, r11, #0x7
    42f4:      	bmi	0x4342 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x1b2> @ imm = #0x4a
    42f6:      	ubfx	r0, r11, #0x1d, #0x2
    42fa:      	str	r5, [sp, #0x14]
    42fc:      	str	r2, [sp, #0x10]
    42fe:      	sub.w	r5, r8, r9
    4302:      	str	r4, [sp, #0xc]
    4304:      	bfc	r11, #21, #11
    4308:      	mov.w	r9, #0x0
    430c:      	mov	r6, r3
    430e:      	tbb	[pc, r0]
    4312: 03 02 52 02  	.word	0x02520203
    4316:      	mov	r9, r5
    4318:      	str	r5, [sp, #0x8]
    431a:      	lsls.w	r0, r9, #0x10
    431e:      	ldrd	r5, r10, [r10]
    4322:      	beq	0x43c8 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x238> @ imm = #0xa2
    4324:      	ldr.w	r8, [r10, #0x10]
    4328:      	movs	r4, #0x0
    432a:      	mov	r0, r5
    432c:      	mov	r1, r11
    432e:      	blx	r8
    4330:      	cmp	r0, #0x0
    4332:      	bne	0x43e6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x256> @ imm = #0xb0
    4334:      	adds	r4, #0x1
    4336:      	uxth.w	r0, r9
    433a:      	uxth	r1, r4
    433c:      	cmp	r1, r0
    433e:      	blo	0x432a <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x19a> @ imm = #-0x18
    4340:      	b	0x43c8 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x238> @ imm = #0x84
    4342:      	ldrd	r6, r0, [r10, #8]
    4346:      	ldrd	r11, r1, [r10]
    434a:      	str	r0, [sp, #0xc]
    434c:      	movs	r0, #0x0
    434e:      	movt	r0, #0x9fe0
    4352:      	ands	r0, r6
    4354:      	orr	r0, r0, #0x20000000
    4358:      	orr	r0, r0, #0x30
    435c:      	str.w	r0, [r10, #0x8]
    4360:      	str	r3, [sp]
    4362:      	mov	r0, r11
    4364:      	mov	r3, r4
    4366:      	str	r1, [sp, #0x10]
    4368:      	bl	0x4df8 <_RNvNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB7_9Formatter12pad_integral12write_prefix> @ imm = #0xa8c
    436c:      	cbnz	r0, 0x43e6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x256> @ imm = #0x76
    436e:      	str	r6, [sp, #0x8]
    4370:      	uxth.w	r0, r9
    4374:      	cmp	r8, r0
    4376:      	str	r5, [sp, #0x14]
    4378:      	beq	0x4396 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x206> @ imm = #0x1a
    437a:      	ldr	r1, [sp, #0x10]
    437c:      	sub.w	r0, r8, r9
    4380:      	movs	r5, #0x0
    4382:      	uxth	r6, r0
    4384:      	ldr	r4, [r1, #0x10]
    4386:      	mov	r0, r11
    4388:      	movs	r1, #0x30
    438a:      	blx	r4
    438c:      	cbnz	r0, 0x43e6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x256> @ imm = #0x56
    438e:      	adds	r5, #0x1
    4390:      	uxth	r0, r5
    4392:      	cmp	r0, r6
    4394:      	blo	0x4386 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x1f6> @ imm = #-0x12
    4396:      	ldr	r0, [sp, #0x10]
    4398:      	ldrd	r2, r1, [sp, #20]
    439c:      	ldr	r3, [r0, #0xc]
    439e:      	mov	r0, r11
    43a0:      	blx	r3
    43a2:      	cbnz	r0, 0x43e6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x256> @ imm = #0x40
    43a4:      	ldrd	r0, r1, [sp, #8]
    43a8:      	strd	r0, r1, [r10, #8]
    43ac:      	movs	r0, #0x0
    43ae:      	add	sp, #0x1c
    43b0:      	pop.w	{r8, r9, r10, r11}
    43b4:      	pop	{r4, r5, r6, r7, pc}
    43b6:      	uxth	r0, r5
    43b8:      	lsr.w	r9, r0, #0x1
    43bc:      	str	r5, [sp, #0x8]
    43be:      	lsls.w	r0, r9, #0x10
    43c2:      	ldrd	r5, r10, [r10]
    43c6:      	bne	0x4324 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x194> @ imm = #-0xa6
    43c8:      	str	r6, [sp]
    43ca:      	mov	r0, r5
    43cc:      	ldrd	r3, r2, [sp, #12]
    43d0:      	mov	r1, r10
    43d2:      	bl	0x4df8 <_RNvNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB7_9Formatter12pad_integral12write_prefix> @ imm = #0xa22
    43d6:      	cbnz	r0, 0x43e6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x256> @ imm = #0xc
    43d8:      	ldrd	r2, r1, [sp, #20]
    43dc:      	mov	r0, r5
    43de:      	ldr.w	r3, [r10, #0xc]
    43e2:      	blx	r3
    43e4:      	cbz	r0, 0x43f0 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x260> @ imm = #0x8
    43e6:      	movs	r0, #0x1
    43e8:      	add	sp, #0x1c
    43ea:      	pop.w	{r8, r9, r10, r11}
    43ee:      	pop	{r4, r5, r6, r7, pc}
    43f0:      	ldr	r2, [sp, #0x8]
    43f2:      	uxth.w	r0, r9
    43f6:      	uxth	r1, r2
    43f8:      	cmp	r1, r0
    43fa:      	bne	0x4406 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x276> @ imm = #0x8
    43fc:      	movs	r0, #0x0
    43fe:      	add	sp, #0x1c
    4400:      	pop.w	{r8, r9, r10, r11}
    4404:      	pop	{r4, r5, r6, r7, pc}
    4406:      	sub.w	r0, r2, r9
    440a:      	ldr.w	r8, [r10, #0x10]
    440e:      	movs	r4, #0x0
    4410:      	uxth.w	r9, r0
    4414:      	mov	r0, r5
    4416:      	mov	r1, r11
    4418:      	blx	r8
    441a:      	cmp	r0, #0x0
    441c:      	bne.w	0x4274 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0xe4> @ imm = #-0x1ac
    4420:      	adds	r4, #0x1
    4422:      	uxth	r1, r4
    4424:      	cmp	r1, r9
    4426:      	blo	0x4414 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x284> @ imm = #-0x16
    4428:      	b	0x4274 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0xe4> @ imm = #-0x1b8
    442a:      	bmi	0x43d6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral+0x246> @ imm = #-0x58

0000442c <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad>:
    442c:      	push	{r4, r5, r6, r7, lr}
    442e:      	add	r7, sp, #0xc
    4430:      	push.w	{r8, r9, r10, r11}
    4434:      	sub	sp, #0xc
    4436:      	ldr.w	r10, [r0, #0x8]
    443a:      	tst.w	r10, #0x18000000
    443e:      	beq.w	0x45b6 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x18a> @ imm = #0x174
    4442:      	lsls.w	r3, r10, #0x3
    4446:      	bmi	0x44b8 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x8c> @ imm = #0x6e
    4448:      	cmp	r2, #0x10
    444a:      	str	r2, [sp, #0x8]
    444c:      	bhs	0x44fc <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0xd0> @ imm = #0xac
    444e:      	cmp	r2, #0x0
    4450:      	beq	0x4530 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x104> @ imm = #0xdc
    4452:      	and	r12, r2, #0x3
    4456:      	lsrs	r3, r2, #0x2
    4458:      	mov.w	r6, #0x0
    445c:      	beq	0x4536 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x10a> @ imm = #0xd6
    445e:      	and	r3, r3, #0x3
    4462:      	add.w	lr, r1, #0x1
    4466:      	sub.w	r8, r6, r3, lsl #2
    446a:      	mvn	r6, #0x3
    446e:      	movs	r3, #0x0
    4470:      	add.w	r4, lr, r6
    4474:      	adds	r6, #0x4
    4476:      	ldrsb.w	r5, [r4, #0x3]
    447a:      	ldrsb.w	r9, [r4, #0x6]
    447e:      	ldrsb.w	r11, [r4, #0x5]
    4482:      	cmn.w	r5, #0x41
    4486:      	ldrsb.w	r4, [r4, #0x4]
    448a:      	it	gt
    448c:      	addgt	r3, #0x1
    448e:      	cmn.w	r4, #0x41
    4492:      	it	gt
    4494:      	addgt	r3, #0x1
    4496:      	cmn.w	r11, #0x41
    449a:      	it	gt
    449c:      	addgt	r3, #0x1
    449e:      	cmn.w	r9, #0x41
    44a2:      	add.w	r4, r8, r6
    44a6:      	it	gt
    44a8:      	addgt	r3, #0x1
    44aa:      	adds	r4, #0x4
    44ac:      	bne	0x4470 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x44> @ imm = #-0x40
    44ae:      	cmp.w	r12, #0x0
    44b2:      	beq	0x4548 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x11c> @ imm = #0x92
    44b4:      	adds	r6, #0x4
    44b6:      	b	0x4538 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x10c> @ imm = #0x7e
    44b8:      	ldrh.w	r12, [r0, #0xe]
    44bc:      	cmp.w	r12, #0x0
    44c0:      	beq	0x450e <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0xe2> @ imm = #0x4a
    44c2:      	adds	r6, r1, r2
    44c4:      	mov.w	r8, #0x0
    44c8:      	mov	r3, r1
    44ca:      	mov	r2, r12
    44cc:      	b	0x44e2 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0xb6> @ imm = #0x12
    44ce:      	cmp	r3, #0xef
    44d0:      	mov.w	r3, #0x3
    44d4:      	it	hi
    44d6:      	movhi	r3, #0x4
    44d8:      	add	r3, r5
    44da:      	subs	r5, r3, r5
    44dc:      	subs	r2, #0x1
    44de:      	add	r8, r5
    44e0:      	beq	0x4522 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0xf6> @ imm = #0x3e
    44e2:      	cmp	r3, r6
    44e4:      	beq	0x4516 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0xea> @ imm = #0x2e
    44e6:      	mov	r5, r3
    44e8:      	ldrsb	r4, [r3], #1
    44ec:      	cmp.w	r4, #0xffffffff
    44f0:      	bgt	0x44da <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0xae> @ imm = #-0x1a
    44f2:      	uxtb	r3, r4
    44f4:      	cmp	r3, #0xe0
    44f6:      	bhs	0x44ce <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0xa2> @ imm = #-0x2c
    44f8:      	adds	r3, r5, #0x2
    44fa:      	b	0x44da <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0xae> @ imm = #-0x24
    44fc:      	mov	r5, r0
    44fe:      	mov	r4, r1
    4500:      	mov	r0, r1
    4502:      	mov	r1, r2
    4504:      	bl	0x485c <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars> @ imm = #0x354
    4508:      	mov	r3, r0
    450a:      	mov	r0, r5
    450c:      	b	0x456e <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x142> @ imm = #0x5e
    450e:      	mov	r4, r1
    4510:      	movs	r1, #0x0
    4512:      	str	r1, [sp, #0x8]
    4514:      	b	0x4528 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0xfc> @ imm = #0x10
    4516:      	str.w	r8, [sp, #0x8]
    451a:      	mov	r4, r1
    451c:      	sub.w	r3, r12, r2
    4520:      	b	0x456e <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x142> @ imm = #0x4a
    4522:      	mov	r4, r1
    4524:      	str.w	r8, [sp, #0x8]
    4528:      	movs	r2, #0x0
    452a:      	sub.w	r3, r12, r2
    452e:      	b	0x456e <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x142> @ imm = #0x3c
    4530:      	mov	r4, r1
    4532:      	movs	r3, #0x0
    4534:      	b	0x456e <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x142> @ imm = #0x36
    4536:      	movs	r3, #0x0
    4538:      	ldrsb	r5, [r1, r6]
    453a:      	cmn.w	r5, #0x41
    453e:      	it	gt
    4540:      	addgt	r3, #0x1
    4542:      	cmp.w	r12, #0x1
    4546:      	bne	0x454c <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x120> @ imm = #0x2
    4548:      	mov	r4, r1
    454a:      	b	0x456e <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x142> @ imm = #0x20
    454c:      	mov	r4, r1
    454e:      	add	r1, r6
    4550:      	ldrsb.w	r2, [r1, #0x1]
    4554:      	cmn.w	r2, #0x41
    4558:      	it	gt
    455a:      	addgt	r3, #0x1
    455c:      	cmp.w	r12, #0x2
    4560:      	beq	0x456e <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x142> @ imm = #0xa
    4562:      	ldrsb.w	r1, [r1, #0x2]
    4566:      	cmn.w	r1, #0x41
    456a:      	it	gt
    456c:      	addgt	r3, #0x1
    456e:      	ldrh	r1, [r0, #0xc]
    4570:      	cmp	r3, r1
    4572:      	bhs	0x45b2 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x186> @ imm = #0x3c
    4574:      	subs	r3, r1, r3
    4576:      	ubfx	r1, r10, #0x1d, #0x2
    457a:      	bfc	r10, #21, #11
    457e:      	movs	r6, #0x0
    4580:      	tbb	[pc, r1]
    4584: 02 27 2e 02  	.word	0x022e2702
    4588:      	ldrd	r5, r11, [r0]
    458c:      	lsls	r0, r6, #0x10
    458e:      	str	r3, [sp, #0x4]
    4590:      	beq	0x45ee <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x1c2> @ imm = #0x5a
    4592:      	ldr.w	r9, [r11, #0x10]
    4596:      	mov.w	r8, #0x0
    459a:      	mov	r0, r5
    459c:      	mov	r1, r10
    459e:      	blx	r9
    45a0:      	cbnz	r0, 0x45c8 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x19c> @ imm = #0x24
    45a2:      	add.w	r8, r8, #0x1
    45a6:      	uxth	r0, r6
    45a8:      	uxth.w	r1, r8
    45ac:      	cmp	r1, r0
    45ae:      	blo	0x459a <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x16e> @ imm = #-0x18
    45b0:      	b	0x45ee <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x1c2> @ imm = #0x3a
    45b2:      	ldr	r2, [sp, #0x8]
    45b4:      	mov	r1, r4
    45b6:      	ldrd	r0, r3, [r0]
    45ba:      	ldr	r3, [r3, #0xc]
    45bc:      	add	sp, #0xc
    45be:      	pop.w	{r8, r9, r10, r11}
    45c2:      	pop.w	{r4, r5, r6, r7, lr}
    45c6:      	bx	r3
    45c8:      	movs	r0, #0x1
    45ca:      	add	sp, #0xc
    45cc:      	pop.w	{r8, r9, r10, r11}
    45d0:      	pop	{r4, r5, r6, r7, pc}
    45d2:      	mov	r6, r3
    45d4:      	ldrd	r5, r11, [r0]
    45d8:      	lsls	r0, r6, #0x10
    45da:      	str	r3, [sp, #0x4]
    45dc:      	bne	0x4592 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x166> @ imm = #-0x4e
    45de:      	b	0x45ee <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x1c2> @ imm = #0xc
    45e0:      	uxth	r1, r3
    45e2:      	lsrs	r6, r1, #0x1
    45e4:      	ldrd	r5, r11, [r0]
    45e8:      	lsls	r0, r6, #0x10
    45ea:      	str	r3, [sp, #0x4]
    45ec:      	bne	0x4592 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x166> @ imm = #-0x5e
    45ee:      	ldr	r2, [sp, #0x8]
    45f0:      	mov	r0, r5
    45f2:      	ldr.w	r3, [r11, #0xc]
    45f6:      	mov	r1, r4
    45f8:      	blx	r3
    45fa:      	cbz	r0, 0x4606 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x1da> @ imm = #0x8
    45fc:      	movs	r0, #0x1
    45fe:      	add	sp, #0xc
    4600:      	pop.w	{r8, r9, r10, r11}
    4604:      	pop	{r4, r5, r6, r7, pc}
    4606:      	ldr	r2, [sp, #0x4]
    4608:      	uxth	r0, r6
    460a:      	uxth	r1, r2
    460c:      	cmp	r1, r0
    460e:      	bne	0x461a <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x1ee> @ imm = #0x8
    4610:      	movs	r0, #0x0
    4612:      	add	sp, #0xc
    4614:      	pop.w	{r8, r9, r10, r11}
    4618:      	pop	{r4, r5, r6, r7, pc}
    461a:      	subs	r0, r2, r6
    461c:      	ldr.w	r8, [r11, #0x10]
    4620:      	movs	r4, #0x0
    4622:      	uxth	r6, r0
    4624:      	mov	r0, r5
    4626:      	mov	r1, r10
    4628:      	blx	r8
    462a:      	cbnz	r0, 0x4634 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x208> @ imm = #0x6
    462c:      	adds	r4, #0x1
    462e:      	uxth	r1, r4
    4630:      	cmp	r1, r6
    4632:      	blo	0x4624 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad+0x1f8> @ imm = #-0x12
    4634:      	add	sp, #0xc
    4636:      	pop.w	{r8, r9, r10, r11}
    463a:      	pop	{r4, r5, r6, r7, pc}

0000463c <_RNvNtCs6e6HQTixP8o_4core3fmt5write>:
    463c:      	push	{r4, r5, r6, r7, lr}
    463e:      	add	r7, sp, #0xc
    4640:      	push.w	{r8, r9, r10, r11}
    4644:      	sub	sp, #0x14
    4646:      	mov	r6, r0
    4648:      	mov	r11, r3
    464a:      	mov	r10, r1
    464c:      	lsls	r0, r3, #0x1f
    464e:      	bne	0x471a <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0xde> @ imm = #0xc8
    4650:      	ldrb	r5, [r2]
    4652:      	movs	r0, #0x0
    4654:      	cmp	r5, #0x0
    4656:      	beq	0x4736 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0xfa> @ imm = #0xdc
    4658:      	ldr.w	r9, [r10, #0xc]
    465c:      	mov.w	r8, #0x0
    4660:      	b	0x4668 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0x2c> @ imm = #0x4
    4662:      	ldrb	r5, [r2]
    4664:      	cmp	r5, #0x0
    4666:      	beq	0x473e <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0x102> @ imm = #0xd4
    4668:      	adds	r4, r2, #0x1
    466a:      	sxtb	r0, r5
    466c:      	cmp.w	r0, #0xffffffff
    4670:      	ble	0x4682 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0x46> @ imm = #0xe
    4672:      	mov	r0, r6
    4674:      	mov	r1, r4
    4676:      	mov	r2, r5
    4678:      	blx	r9
    467a:      	cmp	r0, #0x0
    467c:      	bne	0x4734 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0xf8> @ imm = #0xb4
    467e:      	adds	r2, r4, r5
    4680:      	b	0x4662 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0x26> @ imm = #-0x22
    4682:      	cmp	r5, #0x80
    4684:      	beq	0x469a <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0x5e> @ imm = #0x12
    4686:      	cmp	r5, #0xc0
    4688:      	bne	0x46b0 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0x74> @ imm = #0x24
    468a:      	ldr.w	r0, [r11, r8, lsl #3]
    468e:      	movs	r1, #0x0
    4690:      	str	r1, [sp, #0x10]
    4692:      	movs	r1, #0x20
    4694:      	movt	r1, #0x6000
    4698:      	b	0x46fe <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0xc2> @ imm = #0x62
    469a:      	ldrh.w	r4, [r2, #0x1]
    469e:      	adds	r5, r2, #0x3
    46a0:      	mov	r0, r6
    46a2:      	mov	r1, r5
    46a4:      	mov	r2, r4
    46a6:      	blx	r9
    46a8:      	cmp	r0, #0x0
    46aa:      	bne	0x4734 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0xf8> @ imm = #0x86
    46ac:      	adds	r2, r5, r4
    46ae:      	b	0x4662 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0x26> @ imm = #-0x50
    46b0:      	lsls	r0, r5, #0x1f
    46b2:      	bne	0x46bc <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0x80> @ imm = #0x6
    46b4:      	movs	r1, #0x20
    46b6:      	movt	r1, #0x6000
    46ba:      	b	0x46c2 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0x86> @ imm = #0x4
    46bc:      	ldr.w	r1, [r2, #0x1]
    46c0:      	adds	r4, r2, #0x5
    46c2:      	lsls	r0, r5, #0x1e
    46c4:      	ite	mi
    46c6:      	ldrhmi	r2, [r4], #2
    46ca:      	movpl	r2, #0x0
    46cc:      	lsls	r0, r5, #0x1d
    46ce:      	ite	mi
    46d0:      	ldrhmi	r3, [r4], #2
    46d4:      	movpl	r3, #0x0
    46d6:      	lsls	r0, r5, #0x1c
    46d8:      	it	mi
    46da:      	ldrhmi	r8, [r4], #2
    46de:      	lsls	r0, r5, #0x1b
    46e0:      	itt	mi
    46e2:      	addmi.w	r0, r11, r2, lsl #3
    46e6:      	ldrhmi	r2, [r0, #0x4]
    46e8:      	lsls	r0, r5, #0x1a
    46ea:      	itt	mi
    46ec:      	addmi.w	r0, r11, r3, lsl #3
    46f0:      	ldrhmi	r3, [r0, #0x4]
    46f2:      	ldr.w	r0, [r11, r8, lsl #3]
    46f6:      	strh.w	r3, [sp, #0x12]
    46fa:      	strh.w	r2, [sp, #0x10]
    46fe:      	str	r1, [sp, #0xc]
    4700:      	add.w	r1, r11, r8, lsl #3
    4704:      	str.w	r10, [sp, #0x8]
    4708:      	ldr	r2, [r1, #0x4]
    470a:      	add	r1, sp, #0x4
    470c:      	str	r6, [sp, #0x4]
    470e:      	blx	r2
    4710:      	cbnz	r0, 0x4734 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0xf8> @ imm = #0x20
    4712:      	add.w	r8, r8, #0x1
    4716:      	mov	r2, r4
    4718:      	b	0x4662 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0x26> @ imm = #-0xba
    471a:      	lsr.w	r3, r11, #0x1
    471e:      	mov	r1, r2
    4720:      	ldr.w	r12, [r10, #0xc]
    4724:      	mov	r0, r6
    4726:      	mov	r2, r3
    4728:      	add	sp, #0x14
    472a:      	pop.w	{r8, r9, r10, r11}
    472e:      	pop.w	{r4, r5, r6, r7, lr}
    4732:      	bx	r12
    4734:      	movs	r0, #0x1
    4736:      	add	sp, #0x14
    4738:      	pop.w	{r8, r9, r10, r11}
    473c:      	pop	{r4, r5, r6, r7, pc}
    473e:      	movs	r0, #0x0
    4740:      	add	sp, #0x14
    4742:      	pop.w	{r8, r9, r10, r11}
    4746:      	pop	{r4, r5, r6, r7, pc}

00004748 <_RNvNtCs6e6HQTixP8o_4core4cell22panic_already_borrowed>:
    4748:      	push	{r7, lr}
    474a:      	mov	r7, sp
    474c:      	sub	sp, #0x10
    474e:      	mov	r2, r0
    4750:      	movw	r0, #0x5103
    4754:      	movt	r0, #0x0
    4758:      	add	r1, sp, #0x4
    475a:      	str	r0, [sp, #0x8]
    475c:      	subs	r0, r7, #0x1
    475e:      	str	r0, [sp, #0x4]
    4760:      	movw	r0, #0x5689
    4764:      	movt	r0, #0x0
    4768:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0xd4

0000476c <_RNvNtCs6e6HQTixP8o_4core6option13unwrap_failed>:
    476c:      	push	{r7, lr}
    476e:      	mov	r7, sp
    4770:      	mov	r2, r0
    4772:      	movw	r0, #0x6794
    4776:      	movt	r0, #0x0
    477a:      	movs	r1, #0x2b
    477c:      	bl	0x4834 <_RNvNtCs6e6HQTixP8o_4core9panicking5panic> @ imm = #0xb4

00004780 <_RNvNtCs6e6HQTixP8o_4core9panicking14panic_nounwind>:
    4780:      	push	{r7, lr}
    4782:      	mov	r7, sp
    4784:      	lsls	r1, r1, #0x1
    4786:      	movw	r3, #0x67c0
    478a:      	adds	r1, #0x1
    478c:      	movt	r3, #0x0
    4790:      	movs	r2, #0x0
    4792:      	bl	0x47c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt> @ imm = #0x2a
    4796:      	bmi	0x4742 <_RNvNtCs6e6HQTixP8o_4core3fmt5write+0x106> @ imm = #-0x58

00004798 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_bounds_check>:
    4798:      	push	{r1, r2, r3, r4, r5, r6, r7, lr}
    479a:      	add	r7, sp, #0x18
    479c:      	strd	r0, r1, [sp]
    47a0:      	mov	r1, sp
    47a2:      	ldr	r0, [pc, #0x14]         @ 0x47b8 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_bounds_check+0x20>
    47a4:      	strd	r0, r1, [sp, #12]
    47a8:      	add	r1, sp, #0x8
    47aa:      	str	r0, [sp, #0x14]
    47ac:      	add	r0, sp, #0x4
    47ae:      	str	r0, [sp, #0x8]
    47b0:      	ldr	r0, [pc, #0x8]          @ 0x47bc <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_bounds_check+0x24>
    47b2:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x8a
    47b6:      	nop
    47b8: 6d 4f 00 00  	.word	0x00004f6d
    47bc: a3 57 00 00  	.word	0x000057a3

000047c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt>:
    47c0:      	push	{r7, lr}
    47c2:      	mov	r7, sp
    47c4:      	sub	sp, #0x18
    47c6:      	strd	r0, r1, [sp, #4]
    47ca:      	movs	r0, #0x0
    47cc:      	strb.w	r0, [sp, #0x14]
    47d0:      	add	r0, sp, #0x4
    47d2:      	str	r0, [sp, #0xc]
    47d4:      	add	r0, sp, #0xc
    47d6:      	strb.w	r2, [sp, #0x15]
    47da:      	str	r3, [sp, #0x10]
    47dc:      	bl	0x2e0e <_RNvCsbj5FHA3exiX_7___rustc17rust_begin_unwind> @ imm = #-0x19d2

000047e0 <_RNvNtCs6e6HQTixP8o_4core9panicking30panic_null_pointer_dereference>:
    47e0:      	push	{r7, lr}
    47e2:      	mov	r7, sp
    47e4:      	mov	r3, r0
    47e6:      	ldr	r0, [pc, #0x8]          @ 0x47f0 <_RNvNtCs6e6HQTixP8o_4core9panicking30panic_null_pointer_dereference+0x10>
    47e8:      	movs	r1, #0x43
    47ea:      	movs	r2, #0x0
    47ec:      	bl	0x47c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt> @ imm = #-0x30
    47f0: d0 67 00 00  	.word	0x000067d0

000047f4 <_RNvNtCs6e6HQTixP8o_4core9panicking32panic_null_reference_constructed>:
    47f4:      	push	{r7, lr}
    47f6:      	mov	r7, sp
    47f8:      	mov	r3, r0
    47fa:      	ldr	r0, [pc, #0x8]          @ 0x4804 <_RNvNtCs6e6HQTixP8o_4core9panicking32panic_null_reference_constructed+0x10>
    47fc:      	movs	r1, #0x2f
    47fe:      	movs	r2, #0x0
    4800:      	bl	0x47c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt> @ imm = #-0x44
    4804: f1 67 00 00  	.word	0x000067f1

00004808 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference>:
    4808:      	push	{r1, r2, r3, r4, r5, r6, r7, lr}
    480a:      	add	r7, sp, #0x18
    480c:      	strd	r0, r1, [sp]
    4810:      	add	r1, sp, #0x4
    4812:      	ldr	r0, [pc, #0x18]         @ 0x482c <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference+0x24>
    4814:      	mov	r3, r2
    4816:      	strd	r0, r1, [sp, #12]
    481a:      	add	r1, sp, #0x8
    481c:      	str	r0, [sp, #0x14]
    481e:      	mov	r0, sp
    4820:      	str	r0, [sp, #0x8]
    4822:      	movs	r2, #0x0
    4824:      	ldr	r0, [pc, #0x8]          @ 0x4830 <_RNvNtCs6e6HQTixP8o_4core9panicking36panic_misaligned_pointer_dereference+0x28>
    4826:      	bl	0x47c0 <_RNvNtCs6e6HQTixP8o_4core9panicking18panic_nounwind_fmt> @ imm = #-0x6a
    482a:      	nop
    482c: 51 4e 00 00  	.word	0x00004e51
    4830: 08 68 00 00  	.word	0x00006808

00004834 <_RNvNtCs6e6HQTixP8o_4core9panicking5panic>:
    4834:      	push	{r7, lr}
    4836:      	mov	r7, sp
    4838:      	lsls	r1, r1, #0x1
    483a:      	adds	r1, #0x1
    483c:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #0x0

00004840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt>:
    4840:      	push	{r7, lr}
    4842:      	mov	r7, sp
    4844:      	sub	sp, #0x18
    4846:      	strd	r0, r1, [sp, #4]
    484a:      	movs	r0, #0x1
    484c:      	strh.w	r0, [sp, #0x14]
    4850:      	add	r0, sp, #0x4
    4852:      	str	r0, [sp, #0xc]
    4854:      	add	r0, sp, #0xc
    4856:      	str	r2, [sp, #0x10]
    4858:      	bl	0x2e0e <_RNvCsbj5FHA3exiX_7___rustc17rust_begin_unwind> @ imm = #-0x1a4e

0000485c <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars>:
    485c:      	push	{r4, r5, r6, r7, lr}
    485e:      	add	r7, sp, #0xc
    4860:      	push.w	{r8, r9, r10, r11}
    4864:      	sub	sp, #0x8
    4866:      	mov	r11, r0
    4868:      	adds	r0, #0x3
    486a:      	bic	r0, r0, #0x3
    486e:      	sub.w	r10, r0, r11
    4872:      	cmp	r1, r10
    4874:      	bhs	0x48de <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x82> @ imm = #0x66
    4876:      	cmp	r1, #0x0
    4878:      	beq	0x4904 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0xa8> @ imm = #0x88
    487a:      	and	r12, r1, #0x3
    487e:      	lsrs	r0, r1, #0x2
    4880:      	mov.w	r1, #0x0
    4884:      	beq.w	0x4d06 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x4aa> @ imm = #0x47e
    4888:      	sub.w	r6, r1, r0, lsl #2
    488c:      	add.w	lr, r11, #0x1
    4890:      	mvn	r1, #0x3
    4894:      	movs	r0, #0x0
    4896:      	add.w	r2, lr, r1
    489a:      	adds	r1, #0x4
    489c:      	ldrsb.w	r3, [r2, #0x3]
    48a0:      	ldrsb.w	r4, [r2, #0x6]
    48a4:      	ldrsb.w	r5, [r2, #0x5]
    48a8:      	cmn.w	r3, #0x41
    48ac:      	ldrsb.w	r2, [r2, #0x4]
    48b0:      	it	gt
    48b2:      	addgt	r0, #0x1
    48b4:      	cmn.w	r2, #0x41
    48b8:      	it	gt
    48ba:      	addgt	r0, #0x1
    48bc:      	cmn.w	r5, #0x41
    48c0:      	it	gt
    48c2:      	addgt	r0, #0x1
    48c4:      	cmn.w	r4, #0x41
    48c8:      	add.w	r2, r6, r1
    48cc:      	it	gt
    48ce:      	addgt	r0, #0x1
    48d0:      	adds	r2, #0x4
    48d2:      	bne	0x4896 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x3a> @ imm = #-0x40
    48d4:      	cmp.w	r12, #0x0
    48d8:      	beq	0x4906 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0xaa> @ imm = #0x2a
    48da:      	adds	r1, #0x4
    48dc:      	b	0x4d08 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x4ac> @ imm = #0x428
    48de:      	sub.w	r8, r1, r10
    48e2:      	lsrs.w	r9, r8, #0x2
    48e6:      	beq	0x4876 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x1a> @ imm = #-0x74
    48e8:      	and	lr, r8, #0x3
    48ec:      	cmp	r0, r11
    48ee:      	bne	0x48f4 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x98> @ imm = #0x2
    48f0:      	movs	r0, #0x0
    48f2:      	b	0x498c <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x130> @ imm = #0x96
    48f4:      	sub.w	r0, r11, r0
    48f8:      	cmn.w	r0, #0x4
    48fc:      	bls	0x490e <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0xb2> @ imm = #0xe
    48fe:      	movs	r6, #0x0
    4900:      	movs	r0, #0x0
    4902:      	b	0x4958 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0xfc> @ imm = #0x52
    4904:      	movs	r0, #0x0
    4906:      	add	sp, #0x8
    4908:      	pop.w	{r8, r9, r10, r11}
    490c:      	pop	{r4, r5, r6, r7, pc}
    490e:      	add.w	r12, r11, #0x1
    4912:      	movs	r0, #0x0
    4914:      	mvn	r1, #0x3
    4918:      	add.w	r6, r12, r1
    491c:      	ldrsb.w	r5, [r6, #0x3]
    4920:      	ldrsb.w	r2, [r6, #0x6]
    4924:      	ldrsb.w	r4, [r6, #0x5]
    4928:      	cmn.w	r5, #0x41
    492c:      	ldrsb.w	r6, [r6, #0x4]
    4930:      	it	gt
    4932:      	addgt	r0, #0x1
    4934:      	cmn.w	r6, #0x41
    4938:      	it	gt
    493a:      	addgt	r0, #0x1
    493c:      	cmn.w	r4, #0x41
    4940:      	it	gt
    4942:      	addgt	r0, #0x1
    4944:      	cmn.w	r2, #0x41
    4948:      	add.w	r2, r1, #0x4
    494c:      	it	gt
    494e:      	addgt	r0, #0x1
    4950:      	adds.w	r6, r1, #0x8
    4954:      	mov	r1, r2
    4956:      	bne	0x4918 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0xbc> @ imm = #-0x42
    4958:      	ldrsb.w	r1, [r11, r6]
    495c:      	cmn.w	r1, #0x41
    4960:      	it	gt
    4962:      	addgt	r0, #0x1
    4964:      	cmp.w	r10, #0x1
    4968:      	beq	0x498c <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x130> @ imm = #0x20
    496a:      	add.w	r1, r11, r6
    496e:      	ldrsb.w	r2, [r1, #0x1]
    4972:      	cmn.w	r2, #0x41
    4976:      	it	gt
    4978:      	addgt	r0, #0x1
    497a:      	cmp.w	r10, #0x2
    497e:      	beq	0x498c <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x130> @ imm = #0xa
    4980:      	ldrsb.w	r1, [r1, #0x2]
    4984:      	cmn.w	r1, #0x41
    4988:      	it	gt
    498a:      	addgt	r0, #0x1
    498c:      	movw	r1, #0xfffc
    4990:      	add.w	r2, r11, r10
    4994:      	movt	r1, #0x1fff
    4998:      	movs	r5, #0x0
    499a:      	cmp.w	lr, #0x0
    499e:      	beq	0x49da <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x17e> @ imm = #0x38
    49a0:      	add.w	r1, r1, #0x60000000
    49a4:      	and.w	r1, r1, r8
    49a8:      	add	r1, r2
    49aa:      	ldrsb.w	r4, [r1]
    49ae:      	cmn.w	r4, #0x41
    49b2:      	it	gt
    49b4:      	movgt	r5, #0x1
    49b6:      	cmp.w	lr, #0x1
    49ba:      	beq	0x49da <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x17e> @ imm = #0x1c
    49bc:      	ldrsb.w	r4, [r1, #0x1]
    49c0:      	cmn.w	r4, #0x41
    49c4:      	it	gt
    49c6:      	addgt	r5, #0x1
    49c8:      	cmp.w	lr, #0x2
    49cc:      	beq	0x49da <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x17e> @ imm = #0xa
    49ce:      	ldrsb.w	r1, [r1, #0x2]
    49d2:      	cmn.w	r1, #0x41
    49d6:      	it	gt
    49d8:      	addgt	r5, #0x1
    49da:      	add	r0, r5
    49dc:      	mov.w	r10, #0x1
    49e0:      	b	0x4a06 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x1aa> @ imm = #0x22
    49e2:      	movs	r5, #0x0
    49e4:      	uxtb16	r3, r5
    49e8:      	uxtb16	r6, r5, ror #8
    49ec:      	add	r3, r6
    49ee:      	sub.w	r9, r9, r11
    49f2:      	add.w	r2, lr, r11, lsl #2
    49f6:      	ands	r1, r11, #0x3
    49fa:      	add.w	r3, r3, r3, lsl #16
    49fe:      	add.w	r0, r0, r3, lsr #16
    4a02:      	bne.w	0x4ca4 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x448> @ imm = #0x29e
    4a06:      	cmp.w	r9, #0x0
    4a0a:      	beq.w	0x4906 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0xaa> @ imm = #-0x108
    4a0e:      	mov	lr, r2
    4a10:      	cmp.w	r9, #0xc0
    4a14:      	mov	r11, r9
    4a16:      	it	hs
    4a18:      	movhs.w	r11, #0xc0
    4a1c:      	cmp.w	r9, #0x4
    4a20:      	blo	0x49e2 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x186> @ imm = #-0x42
    4a22:      	mvn	r1, #0xf
    4a26:      	add.w	r2, r1, r11, lsl #2
    4a2a:      	cmp	r2, #0x30
    4a2c:      	add.w	r1, r10, r2, lsr #4
    4a30:      	and	r8, r1, #0x3
    4a34:      	bhs	0x4a3c <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x1e0> @ imm = #0x4
    4a36:      	movs	r5, #0x0
    4a38:      	mov	r6, lr
    4a3a:      	b	0x4bb6 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x35a> @ imm = #0x178
    4a3c:      	movw	r2, #0xfffc
    4a40:      	movs	r5, #0x0
    4a42:      	movt	r2, #0x1fff
    4a46:      	and.w	r10, r1, r2
    4a4a:      	mov	r6, lr
    4a4c:      	str.w	r8, [sp]
    4a50:      	str.w	lr, [sp, #0x4]
    4a54:      	ldm.w	r6, {r2, r3, r12, lr}
    4a58:      	subs.w	r10, r10, #0x4
    4a5c:      	ldr	r1, [r6, #0x14]
    4a5e:      	mvn.w	r8, r2
    4a62:      	lsr.w	r4, r8, #0x7
    4a66:      	orr.w	r2, r4, r2, lsr #6
    4a6a:      	mvn.w	r4, r3
    4a6e:      	bic	r2, r2, #0xfefefefe
    4a72:      	lsr.w	r4, r4, #0x7
    4a76:      	orr.w	r3, r4, r3, lsr #6
    4a7a:      	add	r2, r5
    4a7c:      	bic	r3, r3, #0xfefefefe
    4a80:      	add	r3, r2
    4a82:      	mvn.w	r2, r12
    4a86:      	lsr.w	r4, r2, #0x7
    4a8a:      	ldr	r5, [r6, #0x10]
    4a8c:      	orr.w	r4, r4, r12, lsr #6
    4a90:      	ldr	r2, [r6, #0x38]
    4a92:      	bic	r4, r4, #0xfefefefe
    4a96:      	ldr.w	r8, [r6, #0x3c]
    4a9a:      	add	r3, r4
    4a9c:      	mvn.w	r4, lr
    4aa0:      	lsr.w	r4, r4, #0x7
    4aa4:      	orr.w	r4, r4, lr, lsr #6
    4aa8:      	bic	r4, r4, #0xfefefefe
    4aac:      	add.w	r12, r4, r3
    4ab0:      	mvn.w	r4, r5
    4ab4:      	lsr.w	r4, r4, #0x7
    4ab8:      	orr.w	r5, r4, r5, lsr #6
    4abc:      	ldr	r3, [r6, #0x18]
    4abe:      	mvn.w	r4, r1
    4ac2:      	bic	r5, r5, #0xfefefefe
    4ac6:      	lsr.w	r4, r4, #0x7
    4aca:      	orr.w	r1, r4, r1, lsr #6
    4ace:      	add	r12, r5
    4ad0:      	ldr	r5, [r6, #0x1c]
    4ad2:      	mvn.w	r4, r3
    4ad6:      	bic	r1, r1, #0xfefefefe
    4ada:      	lsr.w	r4, r4, #0x7
    4ade:      	orr.w	r3, r4, r3, lsr #6
    4ae2:      	add	r12, r1
    4ae4:      	ldr	r1, [r6, #0x20]
    4ae6:      	mvn.w	r4, r5
    4aea:      	bic	r3, r3, #0xfefefefe
    4aee:      	lsr.w	r4, r4, #0x7
    4af2:      	orr.w	r5, r4, r5, lsr #6
    4af6:      	add	r12, r3
    4af8:      	ldr	r3, [r6, #0x24]
    4afa:      	mvn.w	r4, r1
    4afe:      	bic	r5, r5, #0xfefefefe
    4b02:      	lsr.w	r4, r4, #0x7
    4b06:      	orr.w	r1, r4, r1, lsr #6
    4b0a:      	add	r12, r5
    4b0c:      	ldr	r5, [r6, #0x28]
    4b0e:      	mvn.w	r4, r3
    4b12:      	bic	r1, r1, #0xfefefefe
    4b16:      	lsr.w	r4, r4, #0x7
    4b1a:      	orr.w	r3, r4, r3, lsr #6
    4b1e:      	add	r12, r1
    4b20:      	ldr	r1, [r6, #0x2c]
    4b22:      	mvn.w	r4, r5
    4b26:      	bic	r3, r3, #0xfefefefe
    4b2a:      	lsr.w	r4, r4, #0x7
    4b2e:      	add	r12, r3
    4b30:      	ldr	r3, [r6, #0x30]
    4b32:      	orr.w	r5, r4, r5, lsr #6
    4b36:      	mvn.w	r4, r1
    4b3a:      	bic	r5, r5, #0xfefefefe
    4b3e:      	lsr.w	r4, r4, #0x7
    4b42:      	orr.w	r1, r4, r1, lsr #6
    4b46:      	mvn.w	r4, r3
    4b4a:      	add	r12, r5
    4b4c:      	ldr	r5, [r6, #0x34]
    4b4e:      	bic	r1, r1, #0xfefefefe
    4b52:      	lsr.w	r4, r4, #0x7
    4b56:      	orr.w	r3, r4, r3, lsr #6
    4b5a:      	add	r1, r12
    4b5c:      	bic	r3, r3, #0xfefefefe
    4b60:      	add.w	r6, r6, #0x40
    4b64:      	add	r1, r3
    4b66:      	mvn.w	r3, r5
    4b6a:      	lsr.w	r3, r3, #0x7
    4b6e:      	orr.w	r3, r3, r5, lsr #6
    4b72:      	bic	r3, r3, #0xfefefefe
    4b76:      	add	r1, r3
    4b78:      	mvn.w	r3, r2
    4b7c:      	lsr.w	r3, r3, #0x7
    4b80:      	orr.w	r2, r3, r2, lsr #6
    4b84:      	bic	r2, r2, #0xfefefefe
    4b88:      	add	r1, r2
    4b8a:      	mvn.w	r2, r8
    4b8e:      	lsr.w	r2, r2, #0x7
    4b92:      	orr.w	r2, r2, r8, lsr #6
    4b96:      	bic	r2, r2, #0xfefefefe
    4b9a:      	add.w	r5, r2, r1
    4b9e:      	bne.w	0x4a54 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x1f8> @ imm = #-0x14e
    4ba2:      	ldr.w	r8, [sp]
    4ba6:      	mov.w	r10, #0x1
    4baa:      	ldr.w	lr, [sp, #0x4]
    4bae:      	cmp.w	r8, #0x0
    4bb2:      	beq.w	0x49e4 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x188> @ imm = #-0x1d2
    4bb6:      	ldm.w	r6, {r1, r2, r3, r12}
    4bba:      	cmp.w	r8, #0x1
    4bbe:      	mvn.w	r4, r1
    4bc2:      	lsr.w	r4, r4, #0x7
    4bc6:      	orr.w	r1, r4, r1, lsr #6
    4bca:      	bic	r1, r1, #0xfefefefe
    4bce:      	add	r1, r5
    4bd0:      	mvn.w	r5, r2
    4bd4:      	lsr.w	r5, r5, #0x7
    4bd8:      	orr.w	r2, r5, r2, lsr #6
    4bdc:      	bic	r2, r2, #0xfefefefe
    4be0:      	add	r1, r2
    4be2:      	mvn.w	r2, r3
    4be6:      	lsr.w	r2, r2, #0x7
    4bea:      	orr.w	r2, r2, r3, lsr #6
    4bee:      	bic	r2, r2, #0xfefefefe
    4bf2:      	add	r1, r2
    4bf4:      	mvn.w	r2, r12
    4bf8:      	lsr.w	r2, r2, #0x7
    4bfc:      	orr.w	r2, r2, r12, lsr #6
    4c00:      	bic	r2, r2, #0xfefefefe
    4c04:      	add.w	r5, r2, r1
    4c08:      	beq.w	0x49e4 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x188> @ imm = #-0x228
    4c0c:      	add.w	r12, r6, #0x10
    4c10:      	cmp.w	r8, #0x2
    4c14:      	ldm.w	r12, {r1, r2, r3, r12}
    4c18:      	mvn.w	r4, r1
    4c1c:      	lsr.w	r4, r4, #0x7
    4c20:      	orr.w	r1, r4, r1, lsr #6
    4c24:      	bic	r1, r1, #0xfefefefe
    4c28:      	add	r1, r5
    4c2a:      	mvn.w	r5, r2
    4c2e:      	lsr.w	r5, r5, #0x7
    4c32:      	orr.w	r2, r5, r2, lsr #6
    4c36:      	bic	r2, r2, #0xfefefefe
    4c3a:      	add	r1, r2
    4c3c:      	mvn.w	r2, r3
    4c40:      	lsr.w	r2, r2, #0x7
    4c44:      	orr.w	r2, r2, r3, lsr #6
    4c48:      	bic	r2, r2, #0xfefefefe
    4c4c:      	add	r1, r2
    4c4e:      	mvn.w	r2, r12
    4c52:      	lsr.w	r2, r2, #0x7
    4c56:      	orr.w	r2, r2, r12, lsr #6
    4c5a:      	bic	r2, r2, #0xfefefefe
    4c5e:      	add.w	r5, r2, r1
    4c62:      	beq.w	0x49e4 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x188> @ imm = #-0x282
    4c66:      	adds	r6, #0x20
    4c68:      	ldm	r6, {r1, r2, r3, r6}
    4c6a:      	mvns	r4, r1
    4c6c:      	lsrs	r4, r4, #0x7
    4c6e:      	orr.w	r1, r4, r1, lsr #6
    4c72:      	bic	r1, r1, #0xfefefefe
    4c76:      	add	r1, r5
    4c78:      	mvns	r5, r2
    4c7a:      	lsrs	r5, r5, #0x7
    4c7c:      	orr.w	r2, r5, r2, lsr #6
    4c80:      	bic	r2, r2, #0xfefefefe
    4c84:      	add	r1, r2
    4c86:      	mvns	r2, r3
    4c88:      	lsrs	r2, r2, #0x7
    4c8a:      	orr.w	r2, r2, r3, lsr #6
    4c8e:      	bic	r2, r2, #0xfefefefe
    4c92:      	add	r1, r2
    4c94:      	mvns	r2, r6
    4c96:      	lsrs	r2, r2, #0x7
    4c98:      	orr.w	r2, r2, r6, lsr #6
    4c9c:      	bic	r2, r2, #0xfefefefe
    4ca0:      	adds	r5, r2, r1
    4ca2:      	b	0x49e4 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x188> @ imm = #-0x2c2
    4ca4:      	and	r3, r11, #0xfc
    4ca8:      	cmp	r1, #0x1
    4caa:      	ldr.w	r2, [lr, r3, lsl #2]
    4cae:      	mvn.w	r6, r2
    4cb2:      	lsr.w	r6, r6, #0x7
    4cb6:      	orr.w	r2, r6, r2, lsr #6
    4cba:      	bic	r2, r2, #0xfefefefe
    4cbe:      	beq	0x4cec <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x490> @ imm = #0x2a
    4cc0:      	add.w	r3, lr, r3, lsl #2
    4cc4:      	cmp	r1, #0x2
    4cc6:      	ldr	r6, [r3, #0x4]
    4cc8:      	mvn.w	r5, r6
    4ccc:      	lsr.w	r5, r5, #0x7
    4cd0:      	orr.w	r6, r5, r6, lsr #6
    4cd4:      	bic	r6, r6, #0xfefefefe
    4cd8:      	add	r2, r6
    4cda:      	beq	0x4cec <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0x490> @ imm = #0xe
    4cdc:      	ldr	r1, [r3, #0x8]
    4cde:      	mvns	r3, r1
    4ce0:      	lsrs	r3, r3, #0x7
    4ce2:      	orr.w	r1, r3, r1, lsr #6
    4ce6:      	bic	r1, r1, #0xfefefefe
    4cea:      	add	r2, r1
    4cec:      	uxtb16	r1, r2
    4cf0:      	uxtb16	r2, r2, ror #8
    4cf4:      	add	r1, r2
    4cf6:      	add.w	r1, r1, r1, lsl #16
    4cfa:      	add.w	r0, r0, r1, lsr #16
    4cfe:      	add	sp, #0x8
    4d00:      	pop.w	{r8, r9, r10, r11}
    4d04:      	pop	{r4, r5, r6, r7, pc}
    4d06:      	movs	r0, #0x0
    4d08:      	ldrsb.w	r2, [r11, r1]
    4d0c:      	cmn.w	r2, #0x41
    4d10:      	it	gt
    4d12:      	addgt	r0, #0x1
    4d14:      	cmp.w	r12, #0x1
    4d18:      	beq.w	0x4906 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0xaa> @ imm = #-0x416
    4d1c:      	add	r1, r11
    4d1e:      	ldrsb.w	r2, [r1, #0x1]
    4d22:      	cmn.w	r2, #0x41
    4d26:      	it	gt
    4d28:      	addgt	r0, #0x1
    4d2a:      	cmp.w	r12, #0x2
    4d2e:      	beq.w	0x4906 <_RNvNtNtCs6e6HQTixP8o_4core3str5count14do_count_chars+0xaa> @ imm = #-0x42c
    4d32:      	ldrsb.w	r1, [r1, #0x2]
    4d36:      	cmn.w	r1, #0x41
    4d3a:      	it	gt
    4d3c:      	addgt	r0, #0x1
    4d3e:      	add	sp, #0x8
    4d40:      	pop.w	{r8, r9, r10, r11}
    4d44:      	pop	{r4, r5, r6, r7, pc}

00004d46 <_RNvNtNtCs6e6HQTixP8o_4core5slice5index16slice_index_fail>:
    4d46:      	push	{r7, lr}
    4d48:      	mov	r7, sp
    4d4a:      	sub	sp, #0x18
    4d4c:      	cmp	r0, r2
    4d4e:      	bls	0x4d78 <_RNvNtNtCs6e6HQTixP8o_4core5slice5index16slice_index_fail+0x32> @ imm = #0x26
    4d50:      	strd	r0, r2, [sp]
    4d54:      	movw	r0, #0x4f6d
    4d58:      	add	r1, sp, #0x4
    4d5a:      	movt	r0, #0x0
    4d5e:      	str	r0, [sp, #0x14]
    4d60:      	strd	r0, r1, [sp, #12]
    4d64:      	mov	r0, sp
    4d66:      	str	r0, [sp, #0x8]
    4d68:      	movw	r0, #0x59c9
    4d6c:      	movt	r0, #0x0
    4d70:      	add	r1, sp, #0x8
    4d72:      	mov	r2, r3
    4d74:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #-0x538
    4d78:      	cmp	r1, r2
    4d7a:      	bhi	0x4da8 <_RNvNtNtCs6e6HQTixP8o_4core5slice5index16slice_index_fail+0x62> @ imm = #0x2a
    4d7c:      	cmp	r0, r1
    4d7e:      	bls	0x4da8 <_RNvNtNtCs6e6HQTixP8o_4core5slice5index16slice_index_fail+0x62> @ imm = #0x26
    4d80:      	strd	r0, r1, [sp]
    4d84:      	movw	r0, #0x4f6d
    4d88:      	add	r1, sp, #0x4
    4d8a:      	movt	r0, #0x0
    4d8e:      	str	r0, [sp, #0x14]
    4d90:      	strd	r0, r1, [sp, #12]
    4d94:      	mov	r0, sp
    4d96:      	str	r0, [sp, #0x8]
    4d98:      	movw	r0, #0x568b
    4d9c:      	movt	r0, #0x0
    4da0:      	add	r1, sp, #0x8
    4da2:      	mov	r2, r3
    4da4:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #-0x568
    4da8:      	movw	r0, #0x4f6d
    4dac:      	strd	r1, r2, [sp]
    4db0:      	movt	r0, #0x0
    4db4:      	add	r1, sp, #0x4
    4db6:      	str	r0, [sp, #0x14]
    4db8:      	str	r0, [sp, #0xc]
    4dba:      	mov	r0, sp
    4dbc:      	str	r0, [sp, #0x8]
    4dbe:      	movw	r0, #0x58cf
    4dc2:      	str	r1, [sp, #0x10]
    4dc4:      	movt	r0, #0x0
    4dc8:      	add	r1, sp, #0x8
    4dca:      	mov	r2, r3
    4dcc:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #-0x590

00004dd0 <_RNvNtNtCs6e6HQTixP8o_4core9panicking11panic_const24panic_const_add_overflow>:
    4dd0:      	push	{r7, lr}
    4dd2:      	mov	r7, sp
    4dd4:      	mov	r2, r0
    4dd6:      	movw	r0, #0x6923
    4dda:      	movt	r0, #0x0
    4dde:      	movs	r1, #0x39
    4de0:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #-0x5a4

00004de4 <_RNvNtNtCs6e6HQTixP8o_4core9panicking11panic_const24panic_const_sub_overflow>:
    4de4:      	push	{r7, lr}
    4de6:      	mov	r7, sp
    4de8:      	mov	r2, r0
    4dea:      	movw	r0, #0x693f
    4dee:      	movt	r0, #0x0
    4df2:      	movs	r1, #0x43
    4df4:      	bl	0x4840 <_RNvNtCs6e6HQTixP8o_4core9panicking9panic_fmt> @ imm = #-0x5b8

00004df8 <_RNvNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB7_9Formatter12pad_integral12write_prefix>:
    4df8:      	push	{r4, r5, r6, r7, lr}
    4dfa:      	add	r7, sp, #0xc
    4dfc:      	str	r8, [sp, #-4]!
    4e00:      	ldr.w	r8, [r7, #0x8]
    4e04:      	mov	r6, r0
    4e06:      	mov	r4, r3
    4e08:      	mov	r5, r1
    4e0a:      	adds	r0, r2, #0x1
    4e0c:      	beq	0x4e20 <_RNvNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB7_9Formatter12pad_integral12write_prefix+0x28> @ imm = #0x10
    4e0e:      	ldr	r3, [r5, #0x10]
    4e10:      	mov	r0, r6
    4e12:      	mov	r1, r2
    4e14:      	blx	r3
    4e16:      	cbz	r0, 0x4e20 <_RNvNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB7_9Formatter12pad_integral12write_prefix+0x28> @ imm = #0x6
    4e18:      	movs	r0, #0x1
    4e1a:      	ldr	r8, [sp], #4
    4e1e:      	pop	{r4, r5, r6, r7, pc}
    4e20:      	cbz	r4, 0x4e34 <_RNvNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB7_9Formatter12pad_integral12write_prefix+0x3c> @ imm = #0x10
    4e22:      	ldr	r3, [r5, #0xc]
    4e24:      	mov	r0, r6
    4e26:      	mov	r1, r4
    4e28:      	mov	r2, r8
    4e2a:      	ldr	r8, [sp], #4
    4e2e:      	pop.w	{r4, r5, r6, r7, lr}
    4e32:      	bx	r3
    4e34:      	movs	r0, #0x0
    4e36:      	ldr	r8, [sp], #4
    4e3a:      	pop	{r4, r5, r6, r7, pc}

00004e3c <_RNvXs1i_NtCs6e6HQTixP8o_4core3fmtReNtB6_7Display3fmtB8_>:
    4e3c:      	push	{r7, lr}
    4e3e:      	mov	r7, sp
    4e40:      	mov	r3, r1
    4e42:      	ldrd	r1, r2, [r0]
    4e46:      	mov	r0, r3
    4e48:      	pop.w	{r7, lr}
    4e4c:      	b.w	0x442c <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad> @ imm = #-0xa24

00004e50 <_RNvXsu_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8LowerHex3fmt>:
    4e50:      	push	{r4, r5, r7, lr}
    4e52:      	add	r7, sp, #0x8
    4e54:      	sub	sp, #0x10
    4e56:      	mov	r12, r1
    4e58:      	ldr	r1, [r0]
    4e5a:      	movw	r3, #0x5ff4
    4e5e:      	add.w	lr, sp, #0x8
    4e62:      	movs	r2, #0x8
    4e64:      	movs	r0, #0x9
    4e66:      	movt	r3, #0x0
    4e6a:      	and	r4, r1, #0xf
    4e6e:      	ldrb	r5, [r3, r4]
    4e70:      	add.w	r4, lr, r0
    4e74:      	strb	r5, [r4, #-2]
    4e78:      	lsrs	r5, r1, #0x4
    4e7a:      	beq	0x4eb2 <_RNvXsu_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8LowerHex3fmt+0x62> @ imm = #0x34
    4e7c:      	and	r5, r5, #0xf
    4e80:      	ldrb	r5, [r3, r5]
    4e82:      	strb	r5, [r4, #-3]
    4e86:      	lsrs	r5, r1, #0x8
    4e88:      	beq	0x4eb6 <_RNvXsu_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8LowerHex3fmt+0x66> @ imm = #0x2a
    4e8a:      	and	r5, r5, #0xf
    4e8e:      	subs	r0, #0x4
    4e90:      	ldrb	r5, [r3, r5]
    4e92:      	strb	r5, [r4, #-4]
    4e96:      	lsrs	r5, r1, #0xc
    4e98:      	beq	0x4ebc <_RNvXsu_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8LowerHex3fmt+0x6c> @ imm = #0x20
    4e9a:      	and	r5, r5, #0xf
    4e9e:      	subs	r2, #0x4
    4ea0:      	lsrs	r1, r1, #0x10
    4ea2:      	ldrb	r5, [r3, r5]
    4ea4:      	strb	r5, [r4, #-5]
    4ea8:      	bne	0x4e6a <_RNvXsu_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8LowerHex3fmt+0x1a> @ imm = #-0x42
    4eaa:      	subs	r1, r0, #0x1
    4eac:      	mov	r2, r0
    4eae:      	mov	r0, r1
    4eb0:      	b	0x4ebe <_RNvXsu_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8LowerHex3fmt+0x6e> @ imm = #0xa
    4eb2:      	subs	r0, #0x2
    4eb4:      	b	0x4ebe <_RNvXsu_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8LowerHex3fmt+0x6e> @ imm = #0x6
    4eb6:      	subs	r2, #0x1
    4eb8:      	subs	r0, #0x3
    4eba:      	b	0x4ebe <_RNvXsu_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8LowerHex3fmt+0x6e> @ imm = #0x0
    4ebc:      	subs	r2, #0x2
    4ebe:      	rsb.w	r1, r2, #0x9
    4ec2:      	movw	r2, #0x6960
    4ec6:      	add	r0, lr
    4ec8:      	movt	r2, #0x0
    4ecc:      	strd	r0, r1, [sp]
    4ed0:      	mov	r0, r12
    4ed2:      	movs	r1, #0x1
    4ed4:      	movs	r3, #0x2
    4ed6:      	bl	0x4190 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral> @ imm = #-0xd4a
    4eda:      	add	sp, #0x10
    4edc:      	pop	{r4, r5, r7, pc}

00004ede <_RNvXsw_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8UpperHex3fmt>:
    4ede:      	push	{r4, r5, r7, lr}
    4ee0:      	add	r7, sp, #0x8
    4ee2:      	sub	sp, #0x10
    4ee4:      	mov	r12, r1
    4ee6:      	ldr	r1, [r0]
    4ee8:      	movw	r3, #0x5fd4
    4eec:      	add.w	lr, sp, #0x8
    4ef0:      	movs	r2, #0x8
    4ef2:      	movs	r0, #0x9
    4ef4:      	movt	r3, #0x0
    4ef8:      	and	r4, r1, #0xf
    4efc:      	ldrb	r5, [r3, r4]
    4efe:      	add.w	r4, lr, r0
    4f02:      	strb	r5, [r4, #-2]
    4f06:      	lsrs	r5, r1, #0x4
    4f08:      	beq	0x4f40 <_RNvXsw_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8UpperHex3fmt+0x62> @ imm = #0x34
    4f0a:      	and	r5, r5, #0xf
    4f0e:      	ldrb	r5, [r3, r5]
    4f10:      	strb	r5, [r4, #-3]
    4f14:      	lsrs	r5, r1, #0x8
    4f16:      	beq	0x4f44 <_RNvXsw_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8UpperHex3fmt+0x66> @ imm = #0x2a
    4f18:      	and	r5, r5, #0xf
    4f1c:      	subs	r0, #0x4
    4f1e:      	ldrb	r5, [r3, r5]
    4f20:      	strb	r5, [r4, #-4]
    4f24:      	lsrs	r5, r1, #0xc
    4f26:      	beq	0x4f4a <_RNvXsw_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8UpperHex3fmt+0x6c> @ imm = #0x20
    4f28:      	and	r5, r5, #0xf
    4f2c:      	subs	r2, #0x4
    4f2e:      	lsrs	r1, r1, #0x10
    4f30:      	ldrb	r5, [r3, r5]
    4f32:      	strb	r5, [r4, #-5]
    4f36:      	bne	0x4ef8 <_RNvXsw_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8UpperHex3fmt+0x1a> @ imm = #-0x42
    4f38:      	subs	r1, r0, #0x1
    4f3a:      	mov	r2, r0
    4f3c:      	mov	r0, r1
    4f3e:      	b	0x4f4c <_RNvXsw_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8UpperHex3fmt+0x6e> @ imm = #0xa
    4f40:      	subs	r0, #0x2
    4f42:      	b	0x4f4c <_RNvXsw_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8UpperHex3fmt+0x6e> @ imm = #0x6
    4f44:      	subs	r2, #0x1
    4f46:      	subs	r0, #0x3
    4f48:      	b	0x4f4c <_RNvXsw_NtNtCs6e6HQTixP8o_4core3fmt3nummNtB7_8UpperHex3fmt+0x6e> @ imm = #0x0
    4f4a:      	subs	r2, #0x2
    4f4c:      	rsb.w	r1, r2, #0x9
    4f50:      	movw	r2, #0x6960
    4f54:      	add	r0, lr
    4f56:      	movt	r2, #0x0
    4f5a:      	strd	r0, r1, [sp]
    4f5e:      	mov	r0, r12
    4f60:      	movs	r1, #0x1
    4f62:      	movs	r3, #0x2
    4f64:      	bl	0x4190 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral> @ imm = #-0xdd8
    4f68:      	add	sp, #0x10
    4f6a:      	pop	{r4, r5, r7, pc}

00004f6c <_RNvXsd_NtNtNtCs6e6HQTixP8o_4core3fmt3num3impjNtB9_7Display3fmt>:
    4f6c:      	push	{r4, r5, r6, r7, lr}
    4f6e:      	add	r7, sp, #0xc
    4f70:      	push.w	{r8, r9, r10, r11}
    4f74:      	sub	sp, #0x1c
    4f76:      	ldr	r4, [r0]
    4f78:      	movw	r0, #0x685b
    4f7c:      	mov	r5, r1
    4f7e:      	movt	r0, #0x0
    4f82:      	cmp.w	r4, #0x3e8
    4f86:      	blo	0x4ffa <_RNvXsd_NtNtNtCs6e6HQTixP8o_4core3fmt3num3impjNtB9_7Display3fmt+0x8e> @ imm = #0x70
    4f88:      	movw	r8, #0x967f
    4f8c:      	sub.w	lr, r7, #0x26
    4f90:      	movs	r3, #0x0
    4f92:      	movw	r9, #0x2710
    4f96:      	movw	r10, #0x147b
    4f9a:      	mov.w	r11, #0x64
    4f9e:      	movt	r8, #0x98
    4fa2:      	mov	r1, r4
    4fa4:      	str	r5, [sp, #0xc]
    4fa6:      	str	r4, [sp, #0x8]
    4fa8:      	mov	r2, r1
    4faa:      	movw	r1, #0x1759
    4fae:      	movt	r1, #0xd1b7
    4fb2:      	add.w	r4, lr, r3
    4fb6:      	umull	r1, r6, r2, r1
    4fba:      	subs	r3, #0x4
    4fbc:      	cmp	r2, r8
    4fbe:      	lsr.w	r1, r6, #0xd
    4fc2:      	mls	r6, r1, r9, r2
    4fc6:      	uxth.w	r12, r6
    4fca:      	lsr.w	r5, r12, #0x2
    4fce:      	mul	r5, r5, r10
    4fd2:      	lsr.w	r5, r5, #0x11
    4fd6:      	mls	r6, r5, r11, r6
    4fda:      	ldrh.w	r5, [r0, r5, lsl #1]
    4fde:      	strh	r5, [r4, #0x6]
    4fe0:      	uxth	r6, r6
    4fe2:      	ldrh.w	r6, [r0, r6, lsl #1]
    4fe6:      	strh	r6, [r4, #0x8]
    4fe8:      	bhi	0x4fa8 <_RNvXsd_NtNtNtCs6e6HQTixP8o_4core3fmt3num3impjNtB9_7Display3fmt+0x3c> @ imm = #-0x44
    4fea:      	ldrd	r4, r5, [sp, #8]
    4fee:      	adds	r3, #0xa
    4ff0:      	cmp	r1, #0x9
    4ff2:      	bhi	0x5002 <_RNvXsd_NtNtNtCs6e6HQTixP8o_4core3fmt3num3impjNtB9_7Display3fmt+0x96> @ imm = #0xc
    4ff4:      	mov	r2, r1
    4ff6:      	cbnz	r4, 0x5024 <_RNvXsd_NtNtNtCs6e6HQTixP8o_4core3fmt3num3impjNtB9_7Display3fmt+0xb8> @ imm = #0x2a
    4ff8:      	b	0x5026 <_RNvXsd_NtNtNtCs6e6HQTixP8o_4core3fmt3num3impjNtB9_7Display3fmt+0xba> @ imm = #0x2a
    4ffa:      	movs	r3, #0xa
    4ffc:      	mov	r1, r4
    4ffe:      	cmp	r1, #0x9
    5000:      	bls	0x4ff4 <_RNvXsd_NtNtNtCs6e6HQTixP8o_4core3fmt3num3impjNtB9_7Display3fmt+0x88> @ imm = #-0x10
    5002:      	uxth	r2, r1
    5004:      	movw	r6, #0x147b
    5008:      	lsrs	r2, r2, #0x2
    500a:      	subs	r3, #0x2
    500c:      	muls	r2, r6, r2
    500e:      	movs	r6, #0x64
    5010:      	lsrs	r2, r2, #0x11
    5012:      	mls	r1, r2, r6, r1
    5016:      	sub.w	r6, r7, #0x26
    501a:      	uxth	r1, r1
    501c:      	ldrh.w	r1, [r0, r1, lsl #1]
    5020:      	strh	r1, [r6, r3]
    5022:      	cbz	r4, 0x5026 <_RNvXsd_NtNtNtCs6e6HQTixP8o_4core3fmt3num3impjNtB9_7Display3fmt+0xba> @ imm = #0x0
    5024:      	cbz	r2, 0x5034 <_RNvXsd_NtNtNtCs6e6HQTixP8o_4core3fmt3num3impjNtB9_7Display3fmt+0xc8> @ imm = #0xc
    5026:      	add.w	r0, r0, r2, lsl #1
    502a:      	subs	r3, #0x1
    502c:      	sub.w	r1, r7, #0x26
    5030:      	ldrb	r0, [r0, #0x1]
    5032:      	strb	r0, [r1, r3]
    5034:      	sub.w	r1, r7, #0x26
    5038:      	rsb.w	r0, r3, #0xa
    503c:      	add	r1, r3
    503e:      	movs	r2, #0x1
    5040:      	strd	r1, r0, [sp]
    5044:      	mov	r0, r5
    5046:      	movs	r1, #0x1
    5048:      	movs	r3, #0x0
    504a:      	bl	0x4190 <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter12pad_integral> @ imm = #-0xebe
    504e:      	add	sp, #0x1c
    5050:      	pop.w	{r8, r9, r10, r11}
    5054:      	pop	{r4, r5, r6, r7, pc}

00005056 <_RNvXs_NtNtCs6e6HQTixP8o_4core5panic10panic_infoNtB4_9PanicInfoNtNtB8_3fmt7Display3fmt>:
    5056:      	push	{r4, r5, r6, r7, lr}
    5058:      	add	r7, sp, #0xc
    505a:      	str	r8, [sp, #-4]!
    505e:      	sub	sp, #0x20
    5060:      	ldrd	r5, r4, [r1]
    5064:      	movw	r1, #0x6962
    5068:      	ldr	r6, [r4, #0xc]
    506a:      	mov	r8, r0
    506c:      	movt	r1, #0x0
    5070:      	movs	r2, #0xc
    5072:      	mov	r0, r5
    5074:      	blx	r6
    5076:      	cbz	r0, 0x5082 <_RNvXs_NtNtCs6e6HQTixP8o_4core5panic10panic_infoNtB4_9PanicInfoNtNtB8_3fmt7Display3fmt+0x2c> @ imm = #0x8
    5078:      	movs	r0, #0x1
    507a:      	add	sp, #0x20
    507c:      	ldr	r8, [sp], #4
    5080:      	pop	{r4, r5, r6, r7, pc}
    5082:      	ldr.w	r0, [r8, #0x4]
    5086:      	add	r3, sp, #0x8
    5088:      	ldrd	r1, r2, [r0]
    508c:      	strd	r1, r2, [sp]
    5090:      	add.w	r2, r0, #0xc
    5094:      	adds	r0, #0x8
    5096:      	movw	r1, #0x4f6d
    509a:      	str	r0, [sp, #0x10]
    509c:      	movw	r0, #0x4e3d
    50a0:      	movt	r1, #0x0
    50a4:      	movt	r0, #0x0
    50a8:      	strd	r1, r2, [sp, #20]
    50ac:      	movw	r2, #0x5ae8
    50b0:      	str	r0, [sp, #0xc]
    50b2:      	mov	r0, sp
    50b4:      	str	r1, [sp, #0x1c]
    50b6:      	movt	r2, #0x0
    50ba:      	str	r0, [sp, #0x8]
    50bc:      	mov	r0, r5
    50be:      	mov	r1, r4
    50c0:      	bl	0x463c <_RNvNtCs6e6HQTixP8o_4core3fmt5write> @ imm = #-0xa88
    50c4:      	cbz	r0, 0x50d0 <_RNvXs_NtNtCs6e6HQTixP8o_4core5panic10panic_infoNtB4_9PanicInfoNtNtB8_3fmt7Display3fmt+0x7a> @ imm = #0x8
    50c6:      	movs	r0, #0x1
    50c8:      	add	sp, #0x20
    50ca:      	ldr	r8, [sp], #4
    50ce:      	pop	{r4, r5, r6, r7, pc}
    50d0:      	movw	r1, #0x696e
    50d4:      	mov	r0, r5
    50d6:      	movt	r1, #0x0
    50da:      	movs	r2, #0x2
    50dc:      	blx	r6
    50de:      	cbz	r0, 0x50ea <_RNvXs_NtNtCs6e6HQTixP8o_4core5panic10panic_infoNtB4_9PanicInfoNtNtB8_3fmt7Display3fmt+0x94> @ imm = #0x8
    50e0:      	movs	r0, #0x1
    50e2:      	add	sp, #0x20
    50e4:      	ldr	r8, [sp], #4
    50e8:      	pop	{r4, r5, r6, r7, pc}
    50ea:      	ldr.w	r0, [r8]
    50ee:      	mov	r1, r4
    50f0:      	ldrd	r2, r3, [r0]
    50f4:      	mov	r0, r5
    50f6:      	bl	0x463c <_RNvNtCs6e6HQTixP8o_4core3fmt5write> @ imm = #-0xabe
    50fa:      	add	sp, #0x20
    50fc:      	ldr	r8, [sp], #4
    5100:      	pop	{r4, r5, r6, r7, pc}

00005102 <_RNvXsr_NtCs6e6HQTixP8o_4core4cellNtB5_14BorrowMutErrorNtNtB7_3fmt7Display3fmt>:
    5102:      	push	{r7, lr}
    5104:      	mov	r7, sp
    5106:      	mov	r0, r1
    5108:      	movw	r1, #0x6970
    510c:      	movt	r1, #0x0
    5110:      	movs	r2, #0x18
    5112:      	pop.w	{r7, lr}
    5116:      	b.w	0x442c <_RNvMsa_NtCs6e6HQTixP8o_4core3fmtNtB5_9Formatter3pad> @ imm = #-0xcee

0000511a <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy>:
    511a:      	push	{r4, r5, r6, r7, lr}
    511c:      	add	r7, sp, #0xc
    511e:      	push.w	{r8, r9, r10, r11}
    5122:      	sub	sp, #0x24
    5124:      	mov	r8, r0
    5126:      	cmp	r2, #0x10
    5128:      	blo	0x516e <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x54> @ imm = #0x42
    512a:      	rsb.w	r0, r8, #0x0
    512e:      	and	r10, r0, #0x3
    5132:      	add.w	r3, r8, r10
    5136:      	cmp	r8, r3
    5138:      	bhs	0x51aa <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x90> @ imm = #0x6e
    513a:      	sub.w	r6, r10, #0x1
    513e:      	mov	r4, r8
    5140:      	mov	r5, r1
    5142:      	cmp.w	r10, #0x0
    5146:      	beq	0x5188 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x6e> @ imm = #0x3e
    5148:      	mov	r5, r1
    514a:      	mov	r4, r8
    514c:      	ldrb	r0, [r5], #1
    5150:      	cmp.w	r10, #0x1
    5154:      	strb	r0, [r4], #1
    5158:      	beq	0x5188 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x6e> @ imm = #0x2c
    515a:      	ldrb	r0, [r1, #0x1]
    515c:      	cmp.w	r10, #0x2
    5160:      	strb.w	r0, [r8, #0x1]
    5164:      	bne	0x517c <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x62> @ imm = #0x14
    5166:      	adds	r5, r1, #0x2
    5168:      	add.w	r4, r8, #0x2
    516c:      	b	0x5188 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x6e> @ imm = #0x18
    516e:      	mov	r12, r8
    5170:      	add.w	r3, r12, r2
    5174:      	cmp	r12, r3
    5176:      	blo.w	0x533e <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x224> @ imm = #0x1c4
    517a:      	b	0x5392 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x278> @ imm = #0x214
    517c:      	adds	r5, r1, #0x3
    517e:      	add.w	r4, r8, #0x3
    5182:      	ldrb	r0, [r1, #0x2]
    5184:      	strb.w	r0, [r8, #0x2]
    5188:      	cmp	r6, #0x3
    518a:      	blo	0x51aa <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x90> @ imm = #0x1c
    518c:      	subs	r6, r5, #0x4
    518e:      	subs	r5, r4, #0x4
    5190:      	ldrb	r0, [r6, #4]!
    5194:      	strb	r0, [r5, #4]!
    5198:      	ldrb	r0, [r6, #0x1]
    519a:      	strb	r0, [r5, #0x1]
    519c:      	ldrb	r0, [r6, #0x2]
    519e:      	strb	r0, [r5, #0x2]
    51a0:      	ldrb	r0, [r6, #0x3]
    51a2:      	strb	r0, [r5, #0x3]
    51a4:      	adds	r0, r5, #0x4
    51a6:      	cmp	r0, r3
    51a8:      	bne	0x5190 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x76> @ imm = #-0x1c
    51aa:      	sub.w	r11, r2, r10
    51ae:      	add.w	r4, r1, r10
    51b2:      	bic	r2, r11, #0x3
    51b6:      	ands	r0, r4, #0x3
    51ba:      	add.w	r12, r3, r2
    51be:      	beq	0x5288 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x16e> @ imm = #0xc6
    51c0:      	mov.w	r9, #0x0
    51c4:      	rsb.w	r6, r0, #0x4
    51c8:      	str	r2, [sp, #0x10]
    51ca:      	add	r2, sp, #0x20
    51cc:      	str.w	r9, [sp, #0x20]
    51d0:      	add	r2, r0
    51d2:      	lsls	r5, r6, #0x1f
    51d4:      	ittt	ne
    51d6:      	ldrbne	r5, [r4]
    51d8:      	strbne	r5, [r2]
    51da:      	movne.w	r9, #0x1
    51de:      	lsls	r6, r6, #0x1e
    51e0:      	itt	mi
    51e2:      	ldrhmi.w	r6, [r4, r9]
    51e6:      	strhmi.w	r6, [r2, r9]
    51ea:      	subs	r5, r4, r0
    51ec:      	str	r4, [sp, #0x14]
    51ee:      	adds	r4, r3, #0x4
    51f0:      	ldr	r2, [sp, #0x20]
    51f2:      	lsl.w	lr, r0, #0x3
    51f6:      	cmp	r4, r12
    51f8:      	rsb.w	r4, lr, #0x0
    51fc:      	strd	r0, r4, [sp, #8]
    5200:      	bhs	0x52ba <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x1a0> @ imm = #0xb6
    5202:      	rsbs	r3, r0, #0
    5204:      	mov	r6, r8
    5206:      	str.w	r11, [sp]
    520a:      	add.w	r8, r1, r3
    520e:      	and	r11, r4, #0x18
    5212:      	str	r6, [sp, #0x4]
    5214:      	add.w	r5, r8, r10
    5218:      	add.w	r4, r6, r10
    521c:      	lsr.w	r1, r2, lr
    5220:      	ldr.w	r9, [r5, #0x4]
    5224:      	lsl.w	r2, r9, r11
    5228:      	orrs	r1, r2
    522a:      	mov	r2, r4
    522c:      	str	r1, [r2], #8
    5230:      	cmp	r2, r12
    5232:      	bhs	0x52be <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x1a4> @ imm = #0x88
    5234:      	ldr	r1, [r5, #0x8]
    5236:      	lsr.w	r3, r9, lr
    523a:      	lsl.w	r0, r1, r11
    523e:      	orrs	r0, r3
    5240:      	add.w	r3, r4, #0xc
    5244:      	cmp	r3, r12
    5246:      	str	r0, [r4, #0x4]
    5248:      	bhs	0x52c4 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x1aa> @ imm = #0x78
    524a:      	ldr.w	r9, [r5, #0xc]
    524e:      	lsr.w	r0, r1, lr
    5252:      	lsl.w	r1, r9, r11
    5256:      	orrs	r0, r1
    5258:      	str	r0, [r2]
    525a:      	add.w	r0, r4, #0x10
    525e:      	cmp	r0, r12
    5260:      	bhs	0x52ce <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x1b4> @ imm = #0x6a
    5262:      	ldr	r2, [r5, #0x10]
    5264:      	lsr.w	r0, r9, lr
    5268:      	adds	r6, #0x10
    526a:      	add.w	r8, r8, #0x10
    526e:      	lsl.w	r1, r2, r11
    5272:      	orrs	r0, r1
    5274:      	str	r0, [r3]
    5276:      	add.w	r3, r6, r10
    527a:      	adds	r0, r3, #0x4
    527c:      	cmp	r0, r12
    527e:      	blo	0x5214 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0xfa> @ imm = #-0x6e
    5280:      	add.w	r5, r8, r10
    5284:      	mov	r9, r2
    5286:      	b	0x52d0 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x1b6> @ imm = #0x46
    5288:      	cmp	r3, r12
    528a:      	bhs	0x5330 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x216> @ imm = #0xa2
    528c:      	mov	r1, r4
    528e:      	ldr	r0, [r1]
    5290:      	str	r0, [r3], #4
    5294:      	cmp	r3, r12
    5296:      	bhs	0x5330 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x216> @ imm = #0x96
    5298:      	ldr	r0, [r1, #0x4]
    529a:      	str	r0, [r3], #4
    529e:      	cmp	r3, r12
    52a0:      	ittt	lo
    52a2:      	ldrlo	r0, [r1, #0x8]
    52a4:      	strlo	r0, [r3], #4
    52a8:      	cmplo	r3, r12
    52aa:      	bhs	0x5330 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x216> @ imm = #0x82
    52ac:      	ldr	r0, [r1, #0xc]
    52ae:      	adds	r1, #0x10
    52b0:      	str	r0, [r3], #4
    52b4:      	cmp	r3, r12
    52b6:      	blo	0x528e <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x174> @ imm = #-0x2c
    52b8:      	b	0x5330 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x216> @ imm = #0x74
    52ba:      	mov	r9, r2
    52bc:      	b	0x52d4 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x1ba> @ imm = #0x14
    52be:      	adds	r5, #0x4
    52c0:      	adds	r3, r4, #0x4
    52c2:      	b	0x52d0 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x1b6> @ imm = #0xa
    52c4:      	adds	r5, #0x8
    52c6:      	add.w	r3, r4, #0x8
    52ca:      	mov	r9, r1
    52cc:      	b	0x52d0 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x1b6> @ imm = #0x0
    52ce:      	adds	r5, #0xc
    52d0:      	ldrd	r11, r8, [sp]
    52d4:      	ldr	r0, [sp, #0x8]
    52d6:      	movs	r2, #0x0
    52d8:      	strb.w	r2, [sp, #0x1c]
    52dc:      	cmp	r0, #0x1
    52de:      	strb	r2, [r7, #-38]
    52e2:      	bne	0x52f2 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x1d8> @ imm = #0xc
    52e4:      	add	r6, sp, #0x1c
    52e6:      	movs	r4, #0x0
    52e8:      	movs	r0, #0x0
    52ea:      	ldr	r1, [sp, #0x14]
    52ec:      	lsls	r1, r1, #0x1f
    52ee:      	bne	0x5308 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x1ee> @ imm = #0x16
    52f0:      	b	0x531a <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x200> @ imm = #0x26
    52f2:      	ldrb	r0, [r5, #0x5]
    52f4:      	sub.w	r6, r7, #0x26
    52f8:      	ldrb	r2, [r5, #0x4]
    52fa:      	strb.w	r2, [sp, #0x1c]
    52fe:      	lsls	r4, r0, #0x8
    5300:      	movs	r0, #0x2
    5302:      	ldr	r1, [sp, #0x14]
    5304:      	lsls	r1, r1, #0x1f
    5306:      	beq	0x531a <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x200> @ imm = #0x10
    5308:      	adds	r1, r5, #0x4
    530a:      	ldrb	r0, [r1, r0]
    530c:      	strb	r0, [r6]
    530e:      	ldrb	r0, [r7, #-38]
    5312:      	ldrb.w	r2, [sp, #0x1c]
    5316:      	orr.w	r4, r4, r0, lsl #16
    531a:      	adds	r0, r4, r2
    531c:      	ldr	r2, [sp, #0xc]
    531e:      	lsr.w	r1, r9, lr
    5322:      	and	r2, r2, #0x18
    5326:      	lsls	r0, r2
    5328:      	ldrd	r2, r4, [sp, #16]
    532c:      	orrs	r0, r1
    532e:      	str	r0, [r3]
    5330:      	adds	r1, r4, r2
    5332:      	and	r2, r11, #0x3
    5336:      	add.w	r3, r12, r2
    533a:      	cmp	r12, r3
    533c:      	bhs	0x5392 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x278> @ imm = #0x52
    533e:      	subs	r6, r2, #0x1
    5340:      	ands	r0, r2, #0x3
    5344:      	beq	0x536c <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x252> @ imm = #0x24
    5346:      	mov	r2, r1
    5348:      	mov	r5, r12
    534a:      	ldrb	r4, [r2], #1
    534e:      	cmp	r0, #0x1
    5350:      	strb	r4, [r5], #1
    5354:      	beq	0x5370 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x256> @ imm = #0x18
    5356:      	ldrb	r2, [r1, #0x1]
    5358:      	cmp	r0, #0x2
    535a:      	strb.w	r2, [r12, #0x1]
    535e:      	bne	0x539c <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x282> @ imm = #0x3a
    5360:      	adds	r2, r1, #0x2
    5362:      	add.w	r5, r12, #0x2
    5366:      	cmp	r6, #0x3
    5368:      	bhs	0x5374 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x25a> @ imm = #0x8
    536a:      	b	0x5392 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x278> @ imm = #0x24
    536c:      	mov	r5, r12
    536e:      	mov	r2, r1
    5370:      	cmp	r6, #0x3
    5372:      	blo	0x5392 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x278> @ imm = #0x1c
    5374:      	subs	r1, r2, #0x4
    5376:      	subs	r2, r5, #0x4
    5378:      	ldrb	r0, [r1, #4]!
    537c:      	strb	r0, [r2, #4]!
    5380:      	ldrb	r0, [r1, #0x1]
    5382:      	strb	r0, [r2, #0x1]
    5384:      	ldrb	r0, [r1, #0x2]
    5386:      	strb	r0, [r2, #0x2]
    5388:      	ldrb	r0, [r1, #0x3]
    538a:      	strb	r0, [r2, #0x3]
    538c:      	adds	r0, r2, #0x4
    538e:      	cmp	r0, r3
    5390:      	bne	0x5378 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x25e> @ imm = #-0x1c
    5392:      	mov	r0, r8
    5394:      	add	sp, #0x24
    5396:      	pop.w	{r8, r9, r10, r11}
    539a:      	pop	{r4, r5, r6, r7, pc}
    539c:      	adds	r2, r1, #0x3
    539e:      	add.w	r5, r12, #0x3
    53a2:      	ldrb	r0, [r1, #0x2]
    53a4:      	strb.w	r0, [r12, #0x2]
    53a8:      	cmp	r6, #0x3
    53aa:      	bhs	0x5374 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x25a> @ imm = #-0x3a
    53ac:      	b	0x5392 <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy+0x278> @ imm = #-0x1e

000053ae <__aeabi_memclr4>:
    53ae:      	push	{r7, lr}
    53b0:      	mov	r7, sp
    53b2:      	cmp	r1, #0x4
    53b4:      	blo	0x53e0 <__aeabi_memclr4+0x32> @ imm = #0x28
    53b6:      	sub.w	r12, r1, #0x4
    53ba:      	movs	r2, #0x1
    53bc:      	add.w	r2, r2, r12, lsr #2
    53c0:      	ands	r3, r2, #0x3
    53c4:      	beq	0x53e4 <__aeabi_memclr4+0x36> @ imm = #0x1c
    53c6:      	mov.w	lr, #0x0
    53ca:      	mov	r2, r0
    53cc:      	str	lr, [r2], #4
    53d0:      	cmp	r3, #0x1
    53d2:      	bne	0x53ec <__aeabi_memclr4+0x3e> @ imm = #0x16
    53d4:      	mov	r1, r12
    53d6:      	mov	r0, r2
    53d8:      	cmp.w	r12, #0xc
    53dc:      	bhs	0x5412 <__aeabi_memclr4+0x64> @ imm = #0x32
    53de:      	b	0x5426 <__aeabi_memclr4+0x78> @ imm = #0x44
    53e0:      	mov	r2, r0
    53e2:      	b	0x5426 <__aeabi_memclr4+0x78> @ imm = #0x40
    53e4:      	cmp.w	r12, #0xc
    53e8:      	bhs	0x5412 <__aeabi_memclr4+0x64> @ imm = #0x26
    53ea:      	b	0x5426 <__aeabi_memclr4+0x78> @ imm = #0x38
    53ec:      	cmp	r3, #0x2
    53ee:      	str.w	lr, [r0, #0x4]
    53f2:      	bne	0x5402 <__aeabi_memclr4+0x54> @ imm = #0xc
    53f4:      	subs	r1, #0x8
    53f6:      	adds	r0, #0x8
    53f8:      	mov	r2, r0
    53fa:      	cmp.w	r12, #0xc
    53fe:      	bhs	0x5412 <__aeabi_memclr4+0x64> @ imm = #0x10
    5400:      	b	0x5426 <__aeabi_memclr4+0x78> @ imm = #0x22
    5402:      	movs	r2, #0x0
    5404:      	subs	r1, #0xc
    5406:      	str	r2, [r0, #0x8]
    5408:      	adds	r0, #0xc
    540a:      	mov	r2, r0
    540c:      	cmp.w	r12, #0xc
    5410:      	blo	0x5426 <__aeabi_memclr4+0x78> @ imm = #0x12
    5412:      	movs	r3, #0x0
    5414:      	mov	r2, r0
    5416:      	subs	r1, #0x10
    5418:      	strd	r3, r3, [r2]
    541c:      	strd	r3, r3, [r2, #8]
    5420:      	adds	r2, #0x10
    5422:      	cmp	r1, #0x3
    5424:      	bhi	0x5416 <__aeabi_memclr4+0x68> @ imm = #-0x12
    5426:      	adds	r0, r2, r1
    5428:      	cmp	r2, r0
    542a:      	bhs	0x5470 <__aeabi_memclr4+0xc2> @ imm = #0x42
    542c:      	sub.w	r12, r1, #0x1
    5430:      	ands	r3, r1, #0x3
    5434:      	beq	0x5450 <__aeabi_memclr4+0xa2> @ imm = #0x18
    5436:      	mov.w	lr, #0x0
    543a:      	mov	r1, r2
    543c:      	strb	lr, [r1], #1
    5440:      	cmp	r3, #0x1
    5442:      	beq	0x545a <__aeabi_memclr4+0xac> @ imm = #0x14
    5444:      	cmp	r3, #0x2
    5446:      	strb.w	lr, [r2, #0x1]
    544a:      	bne	0x5454 <__aeabi_memclr4+0xa6> @ imm = #0x6
    544c:      	adds	r1, r2, #0x2
    544e:      	b	0x545a <__aeabi_memclr4+0xac> @ imm = #0x8
    5450:      	mov	r1, r2
    5452:      	b	0x545a <__aeabi_memclr4+0xac> @ imm = #0x4
    5454:      	movs	r1, #0x0
    5456:      	strb	r1, [r2, #0x2]
    5458:      	adds	r1, r2, #0x3
    545a:      	cmp.w	r12, #0x3
    545e:      	it	lo
    5460:      	poplo	{r7, pc}
    5462:      	subs	r1, #0x4
    5464:      	movs	r2, #0x0
    5466:      	str	r2, [r1, #4]!
    546a:      	adds	r3, r1, #0x4
    546c:      	cmp	r3, r0
    546e:      	bne	0x5466 <__aeabi_memclr4+0xb8> @ imm = #-0xc
    5470:      	pop	{r7, pc}

00005472 <__aeabi_memcpy>:
    5472:      	push	{r7, lr}
    5474:      	mov	r7, sp
    5476:      	pop.w	{r7, lr}
    547a:      	b.w	0x511a <_RNvNtCs63N7pbqZKIM_17compiler_builtins3mem6memcpy> @ imm = #-0x364

0000547e <HardFault_>:
; pub unsafe extern "C" fn HardFault_() -> ! {
    547e:      	push	{r7, lr}
    5480:      	mov	r7, sp
;     loop {}
    5482:      	b	0x5484 <HardFault_+0x6> @ imm = #-0x2
    5484:      	b	0x5484 <HardFault_+0x6> @ imm = #-0x4
    5486:      	bmi	0x5432 <__aeabi_memclr4+0x84> @ imm = #-0x58
