--- ld.c.1	2020-06-01 16:27:10.734632000 -0600
+++ ld.c	2020-06-01 16:41:27.059048000 -0600
@@ -70,6 +70,8 @@
 
 #define THUNKSIZ	8
 
+#define SARMAG 2
+
 /*
  * one entry for each archive member referenced;
  * set in first pass; needs restoring for overlays
@@ -254,6 +256,7 @@
 long	ladd();
 int	delexit();
 long	lseek();
+long	atol();
 char	*savestr();
 char	*malloc();
 char	*mktemp();
@@ -853,6 +856,11 @@
 	sp->n_value = val;
 }
 
+getarhdr()
+{
+	mget((int *)&archdr, sizeof archdr);
+}
+
 setupout()
 {
 	tcreat(&toutb, 0);
@@ -913,7 +921,7 @@
 	} else {	/* scan archive members referenced */
 		for (lp = libp; lp->loc != -1; lp++) {
 			dseek(&text, lp->loc, sizeof archdr);
-			mget((int *)&archdr, sizeof archdr);
+			getarhdr();
 			mkfsym(archdr.ar_name);
 			load2(lp->loc + (sizeof archdr) / 2);
 		}
@@ -1290,10 +1298,12 @@
 	page[0].nuser = page[1].nuser = 0;
 	text.pno = reloc.pno = (PAGE *)&fpage;
 	fpage.nuser = 2;
-	dseek(&text, 0L, 2);
+	dseek(&text, 0L, SARMAG);
 	if (text.size <= 0)
 		error(1, "premature EOF");
-	if (get(&text) != ARMAG)
+	mget((char *)arcmag, SARMAG);
+	arcmag[SARMAG] = 0;
+	if (strcmp(arcmag, ARMAG))
 		return (0);			/* regular file */
 	dseek(&text, 1L, sizeof archdr);	/* word addressing */
 	if (text.size <= 0)
