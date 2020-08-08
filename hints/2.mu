--- /usr/src/sys/mdec/bruboot.s.old	2020-06-14 08:25:17.715240000 -0600
+++ /usr/src/sys/mdec/bruboot.s	2020-06-14 08:25:29.172329000 -0600
@@ -45,8 +45,6 @@
 	nop			/ These two lines must be present or DEC
 	br	start		/ boot ROMs will refuse to run boot block!
 start:
-	clr	r0		/ XXX - for Rome 11/70, boot card doesn't work
-	mov	$176714,r1	/ XXX - for Rome 11/70, boot card doesn't work
 	movb	r0,unit+1	/ save the unit in high byte (for brcs)
 	mov	r1,csr		/  and csr from the ROMs (not base addr!)
 	mov	$..,sp
