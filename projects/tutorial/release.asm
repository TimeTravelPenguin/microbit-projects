
tutorial:	file format elf32-littlearm

Disassembly of section .text:

00000100 <__stext>:
     100:      	bl	0xbea <rtt_init_must_not_be_called_multiple_times> @ imm = #0xae6
     104:      	ldr	r0, [pc, #0x38]         @ 0x140 <__stext+0x40>
     106:      	ldr	r1, [pc, #0x3c]         @ 0x144 <__stext+0x44>
     108:      	movs	r2, #0x0
     10a:      	cmp	r1, r0
     10c:      	beq	0x112 <__stext+0x12>    @ imm = #0x2
     10e:      	stm	r0!, {r2}
     110:      	b	0x10a <__stext+0xa>     @ imm = #-0xa
     112:      	ldr	r0, [pc, #0x34]         @ 0x148 <__stext+0x48>
     114:      	ldr	r1, [pc, #0x34]         @ 0x14c <__stext+0x4c>
     116:      	ldr	r2, [pc, #0x38]         @ 0x150 <__stext+0x50>
     118:      	cmp	r1, r0
     11a:      	beq	0x122 <__stext+0x22>    @ imm = #0x4
     11c:      	ldm	r2!, {r3}
     11e:      	stm	r0!, {r3}
     120:      	b	0x118 <__stext+0x18>    @ imm = #-0xc
     122:      	ldr	r0, [pc, #0x30]         @ 0x154 <__stext+0x54>
     124:      	mov.w	r1, #0xf00000
     128:      	ldr	r2, [r0]
     12a:      	orr.w	r2, r2, r1
     12e:      	str	r2, [r0]
     130:      	dsb	sy
     134:      	isb	sy
     138:      	bl	0x17a <main>            @ imm = #0x3e
     13c:      	udf	#0x0
     13e:      	movs	r0, r0
     140: 00 00 00 20  	.word	0x20000000
     144: 44 04 00 20  	.word	0x20000444
     148: 00 00 00 20  	.word	0x20000000
     14c: 00 00 00 20  	.word	0x20000000
     150: 50 18 00 00  	.word	0x00001850
     154: 88 ed 00 e0  	.word	0xe000ed88

00000158 <tutorial::__cortex_m_rt_main>:
     158:      	push	{r7, lr}
     15a:      	mov	r7, sp
     15c:      	bl	0x114e <tutorial::init> @ imm = #0xfee
     160:      	movw	r0, #0x504
     164:      	movt	r0, #0x5000
     168:      	ldr	r1, [r0]
     16a:      	bic	r1, r1, #0x280000
     16e:      	str	r1, [r0]
     170:      	yield
     172:      	yield
     174:      	yield
     176:      	yield
     178:      	b	0x170 <tutorial::__cortex_m_rt_main+0x18> @ imm = #-0xc

0000017a <main>:
     17a:      	push	{r7, lr}
     17c:      	mov	r7, sp
     17e:      	bl	0x158 <tutorial::__cortex_m_rt_main> @ imm = #-0x2a

00000182 <<&str as core::fmt::Display>::fmt>:
     182:      	push	{r7, lr}
     184:      	mov	r7, sp
     186:      	mov	r3, r1
     188:      	ldrd	r1, r2, [r0]
     18c:      	mov	r0, r3
     18e:      	pop.w	{r7, lr}
     192:      	b.w	0x2c0 <<core::fmt::Formatter>::pad> @ imm = #0x12a

00000196 <core::panicking::panic_fmt>:
     196:      	push	{r7, lr}
     198:      	mov	r7, sp
     19a:      	sub	sp, #0x18
     19c:      	strd	r0, r1, [sp, #4]
     1a0:      	movs	r0, #0x1
     1a2:      	strh.w	r0, [sp, #0x14]
     1a6:      	add	r0, sp, #0x4
     1a8:      	str	r0, [sp, #0xc]
     1aa:      	add	r0, sp, #0xc
     1ac:      	str	r2, [sp, #0x10]
     1ae:      	bl	0xbf0 <__rustc::rust_begin_unwind> @ imm = #0xa3e

000001b2 <core::fmt::write>:
     1b2:      	push	{r4, r5, r6, r7, lr}
     1b4:      	add	r7, sp, #0xc
     1b6:      	push.w	{r8, r9, r10, r11}
     1ba:      	sub	sp, #0x14
     1bc:      	mov	r6, r0
     1be:      	mov	r11, r3
     1c0:      	mov	r10, r1
     1c2:      	lsls	r0, r3, #0x1f
     1c4:      	bne	0x290 <core::fmt::write+0xde> @ imm = #0xc8
     1c6:      	ldrb	r5, [r2]
     1c8:      	movs	r0, #0x0
     1ca:      	cmp	r5, #0x0
     1cc:      	beq	0x2ac <core::fmt::write+0xfa> @ imm = #0xdc
     1ce:      	ldr.w	r9, [r10, #0xc]
     1d2:      	mov.w	r8, #0x0
     1d6:      	b	0x1de <core::fmt::write+0x2c> @ imm = #0x4
     1d8:      	ldrb	r5, [r2]
     1da:      	cmp	r5, #0x0
     1dc:      	beq	0x2b4 <core::fmt::write+0x102> @ imm = #0xd4
     1de:      	adds	r4, r2, #0x1
     1e0:      	sxtb	r0, r5
     1e2:      	cmp.w	r0, #0xffffffff
     1e6:      	ble	0x1f8 <core::fmt::write+0x46> @ imm = #0xe
     1e8:      	mov	r0, r6
     1ea:      	mov	r1, r4
     1ec:      	mov	r2, r5
     1ee:      	blx	r9
     1f0:      	cmp	r0, #0x0
     1f2:      	bne	0x2aa <core::fmt::write+0xf8> @ imm = #0xb4
     1f4:      	adds	r2, r4, r5
     1f6:      	b	0x1d8 <core::fmt::write+0x26> @ imm = #-0x22
     1f8:      	cmp	r5, #0x80
     1fa:      	beq	0x210 <core::fmt::write+0x5e> @ imm = #0x12
     1fc:      	cmp	r5, #0xc0
     1fe:      	bne	0x226 <core::fmt::write+0x74> @ imm = #0x24
     200:      	ldr.w	r0, [r11, r8, lsl #3]
     204:      	movs	r1, #0x0
     206:      	str	r1, [sp, #0x10]
     208:      	movs	r1, #0x20
     20a:      	movt	r1, #0x6000
     20e:      	b	0x274 <core::fmt::write+0xc2> @ imm = #0x62
     210:      	ldrh.w	r4, [r2, #0x1]
     214:      	adds	r5, r2, #0x3
     216:      	mov	r0, r6
     218:      	mov	r1, r5
     21a:      	mov	r2, r4
     21c:      	blx	r9
     21e:      	cmp	r0, #0x0
     220:      	bne	0x2aa <core::fmt::write+0xf8> @ imm = #0x86
     222:      	adds	r2, r5, r4
     224:      	b	0x1d8 <core::fmt::write+0x26> @ imm = #-0x50
     226:      	lsls	r0, r5, #0x1f
     228:      	bne	0x232 <core::fmt::write+0x80> @ imm = #0x6
     22a:      	movs	r1, #0x20
     22c:      	movt	r1, #0x6000
     230:      	b	0x238 <core::fmt::write+0x86> @ imm = #0x4
     232:      	ldr.w	r1, [r2, #0x1]
     236:      	adds	r4, r2, #0x5
     238:      	lsls	r0, r5, #0x1e
     23a:      	ite	mi
     23c:      	ldrhmi	r2, [r4], #2
     240:      	movpl	r2, #0x0
     242:      	lsls	r0, r5, #0x1d
     244:      	ite	mi
     246:      	ldrhmi	r3, [r4], #2
     24a:      	movpl	r3, #0x0
     24c:      	lsls	r0, r5, #0x1c
     24e:      	it	mi
     250:      	ldrhmi	r8, [r4], #2
     254:      	lsls	r0, r5, #0x1b
     256:      	itt	mi
     258:      	addmi.w	r0, r11, r2, lsl #3
     25c:      	ldrhmi	r2, [r0, #0x4]
     25e:      	lsls	r0, r5, #0x1a
     260:      	itt	mi
     262:      	addmi.w	r0, r11, r3, lsl #3
     266:      	ldrhmi	r3, [r0, #0x4]
     268:      	ldr.w	r0, [r11, r8, lsl #3]
     26c:      	strh.w	r3, [sp, #0x12]
     270:      	strh.w	r2, [sp, #0x10]
     274:      	str	r1, [sp, #0xc]
     276:      	add.w	r1, r11, r8, lsl #3
     27a:      	str.w	r10, [sp, #0x8]
     27e:      	ldr	r2, [r1, #0x4]
     280:      	add	r1, sp, #0x4
     282:      	str	r6, [sp, #0x4]
     284:      	blx	r2
     286:      	cbnz	r0, 0x2aa <core::fmt::write+0xf8> @ imm = #0x20
     288:      	add.w	r8, r8, #0x1
     28c:      	mov	r2, r4
     28e:      	b	0x1d8 <core::fmt::write+0x26> @ imm = #-0xba
     290:      	lsr.w	r3, r11, #0x1
     294:      	mov	r1, r2
     296:      	ldr.w	r12, [r10, #0xc]
     29a:      	mov	r0, r6
     29c:      	mov	r2, r3
     29e:      	add	sp, #0x14
     2a0:      	pop.w	{r8, r9, r10, r11}
     2a4:      	pop.w	{r4, r5, r6, r7, lr}
     2a8:      	bx	r12
     2aa:      	movs	r0, #0x1
     2ac:      	add	sp, #0x14
     2ae:      	pop.w	{r8, r9, r10, r11}
     2b2:      	pop	{r4, r5, r6, r7, pc}
     2b4:      	movs	r0, #0x0
     2b6:      	add	sp, #0x14
     2b8:      	pop.w	{r8, r9, r10, r11}
     2bc:      	pop	{r4, r5, r6, r7, pc}
     2be:      	bmi	0x26a <core::fmt::write+0xb8> @ imm = #-0x58

000002c0 <<core::fmt::Formatter>::pad>:
     2c0:      	push	{r4, r5, r6, r7, lr}
     2c2:      	add	r7, sp, #0xc
     2c4:      	push.w	{r8, r9, r10, r11}
     2c8:      	sub	sp, #0x1c
     2ca:      	ldr.w	r9, [r0, #0x8]
     2ce:      	mov	r10, r1
     2d0:      	mov	r4, r0
     2d2:      	tst.w	r9, #0x18000000
     2d6:      	beq.w	0x86a <<core::fmt::Formatter>::pad+0x5aa> @ imm = #0x590
     2da:      	lsls.w	r1, r9, #0x3
     2de:      	bmi	0x366 <<core::fmt::Formatter>::pad+0xa6> @ imm = #0x84
     2e0:      	cmp	r2, #0x10
     2e2:      	str	r2, [sp, #0xc]
     2e4:      	bhs	0x3aa <<core::fmt::Formatter>::pad+0xea> @ imm = #0xc2
     2e6:      	cmp	r2, #0x0
     2e8:      	beq.w	0x3f2 <<core::fmt::Formatter>::pad+0x132> @ imm = #0x106
     2ec:      	and	r12, r2, #0x3
     2f0:      	lsrs	r1, r2, #0x2
     2f2:      	mov.w	r3, #0x0
     2f6:      	beq.w	0x806 <<core::fmt::Formatter>::pad+0x546> @ imm = #0x50c
     2fa:      	and	r0, r1, #0x3
     2fe:      	add.w	r6, r10, #0x1
     302:      	mov	lr, r4
     304:      	mvn	r5, #0x3
     308:      	sub.w	r3, r3, r0, lsl #2
     30c:      	mov.w	r8, #0x0
     310:      	adds	r0, r6, r5
     312:      	mov	r4, r5
     314:      	ldrsb.w	r5, [r0, #0x3]
     318:      	ldrsb.w	r1, [r0, #0x6]
     31c:      	ldrsb.w	r2, [r0, #0x5]
     320:      	cmn.w	r5, #0x41
     324:      	ldrsb.w	r0, [r0, #0x4]
     328:      	it	gt
     32a:      	addgt.w	r8, r8, #0x1
     32e:      	adds	r5, r4, #0x4
     330:      	cmn.w	r0, #0x41
     334:      	it	gt
     336:      	addgt.w	r8, r8, #0x1
     33a:      	cmn.w	r2, #0x41
     33e:      	it	gt
     340:      	addgt.w	r8, r8, #0x1
     344:      	cmn.w	r1, #0x41
     348:      	add.w	r0, r3, r5
     34c:      	it	gt
     34e:      	addgt.w	r8, r8, #0x1
     352:      	adds	r0, #0x4
     354:      	bne	0x310 <<core::fmt::Formatter>::pad+0x50> @ imm = #-0x48
     356:      	cmp.w	r12, #0x0
     35a:      	beq.w	0x844 <<core::fmt::Formatter>::pad+0x584> @ imm = #0x4e6
     35e:      	add.w	r3, r4, #0x8
     362:      	mov	r4, lr
     364:      	b	0x80a <<core::fmt::Formatter>::pad+0x54a> @ imm = #0x4a2
     366:      	ldrh.w	r12, [r4, #0xe]
     36a:      	cmp.w	r12, #0x0
     36e:      	beq	0x3ca <<core::fmt::Formatter>::pad+0x10a> @ imm = #0x58
     370:      	add.w	r3, r10, r2
     374:      	mov	lr, r4
     376:      	movs	r1, #0x0
     378:      	mov	r5, r10
     37a:      	mov	r2, r12
     37c:      	b	0x390 <<core::fmt::Formatter>::pad+0xd0> @ imm = #0x10
     37e:      	movs	r0, #0x3
     380:      	cmp	r5, #0xef
     382:      	it	hi
     384:      	movhi	r0, #0x4
     386:      	adds	r5, r6, r0
     388:      	subs	r0, r5, r6
     38a:      	subs	r2, #0x1
     38c:      	add	r1, r0
     38e:      	beq	0x3d6 <<core::fmt::Formatter>::pad+0x116> @ imm = #0x44
     390:      	cmp	r5, r3
     392:      	beq	0x3d8 <<core::fmt::Formatter>::pad+0x118> @ imm = #0x42
     394:      	mov	r6, r5
     396:      	ldrsb	r4, [r5], #1
     39a:      	cmp.w	r4, #0xffffffff
     39e:      	bgt	0x388 <<core::fmt::Formatter>::pad+0xc8> @ imm = #-0x1a
     3a0:      	uxtb	r5, r4
     3a2:      	cmp	r5, #0xe0
     3a4:      	bhs	0x37e <<core::fmt::Formatter>::pad+0xbe> @ imm = #-0x2a
     3a6:      	adds	r5, r6, #0x2
     3a8:      	b	0x388 <<core::fmt::Formatter>::pad+0xc8> @ imm = #-0x24
     3aa:      	add.w	r1, r10, #0x3
     3ae:      	str.w	r9, [sp, #0x8]
     3b2:      	bic	r5, r1, #0x3
     3b6:      	str	r4, [sp]
     3b8:      	subs.w	lr, r5, r10
     3bc:      	sub.w	r8, r2, lr
     3c0:      	and	r0, r8, #0x3
     3c4:      	bne	0x3e2 <<core::fmt::Formatter>::pad+0x122> @ imm = #0x1a
     3c6:      	movs	r1, #0x0
     3c8:      	b	0x47c <<core::fmt::Formatter>::pad+0x1bc> @ imm = #0xb0
     3ca:      	movs	r0, #0x0
     3cc:      	movs	r2, #0x0
     3ce:      	str	r0, [sp, #0xc]
     3d0:      	sub.w	r8, r12, r2
     3d4:      	b	0x846 <<core::fmt::Formatter>::pad+0x586> @ imm = #0x46e
     3d6:      	movs	r2, #0x0
     3d8:      	str	r1, [sp, #0xc]
     3da:      	mov	r4, lr
     3dc:      	sub.w	r8, r12, r2
     3e0:      	b	0x846 <<core::fmt::Formatter>::pad+0x586> @ imm = #0x462
     3e2:      	sub.w	r1, r10, r5
     3e6:      	cmn.w	r1, #0x4
     3ea:      	bls	0x3f8 <<core::fmt::Formatter>::pad+0x138> @ imm = #0xa
     3ec:      	movs	r3, #0x0
     3ee:      	movs	r1, #0x0
     3f0:      	b	0x448 <<core::fmt::Formatter>::pad+0x188> @ imm = #0x54
     3f2:      	mov.w	r8, #0x0
     3f6:      	b	0x846 <<core::fmt::Formatter>::pad+0x586> @ imm = #0x44c
     3f8:      	add.w	r11, r10, #0x1
     3fc:      	str	r0, [sp, #0x18]
     3fe:      	mov	r0, r10
     400:      	movs	r1, #0x0
     402:      	mvn	r2, #0x3
     406:      	add.w	r3, r11, r2
     40a:      	ldrsb.w	r6, [r3, #0x3]
     40e:      	ldrsb.w	r4, [r3, #0x6]
     412:      	ldrsb.w	r12, [r3, #0x5]
     416:      	cmn.w	r6, #0x41
     41a:      	ldrsb.w	r3, [r3, #0x4]
     41e:      	it	gt
     420:      	addgt	r1, #0x1
     422:      	adds	r6, r2, #0x4
     424:      	cmn.w	r3, #0x41
     428:      	it	gt
     42a:      	addgt	r1, #0x1
     42c:      	cmn.w	r12, #0x41
     430:      	it	gt
     432:      	addgt	r1, #0x1
     434:      	cmn.w	r4, #0x41
     438:      	it	gt
     43a:      	addgt	r1, #0x1
     43c:      	adds.w	r3, r2, #0x8
     440:      	mov	r2, r6
     442:      	bne	0x406 <<core::fmt::Formatter>::pad+0x146> @ imm = #-0x40
     444:      	mov	r10, r0
     446:      	ldr	r0, [sp, #0x18]
     448:      	ldrsb.w	r2, [r10, r3]
     44c:      	cmn.w	r2, #0x41
     450:      	it	gt
     452:      	addgt	r1, #0x1
     454:      	cmp.w	lr, #0x1
     458:      	beq	0x47c <<core::fmt::Formatter>::pad+0x1bc> @ imm = #0x20
     45a:      	add.w	r2, r10, r3
     45e:      	ldrsb.w	r3, [r2, #0x1]
     462:      	cmn.w	r3, #0x41
     466:      	it	gt
     468:      	addgt	r1, #0x1
     46a:      	cmp.w	lr, #0x2
     46e:      	beq	0x47c <<core::fmt::Formatter>::pad+0x1bc> @ imm = #0xa
     470:      	ldrsb.w	r2, [r2, #0x2]
     474:      	cmn.w	r2, #0x41
     478:      	it	gt
     47a:      	addgt	r1, #0x1
     47c:      	movw	r12, #0xfffc
     480:      	lsr.w	r9, r8, #0x2
     484:      	movt	r12, #0x1fff
     488:      	movs	r6, #0x0
     48a:      	str.w	r10, [sp, #0x4]
     48e:      	cbz	r0, 0x4c6 <<core::fmt::Formatter>::pad+0x206> @ imm = #0x34
     490:      	add.w	r2, r12, #0x60000000
     494:      	and.w	r2, r2, r8
     498:      	add	r2, r5
     49a:      	ldrsb.w	r4, [r2]
     49e:      	cmn.w	r4, #0x41
     4a2:      	it	gt
     4a4:      	movgt	r6, #0x1
     4a6:      	cmp	r0, #0x1
     4a8:      	beq	0x4c6 <<core::fmt::Formatter>::pad+0x206> @ imm = #0x1a
     4aa:      	ldrsb.w	r4, [r2, #0x1]
     4ae:      	cmn.w	r4, #0x41
     4b2:      	it	gt
     4b4:      	addgt	r6, #0x1
     4b6:      	cmp	r0, #0x2
     4b8:      	beq	0x4c6 <<core::fmt::Formatter>::pad+0x206> @ imm = #0xa
     4ba:      	ldrsb.w	r2, [r2, #0x2]
     4be:      	cmn.w	r2, #0x41
     4c2:      	it	gt
     4c4:      	addgt	r6, #0x1
     4c6:      	add.w	r8, r6, r1
     4ca:      	mvn	r11, #0xf
     4ce:      	b	0x4f6 <<core::fmt::Formatter>::pad+0x236> @ imm = #0x24
     4d0:      	mov.w	lr, #0x0
     4d4:      	uxtb16	r0, lr
     4d8:      	uxtb16	r1, lr, ror #8
     4dc:      	add	r0, r1
     4de:      	sub.w	r9, r9, r2
     4e2:      	add.w	r5, r4, r2, lsl #2
     4e6:      	ands	r6, r2, #0x3
     4ea:      	add.w	r0, r0, r0, lsl #16
     4ee:      	add.w	r8, r8, r0, lsr #16
     4f2:      	bne.w	0x7a4 <<core::fmt::Formatter>::pad+0x4e4> @ imm = #0x2ae
     4f6:      	cmp.w	r9, #0x0
     4fa:      	beq.w	0x79a <<core::fmt::Formatter>::pad+0x4da> @ imm = #0x29c
     4fe:      	mov	r4, r5
     500:      	cmp.w	r9, #0xc0
     504:      	mov	r2, r9
     506:      	it	hs
     508:      	movhs	r2, #0xc0
     50a:      	cmp.w	r9, #0x4
     50e:      	blo	0x4d0 <<core::fmt::Formatter>::pad+0x210> @ imm = #-0x42
     510:      	add.w	r5, r11, r2, lsl #2
     514:      	movs	r0, #0x1
     516:      	cmp	r5, #0x30
     518:      	str	r2, [sp, #0x18]
     51a:      	add.w	r6, r0, r5, lsr #4
     51e:      	and	r10, r6, #0x3
     522:      	bhs	0x52c <<core::fmt::Formatter>::pad+0x26c> @ imm = #0x6
     524:      	mov.w	lr, #0x0
     528:      	mov	r5, r4
     52a:      	b	0x6a4 <<core::fmt::Formatter>::pad+0x3e4> @ imm = #0x176
     52c:      	and.w	r12, r12, r6
     530:      	mov.w	lr, #0x0
     534:      	mov	r5, r4
     536:      	str.w	r10, [sp, #0x10]
     53a:      	str	r4, [sp, #0x14]
     53c:      	ldm.w	r5, {r4, r6, r10, r11}
     540:      	subs.w	r12, r12, #0x4
     544:      	ldr	r3, [r5, #0x10]
     546:      	mvn.w	r0, r4
     54a:      	ldr	r1, [r5, #0x14]
     54c:      	lsr.w	r0, r0, #0x7
     550:      	orr.w	r0, r0, r4, lsr #6
     554:      	mvn.w	r4, r6
     558:      	bic	r0, r0, #0xfefefefe
     55c:      	lsr.w	r4, r4, #0x7
     560:      	orr.w	r6, r4, r6, lsr #6
     564:      	add	r0, lr
     566:      	bic	r4, r6, #0xfefefefe
     56a:      	ldr	r6, [r5, #0x18]
     56c:      	add	r0, r4
     56e:      	mvn.w	r4, r10
     572:      	lsr.w	r2, r4, #0x7
     576:      	ldr	r4, [r5, #0x38]
     578:      	orr.w	r2, r2, r10, lsr #6
     57c:      	ldr.w	lr, [r5, #0x3c]
     580:      	bic	r2, r2, #0xfefefefe
     584:      	add	r0, r2
     586:      	mvn.w	r2, r11
     58a:      	lsr.w	r2, r2, #0x7
     58e:      	orr.w	r2, r2, r11, lsr #6
     592:      	bic	r2, r2, #0xfefefefe
     596:      	add	r0, r2
     598:      	mvn.w	r2, r3
     59c:      	lsr.w	r2, r2, #0x7
     5a0:      	orr.w	r2, r2, r3, lsr #6
     5a4:      	ldr	r3, [r5, #0x1c]
     5a6:      	bic	r2, r2, #0xfefefefe
     5aa:      	add	r0, r2
     5ac:      	mvn.w	r2, r1
     5b0:      	lsr.w	r2, r2, #0x7
     5b4:      	orr.w	r1, r2, r1, lsr #6
     5b8:      	bic	r1, r1, #0xfefefefe
     5bc:      	ldr	r2, [r5, #0x20]
     5be:      	add	r0, r1
     5c0:      	mvn.w	r1, r6
     5c4:      	lsr.w	r1, r1, #0x7
     5c8:      	orr.w	r1, r1, r6, lsr #6
     5cc:      	ldr	r6, [r5, #0x24]
     5ce:      	bic	r1, r1, #0xfefefefe
     5d2:      	add	r0, r1
     5d4:      	mvn.w	r1, r3
     5d8:      	lsr.w	r1, r1, #0x7
     5dc:      	orr.w	r1, r1, r3, lsr #6
     5e0:      	ldr	r3, [r5, #0x28]
     5e2:      	bic	r1, r1, #0xfefefefe
     5e6:      	add	r0, r1
     5e8:      	mvn.w	r1, r2
     5ec:      	lsr.w	r1, r1, #0x7
     5f0:      	orr.w	r1, r1, r2, lsr #6
     5f4:      	ldr	r2, [r5, #0x2c]
     5f6:      	bic	r1, r1, #0xfefefefe
     5fa:      	add	r0, r1
     5fc:      	mvn.w	r1, r6
     600:      	lsr.w	r1, r1, #0x7
     604:      	orr.w	r1, r1, r6, lsr #6
     608:      	ldr	r6, [r5, #0x30]
     60a:      	bic	r1, r1, #0xfefefefe
     60e:      	add	r0, r1
     610:      	mvn.w	r1, r3
     614:      	lsr.w	r1, r1, #0x7
     618:      	orr.w	r1, r1, r3, lsr #6
     61c:      	ldr	r3, [r5, #0x34]
     61e:      	bic	r1, r1, #0xfefefefe
     622:      	add.w	r5, r5, #0x40
     626:      	add	r0, r1
     628:      	mvn.w	r1, r2
     62c:      	lsr.w	r1, r1, #0x7
     630:      	orr.w	r1, r1, r2, lsr #6
     634:      	bic	r1, r1, #0xfefefefe
     638:      	add	r0, r1
     63a:      	mvn.w	r1, r6
     63e:      	lsr.w	r1, r1, #0x7
     642:      	orr.w	r1, r1, r6, lsr #6
     646:      	bic	r1, r1, #0xfefefefe
     64a:      	add	r0, r1
     64c:      	mvn.w	r1, r3
     650:      	lsr.w	r1, r1, #0x7
     654:      	orr.w	r1, r1, r3, lsr #6
     658:      	bic	r1, r1, #0xfefefefe
     65c:      	add	r0, r1
     65e:      	mvn.w	r1, r4
     662:      	lsr.w	r1, r1, #0x7
     666:      	orr.w	r1, r1, r4, lsr #6
     66a:      	bic	r1, r1, #0xfefefefe
     66e:      	add	r0, r1
     670:      	mvn.w	r1, lr
     674:      	lsr.w	r1, r1, #0x7
     678:      	orr.w	r1, r1, lr, lsr #6
     67c:      	bic	r1, r1, #0xfefefefe
     680:      	add.w	lr, r1, r0
     684:      	bne.w	0x53c <<core::fmt::Formatter>::pad+0x27c> @ imm = #-0x14c
     688:      	ldr.w	r10, [sp, #0x10]
     68c:      	movw	r12, #0xfffc
     690:      	ldr	r4, [sp, #0x14]
     692:      	movt	r12, #0x1fff
     696:      	ldr	r2, [sp, #0x18]
     698:      	mvn	r11, #0xf
     69c:      	cmp.w	r10, #0x0
     6a0:      	beq.w	0x4d4 <<core::fmt::Formatter>::pad+0x214> @ imm = #-0x1d0
     6a4:      	ldm.w	r5, {r0, r1, r2, r3}
     6a8:      	cmp.w	r10, #0x1
     6ac:      	mvn.w	r6, r0
     6b0:      	lsr.w	r6, r6, #0x7
     6b4:      	orr.w	r0, r6, r0, lsr #6
     6b8:      	mvn.w	r6, r1
     6bc:      	bic	r0, r0, #0xfefefefe
     6c0:      	lsr.w	r6, r6, #0x7
     6c4:      	orr.w	r1, r6, r1, lsr #6
     6c8:      	add	r0, lr
     6ca:      	bic	r1, r1, #0xfefefefe
     6ce:      	add	r0, r1
     6d0:      	mvn.w	r1, r2
     6d4:      	lsr.w	r1, r1, #0x7
     6d8:      	orr.w	r1, r1, r2, lsr #6
     6dc:      	ldr	r2, [sp, #0x18]
     6de:      	bic	r1, r1, #0xfefefefe
     6e2:      	add	r0, r1
     6e4:      	mvn.w	r1, r3
     6e8:      	lsr.w	r1, r1, #0x7
     6ec:      	orr.w	r1, r1, r3, lsr #6
     6f0:      	bic	r1, r1, #0xfefefefe
     6f4:      	add.w	lr, r1, r0
     6f8:      	beq.w	0x4d4 <<core::fmt::Formatter>::pad+0x214> @ imm = #-0x228
     6fc:      	add.w	r3, r5, #0x10
     700:      	cmp.w	r10, #0x2
     704:      	ldm	r3, {r0, r1, r2, r3}
     706:      	mvn.w	r6, r0
     70a:      	lsr.w	r6, r6, #0x7
     70e:      	orr.w	r0, r6, r0, lsr #6
     712:      	mvn.w	r6, r1
     716:      	bic	r0, r0, #0xfefefefe
     71a:      	lsr.w	r6, r6, #0x7
     71e:      	orr.w	r1, r6, r1, lsr #6
     722:      	add	r0, lr
     724:      	bic	r1, r1, #0xfefefefe
     728:      	add	r0, r1
     72a:      	mvn.w	r1, r2
     72e:      	lsr.w	r1, r1, #0x7
     732:      	orr.w	r1, r1, r2, lsr #6
     736:      	ldr	r2, [sp, #0x18]
     738:      	bic	r1, r1, #0xfefefefe
     73c:      	add	r0, r1
     73e:      	mvn.w	r1, r3
     742:      	lsr.w	r1, r1, #0x7
     746:      	orr.w	r1, r1, r3, lsr #6
     74a:      	bic	r1, r1, #0xfefefefe
     74e:      	add.w	lr, r1, r0
     752:      	beq.w	0x4d4 <<core::fmt::Formatter>::pad+0x214> @ imm = #-0x282
     756:      	add.w	r3, r5, #0x20
     75a:      	ldm	r3, {r0, r1, r2, r3}
     75c:      	mvns	r6, r0
     75e:      	lsrs	r6, r6, #0x7
     760:      	orr.w	r0, r6, r0, lsr #6
     764:      	mvns	r6, r1
     766:      	bic	r0, r0, #0xfefefefe
     76a:      	lsrs	r6, r6, #0x7
     76c:      	orr.w	r1, r6, r1, lsr #6
     770:      	add	r0, lr
     772:      	bic	r1, r1, #0xfefefefe
     776:      	add	r0, r1
     778:      	mvns	r1, r2
     77a:      	lsrs	r1, r1, #0x7
     77c:      	orr.w	r1, r1, r2, lsr #6
     780:      	ldr	r2, [sp, #0x18]
     782:      	bic	r1, r1, #0xfefefefe
     786:      	add	r0, r1
     788:      	mvns	r1, r3
     78a:      	lsrs	r1, r1, #0x7
     78c:      	orr.w	r1, r1, r3, lsr #6
     790:      	bic	r1, r1, #0xfefefefe
     794:      	add.w	lr, r1, r0
     798:      	b	0x4d4 <<core::fmt::Formatter>::pad+0x214> @ imm = #-0x2c8
     79a:      	ldr.w	r9, [sp, #0x8]
     79e:      	ldrd	r4, r10, [sp]
     7a2:      	b	0x846 <<core::fmt::Formatter>::pad+0x586> @ imm = #0xa0
     7a4:      	and	r3, r2, #0xfc
     7a8:      	ldrd	r10, r9, [sp, #4]
     7ac:      	cmp	r6, #0x1
     7ae:      	ldr.w	r0, [r4, r3, lsl #2]
     7b2:      	mvn.w	r1, r0
     7b6:      	lsr.w	r1, r1, #0x7
     7ba:      	orr.w	r0, r1, r0, lsr #6
     7be:      	bic	r2, r0, #0xfefefefe
     7c2:      	beq	0x7f0 <<core::fmt::Formatter>::pad+0x530> @ imm = #0x2a
     7c4:      	add.w	r3, r4, r3, lsl #2
     7c8:      	cmp	r6, #0x2
     7ca:      	ldr	r0, [r3, #0x4]
     7cc:      	mvn.w	r1, r0
     7d0:      	lsr.w	r1, r1, #0x7
     7d4:      	orr.w	r0, r1, r0, lsr #6
     7d8:      	bic	r0, r0, #0xfefefefe
     7dc:      	add	r2, r0
     7de:      	beq	0x7f0 <<core::fmt::Formatter>::pad+0x530> @ imm = #0xe
     7e0:      	ldr	r0, [r3, #0x8]
     7e2:      	mvns	r1, r0
     7e4:      	lsrs	r1, r1, #0x7
     7e6:      	orr.w	r0, r1, r0, lsr #6
     7ea:      	bic	r0, r0, #0xfefefefe
     7ee:      	add	r2, r0
     7f0:      	uxtb16	r0, r2
     7f4:      	uxtb16	r1, r2, ror #8
     7f8:      	add	r0, r1
     7fa:      	ldr	r4, [sp]
     7fc:      	add.w	r0, r0, r0, lsl #16
     800:      	add.w	r8, r8, r0, lsr #16
     804:      	b	0x846 <<core::fmt::Formatter>::pad+0x586> @ imm = #0x3e
     806:      	mov.w	r8, #0x0
     80a:      	ldrsb.w	r0, [r10, r3]
     80e:      	cmn.w	r0, #0x41
     812:      	it	gt
     814:      	addgt.w	r8, r8, #0x1
     818:      	cmp.w	r12, #0x1
     81c:      	beq	0x846 <<core::fmt::Formatter>::pad+0x586> @ imm = #0x26
     81e:      	add	r3, r10
     820:      	ldrsb.w	r0, [r3, #0x1]
     824:      	cmn.w	r0, #0x41
     828:      	it	gt
     82a:      	addgt.w	r8, r8, #0x1
     82e:      	cmp.w	r12, #0x2
     832:      	beq	0x846 <<core::fmt::Formatter>::pad+0x586> @ imm = #0x10
     834:      	ldrsb.w	r0, [r3, #0x2]
     838:      	cmn.w	r0, #0x41
     83c:      	it	gt
     83e:      	addgt.w	r8, r8, #0x1
     842:      	b	0x846 <<core::fmt::Formatter>::pad+0x586> @ imm = #0x0
     844:      	mov	r4, lr
     846:      	ldrh	r2, [r4, #0xc]
     848:      	cmp	r8, r2
     84a:      	bhs	0x868 <<core::fmt::Formatter>::pad+0x5a8> @ imm = #0x1a
     84c:      	ubfx	r1, r9, #0x1d, #0x2
     850:      	sub.w	r8, r2, r8
     854:      	bfc	r9, #21, #11
     858:      	mov.w	r11, #0x0
     85c:      	tbb	[pc, r1]
     860: 13 02 0f 13  	.word	0x130f0213
     864:      	mov	r11, r8
     866:      	b	0x886 <<core::fmt::Formatter>::pad+0x5c6> @ imm = #0x1c
     868:      	ldr	r2, [sp, #0xc]
     86a:      	ldrd	r0, r1, [r4]
     86e:      	ldr	r3, [r1, #0xc]
     870:      	mov	r1, r10
     872:      	add	sp, #0x1c
     874:      	pop.w	{r8, r9, r10, r11}
     878:      	pop.w	{r4, r5, r6, r7, lr}
     87c:      	bx	r3
     87e:      	uxth.w	r0, r8
     882:      	lsr.w	r11, r0, #0x1
     886:      	ldrd	r5, r6, [r4]
     88a:      	movs	r4, #0x0
     88c:      	uxth.w	r0, r11
     890:      	uxth	r1, r4
     892:      	cmp	r1, r0
     894:      	bhs	0x8a6 <<core::fmt::Formatter>::pad+0x5e6> @ imm = #0xe
     896:      	ldr	r2, [r6, #0x10]
     898:      	mov	r0, r5
     89a:      	mov	r1, r9
     89c:      	blx	r2
     89e:      	adds	r4, #0x1
     8a0:      	cmp	r0, #0x0
     8a2:      	beq	0x88c <<core::fmt::Formatter>::pad+0x5cc> @ imm = #-0x1a
     8a4:      	b	0x8d0 <<core::fmt::Formatter>::pad+0x610> @ imm = #0x28
     8a6:      	ldr	r2, [sp, #0xc]
     8a8:      	mov	r0, r5
     8aa:      	ldr	r3, [r6, #0xc]
     8ac:      	mov	r1, r10
     8ae:      	blx	r3
     8b0:      	cbnz	r0, 0x8d0 <<core::fmt::Formatter>::pad+0x610> @ imm = #0x1c
     8b2:      	sub.w	r0, r8, r11
     8b6:      	movs	r4, #0x0
     8b8:      	uxth.w	r8, r0
     8bc:      	uxth	r0, r4
     8be:      	cmp	r0, r8
     8c0:      	bhs	0x8da <<core::fmt::Formatter>::pad+0x61a> @ imm = #0x16
     8c2:      	ldr	r2, [r6, #0x10]
     8c4:      	mov	r0, r5
     8c6:      	mov	r1, r9
     8c8:      	blx	r2
     8ca:      	adds	r4, #0x1
     8cc:      	cmp	r0, #0x0
     8ce:      	beq	0x8bc <<core::fmt::Formatter>::pad+0x5fc> @ imm = #-0x16
     8d0:      	movs	r0, #0x1
     8d2:      	add	sp, #0x1c
     8d4:      	pop.w	{r8, r9, r10, r11}
     8d8:      	pop	{r4, r5, r6, r7, pc}
     8da:      	movs	r0, #0x0
     8dc:      	add	sp, #0x1c
     8de:      	pop.w	{r8, r9, r10, r11}
     8e2:      	pop	{r4, r5, r6, r7, pc}

000008e4 <<core::fmt::Formatter>::pad_integral::write_prefix>:
     8e4:      	push	{r4, r5, r6, r7, lr}
     8e6:      	add	r7, sp, #0xc
     8e8:      	str	r11, [sp, #-4]!
     8ec:      	mov	r5, r0
     8ee:      	mov	r4, r3
     8f0:      	mov	r6, r1
     8f2:      	adds	r0, r2, #0x1
     8f4:      	beq	0x908 <<core::fmt::Formatter>::pad_integral::write_prefix+0x24> @ imm = #0x10
     8f6:      	ldr	r3, [r6, #0x10]
     8f8:      	mov	r0, r5
     8fa:      	mov	r1, r2
     8fc:      	blx	r3
     8fe:      	cbz	r0, 0x908 <<core::fmt::Formatter>::pad_integral::write_prefix+0x24> @ imm = #0x6
     900:      	movs	r0, #0x1
     902:      	ldr	r11, [sp], #4
     906:      	pop	{r4, r5, r6, r7, pc}
     908:      	cbz	r4, 0x91c <<core::fmt::Formatter>::pad_integral::write_prefix+0x38> @ imm = #0x10
     90a:      	ldr	r3, [r6, #0xc]
     90c:      	mov	r0, r5
     90e:      	mov	r1, r4
     910:      	movs	r2, #0x0
     912:      	ldr	r11, [sp], #4
     916:      	pop.w	{r4, r5, r6, r7, lr}
     91a:      	bx	r3
     91c:      	movs	r0, #0x0
     91e:      	ldr	r11, [sp], #4
     922:      	pop	{r4, r5, r6, r7, pc}

00000924 <core::panicking::panic>:
     924:      	push	{r7, lr}
     926:      	mov	r7, sp
     928:      	mov	r2, r1
     92a:      	movs	r1, #0x57
     92c:      	bl	0x196 <core::panicking::panic_fmt> @ imm = #-0x79a

00000930 <core::option::unwrap_failed>:
     930:      	push	{r7, lr}
     932:      	mov	r7, sp
     934:      	movw	r0, #0x16ac
     938:      	movw	r1, #0x183c
     93c:      	movt	r0, #0x0
     940:      	movt	r1, #0x0
     944:      	bl	0x924 <core::panicking::panic> @ imm = #-0x24

00000948 <<u32 as core::fmt::Display>::fmt>:
     948:      	push	{r4, r5, r6, r7, lr}
     94a:      	add	r7, sp, #0xc
     94c:      	push.w	{r8, r9, r10, r11}
     950:      	sub	sp, #0x1c
     952:      	ldr	r5, [r0]
     954:      	movw	r0, #0x16d7
     958:      	mov	r4, r1
     95a:      	movt	r0, #0x0
     95e:      	cmp.w	r5, #0x3e8
     962:      	blo	0x9d6 <<u32 as core::fmt::Display>::fmt+0x8e> @ imm = #0x70
     964:      	movw	lr, #0x967f
     968:      	sub.w	r11, r7, #0x26
     96c:      	movs	r3, #0x0
     96e:      	movw	r8, #0x2710
     972:      	movw	r9, #0x147b
     976:      	mov.w	r10, #0x64
     97a:      	movt	lr, #0x98
     97e:      	mov	r6, r5
     980:      	str	r4, [sp, #0x8]
     982:      	str	r5, [sp, #0xc]
     984:      	movw	r1, #0x1759
     988:      	mov	r2, r6
     98a:      	movt	r1, #0xd1b7
     98e:      	add.w	r5, r11, r3
     992:      	umull	r6, r4, r6, r1
     996:      	subs	r3, #0x4
     998:      	cmp	r2, lr
     99a:      	lsr.w	r6, r4, #0xd
     99e:      	mls	r4, r6, r8, r2
     9a2:      	uxth.w	r12, r4
     9a6:      	lsr.w	r1, r12, #0x2
     9aa:      	mul	r1, r1, r9
     9ae:      	lsr.w	r1, r1, #0x11
     9b2:      	mls	r4, r1, r10, r4
     9b6:      	ldrh.w	r1, [r0, r1, lsl #1]
     9ba:      	strh	r1, [r5, #0x6]
     9bc:      	uxth	r4, r4
     9be:      	ldrh.w	r4, [r0, r4, lsl #1]
     9c2:      	strh	r4, [r5, #0x8]
     9c4:      	bhi	0x984 <<u32 as core::fmt::Display>::fmt+0x3c> @ imm = #-0x44
     9c6:      	ldrd	r4, r5, [sp, #8]
     9ca:      	adds	r3, #0xa
     9cc:      	cmp	r6, #0x9
     9ce:      	bhi	0x9de <<u32 as core::fmt::Display>::fmt+0x96> @ imm = #0xc
     9d0:      	mov	r2, r6
     9d2:      	cbnz	r5, 0xa00 <<u32 as core::fmt::Display>::fmt+0xb8> @ imm = #0x2a
     9d4:      	b	0xa02 <<u32 as core::fmt::Display>::fmt+0xba> @ imm = #0x2a
     9d6:      	movs	r3, #0xa
     9d8:      	mov	r6, r5
     9da:      	cmp	r6, #0x9
     9dc:      	bls	0x9d0 <<u32 as core::fmt::Display>::fmt+0x88> @ imm = #-0x10
     9de:      	uxth	r1, r6
     9e0:      	movw	r2, #0x147b
     9e4:      	lsrs	r1, r1, #0x2
     9e6:      	subs	r3, #0x2
     9e8:      	muls	r1, r2, r1
     9ea:      	lsrs	r2, r1, #0x11
     9ec:      	movs	r1, #0x64
     9ee:      	mls	r1, r2, r1, r6
     9f2:      	sub.w	r6, r7, #0x26
     9f6:      	uxth	r1, r1
     9f8:      	ldrh.w	r1, [r0, r1, lsl #1]
     9fc:      	strh	r1, [r6, r3]
     9fe:      	cbz	r5, 0xa02 <<u32 as core::fmt::Display>::fmt+0xba> @ imm = #0x0
     a00:      	cbz	r2, 0xa10 <<u32 as core::fmt::Display>::fmt+0xc8> @ imm = #0xc
     a02:      	add.w	r0, r0, r2, lsl #1
     a06:      	subs	r3, #0x1
     a08:      	sub.w	r1, r7, #0x26
     a0c:      	ldrb	r0, [r0, #0x1]
     a0e:      	strb	r0, [r1, r3]
     a10:      	ldr	r6, [r4, #0x8]
     a12:      	sub.w	r0, r7, #0x26
     a16:      	add.w	r10, r0, r3
     a1a:      	rsb.w	r1, r3, #0xa
     a1e:      	ands	r0, r6, #0x200000
     a22:      	ldrh.w	r8, [r4, #0xc]
     a26:      	ubfx	r3, r6, #0x17, #0x1
     a2a:      	mov.w	r11, #0x2b
     a2e:      	add.w	r9, r1, r0, lsr #21
     a32:      	it	eq
     a34:      	moveq.w	r11, #0xffffffff
     a38:      	cmp	r9, r8
     a3a:      	str	r1, [sp, #0xc]
     a3c:      	bhs	0xa60 <<u32 as core::fmt::Display>::fmt+0x118> @ imm = #0x20
     a3e:      	lsls	r0, r6, #0x7
     a40:      	bmi	0xa7a <<u32 as core::fmt::Display>::fmt+0x132> @ imm = #0x36
     a42:      	ubfx	r0, r6, #0x1d, #0x2
     a46:      	str	r3, [sp, #0x8]
     a48:      	sub.w	r2, r8, r9
     a4c:      	bfc	r6, #21, #11
     a50:      	mov.w	r8, #0x0
     a54:      	tbb	[pc, r0]
     a58: 58 02 55 02  	.word	0x02550258
     a5c:      	mov	r8, r2
     a5e:      	b	0xb08 <<u32 as core::fmt::Display>::fmt+0x1c0> @ imm = #0xa6
     a60:      	ldrd	r4, r5, [r4]
     a64:      	mov	r2, r11
     a66:      	mov	r1, r5
     a68:      	mov	r0, r4
     a6a:      	bl	0x8e4 <<core::fmt::Formatter>::pad_integral::write_prefix> @ imm = #-0x18a
     a6e:      	cbz	r0, 0xab2 <<u32 as core::fmt::Display>::fmt+0x16a> @ imm = #0x40
     a70:      	movs	r0, #0x1
     a72:      	add	sp, #0x1c
     a74:      	pop.w	{r8, r9, r10, r11}
     a78:      	pop	{r4, r5, r6, r7, pc}
     a7a:      	ldrd	r6, r0, [r4, #8]
     a7e:      	mov	r2, r11
     a80:      	str.w	r10, [sp, #0x4]
     a84:      	str	r0, [sp]
     a86:      	movs	r0, #0x0
     a88:      	movt	r0, #0x9fe0
     a8c:      	ldrd	r10, r5, [r4]
     a90:      	ands	r0, r6
     a92:      	mov	r1, r5
     a94:      	orr	r0, r0, #0x20000000
     a98:      	str	r4, [sp, #0x8]
     a9a:      	orr	r0, r0, #0x30
     a9e:      	str	r0, [r4, #0x8]
     aa0:      	mov	r0, r10
     aa2:      	bl	0x8e4 <<core::fmt::Formatter>::pad_integral::write_prefix> @ imm = #-0x1c2
     aa6:      	cbz	r0, 0xac4 <<u32 as core::fmt::Display>::fmt+0x17c> @ imm = #0x1a
     aa8:      	movs	r0, #0x1
     aaa:      	add	sp, #0x1c
     aac:      	pop.w	{r8, r9, r10, r11}
     ab0:      	pop	{r4, r5, r6, r7, pc}
     ab2:      	ldr	r2, [sp, #0xc]
     ab4:      	mov	r0, r4
     ab6:      	ldr	r3, [r5, #0xc]
     ab8:      	mov	r1, r10
     aba:      	blx	r3
     abc:      	add	sp, #0x1c
     abe:      	pop.w	{r8, r9, r10, r11}
     ac2:      	pop	{r4, r5, r6, r7, pc}
     ac4:      	sub.w	r0, r8, r9
     ac8:      	mov	r11, r6
     aca:      	movs	r6, #0x0
     acc:      	uxth	r4, r0
     ace:      	uxth	r0, r6
     ad0:      	cmp	r0, r4
     ad2:      	bhs	0xaec <<u32 as core::fmt::Display>::fmt+0x1a4> @ imm = #0x16
     ad4:      	ldr	r2, [r5, #0x10]
     ad6:      	mov	r0, r10
     ad8:      	movs	r1, #0x30
     ada:      	blx	r2
     adc:      	adds	r6, #0x1
     ade:      	cmp	r0, #0x0
     ae0:      	beq	0xace <<u32 as core::fmt::Display>::fmt+0x186> @ imm = #-0x16
     ae2:      	movs	r0, #0x1
     ae4:      	add	sp, #0x1c
     ae6:      	pop.w	{r8, r9, r10, r11}
     aea:      	pop	{r4, r5, r6, r7, pc}
     aec:      	ldr	r1, [sp, #0x4]
     aee:      	mov	r0, r10
     af0:      	ldr	r2, [sp, #0xc]
     af2:      	ldr	r3, [r5, #0xc]
     af4:      	blx	r3
     af6:      	cbz	r0, 0xb64 <<u32 as core::fmt::Display>::fmt+0x21c> @ imm = #0x6a
     af8:      	movs	r0, #0x1
     afa:      	add	sp, #0x1c
     afc:      	pop.w	{r8, r9, r10, r11}
     b00:      	pop	{r4, r5, r6, r7, pc}
     b02:      	uxth	r0, r2
     b04:      	lsr.w	r8, r0, #0x1
     b08:      	ldrd	r5, r9, [r4]
     b0c:      	movs	r4, #0x0
     b0e:      	str	r2, [sp, #0x4]
     b10:      	uxth.w	r0, r8
     b14:      	uxth	r1, r4
     b16:      	cmp	r1, r0
     b18:      	bhs	0xb34 <<u32 as core::fmt::Display>::fmt+0x1ec> @ imm = #0x18
     b1a:      	ldr.w	r2, [r9, #0x10]
     b1e:      	mov	r0, r5
     b20:      	mov	r1, r6
     b22:      	blx	r2
     b24:      	adds	r4, #0x1
     b26:      	cmp	r0, #0x0
     b28:      	beq	0xb10 <<u32 as core::fmt::Display>::fmt+0x1c8> @ imm = #-0x1c
     b2a:      	movs	r0, #0x1
     b2c:      	add	sp, #0x1c
     b2e:      	pop.w	{r8, r9, r10, r11}
     b32:      	pop	{r4, r5, r6, r7, pc}
     b34:      	ldr	r3, [sp, #0x8]
     b36:      	mov	r0, r5
     b38:      	mov	r1, r9
     b3a:      	mov	r2, r11
     b3c:      	bl	0x8e4 <<core::fmt::Formatter>::pad_integral::write_prefix> @ imm = #-0x25c
     b40:      	cbz	r0, 0xb4c <<u32 as core::fmt::Display>::fmt+0x204> @ imm = #0x8
     b42:      	movs	r0, #0x1
     b44:      	add	sp, #0x1c
     b46:      	pop.w	{r8, r9, r10, r11}
     b4a:      	pop	{r4, r5, r6, r7, pc}
     b4c:      	ldr	r2, [sp, #0xc]
     b4e:      	mov	r0, r5
     b50:      	ldr.w	r3, [r9, #0xc]
     b54:      	mov	r1, r10
     b56:      	blx	r3
     b58:      	cbz	r0, 0xb76 <<u32 as core::fmt::Display>::fmt+0x22e> @ imm = #0x1a
     b5a:      	movs	r0, #0x1
     b5c:      	add	sp, #0x1c
     b5e:      	pop.w	{r8, r9, r10, r11}
     b62:      	pop	{r4, r5, r6, r7, pc}
     b64:      	ldr	r0, [sp, #0x8]
     b66:      	ldr	r1, [sp]
     b68:      	strd	r11, r1, [r0, #8]
     b6c:      	movs	r0, #0x0
     b6e:      	add	sp, #0x1c
     b70:      	pop.w	{r8, r9, r10, r11}
     b74:      	pop	{r4, r5, r6, r7, pc}
     b76:      	ldr	r0, [sp, #0x4]
     b78:      	movs	r4, #0x0
     b7a:      	sub.w	r0, r0, r8
     b7e:      	uxth.w	r8, r0
     b82:      	uxth	r0, r4
     b84:      	cmp	r0, r8
     b86:      	bhs	0xb9e <<u32 as core::fmt::Display>::fmt+0x256> @ imm = #0x14
     b88:      	ldr.w	r2, [r9, #0x10]
     b8c:      	mov	r0, r5
     b8e:      	mov	r1, r6
     b90:      	blx	r2
     b92:      	adds	r4, #0x1
     b94:      	mov	r1, r0
     b96:      	movs	r0, #0x1
     b98:      	cmp	r1, #0x0
     b9a:      	beq	0xb82 <<u32 as core::fmt::Display>::fmt+0x23a> @ imm = #-0x1c
     b9c:      	b	0xa72 <<u32 as core::fmt::Display>::fmt+0x12a> @ imm = #-0x12e
     b9e:      	movs	r0, #0x0
     ba0:      	add	sp, #0x1c
     ba2:      	pop.w	{r8, r9, r10, r11}
     ba6:      	pop	{r4, r5, r6, r7, pc}

00000ba8 <core::cell::panic_already_borrowed>:
     ba8:      	push	{r7, lr}
     baa:      	mov	r7, sp
     bac:      	sub	sp, #0x10
     bae:      	mov	r2, r0
     bb0:      	movw	r0, #0xbcd
     bb4:      	movt	r0, #0x0
     bb8:      	add	r1, sp, #0x4
     bba:      	str	r0, [sp, #0x8]
     bbc:      	subs	r0, r7, #0x1
     bbe:      	str	r0, [sp, #0x4]
     bc0:      	movw	r0, #0x161c
     bc4:      	movt	r0, #0x0
     bc8:      	bl	0x196 <core::panicking::panic_fmt> @ imm = #-0xa36

00000bcc <<core::cell::BorrowMutError as core::fmt::Display>::fmt>:
     bcc:      	push	{r7, lr}
     bce:      	mov	r7, sp
     bd0:      	mov	r0, r1
     bd2:      	movw	r1, #0x17ad
     bd6:      	movt	r1, #0x0
     bda:      	movs	r2, #0x18
     bdc:      	pop.w	{r7, lr}
     be0:      	b.w	0x2c0 <<core::fmt::Formatter>::pad> @ imm = #-0x924

00000be4 <WDT>:
; pub unsafe extern "C" fn DefaultHandler_() -> ! {
     be4:      	push	{r7, lr}
     be6:      	mov	r7, sp
;     loop {}
     be8:      	b	0xbe8 <WDT+0x4>         @ imm = #-0x4

00000bea <rtt_init_must_not_be_called_multiple_times>:
; pub unsafe extern "C" fn DefaultPreInit() {}
     bea:      	push	{r7, lr}
     bec:      	mov	r7, sp
     bee:      	pop	{r7, pc}

00000bf0 <__rustc::rust_begin_unwind>:
; fn panic(info: &PanicInfo) -> ! {
     bf0:      	push	{r7, lr}
     bf2:      	mov	r7, sp
     bf4:      	sub	sp, #0x30
;         unsafe { *self.value.get() }
     bf6:      	movw	r6, #0x430
     bfa:      	str	r0, [sp, #0xc]
;     unsafe { asm!("mrs {}, PRIMASK", out(reg) r, options(nomem, nostack, preserves_flags)) };
     bfc:      	mrs	r0, primask
;         unsafe { *self.value.get() }
     c00:      	movt	r6, #0x2000
;     unsafe { asm!("cpsid i", options(nomem, nostack, preserves_flags)) };
     c04:      	cpsid i
;     unsafe { asm!("mrs {}, PRIMASK", out(reg) r, options(nomem, nostack, preserves_flags)) };
     c06:      	mrs	r9, primask
;     unsafe { asm!("cpsid i", options(nomem, nostack, preserves_flags)) };
     c0a:      	cpsid i
;         unsafe { *self.value.get() }
     c0c:      	ldr	r0, [r6, #0x4]
;         match borrow.get() {
     c0e:      	cmp	r0, #0x0
     c10:      	bne.w	0xeac <__rustc::rust_begin_unwind+0x2bc> @ imm = #0x298
;         if let Some(term) = &mut *PRINT_TERMINAL.borrow_ref_mut(cs) {
     c14:      	ldr	r1, [r6, #0x8]
;         crate::intrinsics::write_via_move(dest, src);
     c16:      	mov.w	r0, #0xffffffff
     c1a:      	str	r0, [r6, #0x4]
;         if let Some(term) = &mut *PRINT_TERMINAL.borrow_ref_mut(cs) {
     c1c:      	cmp	r1, #0x0
     c1e:      	beq.w	0xd24 <__rustc::rust_begin_unwind+0x134> @ imm = #0x102
;         unsafe { &mut *self.0 }
     c22:      	ldr	r0, [r6, #0xc]
     c24:      	movs	r2, #0x2
;             SeqCst => intrinsics::atomic_load::<T, { AO::SeqCst }, VOLATILE>(dst),
     c26:      	ldr	r1, [r0, #0x14]
     c28:      	dmb	sy
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
     c2c:      	dmb	sy
;             .store((self.flags.load(SeqCst) & !3) | mode as usize, SeqCst);
     c30:      	bfi	r1, r2, #0, #2
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
     c34:      	str	r1, [r0, #0x14]
     c36:      	dmb	sy
;         unsafe { &mut *self.0 }
     c3a:      	ldr	r4, [r6, #0xc]
;             SeqCst => intrinsics::atomic_load::<T, { AO::SeqCst }, VOLATILE>(dst),
     c3c:      	ldr	r5, [r4, #0xc]
     c3e:      	dmb	sy
     c42:      	ldr	r0, [r4, #0x10]
     c44:      	dmb	sy
;         if write >= self.size || read >= self.size {
     c48:      	ldr	r1, [r4, #0x8]
     c4a:      	cmp	r5, r1
     c4c:      	it	lo
     c4e:      	cmplo	r0, r1
     c50:      	blo	0xc68 <__rustc::rust_begin_unwind+0x78> @ imm = #0x14
     c52:      	movs	r5, #0x0
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
     c54:      	dmb	sy
     c58:      	str	r5, [r4, #0xc]
     c5a:      	dmb	sy
     c5e:      	dmb	sy
     c62:      	str	r5, [r4, #0x10]
     c64:      	dmb	sy
;         if number != self.current {
     c68:      	ldrb	r0, [r6, #0x10]
     c6a:      	mov.w	r11, #0x0
     c6e:      	cmp	r0, #0x0
     c70:      	beq	0xd28 <__rustc::rust_begin_unwind+0x138> @ imm = #0xb4
;         unsafe { &mut *self.0 }
     c72:      	ldr	r0, [r6, #0xc]
;             writer.write_with_mode(mode, &[0xff, TERMINAL_ID[(number & 0x0f) as usize]]);
     c74:      	movw	r1, #0x30ff
;             SeqCst => intrinsics::atomic_load::<T, { AO::SeqCst }, VOLATILE>(dst),
     c78:      	ldr	r0, [r0, #0x14]
     c7a:      	dmb	sy
;             writer.write_with_mode(mode, &[0xff, TERMINAL_ID[(number & 0x0f) as usize]]);
     c7e:      	strh.w	r1, [sp, #0x10]
;         let mode = self.flags.load(SeqCst) & 3;
     c82:      	and	r0, r0, #0x3
     c86:      	cmp	r0, #0x2
     c88:      	bne	0xd2e <__rustc::rust_begin_unwind+0x13e> @ imm = #0xa2
     c8a:      	add.w	r11, sp, #0x10
     c8e:      	str.w	r9, [sp, #0x4]
     c92:      	mov.w	r9, #0x2
     c96:      	mov.w	r8, #0x0
     c9a:      	movs	r1, #0x0
     c9c:      	b	0xccc <__rustc::rust_begin_unwind+0xdc> @ imm = #0x2c
;                 ptr::copy_nonoverlapping(buf.as_ptr(), self.chan.buffer.add(self.write), count);
     c9e:      	ldr	r0, [r4, #0x4]
     ca0:      	mov	r10, r6
     ca2:      	cmp	r9, r6
     ca4:      	it	lo
     ca6:      	movlo	r10, r9
;         unsafe { intrinsics::offset(self, count) }
     ca8:      	add	r0, r5
;     unsafe { crate::intrinsics::copy_nonoverlapping(src, dst, count) }
     caa:      	mov	r1, r11
     cac:      	mov	r2, r10
     cae:      	bl	0x1372 <__aeabi_memcpy> @ imm = #0x6c0
;             if self.write >= self.chan.size {
     cb2:      	ldr	r0, [r4, #0x8]
;             self.write += count;
     cb4:      	add	r5, r10
     cb6:      	movs	r2, #0x0
;     let ptr = unsafe { crate::intrinsics::offset(ptr, offset) };
     cb8:      	add	r11, r10
;             if self.write >= self.chan.size {
     cba:      	cmp	r5, r0
     cbc:      	it	hs
     cbe:      	movhs	r5, r2
     cc0:      	ldr	r1, [sp, #0x8]
     cc2:      	cmp	r9, r6
     cc4:      	mov.w	r9, #0x1
;             self.total += count;
     cc8:      	add	r1, r10
;         while self.state == WriteState::Writable && !buf.is_empty() {
     cca:      	bls	0xd6c <__rustc::rust_begin_unwind+0x17c> @ imm = #0x9e
     ccc:      	mvns	r0, r5
     cce:      	str	r1, [sp, #0x8]
;             SeqCst => intrinsics::atomic_load::<T, { AO::SeqCst }, VOLATILE>(dst),
     cd0:      	ldr	r3, [r4, #0xc]
     cd2:      	dmb	sy
     cd6:      	ldr	r2, [r4, #0x10]
     cd8:      	dmb	sy
;         if write >= self.size || read >= self.size {
     cdc:      	ldr	r1, [r4, #0x8]
     cde:      	cmp	r3, r1
     ce0:      	it	lo
     ce2:      	cmplo	r2, r1
     ce4:      	blo	0xd04 <__rustc::rust_begin_unwind+0x114> @ imm = #0x1c
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
     ce6:      	dmb	sy
     cea:      	str.w	r8, [r4, #0xc]
     cee:      	dmb	sy
     cf2:      	dmb	sy
     cf6:      	str.w	r8, [r4, #0x10]
     cfa:      	dmb	sy
;             self.chan.size - self.write - 1
     cfe:      	adds	r6, r1, r0
;             if count == 0 {
     d00:      	cbz	r6, 0xd18 <__rustc::rust_begin_unwind+0x128> @ imm = #0x14
     d02:      	b	0xc9e <__rustc::rust_begin_unwind+0xae> @ imm = #-0x68
;         if read > self.write {
     d04:      	cmp	r2, r5
     d06:      	bls	0xd0e <__rustc::rust_begin_unwind+0x11e> @ imm = #0x4
;             read - self.write - 1
     d08:      	adds	r6, r2, r0
;             if count == 0 {
     d0a:      	cbz	r6, 0xd18 <__rustc::rust_begin_unwind+0x128> @ imm = #0xa
     d0c:      	b	0xc9e <__rustc::rust_begin_unwind+0xae> @ imm = #-0x72
;         } else if read == 0 {
     d0e:      	cmp	r2, #0x0
     d10:      	beq	0xcfe <__rustc::rust_begin_unwind+0x10e> @ imm = #-0x16
;             self.chan.size - self.write
     d12:      	subs	r6, r1, r5
;             if count == 0 {
     d14:      	cmp	r6, #0x0
     d16:      	bne	0xc9e <__rustc::rust_begin_unwind+0xae> @ imm = #-0x7c
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
     d18:      	dmb	sy
     d1c:      	str	r5, [r4, #0xc]
     d1e:      	dmb	sy
;         while self.state == WriteState::Writable && !buf.is_empty() {
     d22:      	b	0xcd0 <__rustc::rust_begin_unwind+0xe0> @ imm = #-0x56
     d24:      	movs	r0, #0x0
;         if let Some(term) = &mut *PRINT_TERMINAL.borrow_ref_mut(cs) {
     d26:      	b	0xe9e <__rustc::rust_begin_unwind+0x2ae> @ imm = #0x174
     d28:      	movs	r1, #0x0
     d2a:      	movs	r2, #0x0
;         if number != self.current {
     d2c:      	b	0xe3a <__rustc::rust_begin_unwind+0x24a> @ imm = #0x10a
;             SeqCst => intrinsics::atomic_load::<T, { AO::SeqCst }, VOLATILE>(dst),
     d2e:      	ldr	r3, [r4, #0xc]
     d30:      	dmb	sy
     d34:      	ldr	r2, [r4, #0x10]
     d36:      	dmb	sy
;         if write >= self.size || read >= self.size {
     d3a:      	ldr	r0, [r4, #0x8]
     d3c:      	mvns	r1, r5
     d3e:      	cmp	r3, r0
     d40:      	it	lo
     d42:      	cmplo	r2, r0
     d44:      	blo	0xd7e <__rustc::rust_begin_unwind+0x18e> @ imm = #0x36
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
     d46:      	movs	r2, #0x0
     d48:      	dmb	sy
     d4c:      	str	r2, [r4, #0xc]
     d4e:      	dmb	sy
     d52:      	dmb	sy
     d56:      	str	r2, [r4, #0x10]
     d58:      	dmb	sy
;             self.chan.size - self.write - 1
     d5c:      	add.w	r10, r0, r1
     d60:      	movs	r2, #0x2
     d62:      	movs	r1, #0x0
;             if count == 0 {
     d64:      	cmp.w	r10, #0x0
     d68:      	bne	0xda4 <__rustc::rust_begin_unwind+0x1b4> @ imm = #0x38
     d6a:      	b	0xe36 <__rustc::rust_begin_unwind+0x246> @ imm = #0xc8
     d6c:      	movw	r6, #0x430
     d70:      	ldr.w	r9, [sp, #0x4]
     d74:      	movt	r6, #0x2000
     d78:      	mov.w	r11, #0x0
;         while self.state == WriteState::Writable && !buf.is_empty() {
     d7c:      	b	0xe36 <__rustc::rust_begin_unwind+0x246> @ imm = #0xb6
;         if read > self.write {
     d7e:      	cmp	r2, r5
     d80:      	bls	0xd92 <__rustc::rust_begin_unwind+0x1a2> @ imm = #0xe
;             read - self.write - 1
     d82:      	add.w	r10, r2, r1
     d86:      	movs	r2, #0x2
     d88:      	movs	r1, #0x0
;             if count == 0 {
     d8a:      	cmp.w	r10, #0x0
     d8e:      	bne	0xda4 <__rustc::rust_begin_unwind+0x1b4> @ imm = #0x12
     d90:      	b	0xe36 <__rustc::rust_begin_unwind+0x246> @ imm = #0xa2
;         } else if read == 0 {
     d92:      	cmp	r2, #0x0
     d94:      	beq	0xd5c <__rustc::rust_begin_unwind+0x16c> @ imm = #-0x3c
;             self.chan.size - self.write
     d96:      	sub.w	r10, r0, r5
     d9a:      	movs	r2, #0x2
     d9c:      	movs	r1, #0x0
;             if count == 0 {
     d9e:      	cmp.w	r10, #0x0
     da2:      	beq	0xe36 <__rustc::rust_begin_unwind+0x246> @ imm = #0x90
;                 ptr::copy_nonoverlapping(buf.as_ptr(), self.chan.buffer.add(self.write), count);
     da4:      	ldr	r0, [r4, #0x4]
     da6:      	add	r1, sp, #0x10
     da8:      	cmp.w	r10, #0x2
     dac:      	it	lo
     dae:      	movlo	r2, r10
;         unsafe { intrinsics::offset(self, count) }
     db0:      	add	r0, r5
     db2:      	mov	r8, r2
;     unsafe { crate::intrinsics::copy_nonoverlapping(src, dst, count) }
     db4:      	bl	0x1372 <__aeabi_memcpy> @ imm = #0x5ba
;             if self.write >= self.chan.size {
     db8:      	ldr	r0, [r4, #0x8]
;             self.write += count;
     dba:      	add	r5, r8
;             if self.write >= self.chan.size {
     dbc:      	cmp	r5, r0
     dbe:      	mov.w	r0, #0x0
     dc2:      	it	hs
     dc4:      	movhs	r5, r0
;         while self.state == WriteState::Writable && !buf.is_empty() {
     dc6:      	cmp.w	r10, #0x1
     dca:      	bne	0xe00 <__rustc::rust_begin_unwind+0x210> @ imm = #0x32
;             SeqCst => intrinsics::atomic_load::<T, { AO::SeqCst }, VOLATILE>(dst),
     dcc:      	ldr	r1, [r4, #0xc]
     dce:      	dmb	sy
     dd2:      	ldr	r2, [r4, #0x10]
     dd4:      	dmb	sy
;         if write >= self.size || read >= self.size {
     dd8:      	ldr	r0, [r4, #0x8]
     dda:      	mvn.w	r12, r5
     dde:      	cmp	r1, r0
     de0:      	it	lo
     de2:      	cmplo	r2, r0
     de4:      	blo	0xe04 <__rustc::rust_begin_unwind+0x214> @ imm = #0x1c
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
     de6:      	movs	r2, #0x0
     de8:      	dmb	sy
     dec:      	str	r2, [r4, #0xc]
;             self.chan.size - self.write - 1
     dee:      	add	r0, r12
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
     df0:      	dmb	sy
     df4:      	dmb	sy
     df8:      	str	r2, [r4, #0x10]
     dfa:      	dmb	sy
;         } else if read == 0 {
     dfe:      	b	0xe16 <__rustc::rust_begin_unwind+0x226> @ imm = #0x14
     e00:      	mov	r1, r8
     e02:      	b	0xe34 <__rustc::rust_begin_unwind+0x244> @ imm = #0x2e
;         if read > self.write {
     e04:      	cmp	r2, r5
     e06:      	bls	0xe0e <__rustc::rust_begin_unwind+0x21e> @ imm = #0x4
;             read - self.write - 1
     e08:      	add.w	r0, r2, r12
;         if read > self.write {
     e0c:      	b	0xe16 <__rustc::rust_begin_unwind+0x226> @ imm = #0x6
;         } else if read == 0 {
     e0e:      	cmp	r2, #0x0
;             self.chan.size - self.write
     e10:      	ite	ne
     e12:      	subne	r0, r0, r5
;             self.chan.size - self.write - 1
     e14:      	addeq	r0, r12
;             if count == 0 {
     e16:      	cmp	r0, #0x0
     e18:      	beq	0xea6 <__rustc::rust_begin_unwind+0x2b6> @ imm = #0x8a
;     unsafe { crate::intrinsics::copy_nonoverlapping(src, dst, count) }
     e1a:      	add	r1, sp, #0x10
;                 ptr::copy_nonoverlapping(buf.as_ptr(), self.chan.buffer.add(self.write), count);
     e1c:      	ldr	r0, [r4, #0x4]
;     unsafe { crate::intrinsics::copy_nonoverlapping(src, dst, count) }
     e1e:      	ldrb.w	r1, [r1, r8]
     e22:      	strb	r1, [r0, r5]
;             self.write += count;
     e24:      	adds	r5, #0x1
     e26:      	movs	r1, #0x0
;             if self.write >= self.chan.size {
     e28:      	ldr	r0, [r4, #0x8]
     e2a:      	cmp	r5, r0
     e2c:      	it	hs
     e2e:      	movhs	r5, r1
;             self.total += count;
     e30:      	add.w	r1, r8, #0x1
     e34:      	movs	r2, #0x0
;             self.current = number;
     e36:      	movs	r0, #0x0
     e38:      	strb	r0, [r6, #0x10]
;         TerminalWriter {
     e3a:      	add.w	r0, r6, #0x10
     e3e:      	str	r0, [sp, #0x10]
;             writeln!(channel, "{}", info).ok();
     e40:      	movw	r0, #0xeb9
;         TerminalWriter {
     e44:      	strb.w	r2, [sp, #0x20]
;             writeln!(channel, "{}", info).ok();
     e48:      	movt	r0, #0x0
;                     write(self, args)
     e4c:      	movw	r2, #0x1618
;             writeln!(channel, "{}", info).ok();
     e50:      	str	r0, [sp, #0x2c]
     e52:      	add	r0, sp, #0xc
;         TerminalWriter {
     e54:      	str	r1, [sp, #0x1c]
;                     write(self, args)
     e56:      	movw	r1, #0x17d8
;             writeln!(channel, "{}", info).ok();
     e5a:      	str	r0, [sp, #0x28]
     e5c:      	add	r0, sp, #0x10
     e5e:      	add	r3, sp, #0x28
;                     write(self, args)
     e60:      	movt	r1, #0x0
     e64:      	movt	r2, #0x0
;         TerminalWriter {
     e68:      	strb.w	r11, [sp, #0x24]
     e6c:      	strd	r4, r5, [sp, #20]
;                     write(self, args)
     e70:      	bl	0x1b2 <core::fmt::write> @ imm = #-0xcc2
; #[derive(Eq, PartialEq)]
     e74:      	ldrb.w	r0, [sp, #0x20]
;         if !self.writer.is_failed() {
     e78:      	cmp	r0, #0x2
     e7a:      	bne	0xe8c <__rustc::rust_begin_unwind+0x29c> @ imm = #0xe
;             *self.current = self.number;
     e7c:      	ldr	r0, [sp, #0x10]
     e7e:      	ldrb.w	r1, [sp, #0x24]
     e82:      	strb	r1, [r0]
;         match self.state {
     e84:      	ldrb.w	r0, [sp, #0x20]
     e88:      	cmp	r0, #0x2
     e8a:      	beq	0xe9a <__rustc::rust_begin_unwind+0x2aa> @ imm = #0xc
;                 self.chan.write.store(self.write, SeqCst);
     e8c:      	ldrd	r0, r1, [sp, #20]
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
     e90:      	dmb	sy
     e94:      	str	r1, [r0, #0xc]
     e96:      	dmb	sy
;         unsafe { *self.value.get() }
     e9a:      	ldr	r0, [r6, #0x4]
;         self.borrow.replace(borrow + 1);
     e9c:      	adds	r0, #0x1
;         crate::intrinsics::write_via_move(dest, src);
     e9e:      	str	r0, [r6, #0x4]
;     unsafe { asm!("msr PRIMASK, {}", in(reg) r, options(nomem, nostack, preserves_flags)) };
     ea0:      	msr	primask, r9
;             compiler_fence(Ordering::SeqCst);
     ea4:      	b	0xea4 <__rustc::rust_begin_unwind+0x2b4> @ imm = #-0x4
     ea6:      	mov	r1, r8
     ea8:      	movs	r2, #0x2
;             if count == 0 {
     eaa:      	b	0xe36 <__rustc::rust_begin_unwind+0x246> @ imm = #-0x78
;             Err(err) => panic_already_borrowed(err),
     eac:      	movw	r0, #0x17c8
     eb0:      	movt	r0, #0x0
     eb4:      	bl	0xba8 <core::cell::panic_already_borrowed> @ imm = #-0x310

00000eb8 <<&core::panic::panic_info::PanicInfo as core::fmt::Display>::fmt>:
;             fn fmt(&self, f: &mut Formatter<'_>) -> Result { $tr::fmt(&**self, f) }
     eb8:      	push	{r4, r5, r6, r7, lr}
     eba:      	add	r7, sp, #0xc
     ebc:      	push.w	{r8, r9, r11}
     ec0:      	sub	sp, #0x20
     ec2:      	ldrd	r5, r4, [r1]
     ec6:      	movw	r1, #0x179f
;             fn fmt(&self, f: &mut Formatter<'_>) -> Result { $tr::fmt(&**self, f) }
     eca:      	ldr	r0, [r0]
     ecc:      	movt	r1, #0x0
     ed0:      	ldr.w	r9, [r4, #0xc]
     ed4:      	movs	r2, #0xc
;             fn fmt(&self, f: &mut Formatter<'_>) -> Result { $tr::fmt(&**self, f) }
     ed6:      	ldrd	r8, r6, [r0]
     eda:      	mov	r0, r5
     edc:      	blx	r9
     ede:      	cbz	r0, 0xeea <<&core::panic::panic_info::PanicInfo as core::fmt::Display>::fmt+0x32> @ imm = #0x8
     ee0:      	movs	r0, #0x1
;             fn fmt(&self, f: &mut Formatter<'_>) -> Result { $tr::fmt(&**self, f) }
     ee2:      	add	sp, #0x20
     ee4:      	pop.w	{r8, r9, r11}
     ee8:      	pop	{r4, r5, r6, r7, pc}
     eea:      	ldrd	r0, r1, [r6]
     eee:      	movw	r2, #0x16a4
     ef2:      	strd	r0, r1, [sp]
     ef6:      	movw	r0, #0x949
     efa:      	add.w	r1, r6, #0xc
     efe:      	movt	r0, #0x0
     f02:      	str	r0, [sp, #0x1c]
     f04:      	add	r3, sp, #0x8
     f06:      	strd	r0, r1, [sp, #20]
     f0a:      	add.w	r0, r6, #0x8
     f0e:      	str	r0, [sp, #0x10]
     f10:      	movw	r0, #0x183
     f14:      	movt	r0, #0x0
     f18:      	movt	r2, #0x0
     f1c:      	str	r0, [sp, #0xc]
     f1e:      	mov	r0, sp
     f20:      	str	r0, [sp, #0x8]
     f22:      	mov	r0, r5
     f24:      	mov	r1, r4
     f26:      	bl	0x1b2 <core::fmt::write> @ imm = #-0xd78
     f2a:      	cbz	r0, 0xf36 <<&core::panic::panic_info::PanicInfo as core::fmt::Display>::fmt+0x7e> @ imm = #0x8
     f2c:      	movs	r0, #0x1
;             fn fmt(&self, f: &mut Formatter<'_>) -> Result { $tr::fmt(&**self, f) }
     f2e:      	add	sp, #0x20
     f30:      	pop.w	{r8, r9, r11}
     f34:      	pop	{r4, r5, r6, r7, pc}
     f36:      	movw	r1, #0x17ab
     f3a:      	mov	r0, r5
     f3c:      	movt	r1, #0x0
     f40:      	movs	r2, #0x2
     f42:      	blx	r9
     f44:      	cbz	r0, 0xf50 <<&core::panic::panic_info::PanicInfo as core::fmt::Display>::fmt+0x98> @ imm = #0x8
     f46:      	movs	r0, #0x1
;             fn fmt(&self, f: &mut Formatter<'_>) -> Result { $tr::fmt(&**self, f) }
     f48:      	add	sp, #0x20
     f4a:      	pop.w	{r8, r9, r11}
     f4e:      	pop	{r4, r5, r6, r7, pc}
     f50:      	ldrd	r2, r3, [r8]
     f54:      	mov	r0, r5
     f56:      	mov	r1, r4
     f58:      	bl	0x1b2 <core::fmt::write> @ imm = #-0xdaa
;             fn fmt(&self, f: &mut Formatter<'_>) -> Result { $tr::fmt(&**self, f) }
     f5c:      	add	sp, #0x20
     f5e:      	pop.w	{r8, r9, r11}
     f62:      	pop	{r4, r5, r6, r7, pc}

00000f64 <core::ptr::drop_glue::<rtt_target::TerminalWriter>>:
; pub(crate) const unsafe fn drop_glue<T: PointeeSized>(_: &mut T)
     f64:      	push	{r7, lr}
     f66:      	mov	r7, sp
; #[derive(Eq, PartialEq)]
     f68:      	ldrb	r1, [r0, #0x10]
;         if !self.writer.is_failed() {
     f6a:      	cmp	r1, #0x2
     f6c:      	bne	0xf76 <core::ptr::drop_glue::<rtt_target::TerminalWriter>+0x12> @ imm = #0x6
;             *self.current = self.number;
     f6e:      	ldr	r1, [r0]
     f70:      	ldrb	r0, [r0, #0x14]
     f72:      	strb	r0, [r1]
; pub(crate) const unsafe fn drop_glue<T: PointeeSized>(_: &mut T)
     f74:      	pop	{r7, pc}
;                 self.chan.write.store(self.write, SeqCst);
     f76:      	ldrd	r1, r2, [r0, #4]
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
     f7a:      	dmb	sy
     f7e:      	str	r2, [r1, #0xc]
;                 self.state = WriteState::Finished;
     f80:      	movs	r1, #0x2
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
     f82:      	dmb	sy
;                 self.state = WriteState::Finished;
     f86:      	strb	r1, [r0, #0x10]
; pub(crate) const unsafe fn drop_glue<T: PointeeSized>(_: &mut T)
     f88:      	pop	{r7, pc}

00000f8a <<rtt_target::TerminalWriter as core::fmt::Write>::write_char>:
;     fn write_char(&mut self, c: char) -> Result {
     f8a:      	push	{r4, r6, r7, lr}
     f8c:      	add	r7, sp, #0x8
     f8e:      	sub	sp, #0x8
;         self.write_str(c.encode_utf8(&mut [0; char::MAX_LEN_UTF8]))
     f90:      	movs	r2, #0x0
;         ..MAX_ONE_B => 1,
     f92:      	cmp	r1, #0x80
;         self.write_str(c.encode_utf8(&mut [0; char::MAX_LEN_UTF8]))
     f94:      	str	r2, [sp, #0x4]
;         ..MAX_ONE_B => 1,
     f96:      	bhs	0xfa0 <<rtt_target::TerminalWriter as core::fmt::Write>::write_char+0x16> @ imm = #0x6
;             *dst = code as u8;
     f98:      	strb.w	r1, [sp, #0x4]
     f9c:      	movs	r2, #0x1
     f9e:      	b	0x1004 <<rtt_target::TerminalWriter as core::fmt::Write>::write_char+0x7a> @ imm = #0x62
     fa0:      	movw	r12, #0xfffe
;         let last1 = (code >> 0 & 0x3F) as u8 | TAG_CONT;
     fa4:      	mov	r3, r1
     fa6:      	movt	r12, #0x3ff
;         let last2 = (code >> 6 & 0x3F) as u8 | TAG_CONT;
     faa:      	lsrs	r2, r1, #0x6
;         let last1 = (code >> 0 & 0x3F) as u8 | TAG_CONT;
     fac:      	bfi	r3, r12, #6, #26
;         if len == 2 {
     fb0:      	cmp.w	r1, #0x800
     fb4:      	bhs	0xfc6 <<rtt_target::TerminalWriter as core::fmt::Write>::write_char+0x3c> @ imm = #0xe
;             *dst = last2 | TAG_TWO_B;
     fb6:      	orr	r1, r2, #0xc0
;             *dst.add(1) = last1;
     fba:      	strb.w	r3, [sp, #0x5]
;             *dst = last2 | TAG_TWO_B;
     fbe:      	strb.w	r1, [sp, #0x4]
     fc2:      	movs	r2, #0x2
     fc4:      	b	0x1004 <<rtt_target::TerminalWriter as core::fmt::Write>::write_char+0x7a> @ imm = #0x3c
     fc6:      	bfi	r2, r12, #6, #26
     fca:      	lsr.w	lr, r1, #0xc
;         if len == 3 {
     fce:      	movs	r4, #0x0
     fd0:      	cmp.w	r4, r1, lsr #16
     fd4:      	bne	0xfe6 <<rtt_target::TerminalWriter as core::fmt::Write>::write_char+0x5c> @ imm = #0xe
;             *dst.add(1) = last2;
     fd6:      	strb.w	r2, [sp, #0x5]
;             *dst = last3 | TAG_THREE_B;
     fda:      	orr	r1, lr, #0xe0
;             *dst.add(2) = last1;
     fde:      	strb.w	r3, [sp, #0x6]
     fe2:      	movs	r2, #0x3
;             *dst = last3 | TAG_THREE_B;
     fe4:      	b	0x1000 <<rtt_target::TerminalWriter as core::fmt::Write>::write_char+0x76> @ imm = #0x18
;         *dst.add(2) = last2;
     fe6:      	strb.w	r2, [sp, #0x6]
     fea:      	movs	r2, #0x4
     fec:      	mvn	r4, #0xf
     ff0:      	orr.w	r1, r4, r1, lsr #18
     ff4:      	bfi	lr, r12, #6, #26
;         *dst.add(3) = last1;
     ff8:      	strb.w	r3, [sp, #0x7]
;         *dst.add(1) = last3;
     ffc:      	strb.w	lr, [sp, #0x5]
    1000:      	strb.w	r1, [sp, #0x4]
    1004:      	add	r1, sp, #0x4
;         self.write_str(c.encode_utf8(&mut [0; char::MAX_LEN_UTF8]))
    1006:      	bl	0x1028 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str> @ imm = #0x1e
;     }
    100a:      	movs	r0, #0x0
    100c:      	add	sp, #0x8
    100e:      	pop	{r4, r6, r7, pc}

00001010 <<rtt_target::TerminalWriter as core::fmt::Write>::write_fmt>:
;     fn write_fmt(&mut self, args: Arguments<'_>) -> Result {
    1010:      	push	{r7, lr}
    1012:      	mov	r7, sp
    1014:      	mov	r3, r2
    1016:      	mov	r2, r1
;                     write(self, args)
    1018:      	movw	r1, #0x17d8
    101c:      	movt	r1, #0x0
    1020:      	pop.w	{r7, lr}
    1024:      	b.w	0x1b2 <core::fmt::write> @ imm = #-0xe76

00001028 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str>:
;     fn write_str(&mut self, s: &str) -> Result<(), fmt::Error> {
    1028:      	push	{r4, r5, r6, r7, lr}
    102a:      	add	r7, sp, #0xc
    102c:      	push.w	{r8, r9, r10, r11}
    1030:      	sub	sp, #0xc
    1032:      	mov	r10, r0
;         self.write_with_mode(self.chan.mode(), buf);
    1034:      	ldr	r0, [r0, #0x4]
;         while self.state == WriteState::Writable && !buf.is_empty() {
    1036:      	cmp	r2, #0x0
;             SeqCst => intrinsics::atomic_load::<T, { AO::SeqCst }, VOLATILE>(dst),
    1038:      	ldr	r0, [r0, #0x14]
    103a:      	dmb	sy
;         while self.state == WriteState::Writable && !buf.is_empty() {
    103e:      	beq	0x1134 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0x10c> @ imm = #0xf2
;         self.write_with_mode(self.chan.mode(), buf);
    1040:      	ldrb.w	r3, [r10, #0x10]
;         while self.state == WriteState::Writable && !buf.is_empty() {
    1044:      	cmp	r3, #0x0
    1046:      	bne	0x1134 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0x10c> @ imm = #0xea
;         self.write_with_mode(self.chan.mode(), buf);
    1048:      	movw	r3, #0x184c
    104c:      	and	r0, r0, #0x3
    1050:      	movt	r3, #0x0
;         let read = self.chan.read_pointers().1;
    1054:      	ldrd	r8, r5, [r10, #4]
;         self.write_with_mode(self.chan.mode(), buf);
    1058:      	ldrb.w	r11, [r3, r0]
    105c:      	movs	r0, #0x0
    105e:      	ldr.w	r12, [r10, #0xc]
    1062:      	mvn.w	lr, r5
;             SeqCst => intrinsics::atomic_load::<T, { AO::SeqCst }, VOLATILE>(dst),
    1066:      	ldr.w	r3, [r8, #0xc]
    106a:      	dmb	sy
    106e:      	ldr.w	r6, [r8, #0x10]
    1072:      	dmb	sy
;         if write >= self.size || read >= self.size {
    1076:      	ldr.w	r4, [r8, #0x8]
    107a:      	cmp	r3, r4
    107c:      	it	lo
    107e:      	cmplo	r6, r4
    1080:      	blo	0x10a2 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0x7a> @ imm = #0x1e
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
    1082:      	dmb	sy
    1086:      	str.w	r0, [r8, #0xc]
    108a:      	dmb	sy
;             self.chan.size - self.write - 1
    108e:      	add.w	r6, r4, lr
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
    1092:      	dmb	sy
    1096:      	str.w	r0, [r8, #0x10]
    109a:      	dmb	sy
;             if count == 0 {
    109e:      	cbz	r6, 0x10b8 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0x90> @ imm = #0x16
    10a0:      	b	0x10e6 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0xbe> @ imm = #0x42
;         if read > self.write {
    10a2:      	cmp	r6, r5
    10a4:      	bls	0x10ac <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0x84> @ imm = #0x4
;             read - self.write - 1
    10a6:      	add	r6, lr
;             if count == 0 {
    10a8:      	cbz	r6, 0x10b8 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0x90> @ imm = #0xc
    10aa:      	b	0x10e6 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0xbe> @ imm = #0x38
;         } else if read == 0 {
    10ac:      	cmp	r6, #0x0
;             self.chan.size - self.write
    10ae:      	ite	ne
    10b0:      	subne	r6, r4, r5
;             self.chan.size - self.write - 1
    10b2:      	addeq.w	r6, r4, lr
;             if count == 0 {
    10b6:      	cbnz	r6, 0x10e6 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0xbe> @ imm = #0x2c
;                 match mode {
    10b8:      	cmp.w	r11, #0x2
    10bc:      	bne	0x10d0 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0xa8> @ imm = #0x10
;                         self.chan.write.store(self.write, SeqCst);
    10be:      	ldr.w	r8, [r10, #0x4]
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
    10c2:      	dmb	sy
    10c6:      	str.w	r5, [r8, #0xc]
    10ca:      	dmb	sy
;         while self.state == WriteState::Writable && !buf.is_empty() {
    10ce:      	b	0x1066 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0x3e> @ imm = #-0x6c
;                 match mode {
    10d0:      	cmp.w	r11, #0x1
    10d4:      	bne	0x113e <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0x116> @ imm = #0x66
;                         self.state = WriteState::Full;
    10d6:      	movs	r0, #0x1
    10d8:      	strd	r12, r2, [sp, #4]
    10dc:      	strb.w	r0, [r10, #0x10]
    10e0:      	mov.w	r9, #0x0
;                     ChannelMode::NoBlockTrim => {
    10e4:      	b	0x10f4 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0xcc> @ imm = #0xc
    10e6:      	mov	r9, r6
    10e8:      	str.w	r12, [sp, #0x4]
    10ec:      	cmp	r2, r6
    10ee:      	str	r2, [sp, #0x8]
    10f0:      	it	lo
    10f2:      	movlo	r9, r2
;                 ptr::copy_nonoverlapping(buf.as_ptr(), self.chan.buffer.add(self.write), count);
    10f4:      	ldr.w	r8, [r10, #0x4]
;     unsafe { crate::intrinsics::copy_nonoverlapping(src, dst, count) }
    10f8:      	mov	r2, r9
    10fa:      	mov	r4, r1
;                 ptr::copy_nonoverlapping(buf.as_ptr(), self.chan.buffer.add(self.write), count);
    10fc:      	ldr.w	r0, [r8, #0x4]
;         unsafe { intrinsics::offset(self, count) }
    1100:      	add	r0, r5
;     unsafe { crate::intrinsics::copy_nonoverlapping(src, dst, count) }
    1102:      	bl	0x1372 <__aeabi_memcpy> @ imm = #0x26c
    1106:      	ldr.w	r12, [sp, #0x4]
;             self.write += count;
    110a:      	add	r5, r9
;             if self.write >= self.chan.size {
    110c:      	ldr.w	r0, [r8, #0x8]
;             self.total += count;
    1110:      	add	r12, r9
;             if self.write >= self.chan.size {
    1112:      	cmp	r5, r0
    1114:      	mov.w	r0, #0x0
;             self.write += count;
    1118:      	strd	r5, r12, [r10, #8]
    111c:      	itt	hs
    111e:      	movhs	r5, #0x0
;                 self.write = 0;
    1120:      	strhs.w	r5, [r10, #0x8]
;         while self.state == WriteState::Writable && !buf.is_empty() {
    1124:      	cmp	r6, #0x0
    1126:      	ldr	r2, [sp, #0x8]
    1128:      	itt	ne
    112a:      	addne.w	r1, r4, r9
    112e:      	subsne.w	r2, r2, r9
    1132:      	bne	0x1062 <<rtt_target::TerminalWriter as core::fmt::Write>::write_str+0x3a> @ imm = #-0xd4
;     }
    1134:      	movs	r0, #0x0
    1136:      	add	sp, #0xc
    1138:      	pop.w	{r8, r9, r10, r11}
    113c:      	pop	{r4, r5, r6, r7, pc}
;                         self.state = WriteState::Finished;
    113e:      	movs	r0, #0x2
    1140:      	strb.w	r0, [r10, #0x10]
;     }
    1144:      	movs	r0, #0x0
    1146:      	add	sp, #0xc
    1148:      	pop.w	{r8, r9, r10, r11}
    114c:      	pop	{r4, r5, r6, r7, pc}

0000114e <tutorial::init>:
; pub fn init() -> (&'static p0::RegisterBlock, &'static p1::RegisterBlock) {
    114e:      	push	{r4, r5, r6, r7, lr}
    1150:      	add	r7, sp, #0xc
    1152:      	str	r11, [sp, #-4]!
;         unsafe { *self.value.get() }
    1156:      	movw	r5, #0x430
;     unsafe { asm!("mrs {}, PRIMASK", out(reg) r, options(nomem, nostack, preserves_flags)) };
    115a:      	mrs	r0, primask
;     unsafe { asm!("cpsid i", options(nomem, nostack, preserves_flags)) };
    115e:      	cpsid i
;         unsafe { *self.value.get() }
    1160:      	movt	r5, #0x2000
    1164:      	ldrb	r1, [r5, #0x1]
;             if INITIALIZED.borrow(cs).get() {
    1166:      	cmp	r1, #0x1
    1168:      	beq.w	0x1286 <tutorial::init+0x138> @ imm = #0x11a
;         crate::intrinsics::write_bytes(dst, val, count)
    116c:      	movw	r4, #0x400
    1170:      	movs	r6, #0x1
    1172:      	movt	r4, #0x2000
;         crate::intrinsics::write_via_move(dest, src);
    1176:      	strb	r6, [r5, #0x1]
;     unsafe { asm!("msr PRIMASK, {}", in(reg) r, options(nomem, nostack, preserves_flags)) };
    1178:      	msr	primask, r0
;         crate::intrinsics::write_bytes(dst, val, count)
    117c:      	mov	r0, r4
    117e:      	movs	r1, #0x30
    1180:      	bl	0x12ae <__aeabi_memclr4> @ imm = #0x12a
;         intrinsics::volatile_store(dst, src);
    1184:      	movw	r0, #0x169b
    1188:      	movs	r1, #0x54
    118a:      	movt	r0, #0x0
    118e:      	movs	r2, #0x20
;         intrinsics::volatile_store(dst, src);
    1190:      	str	r0, [r4, #0x18]
    1192:      	mov.w	r0, #0x400
    1196:      	str	r0, [r4, #0x20]
;             SeqCst => intrinsics::atomic_load::<T, { AO::SeqCst }, VOLATILE>(dst),
    1198:      	ldr	r0, [r4, #0x2c]
    119a:      	dmb	sy
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
    119e:      	dmb	sy
;             .store((self.flags.load(SeqCst) & !3) | mode as usize, SeqCst);
    11a2:      	bic	r0, r0, #0x3
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
    11a6:      	str	r0, [r4, #0x2c]
;         intrinsics::volatile_store(dst, src);
    11a8:      	movw	r0, #0x0
;             SeqCst => intrinsics::atomic_store::<T, { AO::SeqCst }, VOLATILE>(dst, val),
    11ac:      	dmb	sy
;         intrinsics::volatile_store(dst, src);
    11b0:      	movt	r0, #0x2000
    11b4:      	str	r0, [r4, #0x1c]
    11b6:      	movs	r0, #0x0
;         intrinsics::volatile_store(dst, src);
    11b8:      	str	r6, [r4, #0x10]
    11ba:      	str	r0, [r4, #0x14]
    11bc:      	strb	r0, [r4, #0xf]
    11be:      	strb	r0, [r4, #0xe]
    11c0:      	strb	r0, [r4, #0xd]
    11c2:      	strb	r0, [r4, #0xc]
    11c4:      	strb	r0, [r4, #0xb]
    11c6:      	strb	r0, [r4, #0xa]
    11c8:      	strb	r1, [r4, #0x9]
    11ca:      	strb	r1, [r4, #0x8]
    11cc:      	movs	r1, #0x52
    11ce:      	strb	r1, [r4, #0x7]
    11d0:      	strb	r2, [r4, #0x6]
    11d2:      	movs	r2, #0x47
    11d4:      	strb	r1, [r4, #0x5]
    11d6:      	movs	r1, #0x45
    11d8:      	strb	r1, [r4, #0x4]
    11da:      	strb	r2, [r4, #0x3]
    11dc:      	strb	r2, [r4, #0x2]
    11de:      	strb	r1, [r4, #0x1]
    11e0:      	movs	r1, #0x53
    11e2:      	strb	r1, [r4]
;     unsafe { asm!("mrs {}, PRIMASK", out(reg) r, options(nomem, nostack, preserves_flags)) };
    11e4:      	mrs	r1, primask
;     unsafe { asm!("cpsid i", options(nomem, nostack, preserves_flags)) };
    11e8:      	cpsid i
;         unsafe { *self.value.get() }
    11ea:      	ldr	r2, [r5, #0x4]
;         match borrow.get() {
    11ec:      	cmp	r2, #0x0
    11ee:      	bne	0x129a <tutorial::init+0x14c> @ imm = #0xa8
;         *PRINT_TERMINAL.borrow_ref_mut(cs) = Some(TerminalChannel::new(UpChannel(channel.0)))
    11f0:      	strb	r0, [r5, #0x10]
    11f2:      	add.w	r0, r4, #0x18
    11f6:      	strd	r6, r0, [r5, #8]
;     unsafe { asm!("msr PRIMASK, {}", in(reg) r, options(nomem, nostack, preserves_flags)) };
    11fa:      	msr	primask, r1
;     unsafe { asm!("mrs {}, PRIMASK", out(reg) r, options(nomem, nostack, preserves_flags)) };
    11fe:      	mrs	r0, primask
;     unsafe { asm!("cpsid i", options(nomem, nostack, preserves_flags)) };
    1202:      	cpsid i
;             if unsafe { DEVICE_PERIPHERALS } {
    1204:      	ldrb	r1, [r5]
    1206:      	lsls	r1, r1, #0x1f
    1208:      	bne	0x12a6 <tutorial::init+0x158> @ imm = #0x9a
;         DEVICE_PERIPHERALS = true;
    120a:      	movs	r1, #0x1
;         intrinsics::volatile_store(dst, src);
    120c:      	mov.w	r2, #0x800
;         DEVICE_PERIPHERALS = true;
    1210:      	strb	r1, [r5]
;     unsafe { asm!("msr PRIMASK, {}", in(reg) r, options(nomem, nostack, preserves_flags)) };
    1212:      	msr	primask, r0
    1216:      	movw	r0, #0x50c
;         intrinsics::volatile_store(dst, src);
    121a:      	mov.w	r1, #0x10000000
    121e:      	movt	r0, #0x5000
;         intrinsics::volatile_store(dst, src);
    1222:      	str	r1, [r0]
    1224:      	movs	r1, #0x3
    1226:      	str.w	r1, [r0, #0x264]
    122a:      	str	r2, [r0]
    122c:      	mov.w	r2, #0x80000000
    1230:      	str.w	r1, [r0, #0x220]
    1234:      	str	r2, [r0]
    1236:      	movs	r2, #0x20
    1238:      	str.w	r1, [r0, #0x270]
    123c:      	str.w	r2, [r0, #0x300]
    1240:      	mov.w	r2, #0x40000000
    1244:      	str.w	r1, [r0, #0x508]
    1248:      	str	r2, [r0]
    124a:      	mov.w	r2, #0x200000
    124e:      	str.w	r1, [r0, #0x26c]
    1252:      	str	r2, [r0]
    1254:      	mov.w	r2, #0x400000
    1258:      	str.w	r1, [r0, #0x248]
    125c:      	str	r2, [r0]
    125e:      	mov.w	r2, #0x8000
    1262:      	str.w	r1, [r0, #0x24c]
    1266:      	str	r2, [r0]
    1268:      	mov.w	r2, #0x1000000
    126c:      	str.w	r1, [r0, #0x230]
    1270:      	str	r2, [r0]
    1272:      	mov.w	r2, #0x80000
    1276:      	str.w	r1, [r0, #0x254]
    127a:      	str	r2, [r0]
    127c:      	str.w	r1, [r0, #0x240]
; }
    1280:      	ldr	r11, [sp], #4
    1284:      	pop	{r4, r5, r6, r7, pc}
;                 panic!("rtt_init! must not be called multiple times");
    1286:      	movw	r0, #0x1800
    128a:      	movw	r1, #0x182c
    128e:      	movt	r0, #0x0
    1292:      	movt	r1, #0x0
    1296:      	bl	0x924 <core::panicking::panic> @ imm = #-0x976
;             Err(err) => panic_already_borrowed(err),
    129a:      	movw	r0, #0x17f0
    129e:      	movt	r0, #0x0
    12a2:      	bl	0xba8 <core::cell::panic_already_borrowed> @ imm = #-0x6fe
;     unsafe { asm!("msr PRIMASK, {}", in(reg) r, options(nomem, nostack, preserves_flags)) };
    12a6:      	msr	primask, r0
;             None => unwrap_failed(),
    12aa:      	bl	0x930 <core::option::unwrap_failed> @ imm = #-0x97e

000012ae <__aeabi_memclr4>:
    12ae:      	push	{r7, lr}
    12b0:      	mov	r7, sp
    12b2:      	cmp	r1, #0x4
    12b4:      	blo	0x12e0 <__aeabi_memclr4+0x32> @ imm = #0x28
    12b6:      	sub.w	r12, r1, #0x4
    12ba:      	movs	r2, #0x1
    12bc:      	add.w	r2, r2, r12, lsr #2
    12c0:      	ands	r3, r2, #0x3
    12c4:      	beq	0x12e4 <__aeabi_memclr4+0x36> @ imm = #0x1c
    12c6:      	mov.w	lr, #0x0
    12ca:      	mov	r2, r0
    12cc:      	str	lr, [r2], #4
    12d0:      	cmp	r3, #0x1
    12d2:      	bne	0x12ec <__aeabi_memclr4+0x3e> @ imm = #0x16
    12d4:      	mov	r1, r12
    12d6:      	mov	r0, r2
    12d8:      	cmp.w	r12, #0xc
    12dc:      	bhs	0x1312 <__aeabi_memclr4+0x64> @ imm = #0x32
    12de:      	b	0x1326 <__aeabi_memclr4+0x78> @ imm = #0x44
    12e0:      	mov	r2, r0
    12e2:      	b	0x1326 <__aeabi_memclr4+0x78> @ imm = #0x40
    12e4:      	cmp.w	r12, #0xc
    12e8:      	bhs	0x1312 <__aeabi_memclr4+0x64> @ imm = #0x26
    12ea:      	b	0x1326 <__aeabi_memclr4+0x78> @ imm = #0x38
    12ec:      	cmp	r3, #0x2
    12ee:      	str.w	lr, [r0, #0x4]
    12f2:      	bne	0x1302 <__aeabi_memclr4+0x54> @ imm = #0xc
    12f4:      	subs	r1, #0x8
    12f6:      	adds	r0, #0x8
    12f8:      	mov	r2, r0
    12fa:      	cmp.w	r12, #0xc
    12fe:      	bhs	0x1312 <__aeabi_memclr4+0x64> @ imm = #0x10
    1300:      	b	0x1326 <__aeabi_memclr4+0x78> @ imm = #0x22
    1302:      	movs	r2, #0x0
    1304:      	subs	r1, #0xc
    1306:      	str	r2, [r0, #0x8]
    1308:      	adds	r0, #0xc
    130a:      	mov	r2, r0
    130c:      	cmp.w	r12, #0xc
    1310:      	blo	0x1326 <__aeabi_memclr4+0x78> @ imm = #0x12
    1312:      	movs	r3, #0x0
    1314:      	mov	r2, r0
    1316:      	subs	r1, #0x10
    1318:      	strd	r3, r3, [r2]
    131c:      	strd	r3, r3, [r2, #8]
    1320:      	adds	r2, #0x10
    1322:      	cmp	r1, #0x3
    1324:      	bhi	0x1316 <__aeabi_memclr4+0x68> @ imm = #-0x12
    1326:      	adds	r0, r2, r1
    1328:      	cmp	r2, r0
    132a:      	bhs	0x1370 <__aeabi_memclr4+0xc2> @ imm = #0x42
    132c:      	sub.w	r12, r1, #0x1
    1330:      	ands	r3, r1, #0x3
    1334:      	beq	0x1350 <__aeabi_memclr4+0xa2> @ imm = #0x18
    1336:      	mov.w	lr, #0x0
    133a:      	mov	r1, r2
    133c:      	strb	lr, [r1], #1
    1340:      	cmp	r3, #0x1
    1342:      	beq	0x135a <__aeabi_memclr4+0xac> @ imm = #0x14
    1344:      	cmp	r3, #0x2
    1346:      	strb.w	lr, [r2, #0x1]
    134a:      	bne	0x1354 <__aeabi_memclr4+0xa6> @ imm = #0x6
    134c:      	adds	r1, r2, #0x2
    134e:      	b	0x135a <__aeabi_memclr4+0xac> @ imm = #0x8
    1350:      	mov	r1, r2
    1352:      	b	0x135a <__aeabi_memclr4+0xac> @ imm = #0x4
    1354:      	movs	r1, #0x0
    1356:      	strb	r1, [r2, #0x2]
    1358:      	adds	r1, r2, #0x3
    135a:      	cmp.w	r12, #0x3
    135e:      	it	lo
    1360:      	poplo	{r7, pc}
    1362:      	subs	r1, #0x4
    1364:      	movs	r2, #0x0
    1366:      	str	r2, [r1, #4]!
    136a:      	adds	r3, r1, #0x4
    136c:      	cmp	r3, r0
    136e:      	bne	0x1366 <__aeabi_memclr4+0xb8> @ imm = #-0xc
    1370:      	pop	{r7, pc}

00001372 <__aeabi_memcpy>:
    1372:      	push	{r7, lr}
    1374:      	mov	r7, sp
    1376:      	pop.w	{r7, lr}
    137a:      	b.w	0x137e <compiler_builtins::mem::memcpy> @ imm = #0x0

0000137e <compiler_builtins::mem::memcpy>:
    137e:      	push	{r4, r5, r6, r7, lr}
    1380:      	add	r7, sp, #0xc
    1382:      	push.w	{r8, r9, r10, r11}
    1386:      	sub	sp, #0x24
    1388:      	mov	r8, r0
    138a:      	cmp	r2, #0x10
    138c:      	blo	0x13d2 <compiler_builtins::mem::memcpy+0x54> @ imm = #0x42
    138e:      	rsb.w	r0, r8, #0x0
    1392:      	and	r10, r0, #0x3
    1396:      	add.w	r3, r8, r10
    139a:      	cmp	r8, r3
    139c:      	bhs	0x140e <compiler_builtins::mem::memcpy+0x90> @ imm = #0x6e
    139e:      	sub.w	r6, r10, #0x1
    13a2:      	mov	r4, r8
    13a4:      	mov	r5, r1
    13a6:      	cmp.w	r10, #0x0
    13aa:      	beq	0x13ec <compiler_builtins::mem::memcpy+0x6e> @ imm = #0x3e
    13ac:      	mov	r5, r1
    13ae:      	mov	r4, r8
    13b0:      	ldrb	r0, [r5], #1
    13b4:      	cmp.w	r10, #0x1
    13b8:      	strb	r0, [r4], #1
    13bc:      	beq	0x13ec <compiler_builtins::mem::memcpy+0x6e> @ imm = #0x2c
    13be:      	ldrb	r0, [r1, #0x1]
    13c0:      	cmp.w	r10, #0x2
    13c4:      	strb.w	r0, [r8, #0x1]
    13c8:      	bne	0x13e0 <compiler_builtins::mem::memcpy+0x62> @ imm = #0x14
    13ca:      	adds	r5, r1, #0x2
    13cc:      	add.w	r4, r8, #0x2
    13d0:      	b	0x13ec <compiler_builtins::mem::memcpy+0x6e> @ imm = #0x18
    13d2:      	mov	r12, r8
    13d4:      	add.w	r3, r12, r2
    13d8:      	cmp	r12, r3
    13da:      	blo.w	0x15a2 <compiler_builtins::mem::memcpy+0x224> @ imm = #0x1c4
    13de:      	b	0x15f6 <compiler_builtins::mem::memcpy+0x278> @ imm = #0x214
    13e0:      	adds	r5, r1, #0x3
    13e2:      	add.w	r4, r8, #0x3
    13e6:      	ldrb	r0, [r1, #0x2]
    13e8:      	strb.w	r0, [r8, #0x2]
    13ec:      	cmp	r6, #0x3
    13ee:      	blo	0x140e <compiler_builtins::mem::memcpy+0x90> @ imm = #0x1c
    13f0:      	subs	r6, r5, #0x4
    13f2:      	subs	r5, r4, #0x4
    13f4:      	ldrb	r0, [r6, #4]!
    13f8:      	strb	r0, [r5, #4]!
    13fc:      	ldrb	r0, [r6, #0x1]
    13fe:      	strb	r0, [r5, #0x1]
    1400:      	ldrb	r0, [r6, #0x2]
    1402:      	strb	r0, [r5, #0x2]
    1404:      	ldrb	r0, [r6, #0x3]
    1406:      	strb	r0, [r5, #0x3]
    1408:      	adds	r0, r5, #0x4
    140a:      	cmp	r0, r3
    140c:      	bne	0x13f4 <compiler_builtins::mem::memcpy+0x76> @ imm = #-0x1c
    140e:      	sub.w	r11, r2, r10
    1412:      	add.w	r4, r1, r10
    1416:      	bic	r2, r11, #0x3
    141a:      	ands	r0, r4, #0x3
    141e:      	add.w	r12, r3, r2
    1422:      	beq	0x14ec <compiler_builtins::mem::memcpy+0x16e> @ imm = #0xc6
    1424:      	mov.w	r9, #0x0
    1428:      	rsb.w	r6, r0, #0x4
    142c:      	str	r2, [sp, #0x10]
    142e:      	add	r2, sp, #0x20
    1430:      	str.w	r9, [sp, #0x20]
    1434:      	add	r2, r0
    1436:      	lsls	r5, r6, #0x1f
    1438:      	ittt	ne
    143a:      	ldrbne	r5, [r4]
    143c:      	strbne	r5, [r2]
    143e:      	movne.w	r9, #0x1
    1442:      	lsls	r6, r6, #0x1e
    1444:      	itt	mi
    1446:      	ldrhmi.w	r6, [r4, r9]
    144a:      	strhmi.w	r6, [r2, r9]
    144e:      	subs	r5, r4, r0
    1450:      	str	r4, [sp, #0x14]
    1452:      	adds	r4, r3, #0x4
    1454:      	ldr	r2, [sp, #0x20]
    1456:      	lsl.w	lr, r0, #0x3
    145a:      	cmp	r4, r12
    145c:      	rsb.w	r4, lr, #0x0
    1460:      	strd	r0, r4, [sp, #8]
    1464:      	bhs	0x151e <compiler_builtins::mem::memcpy+0x1a0> @ imm = #0xb6
    1466:      	rsbs	r3, r0, #0
    1468:      	mov	r6, r8
    146a:      	str.w	r11, [sp]
    146e:      	add.w	r8, r1, r3
    1472:      	and	r11, r4, #0x18
    1476:      	str	r6, [sp, #0x4]
    1478:      	add.w	r5, r8, r10
    147c:      	add.w	r4, r6, r10
    1480:      	lsr.w	r1, r2, lr
    1484:      	ldr.w	r9, [r5, #0x4]
    1488:      	lsl.w	r2, r9, r11
    148c:      	orrs	r1, r2
    148e:      	mov	r2, r4
    1490:      	str	r1, [r2], #8
    1494:      	cmp	r2, r12
    1496:      	bhs	0x1522 <compiler_builtins::mem::memcpy+0x1a4> @ imm = #0x88
    1498:      	ldr	r1, [r5, #0x8]
    149a:      	lsr.w	r3, r9, lr
    149e:      	lsl.w	r0, r1, r11
    14a2:      	orrs	r0, r3
    14a4:      	add.w	r3, r4, #0xc
    14a8:      	cmp	r3, r12
    14aa:      	str	r0, [r4, #0x4]
    14ac:      	bhs	0x1528 <compiler_builtins::mem::memcpy+0x1aa> @ imm = #0x78
    14ae:      	ldr.w	r9, [r5, #0xc]
    14b2:      	lsr.w	r0, r1, lr
    14b6:      	lsl.w	r1, r9, r11
    14ba:      	orrs	r0, r1
    14bc:      	str	r0, [r2]
    14be:      	add.w	r0, r4, #0x10
    14c2:      	cmp	r0, r12
    14c4:      	bhs	0x1532 <compiler_builtins::mem::memcpy+0x1b4> @ imm = #0x6a
    14c6:      	ldr	r2, [r5, #0x10]
    14c8:      	lsr.w	r0, r9, lr
    14cc:      	adds	r6, #0x10
    14ce:      	add.w	r8, r8, #0x10
    14d2:      	lsl.w	r1, r2, r11
    14d6:      	orrs	r0, r1
    14d8:      	str	r0, [r3]
    14da:      	add.w	r3, r6, r10
    14de:      	adds	r0, r3, #0x4
    14e0:      	cmp	r0, r12
    14e2:      	blo	0x1478 <compiler_builtins::mem::memcpy+0xfa> @ imm = #-0x6e
    14e4:      	add.w	r5, r8, r10
    14e8:      	mov	r9, r2
    14ea:      	b	0x1534 <compiler_builtins::mem::memcpy+0x1b6> @ imm = #0x46
    14ec:      	cmp	r3, r12
    14ee:      	bhs	0x1594 <compiler_builtins::mem::memcpy+0x216> @ imm = #0xa2
    14f0:      	mov	r1, r4
    14f2:      	ldr	r0, [r1]
    14f4:      	str	r0, [r3], #4
    14f8:      	cmp	r3, r12
    14fa:      	bhs	0x1594 <compiler_builtins::mem::memcpy+0x216> @ imm = #0x96
    14fc:      	ldr	r0, [r1, #0x4]
    14fe:      	str	r0, [r3], #4
    1502:      	cmp	r3, r12
    1504:      	ittt	lo
    1506:      	ldrlo	r0, [r1, #0x8]
    1508:      	strlo	r0, [r3], #4
    150c:      	cmplo	r3, r12
    150e:      	bhs	0x1594 <compiler_builtins::mem::memcpy+0x216> @ imm = #0x82
    1510:      	ldr	r0, [r1, #0xc]
    1512:      	adds	r1, #0x10
    1514:      	str	r0, [r3], #4
    1518:      	cmp	r3, r12
    151a:      	blo	0x14f2 <compiler_builtins::mem::memcpy+0x174> @ imm = #-0x2c
    151c:      	b	0x1594 <compiler_builtins::mem::memcpy+0x216> @ imm = #0x74
    151e:      	mov	r9, r2
    1520:      	b	0x1538 <compiler_builtins::mem::memcpy+0x1ba> @ imm = #0x14
    1522:      	adds	r5, #0x4
    1524:      	adds	r3, r4, #0x4
    1526:      	b	0x1534 <compiler_builtins::mem::memcpy+0x1b6> @ imm = #0xa
    1528:      	adds	r5, #0x8
    152a:      	add.w	r3, r4, #0x8
    152e:      	mov	r9, r1
    1530:      	b	0x1534 <compiler_builtins::mem::memcpy+0x1b6> @ imm = #0x0
    1532:      	adds	r5, #0xc
    1534:      	ldrd	r11, r8, [sp]
    1538:      	ldr	r0, [sp, #0x8]
    153a:      	movs	r2, #0x0
    153c:      	strb.w	r2, [sp, #0x1c]
    1540:      	cmp	r0, #0x1
    1542:      	strb	r2, [r7, #-38]
    1546:      	bne	0x1556 <compiler_builtins::mem::memcpy+0x1d8> @ imm = #0xc
    1548:      	add	r6, sp, #0x1c
    154a:      	movs	r4, #0x0
    154c:      	movs	r0, #0x0
    154e:      	ldr	r1, [sp, #0x14]
    1550:      	lsls	r1, r1, #0x1f
    1552:      	bne	0x156c <compiler_builtins::mem::memcpy+0x1ee> @ imm = #0x16
    1554:      	b	0x157e <compiler_builtins::mem::memcpy+0x200> @ imm = #0x26
    1556:      	ldrb	r0, [r5, #0x5]
    1558:      	sub.w	r6, r7, #0x26
    155c:      	ldrb	r2, [r5, #0x4]
    155e:      	strb.w	r2, [sp, #0x1c]
    1562:      	lsls	r4, r0, #0x8
    1564:      	movs	r0, #0x2
    1566:      	ldr	r1, [sp, #0x14]
    1568:      	lsls	r1, r1, #0x1f
    156a:      	beq	0x157e <compiler_builtins::mem::memcpy+0x200> @ imm = #0x10
    156c:      	adds	r1, r5, #0x4
    156e:      	ldrb	r0, [r1, r0]
    1570:      	strb	r0, [r6]
    1572:      	ldrb	r0, [r7, #-38]
    1576:      	ldrb.w	r2, [sp, #0x1c]
    157a:      	orr.w	r4, r4, r0, lsl #16
    157e:      	adds	r0, r4, r2
    1580:      	ldr	r2, [sp, #0xc]
    1582:      	lsr.w	r1, r9, lr
    1586:      	and	r2, r2, #0x18
    158a:      	lsls	r0, r2
    158c:      	ldrd	r2, r4, [sp, #16]
    1590:      	orrs	r0, r1
    1592:      	str	r0, [r3]
    1594:      	adds	r1, r4, r2
    1596:      	and	r2, r11, #0x3
    159a:      	add.w	r3, r12, r2
    159e:      	cmp	r12, r3
    15a0:      	bhs	0x15f6 <compiler_builtins::mem::memcpy+0x278> @ imm = #0x52
    15a2:      	subs	r6, r2, #0x1
    15a4:      	ands	r0, r2, #0x3
    15a8:      	beq	0x15d0 <compiler_builtins::mem::memcpy+0x252> @ imm = #0x24
    15aa:      	mov	r2, r1
    15ac:      	mov	r5, r12
    15ae:      	ldrb	r4, [r2], #1
    15b2:      	cmp	r0, #0x1
    15b4:      	strb	r4, [r5], #1
    15b8:      	beq	0x15d4 <compiler_builtins::mem::memcpy+0x256> @ imm = #0x18
    15ba:      	ldrb	r2, [r1, #0x1]
    15bc:      	cmp	r0, #0x2
    15be:      	strb.w	r2, [r12, #0x1]
    15c2:      	bne	0x1600 <compiler_builtins::mem::memcpy+0x282> @ imm = #0x3a
    15c4:      	adds	r2, r1, #0x2
    15c6:      	add.w	r5, r12, #0x2
    15ca:      	cmp	r6, #0x3
    15cc:      	bhs	0x15d8 <compiler_builtins::mem::memcpy+0x25a> @ imm = #0x8
    15ce:      	b	0x15f6 <compiler_builtins::mem::memcpy+0x278> @ imm = #0x24
    15d0:      	mov	r5, r12
    15d2:      	mov	r2, r1
    15d4:      	cmp	r6, #0x3
    15d6:      	blo	0x15f6 <compiler_builtins::mem::memcpy+0x278> @ imm = #0x1c
    15d8:      	subs	r1, r2, #0x4
    15da:      	subs	r2, r5, #0x4
    15dc:      	ldrb	r0, [r1, #4]!
    15e0:      	strb	r0, [r2, #4]!
    15e4:      	ldrb	r0, [r1, #0x1]
    15e6:      	strb	r0, [r2, #0x1]
    15e8:      	ldrb	r0, [r1, #0x2]
    15ea:      	strb	r0, [r2, #0x2]
    15ec:      	ldrb	r0, [r1, #0x3]
    15ee:      	strb	r0, [r2, #0x3]
    15f0:      	adds	r0, r2, #0x4
    15f2:      	cmp	r0, r3
    15f4:      	bne	0x15dc <compiler_builtins::mem::memcpy+0x25e> @ imm = #-0x1c
    15f6:      	mov	r0, r8
    15f8:      	add	sp, #0x24
    15fa:      	pop.w	{r8, r9, r10, r11}
    15fe:      	pop	{r4, r5, r6, r7, pc}
    1600:      	adds	r2, r1, #0x3
    1602:      	add.w	r5, r12, #0x3
    1606:      	ldrb	r0, [r1, #0x2]
    1608:      	strb.w	r0, [r12, #0x2]
    160c:      	cmp	r6, #0x3
    160e:      	bhs	0x15d8 <compiler_builtins::mem::memcpy+0x25a> @ imm = #-0x3a
    1610:      	b	0x15f6 <compiler_builtins::mem::memcpy+0x278> @ imm = #-0x1e

00001612 <HardFault_>:
; pub unsafe extern "C" fn HardFault_() -> ! {
    1612:      	push	{r7, lr}
    1614:      	mov	r7, sp
;     loop {}
    1616:      	b	0x1616 <HardFault_+0x4> @ imm = #-0x4
