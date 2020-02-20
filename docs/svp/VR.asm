000800 | 000400: 0038      	LD	r3, r8		;AH <- EXT0
000802 | 000401: B802      	AND	r3, #02		;ACC &= #02
000804 | 000402: 4D50 0400 	BRA	z, 0400		;PC <- 0800
000808 | 000404: B800      	AND	r3, #00		;ACC &= #00
00080A | 000405: 001B      	LD	r1, rB		;X <- EXT3
00080C | 000406: 0031      	LD	r3, r1		;AH <- X
00080E | 000407: 6800 4F48 	CMP	r3, #4F48		;ACC == #4F48		if command == "OH"
000812 | 000409: 4D50 0411 	BRA	z, 0411		;PC <- 0822			goto L_0411
000816 | 00040B: 6800 5254 	CMP	r3, #5254		;ACC == #5254		if command == "RT"
00081A | 00040D: 4D50 C004 	BRA	z, C004		;PC <- 18008		goto L_C004
00081E | 00040F: 4C00 0461 	BRA	0461			;PC <- 08C2			L_0461

L_0411:
000822 | 000411: 1800      	LD	pA0, #00		;pA0 <- #00
000824 | 000412: 1C00      	LD	pB0, #00		;pB0 <- #00
000826 | 000413: 0810 0000 	LD	r1, #0000		;X <- #0000
00082A | 000415: 0830 00FF 	LD	r3, #00FF		;AH <- #00FF
00082E | 000417: 0414      	LD	ptrA4, r1		;[p_A0++] <- X
000830 | 000418: 0514      	LD	ptrB4, r1		;[p_B0++] <- X
000832 | 000419: 3801      	SUB	r3, #01		;ACC -= #01
000834 | 00041A: 4C70 0417 	BRA	ns, 0417		;PC <- 082E
000838 | 00041C: 1CF0      	LD	pB0, #F0		;pB0 <- #F0
00083A | 00041D: 0D04 01C0 	LD	ptrB4, #01C0	;[p_B0++] <- #01C0
00083E | 00041F: 0D04 0000 	LD	ptrB4, #0000	;[p_B0++] <- #0000
000842 | 000421: 0D04 2845 	LD	ptrB4, #2845	;[p_B0++] <- #2845
000846 | 000423: 0D04 5845 	LD	ptrB4, #5845	;[p_B0++] <- #5845
L_0425:
00084A | 000425: 08E0 7F04 	LD	rE, #7F04		;EXT6 <- #7F04
00084E | 000427: 08E0 0018 	LD	rE, #0018		;EXT6 <- #0018
000852 | 000429: 000C      	LD	r0, rC		;R0 <- EXT4
000854 | 00042A: 003C      	LD	r3, rC		;AH <- EXT4
000856 | 00042B: A000      	AND	r3, r0		;ACC &= R0
000858 | 00042C: 4D50 0435 	BRA	z, 0435		;PC <- 086A
00085C | 00042E: 08E0 7F04 	LD	rE, #7F04		;EXT6 <- #7F04
000860 | 000430: 08E0 0018 	LD	rE, #0018		;EXT6 <- #0018
000864 | 000432: 00C0      	LD	rC, r0		;EXT4 <- R0
000866 | 000433: 08C0 0000 	LD	rC, #0000		;EXT4 <- #0000
00086A | 000435: 8800 0438 	ADD	r3, #0438		;ACC += #0438
00086E | 000437: 4A60      	LD	r6, (r3)		;PC <- (AH)			pointers array 000438-000447

000870 | 000438: 0425						;L_0425
000872 | 000439: 0448						;L_0448
000874 | 00043A: 088A						;L_088A
000876 | 00043B: 0959						;L_0959
000878 | 00043C: 0C6F						;L_0C6F
00087A | 00043D: 0EE5						;L_0EE5			show logo SEGA
00087C | 00043E: 0AEE						;L_0AEE
00087E | 00043F: 0BA2						;L_0BA2
000880 | 000440: 0BC9						;L_0BC9
000882 | 000441: 10E8						;L_10E8
000884 | 000442: 0A3A						;L_0A3A
000886 | 000443: 0AC1						;L_0AC1
000888 | 000444: 1158						;L_1158
00088A | 000445: 0425						;L_0425
00088C | 000446: 0425						;L_0425
00088E | 000447: 0425						;L_0425

L_0448:
000890 | 000448: 4800 2784 	CALL	2784			;PC <- 4F08
000894 | 00044A: 4800 2794 	CALL	2794			;PC <- 4F28
000898 | 00044C: 4C00 0425 	BRA	0425			;PC <- 084A

00089C | 00044E: B800      	AND	r3, #00		;ACC &= #00
00089E | 00044F: 0810 0000 	LD	r1, #0000		;X <- #0000
0008A2 | 000451: 0820 03FF 	LD	r2, #03FF		;Y <- #03FF
0008A6 | 000453: 0C03 FC00 	LD	ptrA3, #FC00	;dp_A0 <- #FC00
0008AA | 000455: 0031      	LD	r3, r1		;AH <- X
0008AC | 000456: 8A03      	ADD	r3, *ptrA3		;ACC += (dp_A0++)
0008AE | 000457: 0013      	LD	r1, r3		;X <- AH
0008B0 | 000458: 0032      	LD	r3, r2		;AH <- Y
0008B2 | 000459: 3801      	SUB	r3, #01		;ACC -= #01
0008B4 | 00045A: 0023      	LD	r2, r3		;Y <- AH
0008B6 | 00045B: 4C70 0455 	BRA	ns, 0455		;PC <- 08AA
0008BA | 00045D: 0031      	LD	r3, r1		;AH <- X
0008BC | 00045E: 9006      	NEG	ACC			;
0008BE | 00045F: 4C00 045F 	BRA	045F			;PC <- 08BE

L_0461:
0008C2 | 000461: 0C03 7FC0 	LD	ptrA3, #7FC0	;dp_A0 <- #7FC0
0008C6 | 000463: 0C07 0000 	LD	ptrA7, #0000	;dp_A1 <- #0000
0008CA | 000465: 4800 279C 	CALL	279C			;PC <- 4F38
0008CE | 000467: 4800 2831 	CALL	2831			;PC <- 5062
0008D2 | 000469: 4C00 0469 	BRA	0469			;PC <- 08D2

L_0481:								;IRAM load func, (dp_B0) = start addr IRAM, (dp_B0+1) = size
000902 | 000481: 0BE3      	LD	rE, *ptrB3		;EXT6 <- (dp_B0++)	set PMAR4 to write to IRAM
000904 | 000482: 08E0 081C 	LD	rE, #081C		;EXT6 <- #081C
000908 | 000484: 00C0      	LD	rC, r0		;EXT4 <- R0
00090A | 000485: 0830 0888 	LD	r3, #0888		;AH <- #0888
00090E | 000487: 2B03      	SUB	r3, *ptrB3		;ACC -= (dp_B0++)
000910 | 000488: 0063      	LD	r6, r3		;PC <- AH			
000912 | 000489: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000914 | 00048A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000916 | 00048B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000918 | 00048C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00091A | 00048D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00091C | 00048E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00091E | 00048F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000920 | 000490: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000922 | 000491: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000924 | 000492: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000926 | 000493: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000928 | 000494: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00092A | 000495: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00092C | 000496: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00092E | 000497: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000930 | 000498: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000932 | 000499: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000934 | 00049A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000936 | 00049B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000938 | 00049C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00093A | 00049D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00093C | 00049E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00093E | 00049F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000940 | 0004A0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000942 | 0004A1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000944 | 0004A2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000946 | 0004A3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000948 | 0004A4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00094A | 0004A5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00094C | 0004A6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00094E | 0004A7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000950 | 0004A8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000952 | 0004A9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000954 | 0004AA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000956 | 0004AB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000958 | 0004AC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00095A | 0004AD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00095C | 0004AE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00095E | 0004AF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000960 | 0004B0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000962 | 0004B1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000964 | 0004B2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000966 | 0004B3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000968 | 0004B4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00096A | 0004B5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00096C | 0004B6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00096E | 0004B7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000970 | 0004B8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000972 | 0004B9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000974 | 0004BA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000976 | 0004BB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000978 | 0004BC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00097A | 0004BD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00097C | 0004BE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00097E | 0004BF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000980 | 0004C0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000982 | 0004C1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000984 | 0004C2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000986 | 0004C3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000988 | 0004C4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00098A | 0004C5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00098C | 0004C6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00098E | 0004C7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000990 | 0004C8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000992 | 0004C9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000994 | 0004CA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000996 | 0004CB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000998 | 0004CC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00099A | 0004CD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00099C | 0004CE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00099E | 0004CF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009A0 | 0004D0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009A2 | 0004D1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009A4 | 0004D2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009A6 | 0004D3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009A8 | 0004D4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009AA | 0004D5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009AC | 0004D6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009AE | 0004D7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009B0 | 0004D8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009B2 | 0004D9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009B4 | 0004DA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009B6 | 0004DB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009B8 | 0004DC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009BA | 0004DD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009BC | 0004DE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009BE | 0004DF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009C0 | 0004E0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009C2 | 0004E1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009C4 | 0004E2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009C6 | 0004E3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009C8 | 0004E4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009CA | 0004E5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009CC | 0004E6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009CE | 0004E7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009D0 | 0004E8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009D2 | 0004E9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009D4 | 0004EA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009D6 | 0004EB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009D8 | 0004EC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009DA | 0004ED: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009DC | 0004EE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009DE | 0004EF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009E0 | 0004F0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009E2 | 0004F1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009E4 | 0004F2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009E6 | 0004F3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009E8 | 0004F4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009EA | 0004F5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009EC | 0004F6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009EE | 0004F7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009F0 | 0004F8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009F2 | 0004F9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009F4 | 0004FA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009F6 | 0004FB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009F8 | 0004FC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009FA | 0004FD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009FC | 0004FE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0009FE | 0004FF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A00 | 000500: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A02 | 000501: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A04 | 000502: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A06 | 000503: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A08 | 000504: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A0A | 000505: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A0C | 000506: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A0E | 000507: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A10 | 000508: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A12 | 000509: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A14 | 00050A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A16 | 00050B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A18 | 00050C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A1A | 00050D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A1C | 00050E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A1E | 00050F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A20 | 000510: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A22 | 000511: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A24 | 000512: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A26 | 000513: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A28 | 000514: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A2A | 000515: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A2C | 000516: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A2E | 000517: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A30 | 000518: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A32 | 000519: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A34 | 00051A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A36 | 00051B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A38 | 00051C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A3A | 00051D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A3C | 00051E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A3E | 00051F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A40 | 000520: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A42 | 000521: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A44 | 000522: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A46 | 000523: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A48 | 000524: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A4A | 000525: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A4C | 000526: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A4E | 000527: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A50 | 000528: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A52 | 000529: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A54 | 00052A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A56 | 00052B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A58 | 00052C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A5A | 00052D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A5C | 00052E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A5E | 00052F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A60 | 000530: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A62 | 000531: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A64 | 000532: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A66 | 000533: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A68 | 000534: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A6A | 000535: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A6C | 000536: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A6E | 000537: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A70 | 000538: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A72 | 000539: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A74 | 00053A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A76 | 00053B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A78 | 00053C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A7A | 00053D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A7C | 00053E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A7E | 00053F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A80 | 000540: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A82 | 000541: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A84 | 000542: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A86 | 000543: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A88 | 000544: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A8A | 000545: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A8C | 000546: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A8E | 000547: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A90 | 000548: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A92 | 000549: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A94 | 00054A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A96 | 00054B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A98 | 00054C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A9A | 00054D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A9C | 00054E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000A9E | 00054F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AA0 | 000550: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AA2 | 000551: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AA4 | 000552: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AA6 | 000553: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AA8 | 000554: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AAA | 000555: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AAC | 000556: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AAE | 000557: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AB0 | 000558: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AB2 | 000559: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AB4 | 00055A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AB6 | 00055B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AB8 | 00055C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ABA | 00055D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ABC | 00055E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ABE | 00055F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AC0 | 000560: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AC2 | 000561: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AC4 | 000562: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AC6 | 000563: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AC8 | 000564: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ACA | 000565: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ACC | 000566: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ACE | 000567: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AD0 | 000568: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AD2 | 000569: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AD4 | 00056A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AD6 | 00056B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AD8 | 00056C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ADA | 00056D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ADC | 00056E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ADE | 00056F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AE0 | 000570: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AE2 | 000571: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AE4 | 000572: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AE6 | 000573: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AE8 | 000574: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AEA | 000575: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AEC | 000576: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AEE | 000577: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AF0 | 000578: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AF2 | 000579: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AF4 | 00057A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AF6 | 00057B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AF8 | 00057C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AFA | 00057D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AFC | 00057E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000AFE | 00057F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B00 | 000580: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B02 | 000581: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B04 | 000582: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B06 | 000583: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B08 | 000584: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B0A | 000585: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B0C | 000586: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B0E | 000587: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B10 | 000588: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B12 | 000589: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B14 | 00058A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B16 | 00058B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B18 | 00058C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B1A | 00058D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B1C | 00058E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B1E | 00058F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B20 | 000590: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B22 | 000591: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B24 | 000592: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B26 | 000593: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B28 | 000594: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B2A | 000595: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B2C | 000596: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B2E | 000597: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B30 | 000598: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B32 | 000599: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B34 | 00059A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B36 | 00059B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B38 | 00059C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B3A | 00059D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B3C | 00059E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B3E | 00059F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B40 | 0005A0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B42 | 0005A1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B44 | 0005A2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B46 | 0005A3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B48 | 0005A4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B4A | 0005A5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B4C | 0005A6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B4E | 0005A7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B50 | 0005A8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B52 | 0005A9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B54 | 0005AA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B56 | 0005AB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B58 | 0005AC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B5A | 0005AD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B5C | 0005AE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B5E | 0005AF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B60 | 0005B0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B62 | 0005B1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B64 | 0005B2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B66 | 0005B3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B68 | 0005B4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B6A | 0005B5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B6C | 0005B6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B6E | 0005B7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B70 | 0005B8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B72 | 0005B9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B74 | 0005BA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B76 | 0005BB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B78 | 0005BC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B7A | 0005BD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B7C | 0005BE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B7E | 0005BF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B80 | 0005C0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B82 | 0005C1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B84 | 0005C2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B86 | 0005C3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B88 | 0005C4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B8A | 0005C5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B8C | 0005C6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B8E | 0005C7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B90 | 0005C8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B92 | 0005C9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B94 | 0005CA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B96 | 0005CB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B98 | 0005CC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B9A | 0005CD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B9C | 0005CE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000B9E | 0005CF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BA0 | 0005D0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BA2 | 0005D1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BA4 | 0005D2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BA6 | 0005D3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BA8 | 0005D4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BAA | 0005D5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BAC | 0005D6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BAE | 0005D7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BB0 | 0005D8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BB2 | 0005D9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BB4 | 0005DA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BB6 | 0005DB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BB8 | 0005DC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BBA | 0005DD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BBC | 0005DE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BBE | 0005DF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BC0 | 0005E0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BC2 | 0005E1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BC4 | 0005E2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BC6 | 0005E3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BC8 | 0005E4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BCA | 0005E5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BCC | 0005E6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BCE | 0005E7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BD0 | 0005E8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BD2 | 0005E9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BD4 | 0005EA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BD6 | 0005EB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BD8 | 0005EC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BDA | 0005ED: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BDC | 0005EE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BDE | 0005EF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BE0 | 0005F0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BE2 | 0005F1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BE4 | 0005F2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BE6 | 0005F3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BE8 | 0005F4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BEA | 0005F5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BEC | 0005F6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BEE | 0005F7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BF0 | 0005F8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BF2 | 0005F9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BF4 | 0005FA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BF6 | 0005FB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BF8 | 0005FC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BFA | 0005FD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BFC | 0005FE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000BFE | 0005FF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C00 | 000600: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C02 | 000601: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C04 | 000602: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C06 | 000603: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C08 | 000604: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C0A | 000605: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C0C | 000606: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C0E | 000607: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C10 | 000608: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C12 | 000609: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C14 | 00060A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C16 | 00060B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C18 | 00060C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C1A | 00060D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C1C | 00060E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C1E | 00060F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C20 | 000610: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C22 | 000611: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C24 | 000612: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C26 | 000613: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C28 | 000614: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C2A | 000615: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C2C | 000616: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C2E | 000617: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C30 | 000618: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C32 | 000619: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C34 | 00061A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C36 | 00061B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C38 | 00061C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C3A | 00061D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C3C | 00061E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C3E | 00061F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C40 | 000620: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C42 | 000621: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C44 | 000622: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C46 | 000623: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C48 | 000624: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C4A | 000625: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C4C | 000626: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C4E | 000627: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C50 | 000628: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C52 | 000629: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C54 | 00062A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C56 | 00062B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C58 | 00062C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C5A | 00062D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C5C | 00062E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C5E | 00062F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C60 | 000630: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C62 | 000631: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C64 | 000632: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C66 | 000633: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C68 | 000634: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C6A | 000635: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C6C | 000636: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C6E | 000637: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C70 | 000638: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C72 | 000639: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C74 | 00063A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C76 | 00063B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C78 | 00063C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C7A | 00063D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C7C | 00063E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C7E | 00063F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C80 | 000640: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C82 | 000641: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C84 | 000642: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C86 | 000643: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C88 | 000644: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C8A | 000645: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C8C | 000646: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C8E | 000647: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C90 | 000648: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C92 | 000649: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C94 | 00064A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C96 | 00064B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C98 | 00064C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C9A | 00064D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C9C | 00064E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000C9E | 00064F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CA0 | 000650: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CA2 | 000651: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CA4 | 000652: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CA6 | 000653: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CA8 | 000654: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CAA | 000655: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CAC | 000656: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CAE | 000657: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CB0 | 000658: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CB2 | 000659: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CB4 | 00065A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CB6 | 00065B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CB8 | 00065C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CBA | 00065D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CBC | 00065E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CBE | 00065F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CC0 | 000660: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CC2 | 000661: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CC4 | 000662: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CC6 | 000663: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CC8 | 000664: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CCA | 000665: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CCC | 000666: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CCE | 000667: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CD0 | 000668: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CD2 | 000669: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CD4 | 00066A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CD6 | 00066B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CD8 | 00066C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CDA | 00066D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CDC | 00066E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CDE | 00066F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CE0 | 000670: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CE2 | 000671: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CE4 | 000672: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CE6 | 000673: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CE8 | 000674: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CEA | 000675: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CEC | 000676: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CEE | 000677: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CF0 | 000678: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CF2 | 000679: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CF4 | 00067A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CF6 | 00067B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CF8 | 00067C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CFA | 00067D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CFC | 00067E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000CFE | 00067F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D00 | 000680: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D02 | 000681: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D04 | 000682: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D06 | 000683: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D08 | 000684: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D0A | 000685: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D0C | 000686: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D0E | 000687: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D10 | 000688: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D12 | 000689: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D14 | 00068A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D16 | 00068B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D18 | 00068C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D1A | 00068D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D1C | 00068E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D1E | 00068F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D20 | 000690: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D22 | 000691: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D24 | 000692: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D26 | 000693: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D28 | 000694: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D2A | 000695: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D2C | 000696: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D2E | 000697: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D30 | 000698: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D32 | 000699: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D34 | 00069A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D36 | 00069B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D38 | 00069C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D3A | 00069D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D3C | 00069E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D3E | 00069F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D40 | 0006A0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D42 | 0006A1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D44 | 0006A2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D46 | 0006A3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D48 | 0006A4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D4A | 0006A5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D4C | 0006A6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D4E | 0006A7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D50 | 0006A8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D52 | 0006A9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D54 | 0006AA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D56 | 0006AB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D58 | 0006AC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D5A | 0006AD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D5C | 0006AE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D5E | 0006AF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D60 | 0006B0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D62 | 0006B1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D64 | 0006B2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D66 | 0006B3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D68 | 0006B4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D6A | 0006B5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D6C | 0006B6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D6E | 0006B7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D70 | 0006B8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D72 | 0006B9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D74 | 0006BA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D76 | 0006BB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D78 | 0006BC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D7A | 0006BD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D7C | 0006BE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D7E | 0006BF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D80 | 0006C0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D82 | 0006C1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D84 | 0006C2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D86 | 0006C3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D88 | 0006C4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D8A | 0006C5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D8C | 0006C6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D8E | 0006C7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D90 | 0006C8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D92 | 0006C9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D94 | 0006CA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D96 | 0006CB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D98 | 0006CC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D9A | 0006CD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D9C | 0006CE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000D9E | 0006CF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DA0 | 0006D0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DA2 | 0006D1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DA4 | 0006D2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DA6 | 0006D3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DA8 | 0006D4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DAA | 0006D5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DAC | 0006D6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DAE | 0006D7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DB0 | 0006D8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DB2 | 0006D9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DB4 | 0006DA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DB6 | 0006DB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DB8 | 0006DC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DBA | 0006DD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DBC | 0006DE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DBE | 0006DF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DC0 | 0006E0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DC2 | 0006E1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DC4 | 0006E2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DC6 | 0006E3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DC8 | 0006E4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DCA | 0006E5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DCC | 0006E6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DCE | 0006E7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DD0 | 0006E8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DD2 | 0006E9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DD4 | 0006EA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DD6 | 0006EB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DD8 | 0006EC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DDA | 0006ED: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DDC | 0006EE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DDE | 0006EF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DE0 | 0006F0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DE2 | 0006F1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DE4 | 0006F2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DE6 | 0006F3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DE8 | 0006F4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DEA | 0006F5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DEC | 0006F6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DEE | 0006F7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DF0 | 0006F8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DF2 | 0006F9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DF4 | 0006FA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DF6 | 0006FB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DF8 | 0006FC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DFA | 0006FD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DFC | 0006FE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000DFE | 0006FF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E00 | 000700: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E02 | 000701: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E04 | 000702: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E06 | 000703: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E08 | 000704: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E0A | 000705: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E0C | 000706: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E0E | 000707: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E10 | 000708: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E12 | 000709: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E14 | 00070A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E16 | 00070B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E18 | 00070C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E1A | 00070D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E1C | 00070E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E1E | 00070F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E20 | 000710: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E22 | 000711: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E24 | 000712: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E26 | 000713: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E28 | 000714: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E2A | 000715: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E2C | 000716: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E2E | 000717: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E30 | 000718: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E32 | 000719: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E34 | 00071A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E36 | 00071B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E38 | 00071C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E3A | 00071D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E3C | 00071E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E3E | 00071F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E40 | 000720: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E42 | 000721: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E44 | 000722: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E46 | 000723: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E48 | 000724: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E4A | 000725: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E4C | 000726: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E4E | 000727: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E50 | 000728: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E52 | 000729: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E54 | 00072A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E56 | 00072B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E58 | 00072C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E5A | 00072D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E5C | 00072E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E5E | 00072F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E60 | 000730: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E62 | 000731: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E64 | 000732: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E66 | 000733: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E68 | 000734: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E6A | 000735: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E6C | 000736: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E6E | 000737: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E70 | 000738: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E72 | 000739: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E74 | 00073A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E76 | 00073B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E78 | 00073C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E7A | 00073D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E7C | 00073E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E7E | 00073F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E80 | 000740: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E82 | 000741: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E84 | 000742: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E86 | 000743: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E88 | 000744: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E8A | 000745: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E8C | 000746: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E8E | 000747: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E90 | 000748: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E92 | 000749: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E94 | 00074A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E96 | 00074B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E98 | 00074C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E9A | 00074D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E9C | 00074E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000E9E | 00074F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EA0 | 000750: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EA2 | 000751: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EA4 | 000752: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EA6 | 000753: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EA8 | 000754: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EAA | 000755: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EAC | 000756: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EAE | 000757: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EB0 | 000758: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EB2 | 000759: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EB4 | 00075A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EB6 | 00075B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EB8 | 00075C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EBA | 00075D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EBC | 00075E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EBE | 00075F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EC0 | 000760: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EC2 | 000761: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EC4 | 000762: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EC6 | 000763: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EC8 | 000764: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ECA | 000765: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ECC | 000766: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ECE | 000767: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ED0 | 000768: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ED2 | 000769: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ED4 | 00076A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ED6 | 00076B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000ED8 | 00076C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EDA | 00076D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EDC | 00076E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EDE | 00076F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EE0 | 000770: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EE2 | 000771: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EE4 | 000772: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EE6 | 000773: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EE8 | 000774: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EEA | 000775: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EEC | 000776: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EEE | 000777: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EF0 | 000778: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EF2 | 000779: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EF4 | 00077A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EF6 | 00077B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EF8 | 00077C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EFA | 00077D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EFC | 00077E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000EFE | 00077F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F00 | 000780: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F02 | 000781: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F04 | 000782: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F06 | 000783: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F08 | 000784: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F0A | 000785: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F0C | 000786: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F0E | 000787: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F10 | 000788: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F12 | 000789: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F14 | 00078A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F16 | 00078B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F18 | 00078C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F1A | 00078D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F1C | 00078E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F1E | 00078F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F20 | 000790: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F22 | 000791: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F24 | 000792: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F26 | 000793: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F28 | 000794: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F2A | 000795: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F2C | 000796: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F2E | 000797: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F30 | 000798: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F32 | 000799: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F34 | 00079A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F36 | 00079B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F38 | 00079C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F3A | 00079D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F3C | 00079E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F3E | 00079F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F40 | 0007A0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F42 | 0007A1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F44 | 0007A2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F46 | 0007A3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F48 | 0007A4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F4A | 0007A5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F4C | 0007A6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F4E | 0007A7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F50 | 0007A8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F52 | 0007A9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F54 | 0007AA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F56 | 0007AB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F58 | 0007AC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F5A | 0007AD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F5C | 0007AE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F5E | 0007AF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F60 | 0007B0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F62 | 0007B1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F64 | 0007B2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F66 | 0007B3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F68 | 0007B4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F6A | 0007B5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F6C | 0007B6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F6E | 0007B7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F70 | 0007B8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F72 | 0007B9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F74 | 0007BA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F76 | 0007BB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F78 | 0007BC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F7A | 0007BD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F7C | 0007BE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F7E | 0007BF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F80 | 0007C0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F82 | 0007C1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F84 | 0007C2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F86 | 0007C3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F88 | 0007C4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F8A | 0007C5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F8C | 0007C6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F8E | 0007C7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F90 | 0007C8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F92 | 0007C9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F94 | 0007CA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F96 | 0007CB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F98 | 0007CC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F9A | 0007CD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F9C | 0007CE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000F9E | 0007CF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FA0 | 0007D0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FA2 | 0007D1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FA4 | 0007D2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FA6 | 0007D3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FA8 | 0007D4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FAA | 0007D5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FAC | 0007D6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FAE | 0007D7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FB0 | 0007D8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FB2 | 0007D9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FB4 | 0007DA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FB6 | 0007DB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FB8 | 0007DC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FBA | 0007DD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FBC | 0007DE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FBE | 0007DF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FC0 | 0007E0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FC2 | 0007E1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FC4 | 0007E2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FC6 | 0007E3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FC8 | 0007E4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FCA | 0007E5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FCC | 0007E6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FCE | 0007E7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FD0 | 0007E8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FD2 | 0007E9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FD4 | 0007EA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FD6 | 0007EB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FD8 | 0007EC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FDA | 0007ED: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FDC | 0007EE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FDE | 0007EF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FE0 | 0007F0: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FE2 | 0007F1: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FE4 | 0007F2: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FE6 | 0007F3: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FE8 | 0007F4: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FEA | 0007F5: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FEC | 0007F6: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FEE | 0007F7: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FF0 | 0007F8: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FF2 | 0007F9: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FF4 | 0007FA: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FF6 | 0007FB: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FF8 | 0007FC: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FFA | 0007FD: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FFC | 0007FE: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
000FFE | 0007FF: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001000 | 000800: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001002 | 000801: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001004 | 000802: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001006 | 000803: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001008 | 000804: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00100A | 000805: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00100C | 000806: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00100E | 000807: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001010 | 000808: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001012 | 000809: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001014 | 00080A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001016 | 00080B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001018 | 00080C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00101A | 00080D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00101C | 00080E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00101E | 00080F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001020 | 000810: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001022 | 000811: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001024 | 000812: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001026 | 000813: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001028 | 000814: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00102A | 000815: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00102C | 000816: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00102E | 000817: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001030 | 000818: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001032 | 000819: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001034 | 00081A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001036 | 00081B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001038 | 00081C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00103A | 00081D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00103C | 00081E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00103E | 00081F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001040 | 000820: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001042 | 000821: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001044 | 000822: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001046 | 000823: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001048 | 000824: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00104A | 000825: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00104C | 000826: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00104E | 000827: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001050 | 000828: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001052 | 000829: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001054 | 00082A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001056 | 00082B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001058 | 00082C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00105A | 00082D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00105C | 00082E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00105E | 00082F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001060 | 000830: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001062 | 000831: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001064 | 000832: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001066 | 000833: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001068 | 000834: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00106A | 000835: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00106C | 000836: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00106E | 000837: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001070 | 000838: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001072 | 000839: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001074 | 00083A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001076 | 00083B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001078 | 00083C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00107A | 00083D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00107C | 00083E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00107E | 00083F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001080 | 000840: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001082 | 000841: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001084 | 000842: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001086 | 000843: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001088 | 000844: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00108A | 000845: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00108C | 000846: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00108E | 000847: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001090 | 000848: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001092 | 000849: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001094 | 00084A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001096 | 00084B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001098 | 00084C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00109A | 00084D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00109C | 00084E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00109E | 00084F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010A0 | 000850: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010A2 | 000851: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010A4 | 000852: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010A6 | 000853: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010A8 | 000854: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010AA | 000855: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010AC | 000856: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010AE | 000857: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010B0 | 000858: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010B2 | 000859: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010B4 | 00085A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010B6 | 00085B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010B8 | 00085C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010BA | 00085D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010BC | 00085E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010BE | 00085F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010C0 | 000860: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010C2 | 000861: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010C4 | 000862: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010C6 | 000863: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010C8 | 000864: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010CA | 000865: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010CC | 000866: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010CE | 000867: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010D0 | 000868: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010D2 | 000869: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010D4 | 00086A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010D6 | 00086B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010D8 | 00086C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010DA | 00086D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010DC | 00086E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010DE | 00086F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010E0 | 000870: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010E2 | 000871: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010E4 | 000872: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010E6 | 000873: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010E8 | 000874: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010EA | 000875: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010EC | 000876: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010EE | 000877: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010F0 | 000878: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010F2 | 000879: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010F4 | 00087A: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010F6 | 00087B: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010F8 | 00087C: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010FA | 00087D: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010FC | 00087E: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
0010FE | 00087F: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001100 | 000880: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001102 | 000881: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001104 | 000882: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001106 | 000883: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001108 | 000884: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00110A | 000885: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00110C | 000886: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
00110E | 000887: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001110 | 000888: 0BC3      	LD	rC, *ptrB3		;EXT4 <- (dp_B0++)
001112 | 000889: 0065      	LD	r6, r5		;PC <- STACK


L_0D69:
001AD2 | 000D69: 07C1      	LD	r3, B[C1]		;AH <- B[C1]
001AD4 | 000D6A: 8800 0D6D 	ADD	r3, #0D6D		;ACC += #0D6D
001AD8 | 000D6C: 4A60      	LD	r6, (r3)		;PC <- (AH)			data array L_0D6D
L_0D6D:
001ADA | 000D6D: 0E55
001ADC | 000D6E: 0E55

L_0D6F:
001ADE | 000D6F: 1C20      	LD	pB0, #20		;pB0 <- #20
001AE0 | 000D70: 0D04 02AA 	LD	ptrB4, #02AA	;[p_B0++] <- #02AA
001AE4 | 000D72: 0D04 0800 	LD	ptrB4, #0800	;[p_B0++] <- #0800
001AE8 | 000D74: 0D04 F000 	LD	ptrB4, #F000	;[p_B0++] <- #F000
001AEC | 000D76: 0D04 0000 	LD	ptrB4, #0000	;[p_B0++] <- #0000
001AF0 | 000D78: 0D04 0AAA 	LD	ptrB4, #0AAA	;[p_B0++] <- #0AAA
001AF4 | 000D7A: 0D04 F800 	LD	ptrB4, #F800	;[p_B0++] <- #F800
001AF8 | 000D7C: 0D04 0800 	LD	ptrB4, #0800	;[p_B0++] <- #0800
001AFC | 000D7E: 0D04 0800 	LD	ptrB4, #0800	;[p_B0++] <- #0800
001B00 | 000D80: 0D04 02AA 	LD	ptrB4, #02AA	;[p_B0++] <- #02AA
001B04 | 000D82: 0D04 02AA 	LD	ptrB4, #02AA	;[p_B0++] <- #02AA
001B08 | 000D84: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001B0A | 000D85: 0E27      	LD	RAMA[27], r3	;RAMA[27] <- AH
001B0C | 000D86: 0013      	LD	r1, r3		;X <- AH
001B0E | 000D87: 0023      	LD	r2, r3		;Y <- AH
001B10 | 000D88: 0037      	LD	r3, r7		;AH <- P
001B12 | 000D89: 9003      	SHL	ACC			;
001B14 | 000D8A: 9003      	SHL	ACC			;
001B16 | 000D8B: 9003      	SHL	ACC			;
001B18 | 000D8C: 0E22      	LD	RAMA[22], r3	;RAMA[22] <- AH
001B1A | 000D8D: 0E26      	LD	RAMA[26], r3	;RAMA[26] <- AH
001B1C | 000D8E: 0013      	LD	r1, r3		;X <- AH
001B1E | 000D8F: 0037      	LD	r3, r7		;AH <- P
001B20 | 000D90: 9003      	SHL	ACC			;
001B22 | 000D91: 9003      	SHL	ACC			;
001B24 | 000D92: 9003      	SHL	ACC			;
001B26 | 000D93: 0E21      	LD	RAMA[21], r3	;RAMA[21] <- AH
001B28 | 000D94: 0E25      	LD	RAMA[25], r3	;RAMA[25] <- AH
001B2A | 000D95: 0E29      	LD	RAMA[29], r3	;RAMA[29] <- AH
001B2C | 000D96: 0830 1000 	LD	r3, #1000		;AH <- #1000
001B30 | 000D98: 27C0      	SUB	r3, RAMB[C0]	;ACC -= RAMB[C0]
001B32 | 000D99: 0013      	LD	r1, r3		;X <- AH
001B34 | 000D9A: 0023      	LD	r2, r3		;Y <- AH
001B36 | 000D9B: 0037      	LD	r3, r7		;AH <- P
001B38 | 000D9C: 9003      	SHL	ACC			;
001B3A | 000D9D: 9003      	SHL	ACC			;
001B3C | 000D9E: 9003      	SHL	ACC			;
001B3E | 000D9F: 0013      	LD	r1, r3		;X <- AH
001B40 | 000DA0: 0037      	LD	r3, r7		;AH <- P
001B42 | 000DA1: 9003      	SHL	ACC			;
001B44 | 000DA2: 9003      	SHL	ACC			;
001B46 | 000DA3: 9003      	SHL	ACC			;
001B48 | 000DA4: 0E20      	LD	RAMA[20], r3	;RAMA[20] <- AH
001B4A | 000DA5: 1D13      	LD	pB1, #13		;pB1 <- #13
001B4C | 000DA6: 4C00 0E8E 	BRA	0E8E			;PC <- 1D1C			L_0E8E
L_0DA8:
001B50 | 000DA8: 1C20      	LD	pB0, #20		;pB0 <- #20
001B52 | 000DA9: 0D04 1000 	LD	ptrB4, #1000	;[p_B0++] <- #1000
001B56 | 000DAB: 0D04 1C00 	LD	ptrB4, #1C00	;[p_B0++] <- #1C00
001B5A | 000DAD: 0D04 B800 	LD	ptrB4, #B800	;[p_B0++] <- #B800
001B5E | 000DAF: 0D04 3000 	LD	ptrB4, #3000	;[p_B0++] <- #3000
001B62 | 000DB1: 0D04 0000 	LD	ptrB4, #0000	;[p_B0++] <- #0000
001B66 | 000DB3: 0D04 F156 	LD	ptrB4, #F156	;[p_B0++] <- #F156
001B6A | 000DB5: 0D04 1800 	LD	ptrB4, #1800	;[p_B0++] <- #1800
001B6E | 000DB7: 0D04 0000 	LD	ptrB4, #0000	;[p_B0++] <- #0000
001B72 | 000DB9: 0D04 0000 	LD	ptrB4, #0000	;[p_B0++] <- #0000
001B76 | 000DBB: 0D04 02AA 	LD	ptrB4, #02AA	;[p_B0++] <- #02AA
001B7A | 000DBD: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001B7C | 000DBE: 0E23      	LD	RAMA[23], r3	;RAMA[23] <- AH
001B7E | 000DBF: 0013      	LD	r1, r3		;X <- AH
001B80 | 000DC0: 0023      	LD	r2, r3		;Y <- AH
001B82 | 000DC1: 0037      	LD	r3, r7		;AH <- P
001B84 | 000DC2: 9003      	SHL	ACC			;
001B86 | 000DC3: 9003      	SHL	ACC			;
001B88 | 000DC4: 9003      	SHL	ACC			;
001B8A | 000DC5: 0E22      	LD	RAMA[22], r3	;RAMA[22] <- AH
001B8C | 000DC6: 0E26      	LD	RAMA[26], r3	;RAMA[26] <- AH
001B8E | 000DC7: 0013      	LD	r1, r3		;X <- AH
001B90 | 000DC8: 0037      	LD	r3, r7		;AH <- P
001B92 | 000DC9: 9003      	SHL	ACC			;
001B94 | 000DCA: 9003      	SHL	ACC			;
001B96 | 000DCB: 9003      	SHL	ACC			;
001B98 | 000DCC: 0E21      	LD	RAMA[21], r3	;RAMA[21] <- AH
001B9A | 000DCD: 0E25      	LD	RAMA[25], r3	;RAMA[25] <- AH
001B9C | 000DCE: 0E29      	LD	RAMA[29], r3	;RAMA[29] <- AH
001B9E | 000DCF: 0830 1000 	LD	r3, #1000		;AH <- #1000
001BA2 | 000DD1: 27C0      	SUB	r3, RAMB[C0]	;ACC -= RAMB[C0]
001BA4 | 000DD2: 0013      	LD	r1, r3		;X <- AH
001BA6 | 000DD3: 0023      	LD	r2, r3		;Y <- AH
001BA8 | 000DD4: 0037      	LD	r3, r7		;AH <- P
001BAA | 000DD5: 9003      	SHL	ACC			;
001BAC | 000DD6: 9003      	SHL	ACC			;
001BAE | 000DD7: 9003      	SHL	ACC			;
001BB0 | 000DD8: 0013      	LD	r1, r3		;X <- AH
001BB2 | 000DD9: 0037      	LD	r3, r7		;AH <- P
001BB4 | 000DDA: 9003      	SHL	ACC			;
001BB6 | 000DDB: 9003      	SHL	ACC			;
001BB8 | 000DDC: 9003      	SHL	ACC			;
001BBA | 000DDD: 0E20      	LD	RAMA[20], r3	;RAMA[20] <- AH
001BBC | 000DDE: 1D13      	LD	pB1, #13		;pB1 <- #13
001BBE | 000DDF: 4C00 0E8E 	BRA	0E8E			;PC <- 1D1C			L_0E8E
L_0DE1:
001BC2 | 000DE1: 1C20      	LD	pB0, #20		;pB0 <- #20
001BC4 | 000DE2: 0D04 0400 	LD	ptrB4, #0400	;[p_B0++] <- #0400
001BC8 | 000DE4: 0D04 0955 	LD	ptrB4, #0955	;[p_B0++] <- #0955
001BCC | 000DE6: 0D04 EC00 	LD	ptrB4, #EC00	;[p_B0++] <- #EC00
001BD0 | 000DE8: 0D04 0400 	LD	ptrB4, #0400	;[p_B0++] <- #0400
001BD4 | 000DEA: 0D04 0955 	LD	ptrB4, #0955	;[p_B0++] <- #0955
001BD8 | 000DEC: 0D04 F800 	LD	ptrB4, #F800	;[p_B0++] <- #F800
001BDC | 000DEE: 0D04 0800 	LD	ptrB4, #0800	;[p_B0++] <- #0800
001BE0 | 000DF0: 0D04 0800 	LD	ptrB4, #0800	;[p_B0++] <- #0800
001BE4 | 000DF2: 0D04 02AA 	LD	ptrB4, #02AA	;[p_B0++] <- #02AA
001BE8 | 000DF4: 0D04 02AA 	LD	ptrB4, #02AA	;[p_B0++] <- #02AA
001BEC | 000DF6: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001BEE | 000DF7: 0E23      	LD	RAMA[23], r3	;RAMA[23] <- AH
001BF0 | 000DF8: 0E27      	LD	RAMA[27], r3	;RAMA[27] <- AH
001BF2 | 000DF9: 0013      	LD	r1, r3		;X <- AH
001BF4 | 000DFA: 0023      	LD	r2, r3		;Y <- AH
001BF6 | 000DFB: 0037      	LD	r3, r7		;AH <- P
001BF8 | 000DFC: 9003      	SHL	ACC			;
001BFA | 000DFD: 9003      	SHL	ACC			;
001BFC | 000DFE: 9003      	SHL	ACC			;
001BFE | 000DFF: 0E22      	LD	RAMA[22], r3	;RAMA[22] <- AH
001C00 | 000E00: 0E26      	LD	RAMA[26], r3	;RAMA[26] <- AH
001C02 | 000E01: 0013      	LD	r1, r3		;X <- AH
001C04 | 000E02: 0037      	LD	r3, r7		;AH <- P
001C06 | 000E03: 9003      	SHL	ACC			;
001C08 | 000E04: 9003      	SHL	ACC			;
001C0A | 000E05: 9003      	SHL	ACC			;
001C0C | 000E06: 0E21      	LD	RAMA[21], r3	;RAMA[21] <- AH
001C0E | 000E07: 0E25      	LD	RAMA[25], r3	;RAMA[25] <- AH
001C10 | 000E08: 0E29      	LD	RAMA[29], r3	;RAMA[29] <- AH
001C12 | 000E09: 0830 1000 	LD	r3, #1000		;AH <- #1000
001C16 | 000E0B: 27C0      	SUB	r3, RAMB[C0]	;ACC -= RAMB[C0]
001C18 | 000E0C: 0013      	LD	r1, r3		;X <- AH
001C1A | 000E0D: 0023      	LD	r2, r3		;Y <- AH
001C1C | 000E0E: 0037      	LD	r3, r7		;AH <- P
001C1E | 000E0F: 9003      	SHL	ACC			;
001C20 | 000E10: 9003      	SHL	ACC			;
001C22 | 000E11: 9003      	SHL	ACC			;
001C24 | 000E12: 0013      	LD	r1, r3		;X <- AH
001C26 | 000E13: 0037      	LD	r3, r7		;AH <- P
001C28 | 000E14: 9003      	SHL	ACC			;
001C2A | 000E15: 9003      	SHL	ACC			;
001C2C | 000E16: 9003      	SHL	ACC			;
001C2E | 000E17: 0E20      	LD	RAMA[20], r3	;RAMA[20] <- AH
001C30 | 000E18: 1D10      	LD	pB1, #10		;pB1 <- #10
001C32 | 000E19: 4C00 0E8E 	BRA	0E8E			;PC <- 1D1C			L_0E8E
L_0E1B:
001C36 | 000E1B: 1C20      	LD	pB0, #20		;pB0 <- #20
001C38 | 000E1C: 0D04 02AA 	LD	ptrB4, #02AA	;[p_B0++] <- #02AA
001C3C | 000E1E: 0D04 F800 	LD	ptrB4, #F800	;[p_B0++] <- #F800
001C40 | 000E20: 0D04 0800 	LD	ptrB4, #0800	;[p_B0++] <- #0800
001C44 | 000E22: 0D04 0800 	LD	ptrB4, #0800	;[p_B0++] <- #0800
001C48 | 000E24: 0D04 02AA 	LD	ptrB4, #02AA	;[p_B0++] <- #02AA
001C4C | 000E26: 0D04 0955 	LD	ptrB4, #0955	;[p_B0++] <- #0955
001C50 | 000E28: 0D04 EC00 	LD	ptrB4, #EC00	;[p_B0++] <- #EC00
001C54 | 000E2A: 0D04 0400 	LD	ptrB4, #0400	;[p_B++] <- #0400
001C58 | 000E2C: 0D04 0955 	LD	ptrB4, #0955	;[p_B0++] <- #0955
001C5C | 000E2E: 0D04 0400 	LD	ptrB4, #0400	;[p_B0++] <- #0400
001C60 | 000E30: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001C62 | 000E31: 0013      	LD	r1, r3		;X <- AH
001C64 | 000E32: 0023      	LD	r2, r3		;Y <- AH
001C66 | 000E33: 0037      	LD	r3, r7		;AH <- P
001C68 | 000E34: 9003      	SHL	ACC			;
001C6A | 000E35: 9003      	SHL	ACC			;
001C6C | 000E36: 9003      	SHL	ACC			;
001C6E | 000E37: 0013      	LD	r1, r3		;X <- AH
001C70 | 000E38: 0037      	LD	r3, r7		;AH <- P
001C72 | 000E39: 9003      	SHL	ACC			;
001C74 | 000E3A: 9003      	SHL	ACC			;
001C76 | 000E3B: 9003      	SHL	ACC			;
001C78 | 000E3C: 0E29      	LD	RAMA[29], r3	;RAMA[29] <- AH
001C7A | 000E3D: 0830 1000 	LD	r3, #1000		;AH <- #1000
001C7E | 000E3F: 27C0      	SUB	r3, RAMB[C0]	;ACC -= RAMB[C0]
001C80 | 000E40: 0E23      	LD	RAMA[23], r3	;RAMA[23] <- AH
001C82 | 000E41: 0E27      	LD	RAMA[27], r3	;RAMA[27] <- AH
001C84 | 000E42: 0013      	LD	r1, r3		;X <- AH
001C86 | 000E43: 0023      	LD	r2, r3		;Y <- AH
001C88 | 000E44: 0037      	LD	r3, r7		;AH <- P
001C8A | 000E45: 9003      	SHL	ACC			;
001C8C | 000E46: 9003      	SHL	ACC			;
001C8E | 000E47: 9003      	SHL	ACC			;
001C90 | 000E48: 0E22      	LD	RAMA[22], r3	;RAMA[22] <- AH
001C92 | 000E49: 0E26      	LD	RAMA[26], r3	;RAMA[26] <- AH
001C94 | 000E4A: 0013      	LD	r1, r3		;X <- AH
001C96 | 000E4B: 0037      	LD	r3, r7		;AH <- P
001C98 | 000E4C: 9003      	SHL	ACC			;
001C9A | 000E4D: 9003      	SHL	ACC			;
001C9C | 000E4E: 9003      	SHL	ACC			;
001C9E | 000E4F: 0E20      	LD	RAMA[20], r3	;RAMA[20] <- AH
001CA0 | 000E50: 0E21      	LD	RAMA[21], r3	;RAMA[21] <- AH
001CA2 | 000E51: 0E25      	LD	RAMA[25], r3	;RAMA[25] <- AH
001CA4 | 000E52: 1D13      	LD	pB1, #13		;pB1 <- #13
001CA6 | 000E53: 4C00 0E8E 	BRA	0E8E			;PC <- 1D1C			L_0E8E
L_0E55:
001CAA | 000E55: 1C20      	LD	pB0, #20		;pB0 <- #20
001CAC | 000E56: 0D04 02AA 	LD	ptrB4, #02AA	;[p_B0++] <- #02AA
001CB0 | 000E58: 0D04 F156 	LD	ptrB4, #F156	;[p_B0++] <- #F156
001CB4 | 000E5A: 0D04 1800 	LD	ptrB4, #1800	;[p_B0++] <- #1800
001CB8 | 000E5C: 0D04 0000 	LD	ptrB4, #0000	;[p_B0++] <- #0000
001CBC | 000E5E: 0D04 0000 	LD	ptrB4, #0000	;[p_B0++] <- #0000
001CC0 | 000E60: 0D04 1C00 	LD	ptrB4, #1C00	;[p_B0++] <- #1C00
001CC4 | 000E62: 0D04 B800 	LD	ptrB4, #B800	;[p_B0++] <- #B800
001CC8 | 000E64: 0D04 3000 	LD	ptrB4, #3000	;[p_B0++] <- #3000
001CCC | 000E66: 0D04 0000 	LD	ptrB4, #0000	;[p_B0++] <- #0000
001CD0 | 000E68: 0D04 1000 	LD	ptrB4, #1000	;[p_B0++] <- #1000
001CD4 | 000E6A: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001CD6 | 000E6B: 0013      	LD	r1, r3		;X <- AH
001CD8 | 000E6C: 0023      	LD	r2, r3		;Y <- AH
001CDA | 000E6D: 0037      	LD	r3, r7		;AH <- P
001CDC | 000E6E: 9003      	SHL	ACC			;
001CDE | 000E6F: 9003      	SHL	ACC			;
001CE0 | 000E70: 9003      	SHL	ACC			;
001CE2 | 000E71: 0013      	LD	r1, r3		;X <- AH
001CE4 | 000E72: 0037      	LD	r3, r7		;AH <- P
001CE6 | 000E73: 9003      	SHL	ACC			;
001CE8 | 000E74: 9003      	SHL	ACC			;
001CEA | 000E75: 9003      	SHL	ACC			;
001CEC | 000E76: 0E29      	LD	RAMA[29], r3	;RAMA[29] <- AH
001CEE | 000E77: 0830 1000 	LD	r3, #1000		;AH <- #1000
001CF2 | 000E79: 27C0      	SUB	r3, RAMB[C0]	;ACC -= RAMB[C0]
001CF4 | 000E7A: 0E27      	LD	RAMA[27], r3	;RAMA[27] <- AH
001CF6 | 000E7B: 0013      	LD	r1, r3		;X <- AH
001CF8 | 000E7C: 0023      	LD	r2, r3		;Y <- AH
001CFA | 000E7D: 0037      	LD	r3, r7		;AH <- P
001CFC | 000E7E: 9003      	SHL	ACC			;
001CFE | 000E7F: 9003      	SHL	ACC			;
001D00 | 000E80: 9003      	SHL	ACC			;
001D02 | 000E81: 0E22      	LD	RAMA[22], r3	;RAMA[22] <- AH
001D04 | 000E82: 0E26      	LD	RAMA[26], r3	;RAMA[26] <- AH
001D06 | 000E83: 0013      	LD	r1, r3		;X <- AH
001D08 | 000E84: 0037      	LD	r3, r7		;AH <- P
001D0A | 000E85: 9003      	SHL	ACC			;
001D0C | 000E86: 9003      	SHL	ACC			;
001D0E | 000E87: 9003      	SHL	ACC			;
001D10 | 000E88: 0E20      	LD	RAMA[20], r3	;RAMA[20] <- AH
001D12 | 000E89: 0E21      	LD	RAMA[21], r3	;RAMA[21] <- AH
001D14 | 000E8A: 0E25      	LD	RAMA[25], r3	;RAMA[25] <- AH
001D16 | 000E8B: 1D10      	LD	pB1, #10		;pB1 <- #10
001D18 | 000E8C: 4C00 0E8E 	BRA	0E8E			;PC <- 1D1C			L_0E8E

L_0E8E:
001D1C | 000E8E: 1820      	LD	pA0, #20		;pA0 <- #20
001D1E | 000E8F: 1C20      	LD	pB0, #20		;pB0 <- #20
001D20 | 000E90: B744      	MLD	ptrA4, ptrB4	;ACC = 0, X <- [p_A0++], Y <- [p_B0++]
001D22 | 000E91: 8007      	ADD	r3, r7		;ACC += P
001D24 | 000E92: 9003      	SHL	ACC			;
001D26 | 000E93: 9003      	SHL	ACC			;
001D28 | 000E94: 9003      	SHL	ACC			;
001D2A | 000E95: 0E10      	LD	RAMA[10], r3	;RAMA[10] <- AH
001D2C | 000E96: B744      	MLD	ptrA4, ptrB4	;ACC = 0, X <- [p_A0++], Y <- [p_B0++]
001D2E | 000E97: 9744      	MPYA	ptrA4, ptrB4	;ACC += P, X <- [p_A0++], Y <- [p_B0++]
001D30 | 000E98: 9744      	MPYA	ptrA4, ptrB4	;ACC += P, X <- [p_A0++], Y <- [p_B0++]
001D32 | 000E99: 9744      	MPYA	ptrA4, ptrB4	;ACC += P, X <- [p_A0++], Y <- [p_B0++]
001D34 | 000E9A: 8007      	ADD	r3, r7		;ACC += P
001D36 | 000E9B: 9003      	SHL	ACC			;
001D38 | 000E9C: 9003      	SHL	ACC			;
001D3A | 000E9D: 9003      	SHL	ACC			;
001D3C | 000E9E: 0E11      	LD	RAMA[11], r3	;RAMA[11] <- AH
001D3E | 000E9F: B744      	MLD	ptrA4, ptrB4	;ACC = 0, X <- [p_A0++], Y <- [p_B0++]
001D40 | 000EA0: 9744      	MPYA	ptrA4, ptrB4	;ACC += P, X <- [p_A0++], Y <- [p_B0++]
001D42 | 000EA1: 9744      	MPYA	ptrA4, ptrB4	;ACC += P, X <- [p_A0++], Y <- [p_B0++]
001D44 | 000EA2: 9744      	MPYA	ptrA4, ptrB4	;ACC += P, X <- [p_A0++], Y <- [p_B0++]
001D46 | 000EA3: 8007      	ADD	r3, r7		;ACC += P
001D48 | 000EA4: 9003      	SHL	ACC			;
001D4A | 000EA5: 9003      	SHL	ACC			;
001D4C | 000EA6: 9003      	SHL	ACC			;
001D4E | 000EA7: 0E12      	LD	RAMA[12], r3	;RAMA[12] <- AH
001D50 | 000EA8: B744      	MLD	ptrA4, ptrB4	;ACC = 0, X <- [p_A0++], Y <- [p_B0++]
001D52 | 000EA9: 8007      	ADD	r3, r7		;ACC += P
001D54 | 000EAA: 9003      	SHL	ACC			;
001D56 | 000EAB: 9003      	SHL	ACC			;
001D58 | 000EAC: 9003      	SHL	ACC			;
001D5A | 000EAD: 0E13      	LD	RAMA[13], r3	;RAMA[13] <- AH
001D5C | 000EAE: 1810      	LD	pA0, #10		;pA0 <- #10
001D5E | 000EAF: B754      	MLD	ptrA4, ptrB5	;ACC = 0, X <- [p_A0++], Y <- [p_B1++]
001D60 | 000EB0: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D62 | 000EB1: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D64 | 000EB2: 9754      	MPYA	ptrA4, ptrB5	;ACC += P, X <- [p_A0++], Y <- [p_B1++]
001D66 | 000EB3: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D68 | 000EB4: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D6A | 000EB5: 9754      	MPYA	ptrA4, ptrB5	;ACC += P, X <- [p_A0++], Y <- [p_B1++]
001D6C | 000EB6: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D6E | 000EB7: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D70 | 000EB8: 9754      	MPYA	ptrA4, ptrB5	;ACC += P, X <- [p_A0++], Y <- [p_B1++]
001D72 | 000EB9: 8007      	ADD	r3, r7		;ACC += P
001D74 | 000EBA: 9003      	SHL	ACC			;
001D76 | 000EBB: 9003      	SHL	ACC			;
001D78 | 000EBC: 9003      	SHL	ACC			;
001D7A | 000EBD: 0E14      	LD	RAMA[14], r3	;RAMA[14] <- AH
001D7C | 000EBE: 1331      	LD	r3, pB1		;AH <- p_B1
001D7E | 000EBF: 3809      	SUB	r3, #09		;ACC -= #09
001D80 | 000EC0: 1531      	LD	pB1, r3		;p_B1 <- AH
001D82 | 000EC1: 1810      	LD	pA0, #10		;pA0 <- #10
001D84 | 000EC2: B754      	MLD	ptrA4, ptrB5	;ACC = 0, X <- [p_A0++], Y <- [p_B1++]
001D86 | 000EC3: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D88 | 000EC4: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D8A | 000EC5: 9754      	MPYA	ptrA4, ptrB5	;ACC += P, X <- [p_A0++], Y <- [p_B1++]
001D8C | 000EC6: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D8E | 000EC7: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D90 | 000EC8: 9754      	MPYA	ptrA4, ptrB5	;ACC += P, X <- [p_A0++], Y <- [p_B1++]
001D92 | 000EC9: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D94 | 000ECA: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001D96 | 000ECB: 9754      	MPYA	ptrA4, ptrB5	;ACC += P, X <- [p_A0++], Y <- [p_B1++]
001D98 | 000ECC: 8007      	ADD	r3, r7		;ACC += P
001D9A | 000ECD: 9003      	SHL	ACC			;
001D9C | 000ECE: 9003      	SHL	ACC			;
001D9E | 000ECF: 9003      	SHL	ACC			;
001DA0 | 000ED0: 0E15      	LD	RAMA[15], r3	;RAMA[15] <- AH
001DA2 | 000ED1: 1331      	LD	r3, pB1		;AH <- p_B1
001DA4 | 000ED2: 3809      	SUB	r3, #09		;ACC -= #09
001DA6 | 000ED3: 1531      	LD	pB1, r3		;p_B1 <- AH
001DA8 | 000ED4: 1810      	LD	pA0, #10		;pA0 <- #10
001DAA | 000ED5: B754      	MLD	ptrA4, ptrB5	;ACC = 0, X <- [p_A0++], Y <- [p_B1++]
001DAC | 000ED6: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001DAE | 000ED7: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001DB0 | 000ED8: 9754      	MPYA	ptrA4, ptrB5	;ACC += P, X <- [p_A0++], Y <- [p_B1++]
001DB2 | 000ED9: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001DB4 | 000EDA: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001DB6 | 000EDB: 9754      	MPYA	ptrA4, ptrB5	;ACC += P, X <- [p_A0++], Y <- [p_B1++]
001DB8 | 000EDC: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001DBA | 000EDD: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
001DBC | 000EDE: 9754      	MPYA	ptrA4, ptrB5	;ACC += P, X <- [p_A0++], Y <- [p_B1++]
001DBE | 000EDF: 8007      	ADD	r3, r7		;ACC += P
001DC0 | 000EE0: 9003      	SHL	ACC			;
001DC2 | 000EE1: 9003      	SHL	ACC			;
001DC4 | 000EE2: 9003      	SHL	ACC			;
001DC6 | 000EE3: 0E16      	LD	RAMA[16], r3	;RAMA[16] <- AH
001DC8 | 000EE4: 0065      	LD	r6, r5		;PC <- STACK

L_0EE5:								;SEGA logo
001DCA | 000EE5: 0034      	LD	r3, r4		;AH <- ST
001DCC | 000EE6: D860      	OR	r3, #60		;ACC |= #60
001DCE | 000EE7: 0043      	LD	r4, r3		;ST <- AH
001DD0 | 000EE8: 0830 00C0 	LD	r3, #00C0		;AH <- #00C0
001DD4 | 000EEA: 0FE2      	LD	B[E2], r3		;B[E2] <- AH
001DD6 | 000EEB: B800      	AND	r3, #00		;ACC &= #00
001DD8 | 000EEC: 0FC1      	LD	B[C1], r3		;B[C1] <- AH
001DDA | 000EED: 08E0 7F08 	LD	rE, #7F08		;EXT6 <- #7F08
001DDE | 000EEF: 08E0 0018 	LD	rE, #0018		;EXT6 <- #0018
001DE2 | 000EF1: 000C      	LD	r0, rC		;R0 <- EXT4
001DE4 | 000EF2: 003C      	LD	r3, rC		;AH <- EXT4
001DE6 | 000EF3: 0FC0      	LD	B[C0], r3		;B[C0] <- AH
001DE8 | 000EF4: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
001DEA | 000EF5: 3801      	SUB	r3, #01		;ACC -= #01
001DEC | 000EF6: 0FF0      	LD	B[F0], r3		;B[F0] <- AH
001DEE | 000EF7: 1531      	LD	pB1, r3		;p_B1 <- AH
001DF0 | 000EF8: 0D01 0EFC 	LD	ptrB1, #0EFC	;[p_B1] <- #0EFC		save return address
001DF4 | 000EFA: 4C00 0F84 	BRA	0F84			;PC <- 1F08			call L_0F84 and return
001DF8 | 000EFC: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
001DFA | 000EFD: 3801      	SUB	r3, #01		;ACC -= #01
001DFC | 000EFE: 0FF0      	LD	B[F0], r3		;B[F0] <- AH
001DFE | 000EFF: 1531      	LD	pB1, r3		;p_B1 <- AH
001E00 | 000F00: 0D01 0F04 	LD	ptrB1, #0F04	;[p_B1] <- #0F04		save return address
001E04 | 000F02: 4C00 1265 	BRA	1265			;PC <- 24CA			call L_1265 and return
001E08 | 000F04: 0D03 15B5 	LD	ptrB3, #15B5	;dp_B0 <- #15B5
001E0C | 000F06: 0840 0000 	LD	r4, #0000		;ST <- #0000
001E10 | 000F08: 0880 0000 	LD	r8, #0000		;EXT0 <- #0000
001E14 | 000F0A: 0880 0000 	LD	r8, #0000		;EXT0 <- #0000
001E18 | 000F0C: 0840 0060 	LD	r4, #0060		;ST <- #0060
001E1C | 000F0E: 4800 0481 	CALL	0481			;PC <- 0902			load IRAM from L_15B5
001E20 | 000F10: 0D03 138F 	LD	ptrB3, #138F	;dp_B0 <- #138F
001E24 | 000F12: 0840 0000 	LD	r4, #0000		;ST <- #0000
001E28 | 000F14: 0880 0000 	LD	r8, #0000		;EXT0 <- #0000
001E2C | 000F16: 0880 0000 	LD	r8, #0000		;EXT0 <- #0000
001E30 | 000F18: 0840 0060 	LD	r4, #0060		;ST <- #0060
001E34 | 000F1A: 4800 0481 	CALL	0481			;PC <- 0902			load IRAM from L_138F
001E38 | 000F1C: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
001E3A | 000F1D: 3801      	SUB	r3, #01		;ACC -= #01
001E3C | 000F1E: 0FF0      	LD	B[F0], r3		;B[F0] <- AH
001E3E | 000F1F: 1531      	LD	pB1, r3		;p_B1 <- AH
001E40 | 000F20: 0D01 0F24 	LD	ptrB1, #0F24	;[p_B1] <- #0F24		save return address
001E44 | 000F22: 4C00 0240 	BRA	0240			;PC <- 0480			call L_0240 and return
001E48 | 000F24: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
001E4A | 000F25: 3801      	SUB	r3, #01		;ACC -= #01
001E4C | 000F26: 0FF0      	LD	B[F0], r3		;B[F0] <- AH
001E4E | 000F27: 1531      	LD	pB1, r3		;p_B1 <- AH
001E50 | 000F28: 0D01 0F2C 	LD	ptrB1, #0F2C	;[p_B1] <- #0F2C		save return address
001E54 | 000F2A: 4C00 17F3 	BRA	17F3			;PC <- 2FE6			call L_17F3 and return
001E58 | 000F2C: 0D03 19B5 	LD	ptrB3, #19B5	;dp_B0 <- #19B5
001E5C | 000F2E: 0840 0000 	LD	r4, #0000		;ST <- #0000
001E60 | 000F30: 0880 0000 	LD	r8, #0000		;EXT0 <- #0000
001E64 | 000F32: 0880 0000 	LD	r8, #0000		;EXT0 <- #0000
001E68 | 000F34: 0840 0060 	LD	r4, #0060		;ST <- #0060
001E6C | 000F36: 4800 0481 	CALL	0481			;PC <- 0902			load IRAM from L_19B5
001E70 | 000F38: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
001E72 | 000F39: 3801      	SUB	r3, #01		;ACC -= #01
001E74 | 000F3A: 0FF0      	LD	B[F0], r3		;B[F0] <- AH
001E76 | 000F3B: 1531      	LD	pB1, r3		;p_B1 <- AH
001E78 | 000F3C: 0D01 0F40 	LD	ptrB1, #0F40	;[p_B1] <- #0F40		save return address
001E7C | 000F3E: 4C00 18A3 	BRA	18A3			;PC <- 3146			call L_18A3 and return
001E80 | 000F40: 4800 2784 	CALL	2784			;PC <- 4F08
001E84 | 000F42: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
001E86 | 000F43: 3801      	SUB	r3, #01		;ACC -= #01
001E88 | 000F44: 0FF0      	LD	B[F0], r3		;B[F0] <- AH
001E8A | 000F45: 1531      	LD	pB1, r3		;p_B1 <- AH
001E8C | 000F46: 0D01 0F4A 	LD	ptrB1, #0F4A	;[p_B1] <- #0F4A		save return address
001E90 | 000F48: 4C00 1E09 	BRA	1E09			;PC <- 3C12			call L_1E09 and return
001E94 | 000F4A: 0D03 1EB7 	LD	ptrB3, #1EB7	;dp_B0 <- #1EB7
001E98 | 000F4C: 0840 0000 	LD	r4, #0000		;ST <- #0000
001E9C | 000F4E: 0880 0000 	LD	r8, #0000		;EXT0 <- #0000
001EA0 | 000F50: 0880 0000 	LD	r8, #0000		;EXT0 <- #0000
001EA4 | 000F52: 0840 0060 	LD	r4, #0060		;ST <- #0060
001EA8 | 000F54: 4800 0481 	CALL	0481			;PC <- 0902			load IRAM from L_1EB7
001EAC | 000F56: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
001EAE | 000F57: 3801      	SUB	r3, #01		;ACC -= #01
001EB0 | 000F58: 0FF0      	LD	B[F0], r3		;B[F0] <- AH
001EB2 | 000F59: 1531      	LD	pB1, r3		;p_B1 <- AH
001EB4 | 000F5A: 0D01 0F5E 	LD	ptrB1, #0F5E	;[p_B1] <- #0F5E		save return address
001EB8 | 000F5C: 4C00 1E7D 	BRA	1E7D			;PC <- 3CFA			call L_1E7D and return
001EBC | 000F5E: 4800 2794 	CALL	2794			;PC <- 4F28
001EC0 | 000F60: 4C00 0425 	BRA	0425			;PC <- 084A

001EC4 | 000F62: 07C1      	LD	r3, B[C1]		;AH <- B[C1]
001EC6 | 000F63: 8800 0F66 	ADD	r3, #0F66		;ACC += #0F66
001ECA | 000F65: 4A60      	LD	r6, (r3)		;PC <- (AH)
001ECC | 000F66: 0F68      	LD	B[68], r3		;B[68] <- AH
001ECE | 000F67: 0F7F      	LD	B[7F], r3		;B[7F] <- AH
001ED0 | 000F68: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001ED2 | 000F69: 8800 0020 	ADD	r3, #0020		;ACC += #0020
001ED6 | 000F6B: 6800 1001 	CMP	r3, #1001		;ACC == #1001
001EDA | 000F6D: 4D70 0F79 	BRA	s, 0F79		;PC <- 1EF2
001EDE | 000F6F: 0830 1000 	LD	r3, #1000		;AH <- #1000
001EE2 | 000F71: 07C1      	LD	r3, B[C1]		;AH <- B[C1]
001EE4 | 000F72: 9801      	ADD	r3, #01		;ACC += #01
001EE6 | 000F73: 0FC1      	LD	B[C1], r3		;B[C1] <- AH
001EE8 | 000F74: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
001EEA | 000F75: 1531      	LD	pB1, r3		;p_B1 <- AH
001EEC | 000F76: 9801      	ADD	r3, #01		;ACC += #01
001EEE | 000F77: 0FF0      	LD	B[F0], r3		;B[F0] <- AH
001EF0 | 000F78: 0361      	LD	r6, ptrB1		;PC <- [p_B1]
001EF2 | 000F79: 0FC0      	LD	B[C0], r3		;B[C0] <- AH
001EF4 | 000F7A: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
001EF6 | 000F7B: 1531      	LD	pB1, r3		;p_B1 <- AH
001EF8 | 000F7C: 9801      	ADD	r3, #01		;ACC += #01
001EFA | 000F7D: 0FF0      	LD	B[F0], r3		;B[F0] <- AH
001EFC | 000F7E: 0361      	LD	r6, ptrB1		;PC <- [p_B1]
001EFE | 000F7F: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
001F00 | 000F80: 1531      	LD	pB1, r3		;p_B1 <- AH
001F02 | 000F81: 9801      	ADD	r3, #01		;ACC += #01
001F04 | 000F82: 0FF0      	LD	B[F0], r3		;B[F0] <- AH
001F06 | 000F83: 0361      	LD	r6, ptrB1		;PC <- [p_B1]

L_0F84:
001F08 | 000F84: 0C03 1025 	LD	ptrA3, #1025	;dp_A0 <- #1025
001F0C | 000F86: 1D10      	LD	pB1, #10		;pB1 <- #10
001F0E | 000F87: 0830 000E 	LD	r3, #000E		;AH <- #000E
001F12 | 000F89: 0A13      	LD	r1, *ptrA3		;X <- (dp_A0++)		data array L_1025
001F14 | 000F8A: 0515      	LD	ptrB5, r1		;[p_B1++] <- X
001F16 | 000F8B: 3801      	SUB	r3, #01		;ACC -= #01
001F18 | 000F8C: 4C70 0F89 	BRA	ns, 0F89		;PC <- 1F12
001F1C | 000F8E: 4800 0D69 	CALL	0D69			;PC <- 1AD2			L_0D69
001F20 | 000F90: 08E0 7641 	LD	rE, #7641		;EXT6 <- #7641
001F24 | 000F92: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
001F28 | 000F94: 00C0      	LD	rC, r0		;EXT4 <- R0
001F2A | 000F95: 1814      	LD	pA0, #14		;pA0 <- #14
001F2C | 000F96: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001F2E | 000F97: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001F30 | 000F98: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001F32 | 000F99: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001F34 | 000F9A: 9003      	SHL	ACC			;
001F36 | 000F9B: 9003      	SHL	ACC			;
001F38 | 000F9C: 00C3      	LD	rC, r3		;EXT4 <- AH
001F3A | 000F9D: 08E0 7661 	LD	rE, #7661		;EXT6 <- #7661
001F3E | 000F9F: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
001F42 | 000FA1: 00C0      	LD	rC, r0		;EXT4 <- R0
001F44 | 000FA2: 1814      	LD	pA0, #14		;pA0 <- #14
001F46 | 000FA3: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001F48 | 000FA4: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
001F4A | 000FA5: 9006      	NEG	ACC			;
001F4C | 000FA6: 00C3      	LD	rC, r3		;EXT4 <- AH
001F4E | 000FA7: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001F50 | 000FA8: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001F52 | 000FA9: 9003      	SHL	ACC			;
001F54 | 000FAA: 9003      	SHL	ACC			;
001F56 | 000FAB: 9006      	NEG	ACC			;
001F58 | 000FAC: 00C3      	LD	rC, r3		;EXT4 <- AH
001F5A | 000FAD: 08E0 7681 	LD	rE, #7681		;EXT6 <- #7681
001F5E | 000FAF: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
001F62 | 000FB1: 00C0      	LD	rC, r0		;EXT4 <- R0
001F64 | 000FB2: 1814      	LD	pA0, #14		;pA0 <- #14
001F66 | 000FB3: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
001F68 | 000FB4: 9006      	NEG	ACC			;
001F6A | 000FB5: 00C3      	LD	rC, r3		;EXT4 <- AH
001F6C | 000FB6: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001F6E | 000FB7: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001F70 | 000FB8: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001F72 | 000FB9: 9003      	SHL	ACC			;
001F74 | 000FBA: 9003      	SHL	ACC			;
001F76 | 000FBB: 00C3      	LD	rC, r3		;EXT4 <- AH
001F78 | 000FBC: 08E0 76A1 	LD	rE, #76A1		;EXT6 <- #76A1
001F7C | 000FBE: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
001F80 | 000FC0: 00C0      	LD	rC, r0		;EXT4 <- R0
001F82 | 000FC1: 1814      	LD	pA0, #14		;pA0 <- #14
001F84 | 000FC2: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
001F86 | 000FC3: 9006      	NEG	ACC			;
001F88 | 000FC4: 00C3      	LD	rC, r3		;EXT4 <- AH
001F8A | 000FC5: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
001F8C | 000FC6: 9006      	NEG	ACC			;
001F8E | 000FC7: 00C3      	LD	rC, r3		;EXT4 <- AH
001F90 | 000FC8: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001F92 | 000FC9: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001F94 | 000FCA: 9003      	SHL	ACC			;
001F96 | 000FCB: 9003      	SHL	ACC			;
001F98 | 000FCC: 9006      	NEG	ACC			;
001F9A | 000FCD: 00C3      	LD	rC, r3		;EXT4 <- AH
001F9C | 000FCE: 0C03 1034 	LD	ptrA3, #1034	;dp_A0 <- #1034
001FA0 | 000FD0: 1D10      	LD	pB1, #10		;pB1 <- #10
001FA2 | 000FD1: 0830 000E 	LD	r3, #000E		;AH <- #000E
001FA6 | 000FD3: 0A13      	LD	r1, *ptrA3		;X <- (dp_A0++)
001FA8 | 000FD4: 0515      	LD	ptrB5, r1		;[p_B1++] <- X
001FAA | 000FD5: 3801      	SUB	r3, #01		;ACC -= #01
001FAC | 000FD6: 4C70 0FD3 	BRA	ns, 0FD3		;PC <- 1FA6
001FB0 | 000FD8: 4800 0D69 	CALL	0D69			;PC <- 1AD2			L_0D69
001FB4 | 000FDA: 08E0 7601 	LD	rE, #7601		;EXT6 <- #7601
001FB8 | 000FDC: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
001FBC | 000FDE: 00C0      	LD	rC, r0		;EXT4 <- R0
001FBE | 000FDF: 1814      	LD	pA0, #14		;pA0 <- #14
001FC0 | 000FE0: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001FC2 | 000FE1: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001FC4 | 000FE2: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001FC6 | 000FE3: 08C0 0000 	LD	rC, #0000		;EXT4 <- #0000
001FCA | 000FE5: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001FCC | 000FE6: 9003      	SHL	ACC			;
001FCE | 000FE7: 9003      	SHL	ACC			;
001FD0 | 000FE8: 00C3      	LD	rC, r3		;EXT4 <- AH
001FD2 | 000FE9: 08E0 7621 	LD	rE, #7621		;EXT6 <- #7621
001FD6 | 000FEB: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
001FDA | 000FED: 00C0      	LD	rC, r0		;EXT4 <- R0
001FDC | 000FEE: 1814      	LD	pA0, #14		;pA0 <- #14
001FDE | 000FEF: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001FE0 | 000FF0: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
001FE2 | 000FF1: 9006      	NEG	ACC			;
001FE4 | 000FF2: 00C3      	LD	rC, r3		;EXT4 <- AH
001FE6 | 000FF3: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
001FE8 | 000FF4: 08C0 0000 	LD	rC, #0000		;EXT4 <- #0000
001FEC | 000FF6: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
001FEE | 000FF7: 9003      	SHL	ACC			;
001FF0 | 000FF8: 9003      	SHL	ACC			;
001FF2 | 000FF9: 9006      	NEG	ACC			;
001FF4 | 000FFA: 00C3      	LD	rC, r3		;EXT4 <- AH
001FF6 | 000FFB: 08E0 76C1 	LD	rE, #76C1		;EXT6 <- #76C1
001FFA | 000FFD: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
001FFE | 000FFF: 00C0      	LD	rC, r0		;EXT4 <- R0
002000 | 001000: 1814      	LD	pA0, #14		;pA0 <- #14
002002 | 001001: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002004 | 001002: 9006      	NEG	ACC			;
002006 | 001003: 00C3      	LD	rC, r3		;EXT4 <- AH
002008 | 001004: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
00200A | 001005: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
00200C | 001006: 08C0 0000 	LD	rC, #0000		;EXT4 <- #0000
002010 | 001008: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
002012 | 001009: 9003      	SHL	ACC			;
002014 | 00100A: 9003      	SHL	ACC			;
002016 | 00100B: 00C3      	LD	rC, r3		;EXT4 <- AH
002018 | 00100C: 08E0 76E1 	LD	rE, #76E1		;EXT6 <- #76E1
00201C | 00100E: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
002020 | 001010: 00C0      	LD	rC, r0		;EXT4 <- R0
002022 | 001011: 1814      	LD	pA0, #14		;pA0 <- #14
002024 | 001012: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002026 | 001013: 9006      	NEG	ACC			;
002028 | 001014: 00C3      	LD	rC, r3		;EXT4 <- AH
00202A | 001015: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
00202C | 001016: 9006      	NEG	ACC			;
00202E | 001017: 00C3      	LD	rC, r3		;EXT4 <- AH
002030 | 001018: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
002032 | 001019: 08C0 0000 	LD	rC, #0000		;EXT4 <- #0000
002036 | 00101B: 07C0      	LD	r3, B[C0]		;AH <- B[C0]
002038 | 00101C: 9003      	SHL	ACC			;
00203A | 00101D: 9003      	SHL	ACC			;
00203C | 00101E: 9006      	NEG	ACC			;
00203E | 00101F: 00C3      	LD	rC, r3		;EXT4 <- AH
002040 | 001020: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
002042 | 001021: 1531      	LD	pB1, r3		;p_B1 <- AH
002044 | 001022: 9801      	ADD	r3, #01		;ACC += #01
002046 | 001023: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
002048 | 001024: 0361      	LD	r6, ptrB1		;PC <- [p_B1]

L_1025:
00204A | 001025: 0EC0
00204C | 001026: F806
00204E | 001027: 379A
002050 | 001028: 0000
002052 | 001029: 0000
002054 | 00102A: 1CE0
002056 | 00102B: F140
002058 | 00102C: 07FA
00205A | 00102D: 0225
00205C | 00102E: FF35
00205E | 00102F: 0000
002060 | 001030: 02C0
002062 | 001031: 148A
002064 | 001032: F806
002066 | 001033: FD7B
002068 | 001034: BE66
00206A | 001035: F355
00206C | 001036: 37BF
00206E | 001037: DDBC
002070 | 001038: 0000
002072 | 001039: 1CE0
002074 | 00103A: FD12
002076 | 00103B: 0CAB
002078 | 00103C: 0200
00207A | 00103D: FDA8
00207C | 00103E: 0000
00207E | 00103F: 02C0
002080 | 001040: FFB6
002082 | 001041: EF1A
002084 | 001042: FDA0

L_1265:
0024CA | 001265: 1C20      	LD	pB0, #20		;pB0 <- #20
0024CC | 001266: 0D04 0FFF 	LD	ptrB4, #0FFF	;[p_B0++] <- #0FFF
0024D0 | 001268: 0D04 0400 	LD	ptrB4, #0400	;[p_B0++] <- #0400
0024D4 | 00126A: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
0024D6 | 00126B: 1531      	LD	pB1, r3		;p_B1 <- AH
0024D8 | 00126C: 9801      	ADD	r3, #01		;ACC += #01
0024DA | 00126D: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
0024DC | 00126E: 0361      	LD	r6, ptrB1		;PC <- [p_B1]		ret



;area copy to IRAM

00271E | 00138F: 8240      					;start addr IRAM
002720 | 001390: 0037      					;size
L_I0240:
002722 | 001391: 1804      	LD	pA0, #04		;pA0 <- #04
002724 | 001392: 0C04 7600 	LD	ptrA4, #7600	;[p_A0++] <- #7600
002728 | 001394: 0C04 0007 	LD	ptrA4, #0007	;[p_A0++] <- #0007
00272C | 001396: 0604      	LD	r3, A[04]		;AH <- A[04]
00272E | 001397: 1C10      	LD	pB0, #10		;pB0 <- #10
002730 | 001398: 4800 00CF 	CALL	00CF			;PC <- 019E
002734 | 00139A: 0710      	LD	r3, B[10]		;AH <- B[10]
002736 | 00139B: A000      	AND	r3, r0		;ACC &= R0
002738 | 00139C: 4D50 0251 	BRA	z, 0251		;PC <- 04A2
00273C | 00139E: 4800 025E 	CALL	025E			;PC <- 04BC
002740 | 0013A0: 4800 00DB 	CALL	00DB			;PC <- 01B6
002744 | 0013A2: 0604      	LD	r3, A[04]		;AH <- A[04]
002746 | 0013A3: 9820      	ADD	r3, #20		;ACC += #20
002748 | 0013A4: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
00274A | 0013A5: 0605      	LD	r3, A[05]		;AH <- A[05]
00274C | 0013A6: 3801      	SUB	r3, #01		;ACC -= #01
00274E | 0013A7: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
002750 | 0013A8: 4C70 0245 	BRA	ns, 0245		;PC <- 048A
002754 | 0013AA: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
002756 | 0013AB: 1531      	LD	pB1, r3		;p_B1 <- AH
002758 | 0013AC: 9801      	ADD	r3, #01		;ACC += #01
00275A | 0013AD: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
00275C | 0013AE: 0361      	LD	r6, ptrB1		;PC <- [p_B1]		ret

L_I025E:
00275E | 0013AF: 1910      	LD	pA1, #10		;pA1 <- #10
002760 | 0013B0: 0810 0400 	LD	r1, #0400		;X <- #0400
002764 | 0013B2: 4800 00C1 	CALL	00C1			;PC <- 0182
002768 | 0013B4: 1810      	LD	pA0, #10		;pA0 <- #10
00276A | 0013B5: 0715      	LD	r3, B[15]		;AH <- B[15]
00276C | 0013B6: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
00276E | 0013B7: 4800 007C 	CALL	007C			;PC <- 00F8
002772 | 0013B9: 0714      	LD	r3, B[14]		;AH <- B[14]
002774 | 0013BA: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002776 | 0013BB: 4800 0067 	CALL	0067			;PC <- 00CE
00277A | 0013BD: 0716      	LD	r3, B[16]		;AH <- B[16]
00277C | 0013BE: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
00277E | 0013BF: 4800 0093 	CALL	0093			;PC <- 0126
002782 | 0013C1: 0711      	LD	r3, B[11]		;AH <- B[11]
002784 | 0013C2: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002786 | 0013C3: 0712      	LD	r3, B[12]		;AH <- B[12]
002788 | 0013C4: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
00278A | 0013C5: 0713      	LD	r3, B[13]		;AH <- B[13]
00278C | 0013C6: 043B      	LD	ptrAB, r3		;dp_A2 <- AH
00278E | 0013C7: 4C00 0000 	BRA	0000			;PC <- 0000


002792 | 0013C9: 8240      	ADD	r3, ptrA0		;ACC += [p_A0]
002794 | 0013CA: 009E      	LD	r9, rE		;EXT1 <- EXT6
002796 | 0013CB: 0830 7880 	LD	r3, #7880		;AH <- #7880
00279A | 0013CD: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
00279C | 0013CE: 4C00 0248 	BRA	0248			;PC <- 0490
0027A0 | 0013D0: 0830 7600 	LD	r3, #7600		;AH <- #7600
0027A4 | 0013D2: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
0027A6 | 0013D3: 0604      	LD	r3, A[04]		;AH <- A[04]
0027A8 | 0013D4: 1C18      	LD	pB0, #18		;pB0 <- #18
0027AA | 0013D5: 4800 00CF 	CALL	00CF			;PC <- 019E
0027AE | 0013D7: 0604      	LD	r3, A[04]		;AH <- A[04]
0027B0 | 0013D8: 9820      	ADD	r3, #20		;ACC += #20
0027B2 | 0013D9: 1C10      	LD	pB0, #10		;pB0 <- #10
0027B4 | 0013DA: 4800 00CF 	CALL	00CF			;PC <- 019E
0027B8 | 0013DC: 4800 010C 	CALL	010C			;PC <- 0218
0027BC | 0013DE: 4800 014A 	CALL	014A			;PC <- 0294
0027C0 | 0013E0: 4800 00DB 	CALL	00DB			;PC <- 01B6
0027C4 | 0013E2: 0604      	LD	r3, A[04]		;AH <- A[04]
0027C6 | 0013E3: 9820      	ADD	r3, #20		;ACC += #20
0027C8 | 0013E4: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
0027CA | 0013E5: 1C10      	LD	pB0, #10		;pB0 <- #10
0027CC | 0013E6: 4800 00CF 	CALL	00CF			;PC <- 019E
0027D0 | 0013E8: 0710      	LD	r3, B[10]		;AH <- B[10]
0027D2 | 0013E9: A000      	AND	r3, r0		;ACC &= R0
0027D4 | 0013EA: 7801      	CMP	r3, #01		;ACC == #01
0027D6 | 0013EB: 4950 015A 	CALL	z, 015A		;PC <- 02B4
0027DA | 0013ED: 7802      	CMP	r3, #02		;ACC == #02
0027DC | 0013EE: 4950 01E4 	CALL	z, 01E4		;PC <- 03C8
0027E0 | 0013F0: 4800 00DB 	CALL	00DB			;PC <- 01B6
0027E4 | 0013F2: 0604      	LD	r3, A[04]		;AH <- A[04]
0027E6 | 0013F3: 9820      	ADD	r3, #20		;ACC += #20
0027E8 | 0013F4: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
0027EA | 0013F5: 0830 0002 	LD	r3, #0002		;AH <- #0002
0027EE | 0013F7: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
0027F0 | 0013F8: 0604      	LD	r3, A[04]		;AH <- A[04]
0027F2 | 0013F9: 1C18      	LD	pB0, #18		;pB0 <- #18
0027F4 | 0013FA: 4800 00CF 	CALL	00CF			;PC <- 019E
0027F8 | 0013FC: 0718      	LD	r3, B[18]		;AH <- B[18]
0027FA | 0013FD: A000      	AND	r3, r0		;ACC &= R0
0027FC | 0013FE: 7801      	CMP	r3, #01		;ACC == #01
0027FE | 0013FF: 4950 017A 	CALL	z, 017A		;PC <- 02F4
002802 | 001401: 7802      	CMP	r3, #02		;ACC == #02
002804 | 001402: 4950 020B 	CALL	z, 020B		;PC <- 0416
002808 | 001404: 4800 00DB 	CALL	00DB			;PC <- 01B6
00280C | 001406: 0604      	LD	r3, A[04]		;AH <- A[04]
00280E | 001407: 9820      	ADD	r3, #20		;ACC += #20
002810 | 001408: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
002812 | 001409: 0605      	LD	r3, A[05]		;AH <- A[05]
002814 | 00140A: 3801      	SUB	r3, #01		;ACC -= #01
002816 | 00140B: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
002818 | 00140C: 4C70 026D 	BRA	ns, 026D		;PC <- 04DA
00281C | 00140E: 0604      	LD	r3, A[04]		;AH <- A[04]
00281E | 00140F: 9820      	ADD	r3, #20		;ACC += #20
002820 | 001410: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
002822 | 001411: 0830 0004 	LD	r3, #0004		;AH <- #0004
002826 | 001413: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
002828 | 001414: 0604      	LD	r3, A[04]		;AH <- A[04]
00282A | 001415: 1C18      	LD	pB0, #18		;pB0 <- #18
00282C | 001416: 4800 00CF 	CALL	00CF			;PC <- 019E
002830 | 001418: 0718      	LD	r3, B[18]		;AH <- B[18]
002832 | 001419: A000      	AND	r3, r0		;ACC &= R0
002834 | 00141A: 4D50 0299 	BRA	z, 0299		;PC <- 0532
002838 | 00141C: 7801      	CMP	r3, #01		;ACC == #01
00283A | 00141D: 4950 015A 	CALL	z, 015A		;PC <- 02B4
00283E | 00141F: 7802      	CMP	r3, #02		;ACC == #02
002840 | 001420: 4950 01E4 	CALL	z, 01E4		;PC <- 03C8
002844 | 001422: 4800 00DB 	CALL	00DB			;PC <- 01B6
002848 | 001424: 0604      	LD	r3, A[04]		;AH <- A[04]
00284A | 001425: 9820      	ADD	r3, #20		;ACC += #20
00284C | 001426: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
00284E | 001427: 0605      	LD	r3, A[05]		;AH <- A[05]
002850 | 001428: 3801      	SUB	r3, #01		;ACC -= #01
002852 | 001429: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
002854 | 00142A: 4C70 0289 	BRA	ns, 0289		;PC <- 0512
002858 | 00142C: 0604      	LD	r3, A[04]		;AH <- A[04]
00285A | 00142D: 1C10      	LD	pB0, #10		;pB0 <- #10
00285C | 00142E: 4800 00CF 	CALL	00CF			;PC <- 019E
002860 | 001430: 0710      	LD	r3, B[10]		;AH <- B[10]
002862 | 001431: A000      	AND	r3, r0		;ACC &= R0
002864 | 001432: 4D50 02DA 	BRA	z, 02DA		;PC <- 05B4
002868 | 001434: 4800 01E4 	CALL	01E4			;PC <- 03C8
00286C | 001436: 4800 00DB 	CALL	00DB			;PC <- 01B6
002870 | 001438: 0604      	LD	r3, A[04]		;AH <- A[04]
002872 | 001439: 9820      	ADD	r3, #20		;ACC += #20
002874 | 00143A: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
002876 | 00143B: 0830 0002 	LD	r3, #0002		;AH <- #0002
00287A | 00143D: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
00287C | 00143E: 0604      	LD	r3, A[04]		;AH <- A[04]
00287E | 00143F: 1C18      	LD	pB0, #18		;pB0 <- #18
002880 | 001440: 4800 00CF 	CALL	00CF			;PC <- 019E
002884 | 001442: 4800 020B 	CALL	020B			;PC <- 0416
002888 | 001444: 4800 00DB 	CALL	00DB			;PC <- 01B6
00288C | 001446: 0604      	LD	r3, A[04]		;AH <- A[04]
00288E | 001447: 9820      	ADD	r3, #20		;ACC += #20
002890 | 001448: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
002892 | 001449: 0605      	LD	r3, A[05]		;AH <- A[05]
002894 | 00144A: 3801      	SUB	r3, #01		;ACC -= #01
002896 | 00144B: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
002898 | 00144C: 4C70 02B3 	BRA	ns, 02B3		;PC <- 0566
00289C | 00144E: 0830 0004 	LD	r3, #0004		;AH <- #0004
0028A0 | 001450: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
0028A2 | 001451: 0604      	LD	r3, A[04]		;AH <- A[04]
0028A4 | 001452: 1C18      	LD	pB0, #18		;pB0 <- #18
0028A6 | 001453: 4800 00CF 	CALL	00CF			;PC <- 019E
0028AA | 001455: 0718      	LD	r3, B[18]		;AH <- B[18]
0028AC | 001456: A000      	AND	r3, r0		;ACC &= R0
0028AE | 001457: 4D50 02D2 	BRA	z, 02D2		;PC <- 05A4
0028B2 | 001459: 4800 01E4 	CALL	01E4			;PC <- 03C8
0028B6 | 00145B: 4800 00DB 	CALL	00DB			;PC <- 01B6
0028BA | 00145D: 0604      	LD	r3, A[04]		;AH <- A[04]
0028BC | 00145E: 9820      	ADD	r3, #20		;ACC += #20
0028BE | 00145F: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
0028C0 | 001460: 0605      	LD	r3, A[05]		;AH <- A[05]
0028C2 | 001461: 3801      	SUB	r3, #01		;ACC -= #01
0028C4 | 001462: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
0028C6 | 001463: 4C70 02C6 	BRA	ns, 02C6		;PC <- 058C
0028CA | 001465: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
0028CC | 001466: 1531      	LD	pB1, r3		;p_B1 <- AH
0028CE | 001467: 9801      	ADD	r3, #01		;ACC += #01
0028D0 | 001468: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
0028D2 | 001469: 0361      	LD	r6, ptrB1		;PC <- [p_B1]
0028D4 | 00146A: 8240      	ADD	r3, ptrA0		;ACC += [p_A0]
0028D6 | 00146B: 0020      	LD	r2, r0		;Y <- R0
0028D8 | 00146C: 0830 7D20 	LD	r3, #7D20		;AH <- #7D20
0028DC | 00146E: 1C10      	LD	pB0, #10		;pB0 <- #10
0028DE | 00146F: 4800 00CF 	CALL	00CF			;PC <- 019E
0028E2 | 001471: 1910      	LD	pA1, #10		;pA1 <- #10
0028E4 | 001472: 4800 00BB 	CALL	00BB			;PC <- 0176
0028E8 | 001474: 1810      	LD	pA0, #10		;pA0 <- #10
0028EA | 001475: 0714      	LD	r3, B[14]		;AH <- B[14]
0028EC | 001476: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
0028EE | 001477: 4800 0067 	CALL	0067			;PC <- 00CE
0028F2 | 001479: B800      	AND	r3, #00		;ACC &= #00
0028F4 | 00147A: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
0028F6 | 00147B: 0712      	LD	r3, B[12]		;AH <- B[12]
0028F8 | 00147C: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
0028FA | 00147D: 0713      	LD	r3, B[13]		;AH <- B[13]
0028FC | 00147E: 043B      	LD	ptrAB, r3		;dp_A2 <- AH
0028FE | 00147F: 4800 0000 	CALL	0000			;PC <- 0000
002902 | 001481: 08E0 7D27 	LD	rE, #7D27		;EXT6 <- #7D27
002906 | 001483: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
00290A | 001485: 00C0      	LD	rC, r0		;EXT4 <- R0
00290C | 001486: 4800 00E0 	CALL	00E0			;PC <- 01C0
002910 | 001488: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
002912 | 001489: 1531      	LD	pB1, r3		;p_B1 <- AH
002914 | 00148A: 9801      	ADD	r3, #01		;ACC += #01
002916 | 00148B: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
002918 | 00148C: 0361      	LD	r6, ptrB1		;PC <- [p_B1]
00291A | 00148D: 8240      	ADD	r3, ptrA0		;ACC += [p_A0]
00291C | 00148E: 00A2      	LD	rA, r2		;EXT2 <- Y
00291E | 00148F: 0830 7600 	LD	r3, #7600		;AH <- #7600
002922 | 001491: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
002924 | 001492: 0830 0005 	LD	r3, #0005		;AH <- #0005
002928 | 001494: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
00292A | 001495: 0604      	LD	r3, A[04]		;AH <- A[04]
00292C | 001496: 1C10      	LD	pB0, #10		;pB0 <- #10
00292E | 001497: 4800 00CF 	CALL	00CF			;PC <- 019E
002932 | 001499: 0710      	LD	r3, B[10]		;AH <- B[10]
002934 | 00149A: A000      	AND	r3, r0		;ACC &= R0
002936 | 00149B: 4D50 0252 	BRA	z, 0252		;PC <- 04A4
00293A | 00149D: 4800 026D 	CALL	026D			;PC <- 04DA
00293E | 00149F: 4800 00DB 	CALL	00DB			;PC <- 01B6
002942 | 0014A1: 0604      	LD	r3, A[04]		;AH <- A[04]
002944 | 0014A2: 9840      	ADD	r3, #40		;ACC += #40
002946 | 0014A3: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
002948 | 0014A4: 0605      	LD	r3, A[05]		;AH <- A[05]
00294A | 0014A5: 3801      	SUB	r3, #01		;ACC -= #01
00294C | 0014A6: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
00294E | 0014A7: 4C70 0246 	BRA	ns, 0246		;PC <- 048C
002952 | 0014A9: 4800 0286 	CALL	0286			;PC <- 050C
002956 | 0014AB: 08E0 7F50 	LD	rE, #7F50		;EXT6 <- #7F50
00295A | 0014AD: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
00295E | 0014AF: 00C0      	LD	rC, r0		;EXT4 <- R0
002960 | 0014B0: 1DC8      	LD	pB1, #C8		;pB1 <- #C8
002962 | 0014B1: 0830 0005 	LD	r3, #0005		;AH <- #0005
002966 | 0014B3: 03C5      	LD	rC, ptrB5		;EXT4 <- [p_B1++]
002968 | 0014B4: 3801      	SUB	r3, #01		;ACC -= #01
00296A | 0014B5: 4C70 0264 	BRA	ns, 0264		;PC <- 04C8
00296E | 0014B7: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
002970 | 0014B8: 1531      	LD	pB1, r3		;p_B1 <- AH
002972 | 0014B9: 9801      	ADD	r3, #01		;ACC += #01
002974 | 0014BA: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
002976 | 0014BB: 0361      	LD	r6, ptrB1		;PC <- [p_B1]
002978 | 0014BC: 1910      	LD	pA1, #10		;pA1 <- #10
00297A | 0014BD: 4800 00BB 	CALL	00BB			;PC <- 0176
00297E | 0014BF: 1810      	LD	pA0, #10		;pA0 <- #10
002980 | 0014C0: 0715      	LD	r3, B[15]		;AH <- B[15]
002982 | 0014C1: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002984 | 0014C2: 4800 007C 	CALL	007C			;PC <- 00F8
002988 | 0014C4: 0714      	LD	r3, B[14]		;AH <- B[14]
00298A | 0014C5: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
00298C | 0014C6: 4800 0067 	CALL	0067			;PC <- 00CE
002990 | 0014C8: 0716      	LD	r3, B[16]		;AH <- B[16]
002992 | 0014C9: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002994 | 0014CA: 4800 0093 	CALL	0093			;PC <- 0126
002998 | 0014CC: 0711      	LD	r3, B[11]		;AH <- B[11]
00299A | 0014CD: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
00299C | 0014CE: 0712      	LD	r3, B[12]		;AH <- B[12]
00299E | 0014CF: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
0029A0 | 0014D0: 0713      	LD	r3, B[13]		;AH <- B[13]
0029A2 | 0014D1: 043B      	LD	ptrAB, r3		;dp_A2 <- AH
0029A4 | 0014D2: 4C00 0000 	BRA	0000			;PC <- 0000
0029A8 | 0014D4: 0065      	LD	r6, r5		;PC <- STACK
0029AA | 0014D5: 1CC0      	LD	pB0, #C0		;pB0 <- #C0
0029AC | 0014D6: 1DC8      	LD	pB1, #C8		;pB1 <- #C8
0029AE | 0014D7: 0830 7600 	LD	r3, #7600		;AH <- #7600
0029B2 | 0014D9: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
0029B4 | 0014DA: 0830 0005 	LD	r3, #0005		;AH <- #0005
0029B8 | 0014DC: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
0029BA | 0014DD: 0604      	LD	r3, A[04]		;AH <- A[04]
0029BC | 0014DE: 00E3      	LD	rE, r3		;EXT6 <- AH
0029BE | 0014DF: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
0029C2 | 0014E1: 000C      	LD	r0, rC		;R0 <- EXT4
0029C4 | 0014E2: 003C      	LD	r3, rC		;AH <- EXT4
0029C6 | 0014E3: A000      	AND	r3, r0		;ACC &= R0
0029C8 | 0014E4: 0604      	LD	r3, A[04]		;AH <- A[04]
0029CA | 0014E5: 4C50 0299 	BRA	nz, 0299		;PC <- 0532
0029CE | 0014E7: B800      	AND	r3, #00		;ACC &= #00
0029D0 | 0014E8: 0535      	LD	ptrB5, r3		;[p_B1++] <- AH
0029D2 | 0014E9: 0604      	LD	r3, A[04]		;AH <- A[04]
0029D4 | 0014EA: 9803      	ADD	r3, #03		;ACC += #03
0029D6 | 0014EB: 00E3      	LD	rE, r3		;EXT6 <- AH
0029D8 | 0014EC: 000E      	LD	r0, rE		;R0 <- EXT6
0029DA | 0014ED: 000C      	LD	r0, rC		;R0 <- EXT4
0029DC | 0014EE: 05C4      	LD	ptrB4, rC		;[p_B0++] <- EXT4
0029DE | 0014EF: 0604      	LD	r3, A[04]		;AH <- A[04]
0029E0 | 0014F0: 9840      	ADD	r3, #40		;ACC += #40
0029E2 | 0014F1: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
0029E4 | 0014F2: 0605      	LD	r3, A[05]		;AH <- A[05]
0029E6 | 0014F3: 3801      	SUB	r3, #01		;ACC -= #01
0029E8 | 0014F4: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
0029EA | 0014F5: 4C70 028E 	BRA	ns, 028E		;PC <- 051C
0029EE | 0014F7: 08E0 7FD0 	LD	rE, #7FD0		;EXT6 <- #7FD0
0029F2 | 0014F9: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
0029F6 | 0014FB: 00C0      	LD	rC, r0		;EXT4 <- R0
0029F8 | 0014FC: 1CC0      	LD	pB0, #C0		;pB0 <- #C0
0029FA | 0014FD: 0830 000F 	LD	r3, #000F		;AH <- #000F
0029FE | 0014FF: 03C4      	LD	rC, ptrB4		;EXT4 <- [p_B0++]
002A00 | 001500: 3801      	SUB	r3, #01		;ACC -= #01
002A02 | 001501: 4C70 02B0 	BRA	ns, 02B0		;PC <- 0560
002A06 | 001503: 0D03 0004 	LD	ptrB3, #0004	;dp_B0 <- #0004
002A0A | 001505: 0D07 0004 	LD	ptrB7, #0004	;dp_B1 <- #0004
002A0E | 001507: 0337      	LD	r3, ptrB7		;AH <- dp_B1
002A10 | 001508: 053B      	LD	ptrBB, r3		;dp_B2 <- AH
002A12 | 001509: 1CC0      	LD	pB0, #C0		;pB0 <- #C0
002A14 | 00150A: 1DC8      	LD	pB1, #C8		;pB1 <- #C8
002A16 | 00150B: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
002A18 | 00150C: 0334      	LD	r3, ptrB4		;AH <- [p_B0++]
002A1A | 00150D: 6300      	CMP	r3, ptrB0		;ACC == [p_B0]
002A1C | 00150E: 4C70 02C9 	BRA	ns, 02C9		;PC <- 0592
002A20 | 001510: 0318      	LD	r1, ptrB8		;X <- [p_B0--!]
002A22 | 001511: 0320      	LD	r2, ptrB0		;Y <- [p_B0]
002A24 | 001512: 0514      	LD	ptrB4, r1		;[p_B0++] <- X
002A26 | 001513: 0520      	LD	ptrB0, r2		;[p_B0] <- Y
002A28 | 001514: 0319      	LD	r1, ptrB9		;X <- [p_B1--!]
002A2A | 001515: 0321      	LD	r2, ptrB1		;Y <- [p_B1]
002A2C | 001516: 0515      	LD	ptrB5, r1		;[p_B1++] <- X
002A2E | 001517: 0521      	LD	ptrB1, r2		;[p_B1] <- Y
002A30 | 001518: 033B      	LD	r3, ptrBB		;AH <- dp_B2
002A32 | 001519: 3801      	SUB	r3, #01		;ACC -= #01
002A34 | 00151A: 053B      	LD	ptrBB, r3		;dp_B2 <- AH
002A36 | 00151B: 4C70 02BC 	BRA	ns, 02BC		;PC <- 0578
002A3A | 00151D: 0337      	LD	r3, ptrB7		;AH <- dp_B1
002A3C | 00151E: 3801      	SUB	r3, #01		;ACC -= #01
002A3E | 00151F: 0537      	LD	ptrB7, r3		;dp_B1 <- AH
002A40 | 001520: 0333      	LD	r3, ptrB3		;AH <- dp_B0
002A42 | 001521: 3801      	SUB	r3, #01		;ACC -= #01
002A44 | 001522: 0533      	LD	ptrB3, r3		;dp_B0 <- AH
002A46 | 001523: 4C70 02B8 	BRA	ns, 02B8		;PC <- 0570
002A4A | 001525: 08E0 7FE0 	LD	rE, #7FE0		;EXT6 <- #7FE0
002A4E | 001527: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
002A52 | 001529: 00C0      	LD	rC, r0		;EXT4 <- R0
002A54 | 00152A: 1CC0      	LD	pB0, #C0		;pB0 <- #C0
002A56 | 00152B: 0830 000F 	LD	r3, #000F		;AH <- #000F
002A5A | 00152D: 03C4      	LD	rC, ptrB4		;EXT4 <- [p_B0++]
002A5C | 00152E: 3801      	SUB	r3, #01		;ACC -= #01
002A5E | 00152F: 4C70 02DE 	BRA	ns, 02DE		;PC <- 05BC
002A62 | 001531: 0065      	LD	r6, r5		;PC <- STACK
002A64 | 001532: 8240      	ADD	r3, ptrA0		;ACC += [p_A0]
002A66 | 001533: 0080      	LD	r8, r0		;EXT0 <- R0
002A68 | 001534: 0830 7600 	LD	r3, #7600		;AH <- #7600
002A6C | 001536: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
002A6E | 001537: 0604      	LD	r3, A[04]		;AH <- A[04]
002A70 | 001538: 1C10      	LD	pB0, #10		;pB0 <- #10
002A72 | 001539: 4800 00CF 	CALL	00CF			;PC <- 019E
002A76 | 00153B: 0710      	LD	r3, B[10]		;AH <- B[10]
002A78 | 00153C: A000      	AND	r3, r0		;ACC &= R0
002A7A | 00153D: 4D50 0269 	BRA	z, 0269		;PC <- 04D2
002A7E | 00153F: 4800 0293 	CALL	0293			;PC <- 0526
002A82 | 001541: 4800 00DB 	CALL	00DB			;PC <- 01B6
002A86 | 001543: 0604      	LD	r3, A[04]		;AH <- A[04]
002A88 | 001544: 9820      	ADD	r3, #20		;ACC += #20
002A8A | 001545: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
002A8C | 001546: 0830 0002 	LD	r3, #0002		;AH <- #0002
002A90 | 001548: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
002A92 | 001549: 0604      	LD	r3, A[04]		;AH <- A[04]
002A94 | 00154A: 1C18      	LD	pB0, #18		;pB0 <- #18
002A96 | 00154B: 4800 00CF 	CALL	00CF			;PC <- 019E
002A9A | 00154D: 0718      	LD	r3, B[18]		;AH <- B[18]
002A9C | 00154E: A000      	AND	r3, r0		;ACC &= R0
002A9E | 00154F: 4D50 0261 	BRA	z, 0261		;PC <- 04C2
002AA2 | 001551: 4800 02AB 	CALL	02AB			;PC <- 0556
002AA6 | 001553: 4800 00DB 	CALL	00DB			;PC <- 01B6
002AAA | 001555: 0604      	LD	r3, A[04]		;AH <- A[04]
002AAC | 001556: 9820      	ADD	r3, #20		;ACC += #20
002AAE | 001557: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
002AB0 | 001558: 0605      	LD	r3, A[05]		;AH <- A[05]
002AB2 | 001559: 3801      	SUB	r3, #01		;ACC -= #01
002AB4 | 00155A: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
002AB6 | 00155B: 4C70 0255 	BRA	ns, 0255		;PC <- 04AA
002ABA | 00155D: 0830 0001 	LD	r3, #0001		;AH <- #0001
002ABE | 00155F: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
002AC0 | 001560: 0604      	LD	r3, A[04]		;AH <- A[04]
002AC2 | 001561: 1C18      	LD	pB0, #18		;pB0 <- #18
002AC4 | 001562: 4800 00CF 	CALL	00CF			;PC <- 019E
002AC8 | 001564: 0718      	LD	r3, B[18]		;AH <- B[18]
002ACA | 001565: A000      	AND	r3, r0		;ACC &= R0
002ACC | 001566: 4D50 0278 	BRA	z, 0278		;PC <- 04F0
002AD0 | 001568: 4800 0293 	CALL	0293			;PC <- 0526
002AD4 | 00156A: 4800 00DB 	CALL	00DB			;PC <- 01B6
002AD8 | 00156C: 0604      	LD	r3, A[04]		;AH <- A[04]
002ADA | 00156D: 9820      	ADD	r3, #20		;ACC += #20
002ADC | 00156E: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
002ADE | 00156F: 0605      	LD	r3, A[05]		;AH <- A[05]
002AE0 | 001570: 3801      	SUB	r3, #01		;ACC -= #01
002AE2 | 001571: 0E05      	LD	RAMA[05], r3	;RAMA[05] <- AH
002AE4 | 001572: 4C70 026C 	BRA	ns, 026C		;PC <- 04D8
002AE8 | 001574: 0830 7D20 	LD	r3, #7D20		;AH <- #7D20
002AEC | 001576: 0E04      	LD	RAMA[04], r3	;RAMA[04] <- AH
002AEE | 001577: 1C10      	LD	pB0, #10		;pB0 <- #10
002AF0 | 001578: 4800 00CF 	CALL	00CF			;PC <- 019E
002AF4 | 00157A: 0710      	LD	r3, B[10]		;AH <- B[10]
002AF6 | 00157B: A000      	AND	r3, r0		;ACC &= R0
002AF8 | 00157C: 4D50 028E 	BRA	z, 028E		;PC <- 051C
002AFC | 00157E: 4800 0293 	CALL	0293			;PC <- 0526
002B00 | 001580: 4800 00DB 	CALL	00DB			;PC <- 01B6
002B04 | 001582: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
002B06 | 001583: 1531      	LD	pB1, r3		;p_B1 <- AH
002B08 | 001584: 9801      	ADD	r3, #01		;ACC += #01
002B0A | 001585: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
002B0C | 001586: 0361      	LD	r6, ptrB1		;PC <- [p_B1]
002B0E | 001587: 1910      	LD	pA1, #10		;pA1 <- #10
002B10 | 001588: 4800 00BB 	CALL	00BB			;PC <- 0176
002B14 | 00158A: 1810      	LD	pA0, #10		;pA0 <- #10
002B16 | 00158B: 0715      	LD	r3, B[15]		;AH <- B[15]
002B18 | 00158C: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002B1A | 00158D: 4800 007C 	CALL	007C			;PC <- 00F8
002B1E | 00158F: 0714      	LD	r3, B[14]		;AH <- B[14]
002B20 | 001590: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002B22 | 001591: 4800 0067 	CALL	0067			;PC <- 00CE
002B26 | 001593: 0716      	LD	r3, B[16]		;AH <- B[16]
002B28 | 001594: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002B2A | 001595: 4800 0093 	CALL	0093			;PC <- 0126
002B2E | 001597: 0711      	LD	r3, B[11]		;AH <- B[11]
002B30 | 001598: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002B32 | 001599: 0712      	LD	r3, B[12]		;AH <- B[12]
002B34 | 00159A: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
002B36 | 00159B: 0713      	LD	r3, B[13]		;AH <- B[13]
002B38 | 00159C: 043B      	LD	ptrAB, r3		;dp_A2 <- AH
002B3A | 00159D: 4C00 0000 	BRA	0000			;PC <- 0000
002B3E | 00159F: 1910      	LD	pA1, #10		;pA1 <- #10
002B40 | 0015A0: 4800 00BB 	CALL	00BB			;PC <- 0176
002B44 | 0015A2: 1810      	LD	pA0, #10		;pA0 <- #10
002B46 | 0015A3: 071C      	LD	r3, B[1C]		;AH <- B[1C]
002B48 | 0015A4: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002B4A | 0015A5: 4800 0067 	CALL	0067			;PC <- 00CE
002B4E | 0015A7: 071D      	LD	r3, B[1D]		;AH <- B[1D]
002B50 | 0015A8: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002B52 | 0015A9: 4800 007C 	CALL	007C			;PC <- 00F8
002B56 | 0015AB: 0719      	LD	r3, B[19]		;AH <- B[19]
002B58 | 0015AC: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002B5A | 0015AD: 071A      	LD	r3, B[1A]		;AH <- B[1A]
002B5C | 0015AE: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
002B5E | 0015AF: 071B      	LD	r3, B[1B]		;AH <- B[1B]
002B60 | 0015B0: 043B      	LD	ptrAB, r3		;dp_A2 <- AH
002B62 | 0015B1: 4800 0000 	CALL	0000			;PC <- 0000
002B66 | 0015B3: 4C00 0297 	BRA	0297			;PC <- 052E

L_15B5:
002B6A | 0015B5: 8000      					;start addr IRAM
002B6C | 0015B6: 023B						;size
L_I0000:
002B6E | 0015B7: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002B70 | 0015B8: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002B72 | 0015B9: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002B74 | 0015BA: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002B76 | 0015BB: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002B78 | 0015BC: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002B7A | 0015BD: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002B7C | 0015BE: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002B7E | 0015BF: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002B80 | 0015C0: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002B82 | 0015C1: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002B84 | 0015C2: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002B86 | 0015C3: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002B88 | 0015C4: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002B8A | 0015C5: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002B8C | 0015C6: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002B8E | 0015C7: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002B90 | 0015C8: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002B92 | 0015C9: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002B94 | 0015CA: 8203      	ADD	r3, ptrA3		;ACC += dp_A0
002B96 | 0015CB: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002B98 | 0015CC: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002B9A | 0015CD: 8207      	ADD	r3, ptrA7		;ACC += dp_A1
002B9C | 0015CE: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002B9E | 0015CF: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002BA0 | 0015D0: 820B      	ADD	r3, ptrAB		;ACC += dp_A2
002BA2 | 0015D1: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BA4 | 0015D2: 0065      	LD	r6, r5		;PC <- STACK

002BA6 | 0015D3: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002BA8 | 0015D4: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BAA | 0015D5: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002BAC | 0015D6: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BAE | 0015D7: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002BB0 | 0015D8: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BB2 | 0015D9: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002BB4 | 0015DA: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BB6 | 0015DB: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002BB8 | 0015DC: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BBA | 0015DD: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002BBC | 0015DE: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BBE | 0015DF: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002BC0 | 0015E0: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BC2 | 0015E1: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002BC4 | 0015E2: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BC6 | 0015E3: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002BC8 | 0015E4: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BCA | 0015E5: B800      	AND	r3, #00		;ACC &= #00
002BCC | 0015E6: 0233      	LD	r3, ptrA3		;AH <- dp_A0
002BCE | 0015E7: 9003      	SHL	ACC			;
002BD0 | 0015E8: 9003      	SHL	ACC			;
002BD2 | 0015E9: 8204      	ADD	r3, ptrA4		;ACC += [p_A0++]
002BD4 | 0015EA: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BD6 | 0015EB: 0237      	LD	r3, ptrA7		;AH <- dp_A1
002BD8 | 0015EC: 9003      	SHL	ACC			;
002BDA | 0015ED: 9003      	SHL	ACC			;
002BDC | 0015EE: 8204      	ADD	r3, ptrA4		;ACC += [p_A0++]
002BDE | 0015EF: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BE0 | 0015F0: 023B      	LD	r3, ptrAB		;AH <- dp_A2
002BE2 | 0015F1: 9003      	SHL	ACC			;
002BE4 | 0015F2: 9003      	SHL	ACC			;
002BE6 | 0015F3: 8204      	ADD	r3, ptrA4		;ACC += [p_A0++]
002BE8 | 0015F4: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002BEA | 0015F5: 0065      	LD	r6, r5		;PC <- STACK
002BEC | 0015F6: 1A03      	LD	pA2, #03		;pA2 <- #03
002BEE | 0015F7: B734      	MLD	ptrA4, ptrB3	;ACC = 0, X <- [p_A0++], Y <- dp_B0
002BF0 | 0015F8: 0037      	LD	r3, r7		;AH <- P
002BF2 | 0015F9: 9002      	SHR	ACC			;
002BF4 | 0015FA: 9002      	SHR	ACC			;
002BF6 | 0015FB: 9002      	SHR	ACC			;
002BF8 | 0015FC: 9002      	SHR	ACC			;
002BFA | 0015FD: 9002      	SHR	ACC			;
002BFC | 0015FE: 9002      	SHR	ACC			;
002BFE | 0015FF: 9002      	SHR	ACC			;
002C00 | 001600: 9002      	SHR	ACC			;
002C02 | 001601: 04F5      	LD	ptrA5, rF		;[p_A1++] <- AL
002C04 | 001602: B774      	MLD	ptrA4, ptrB7	;ACC = 0, X <- [p_A0++], Y <- dp_B1
002C06 | 001603: 0037      	LD	r3, r7		;AH <- P
002C08 | 001604: 9002      	SHR	ACC			;
002C0A | 001605: 9002      	SHR	ACC			;
002C0C | 001606: 9002      	SHR	ACC			;
002C0E | 001607: 9002      	SHR	ACC			;
002C10 | 001608: 9002      	SHR	ACC			;
002C12 | 001609: 9002      	SHR	ACC			;
002C14 | 00160A: 9002      	SHR	ACC			;
002C16 | 00160B: 9002      	SHR	ACC			;
002C18 | 00160C: 04F5      	LD	ptrA5, rF		;[p_A1++] <- AL
002C1A | 00160D: B7B4      	MLD	ptrA4, ptrBB	;ACC = 0, X <- [p_A0++], Y <- dp_B2
002C1C | 00160E: 0037      	LD	r3, r7		;AH <- P
002C1E | 00160F: 9002      	SHR	ACC			;
002C20 | 001610: 9002      	SHR	ACC			;
002C22 | 001611: 9002      	SHR	ACC			;
002C24 | 001612: 9002      	SHR	ACC			;
002C26 | 001613: 9002      	SHR	ACC			;
002C28 | 001614: 9002      	SHR	ACC			;
002C2A | 001615: 9002      	SHR	ACC			;
002C2C | 001616: 9002      	SHR	ACC			;
002C2E | 001617: 04F5      	LD	ptrA5, rF		;[p_A1++] <- AL
002C30 | 001618: 1232      	LD	r3, pA2		;AH <- p_A2
002C32 | 001619: 3801      	SUB	r3, #01		;ACC -= #01
002C34 | 00161A: 1432      	LD	pA2, r3		;p_A2 <- AH
002C36 | 00161B: 4C70 0040 	BRA	ns, 0040		;PC <- 0080
002C3A | 00161D: 0065      	LD	r6, r5		;PC <- STACK
002C3C | 00161E: 4800 00A8 	CALL	00A8			;PC <- 0150
002C40 | 001620: 1A03      	LD	pA2, #03		;pA2 <- #03
002C42 | 001621: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002C44 | 001622: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002C46 | 001623: B774      	MLD	ptrA4, ptrB7	;ACC = 0, X <- [p_A0++], Y <- dp_B1
002C48 | 001624: 9738      	MPYA	ptrA8, ptrB3	;ACC += P, X <- [p_A0--!], Y <- dp_B0
002C4A | 001625: 9733      	MPYA	ptrA3, ptrB3	;ACC += P, X <- dp_A0, Y <- dp_B0
002C4C | 001626: 9003      	SHL	ACC			;
002C4E | 001627: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002C50 | 001628: B7B4      	MLD	ptrA4, ptrBB	;ACC = 0, X <- [p_A0++], Y <- dp_B2
002C52 | 001629: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
002C54 | 00162A: 9733      	MPYA	ptrA3, ptrB3	;ACC += P, X <- dp_A0, Y <- dp_B0
002C56 | 00162B: 9003      	SHL	ACC			;
002C58 | 00162C: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002C5A | 00162D: 1232      	LD	r3, pA2		;AH <- p_A2
002C5C | 00162E: 3801      	SUB	r3, #01		;ACC -= #01
002C5E | 00162F: 1432      	LD	pA2, r3		;p_A2 <- AH
002C60 | 001630: 4C70 006A 	BRA	ns, 006A		;PC <- 00D4
002C64 | 001632: 0065      	LD	r6, r5		;PC <- STACK

L_I007C:
002C66 | 001633: 4800 00A8 	CALL	00A8			;PC <- 0150
002C6A | 001635: 1A03      	LD	pA2, #03		;pA2 <- #03
002C6C | 001636: B774      	MLD	ptrA4, ptrB7	;ACC = 0, X <- [p_A0++], Y <- dp_B1
002C6E | 001637: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002C70 | 001638: 97B8      	MPYA	ptrA8, ptrBB	;ACC += P, X <- [p_A0--!], Y <- dp_B2
002C72 | 001639: 9733      	MPYA	ptrA3, ptrB3	;ACC += P, X <- dp_A0, Y <- dp_B0
002C74 | 00163A: 9003      	SHL	ACC			;
002C76 | 00163B: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002C78 | 00163C: 0238      	LD	r3, ptrA8		;AH <- [p_A0--!]
002C7A | 00163D: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002C7C | 00163E: B734      	MLD	ptrA4, ptrB3	;ACC = 0, X <- [p_A0++], Y <- dp_B0
002C7E | 00163F: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002C80 | 001640: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
002C82 | 001641: 9733      	MPYA	ptrA3, ptrB3	;ACC += P, X <- dp_A0, Y <- dp_B0
002C84 | 001642: 9003      	SHL	ACC			;
002C86 | 001643: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002C88 | 001644: 1232      	LD	r3, pA2		;AH <- p_A2
002C8A | 001645: 3801      	SUB	r3, #01		;ACC -= #01
002C8C | 001646: 1432      	LD	pA2, r3		;p_A2 <- AH
002C8E | 001647: 4C70 007F 	BRA	ns, 007F		;PC <- 00FE
002C92 | 001649: 0065      	LD	r6, r5		;PC <- STACK

L_I0093:
002C94 | 00164A: 4800 00A8 	CALL	00A8			;PC <- 0150
002C98 | 00164C: 1A03      	LD	pA2, #03		;pA2 <- #03
002C9A | 00164D: B774      	MLD	ptrA4, ptrB7	;ACC = 0, X <- [p_A0++], Y <- dp_B1
002C9C | 00164E: 9738      	MPYA	ptrA8, ptrB3	;ACC += P, X <- [p_A0--!], Y <- dp_B0
002C9E | 00164F: 9733      	MPYA	ptrA3, ptrB3	;ACC += P, X <- dp_A0, Y <- dp_B0
002CA0 | 001650: 9003      	SHL	ACC			;
002CA2 | 001651: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002CA4 | 001652: B7B4      	MLD	ptrA4, ptrBB	;ACC = 0, X <- [p_A0++], Y <- dp_B2
002CA6 | 001653: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
002CA8 | 001654: 9733      	MPYA	ptrA3, ptrB3	;ACC += P, X <- dp_A0, Y <- dp_B0
002CAA | 001655: 9003      	SHL	ACC			;
002CAC | 001656: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002CAE | 001657: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002CB0 | 001658: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002CB2 | 001659: 1232      	LD	r3, pA2		;AH <- p_A2
002CB4 | 00165A: 3801      	SUB	r3, #01		;ACC -= #01
002CB6 | 00165B: 1432      	LD	pA2, r3		;p_A2 <- AH
002CB8 | 00165C: 4C70 0096 	BRA	ns, 0096		;PC <- 012C
002CBC | 00165E: 0065      	LD	r6, r5		;PC <- STACK

L_I00A8:
002CBE | 00165F: 0233      	LD	r3, ptrA3		;AH <- dp_A0
002CC0 | 001660: A720      	AND	r3, RAMB[20]	;ACC &= RAMB[20]
002CC2 | 001661: 87F2      	ADD	r3, RAMB[F2]	;ACC += RAMB[F2]
002CC4 | 001662: 4A10      	LD	r1, (r3)		;X <- (AH)
002CC6 | 001663: 0233      	LD	r3, ptrA3		;AH <- dp_A0
002CC8 | 001664: 8721      	ADD	r3, RAMB[21]	;ACC += RAMB[21]
002CCA | 001665: A720      	AND	r3, RAMB[20]	;ACC &= RAMB[20]
002CCC | 001666: 87F2      	ADD	r3, RAMB[F2]	;ACC += RAMB[F2]
002CCE | 001667: 4A20      	LD	r2, (r3)		;Y <- (AH)
002CD0 | 001668: 0031      	LD	r3, r1		;AH <- X
002CD2 | 001669: 0533      	LD	ptrB3, r3		;dp_B0 <- AH
002CD4 | 00166A: 9006      	NEG	ACC			;
002CD6 | 00166B: 053B      	LD	ptrBB, r3		;dp_B2 <- AH
002CD8 | 00166C: 0527      	LD	ptrB7, r2		;dp_B1 <- Y
002CDA | 00166D: 0065      	LD	r6, r5		;PC <- STACK

L_I00B7:
002CDC | 00166E: 0810 4000 	LD	r1, #4000		;X <- #4000
002CE0 | 001670: 4C00 00C1 	BRA	00C1			;PC <- 0182
002CE4 | 001672: 0810 1000 	LD	r1, #1000		;X <- #1000
002CE8 | 001674: 4C00 00C1 	BRA	00C1			;PC <- 0182
002CEC | 001676: 0810 0080 	LD	r1, #0080		;X <- #0080
002CF0 | 001678: B800      	AND	r3, #00		;ACC &= #00
002CF2 | 001679: 0415      	LD	ptrA5, r1		;[p_A1++] <- X
002CF4 | 00167A: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002CF6 | 00167B: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002CF8 | 00167C: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002CFA | 00167D: 0415      	LD	ptrA5, r1		;[p_A1++] <- X
002CFC | 00167E: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002CFE | 00167F: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002D00 | 001680: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002D02 | 001681: 0415      	LD	ptrA5, r1		;[p_A1++] <- X
002D04 | 001682: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002D06 | 001683: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002D08 | 001684: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002D0A | 001685: 0065      	LD	r6, r5		;PC <- STACK

L_I00CF:
002D0C | 001686: 00E3      	LD	rE, r3		;EXT6 <- AH
002D0E | 001687: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
002D12 | 001689: 000C      	LD	r0, rC		;R0 <- EXT4
002D14 | 00168A: 05C4      	LD	ptrB4, rC		;[p_B0++] <- EXT4
002D16 | 00168B: 05C4      	LD	ptrB4, rC		;[p_B0++] <- EXT4
002D18 | 00168C: 05C4      	LD	ptrB4, rC		;[p_B0++] <- EXT4
002D1A | 00168D: 05C4      	LD	ptrB4, rC		;[p_B0++] <- EXT4
002D1C | 00168E: 05C4      	LD	ptrB4, rC		;[p_B0++] <- EXT4
002D1E | 00168F: 05C4      	LD	ptrB4, rC		;[p_B0++] <- EXT4
002D20 | 001690: 05C4      	LD	ptrB4, rC		;[p_B0++] <- EXT4
002D22 | 001691: 0065      	LD	r6, r5		;PC <- STACK

L_I00DB:
002D24 | 001692: 0604      	LD	r3, A[04]		;AH <- A[04]
002D26 | 001693: 9807      	ADD	r3, #07		;ACC += #07
002D28 | 001694: 00E3      	LD	rE, r3		;EXT6 <- AH
002D2A | 001695: 000E      	LD	r0, rE		;R0 <- EXT6
002D2C | 001696: 00C0      	LD	rC, r0		;EXT4 <- R0
002D2E | 001697: 1A02      	LD	pA2, #02		;pA2 <- #02
002D30 | 001698: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
002D32 | 001699: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D34 | 00169A: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D36 | 00169B: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
002D38 | 00169C: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D3A | 00169D: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D3C | 00169E: 02C4      	LD	rC, ptrA4		;EXT4 <- [p_A0++]
002D3E | 00169F: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D40 | 0016A0: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D42 | 0016A1: 02C0      	LD	rC, ptrA0		;EXT4 <- [p_A0]
002D44 | 0016A2: 1230      	LD	r3, pA0		;AH <- p_A0
002D46 | 0016A3: 3808      	SUB	r3, #08		;ACC -= #08
002D48 | 0016A4: 1430      	LD	pA0, r3		;p_A0 <- AH
002D4A | 0016A5: 1232      	LD	r3, pA2		;AH <- p_A2
002D4C | 0016A6: 3801      	SUB	r3, #01		;ACC -= #01
002D4E | 0016A7: 1432      	LD	pA2, r3		;p_A2 <- AH
002D50 | 0016A8: 4C70 00E1 	BRA	ns, 00E1		;PC <- 01C2
002D54 | 0016AA: 0065      	LD	r6, r5		;PC <- STACK
002D56 | 0016AB: 1A02      	LD	pA2, #02		;pA2 <- #02
002D58 | 0016AC: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002D5A | 0016AD: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002D5C | 0016AE: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D5E | 0016AF: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D60 | 0016B0: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002D62 | 0016B1: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002D64 | 0016B2: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D66 | 0016B3: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D68 | 0016B4: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
002D6A | 0016B5: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002D6C | 0016B6: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D6E | 0016B7: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
002D70 | 0016B8: 0230      	LD	r3, ptrA0		;AH <- [p_A0]
002D72 | 0016B9: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
002D74 | 0016BA: 1230      	LD	r3, pA0		;AH <- p_A0
002D76 | 0016BB: 3808      	SUB	r3, #08		;ACC -= #08
002D78 | 0016BC: 1430      	LD	pA0, r3		;p_A0 <- AH
002D7A | 0016BD: 1232      	LD	r3, pA2		;AH <- p_A2
002D7C | 0016BE: 3801      	SUB	r3, #01		;ACC -= #01
002D7E | 0016BF: 1432      	LD	pA2, r3		;p_A2 <- AH
002D80 | 0016C0: 4C70 00F5 	BRA	ns, 00F5		;PC <- 01EA
002D84 | 0016C2: 0065      	LD	r6, r5		;PC <- STACK
002D86 | 0016C3: 1910      	LD	pA1, #10		;pA1 <- #10
002D88 | 0016C4: 4800 00B7 	CALL	00B7			;PC <- 016E
002D8C | 0016C6: 1810      	LD	pA0, #10		;pA0 <- #10
002D8E | 0016C7: 071E      	LD	r3, B[1E]		;AH <- B[1E]
002D90 | 0016C8: 0FC5      	LD	RAMB[C5], r3	;RAMB[C5] <- AH
002D92 | 0016C9: 9006      	NEG	ACC			;
002D94 | 0016CA: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002D96 | 0016CB: 4800 0093 	CALL	0093			;PC <- 0126
002D9A | 0016CD: 071C      	LD	r3, B[1C]		;AH <- B[1C]
002D9C | 0016CE: 0FC3      	LD	RAMB[C3], r3	;RAMB[C3] <- AH
002D9E | 0016CF: 9006      	NEG	ACC			;
002DA0 | 0016D0: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002DA2 | 0016D1: 4800 0067 	CALL	0067			;PC <- 00CE
002DA6 | 0016D3: 071D      	LD	r3, B[1D]		;AH <- B[1D]
002DA8 | 0016D4: 0FC4      	LD	RAMB[C4], r3	;RAMB[C4] <- AH
002DAA | 0016D5: 9006      	NEG	ACC			;
002DAC | 0016D6: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002DAE | 0016D7: 4800 007C 	CALL	007C			;PC <- 00F8
002DB2 | 0016D9: 1910      	LD	pA1, #10		;pA1 <- #10
002DB4 | 0016DA: 4800 00F4 	CALL	00F4			;PC <- 01E8
002DB8 | 0016DC: 0719      	LD	r3, B[19]		;AH <- B[19]
002DBA | 0016DD: 0533      	LD	ptrB3, r3		;dp_B0 <- AH
002DBC | 0016DE: 071A      	LD	r3, B[1A]		;AH <- B[1A]
002DBE | 0016DF: 0FC6      	LD	RAMB[C6], r3	;RAMB[C6] <- AH
002DC0 | 0016E0: 0537      	LD	ptrB7, r3		;dp_B1 <- AH
002DC2 | 0016E1: 071B      	LD	r3, B[1B]		;AH <- B[1B]
002DC4 | 0016E2: 0FC7      	LD	RAMB[C7], r3	;RAMB[C7] <- AH
002DC6 | 0016E3: 9006      	NEG	ACC			;
002DC8 | 0016E4: 053B      	LD	ptrBB, r3		;dp_B2 <- AH
002DCA | 0016E5: 0D0F 0020 	LD	ptrBF, #0020	;dp_B3 <- #0020
002DCE | 0016E7: 1810      	LD	pA0, #10		;pA0 <- #10
002DD0 | 0016E8: B734      	MLD	ptrA4, ptrB3	;ACC = 0, X <- [p_A0++], Y <- dp_B0
002DD2 | 0016E9: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
002DD4 | 0016EA: 97B4      	MPYA	ptrA4, ptrBB	;ACC += P, X <- [p_A0++], Y <- dp_B2
002DD6 | 0016EB: 97F4      	MPYA	ptrA4, ptrBF	;ACC += P, X <- [p_A0++], Y <- dp_B3
002DD8 | 0016EC: 97F0      	MPYA	ptrA0, ptrBF	;ACC += P, X <- [p_A0], Y <- dp_B3
002DDA | 0016ED: 9003      	SHL	ACC			;
002DDC | 0016EE: 8711      	ADD	r3, RAMB[11]	;ACC += RAMB[11]
002DDE | 0016EF: 0FC0      	LD	RAMB[C0], r3	;RAMB[C0] <- AH
002DE0 | 0016F0: B734      	MLD	ptrA4, ptrB3	;ACC = 0, X <- [p_A0++], Y <- dp_B0
002DE2 | 0016F1: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
002DE4 | 0016F2: 97B4      	MPYA	ptrA4, ptrBB	;ACC += P, X <- [p_A0++], Y <- dp_B2
002DE6 | 0016F3: 97F4      	MPYA	ptrA4, ptrBF	;ACC += P, X <- [p_A0++], Y <- dp_B3
002DE8 | 0016F4: 97F0      	MPYA	ptrA0, ptrBF	;ACC += P, X <- [p_A0], Y <- dp_B3
002DEA | 0016F5: 9003      	SHL	ACC			;
002DEC | 0016F6: 8712      	ADD	r3, RAMB[12]	;ACC += RAMB[12]
002DEE | 0016F7: 0FC1      	LD	RAMB[C1], r3	;RAMB[C1] <- AH
002DF0 | 0016F8: B734      	MLD	ptrA4, ptrB3	;ACC = 0, X <- [p_A0++], Y <- dp_B0
002DF2 | 0016F9: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
002DF4 | 0016FA: 97B4      	MPYA	ptrA4, ptrBB	;ACC += P, X <- [p_A0++], Y <- dp_B2
002DF6 | 0016FB: 97F4      	MPYA	ptrA4, ptrBF	;ACC += P, X <- [p_A0++], Y <- dp_B3
002DF8 | 0016FC: 97F0      	MPYA	ptrA0, ptrBF	;ACC += P, X <- [p_A0], Y <- dp_B3
002DFA | 0016FD: 9003      	SHL	ACC			;
002DFC | 0016FE: 8713      	ADD	r3, RAMB[13]	;ACC += RAMB[13]
002DFE | 0016FF: 0FC2      	LD	RAMB[C2], r3	;RAMB[C2] <- AH
002E00 | 001700: 0065      	LD	r6, r5		;PC <- STACK
002E02 | 001701: 1910      	LD	pA1, #10		;pA1 <- #10
002E04 | 001702: 4800 00B7 	CALL	00B7			;PC <- 016E
002E08 | 001704: 1810      	LD	pA0, #10		;pA0 <- #10
002E0A | 001705: 07C4      	LD	r3, B[C4]		;AH <- B[C4]
002E0C | 001706: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002E0E | 001707: 4800 007C 	CALL	007C			;PC <- 00F8
002E12 | 001709: 07C3      	LD	r3, B[C3]		;AH <- B[C3]
002E14 | 00170A: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002E16 | 00170B: 4800 0067 	CALL	0067			;PC <- 00CE
002E1A | 00170D: 07C5      	LD	r3, B[C5]		;AH <- B[C5]
002E1C | 00170E: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002E1E | 00170F: 4C00 0093 	BRA	0093			;PC <- 0126

002E22 | 001711: 07C8      	LD	r3, B[C8]		;AH <- B[C8]
002E24 | 001712: A000      	AND	r3, r0		;ACC &= R0
002E26 | 001713: 4C50 0194 	BRA	nz, 0194		;PC <- 0328
002E2A | 001715: 1910      	LD	pA1, #10		;pA1 <- #10
002E2C | 001716: 4800 00BF 	CALL	00BF			;PC <- 017E
002E30 | 001718: 1810      	LD	pA0, #10		;pA0 <- #10
002E32 | 001719: 0716      	LD	r3, B[16]		;AH <- B[16]
002E34 | 00171A: 87C5      	ADD	r3, RAMB[C5]	;ACC += RAMB[C5]
002E36 | 00171B: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002E38 | 00171C: 4800 0093 	CALL	0093			;PC <- 0126
002E3C | 00171E: 0714      	LD	r3, B[14]		;AH <- B[14]
002E3E | 00171F: 87C3      	ADD	r3, RAMB[C3]	;ACC += RAMB[C3]
002E40 | 001720: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002E42 | 001721: 4800 0067 	CALL	0067			;PC <- 00CE
002E46 | 001723: 0715      	LD	r3, B[15]		;AH <- B[15]
002E48 | 001724: 87C4      	ADD	r3, RAMB[C4]	;ACC += RAMB[C4]
002E4A | 001725: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002E4C | 001726: 4800 007C 	CALL	007C			;PC <- 00F8
002E50 | 001728: B800      	AND	r3, #00		;ACC &= #00
002E52 | 001729: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002E54 | 00172A: 07C6      	LD	r3, B[C6]		;AH <- B[C6]
002E56 | 00172B: 9006      	NEG	ACC			;
002E58 | 00172C: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
002E5A | 00172D: 07C7      	LD	r3, B[C7]		;AH <- B[C7]
002E5C | 00172E: 043B      	LD	ptrAB, r3		;dp_A2 <- AH
002E5E | 00172F: 4C00 001C 	BRA	001C			;PC <- 0038
002E62 | 001731: 07C8      	LD	r3, B[C8]		;AH <- B[C8]
002E64 | 001732: A000      	AND	r3, r0		;ACC &= R0
002E66 | 001733: 4C50 01AC 	BRA	nz, 01AC		;PC <- 0358
002E6A | 001735: 1910      	LD	pA1, #10		;pA1 <- #10
002E6C | 001736: 4800 00BF 	CALL	00BF			;PC <- 017E
002E70 | 001738: 1810      	LD	pA0, #10		;pA0 <- #10
002E72 | 001739: 071C      	LD	r3, B[1C]		;AH <- B[1C]
002E74 | 00173A: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002E76 | 00173B: 4800 0067 	CALL	0067			;PC <- 00CE
002E7A | 00173D: 071D      	LD	r3, B[1D]		;AH <- B[1D]
002E7C | 00173E: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002E7E | 00173F: 4800 007C 	CALL	007C			;PC <- 00F8
002E82 | 001741: 0719      	LD	r3, B[19]		;AH <- B[19]
002E84 | 001742: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002E86 | 001743: 071A      	LD	r3, B[1A]		;AH <- B[1A]
002E88 | 001744: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
002E8A | 001745: 071B      	LD	r3, B[1B]		;AH <- B[1B]
002E8C | 001746: 043B      	LD	ptrAB, r3		;dp_A2 <- AH
002E8E | 001747: 4800 001C 	CALL	001C			;PC <- 0038
002E92 | 001749: 4C00 0162 	BRA	0162			;PC <- 02C4

002E96 | 00174B: 1910      	LD	pA1, #10		;pA1 <- #10
002E98 | 00174C: 4800 00BB 	CALL	00BB			;PC <- 0176
002E9C | 00174E: 1810      	LD	pA0, #10		;pA0 <- #10
002E9E | 00174F: 0716      	LD	r3, B[16]		;AH <- B[16]
002EA0 | 001750: 87C5      	ADD	r3, RAMB[C5]	;ACC += RAMB[C5]
002EA2 | 001751: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002EA4 | 001752: 4800 0093 	CALL	0093			;PC <- 0126
002EA8 | 001754: B800      	AND	r3, #00		;ACC &= #00
002EAA | 001755: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002EAC | 001756: 0820 0040 	LD	r2, #0040		;Y <- #0040
002EB0 | 001758: 07C6      	LD	r3, B[C6]		;AH <- B[C6]
002EB2 | 001759: 9006      	NEG	ACC			;
002EB4 | 00175A: 0013      	LD	r1, r3		;X <- AH
002EB6 | 00175B: 0037      	LD	r3, r7		;AH <- P
002EB8 | 00175C: 04F7      	LD	ptrA7, rF		;dp_A1 <- AL
002EBA | 00175D: 07C7      	LD	r3, B[C7]		;AH <- B[C7]
002EBC | 00175E: 0013      	LD	r1, r3		;X <- AH
002EBE | 00175F: 0037      	LD	r3, r7		;AH <- P
002EC0 | 001760: 04FB      	LD	ptrAB, rF		;dp_A2 <- AL
002EC2 | 001761: 4C00 0000 	BRA	0000			;PC <- 0000

002EC6 | 001763: 1910      	LD	pA1, #10		;pA1 <- #10
002EC8 | 001764: 4800 00BB 	CALL	00BB			;PC <- 0176
002ECC | 001766: 1810      	LD	pA0, #10		;pA0 <- #10
002ECE | 001767: 071C      	LD	r3, B[1C]		;AH <- B[1C]
002ED0 | 001768: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002ED2 | 001769: 4800 0067 	CALL	0067			;PC <- 00CE
002ED6 | 00176B: 071D      	LD	r3, B[1D]		;AH <- B[1D]
002ED8 | 00176C: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002EDA | 00176D: 4800 007C 	CALL	007C			;PC <- 00F8
002EDE | 00176F: 0820 0040 	LD	r2, #0040		;Y <- #0040
002EE2 | 001771: 0719      	LD	r3, B[19]		;AH <- B[19]
002EE4 | 001772: 0013      	LD	r1, r3		;X <- AH
002EE6 | 001773: 0037      	LD	r3, r7		;AH <- P
002EE8 | 001774: 04F3      	LD	ptrA3, rF		;dp_A0 <- AL
002EEA | 001775: 071A      	LD	r3, B[1A]		;AH <- B[1A]
002EEC | 001776: 0013      	LD	r1, r3		;X <- AH
002EEE | 001777: 0037      	LD	r3, r7		;AH <- P
002EF0 | 001778: 04F7      	LD	ptrA7, rF		;dp_A1 <- AL
002EF2 | 001779: 071B      	LD	r3, B[1B]		;AH <- B[1B]
002EF4 | 00177A: 0013      	LD	r1, r3		;X <- AH
002EF6 | 00177B: 0037      	LD	r3, r7		;AH <- P
002EF8 | 00177C: 04FB      	LD	ptrAB, rF		;dp_A2 <- AL
002EFA | 00177D: 4800 0000 	CALL	0000			;PC <- 0000
002EFE | 00177F: 4C00 019D 	BRA	019D			;PC <- 033A

002F02 | 001781: 1910      	LD	pA1, #10		;pA1 <- #10
002F04 | 001782: 4800 00BB 	CALL	00BB			;PC <- 0176
002F08 | 001784: 1810      	LD	pA0, #10		;pA0 <- #10
002F0A | 001785: 071E      	LD	r3, B[1E]		;AH <- B[1E]
002F0C | 001786: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002F0E | 001787: 4800 0093 	CALL	0093			;PC <- 0126
002F12 | 001789: 0820 0040 	LD	r2, #0040		;Y <- #0040
002F16 | 00178B: 0719      	LD	r3, B[19]		;AH <- B[19]
002F18 | 00178C: 0013      	LD	r1, r3		;X <- AH
002F1A | 00178D: 0037      	LD	r3, r7		;AH <- P
002F1C | 00178E: 04F3      	LD	ptrA3, rF		;dp_A0 <- AL
002F1E | 00178F: 071A      	LD	r3, B[1A]		;AH <- B[1A]
002F20 | 001790: 0013      	LD	r1, r3		;X <- AH
002F22 | 001791: 0037      	LD	r3, r7		;AH <- P
002F24 | 001792: 04F7      	LD	ptrA7, rF		;dp_A1 <- AL
002F26 | 001793: 071B      	LD	r3, B[1B]		;AH <- B[1B]
002F28 | 001794: 0013      	LD	r1, r3		;X <- AH
002F2A | 001795: 0037      	LD	r3, r7		;AH <- P
002F2C | 001796: 04FB      	LD	ptrAB, rF		;dp_A2 <- AL
002F2E | 001797: 4800 0000 	CALL	0000			;PC <- 0000
002F32 | 001799: 4C00 0198 	BRA	0198			;PC <- 0330
002F36 | 00179B: 1910      	LD	pA1, #10		;pA1 <- #10
002F38 | 00179C: 4800 00BF 	CALL	00BF			;PC <- 017E
002F3C | 00179E: 1810      	LD	pA0, #10		;pA0 <- #10
002F3E | 00179F: 0716      	LD	r3, B[16]		;AH <- B[16]
002F40 | 0017A0: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002F42 | 0017A1: 4800 0093 	CALL	0093			;PC <- 0126
002F46 | 0017A3: 0714      	LD	r3, B[14]		;AH <- B[14]
002F48 | 0017A4: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002F4A | 0017A5: 4800 0067 	CALL	0067			;PC <- 00CE
002F4E | 0017A7: 0715      	LD	r3, B[15]		;AH <- B[15]
002F50 | 0017A8: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002F52 | 0017A9: 4800 007C 	CALL	007C			;PC <- 00F8
002F56 | 0017AB: 0711      	LD	r3, B[11]		;AH <- B[11]
002F58 | 0017AC: 27C0      	SUB	r3, RAMB[C0]	;ACC -= RAMB[C0]
002F5A | 0017AD: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002F5C | 0017AE: 0712      	LD	r3, B[12]		;AH <- B[12]
002F5E | 0017AF: 27C1      	SUB	r3, RAMB[C1]	;ACC -= RAMB[C1]
002F60 | 0017B0: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
002F62 | 0017B1: 0713      	LD	r3, B[13]		;AH <- B[13]
002F64 | 0017B2: 27C2      	SUB	r3, RAMB[C2]	;ACC -= RAMB[C2]
002F66 | 0017B3: 043B      	LD	ptrAB, r3		;dp_A2 <- AH
002F68 | 0017B4: 4800 001C 	CALL	001C			;PC <- 0038
002F6C | 0017B6: 07C4      	LD	r3, B[C4]		;AH <- B[C4]
002F6E | 0017B7: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002F70 | 0017B8: 4800 007C 	CALL	007C			;PC <- 00F8
002F74 | 0017BA: 07C3      	LD	r3, B[C3]		;AH <- B[C3]
002F76 | 0017BB: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002F78 | 0017BC: 4800 0067 	CALL	0067			;PC <- 00CE
002F7C | 0017BE: 07C5      	LD	r3, B[C5]		;AH <- B[C5]
002F7E | 0017BF: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002F80 | 0017C0: 4C00 0093 	BRA	0093			;PC <- 0126
002F84 | 0017C2: 1910      	LD	pA1, #10		;pA1 <- #10
002F86 | 0017C3: 4800 00BF 	CALL	00BF			;PC <- 017E
002F8A | 0017C5: 1810      	LD	pA0, #10		;pA0 <- #10
002F8C | 0017C6: 071C      	LD	r3, B[1C]		;AH <- B[1C]
002F8E | 0017C7: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002F90 | 0017C8: 4800 0067 	CALL	0067			;PC <- 00CE
002F94 | 0017CA: 071D      	LD	r3, B[1D]		;AH <- B[1D]
002F96 | 0017CB: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002F98 | 0017CC: 4800 007C 	CALL	007C			;PC <- 00F8
002F9C | 0017CE: 0719      	LD	r3, B[19]		;AH <- B[19]
002F9E | 0017CF: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002FA0 | 0017D0: 071A      	LD	r3, B[1A]		;AH <- B[1A]
002FA2 | 0017D1: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
002FA4 | 0017D2: 071B      	LD	r3, B[1B]		;AH <- B[1B]
002FA6 | 0017D3: 043B      	LD	ptrAB, r3		;dp_A2 <- AH
002FA8 | 0017D4: 4800 001C 	CALL	001C			;PC <- 0038
002FAC | 0017D6: 4C00 01E8 	BRA	01E8			;PC <- 03D0
002FB0 | 0017D8: 1910      	LD	pA1, #10		;pA1 <- #10
002FB2 | 0017D9: 4800 00BF 	CALL	00BF			;PC <- 017E
002FB6 | 0017DB: 1810      	LD	pA0, #10		;pA0 <- #10
002FB8 | 0017DC: 0711      	LD	r3, B[11]		;AH <- B[11]
002FBA | 0017DD: 27C0      	SUB	r3, RAMB[C0]	;ACC -= RAMB[C0]
002FBC | 0017DE: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002FBE | 0017DF: 0712      	LD	r3, B[12]		;AH <- B[12]
002FC0 | 0017E0: 27C1      	SUB	r3, RAMB[C1]	;ACC -= RAMB[C1]
002FC2 | 0017E1: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
002FC4 | 0017E2: 0713      	LD	r3, B[13]		;AH <- B[13]
002FC6 | 0017E3: 27C2      	SUB	r3, RAMB[C2]	;ACC -= RAMB[C2]
002FC8 | 0017E4: 043B      	LD	ptrAB, r3		;dp_A2 <- AH
002FCA | 0017E5: 4800 001C 	CALL	001C			;PC <- 0038
002FCE | 0017E7: 07C4      	LD	r3, B[C4]		;AH <- B[C4]
002FD0 | 0017E8: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002FD2 | 0017E9: 4800 007C 	CALL	007C			;PC <- 00F8
002FD6 | 0017EB: 07C3      	LD	r3, B[C3]		;AH <- B[C3]
002FD8 | 0017EC: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002FDA | 0017ED: 4800 0067 	CALL	0067			;PC <- 00CE
002FDE | 0017EF: 07C5      	LD	r3, B[C5]		;AH <- B[C5]
002FE0 | 0017F0: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
002FE2 | 0017F1: 4C00 0093 	BRA	0093			;PC <- 0126

L_18A3:
003146 | 0018A3: 0830 FFE0 	LD	r3, #FFE0		;AH <- #FFE0
00314A | 0018A5: 0F16      	LD	RAMB[16], r3	;RAMB[16] <- AH
00314C | 0018A6: 0830 1FFF 	LD	r3, #1FFF		;AH <- #1FFF
003150 | 0018A8: 0F11      	LD	RAMB[11], r3	;RAMB[11] <- AH
003152 | 0018A9: 0830 0080 	LD	r3, #0080		;AH <- #0080
003156 | 0018AB: 0F1A      	LD	RAMB[1A], r3	;RAMB[1A] <- AH
003158 | 0018AC: 08E0 6000 	LD	rE, #6000		;EXT6 <- #6000
00315C | 0018AE: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
003160 | 0018B0: 0080      	LD	r8, r0		;EXT0 <- R0
003162 | 0018B1: 0830 0096 	LD	r3, #0096		;AH <- #0096
003166 | 0018B3: 4800 1DBE 	CALL	1DBE			;PC <- 3B7C
00316A | 0018B5: 0830 7FFF 	LD	r3, #7FFF		;AH <- #7FFF
00316E | 0018B7: 0F12      	LD	RAMB[12], r3	;RAMB[12] <- AH
003170 | 0018B8: 0830 0002 	LD	r3, #0002		;AH <- #0002
003174 | 0018BA: 0EF4      	LD	RAMA[F4], r3	;RAMA[F4] <- AH
003176 | 0018BB: 0830 0007 	LD	r3, #0007		;AH <- #0007
00317A | 0018BD: 0EF3      	LD	RAMA[F3], r3	;RAMA[F3] <- AH
00317C | 0018BE: 0810 7600 	LD	r1, #7600		;X <- #7600
003180 | 0018C0: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
003182 | 0018C1: 3801      	SUB	r3, #01		;ACC -= #01
003184 | 0018C2: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
003186 | 0018C3: 1531      	LD	pB1, r3		;p_B1 <- AH
003188 | 0018C4: 0D01 18C8 	LD	ptrB1, #18C8	;[p_B1] <- #18C8
00318C | 0018C6: 4C00 0000 	BRA	0000			;PC <- 0000
003190 | 0018C8: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
003192 | 0018C9: 1531      	LD	pB1, r3		;p_B1 <- AH
003194 | 0018CA: 9801      	ADD	r3, #01		;ACC += #01
003196 | 0018CB: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
003198 | 0018CC: 0361      	LD	r6, ptrB1		;PC <- [p_B1]

00319A | 0018CD: 08E0 6000 	LD	rE, #6000		;EXT6 <- #6000
00319E | 0018CF: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
0031A2 | 0018D1: 0080      	LD	r8, r0		;EXT0 <- R0
0031A4 | 0018D2: B800      	AND	r3, #00		;ACC &= #00
0031A6 | 0018D3: 0FE3      	LD	RAMB[E3], r3	;RAMB[E3] <- AH
0031A8 | 0018D4: 0830 1000 	LD	r3, #1000		;AH <- #1000
0031AC | 0018D6: 0F12      	LD	RAMB[12], r3	;RAMB[12] <- AH
0031AE | 0018D7: 0830 0002 	LD	r3, #0002		;AH <- #0002
0031B2 | 0018D9: 0EF4      	LD	RAMA[F4], r3	;RAMA[F4] <- AH
0031B4 | 0018DA: 08E0 7D20 	LD	rE, #7D20		;EXT6 <- #7D20
0031B8 | 0018DC: 08E0 3018 	LD	rE, #3018		;EXT6 <- #3018
0031BC | 0018DE: 000A      	LD	r0, rA		;R0 <- EXT2
0031BE | 0018DF: 003A      	LD	r3, rA		;AH <- EXT2
0031C0 | 0018E0: A000      	AND	r3, r0		;ACC &= R0
0031C2 | 0018E1: 4D50 18EB 	BRA	z, 18EB		;PC <- 31D6
0031C6 | 0018E3: 0830 7D27 	LD	r3, #7D27		;AH <- #7D27
0031CA | 0018E5: 4800 01B5 	CALL	01B5			;PC <- 036A
0031CE | 0018E7: 0031      	LD	r3, r1		;AH <- X
0031D0 | 0018E8: 00F2      	LD	rF, r2		;AL <- Y
0031D2 | 0018E9: 4800 0376 	CALL	0376			;PC <- 06EC
0031D6 | 0018EB: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
0031D8 | 0018EC: 1531      	LD	pB1, r3		;p_B1 <- AH
0031DA | 0018ED: 9801      	ADD	r3, #01		;ACC += #01
0031DC | 0018EE: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
0031DE | 0018EF: 0361      	LD	r6, ptrB1		;PC <- [p_B1]
0031E0 | 0018F0: 0830 7880 	LD	r3, #7880		;AH <- #7880
0031E4 | 0018F2: 0EF2      	LD	RAMA[F2], r3	;RAMA[F2] <- AH
0031E6 | 0018F3: 4C00 18F8 	BRA	18F8			;PC <- 31F0
0031EA | 0018F5: 0830 7600 	LD	r3, #7600		;AH <- #7600
0031EE | 0018F7: 0EF2      	LD	RAMA[F2], r3	;RAMA[F2] <- AH
0031F0 | 0018F8: 4800 1DD9 	CALL	1DD9			;PC <- 3BB2
0031F4 | 0018FA: 4800 1DCD 	CALL	1DCD			;PC <- 3B9A
0031F8 | 0018FC: 08E0 6000 	LD	rE, #6000		;EXT6 <- #6000
0031FC | 0018FE: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
003200 | 001900: 0080      	LD	r8, r0		;EXT0 <- R0
003202 | 001901: 0830 0074 	LD	r3, #0074		;AH <- #0074
003206 | 001903: 4800 1DBE 	CALL	1DBE			;PC <- 3B7C
00320A | 001905: 0830 0010 	LD	r3, #0010		;AH <- #0010
00320E | 001907: 0EF4      	LD	RAMA[F4], r3	;RAMA[F4] <- AH
003210 | 001908: 0830 0006 	LD	r3, #0006		;AH <- #0006
003214 | 00190A: 0EF1      	LD	RAMA[F1], r3	;RAMA[F1] <- AH
003216 | 00190B: 06F2      	LD	r3, A[F2]		;AH <- A[F2]
003218 | 00190C: 9807      	ADD	r3, #07		;ACC += #07
00321A | 00190D: 0013      	LD	r1, r3		;X <- AH
00321C | 00190E: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
00321E | 00190F: 3801      	SUB	r3, #01		;ACC -= #01
003220 | 001910: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
003222 | 001911: 1531      	LD	pB1, r3		;p_B1 <- AH
003224 | 001912: 0D01 1916 	LD	ptrB1, #1916	;[p_B1] <- #1916
003228 | 001914: 4C00 1D7D 	BRA	1D7D			;PC <- 3AFA
00322C | 001916: 06F2      	LD	r3, A[F2]		;AH <- A[F2]
00322E | 001917: 9820      	ADD	r3, #20		;ACC += #20
003230 | 001918: 0EF2      	LD	RAMA[F2], r3	;RAMA[F2] <- AH
003232 | 001919: 0830 0800 	LD	r3, #0800		;AH <- #0800
003236 | 00191B: 0F12      	LD	RAMB[12], r3	;RAMB[12] <- AH
003238 | 00191C: 0830 0002 	LD	r3, #0002		;AH <- #0002
00323C | 00191E: 0EF4      	LD	RAMA[F4], r3	;RAMA[F4] <- AH
00323E | 00191F: 0830 0096 	LD	r3, #0096		;AH <- #0096
003242 | 001921: 4800 1DBE 	CALL	1DBE			;PC <- 3B7C
003246 | 001923: 0830 0012 	LD	r3, #0012		;AH <- #0012
00324A | 001925: 0EF3      	LD	RAMA[F3], r3	;RAMA[F3] <- AH
00324C | 001926: 06F2      	LD	r3, A[F2]		;AH <- A[F2]
00324E | 001927: 0013      	LD	r1, r3		;X <- AH
003250 | 001928: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
003252 | 001929: 3801      	SUB	r3, #01		;ACC -= #01
003254 | 00192A: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
003256 | 00192B: 1531      	LD	pB1, r3		;p_B1 <- AH
003258 | 00192C: 0D01 1930 	LD	ptrB1, #1930	;[p_B1] <- #1930
00325C | 00192E: 4C00 0000 	BRA	0000			;PC <- 0000
003260 | 001930: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
003262 | 001931: 1531      	LD	pB1, r3		;p_B1 <- AH
003264 | 001932: 9801      	ADD	r3, #01		;ACC += #01
003266 | 001933: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
003268 | 001934: 0361      	LD	r6, ptrB1		;PC <- [p_B1]
00326A | 001935: 4800 1DD9 	CALL	1DD9			;PC <- 3BB2
00326E | 001937: 08E0 6000 	LD	rE, #6000		;EXT6 <- #6000
003272 | 001939: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
003276 | 00193B: 0080      	LD	r8, r0		;EXT0 <- R0
003278 | 00193C: 4800 1E02 	CALL	1E02			;PC <- 3C04
00327C | 00193E: A000      	AND	r3, r0		;ACC &= R0
00327E | 00193F: 9003      	SHL	ACC			;
003280 | 001940: 9003      	SHL	ACC			;
003282 | 001941: 9003      	SHL	ACC			;
003284 | 001942: 9003      	SHL	ACC			;
003286 | 001943: 9003      	SHL	ACC			;
003288 | 001944: 0F10      	LD	RAMB[10], r3	;RAMB[10] <- AH
00328A | 001945: 0830 0096 	LD	r3, #0096		;AH <- #0096
00328E | 001947: 4800 1DBE 	CALL	1DBE			;PC <- 3B7C
003292 | 001949: 0830 1000 	LD	r3, #1000		;AH <- #1000
003296 | 00194B: 0F12      	LD	RAMB[12], r3	;RAMB[12] <- AH
003298 | 00194C: 0830 0010 	LD	r3, #0010		;AH <- #0010
00329C | 00194E: 8710      	ADD	r3, RAMB[10]	;ACC += RAMB[10]
00329E | 00194F: 0EF4      	LD	RAMA[F4], r3	;RAMA[F4] <- AH
0032A0 | 001950: 0830 0004 	LD	r3, #0004		;AH <- #0004
0032A4 | 001952: 0EF3      	LD	RAMA[F3], r3	;RAMA[F3] <- AH
0032A6 | 001953: 0810 7620 	LD	r1, #7620		;X <- #7620
0032AA | 001955: 4C00 0000 	BRA	0000			;PC <- 0000
0032AE | 001957: 4800 1DD9 	CALL	1DD9			;PC <- 3BB2
0032B2 | 001959: 08E0 6000 	LD	rE, #6000		;EXT6 <- #6000
0032B6 | 00195B: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
0032BA | 00195D: 0080      	LD	r8, r0		;EXT0 <- R0
0032BC | 00195E: 4800 1E02 	CALL	1E02			;PC <- 3C04
0032C0 | 001960: 0F10      	LD	RAMB[10], r3	;RAMB[10] <- AH
0032C2 | 001961: 0830 0074 	LD	r3, #0074		;AH <- #0074
0032C6 | 001963: 4800 1DBE 	CALL	1DBE			;PC <- 3B7C
0032CA | 001965: 0830 0010 	LD	r3, #0010		;AH <- #0010
0032CE | 001967: 8710      	ADD	r3, RAMB[10]	;ACC += RAMB[10]
0032D0 | 001968: 0EF4      	LD	RAMA[F4], r3	;RAMA[F4] <- AH
0032D2 | 001969: 0830 0007 	LD	r3, #0007		;AH <- #0007
0032D6 | 00196B: 0EF1      	LD	RAMA[F1], r3	;RAMA[F1] <- AH
0032D8 | 00196C: 0810 7607 	LD	r1, #7607		;X <- #7607
0032DC | 00196E: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
0032DE | 00196F: 3801      	SUB	r3, #01		;ACC -= #01
0032E0 | 001970: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
0032E2 | 001971: 1531      	LD	pB1, r3		;p_B1 <- AH
0032E4 | 001972: 0D01 1976 	LD	ptrB1, #1976	;[p_B1] <- #1976
0032E8 | 001974: 4C00 1D7D 	BRA	1D7D			;PC <- 3AFA
0032EC | 001976: 0830 0800 	LD	r3, #0800		;AH <- #0800
0032F0 | 001978: 0F12      	LD	RAMB[12], r3	;RAMB[12] <- AH
0032F2 | 001979: 0830 0096 	LD	r3, #0096		;AH <- #0096
0032F6 | 00197B: 4800 1DBE 	CALL	1DBE			;PC <- 3B7C
0032FA | 00197D: 07C8      	LD	r3, B[C8]		;AH <- B[C8]
0032FC | 00197E: A000      	AND	r3, r0		;ACC &= R0
0032FE | 00197F: 4C50 1992 	BRA	nz, 1992		;PC <- 3324
003302 | 001981: 0830 0002 	LD	r3, #0002		;AH <- #0002
003306 | 001983: 8710      	ADD	r3, RAMB[10]	;ACC += RAMB[10]
003308 | 001984: 0EF4      	LD	RAMA[F4], r3	;RAMA[F4] <- AH
00330A | 001985: 0830 0009 	LD	r3, #0009		;AH <- #0009
00330E | 001987: 0EF3      	LD	RAMA[F3], r3	;RAMA[F3] <- AH
003310 | 001988: 0810 7620 	LD	r1, #7620		;X <- #7620
003314 | 00198A: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
003316 | 00198B: 3801      	SUB	r3, #01		;ACC -= #01
003318 | 00198C: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
00331A | 00198D: 1531      	LD	pB1, r3		;p_B1 <- AH
00331C | 00198E: 0D01 1992 	LD	ptrB1, #1992	;[p_B1] <- #1992
003320 | 001990: 4C00 0000 	BRA	0000			;PC <- 0000
003324 | 001992: 0830 0006 	LD	r3, #0006		;AH <- #0006
003328 | 001994: 8710      	ADD	r3, RAMB[10]	;ACC += RAMB[10]
00332A | 001995: 0EF4      	LD	RAMA[F4], r3	;RAMA[F4] <- AH
00332C | 001996: 0830 002C 	LD	r3, #002C		;AH <- #002C
003330 | 001998: 0EF3      	LD	RAMA[F3], r3	;RAMA[F3] <- AH
003332 | 001999: 0810 7760 	LD	r1, #7760		;X <- #7760
003336 | 00199B: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
003338 | 00199C: 3801      	SUB	r3, #01		;ACC -= #01
00333A | 00199D: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
00333C | 00199E: 1531      	LD	pB1, r3		;p_B1 <- AH
00333E | 00199F: 0D01 19A3 	LD	ptrB1, #19A3	;[p_B1] <- #19A3
003342 | 0019A1: 4C00 0000 	BRA	0000			;PC <- 0000
003346 | 0019A3: 0830 0006 	LD	r3, #0006		;AH <- #0006
00334A | 0019A5: 0EF1      	LD	RAMA[F1], r3	;RAMA[F1] <- AH
00334C | 0019A6: 0810 7D00 	LD	r1, #7D00		;X <- #7D00
003350 | 0019A8: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
003352 | 0019A9: 3801      	SUB	r3, #01		;ACC -= #01
003354 | 0019AA: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
003356 | 0019AB: 1531      	LD	pB1, r3		;p_B1 <- AH
003358 | 0019AC: 0D01 19B0 	LD	ptrB1, #19B0	;[p_B1] <- #19B0
00335C | 0019AE: 4C00 1D97 	BRA	1D97			;PC <- 3B2E
003360 | 0019B0: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
003362 | 0019B1: 1531      	LD	pB1, r3		;p_B1 <- AH
003364 | 0019B2: 9801      	ADD	r3, #01		;ACC += #01
003366 | 0019B3: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
003368 | 0019B4: 0361      	LD	r6, ptrB1		;PC <- [p_B1]

L_19B5:
00336A | 0019B5: 8000						;start addr IRAM
00336C | 0019B6: 03C5						;size
L_I0000:
00336E | 0019B7: 0031      	LD	r3, r1		;AH <- X
003370 | 0019B8: 00E3      	LD	rE, r3		;EXT6 <- AH
003372 | 0019B9: 08E0 3018 	LD	rE, #3018		;EXT6 <- #3018
003376 | 0019BB: 000A      	LD	r0, rA		;R0 <- EXT2
003378 | 0019BC: 9807      	ADD	r3, #07		;ACC += #07
00337A | 0019BD: 0EF2      	LD	RAMA[F2], r3	;RAMA[F2] <- AH
00337C | 0019BE: 003A      	LD	r3, rA		;AH <- EXT2
00337E | 0019BF: A000      	AND	r3, r0		;ACC &= R0
003380 | 0019C0: 4D50 0012 	BRA	z, 0012		;PC <- 0024
003384 | 0019C2: 06F2      	LD	r3, A[F2]		;AH <- A[F2]
003386 | 0019C3: 4800 01B5 	CALL	01B5			;PC <- 036A
00338A | 0019C5: 0031      	LD	r3, r1		;AH <- X
00338C | 0019C6: 00F2      	LD	rF, r2		;AL <- Y
00338E | 0019C7: 4800 002C 	CALL	002C			;PC <- 0058
003392 | 0019C9: 06F2      	LD	r3, A[F2]		;AH <- A[F2]
003394 | 0019CA: 9820      	ADD	r3, #20		;ACC += #20
003396 | 0019CB: 0EF2      	LD	RAMA[F2], r3	;RAMA[F2] <- AH
003398 | 0019CC: 06F3      	LD	r3, A[F3]		;AH <- A[F3]
00339A | 0019CD: 3801      	SUB	r3, #01		;ACC -= #01
00339C | 0019CE: 0EF3      	LD	RAMA[F3], r3	;RAMA[F3] <- AH
00339E | 0019CF: 4C70 0007 	BRA	ns, 0007		;PC <- 000E
0033A2 | 0019D1: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
0033A4 | 0019D2: 1531      	LD	pB1, r3		;p_B1 <- AH
0033A6 | 0019D3: 9801      	ADD	r3, #01		;ACC += #01
0033A8 | 0019D4: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
0033AA | 0019D5: 0361      	LD	r6, ptrB1		;PC <- [p_B1]
0033AC | 0019D6: 0820 0001 	LD	r2, #0001		;Y <- #0001
0033B0 | 0019D8: 8007      	ADD	r3, r7		;ACC += P
0033B2 | 0019D9: 001F      	LD	r1, rF		;X <- AL
0033B4 | 0019DA: 00E1      	LD	rE, r1		;EXT6 <- X
0033B6 | 0019DB: C715      	OR	r3, RAMB[15]	;ACC |= RAMB[15]
0033B8 | 0019DC: 00E3      	LD	rE, r3		;EXT6 <- AH
0033BA | 0019DD: 0008      	LD	r0, r8		;R0 <- EXT0
0033BC | 0019DE: 0038      	LD	r3, r8		;AH <- EXT0
0033BE | 0019DF: 0018      	LD	r1, r8		;X <- EXT0
0033C0 | 0019E0: 00F1      	LD	rF, r1		;AL <- X
0033C2 | 0019E1: 9002      	SHR	ACC			;
0033C4 | 0019E2: C715      	OR	r3, RAMB[15]	;ACC |= RAMB[15]
0033C6 | 0019E3: 001F      	LD	r1, rF		;X <- AL
0033C8 | 0019E4: 00E1      	LD	rE, r1		;EXT6 <- X
0033CA | 0019E5: 00E3      	LD	rE, r3		;EXT6 <- AH
0033CC | 0019E6: 0008      	LD	r0, r8		;R0 <- EXT0
0033CE | 0019E7: 0038      	LD	r3, r8		;AH <- EXT0
0033D0 | 0019E8: 0EED      	LD	RAMA[ED], r3	;RAMA[ED] <- AH
L_I0032:
0033D2 | 0019E9: 0713      	LD	r3, B[13]		;AH <- B[13]
0033D4 | 0019EA: 671B      	CMP	r3, RAMB[1B]	;ACC == RAMB[1B]
0033D6 | 0019EB: 4C70 0053 	BRA	ns, 0053		;PC <- 00A6
0033DA | 0019ED: 0038      	LD	r3, r8		;AH <- EXT0
0033DC | 0019EE: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
0033DE | 0019EF: 0000      	LD	r0, r0		;R0 <- R0
		     B880      	AND	r3, #80		;ACC &= #80
0033E0 | 0019F0: 0000      	LD	r0, r0		;R0 <- R0
0033E2 | 0019F1: 0000      	LD	r0, r0		;R0 <- R0
                 4C50 0060 	BRA	nz, 0060		;PC <- 00B0
0033E4 | 0019F2: 19E0      	LD	pA1, #E0		;pA1 <- #E0
0033E6 | 0019F3: 4800 0072 	CALL	0072			;PC <- 00E4
0033EA | 0019F5: 4800 0072 	CALL	0072			;PC <- 00E4
0033EE | 0019F7: 4800 0072 	CALL	0072			;PC <- 00E4
0033F2 | 0019F9: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
0033F4 | 0019FA: B810      	AND	r3, #10		;ACC &= #10
0033F6 | 0019FB: 4C50 0054 	BRA	nz, 0054		;PC <- 00A8			goto L_I0054
0033FA | 0019FD: 4800 0072 	CALL	0072			;PC <- 00E4
0033FE | 0019FF: 4800 01C5 	CALL	01C5			;PC <- 038A
003402 | 001A01: 06EF      	LD	r3, A[EF]		;AH <- A[EF]
003404 | 001A02: A000      	AND	r3, r0		;ACC &= R0
003406 | 001A03: 4950 01EB 	CALL	z, 01EB		;PC <- 03D6
00340A | 001A05: 06ED      	LD	r3, A[ED]		;AH <- A[ED]
00340C | 001A06: 3801      	SUB	r3, #01		;ACC -= #01
00340E | 001A07: 0EED      	LD	RAMA[ED], r3	;RAMA[ED] <- AH
003410 | 001A08: 4C70 0032 	BRA	ns, 0032		;PC <- 0064
003414 | 001A0A: 0065      	LD	r6, r5		;PC <- STACK

L_I0054:
003416 | 001A0B: 4800 01C2 	CALL	01C2			;PC <- 0384
00341A | 001A0D: 06EF      	LD	r3, A[EF]		;AH <- A[EF]
00341C | 001A0E: A000      	AND	r3, r0		;ACC &= R0
00341E | 001A0F: 4950 02D6 	CALL	z, 02D6		;PC <- 05AC			call L_I02D6
003422 | 001A11: 06ED      	LD	r3, A[ED]		;AH <- A[ED]
003424 | 001A12: 3801      	SUB	r3, #01		;ACC -= #01
003426 | 001A13: 0EED      	LD	RAMA[ED], r3	;RAMA[ED] <- AH
003428 | 001A14: 4C70 0032 	BRA	ns, 0032		;PC <- 0064
00342C | 001A16: 0065      	LD	r6, r5		;PC <- STACK

L_I0060:
00342E | 001A17: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
003430 | 001A18: B810      	AND	r3, #10		;ACC &= #10
003432 | 001A19: 4C50 0067 	BRA	nz, 0067		;PC <- 00CE
003436 | 001A1B: 0008      	LD	r0, r8		;R0 <- EXT0
003438 | 001A1C: 0008      	LD	r0, r8		;R0 <- EXT0
00343A | 001A1D: 0008      	LD	r0, r8		;R0 <- EXT0
00343C | 001A1E: 0008      	LD	r0, r8		;R0 <- EXT0
00343E | 001A1F: 0008      	LD	r0, r8		;R0 <- EXT0
003440 | 001A20: 0008      	LD	r0, r8		;R0 <- EXT0
003442 | 001A21: 0008      	LD	r0, r8		;R0 <- EXT0
003444 | 001A22: 0008      	LD	r0, r8		;R0 <- EXT0
003446 | 001A23: 0008      	LD	r0, r8		;R0 <- EXT0
003448 | 001A24: 0008      	LD	r0, r8		;R0 <- EXT0
00344A | 001A25: 0008      	LD	r0, r8		;R0 <- EXT0
00344C | 001A26: 0008      	LD	r0, r8		;R0 <- EXT0
00344E | 001A27: 4C00 004E 	BRA	004E			;PC <- 009C

003452 | 001A29: 06F0      	LD	r3, A[F0]		;AH <- A[F0]
003454 | 001A2A: 0063      	LD	r6, r3		;PC <- AH
003456 | 001A2B: 0038      	LD	r3, r8		;AH <- EXT0
003458 | 001A2C: 27C0      	SUB	r3, RAMB[C0]	;ACC -= RAMB[C0]
00345A | 001A2D: 0533      	LD	ptrB3, r3		;dp_B0 <- AH
00345C | 001A2E: 0038      	LD	r3, r8		;AH <- EXT0
00345E | 001A2F: 27C1      	SUB	r3, RAMB[C1]	;ACC -= RAMB[C1]
003460 | 001A30: 0537      	LD	ptrB7, r3		;dp_B1 <- AH
003462 | 001A31: 0038      	LD	r3, r8		;AH <- EXT0
003464 | 001A32: 27C2      	SUB	r3, RAMB[C2]	;ACC -= RAMB[C2]
003466 | 001A33: 053B      	LD	ptrBB, r3		;dp_B2 <- AH
003468 | 001A34: 0D0F 0020 	LD	ptrBF, #0020	;dp_B3 <- #0020
00346C | 001A36: 1810      	LD	pA0, #10		;pA0 <- #10
00346E | 001A37: B734      	MLD	ptrA4, ptrB3	;ACC = 0, X <- [p_A0++], Y <- dp_B0
003470 | 001A38: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
003472 | 001A39: 97B4      	MPYA	ptrA4, ptrBB	;ACC += P, X <- [p_A0++], Y <- dp_B2
003474 | 001A3A: 97F4      	MPYA	ptrA4, ptrBF	;ACC += P, X <- [p_A0++], Y <- dp_B3
003476 | 001A3B: 97F0      	MPYA	ptrA0, ptrBF	;ACC += P, X <- [p_A0], Y <- dp_B3
003478 | 001A3C: 9003      	SHL	ACC			;
00347A | 001A3D: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
00347C | 001A3E: B734      	MLD	ptrA4, ptrB3	;ACC = 0, X <- [p_A0++], Y <- dp_B0
00347E | 001A3F: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
003480 | 001A40: 97B4      	MPYA	ptrA4, ptrBB	;ACC += P, X <- [p_A0++], Y <- dp_B2
003482 | 001A41: 97F4      	MPYA	ptrA4, ptrBF	;ACC += P, X <- [p_A0++], Y <- dp_B3
003484 | 001A42: 97F0      	MPYA	ptrA0, ptrBF	;ACC += P, X <- [p_A0], Y <- dp_B3
003486 | 001A43: 9003      	SHL	ACC			;
003488 | 001A44: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
00348A | 001A45: B734      	MLD	ptrA4, ptrB3	;ACC = 0, X <- [p_A0++], Y <- dp_B0
00348C | 001A46: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
00348E | 001A47: 97B4      	MPYA	ptrA4, ptrBB	;ACC += P, X <- [p_A0++], Y <- dp_B2
003490 | 001A48: 97F4      	MPYA	ptrA4, ptrBF	;ACC += P, X <- [p_A0++], Y <- dp_B3
003492 | 001A49: 97F0      	MPYA	ptrA0, ptrBF	;ACC += P, X <- [p_A0], Y <- dp_B3
003494 | 001A4A: 9003      	SHL	ACC			;
003496 | 001A4B: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
003498 | 001A4C: 0065      	LD	r6, r5		;PC <- STACK
00349A | 001A4D: 0583      	LD	ptrB3, r8		;dp_B0 <- EXT0
00349C | 001A4E: 0587      	LD	ptrB7, r8		;dp_B1 <- EXT0
00349E | 001A4F: 058B      	LD	ptrBB, r8		;dp_B2 <- EXT0
0034A0 | 001A50: 0D0F 0400 	LD	ptrBF, #0400	;dp_B3 <- #0400
0034A4 | 001A52: 1810      	LD	pA0, #10		;pA0 <- #10
0034A6 | 001A53: B734      	MLD	ptrA4, ptrB3	;ACC = 0, X <- [p_A0++], Y <- dp_B0
0034A8 | 001A54: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
0034AA | 001A55: 97B4      	MPYA	ptrA4, ptrBB	;ACC += P, X <- [p_A0++], Y <- dp_B2
0034AC | 001A56: 97F4      	MPYA	ptrA4, ptrBF	;ACC += P, X <- [p_A0++], Y <- dp_B3
0034AE | 001A57: 97F0      	MPYA	ptrA0, ptrBF	;ACC += P, X <- [p_A0], Y <- dp_B3
0034B0 | 001A58: 9003      	SHL	ACC			;
0034B2 | 001A59: 9003      	SHL	ACC			;
0034B4 | 001A5A: 9003      	SHL	ACC			;
0034B6 | 001A5B: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
0034B8 | 001A5C: B734      	MLD	ptrA4, ptrB3	;ACC = 0, X <- [p_A0++], Y <- dp_B0
0034BA | 001A5D: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
0034BC | 001A5E: 97B4      	MPYA	ptrA4, ptrBB	;ACC += P, X <- [p_A0++], Y <- dp_B2
0034BE | 001A5F: 97F4      	MPYA	ptrA4, ptrBF	;ACC += P, X <- [p_A0++], Y <- dp_B3
0034C0 | 001A60: 97F0      	MPYA	ptrA0, ptrBF	;ACC += P, X <- [p_A0], Y <- dp_B3
0034C2 | 001A61: 9003      	SHL	ACC			;
0034C4 | 001A62: 9003      	SHL	ACC			;
0034C6 | 001A63: 9003      	SHL	ACC			;
0034C8 | 001A64: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
0034CA | 001A65: B734      	MLD	ptrA4, ptrB3	;ACC = 0, X <- [p_A0++], Y <- dp_B0
0034CC | 001A66: 9774      	MPYA	ptrA4, ptrB7	;ACC += P, X <- [p_A0++], Y <- dp_B1
0034CE | 001A67: 97B4      	MPYA	ptrA4, ptrBB	;ACC += P, X <- [p_A0++], Y <- dp_B2
0034D0 | 001A68: 97F4      	MPYA	ptrA4, ptrBF	;ACC += P, X <- [p_A0++], Y <- dp_B3
0034D2 | 001A69: 97F0      	MPYA	ptrA0, ptrBF	;ACC += P, X <- [p_A0], Y <- dp_B3
0034D4 | 001A6A: 9003      	SHL	ACC			;
0034D6 | 001A6B: 9003      	SHL	ACC			;
0034D8 | 001A6C: 9003      	SHL	ACC			;
0034DA | 001A6D: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
0034DC | 001A6E: 0065      	LD	r6, r5		;PC <- STACK

L_I00B8:
0034DE | 001A6F: 0239      	LD	r3, ptrA9		;AH <- [p_A1--!]
0034E0 | 001A70: 2710      	SUB	r3, RAMB[10]	;ACC -= RAMB[10]
0034E2 | 001A71: 671D      	CMP	r3, RAMB[1D]	;ACC == RAMB[1D]
0034E4 | 001A72: 4C70 00D5 	BRA	ns, 00D5		;PC <- 01AA
0034E8 | 001A74: 87F3      	ADD	r3, RAMB[F3]	;ACC += RAMB[F3]
0034EA | 001A75: 4A10      	LD	r1, (r3)		;X <- (AH)
0034EC | 001A76: 0229      	LD	r2, ptrA9		;Y <- [p_A1--!]
0034EE | 001A77: 0037      	LD	r3, r7		;AH <- P
0034F0 | 001A78: 9003      	SHL	ACC			;
0034F2 | 001A79: 9003      	SHL	ACC			;
0034F4 | 001A7A: 9003      	SHL	ACC			;
0034F6 | 001A7B: 9003      	SHL	ACC			;
0034F8 | 001A7C: 0023      	LD	r2, r3		;Y <- AH
0034FA | 001A7D: 9003      	SHL	ACC			;
0034FC | 001A7E: 9003      	SHL	ACC			;
0034FE | 001A7F: 8002      	ADD	r3, r2		;ACC += Y
003500 | 001A80: 043A      	LD	ptrAA, r3		;[p_A2--!] <- AH
003502 | 001A81: 0229      	LD	r2, ptrA9		;Y <- [p_A1--!]
003504 | 001A82: 0037      	LD	r3, r7		;AH <- P
003506 | 001A83: 9003      	SHL	ACC			;
003508 | 001A84: 9003      	SHL	ACC			;
00350A | 001A85: 9003      	SHL	ACC			;
00350C | 001A86: 9003      	SHL	ACC			;
00350E | 001A87: 9003      	SHL	ACC			;
003510 | 001A88: 9003      	SHL	ACC			;
003512 | 001A89: 043A      	LD	ptrAA, r3		;[p_A2--!] <- AH
003514 | 001A8A: 0065      	LD	r6, r5		;PC <- STACK
003516 | 001A8B: 0000      	LD	r0, r0		;R0 <- R0

L_I00D5:
003518 | 001A8C: 9002      	SHR	ACC			;
00351A | 001A8D: 9002      	SHR	ACC			;
00351C | 001A8E: 9002      	SHR	ACC			;
00351E | 001A8F: 9002      	SHR	ACC			;
003520 | 001A90: 9002      	SHR	ACC			;
003522 | 001A91: 87F3      	ADD	r3, RAMB[F3]	;ACC += RAMB[F3]
003524 | 001A92: 4A10      	LD	r1, (r3)		;X <- (AH)
003526 | 001A93: 0229      	LD	r2, ptrA9		;Y <- [p_A1--!]
003528 | 001A94: 0037      	LD	r3, r7		;AH <- P
00352A | 001A95: 9003      	SHL	ACC			;
00352C | 001A96: 0023      	LD	r2, r3		;Y <- AH
00352E | 001A97: 9002      	SHR	ACC			;
003530 | 001A98: 9002      	SHR	ACC			;
003532 | 001A99: 8002      	ADD	r3, r2		;ACC += Y
003534 | 001A9A: 043A      	LD	ptrAA, r3		;[p_A2--!] <- AH
003536 | 001A9B: 0229      	LD	r2, ptrA9		;Y <- [p_A1--!]
003538 | 001A9C: 0037      	LD	r3, r7		;AH <- P
00353A | 001A9D: 9003      	SHL	ACC			;
00353C | 001A9E: 043A      	LD	ptrAA, r3		;[p_A2--!] <- AH
00353E | 001A9F: 0065      	LD	r6, r5		;PC <- STACK
003540 | 001AA0: 0000      	LD	r0, r0		;R0 <- R0

L_I00EA:
003542 | 001AA1: 19EB      	LD	pA1, #EB		;pA1 <- #EB
003544 | 001AA2: 1A0F      	LD	pA2, #0F		;pA2 <- #0F
003546 | 001AA3: 4800 00B8 	CALL	00B8			;PC <- 0170
00354A | 001AA5: 4800 00B8 	CALL	00B8			;PC <- 0170
00354E | 001AA7: 4800 00B8 	CALL	00B8			;PC <- 0170
003552 | 001AA9: 4800 00B8 	CALL	00B8			;PC <- 0170
003556 | 001AAB: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
003558 | 001AAC: B840      	AND	r3, #40		;ACC &= #40
00355A | 001AAD: 4D50 00FC 	BRA	z, 00FC		;PC <- 01F8
00355E | 001AAF: 4800 01A5 	CALL	01A5			;PC <- 034A
003562 | 001AB1: 4C70 0126 	BRA	ns, 0126		;PC <- 024C
L_I00FC:
003566 | 001AB3: 4800 0160 	CALL	0160			;PC <- 02C0
00356A | 001AB5: 6711      	CMP	r3, RAMB[11]	;ACC == RAMB[11]
00356C | 001AB6: 4C70 0126 	BRA	ns, 0126		;PC <- 024C
003570 | 001AB8: A716      	AND	r3, RAMB[16]	;ACC &= RAMB[16]
003572 | 001AB9: 9003      	SHL	ACC			;
003574 | 001ABA: 9003      	SHL	ACC			;
003576 | 001ABB: 8714      	ADD	r3, RAMB[14]	;ACC += RAMB[14]
003578 | 001ABC: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
00357A | 001ABD: 00E3      	LD	rE, r3		;EXT6 <- AH
00357C | 001ABE: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
003580 | 001AC0: 0009      	LD	r0, r9		;R0 <- EXT1
003582 | 001AC1: 0039      	LD	r3, r9		;AH <- EXT1
003584 | 001AC2: 9801      	ADD	r3, #01		;ACC += #01
003586 | 001AC3: 671A      	CMP	r3, RAMB[1A]	;ACC == RAMB[1A]
003588 | 001AC4: 4C70 0126 	BRA	ns, 0126		;PC <- 024C
00358C | 001AC6: 02E7      	LD	rE, ptrA7		;EXT6 <- dp_A1
00358E | 001AC7: 000E      	LD	r0, rE		;R0 <- EXT6
003590 | 001AC8: 0090      	LD	r9, r0		;EXT1 <- R0
003592 | 001AC9: 0093      	LD	r9, r3		;EXT1 <- AH
003594 | 001ACA: 8207      	ADD	r3, ptrA7		;ACC += dp_A1
003596 | 001ACB: 00E3      	LD	rE, r3		;EXT6 <- AH
003598 | 001ACC: 000E      	LD	r0, rE		;R0 <- EXT6
00359A | 001ACD: 0090      	LD	r9, r0		;EXT1 <- R0
00359C | 001ACE: 0713      	LD	r3, B[13]		;AH <- B[13]
00359E | 001ACF: 0093      	LD	r9, r3		;EXT1 <- AH
0035A0 | 001AD0: 9809      	ADD	r3, #09		;ACC += #09
0035A2 | 001AD1: 0F13      	LD	RAMB[13], r3	;RAMB[13] <- AH
0035A4 | 001AD2: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
0035A6 | 001AD3: 0083      	LD	r8, r3		;EXT0 <- AH
0035A8 | 001AD4: 1908      	LD	pA1, #08		;pA1 <- #08
0035AA | 001AD5: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
0035AC | 001AD6: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
0035AE | 001AD7: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
0035B0 | 001AD8: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
0035B2 | 001AD9: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
0035B4 | 001ADA: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
0035B6 | 001ADB: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
0035B8 | 001ADC: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
L_I0126:
0035BA | 001ADD: 0065      	LD	r6, r5		;PC <- STACK

L_I0127:
0035BC | 001ADE: 19E8      	LD	pA1, #E8		;pA1 <- #E8
0035BE | 001ADF: 1A0D      	LD	pA2, #0D		;pA2 <- #0D
0035C0 | 001AE0: 4800 00B8 	CALL	00B8			;PC <- 0170			call L_I00B8
0035C4 | 001AE2: 4800 00B8 	CALL	00B8			;PC <- 0170			call L_I00B8
0035C8 | 001AE4: 4800 00B8 	CALL	00B8			;PC <- 0170			call L_I00B8
0035CC | 001AE6: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
0035CE | 001AE7: B840      	AND	r3, #40		;ACC &= #40
0035D0 | 001AE8: 4D50 0137 	BRA	z, 0137		;PC <- 026E
0035D4 | 001AEA: 4800 01A5 	CALL	01A5			;PC <- 034A			call L_I01A5
0035D8 | 001AEC: 4C70 015F 	BRA	ns, 015F		;PC <- 02BE
0035DC | 001AEE: 4800 0190 	CALL	0190			;PC <- 0320			call L_I0190
0035E0 | 001AF0: 6711      	CMP	r3, RAMB[11]	;ACC == RAMB[11]
0035E2 | 001AF1: 4C70 015F 	BRA	ns, 015F		;PC <- 02BE
0035E6 | 001AF3: A716      	AND	r3, RAMB[16]	;ACC &= RAMB[16]
0035E8 | 001AF4: 9003      	SHL	ACC			;
0035EA | 001AF5: 9003      	SHL	ACC			;
0035EC | 001AF6: 8714      	ADD	r3, RAMB[14]	;ACC += RAMB[14]
0035EE | 001AF7: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
0035F0 | 001AF8: 00E3      	LD	rE, r3		;EXT6 <- AH
0035F2 | 001AF9: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
0035F6 | 001AFB: 0009      	LD	r0, r9		;R0 <- EXT1
0035F8 | 001AFC: 0039      	LD	r3, r9		;AH <- EXT1
0035FA | 001AFD: 9801      	ADD	r3, #01		;ACC += #01
0035FC | 001AFE: 671A      	CMP	r3, RAMB[1A]	;ACC == RAMB[1A]
0035FE | 001AFF: 4C70 015F 	BRA	ns, 015F		;PC <- 02BE
003602 | 001B01: 02E7      	LD	rE, ptrA7		;EXT6 <- dp_A1
003604 | 001B02: 000E      	LD	r0, rE		;R0 <- EXT6
003606 | 001B03: 0090      	LD	r9, r0		;EXT1 <- R0
003608 | 001B04: 0093      	LD	r9, r3		;EXT1 <- AH
00360A | 001B05: 8207      	ADD	r3, ptrA7		;ACC += dp_A1
00360C | 001B06: 00E3      	LD	rE, r3		;EXT6 <- AH
00360E | 001B07: 000E      	LD	r0, rE		;R0 <- EXT6
003610 | 001B08: 0090      	LD	r9, r0		;EXT1 <- R0
003612 | 001B09: 0713      	LD	r3, B[13]		;AH <- B[13]
003614 | 001B0A: 0093      	LD	r9, r3		;EXT1 <- AH
003616 | 001B0B: 9807      	ADD	r3, #07		;ACC += #07
003618 | 001B0C: 0F13      	LD	RAMB[13], r3	;RAMB[13] <- AH
00361A | 001B0D: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
00361C | 001B0E: 0083      	LD	r8, r3		;EXT0 <- AH
00361E | 001B0F: 1908      	LD	pA1, #08		;pA1 <- #08
003620 | 001B10: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003622 | 001B11: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003624 | 001B12: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003626 | 001B13: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003628 | 001B14: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
00362A | 001B15: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
L_I015f:
00362C | 001B16: 0065      	LD	r6, r5		;PC <- STACK

L_I0160:
00362E | 001B17: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
003630 | 001B18: B807      	AND	r3, #07		;ACC &= #07
003632 | 001B19: 9838      	ADD	r3, #38		;ACC += #38
003634 | 001B1A: 1430      	LD	pA0, r3		;p_A0 <- AH
003636 | 001B1B: 0260      	LD	r6, ptrA0		;PC <- [p_A0]

003638 | 001B1C: 4800 016D 	CALL	016D			;PC <- 02DA
00363C | 001B1E: 8717      	ADD	r3, RAMB[17]	;ACC += RAMB[17]
00363E | 001B1F: 0065      	LD	r6, r5		;PC <- STACK
003640 | 001B20: 4800 0189 	CALL	0189			;PC <- 0312
003644 | 001B22: 8718      	ADD	r3, RAMB[18]	;ACC += RAMB[18]
003646 | 001B23: 0065      	LD	r6, r5		;PC <- STACK
003648 | 001B24: 06EB      	LD	r3, A[EB]		;AH <- A[EB]
00364A | 001B25: 66E8      	CMP	r3, RAMA[E8]	;ACC == RAMA[E8]
00364C | 001B26: 4C70 0172 	BRA	ns, 0172		;PC <- 02E4
003650 | 001B28: 06E8      	LD	r3, A[E8]		;AH <- A[E8]
003652 | 001B29: 66E5      	CMP	r3, RAMA[E5]	;ACC == RAMA[E5]
003654 | 001B2A: 4C70 0176 	BRA	ns, 0176		;PC <- 02EC
003658 | 001B2C: 06E5      	LD	r3, A[E5]		;AH <- A[E5]
00365A | 001B2D: 66E2      	CMP	r3, RAMA[E2]	;ACC == RAMA[E2]
00365C | 001B2E: 4C70 017A 	BRA	ns, 017A		;PC <- 02F4
003660 | 001B30: 06E2      	LD	r3, A[E2]		;AH <- A[E2]
003662 | 001B31: 0065      	LD	r6, r5		;PC <- STACK
003664 | 001B32: 06EB      	LD	r3, A[EB]		;AH <- A[EB]
003666 | 001B33: 66E8      	CMP	r3, RAMA[E8]	;ACC == RAMA[E8]
003668 | 001B34: 4D70 0180 	BRA	s, 0180		;PC <- 0300
00366C | 001B36: 06E8      	LD	r3, A[E8]		;AH <- A[E8]
00366E | 001B37: 66E5      	CMP	r3, RAMA[E5]	;ACC == RAMA[E5]
003670 | 001B38: 4D70 0184 	BRA	s, 0184		;PC <- 0308
003674 | 001B3A: 06E5      	LD	r3, A[E5]		;AH <- A[E5]
003676 | 001B3B: 66E2      	CMP	r3, RAMA[E2]	;ACC == RAMA[E2]
003678 | 001B3C: 4D70 0188 	BRA	s, 0188		;PC <- 0310
00367C | 001B3E: 06E2      	LD	r3, A[E2]		;AH <- A[E2]
00367E | 001B3F: 0065      	LD	r6, r5		;PC <- STACK
003680 | 001B40: 06E2      	LD	r3, A[E2]		;AH <- A[E2]
003682 | 001B41: 86E5      	ADD	r3, RAMA[E5]	;ACC += RAMA[E5]
003684 | 001B42: 86E8      	ADD	r3, RAMA[E8]	;ACC += RAMA[E8]
003686 | 001B43: 86EB      	ADD	r3, RAMA[EB]	;ACC += RAMA[EB]
003688 | 001B44: 9002      	SHR	ACC			;
00368A | 001B45: 9002      	SHR	ACC			;
00368C | 001B46: 0065      	LD	r6, r5		;PC <- STACK

L_I0190:
00368E | 001B47: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
003690 | 001B48: B807      	AND	r3, #07		;ACC &= #07
003692 | 001B49: 983E      	ADD	r3, #3E		;ACC += #3E
003694 | 001B4A: 1430      	LD	pA0, r3		;p_A0 <- AH
003696 | 001B4B: 0260      	LD	r6, ptrA0		;PC <- [p_A0]

003698 | 001B4C: 4800 019D 	CALL	019D			;PC <- 033A
00369C | 001B4E: 8717      	ADD	r3, RAMB[17]	;ACC += RAMB[17]
00369E | 001B4F: 0065      	LD	r6, r5		;PC <- STACK
0036A0 | 001B50: 4800 019D 	CALL	019D			;PC <- 033A
0036A4 | 001B52: 8718      	ADD	r3, RAMB[18]	;ACC += RAMB[18]
0036A6 | 001B53: 0065      	LD	r6, r5		;PC <- STACK
0036A8 | 001B54: 06E2      	LD	r3, A[E2]		;AH <- A[E2]
0036AA | 001B55: 86E5      	ADD	r3, RAMA[E5]	;ACC += RAMA[E5]
0036AC | 001B56: 86E8      	ADD	r3, RAMA[E8]	;ACC += RAMA[E8]
0036AE | 001B57: 0013      	LD	r1, r3		;X <- AH
0036B0 | 001B58: 0820 2AAA 	LD	r2, #2AAA		;Y <- #2AAA
0036B4 | 001B5A: 0037      	LD	r3, r7		;AH <- P
0036B6 | 001B5B: 0065      	LD	r6, r5		;PC <- STACK

L_I01A5:
0036B8 | 001B5C: 060A      	LD	r3, A[0A]		;AH <- A[0A]
0036BA | 001B5D: 260C      	SUB	r3, RAMA[0C]	;ACC -= RAMA[0C]
0036BC | 001B5E: 0013      	LD	r1, r3		;X <- AH
0036BE | 001B5F: 0609      	LD	r3, A[09]		;AH <- A[09]
0036C0 | 001B60: 260B      	SUB	r3, RAMA[0B]	;ACC -= RAMA[0B]
0036C2 | 001B61: 0023      	LD	r2, r3		;Y <- AH
0036C4 | 001B62: 060B      	LD	r3, A[0B]		;AH <- A[0B]
0036C6 | 001B63: 260D      	SUB	r3, RAMA[0D]	;ACC -= RAMA[0D]
0036C8 | 001B64: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
0036CA | 001B65: 0608      	LD	r3, A[08]		;AH <- A[08]
0036CC | 001B66: 260A      	SUB	r3, RAMA[0A]	;ACC -= RAMA[0A]
0036CE | 001B67: 0533      	LD	ptrB3, r3		;dp_B0 <- AH
0036D0 | 001B68: B800      	AND	r3, #00		;ACC &= #00
0036D2 | 001B69: 9733      	MPYA	ptrA3, ptrB3	;ACC += P, X <- dp_A0, Y <- dp_B0
0036D4 | 001B6A: 3733      	MPYS	ptrA3, ptrB3	;ACC -= P, X <- dp_A0, Y <- dp_B0
0036D6 | 001B6B: 0065      	LD	r6, r5		;PC <- STACK


0036D8 | 001B6C: 00E3      	LD	rE, r3		;EXT6 <- AH
0036DA | 001B6D: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
0036DE | 001B6F: 000C      	LD	r0, rC		;R0 <- EXT4
0036E0 | 001B70: 1810      	LD	pA0, #10		;pA0 <- #10
0036E2 | 001B71: 071C      	LD	r3, B[1C]		;AH <- B[1C]
0036E4 | 001B72: 04C4      	LD	ptrA4, rC		;[p_A0++] <- EXT4
0036E6 | 001B73: 3801      	SUB	r3, #01		;ACC -= #01
0036E8 | 001B74: 4C70 01BB 	BRA	ns, 01BB		;PC <- 0376
0036EC | 001B76: 001C      	LD	r1, rC		;X <- EXT4
0036EE | 001B77: 002C      	LD	r2, rC		;Y <- EXT4
0036F0 | 001B78: 0065      	LD	r6, r5		;PC <- STACK

L_I01C2:
0036F2 | 001B79: 1D02      	LD	pB1, #02		;pB1 <- #02
0036F4 | 001B7A: 4C00 01C6 	BRA	01C6			;PC <- 038C
0036F8 | 001B7C: 1D03      	LD	pB1, #03		;pB1 <- #03
0036FA | 001B7D: B800      	AND	r3, #00		;ACC &= #00
0036FC | 001B7E: 0EEF      	LD	RAMA[EF], r3	;RAMA[EF] <- AH
0036FE | 001B7F: 0EEE      	LD	RAMA[EE], r3	;RAMA[EE] <- AH
003700 | 001B80: 1C01      	LD	pB0, #01		;pB0 <- #01
003702 | 001B81: 18E0      	LD	pA0, #E0		;pA0 <- #E0+
L_I01CB:
003704 | 001B82: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
003706 | 001B83: 9007      	ABS	ACC			;
003708 | 001B84: 6712      	CMP	r3, RAMB[12]	;ACC == RAMB[12]
00370A | 001B85: 4D70 01D3 	BRA	s, 01D3		;PC <- 03A6
00370E | 001B87: 06EF      	LD	r3, A[EF]		;AH <- A[EF]
003710 | 001B88: D300      	OR	r3, pB0		;ACC |= pB0
003712 | 001B89: 0EEF      	LD	RAMA[EF], r3	;RAMA[EF] <- AH
003714 | 001B8A: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
003716 | 001B8B: 0230      	LD	r3, ptrA0		;AH <- [p_A0]
003718 | 001B8C: 6711      	CMP	r3, RAMB[11]	;ACC == RAMB[11]
00371A | 001B8D: 4D70 01DB 	BRA	s, 01DB		;PC <- 03B6
00371E | 001B8F: 06EF      	LD	r3, A[EF]		;AH <- A[EF]
003720 | 001B90: D300      	OR	r3, pB0		;ACC |= pB0
003722 | 001B91: 0EEF      	LD	RAMA[EF], r3	;RAMA[EF] <- AH
003724 | 001B92: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
003726 | 001B93: 66F4      	CMP	r3, RAMA[F4]	;ACC == RAMA[F4]
003728 | 001B94: 4C70 01E2 	BRA	ns, 01E2		;PC <- 03C4
00372C | 001B96: 06EE      	LD	r3, A[EE]		;AH <- A[EE]
00372E | 001B97: D300      	OR	r3, pB0		;ACC |= pB0
003730 | 001B98: 0EEE      	LD	RAMA[EE], r3	;RAMA[EE] <- AH
003732 | 001B99: 1330      	LD	r3, pB0		;AH <- p_B0
003734 | 001B9A: 9003      	SHL	ACC			;
003736 | 001B9B: 1530      	LD	pB0, r3		;p_B0 <- AH
003738 | 001B9C: 1331      	LD	r3, pB1		;AH <- p_B1
00373A | 001B9D: 3801      	SUB	r3, #01		;ACC -= #01
00373C | 001B9E: 1531      	LD	pB1, r3		;p_B1 <- AH
00373E | 001B9F: 4C70 01CB 	BRA	ns, 01CB		;PC <- 0396
003742 | 001BA1: 0065      	LD	r6, r5		;PC <- STACK

003744 | 001BA2: 06EE      	LD	r3, A[EE]		;AH <- A[EE]
003746 | 001BA3: 9820      	ADD	r3, #20		;ACC += #20
003748 | 001BA4: 1430      	LD	pA0, r3		;p_A0 <- AH
00374A | 001BA5: 0260      	LD	r6, ptrA0		;PC <- [p_A0]
00374C | 001BA6: 0065      	LD	r6, r5		;PC <- STACK

00374E | 001BA7: 1806      	LD	pA0, #06		;pA0 <- #06
003750 | 001BA8: 19E2      	LD	pA1, #E2		;pA1 <- #E2
003752 | 001BA9: 1AE5      	LD	pA2, #E5		;pA2 <- #E5
003754 | 001BAA: 4800 0338 	CALL	0338			;PC <- 0670
003758 | 001BAC: 18E2      	LD	pA0, #E2		;pA0 <- #E2
00375A | 001BAD: 19E2      	LD	pA1, #E2		;pA1 <- #E2
00375C | 001BAE: 1AEB      	LD	pA2, #EB		;pA2 <- #EB
00375E | 001BAF: 4800 0338 	CALL	0338			;PC <- 0670
003762 | 001BB1: 4800 00EA 	CALL	00EA			;PC <- 01D4			call L_I00EA
003766 | 001BB3: 06E3      	LD	r3, A[E3]		;AH <- A[E3]
003768 | 001BB4: 0EE6      	LD	RAMA[E6], r3	;RAMA[E6] <- AH
00376A | 001BB5: 06E4      	LD	r3, A[E4]		;AH <- A[E4]
00376C | 001BB6: 0EE7      	LD	RAMA[E7], r3	;RAMA[E7] <- AH
00376E | 001BB7: 06E5      	LD	r3, A[E5]		;AH <- A[E5]
003770 | 001BB8: 0EE8      	LD	RAMA[E8], r3	;RAMA[E8] <- AH
003772 | 001BB9: 0604      	LD	r3, A[04]		;AH <- A[04]
003774 | 001BBA: 0EE3      	LD	RAMA[E3], r3	;RAMA[E3] <- AH
003776 | 001BBB: 0605      	LD	r3, A[05]		;AH <- A[05]
003778 | 001BBC: 0EE4      	LD	RAMA[E4], r3	;RAMA[E4] <- AH
00377A | 001BBD: 0606      	LD	r3, A[06]		;AH <- A[06]
00377C | 001BBE: 0EE5      	LD	RAMA[E5], r3	;RAMA[E5] <- AH
00377E | 001BBF: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
003780 | 001BC0: D810      	OR	r3, #10		;ACC |= #10
003782 | 001BC1: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
003784 | 001BC2: 4C00 0127 	BRA	0127			;PC <- 024E

003788 | 001BC4: 1806      	LD	pA0, #06		;pA0 <- #06
00378A | 001BC5: 19E5      	LD	pA1, #E5		;pA1 <- #E5
00378C | 001BC6: 1AE8      	LD	pA2, #E8		;pA2 <- #E8
00378E | 001BC7: 4800 0338 	CALL	0338			;PC <- 0670
003792 | 001BC9: 18E5      	LD	pA0, #E5		;pA0 <- #E5
003794 | 001BCA: 19E5      	LD	pA1, #E5		;pA1 <- #E5
003796 | 001BCB: 1AE2      	LD	pA2, #E2		;pA2 <- #E2
003798 | 001BCC: 4800 0338 	CALL	0338			;PC <- 0670
00379C | 001BCE: 4800 00EA 	CALL	00EA			;PC <- 01D4			call L_I00EA
0037A0 | 001BD0: 06E3      	LD	r3, A[E3]		;AH <- A[E3]
0037A2 | 001BD1: 0EE0      	LD	RAMA[E0], r3	;RAMA[E0] <- AH
0037A4 | 001BD2: 06E4      	LD	r3, A[E4]		;AH <- A[E4]
0037A6 | 001BD3: 0EE1      	LD	RAMA[E1], r3	;RAMA[E1] <- AH
0037A8 | 001BD4: 06E5      	LD	r3, A[E5]		;AH <- A[E5]
0037AA | 001BD5: 0EE2      	LD	RAMA[E2], r3	;RAMA[E2] <- AH
0037AC | 001BD6: 0604      	LD	r3, A[04]		;AH <- A[04]
0037AE | 001BD7: 0EE3      	LD	RAMA[E3], r3	;RAMA[E3] <- AH
0037B0 | 001BD8: 0605      	LD	r3, A[05]		;AH <- A[05]
0037B2 | 001BD9: 0EE4      	LD	RAMA[E4], r3	;RAMA[E4] <- AH
0037B4 | 001BDA: 0606      	LD	r3, A[06]		;AH <- A[06]
0037B6 | 001BDB: 0EE5      	LD	RAMA[E5], r3	;RAMA[E5] <- AH
0037B8 | 001BDC: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
0037BA | 001BDD: D810      	OR	r3, #10		;ACC |= #10
0037BC | 001BDE: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
0037BE | 001BDF: 4C00 0127 	BRA	0127			;PC <- 024E

0037C2 | 001BE1: 18E5      	LD	pA0, #E5		;pA0 <- #E5
0037C4 | 001BE2: 19E5      	LD	pA1, #E5		;pA1 <- #E5
0037C6 | 001BE3: 1AE8      	LD	pA2, #E8		;pA2 <- #E8
0037C8 | 001BE4: 4800 0338 	CALL	0338			;PC <- 0670
0037CC | 001BE6: 18E2      	LD	pA0, #E2		;pA0 <- #E2
0037CE | 001BE7: 19E2      	LD	pA1, #E2		;pA1 <- #E2
0037D0 | 001BE8: 1AEB      	LD	pA2, #EB		;pA2 <- #EB
0037D2 | 001BE9: 4800 0338 	CALL	0338			;PC <- 0670
0037D6 | 001BEB: 4C00 00EA 	BRA	00EA			;PC <- 01D4			goto L_I00EA

0037DA | 001BED: 1806      	LD	pA0, #06		;pA0 <- #06
0037DC | 001BEE: 19E8      	LD	pA1, #E8		;pA1 <- #E8
0037DE | 001BEF: 1AEB      	LD	pA2, #EB		;pA2 <- #EB
0037E0 | 001BF0: 4800 0338 	CALL	0338			;PC <- 0670
0037E4 | 001BF2: 18E8      	LD	pA0, #E8		;pA0 <- #E8
0037E6 | 001BF3: 19E8      	LD	pA1, #E8		;pA1 <- #E8
0037E8 | 001BF4: 1AE5      	LD	pA2, #E5		;pA2 <- #E5
0037EA | 001BF5: 4800 0338 	CALL	0338			;PC <- 0670
0037EE | 001BF7: 4800 00EA 	CALL	00EA			;PC <- 01D4
0037F2 | 001BF9: 06E9      	LD	r3, A[E9]		;AH <- A[E9]
0037F4 | 001BFA: 0EE3      	LD	RAMA[E3], r3	;RAMA[E3] <- AH
0037F6 | 001BFB: 06EA      	LD	r3, A[EA]		;AH <- A[EA]
0037F8 | 001BFC: 0EE4      	LD	RAMA[E4], r3	;RAMA[E4] <- AH
0037FA | 001BFD: 06EB      	LD	r3, A[EB]		;AH <- A[EB]
0037FC | 001BFE: 0EE5      	LD	RAMA[E5], r3	;RAMA[E5] <- AH
0037FE | 001BFF: 0604      	LD	r3, A[04]		;AH <- A[04]
003800 | 001C00: 0EE0      	LD	RAMA[E0], r3	;RAMA[E0] <- AH
003802 | 001C01: 0605      	LD	r3, A[05]		;AH <- A[05]
003804 | 001C02: 0EE1      	LD	RAMA[E1], r3	;RAMA[E1] <- AH
003806 | 001C03: 0606      	LD	r3, A[06]		;AH <- A[06]
003808 | 001C04: 0EE2      	LD	RAMA[E2], r3	;RAMA[E2] <- AH
00380A | 001C05: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
00380C | 001C06: D810      	OR	r3, #10		;ACC |= #10
00380E | 001C07: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
003810 | 001C08: 4C00 0127 	BRA	0127			;PC <- 024E
003814 | 001C0A: 18E8      	LD	pA0, #E8		;pA0 <- #E8
003816 | 001C0B: 19E8      	LD	pA1, #E8		;pA1 <- #E8
003818 | 001C0C: 1AEB      	LD	pA2, #EB		;pA2 <- #EB
00381A | 001C0D: 4800 0338 	CALL	0338			;PC <- 0670
00381E | 001C0F: 18E5      	LD	pA0, #E5		;pA0 <- #E5
003820 | 001C10: 19E5      	LD	pA1, #E5		;pA1 <- #E5
003822 | 001C11: 1AE2      	LD	pA2, #E2		;pA2 <- #E2
003824 | 001C12: 4800 0338 	CALL	0338			;PC <- 0670
003828 | 001C14: 4C00 00EA 	BRA	00EA			;PC <- 01D4
00382C | 001C16: 18E5      	LD	pA0, #E5		;pA0 <- #E5
00382E | 001C17: 19E8      	LD	pA1, #E8		;pA1 <- #E8
003830 | 001C18: 1AEB      	LD	pA2, #EB		;pA2 <- #EB
003832 | 001C19: 4800 0338 	CALL	0338			;PC <- 0670
003836 | 001C1B: 18E2      	LD	pA0, #E2		;pA0 <- #E2
003838 | 001C1C: 19E2      	LD	pA1, #E2		;pA1 <- #E2
00383A | 001C1D: 1AEB      	LD	pA2, #EB		;pA2 <- #EB
00383C | 001C1E: 4800 0338 	CALL	0338			;PC <- 0670
003840 | 001C20: 06E9      	LD	r3, A[E9]		;AH <- A[E9]
003842 | 001C21: 0EE6      	LD	RAMA[E6], r3	;RAMA[E6] <- AH
003844 | 001C22: 06EA      	LD	r3, A[EA]		;AH <- A[EA]
003846 | 001C23: 0EE7      	LD	RAMA[E7], r3	;RAMA[E7] <- AH
003848 | 001C24: 06EB      	LD	r3, A[EB]		;AH <- A[EB]
00384A | 001C25: 0EE8      	LD	RAMA[E8], r3	;RAMA[E8] <- AH
00384C | 001C26: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
00384E | 001C27: D810      	OR	r3, #10		;ACC |= #10
003850 | 001C28: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
003852 | 001C29: 4C00 0127 	BRA	0127			;PC <- 024E
003856 | 001C2B: 1806      	LD	pA0, #06		;pA0 <- #06
003858 | 001C2C: 19EB      	LD	pA1, #EB		;pA1 <- #EB
00385A | 001C2D: 1AE2      	LD	pA2, #E2		;pA2 <- #E2
00385C | 001C2E: 4800 0338 	CALL	0338			;PC <- 0670
003860 | 001C30: 18EB      	LD	pA0, #EB		;pA0 <- #EB
003862 | 001C31: 19EB      	LD	pA1, #EB		;pA1 <- #EB
003864 | 001C32: 1AE8      	LD	pA2, #E8		;pA2 <- #E8
003866 | 001C33: 4800 0338 	CALL	0338			;PC <- 0670
00386A | 001C35: 4800 00EA 	CALL	00EA			;PC <- 01D4
00386E | 001C37: 06E9      	LD	r3, A[E9]		;AH <- A[E9]
003870 | 001C38: 0EE3      	LD	RAMA[E3], r3	;RAMA[E3] <- AH
003872 | 001C39: 06EA      	LD	r3, A[EA]		;AH <- A[EA]
003874 | 001C3A: 0EE4      	LD	RAMA[E4], r3	;RAMA[E4] <- AH
003876 | 001C3B: 06EB      	LD	r3, A[EB]		;AH <- A[EB]
003878 | 001C3C: 0EE5      	LD	RAMA[E5], r3	;RAMA[E5] <- AH
00387A | 001C3D: 0604      	LD	r3, A[04]		;AH <- A[04]
00387C | 001C3E: 0EE6      	LD	RAMA[E6], r3	;RAMA[E6] <- AH
00387E | 001C3F: 0605      	LD	r3, A[05]		;AH <- A[05]
003880 | 001C40: 0EE7      	LD	RAMA[E7], r3	;RAMA[E7] <- AH
003882 | 001C41: 0606      	LD	r3, A[06]		;AH <- A[06]
003884 | 001C42: 0EE8      	LD	RAMA[E8], r3	;RAMA[E8] <- AH
003886 | 001C43: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
003888 | 001C44: D810      	OR	r3, #10		;ACC |= #10
00388A | 001C45: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
00388C | 001C46: 4C00 0127 	BRA	0127			;PC <- 024E
003890 | 001C48: 18E2      	LD	pA0, #E2		;pA0 <- #E2
003892 | 001C49: 19E2      	LD	pA1, #E2		;pA1 <- #E2
003894 | 001C4A: 1AE5      	LD	pA2, #E5		;pA2 <- #E5
003896 | 001C4B: 4800 0338 	CALL	0338			;PC <- 0670
00389A | 001C4D: 18EB      	LD	pA0, #EB		;pA0 <- #EB
00389C | 001C4E: 19EB      	LD	pA1, #EB		;pA1 <- #EB
00389E | 001C4F: 1AE8      	LD	pA2, #E8		;pA2 <- #E8
0038A0 | 001C50: 4800 0338 	CALL	0338			;PC <- 0670
0038A4 | 001C52: 4C00 00EA 	BRA	00EA			;PC <- 01D4
0038A8 | 001C54: 18E5      	LD	pA0, #E5		;pA0 <- #E5
0038AA | 001C55: 19E5      	LD	pA1, #E5		;pA1 <- #E5
0038AC | 001C56: 1AE8      	LD	pA2, #E8		;pA2 <- #E8
0038AE | 001C57: 4800 0338 	CALL	0338			;PC <- 0670
0038B2 | 001C59: 18E2      	LD	pA0, #E2		;pA0 <- #E2
0038B4 | 001C5A: 19EB      	LD	pA1, #EB		;pA1 <- #EB
0038B6 | 001C5B: 1AE8      	LD	pA2, #E8		;pA2 <- #E8
0038B8 | 001C5C: 4800 0338 	CALL	0338			;PC <- 0670
0038BC | 001C5E: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
0038BE | 001C5F: D810      	OR	r3, #10		;ACC |= #10
0038C0 | 001C60: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
0038C2 | 001C61: 4C00 0127 	BRA	0127			;PC <- 024E
0038C6 | 001C63: 18EB      	LD	pA0, #EB		;pA0 <- #EB
0038C8 | 001C64: 19EB      	LD	pA1, #EB		;pA1 <- #EB
0038CA | 001C65: 1AE2      	LD	pA2, #E2		;pA2 <- #E2
0038CC | 001C66: 4800 0338 	CALL	0338			;PC <- 0670
0038D0 | 001C68: 18E8      	LD	pA0, #E8		;pA0 <- #E8
0038D2 | 001C69: 19E8      	LD	pA1, #E8		;pA1 <- #E8
0038D4 | 001C6A: 1AE5      	LD	pA2, #E5		;pA2 <- #E5
0038D6 | 001C6B: 4800 0338 	CALL	0338			;PC <- 0670
0038DA | 001C6D: 4C00 00EA 	BRA	00EA			;PC <- 01D4
0038DE | 001C6F: 18E2      	LD	pA0, #E2		;pA0 <- #E2
0038E0 | 001C70: 19E2      	LD	pA1, #E2		;pA1 <- #E2
0038E2 | 001C71: 1AE5      	LD	pA2, #E5		;pA2 <- #E5
0038E4 | 001C72: 4800 0338 	CALL	0338			;PC <- 0670
0038E8 | 001C74: 18E8      	LD	pA0, #E8		;pA0 <- #E8
0038EA | 001C75: 19E8      	LD	pA1, #E8		;pA1 <- #E8
0038EC | 001C76: 1AE5      	LD	pA2, #E5		;pA2 <- #E5
0038EE | 001C77: 4800 0338 	CALL	0338			;PC <- 0670
0038F2 | 001C79: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
0038F4 | 001C7A: D810      	OR	r3, #10		;ACC |= #10
0038F6 | 001C7B: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
0038F8 | 001C7C: 4C00 0127 	BRA	0127			;PC <- 024E
0038FC | 001C7E: 18E8      	LD	pA0, #E8		;pA0 <- #E8
0038FE | 001C7F: 19EB      	LD	pA1, #EB		;pA1 <- #EB
003900 | 001C80: 1AE2      	LD	pA2, #E2		;pA2 <- #E2
003902 | 001C81: 4800 0338 	CALL	0338			;PC <- 0670
003906 | 001C83: 18E5      	LD	pA0, #E5		;pA0 <- #E5
003908 | 001C84: 19E5      	LD	pA1, #E5		;pA1 <- #E5
00390A | 001C85: 1AE2      	LD	pA2, #E2		;pA2 <- #E2
00390C | 001C86: 4800 0338 	CALL	0338			;PC <- 0670
003910 | 001C88: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
003912 | 001C89: D810      	OR	r3, #10		;ACC |= #10
003914 | 001C8A: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
003916 | 001C8B: 4C00 0127 	BRA	0127			;PC <- 024E

L_I02D6:
00391A | 001C8D: 06EE      	LD	r3, A[EE]		;AH <- A[EE]
00391C | 001C8E: 9830      	ADD	r3, #30		;ACC += #30
00391E | 001C8F: 1430      	LD	pA0, r3		;p_A0 <- AH
003920 | 001C90: 0260      	LD	r6, ptrA0		;PC <- [p_A0]		L_I0127
003922 | 001C91: 0065      	LD	r6, r5		;PC <- STACK

003924 | 001C92: 18EB      	LD	pA0, #EB		;pA0 <- #EB
003926 | 001C93: 19E2      	LD	pA1, #E2		;pA1 <- #E2
003928 | 001C94: 1AE8      	LD	pA2, #E8		;pA2 <- #E8
00392A | 001C95: 4800 0338 	CALL	0338			;PC <- 0670
00392E | 001C97: 18E2      	LD	pA0, #E2		;pA0 <- #E2
003930 | 001C98: 19E2      	LD	pA1, #E2		;pA1 <- #E2
003932 | 001C99: 1AE5      	LD	pA2, #E5		;pA2 <- #E5
003934 | 001C9A: 4800 0338 	CALL	0338			;PC <- 0670
003938 | 001C9C: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
00393A | 001C9D: A719      	AND	r3, RAMB[19]	;ACC &= RAMB[19]
00393C | 001C9E: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
00393E | 001C9F: 4C00 00EA 	BRA	00EA			;PC <- 01D4
003942 | 001CA1: 1806      	LD	pA0, #06		;pA0 <- #06
003944 | 001CA2: 19E5      	LD	pA1, #E5		;pA1 <- #E5
003946 | 001CA3: 1AE8      	LD	pA2, #E8		;pA2 <- #E8
003948 | 001CA4: 4800 0338 	CALL	0338			;PC <- 0670
00394C | 001CA6: 18E5      	LD	pA0, #E5		;pA0 <- #E5
00394E | 001CA7: 19E5      	LD	pA1, #E5		;pA1 <- #E5
003950 | 001CA8: 1AE2      	LD	pA2, #E2		;pA2 <- #E2
003952 | 001CA9: 4800 0338 	CALL	0338			;PC <- 0670
003956 | 001CAB: 06E6      	LD	r3, A[E6]		;AH <- A[E6]
003958 | 001CAC: 0EE9      	LD	RAMA[E9], r3	;RAMA[E9] <- AH
00395A | 001CAD: 06E7      	LD	r3, A[E7]		;AH <- A[E7]
00395C | 001CAE: 0EEA      	LD	RAMA[EA], r3	;RAMA[EA] <- AH
00395E | 001CAF: 06E8      	LD	r3, A[E8]		;AH <- A[E8]
003960 | 001CB0: 0EEB      	LD	RAMA[EB], r3	;RAMA[EB] <- AH
003962 | 001CB1: 0604      	LD	r3, A[04]		;AH <- A[04]
003964 | 001CB2: 0EE6      	LD	RAMA[E6], r3	;RAMA[E6] <- AH
003966 | 001CB3: 0605      	LD	r3, A[05]		;AH <- A[05]
003968 | 001CB4: 0EE7      	LD	RAMA[E7], r3	;RAMA[E7] <- AH
00396A | 001CB5: 0606      	LD	r3, A[06]		;AH <- A[06]
00396C | 001CB6: 0EE8      	LD	RAMA[E8], r3	;RAMA[E8] <- AH
00396E | 001CB7: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
003970 | 001CB8: A719      	AND	r3, RAMB[19]	;ACC &= RAMB[19]
003972 | 001CB9: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
003974 | 001CBA: 4C00 00EA 	BRA	00EA			;PC <- 01D4
003978 | 001CBC: 18E5      	LD	pA0, #E5		;pA0 <- #E5
00397A | 001CBD: 19E5      	LD	pA1, #E5		;pA1 <- #E5
00397C | 001CBE: 1AE8      	LD	pA2, #E8		;pA2 <- #E8
00397E | 001CBF: 4800 0338 	CALL	0338			;PC <- 0670
003982 | 001CC1: 18E2      	LD	pA0, #E2		;pA0 <- #E2
003984 | 001CC2: 19E2      	LD	pA1, #E2		;pA1 <- #E2
003986 | 001CC3: 1AE8      	LD	pA2, #E8		;pA2 <- #E8
003988 | 001CC4: 4800 0338 	CALL	0338			;PC <- 0670
00398C | 001CC6: 4C00 0127 	BRA	0127			;PC <- 024E
003990 | 001CC8: 18EB      	LD	pA0, #EB		;pA0 <- #EB
003992 | 001CC9: 19E8      	LD	pA1, #E8		;pA1 <- #E8
003994 | 001CCA: 1AE2      	LD	pA2, #E2		;pA2 <- #E2
003996 | 001CCB: 4800 0338 	CALL	0338			;PC <- 0670
00399A | 001CCD: 18E8      	LD	pA0, #E8		;pA0 <- #E8
00399C | 001CCE: 19E8      	LD	pA1, #E8		;pA1 <- #E8
00399E | 001CCF: 1AE5      	LD	pA2, #E5		;pA2 <- #E5
0039A0 | 001CD0: 4800 0338 	CALL	0338			;PC <- 0670
0039A4 | 001CD2: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
0039A6 | 001CD3: A719      	AND	r3, RAMB[19]	;ACC &= RAMB[19]
0039A8 | 001CD4: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
0039AA | 001CD5: 4C00 00EA 	BRA	00EA			;PC <- 01D4
0039AE | 001CD7: 18E2      	LD	pA0, #E2		;pA0 <- #E2
0039B0 | 001CD8: 19E2      	LD	pA1, #E2		;pA1 <- #E2
0039B2 | 001CD9: 1AE5      	LD	pA2, #E5		;pA2 <- #E5
0039B4 | 001CDA: 4800 0338 	CALL	0338			;PC <- 0670
0039B8 | 001CDC: 18E8      	LD	pA0, #E8		;pA0 <- #E8
0039BA | 001CDD: 19E8      	LD	pA1, #E8		;pA1 <- #E8
0039BC | 001CDE: 1AE5      	LD	pA2, #E5		;pA2 <- #E5
0039BE | 001CDF: 4800 0338 	CALL	0338			;PC <- 0670
0039C2 | 001CE1: 4C00 0127 	BRA	0127			;PC <- 024E
0039C6 | 001CE3: 18E8      	LD	pA0, #E8		;pA0 <- #E8
0039C8 | 001CE4: 19E8      	LD	pA1, #E8		;pA1 <- #E8
0039CA | 001CE5: 1AE2      	LD	pA2, #E2		;pA2 <- #E2
0039CC | 001CE6: 4800 0338 	CALL	0338			;PC <- 0670
0039D0 | 001CE8: 18E5      	LD	pA0, #E5		;pA0 <- #E5
0039D2 | 001CE9: 19E5      	LD	pA1, #E5		;pA1 <- #E5
0039D4 | 001CEA: 1AE2      	LD	pA2, #E2		;pA2 <- #E2
0039D6 | 001CEB: 4800 0338 	CALL	0338			;PC <- 0670
0039DA | 001CED: 4C00 0127 	BRA	0127			;PC <- 024E
0039DE | 001CEF: 0232      	LD	r3, ptrA2		;AH <- [p_A2]
0039E0 | 001CF0: 2209      	SUB	r3, ptrA9		;ACC -= [p_A1--!]
0039E2 | 001CF1: 87F3      	ADD	r3, RAMB[F3]	;ACC += RAMB[F3]
0039E4 | 001CF2: 4A10      	LD	r1, (r3)		;X <- (AH)
0039E6 | 001CF3: 06F4      	LD	r3, A[F4]		;AH <- A[F4]
0039E8 | 001CF4: 220A      	SUB	r3, ptrAA		;ACC -= [p_A2--!]
0039EA | 001CF5: 0023      	LD	r2, r3		;Y <- AH
0039EC | 001CF6: 0037      	LD	r3, r7		;AH <- P
0039EE | 001CF7: 1D00      	LD	pB1, #00		;pB1 <- #00
0039F0 | 001CF8: A003      	AND	r3, r3		;ACC &= AH
0039F2 | 001CF9: 4C70 0346 	BRA	ns, 0346		;PC <- 068C
0039F6 | 001CFB: 1D01      	LD	pB1, #01		;pB1 <- #01
0039F8 | 001CFC: 9006      	NEG	ACC			;
0039FA | 001CFD: 9003      	SHL	ACC			;
0039FC | 001CFE: 0533      	LD	ptrB3, r3		;dp_B0 <- AH
0039FE | 001CFF: 07F1      	LD	r3, B[F1]		;AH <- B[F1]
003A00 | 001D00: 9002      	SHR	ACC			;
003A02 | 001D01: 05F7      	LD	ptrB7, rF		;dp_B1 <- AL
003A04 | 001D02: 023A      	LD	r3, ptrAA		;AH <- [p_A2--!]
003A06 | 001D03: 2209      	SUB	r3, ptrA9		;ACC -= [p_A1--!]
003A08 | 001D04: 0437      	LD	ptrA7, r3		;dp_A1 <- AH
003A0A | 001D05: 0236      	LD	r3, ptrA6		;AH <- [p_A2++]
003A0C | 001D06: 2205      	SUB	r3, ptrA5		;ACC -= [p_A1++]
003A0E | 001D07: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
003A10 | 001D08: 06F4      	LD	r3, A[F4]		;AH <- A[F4]
003A12 | 001D09: 0438      	LD	ptrA8, r3		;[p_A0--!] <- AH
003A14 | 001D0A: B737      	MLD	ptrA7, ptrB3	;ACC = 0, X <- dp_A1, Y <- dp_B0
003A16 | 001D0B: 9777      	MPYA	ptrA7, ptrB7	;ACC += P, X <- dp_A1, Y <- dp_B1
003A18 | 001D0C: 04FF      	LD	ptrAF, rF		;dp_A3 <- AL
003A1A | 001D0D: B800      	AND	r3, #00		;ACC &= #00
003A1C | 001D0E: 023F      	LD	r3, ptrAF		;AH <- dp_A3
003A1E | 001D0F: 9002      	SHR	ACC			;
003A20 | 001D10: 8007      	ADD	r3, r7		;ACC += P
003A22 | 001D11: 9002      	SHR	ACC			;
003A24 | 001D12: 0013      	LD	r1, r3		;X <- AH
003A26 | 001D13: 002F      	LD	r2, rF		;Y <- AL
003A28 | 001D14: 1331      	LD	r3, pB1		;AH <- p_B1
003A2A | 001D15: A000      	AND	r3, r0		;ACC &= R0
003A2C | 001D16: 0031      	LD	r3, r1		;AH <- X
003A2E | 001D17: 00F2      	LD	rF, r2		;AL <- Y
003A30 | 001D18: 9056      	NEG	nz, ACC		;
003A32 | 001D19: 820A      	ADD	r3, ptrAA		;ACC += [p_A2--!]
003A34 | 001D1A: 0438      	LD	ptrA8, r3		;[p_A0--!] <- AH
003A36 | 001D1B: B733      	MLD	ptrA3, ptrB3	;ACC = 0, X <- dp_A0, Y <- dp_B0
003A38 | 001D1C: 9773      	MPYA	ptrA3, ptrB7	;ACC += P, X <- dp_A0, Y <- dp_B1
003A3A | 001D1D: 04FF      	LD	ptrAF, rF		;dp_A3 <- AL
003A3C | 001D1E: B800      	AND	r3, #00		;ACC &= #00
003A3E | 001D1F: 023F      	LD	r3, ptrAF		;AH <- dp_A3
003A40 | 001D20: 9002      	SHR	ACC			;
003A42 | 001D21: 8007      	ADD	r3, r7		;ACC += P
003A44 | 001D22: 9002      	SHR	ACC			;
003A46 | 001D23: 0013      	LD	r1, r3		;X <- AH
003A48 | 001D24: 002F      	LD	r2, rF		;Y <- AL
003A4A | 001D25: 1331      	LD	r3, pB1		;AH <- p_B1
003A4C | 001D26: A000      	AND	r3, r0		;ACC &= R0
003A4E | 001D27: 0031      	LD	r3, r1		;AH <- X
003A50 | 001D28: 00F2      	LD	rF, r2		;AL <- Y
003A52 | 001D29: 9056      	NEG	nz, ACC		;
003A54 | 001D2A: 820A      	ADD	r3, ptrAA		;ACC += [p_A2--!]
003A56 | 001D2B: 0438      	LD	ptrA8, r3		;[p_A0--!] <- AH
003A58 | 001D2C: 0065      	LD	r6, r5		;PC <- STACK
003A5A | 001D2D: 001F      	LD	r1, rF		;X <- AL
003A5C | 001D2E: 00E1      	LD	rE, r1		;EXT6 <- X
003A5E | 001D2F: 00E3      	LD	rE, r3		;EXT6 <- AH
003A60 | 001D30: 0008      	LD	r0, r8		;R0 <- EXT0
003A62 | 001D31: 0038      	LD	r3, r8		;AH <- EXT0
003A64 | 001D32: 0EED      	LD	RAMA[ED], r3	;RAMA[ED] <- AH
003A66 | 001D33: 9801      	ADD	r3, #01		;ACC += #01
003A68 | 001D34: 87E3      	ADD	r3, RAMB[E3]	;ACC += RAMB[E3]
003A6A | 001D35: 0FE3      	LD	RAMB[E3], r3	;RAMB[E3] <- AH
003A6C | 001D36: 0038      	LD	r3, r8		;AH <- EXT0
003A6E | 001D37: 0EEC      	LD	RAMA[EC], r3	;RAMA[EC] <- AH
003A70 | 001D38: 19E0      	LD	pA1, #E0		;pA1 <- #E0
003A72 | 001D39: 4800 0096 	CALL	0096			;PC <- 012C
003A76 | 001D3B: 4800 0096 	CALL	0096			;PC <- 012C
003A7A | 001D3D: 4800 0096 	CALL	0096			;PC <- 012C
003A7E | 001D3F: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
003A80 | 001D40: B810      	AND	r3, #10		;ACC &= #10
003A82 | 001D41: 4C50 0396 	BRA	nz, 0396		;PC <- 072C
003A86 | 001D43: 4800 0096 	CALL	0096			;PC <- 012C
003A8A | 001D45: 4800 039E 	CALL	039E			;PC <- 073C
003A8E | 001D47: 06ED      	LD	r3, A[ED]		;AH <- A[ED]
003A90 | 001D48: 3801      	SUB	r3, #01		;ACC -= #01
003A92 | 001D49: 0EED      	LD	RAMA[ED], r3	;RAMA[ED] <- AH
003A94 | 001D4A: 4C70 037F 	BRA	ns, 037F		;PC <- 06FE
003A98 | 001D4C: 0065      	LD	r6, r5		;PC <- STACK
003A9A | 001D4D: 4800 03B4 	CALL	03B4			;PC <- 0768
003A9E | 001D4F: 06ED      	LD	r3, A[ED]		;AH <- A[ED]
003AA0 | 001D50: 3801      	SUB	r3, #01		;ACC -= #01
003AA2 | 001D51: 0EED      	LD	RAMA[ED], r3	;RAMA[ED] <- AH
003AA4 | 001D52: 4C70 037F 	BRA	ns, 037F		;PC <- 06FE
003AA8 | 001D54: 0065      	LD	r6, r5		;PC <- STACK
003AAA | 001D55: 19EB      	LD	pA1, #EB		;pA1 <- #EB
003AAC | 001D56: 1A0F      	LD	pA2, #0F		;pA2 <- #0F
003AAE | 001D57: 4800 00B8 	CALL	00B8			;PC <- 0170
003AB2 | 001D59: 4800 00B8 	CALL	00B8			;PC <- 0170
003AB6 | 001D5B: 4800 00B8 	CALL	00B8			;PC <- 0170
003ABA | 001D5D: 4800 00B8 	CALL	00B8			;PC <- 0170
003ABE | 001D5F: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
003AC0 | 001D60: 0083      	LD	r8, r3		;EXT0 <- AH
003AC2 | 001D61: 1908      	LD	pA1, #08		;pA1 <- #08
003AC4 | 001D62: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003AC6 | 001D63: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003AC8 | 001D64: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003ACA | 001D65: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003ACC | 001D66: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003ACE | 001D67: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003AD0 | 001D68: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003AD2 | 001D69: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003AD4 | 001D6A: 0065      	LD	r6, r5		;PC <- STACK
003AD6 | 001D6B: 19E8      	LD	pA1, #E8		;pA1 <- #E8
003AD8 | 001D6C: 1A0D      	LD	pA2, #0D		;pA2 <- #0D
003ADA | 001D6D: 4800 00B8 	CALL	00B8			;PC <- 0170
003ADE | 001D6F: 4800 00B8 	CALL	00B8			;PC <- 0170
003AE2 | 001D71: 4800 00B8 	CALL	00B8			;PC <- 0170
003AE6 | 001D73: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
003AE8 | 001D74: 0083      	LD	r8, r3		;EXT0 <- AH
003AEA | 001D75: 1908      	LD	pA1, #08		;pA1 <- #08
003AEC | 001D76: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003AEE | 001D77: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003AF0 | 001D78: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003AF2 | 001D79: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003AF4 | 001D7A: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003AF6 | 001D7B: 0285      	LD	r8, ptrA5		;EXT0 <- [p_A1++]
003AF8 | 001D7C: 0065      	LD	r6, r5		;PC <- STACK

L_1DBE:
003B7C | 001DBE: 08E0 803D 	LD	rE, #803D		;EXT6 <- #803D
003B80 | 001DC0: 08E0 101C 	LD	rE, #101C		;EXT6 <- #101C
003B84 | 001DC2: 00C0      	LD	rC, r0		;EXT4 <- R0
003B86 | 001DC3: 00C3      	LD	rC, r3		;EXT4 <- AH
003B88 | 001DC4: 00C3      	LD	rC, r3		;EXT4 <- AH
003B8A | 001DC5: 00C3      	LD	rC, r3		;EXT4 <- AH
003B8C | 001DC6: 08E0 8047 	LD	rE, #8047		;EXT6 <- #8047
003B90 | 001DC8: 08E0 101C 	LD	rE, #101C		;EXT6 <- #101C
003B94 | 001DCA: 00C0      	LD	rC, r0		;EXT4 <- R0
003B96 | 001DCB: 00C3      	LD	rC, r3		;EXT4 <- AH
003B98 | 001DCC: 0065      	LD	r6, r5		;PC <- STACK

003B9A | 001DCD: 08E0 8038 	LD	rE, #8038		;EXT6 <- #8038
003B9E | 001DCF: 08E0 081C 	LD	rE, #081C		;EXT6 <- #081C
003BA2 | 001DD1: 00C0      	LD	rC, r0		;EXT4 <- R0
003BA4 | 001DD2: 08C0 B880 	LD	rC, #B880		;EXT4 <- #B880
003BA8 | 001DD4: 08C0 4C50 	LD	rC, #4C50		;EXT4 <- #4C50
003BAC | 001DD6: 08C0 0060 	LD	rC, #0060		;EXT4 <- #0060
003BB0 | 001DD8: 0065      	LD	r6, r5		;PC <- STACK

003BB2 | 001DD9: 08E0 7F00 	LD	rE, #7F00		;EXT6 <- #7F00
003BB6 | 001DDB: 08E0 0018 	LD	rE, #0018		;EXT6 <- #0018
003BBA | 001DDD: 000C      	LD	r0, rC		;R0 <- EXT4
003BBC | 001DDE: 003C      	LD	r3, rC		;AH <- EXT4
003BBE | 001DDF: A000      	AND	r3, r0		;ACC &= R0
003BC0 | 001DE0: 4D50 1E01 	BRA	z, 1E01		;PC <- 3C02
003BC4 | 001DE2: 08E0 80D2 	LD	rE, #80D2		;EXT6 <- #80D2
003BC8 | 001DE4: 08E0 081C 	LD	rE, #081C		;EXT6 <- #081C
003BCC | 001DE6: 00C0      	LD	rC, r0		;EXT4 <- R0
003BCE | 001DE7: 08C0 9006 	LD	rC, #9006		;EXT4 <- #9006
003BD2 | 001DE9: 08C0 043A 	LD	rC, #043A		;EXT4 <- #043A
003BD6 | 001DEB: 08C0 0065 	LD	rC, #0065		;EXT4 <- #0065
003BDA | 001DED: 08E0 80E7 	LD	rE, #80E7		;EXT6 <- #80E7
003BDE | 001DEF: 08E0 081C 	LD	rE, #081C		;EXT6 <- #081C
003BE2 | 001DF1: 00C0      	LD	rC, r0		;EXT4 <- R0
003BE4 | 001DF2: 08C0 9006 	LD	rC, #9006		;EXT4 <- #9006
003BE8 | 001DF4: 08C0 043A 	LD	rC, #043A		;EXT4 <- #043A
003BEC | 001DF6: 08C0 0065 	LD	rC, #0065		;EXT4 <- #0065
003BF0 | 001DF8: 08E0 81B2 	LD	rE, #81B2		;EXT6 <- #81B2
003BF4 | 001DFA: 08E0 081C 	LD	rE, #081C		;EXT6 <- #081C
003BF8 | 001DFC: 00C0      	LD	rC, r0		;EXT4 <- R0
003BFA | 001DFD: 08C0 3733 	LD	rC, #3733		;EXT4 <- #3733
003BFE | 001DFF: 08C0 9733 	LD	rC, #9733		;EXT4 <- #9733
003C02 | 001E01: 0065      	LD	r6, r5		;PC <- STACK

003C04 | 001E02: 08E0 7F09 	LD	rE, #7F09		;EXT6 <- #7F09
003C08 | 001E04: 08E0 0018 	LD	rE, #0018		;EXT6 <- #0018
003C0C | 001E06: 000C      	LD	r0, rC		;R0 <- EXT4
003C0E | 001E07: 003C      	LD	r3, rC		;AH <- EXT4
003C10 | 001E08: 0065      	LD	r6, r5		;PC <- STACK

L_1E09:
003C12 | 001E09: 1C00      	LD	pB0, #00		;pB0 <- #00
003C14 | 001E0A: 0830 003F 	LD	r3, #003F		;AH <- #003F
003C18 | 001E0C: 0810 0000 	LD	r1, #0000		;X <- #0000
003C1C | 001E0E: 0514      	LD	ptrB4, r1		;[p_B0++] <- X
003C1E | 001E0F: 3801      	SUB	r3, #01		;ACC -= #01
003C20 | 001E10: 4C70 1E0E 	BRA	ns, 1E0E		;PC <- 3C1C
003C24 | 001E12: 08E0 7F02 	LD	rE, #7F02		;EXT6 <- #7F02
003C28 | 001E14: 08E0 0018 	LD	rE, #0018		;EXT6 <- #0018
003C2C | 001E16: 000C      	LD	r0, rC		;R0 <- EXT4
003C2E | 001E17: 003C      	LD	r3, rC		;AH <- EXT4
003C30 | 001E18: 0EF6      	LD	RAMA[F6], r3	;RAMA[F6] <- AH
003C32 | 001E19: 1975      	LD	pA1, #75		;pA1 <- #75
003C34 | 001E1A: 0C05 0000 	LD	ptrA5, #0000	;[p_A1++] <- #0000
003C38 | 001E1C: 07E2      	LD	r3, B[E2]		;AH <- B[E2]
003C3A | 001E1D: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
003C3C | 001E1E: 9801      	ADD	r3, #01		;ACC += #01
003C3E | 001E1F: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
003C40 | 001E20: 3802      	SUB	r3, #02		;ACC -= #02
003C42 | 001E21: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
003C44 | 001E22: 9801      	ADD	r3, #01		;ACC += #01
003C46 | 001E23: 9002      	SHR	ACC			;
003C48 | 001E24: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
003C4A | 001E25: 18C0      	LD	pA0, #C0		;pA0 <- #C0
003C4C | 001E26: 0C03 1E4E 	LD	ptrA3, #1E4E	;dp_A0 <- #1E4E
003C50 | 001E28: 0830 0027 	LD	r3, #0027		;AH <- #0027
003C54 | 001E2A: 0A13      	LD	r1, *ptrA3		;X <- (dp_A0++)
003C56 | 001E2B: 0414      	LD	ptrA4, r1		;[p_A0++] <- X
003C58 | 001E2C: 3801      	SUB	r3, #01		;ACC -= #01
003C5A | 001E2D: 4C70 1E2A 	BRA	ns, 1E2A		;PC <- 3C54
003C5E | 001E2F: 18E8      	LD	pA0, #E8		;pA0 <- #E8
003C60 | 001E30: 0C04 FFF8 	LD	ptrA4, #FFF8	;[p_A0++] <- #FFF8
003C64 | 001E32: 0C04 8000 	LD	ptrA4, #8000	;[p_A0++] <- #8000
003C68 | 001E34: 0C04 0078 	LD	ptrA4, #0078	;[p_A0++] <- #0078
003C6C | 001E36: 0C04 0800 	LD	ptrA4, #0800	;[p_A0++] <- #0800
003C70 | 001E38: 0C04 4418 	LD	ptrA4, #4418	;[p_A0++] <- #4418
003C74 | 001E3A: 0C04 4018 	LD	ptrA4, #4018	;[p_A0++] <- #4018
003C78 | 001E3C: 0C04 0100 	LD	ptrA4, #0100	;[p_A0++] <- #0100
003C7C | 001E3E: 18B0      	LD	pA0, #B0		;pA0 <- #B0
003C7E | 001E3F: 0C04 03E2 	LD	ptrA4, #03E2	;[p_A0++] <- #03E2
003C82 | 001E41: 0810 0002 	LD	r1, #0002		;X <- #0002
003C86 | 001E43: 0830 000E 	LD	r3, #000E		;AH <- #000E
003C8A | 001E45: 0414      	LD	ptrA4, r1		;[p_A0++] <- X
003C8C | 001E46: 3801      	SUB	r3, #01		;ACC -= #01
003C8E | 001E47: 4C70 1E45 	BRA	ns, 1E45		;PC <- 3C8A
003C92 | 001E49: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
003C94 | 001E4A: 1531      	LD	pB1, r3		;p_B1 <- AH
003C96 | 001E4B: 9801      	ADD	r3, #01		;ACC += #01
003C98 | 001E4C: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
003C9A | 001E4D: 0361      	LD	r6, ptrB1		;PC <- [p_B1]

L_1E4E:
003C9C | 001E4E: FFFF
003C9E | 001E4F: 0FFF
003CA0 | 001E50: 00FF
003CA2 | 001E51: 000F
003CA4 | 001E52: 0000
003CA6 | 001E53: F000      	
003CA8 | 001E54: FF00	
003CAA | 001E55: FFF0	
003CAC | 001E56: F000      	
003CAE | 001E57: 0000
003CB0 | 001E58: 0F00
003CB2 | 001E59: 0000
003CB4 | 001E5A: 00F0
003CB6 | 001E5B: 0000
003CB8 | 001E5C: 000F
003CBA | 001E5D: 0000
003CBC | 001E5E: FF00
003CBE | 001E5F: 0000
003CC0 | 001E60: 0FF0
003CC2 | 001E61: 0000
003CC4 | 001E62: 00FF
003CC6 | 001E63: 0000
003CC8 | 001E64: 000F
003CCA | 001E65: F000
003CCC | 001E66: FFF0
003CCE | 001E67: 0000
003CD0 | 001E68: 0FFF
003CD2 | 001E69: 0000
003CD4 | 001E6A: 00FF
003CD6 | 001E6B: F000      	
003CD8 | 001E6C: 000F
003CDA | 001E6D: FF00
003CDC | 001E6E: FFFF
003CDE | 001E6F: 0000
003CE0 | 001E70: 0FFF
003CE2 | 001E71: F000
003CE4 | 001E72: 00FF
003CE6 | 001E73: FF00
003CE8 | 001E74: 000F
003CEA | 001E75: FFF0

003CEC | 001E76: 08E0 6000 	LD	rE, #6000		;EXT6 <- #6000
003CF0 | 001E78: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
003CF4 | 001E7A: 000C      	LD	r0, rC		;R0 <- EXT4
003CF6 | 001E7B: 4C00 03A3 	BRA	03A3			;PC <- 0746

L_1E7D:
003CFA | 001E7D: 0830 0080 	LD	r3, #0080		;AH <- #0080
003CFE | 001E7F: 0EFD      	LD	RAMA[FD], r3	;RAMA[FD] <- AH
003D00 | 001E80: 08E0 FF80 	LD	rE, #FF80		;EXT6 <- #FF80
003D04 | 001E82: 08E0 B818 	LD	rE, #B818		;EXT6 <- #B818
003D08 | 001E84: 0008      	LD	r0, r8		;R0 <- EXT0
003D0A | 001E85: 08E0 0080 	LD	rE, #0080		;EXT6 <- #0080
003D0E | 001E87: 000F      	LD	r0, rF		;R0 <- AL
003D10 | 001E88: 0830 00FF 	LD	r3, #00FF		;AH <- #00FF
003D14 | 001E8A: 0EFA      	LD	RAMA[FA], r3	;RAMA[FA] <- AH
003D16 | 001E8B: 0830 FF81 	LD	r3, #FF81		;AH <- #FF81
003D1A | 001E8D: 0EFB      	LD	RAMA[FB], r3	;RAMA[FB] <- AH
003D1C | 001E8E: 4C00 037C 	BRA	037C			;PC <- 06F8


003D20 | 001E90: 08E0 6000 	LD	rE, #6000		;EXT6 <- #6000
003D24 | 001E92: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
003D28 | 001E94: 000C      	LD	r0, rC		;R0 <- EXT4
003D2A | 001E95: 4C00 03A3 	BRA	03A3			;PC <- 0746

003D2E | 001E97: 0830 0010 	LD	r3, #0010		;AH <- #0010
003D32 | 001E99: 0EFD      	LD	RAMA[FD], r3	;RAMA[FD] <- AH
003D34 | 001E9A: 08E0 9FF0 	LD	rE, #9FF0		;EXT6 <- #9FF0
003D38 | 001E9C: 08E0 A818 	LD	rE, #A818		;EXT6 <- #A818
003D3C | 001E9E: 0008      	LD	r0, r8		;R0 <- EXT0
003D3E | 001E9F: 0830 01FF 	LD	r3, #01FF		;AH <- #01FF
003D42 | 001EA1: 0EFA      	LD	RAMA[FA], r3	;RAMA[FA] <- AH
003D44 | 001EA2: 0830 9FF1 	LD	r3, #9FF1		;AH <- #9FF1
003D48 | 001EA4: 0EFB      	LD	RAMA[FB], r3	;RAMA[FB] <- AH
003D4A | 001EA5: 4C00 037C 	BRA	037C			;PC <- 06F8

003D4E | 001EA7: 0830 0010 	LD	r3, #0010		;AH <- #0010
003D52 | 001EA9: 0EFD      	LD	RAMA[FD], r3	;RAMA[FD] <- AH
003D54 | 001EAA: 08E0 FFF0 	LD	rE, #FFF0		;EXT6 <- #FFF0
003D58 | 001EAC: 08E0 A818 	LD	rE, #A818		;EXT6 <- #A818
003D5C | 001EAE: 0008      	LD	r0, r8		;R0 <- EXT0
003D5E | 001EAF: 0830 07FF 	LD	r3, #07FF		;AH <- #07FF
003D62 | 001EB1: 0EFA      	LD	RAMA[FA], r3	;RAMA[FA] <- AH
003D64 | 001EB2: 0830 FFF1 	LD	r3, #FFF1		;AH <- #FFF1
003D68 | 001EB4: 0EFB      	LD	RAMA[FB], r3	;RAMA[FB] <- AH
003D6A | 001EB5: 4C00 037C 	BRA	037C			;PC <- 06F8


;*********************IRAM************************************************
L_1EB7:
003D6E | 001EB7: 8000      					;start address
003D70 | 001EB8: 03B1      					;size
L_I0000:
003D72 | 001EB9: 06F0      	LD	r3, A[F0]		;AH <- A[F0]
003D74 | 001EBA: B807      	AND	r3, #07		;ACC &= #07
003D76 | 001EBB: 9002      	SHR	ACC			;
003D78 | 001EBC: 9002      	SHR	ACC			;
003D7A | 001EBD: 0EF7      	LD	RAMA[F7], r3	;RAMA[F7] <- AH
003D7C | 001EBE: 06F0      	LD	r3, A[F0]		;AH <- A[F0]
003D7E | 001EBF: A6E8      	AND	r3, RAMA[E8]	;ACC &= RAMA[E8]
003D80 | 001EC0: 9003      	SHL	ACC			;
003D82 | 001EC1: 9003      	SHL	ACC			;
003D84 | 001EC2: 86F7      	ADD	r3, RAMA[F7]	;ACC += RAMA[F7]
003D86 | 001EC3: 86F3      	ADD	r3, RAMA[F3]	;ACC += RAMA[F3]
003D88 | 001EC4: 00E3      	LD	rE, r3		;EXT6 <- AH
003D8A | 001EC5: 000E      	LD	r0, rE		;R0 <- EXT6
003D8C | 001EC6: 00C0      	LD	rC, r0		;EXT4 <- R0
003D8E | 001EC7: 06F2      	LD	r3, A[F2]		;AH <- A[F2]
003D90 | 001EC8: 9801      	ADD	r3, #01		;ACC += #01
003D92 | 001EC9: 0EF2      	LD	RAMA[F2], r3	;RAMA[F2] <- AH
003D94 | 001ECA: B80F      	AND	r3, #0F		;ACC &= #0F
003D96 | 001ECB: 98B0      	ADD	r3, #B0		;ACC += #B0
003D98 | 001ECC: 1432      	LD	pA2, r3		;p_A2 <- AH
003D9A | 001ECD: 0232      	LD	r3, ptrA2		;AH <- [p_A2]
003D9C | 001ECE: 86F3      	ADD	r3, RAMA[F3]	;ACC += RAMA[F3]
003D9E | 001ECF: 0EF3      	LD	RAMA[F3], r3	;RAMA[F3] <- AH
003DA0 | 001ED0: 036F      	LD	r6, ptrBF		;PC <- dp_B3
003DA2 | 001ED1: 02E3      	LD	rE, ptrA3		;EXT6 <- dp_A0
003DA4 | 001ED2: 04E3      	LD	ptrA3, rE		;dp_A0 <- EXT6
003DA6 | 001ED3: 000F      	LD	r0, rF		;R0 <- AL
003DA8 | 001ED4: 06F1      	LD	r3, A[F1]		;AH <- A[F1]
003DAA | 001ED5: 26F0      	SUB	r3, RAMA[F0]	;ACC -= RAMA[F0]
003DAC | 001ED6: 7804      	CMP	r3, #04		;ACC == #04
003DAE | 001ED7: 4D70 0084 	BRA	s, 0084		;PC <- 0108
003DB2 | 001ED9: 66EE      	CMP	r3, RAMA[EE]	;ACC == RAMA[EE]
003DB4 | 001EDA: 4C70 0083 	BRA	ns, 0083		;PC <- 0106
003DB8 | 001EDC: 0EF5      	LD	RAMA[F5], r3	;RAMA[F5] <- AH
003DBA | 001EDD: 06F0      	LD	r3, A[F0]		;AH <- A[F0]
003DBC | 001EDE: B803      	AND	r3, #03		;ACC &= #03
003DBE | 001EDF: 0EF8      	LD	RAMA[F8], r3	;RAMA[F8] <- AH
003DC0 | 001EE0: 98C0      	ADD	r3, #C0		;ACC += #C0
003DC2 | 001EE1: 1432      	LD	pA2, r3		;p_A2 <- AH
003DC4 | 001EE2: 0233      	LD	r3, ptrA3		;AH <- dp_A0
003DC6 | 001EE3: A202      	AND	r3, ptrA2		;ACC &= [p_A2]
003DC8 | 001EE4: 00C3      	LD	rC, r3		;EXT4 <- AH
003DCA | 001EE5: 000E      	LD	r0, rE		;R0 <- EXT6
003DCC | 001EE6: 02EF      	LD	rE, ptrAF		;EXT6 <- dp_A3
003DCE | 001EE7: 00C0      	LD	rC, r0		;EXT4 <- R0
003DD0 | 001EE8: 06F5      	LD	r3, A[F5]		;AH <- A[F5]
003DD2 | 001EE9: 3803      	SUB	r3, #03		;ACC -= #03
003DD4 | 001EEA: 86F8      	ADD	r3, RAMA[F8]	;ACC += RAMA[F8]
003DD6 | 001EEB: 9002      	SHR	ACC			;
003DD8 | 001EEC: 9002      	SHR	ACC			;
003DDA | 001EED: 0013      	LD	r1, r3		;X <- AH
003DDC | 001EEE: 06EA      	LD	r3, A[EA]		;AH <- A[EA]
003DDE | 001EEF: 2001      	SUB	r3, r1		;ACC -= X
003DE0 | 001EF0: 0063      	LD	r6, r3		;PC <- AH
003DE2 | 001EF1: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DE4 | 001EF2: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DE6 | 001EF3: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DE8 | 001EF4: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DEA | 001EF5: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DEC | 001EF6: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DEE | 001EF7: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DF0 | 001EF8: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DF2 | 001EF9: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DF4 | 001EFA: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DF6 | 001EFB: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DF8 | 001EFC: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DFA | 001EFD: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DFC | 001EFE: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003DFE | 001EFF: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E00 | 001F00: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E02 | 001F01: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E04 | 001F02: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E06 | 001F03: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E08 | 001F04: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E0A | 001F05: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E0C | 001F06: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E0E | 001F07: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E10 | 001F08: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E12 | 001F09: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E14 | 001F0A: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E16 | 001F0B: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E18 | 001F0C: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E1A | 001F0D: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E1C | 001F0E: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E1E | 001F0F: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E20 | 001F10: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E22 | 001F11: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E24 | 001F12: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E26 | 001F13: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E28 | 001F14: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E2A | 001F15: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E2C | 001F16: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E2E | 001F17: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E30 | 001F18: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E32 | 001F19: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E34 | 001F1A: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E36 | 001F1B: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E38 | 001F1C: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E3A | 001F1D: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E3C | 001F1E: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E3E | 001F1F: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E40 | 001F20: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E42 | 001F21: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E44 | 001F22: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E46 | 001F23: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E48 | 001F24: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E4A | 001F25: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E4C | 001F26: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E4E | 001F27: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E50 | 001F28: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E52 | 001F29: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E54 | 001F2A: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E56 | 001F2B: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E58 | 001F2C: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E5A | 001F2D: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E5C | 001F2E: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E5E | 001F2F: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E60 | 001F30: 02C3      	LD	rC, ptrA3		;EXT4 <- dp_A0
003E62 | 001F31: 000E      	LD	r0, rE		;R0 <- EXT6
003E64 | 001F32: 02EB      	LD	rE, ptrAB		;EXT6 <- dp_A2
003E66 | 001F33: 00C0      	LD	rC, r0		;EXT4 <- R0
003E68 | 001F34: 06F1      	LD	r3, A[F1]		;AH <- A[F1]
003E6A | 001F35: 9801      	ADD	r3, #01		;ACC += #01
003E6C | 001F36: B803      	AND	r3, #03		;ACC &= #03
003E6E | 001F37: 98C4      	ADD	r3, #C4		;ACC += #C4
003E70 | 001F38: 1432      	LD	pA2, r3		;p_A2 <- AH
003E72 | 001F39: 0233      	LD	r3, ptrA3		;AH <- dp_A0
003E74 | 001F3A: A202      	AND	r3, ptrA2		;ACC &= [p_A2]
003E76 | 001F3B: 00C3      	LD	rC, r3		;EXT4 <- AH
L_I0083:
003E78 | 001F3C: 0065      	LD	r6, r5		;PC <- STACK

L_I0084:
003E7A | 001F3D: 9003      	SHL	ACC			;
003E7C | 001F3E: 4D70 0096 	BRA	s, 0096		;PC <- 012C
003E80 | 001F40: 9003      	SHL	ACC			;
003E82 | 001F41: 9003      	SHL	ACC			;
003E84 | 001F42: 98C8      	ADD	r3, #C8		;ACC += #C8
003E86 | 001F43: 0013      	LD	r1, r3		;X <- AH
003E88 | 001F44: 06F0      	LD	r3, A[F0]		;AH <- A[F0]
003E8A | 001F45: B803      	AND	r3, #03		;ACC &= #03
003E8C | 001F46: 9003      	SHL	ACC			;
003E8E | 001F47: 8001      	ADD	r3, r1		;ACC += X
003E90 | 001F48: 1432      	LD	pA2, r3		;p_A2 <- AH
003E92 | 001F49: 0233      	LD	r3, ptrA3		;AH <- dp_A0
003E94 | 001F4A: A206      	AND	r3, ptrA6		;ACC &= [p_A2++]
003E96 | 001F4B: 00C3      	LD	rC, r3		;EXT4 <- AH
003E98 | 001F4C: 0233      	LD	r3, ptrA3		;AH <- dp_A0
003E9A | 001F4D: A202      	AND	r3, ptrA2		;ACC &= [p_A2]
003E9C | 001F4E: 00C3      	LD	rC, r3		;EXT4 <- AH
003E9E | 001F4F: 0065      	LD	r6, r5		;PC <- STACK

L_I0097:
003EA0 | 001F50: 1807      	LD	pA0, #07		;pA0 <- #07
003EA2 | 001F51: 04C4      	LD	ptrA4, rC		;[p_A0++] <- EXT4
003EA4 | 001F52: 003C      	LD	r3, rC		;AH <- EXT4
003EA6 | 001F53: 9880      	ADD	r3, #80		;ACC += #80
003EA8 | 001F54: 0434      	LD	ptrA4, r3		;[p_A0++] <- AH
003EAA | 001F55: 0679      	LD	r3, A[79]		;AH <- A[79]
003EAC | 001F56: 200C      	SUB	r3, rC		;ACC -= EXT4
003EAE | 001F57: 0434      	LD	ptrA4, r3		;[p_A0++] <- AH
003EB0 | 001F58: 003C      	LD	r3, rC		;AH <- EXT4
003EB2 | 001F59: 9880      	ADD	r3, #80		;ACC += #80
003EB4 | 001F5A: 0434      	LD	ptrA4, r3		;[p_A0++] <- AH
003EB6 | 001F5B: 0679      	LD	r3, A[79]		;AH <- A[79]
003EB8 | 001F5C: 200C      	SUB	r3, rC		;ACC -= EXT4
003EBA | 001F5D: 0434      	LD	ptrA4, r3		;[p_A0++] <- AH
003EBC | 001F5E: 003C      	LD	r3, rC		;AH <- EXT4
003EBE | 001F5F: 9880      	ADD	r3, #80		;ACC += #80
003EC0 | 001F60: 0E0C      	LD	RAMA[0C], r3	;RAMA[0C] <- AH
003EC2 | 001F61: 0E0E      	LD	RAMA[0E], r3	;RAMA[0E] <- AH
003EC4 | 001F62: 0679      	LD	r3, A[79]		;AH <- A[79]
003EC6 | 001F63: 200C      	SUB	r3, rC		;ACC -= EXT4
003EC8 | 001F64: 0E0D      	LD	RAMA[0D], r3	;RAMA[0D] <- AH
003ECA | 001F65: 0E0F      	LD	RAMA[0F], r3	;RAMA[0F] <- AH
003ECC | 001F66: 0607      	LD	r3, A[07]		;AH <- A[07]
003ECE | 001F67: B810      	AND	r3, #10		;ACC &= #10
003ED0 | 001F68: 4C50 00B7 	BRA	nz, 00B7		;PC <- 016E
003ED4 | 001F6A: 003C      	LD	r3, rC		;AH <- EXT4
003ED6 | 001F6B: 9880      	ADD	r3, #80		;ACC += #80
003ED8 | 001F6C: 0E0E      	LD	RAMA[0E], r3	;RAMA[0E] <- AH
003EDA | 001F6D: 0679      	LD	r3, A[79]		;AH <- A[79]
003EDC | 001F6E: 200C      	SUB	r3, rC		;ACC -= EXT4
003EDE | 001F6F: 0E0F      	LD	RAMA[0F], r3	;RAMA[0F] <- AH
L_I00B7:
003EE0 | 001F70: 1809      	LD	pA0, #09		;pA0 <- #09
003EE2 | 001F71: 1909      	LD	pA1, #09		;pA1 <- #09
003EE4 | 001F72: 1A0B      	LD	pA2, #0B		;pA2 <- #0B
003EE6 | 001F73: 1D02      	LD	pB1, #02		;pB1 <- #02
L_I00BB:
003EE8 | 001F74: 0232      	LD	r3, ptrA2		;AH <- [p_A2]
003EEA | 001F75: 6200      	CMP	r3, ptrA0		;ACC == [p_A0]
003EEC | 001F76: 4C70 00C1 	BRA	ns, 00C1		;PC <- 0182
003EF0 | 001F78: 1212      	LD	r1, pA2		;X <- p_A2
003EF2 | 001F79: 1410      	LD	pA0, r1		;p_A0 <- X
L_I00C1:
003EF4 | 001F7A: 6201      	CMP	r3, ptrA1		;ACC == [p_A1]
003EF6 | 001F7B: 4D70 00C6 	BRA	s, 00C6		;PC <- 018C
003EFA | 001F7D: 1212      	LD	r1, pA2		;X <- p_A2
003EFC | 001F7E: 1411      	LD	pA1, r1		;p_A1 <- X
L_I00C6:
003EFE | 001F7F: 0206      	LD	r0, ptrA6		;R0 <- [p_A2++]
003F00 | 001F80: 0206      	LD	r0, ptrA6		;R0 <- [p_A2++]
003F02 | 001F81: 1331      	LD	r3, pB1		;AH <- p_B1
003F04 | 001F82: 3801      	SUB	r3, #01		;ACC -= #01
003F06 | 001F83: 1531      	LD	pB1, r3		;p_B1 <- AH
003F08 | 001F84: 4C70 00BB 	BRA	ns, 00BB		;PC <- 0176
003F0C | 001F86: 0034      	LD	r3, r4		;AH <- ST
003F0E | 001F87: A6E8      	AND	r3, RAMA[E8]	;ACC &= RAMA[E8]
003F10 | 001F88: D803      	OR	r3, #03		;ACC |= #03
003F12 | 001F89: 0043      	LD	r4, r3		;ST <- AH
003F14 | 001F8A: 0230      	LD	r3, ptrA0		;AH <- [p_A0]
003F16 | 001F8B: 6201      	CMP	r3, ptrA1		;ACC == [p_A1]
003F18 | 001F8C: 4D50 02B8 	BRA	z, 02B8		;PC <- 0570
003F1C | 001F8E: 1230      	LD	r3, pA0		;AH <- p_A0
003F1E | 001F8F: 0E06      	LD	RAMA[06], r3	;RAMA[06] <- AH
003F20 | 001F90: 0208      	LD	r0, ptrA8		;R0 <- [p_A0--!]
003F22 | 001F91: 0229      	LD	r2, ptrA9		;Y <- [p_A1--!]
003F24 | 001F92: 1211      	LD	r1, pA1		;X <- p_A1
003F26 | 001F93: 020D      	LD	r0, ptrAD		;R0 <- [p_A1++!]
003F28 | 001F94: 020D      	LD	r0, ptrAD		;R0 <- [p_A1++!]
003F2A | 001F95: 1231      	LD	r3, pA1		;AH <- p_A1
003F2C | 001F96: 0F04      	LD	RAMB[04], r3	;RAMB[04] <- AH
003F2E | 001F97: 1411      	LD	pA1, r1		;p_A1 <- X
003F30 | 001F98: 0209      	LD	r0, ptrA9		;R0 <- [p_A1--!]
003F32 | 001F99: 1231      	LD	r3, pA1		;AH <- p_A1
003F34 | 001F9A: 0F05      	LD	RAMB[05], r3	;RAMB[05] <- AH
003F36 | 001F9B: 0032      	LD	r3, r2		;AH <- Y
003F38 | 001F9C: 6675      	CMP	r3, RAMA[75]	;ACC == RAMA[75]
003F3A | 001F9D: 4D70 02B8 	BRA	s, 02B8		;PC <- 0570
003F3E | 001F9F: 1A90      	LD	pA2, #90		;pA2 <- #90
003F40 | 001FA0: 021C      	LD	r1, ptrAC		;X <- [p_A0++!]
003F42 | 001FA1: 023C      	LD	r3, ptrAC		;AH <- [p_A0++!]
003F44 | 001FA2: 6676      	CMP	r3, RAMA[76]	;ACC == RAMA[76]
003F46 | 001FA3: 4C70 02B8 	BRA	ns, 02B8		;PC <- 0570
003F4A | 001FA5: 0023      	LD	r2, r3		;Y <- AH
003F4C | 001FA6: 6675      	CMP	r3, RAMA[75]	;ACC == RAMA[75]
003F4E | 001FA7: 4C70 0102 	BRA	ns, 0102		;PC <- 0204
L_I00F0:
003F52 | 001FA9: 0513      	LD	ptrB3, r1		;dp_B0 <- X
003F54 | 001FAA: 0527      	LD	ptrB7, r2		;dp_B1 <- Y
003F56 | 001FAB: 021C      	LD	r1, ptrAC		;X <- [p_A0++!]
003F58 | 001FAC: 022C      	LD	r2, ptrAC		;Y <- [p_A0++!]
003F5A | 001FAD: 0032      	LD	r3, r2		;AH <- Y
003F5C | 001FAE: 6675      	CMP	r3, RAMA[75]	;ACC == RAMA[75]
003F5E | 001FAF: 4D70 00F0 	BRA	s, 00F0		;PC <- 01E0
003F62 | 001FB1: 051B      	LD	ptrBB, r1		;dp_B2 <- X
003F64 | 001FB2: 052F      	LD	ptrBF, r2		;dp_B3 <- Y
003F66 | 001FB3: 0675      	LD	r3, A[75]		;AH <- A[75]
003F68 | 001FB4: 043F      	LD	ptrAF, r3		;dp_A3 <- AH
003F6A | 001FB5: 4800 02DF 	CALL	02DF			;PC <- 05BE
003F6E | 001FB7: 0675      	LD	r3, A[75]		;AH <- A[75]
003F70 | 001FB8: 0023      	LD	r2, r3		;Y <- AH
003F72 | 001FB9: 0208      	LD	r0, ptrA8		;R0 <- [p_A0--!]
003F74 | 001FBA: 0208      	LD	r0, ptrA8		;R0 <- [p_A0--!]
L_I0102:
003F76 | 001FBB: 0416      	LD	ptrA6, r1		;[p_A2++] <- X
003F78 | 001FBC: 0426      	LD	ptrA6, r2		;[p_A2++] <- Y
L_I0104:
003F7A | 001FBD: 0513      	LD	ptrB3, r1		;dp_B0 <- X
003F7C | 001FBE: 0527      	LD	ptrB7, r2		;dp_B1 <- Y
003F7E | 001FBF: 021C      	LD	r1, ptrAC		;X <- [p_A0++!]
003F80 | 001FC0: 022C      	LD	r2, ptrAC		;Y <- [p_A0++!]
003F82 | 001FC1: 0032      	LD	r3, r2		;AH <- Y
003F84 | 001FC2: 6676      	CMP	r3, RAMA[76]	;ACC == RAMA[76]
003F86 | 001FC3: 4C70 0114 	BRA	ns, 0114		;PC <- 0228
003F8A | 001FC5: 0416      	LD	ptrA6, r1		;[p_A2++] <- X
003F8C | 001FC6: 0426      	LD	ptrA6, r2		;[p_A2++] <- Y
003F8E | 001FC7: 1230      	LD	r3, pA0		;AH <- p_A0
003F90 | 001FC8: 6704      	CMP	r3, RAMB[04]	;ACC == RAMB[04]
003F92 | 001FC9: 4C50 0104 	BRA	nz, 0104		;PC <- 0208
003F96 | 001FCB: 4C00 011D 	BRA	011D			;PC <- 023A
L_I0114:
003F9A | 001FCD: 051B      	LD	ptrBB, r1		;dp_B2 <- X
003F9C | 001FCE: 052F      	LD	ptrBF, r2		;dp_B3 <- Y
003F9E | 001FCF: 0676      	LD	r3, A[76]		;AH <- A[76]
003FA0 | 001FD0: 043F      	LD	ptrAF, r3		;dp_A3 <- AH
003FA2 | 001FD1: 4800 02DF 	CALL	02DF			;PC <- 05BE
003FA6 | 001FD3: 0416      	LD	ptrA6, r1		;[p_A2++] <- X
003FA8 | 001FD4: 0676      	LD	r3, A[76]		;AH <- A[76]
003FAA | 001FD5: 0436      	LD	ptrA6, r3		;[p_A2++] <- AH
003FAC | 001FD6: 0406      	LD	ptrA6, r0		;[p_A2++] <- R0
003FAE | 001FD7: 0406      	LD	ptrA6, r0		;[p_A2++] <- R0
003FB0 | 001FD8: 0606      	LD	r3, A[06]		;AH <- A[06]
003FB2 | 001FD9: 1430      	LD	pA0, r3		;p_A0 <- AH
003FB4 | 001FDA: 1AA0      	LD	pA2, #A0		;pA2 <- #A0
003FB6 | 001FDB: 0228      	LD	r2, ptrA8		;Y <- [p_A0--!]
003FB8 | 001FDC: 0218      	LD	r1, ptrA8		;X <- [p_A0--!]
003FBA | 001FDD: 0032      	LD	r3, r2		;AH <- Y
003FBC | 001FDE: 6675      	CMP	r3, RAMA[75]	;ACC == RAMA[75]
003FBE | 001FDF: 4C70 013A 	BRA	ns, 013A		;PC <- 0274
003FC2 | 001FE1: 0513      	LD	ptrB3, r1		;dp_B0 <- X
003FC4 | 001FE2: 0527      	LD	ptrB7, r2		;dp_B1 <- Y
003FC6 | 001FE3: 0228      	LD	r2, ptrA8		;Y <- [p_A0--!]
003FC8 | 001FE4: 0218      	LD	r1, ptrA8		;X <- [p_A0--!]
003FCA | 001FE5: 0032      	LD	r3, r2		;AH <- Y
003FCC | 001FE6: 6675      	CMP	r3, RAMA[75]	;ACC == RAMA[75]
003FCE | 001FE7: 4D70 0128 	BRA	s, 0128		;PC <- 0250
003FD2 | 001FE9: 051B      	LD	ptrBB, r1		;dp_B2 <- X
003FD4 | 001FEA: 052F      	LD	ptrBF, r2		;dp_B3 <- Y
003FD6 | 001FEB: 0675      	LD	r3, A[75]		;AH <- A[75]
003FD8 | 001FEC: 043F      	LD	ptrAF, r3		;dp_A3 <- AH
003FDA | 001FED: 4800 02DF 	CALL	02DF			;PC <- 05BE
003FDE | 001FEF: 0675      	LD	r3, A[75]		;AH <- A[75]
003FE0 | 001FF0: 0023      	LD	r2, r3		;Y <- AH
003FE2 | 001FF1: 020C      	LD	r0, ptrAC		;R0 <- [p_A0++!]
003FE4 | 001FF2: 020C      	LD	r0, ptrAC		;R0 <- [p_A0++!]
003FE6 | 001FF3: 0416      	LD	ptrA6, r1		;[p_A2++] <- X
003FE8 | 001FF4: 0426      	LD	ptrA6, r2		;[p_A2++] <- Y
003FEA | 001FF5: 0513      	LD	ptrB3, r1		;dp_B0 <- X
003FEC | 001FF6: 0527      	LD	ptrB7, r2		;dp_B1 <- Y
003FEE | 001FF7: 0228      	LD	r2, ptrA8		;Y <- [p_A0--!]
003FF0 | 001FF8: 0218      	LD	r1, ptrA8		;X <- [p_A0--!]
003FF2 | 001FF9: 0032      	LD	r3, r2		;AH <- Y
003FF4 | 001FFA: 6676      	CMP	r3, RAMA[76]	;ACC == RAMA[76]
003FF6 | 001FFB: 4C70 014C 	BRA	ns, 014C		;PC <- 0298
003FFA | 001FFD: 0416      	LD	ptrA6, r1		;[p_A2++] <- X
003FFC | 001FFE: 0426      	LD	ptrA6, r2		;[p_A2++] <- Y
003FFE | 001FFF: 1230      	LD	r3, pA0		;AH <- p_A0
004000 | 002000: 6705      	CMP	r3, RAMB[05]	;ACC == RAMB[05]
004002 | 002001: 4C50 013C 	BRA	nz, 013C		;PC <- 0278
004006 | 002003: 4C00 0155 	BRA	0155			;PC <- 02AA
00400A | 002005: 051B      	LD	ptrBB, r1		;dp_B2 <- X
00400C | 002006: 052F      	LD	ptrBF, r2		;dp_B3 <- Y
00400E | 002007: 0676      	LD	r3, A[76]		;AH <- A[76]
004010 | 002008: 043F      	LD	ptrAF, r3		;dp_A3 <- AH
004012 | 002009: 4800 02DF 	CALL	02DF			;PC <- 05BE
004016 | 00200B: 0416      	LD	ptrA6, r1		;[p_A2++] <- X
004018 | 00200C: 0676      	LD	r3, A[76]		;AH <- A[76]
00401A | 00200D: 0436      	LD	ptrA6, r3		;[p_A2++] <- AH
00401C | 00200E: 0406      	LD	ptrA6, r0		;[p_A2++] <- R0
00401E | 00200F: 0406      	LD	ptrA6, r0		;[p_A2++] <- R0
004020 | 002010: 0034      	LD	r3, r4		;AH <- ST
004022 | 002011: A6E8      	AND	r3, RAMA[E8]	;ACC &= RAMA[E8]
004024 | 002012: 0043      	LD	r4, r3		;ST <- AH
004026 | 002013: 0690      	LD	r3, A[90]		;AH <- A[90]
004028 | 002014: 0F06      	LD	RAMB[06], r3	;RAMB[06] <- AH
00402A | 002015: 0F07      	LD	RAMB[07], r3	;RAMB[07] <- AH
00402C | 002016: 1892      	LD	pA0, #92		;pA0 <- #92
00402E | 002017: 4800 036B 	CALL	036B			;PC <- 06D6
004032 | 002019: 18A0      	LD	pA0, #A0		;pA0 <- #A0
004034 | 00201A: 4800 036B 	CALL	036B			;PC <- 06D6
004038 | 00201C: 0707      	LD	r3, B[07]		;AH <- B[07]
00403A | 00201D: 7800      	CMP	r3, #00		;ACC == #00
00403C | 00201E: 4D70 02B8 	BRA	s, 02B8		;PC <- 0570
004040 | 002020: 0706      	LD	r3, B[06]		;AH <- B[06]
004042 | 002021: 78FF      	CMP	r3, #FF		;ACC == #FF
004044 | 002022: 4C70 02B8 	BRA	ns, 02B8		;PC <- 0570
004048 | 002024: 7800      	CMP	r3, #00		;ACC == #00
00404A | 002025: 4D70 0172 	BRA	s, 0172		;PC <- 02E4
00404E | 002027: 0707      	LD	r3, B[07]		;AH <- B[07]
004050 | 002028: 78FF      	CMP	r3, #FF		;ACC == #FF
004052 | 002029: 4D70 021A 	BRA	s, 021A		;PC <- 0434
004056 | 00202B: 1890      	LD	pA0, #90		;pA0 <- #90
004058 | 00202C: 1990      	LD	pA1, #90		;pA1 <- #90
00405A | 00202D: 1C0A      	LD	pB0, #0A		;pB0 <- #0A
00405C | 00202E: 1D22      	LD	pB1, #22		;pB1 <- #22
00405E | 00202F: 4800 030F 	CALL	030F			;PC <- 061E
004062 | 002031: 18A0      	LD	pA0, #A0		;pA0 <- #A0
004064 | 002032: 19A0      	LD	pA1, #A0		;pA1 <- #A0
004066 | 002033: 1C16      	LD	pB0, #16		;pB0 <- #16
004068 | 002034: 4800 030F 	CALL	030F			;PC <- 061E
00406C | 002036: 1890      	LD	pA0, #90		;pA0 <- #90
00406E | 002037: 19A0      	LD	pA1, #A0		;pA1 <- #A0
004070 | 002038: 1C0A      	LD	pB0, #0A		;pB0 <- #0A
004072 | 002039: 1D16      	LD	pB1, #16		;pB1 <- #16
004074 | 00203A: 0722      	LD	r3, B[22]		;AH <- B[22]
004076 | 00203B: C724      	OR	r3, RAMB[24]	;ACC |= RAMB[24]
004078 | 00203C: 4D50 01C4 	BRA	z, 01C4		;PC <- 0388
00407C | 00203E: 0675      	LD	r3, A[75]		;AH <- A[75]
00407E | 00203F: 0023      	LD	r2, r3		;Y <- AH
004080 | 002040: 0722      	LD	r3, B[22]		;AH <- B[22]
004082 | 002041: A724      	AND	r3, RAMB[24]	;ACC &= RAMB[24]
004084 | 002042: 4C50 01AD 	BRA	nz, 01AD		;PC <- 035A
004088 | 002044: 0722      	LD	r3, B[22]		;AH <- B[22]
00408A | 002045: 7801      	CMP	r3, #01		;ACC == #01
00408C | 002046: 4C50 0194 	BRA	nz, 0194		;PC <- 0328
004090 | 002048: 0C04 0000 	LD	ptrA4, #0000	;[p_A0++] <- #0000
004094 | 00204A: 0424      	LD	ptrA4, r2		;[p_A0++] <- Y
004096 | 00204B: 4C00 019B 	BRA	019B			;PC <- 0336
00409A | 00204D: 0722      	LD	r3, B[22]		;AH <- B[22]
00409C | 00204E: 7802      	CMP	r3, #02		;ACC == #02
00409E | 00204F: 4C50 019B 	BRA	nz, 019B		;PC <- 0336
0040A2 | 002051: 0C04 00FF 	LD	ptrA4, #00FF	;[p_A0++] <- #00FF
0040A6 | 002053: 0424      	LD	ptrA4, r2		;[p_A0++] <- Y
0040A8 | 002054: 0724      	LD	r3, B[24]		;AH <- B[24]
0040AA | 002055: 7801      	CMP	r3, #01		;ACC == #01
0040AC | 002056: 4C50 01A4 	BRA	nz, 01A4		;PC <- 0348
0040B0 | 002058: 0C05 0000 	LD	ptrA5, #0000	;[p_A1++] <- #0000
0040B4 | 00205A: 0425      	LD	ptrA5, r2		;[p_A1++] <- Y
0040B6 | 00205B: 4C00 01C4 	BRA	01C4			;PC <- 0388
0040BA | 00205D: 0724      	LD	r3, B[24]		;AH <- B[24]
0040BC | 00205E: 7802      	CMP	r3, #02		;ACC == #02
0040BE | 00205F: 4C50 01C4 	BRA	nz, 01C4		;PC <- 0388
0040C2 | 002061: 0C05 00FF 	LD	ptrA5, #00FF	;[p_A1++] <- #00FF
0040C6 | 002063: 0425      	LD	ptrA5, r2		;[p_A1++] <- Y
0040C8 | 002064: 4C00 01C4 	BRA	01C4			;PC <- 0388
0040CC | 002066: 0030      	LD	r3, r0		;AH <- R0
0040CE | 002067: 6300      	CMP	r3, ptrB0		;ACC == [p_B0]
0040D0 | 002068: 4D50 01BE 	BRA	z, 01BE		;PC <- 037C
0040D4 | 00206A: 6301      	CMP	r3, ptrB1		;ACC == [p_B1]
0040D6 | 00206B: 4D50 01BA 	BRA	z, 01BA		;PC <- 0374
0040DA | 00206D: 0304      	LD	r0, ptrB4		;R0 <- [p_B0++]
0040DC | 00206E: 0338      	LD	r3, ptrB8		;AH <- [p_B0--!]
0040DE | 00206F: 0305      	LD	r0, ptrB5		;R0 <- [p_B1++]
0040E0 | 002070: 6309      	CMP	r3, ptrB9		;ACC == [p_B1--!]
0040E2 | 002071: 4C70 01BE 	BRA	ns, 01BE		;PC <- 037C
0040E6 | 002073: 0334      	LD	r3, ptrB4		;AH <- [p_B0++]
0040E8 | 002074: 0328      	LD	r2, ptrB8		;Y <- [p_B0--!]
0040EA | 002075: 4C00 01C0 	BRA	01C0			;PC <- 0380
0040EE | 002077: 0335      	LD	r3, ptrB5		;AH <- [p_B1++]
0040F0 | 002078: 0329      	LD	r2, ptrB9		;Y <- [p_B1--!]
0040F2 | 002079: 0434      	LD	ptrA4, r3		;[p_A0++] <- AH
0040F4 | 00207A: 0424      	LD	ptrA4, r2		;[p_A0++] <- Y
0040F6 | 00207B: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
0040F8 | 00207C: 0425      	LD	ptrA5, r2		;[p_A1++] <- Y
0040FA | 00207D: 0334      	LD	r3, ptrB4		;AH <- [p_B0++]
0040FC | 00207E: 0434      	LD	ptrA4, r3		;[p_A0++] <- AH
0040FE | 00207F: 0314      	LD	r1, ptrB4		;X <- [p_B0++]
004100 | 002080: 0414      	LD	ptrA4, r1		;[p_A0++] <- X
004102 | 002081: 7800      	CMP	r3, #00		;ACC == #00
004104 | 002082: 4C70 01C4 	BRA	ns, 01C4		;PC <- 0388
004108 | 002084: 0208      	LD	r0, ptrA8		;R0 <- [p_A0--!]
00410A | 002085: 0208      	LD	r0, ptrA8		;R0 <- [p_A0--!]
00410C | 002086: 0335      	LD	r3, ptrB5		;AH <- [p_B1++]
00410E | 002087: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
004110 | 002088: 0315      	LD	r1, ptrB5		;X <- [p_B1++]
004112 | 002089: 0415      	LD	ptrA5, r1		;[p_A1++] <- X
004114 | 00208A: 7800      	CMP	r3, #00		;ACC == #00
004116 | 00208B: 4C70 01CD 	BRA	ns, 01CD		;PC <- 039A
00411A | 00208D: 0209      	LD	r0, ptrA9		;R0 <- [p_A1--!]
00411C | 00208E: 0209      	LD	r0, ptrA9		;R0 <- [p_A1--!]
00411E | 00208F: 0676      	LD	r3, A[76]		;AH <- A[76]
004120 | 002090: 0023      	LD	r2, r3		;Y <- AH
004122 | 002091: 0723      	LD	r3, B[23]		;AH <- B[23]
004124 | 002092: C725      	OR	r3, RAMB[25]	;ACC |= RAMB[25]
004126 | 002093: 4D50 0216 	BRA	z, 0216		;PC <- 042C
00412A | 002095: 0723      	LD	r3, B[23]		;AH <- B[23]
00412C | 002096: A725      	AND	r3, RAMB[25]	;ACC &= RAMB[25]
00412E | 002097: 4C50 0202 	BRA	nz, 0202		;PC <- 0404
004132 | 002099: 0723      	LD	r3, B[23]		;AH <- B[23]
004134 | 00209A: 7801      	CMP	r3, #01		;ACC == #01
004136 | 00209B: 4C50 01E9 	BRA	nz, 01E9		;PC <- 03D2
00413A | 00209D: 0C04 0000 	LD	ptrA4, #0000	;[p_A0++] <- #0000
00413E | 00209F: 0424      	LD	ptrA4, r2		;[p_A0++] <- Y
004140 | 0020A0: 4C00 01F0 	BRA	01F0			;PC <- 03E0
004144 | 0020A2: 0723      	LD	r3, B[23]		;AH <- B[23]
004146 | 0020A3: 7802      	CMP	r3, #02		;ACC == #02
004148 | 0020A4: 4C50 01F0 	BRA	nz, 01F0		;PC <- 03E0
00414C | 0020A6: 0C04 00FF 	LD	ptrA4, #00FF	;[p_A0++] <- #00FF
004150 | 0020A8: 0424      	LD	ptrA4, r2		;[p_A0++] <- Y
004152 | 0020A9: 0725      	LD	r3, B[25]		;AH <- B[25]
004154 | 0020AA: 7801      	CMP	r3, #01		;ACC == #01
004156 | 0020AB: 4C50 01F9 	BRA	nz, 01F9		;PC <- 03F2
00415A | 0020AD: 0C05 0000 	LD	ptrA5, #0000	;[p_A1++] <- #0000
00415E | 0020AF: 0425      	LD	ptrA5, r2		;[p_A1++] <- Y
004160 | 0020B0: 4C00 0216 	BRA	0216			;PC <- 042C
004164 | 0020B2: 0725      	LD	r3, B[25]		;AH <- B[25]
004166 | 0020B3: 7802      	CMP	r3, #02		;ACC == #02
004168 | 0020B4: 4C50 0216 	BRA	nz, 0216		;PC <- 042C
00416C | 0020B6: 0C05 00FF 	LD	ptrA5, #00FF	;[p_A1++] <- #00FF
004170 | 0020B8: 0425      	LD	ptrA5, r2		;[p_A1++] <- Y
004172 | 0020B9: 4C00 0216 	BRA	0216			;PC <- 042C
004176 | 0020BB: 1330      	LD	r3, pB0		;AH <- p_B0
004178 | 0020BC: 3803      	SUB	r3, #03		;ACC -= #03
00417A | 0020BD: 1530      	LD	pB0, r3		;p_B0 <- AH
00417C | 0020BE: 1331      	LD	r3, pB1		;AH <- p_B1
00417E | 0020BF: 3803      	SUB	r3, #03		;ACC -= #03
004180 | 0020C0: 1531      	LD	pB1, r3		;p_B1 <- AH
004182 | 0020C1: 0338      	LD	r3, ptrB8		;AH <- [p_B0--!]
004184 | 0020C2: 6309      	CMP	r3, ptrB9		;ACC == [p_B1--!]
004186 | 0020C3: 4D70 0210 	BRA	s, 0210		;PC <- 0420
00418A | 0020C5: 0334      	LD	r3, ptrB4		;AH <- [p_B0++]
00418C | 0020C6: 0324      	LD	r2, ptrB4		;Y <- [p_B0++]
00418E | 0020C7: 4C00 0212 	BRA	0212			;PC <- 0424
004192 | 0020C9: 0335      	LD	r3, ptrB5		;AH <- [p_B1++]
004194 | 0020CA: 0325      	LD	r2, ptrB5		;Y <- [p_B1++]
004196 | 0020CB: 0434      	LD	ptrA4, r3		;[p_A0++] <- AH
004198 | 0020CC: 0424      	LD	ptrA4, r2		;[p_A0++] <- Y
00419A | 0020CD: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
00419C | 0020CE: 0425      	LD	ptrA5, r2		;[p_A1++] <- Y
00419E | 0020CF: 0404      	LD	ptrA4, r0		;[p_A0++] <- R0
0041A0 | 0020D0: 0404      	LD	ptrA4, r0		;[p_A0++] <- R0
0041A2 | 0020D1: 0405      	LD	ptrA5, r0		;[p_A1++] <- R0
0041A4 | 0020D2: 0405      	LD	ptrA5, r0		;[p_A1++] <- R0
0041A6 | 0020D3: 000E      	LD	r0, rE		;R0 <- EXT6
0041A8 | 0020D4: 08E0 4418 	LD	rE, #4418		;EXT6 <- #4418
0041AC | 0020D6: 00C0      	LD	rC, r0		;EXT4 <- R0
0041AE | 0020D7: 0C0B 4418 	LD	ptrAB, #4418	;dp_A2 <- #4418
0041B2 | 0020D9: 1890      	LD	pA0, #90		;pA0 <- #90
0041B4 | 0020DA: 19A0      	LD	pA1, #A0		;pA1 <- #A0
0041B6 | 0020DB: B800      	AND	r3, #00		;ACC &= #00
0041B8 | 0020DC: 0E88      	LD	RAMA[88], r3	;RAMA[88] <- AH
0041BA | 0020DD: 0E89      	LD	RAMA[89], r3	;RAMA[89] <- AH
0041BC | 0020DE: 06E9      	LD	r3, A[E9]		;AH <- A[E9]
0041BE | 0020DF: 0E8C      	LD	RAMA[8C], r3	;RAMA[8C] <- AH
0041C0 | 0020E0: 0E8F      	LD	RAMA[8F], r3	;RAMA[8F] <- AH
0041C2 | 0020E1: 0215      	LD	r1, ptrA5		;X <- [p_A1++]
0041C4 | 0020E2: 0225      	LD	r2, ptrA5		;Y <- [p_A1++]
0041C6 | 0020E3: 0235      	LD	r3, ptrA5		;AH <- [p_A1++]
0041C8 | 0020E4: 2001      	SUB	r3, r1		;ACC -= X
0041CA | 0020E5: 0533      	LD	ptrB3, r3		;dp_B0 <- AH
0041CC | 0020E6: 0239      	LD	r3, ptrA9		;AH <- [p_A1--!]
0041CE | 0020E7: 2002      	SUB	r3, r2		;ACC -= Y
0041D0 | 0020E8: 4D50 0228 	BRA	z, 0228		;PC <- 0450
0041D4 | 0020EA: 0209      	LD	r0, ptrA9		;R0 <- [p_A1--!]
0041D6 | 0020EB: 0209      	LD	r0, ptrA9		;R0 <- [p_A1--!]
0041D8 | 0020EC: 87F3      	ADD	r3, RAMB[F3]	;ACC += RAMB[F3]
0041DA | 0020ED: 4A20      	LD	r2, (r3)		;Y <- (AH)
0041DC | 0020EE: 0527      	LD	ptrB7, r2		;dp_B1 <- Y
0041DE | 0020EF: 0214      	LD	r1, ptrA4		;X <- [p_A0++]
0041E0 | 0020F0: 0224      	LD	r2, ptrA4		;Y <- [p_A0++]
0041E2 | 0020F1: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
0041E4 | 0020F2: 2001      	SUB	r3, r1		;ACC -= X
0041E6 | 0020F3: 0013      	LD	r1, r3		;X <- AH
0041E8 | 0020F4: 0238      	LD	r3, ptrA8		;AH <- [p_A0--!]
0041EA | 0020F5: 2002      	SUB	r3, r2		;ACC -= Y
0041EC | 0020F6: 4D50 0236 	BRA	z, 0236		;PC <- 046C
0041F0 | 0020F8: 0208      	LD	r0, ptrA8		;R0 <- [p_A0--!]
0041F2 | 0020F9: 0208      	LD	r0, ptrA8		;R0 <- [p_A0--!]
0041F4 | 0020FA: 87F3      	ADD	r3, RAMB[F3]	;ACC += RAMB[F3]
0041F6 | 0020FB: 4A20      	LD	r2, (r3)		;Y <- (AH)
0041F8 | 0020FC: B800      	AND	r3, #00		;ACC &= #00
0041FA | 0020FD: 0230      	LD	r3, ptrA0		;AH <- [p_A0]
0041FC | 0020FE: 6201      	CMP	r3, ptrA1		;ACC == [p_A1]
0041FE | 0020FF: 4D70 0254 	BRA	s, 0254		;PC <- 04A8
004202 | 002101: 4C50 0250 	BRA	nz, 0250		;PC <- 04A0
004206 | 002103: 0037      	LD	r3, r7		;AH <- P
004208 | 002104: 0313      	LD	r1, ptrB3		;X <- dp_B0
00420A | 002105: 0327      	LD	r2, ptrB7		;Y <- dp_B1
00420C | 002106: 2007      	SUB	r3, r7		;ACC -= P
00420E | 002107: 4D70 0254 	BRA	s, 0254		;PC <- 04A8
004212 | 002109: 1210      	LD	r1, pA0		;X <- p_A0
004214 | 00210A: 1231      	LD	r3, pA1		;AH <- p_A1
004216 | 00210B: 1430      	LD	pA0, r3		;p_A0 <- AH
004218 | 00210C: 1411      	LD	pA1, r1		;p_A1 <- X
00421A | 00210D: 0691      	LD	r3, A[91]		;AH <- A[91]
00421C | 00210E: 0EF2      	LD	RAMA[F2], r3	;RAMA[F2] <- AH
00421E | 00210F: B80F      	AND	r3, #0F		;ACC &= #0F
004220 | 002110: 9003      	SHL	ACC			;
004222 | 002111: 86F6      	ADD	r3, RAMA[F6]	;ACC += RAMA[F6]
004224 | 002112: 0EF7      	LD	RAMA[F7], r3	;RAMA[F7] <- AH
004226 | 002113: 06F2      	LD	r3, A[F2]		;AH <- A[F2]
004228 | 002114: B8F0      	AND	r3, #F0		;ACC &= #F0
00422A | 002115: 0013      	LD	r1, r3		;X <- AH
00422C | 002116: 0820 0020 	LD	r2, #0020		;Y <- #0020
004230 | 002118: 0037      	LD	r3, r7		;AH <- P
004232 | 002119: 001F      	LD	r1, rF		;X <- AL
004234 | 00211A: 0031      	LD	r3, r1		;AH <- X
004236 | 00211B: 86F7      	ADD	r3, RAMA[F7]	;ACC += RAMA[F7]
004238 | 00211C: 0EF3      	LD	RAMA[F3], r3	;RAMA[F3] <- AH
00423A | 00211D: 0607      	LD	r3, A[07]		;AH <- A[07]
00423C | 00211E: B820      	AND	r3, #20		;ACC &= #20
00423E | 00211F: 4D50 0283 	BRA	z, 0283		;PC <- 0506
004242 | 002121: 0607      	LD	r3, A[07]		;AH <- A[07]
004244 | 002122: A6C5      	AND	r3, RAMA[C5]	;ACC &= RAMA[C5]
004246 | 002123: 06EC      	LD	r3, A[EC]		;AH <- A[EC]
004248 | 002124: 4D50 026E 	BRA	z, 026E		;PC <- 04DC
00424C | 002126: 06ED      	LD	r3, A[ED]		;AH <- A[ED]
00424E | 002127: 043F      	LD	ptrAF, r3		;dp_A3 <- AH
004250 | 002128: 0607      	LD	r3, A[07]		;AH <- A[07]
004252 | 002129: A6C6      	AND	r3, RAMA[C6]	;ACC &= RAMA[C6]
004254 | 00212A: 0013      	LD	r1, r3		;X <- AH
004256 | 00212B: 0820 0080 	LD	r2, #0080		;Y <- #0080
00425A | 00212D: 0037      	LD	r3, r7		;AH <- P
00425C | 00212E: B8FF      	AND	r3, #FF		;ACC &= #FF
00425E | 00212F: C001      	OR	r3, r1		;ACC |= X
004260 | 002130: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
004262 | 002131: 06F2      	LD	r3, A[F2]		;AH <- A[F2]
004264 | 002132: B801      	AND	r3, #01		;ACC &= #01
004266 | 002133: 4D50 027F 	BRA	z, 027F		;PC <- 04FE
00426A | 002135: 02E3      	LD	rE, ptrA3		;EXT6 <- dp_A0
00426C | 002136: 04E3      	LD	ptrA3, rE		;dp_A0 <- EXT6
00426E | 002137: 000F      	LD	r0, rF		;R0 <- AL
004270 | 002138: 0D0F 0018 	LD	ptrBF, #0018	;dp_B3 <- #0018
004274 | 00213A: 4C00 02A3 	BRA	02A3			;PC <- 0546
004278 | 00213C: 0C0F 4018 	LD	ptrAF, #4018	;dp_A3 <- #4018
00427C | 00213E: 0607      	LD	r3, A[07]		;AH <- A[07]
00427E | 00213F: A6C6      	AND	r3, RAMA[C6]	;ACC &= RAMA[C6]
004280 | 002140: 0013      	LD	r1, r3		;X <- AH
004282 | 002141: 0820 0080 	LD	r2, #0080		;Y <- #0080
004286 | 002143: 0037      	LD	r3, r7		;AH <- P
004288 | 002144: B8FF      	AND	r3, #FF		;ACC &= #FF
00428A | 002145: C001      	OR	r3, r1		;ACC |= X
00428C | 002146: 0433      	LD	ptrA3, r3		;dp_A0 <- AH
00428E | 002147: 0D0F 001B 	LD	ptrBF, #001B	;dp_B3 <- #001B
004292 | 002149: 4C00 02A3 	BRA	02A3			;PC <- 0546
004296 | 00214B: 4800 0000 	CALL	0000			;PC <- 0000
00429A | 00214D: 1A8A      	LD	pA2, #8A		;pA2 <- #8A
00429C | 00214E: 0216      	LD	r1, ptrA6		;X <- [p_A2++]
00429E | 00214F: 0226      	LD	r2, ptrA6		;Y <- [p_A2++]
0042A0 | 002150: 02F2      	LD	rF, ptrA2		;AL <- [p_A2]
0042A2 | 002151: 06F0      	LD	r3, A[F0]		;AH <- A[F0]
0042A4 | 002152: 8007      	ADD	r3, r7		;ACC += P
0042A6 | 002153: 0EF0      	LD	RAMA[F0], r3	;RAMA[F0] <- AH
0042A8 | 002154: 04F6      	LD	ptrA6, rF		;[p_A2++] <- AL
0042AA | 002155: 0216      	LD	r1, ptrA6		;X <- [p_A2++]
0042AC | 002156: 0226      	LD	r2, ptrA6		;Y <- [p_A2++]
0042AE | 002157: 02F2      	LD	rF, ptrA2		;AL <- [p_A2]
0042B0 | 002158: 06F1      	LD	r3, A[F1]		;AH <- A[F1]
0042B2 | 002159: 8007      	ADD	r3, r7		;ACC += P
0042B4 | 00215A: 0EF1      	LD	RAMA[F1], r3	;RAMA[F1] <- AH
0042B6 | 00215B: 04F6      	LD	ptrA6, rF		;[p_A2++] <- AL
0042B8 | 00215C: 0688      	LD	r3, A[88]		;AH <- A[88]
0042BA | 00215D: 3801      	SUB	r3, #01		;ACC -= #01
0042BC | 00215E: 0E88      	LD	RAMA[88], r3	;RAMA[88] <- AH
0042BE | 00215F: 4C70 02C2 	BRA	ns, 02C2		;PC <- 0584
0042C2 | 002161: B800      	AND	r3, #00		;ACC &= #00
0042C4 | 002162: 06E9      	LD	r3, A[E9]		;AH <- A[E9]
0042C6 | 002163: 0E8C      	LD	RAMA[8C], r3	;RAMA[8C] <- AH
0042C8 | 002164: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
0042CA | 002165: 0EF0      	LD	RAMA[F0], r3	;RAMA[F0] <- AH
0042CC | 002166: 0013      	LD	r1, r3		;X <- AH
0042CE | 002167: 0224      	LD	r2, ptrA4		;Y <- [p_A0++]
0042D0 | 002168: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
0042D2 | 002169: 2001      	SUB	r3, r1		;ACC -= X
0042D4 | 00216A: 0E8A      	LD	RAMA[8A], r3	;RAMA[8A] <- AH
0042D6 | 00216B: 0238      	LD	r3, ptrA8		;AH <- [p_A0--!]
0042D8 | 00216C: 2002      	SUB	r3, r2		;ACC -= Y
0042DA | 00216D: 4D50 02AB 	BRA	z, 02AB		;PC <- 0556
0042DE | 00216F: 4C70 02BC 	BRA	ns, 02BC		;PC <- 0578
0042E2 | 002171: 0034      	LD	r3, r4		;AH <- ST
0042E4 | 002172: A6E8      	AND	r3, RAMA[E8]	;ACC &= RAMA[E8]
0042E6 | 002173: 0043      	LD	r4, r3		;ST <- AH
0042E8 | 002174: 0065      	LD	r6, r5		;PC <- STACK
0042EA | 002175: 3801      	SUB	r3, #01		;ACC -= #01
0042EC | 002176: 0E88      	LD	RAMA[88], r3	;RAMA[88] <- AH
0042EE | 002177: 87F3      	ADD	r3, RAMB[F3]	;ACC += RAMB[F3]
0042F0 | 002178: 4A10      	LD	r1, (r3)		;X <- (AH)
0042F2 | 002179: 0031      	LD	r3, r1		;AH <- X
0042F4 | 00217A: 0E8B      	LD	RAMA[8B], r3	;RAMA[8B] <- AH
0042F6 | 00217B: 0689      	LD	r3, A[89]		;AH <- A[89]
0042F8 | 00217C: 3801      	SUB	r3, #01		;ACC -= #01
0042FA | 00217D: 0E89      	LD	RAMA[89], r3	;RAMA[89] <- AH
0042FC | 00217E: 4C70 0292 	BRA	ns, 0292		;PC <- 0524
004300 | 002180: B800      	AND	r3, #00		;ACC &= #00
004302 | 002181: 06E9      	LD	r3, A[E9]		;AH <- A[E9]
004304 | 002182: 0E8F      	LD	RAMA[8F], r3	;RAMA[8F] <- AH
004306 | 002183: 0235      	LD	r3, ptrA5		;AH <- [p_A1++]
004308 | 002184: 0EF1      	LD	RAMA[F1], r3	;RAMA[F1] <- AH
00430A | 002185: 0013      	LD	r1, r3		;X <- AH
00430C | 002186: 0225      	LD	r2, ptrA5		;Y <- [p_A1++]
00430E | 002187: 0235      	LD	r3, ptrA5		;AH <- [p_A1++]
004310 | 002188: 2001      	SUB	r3, r1		;ACC -= X
004312 | 002189: 0E8D      	LD	RAMA[8D], r3	;RAMA[8D] <- AH
004314 | 00218A: 0239      	LD	r3, ptrA9		;AH <- [p_A1--!]
004316 | 00218B: 2002      	SUB	r3, r2		;ACC -= Y
004318 | 00218C: 4D50 02CA 	BRA	z, 02CA		;PC <- 0594
00431C | 00218E: 4D70 02B8 	BRA	s, 02B8		;PC <- 0570
004320 | 002190: 3801      	SUB	r3, #01		;ACC -= #01
004322 | 002191: 0E89      	LD	RAMA[89], r3	;RAMA[89] <- AH
004324 | 002192: 87F3      	ADD	r3, RAMB[F3]	;ACC += RAMB[F3]
004326 | 002193: 4A10      	LD	r1, (r3)		;X <- (AH)
004328 | 002194: 0031      	LD	r3, r1		;AH <- X
00432A | 002195: 0E8E      	LD	RAMA[8E], r3	;RAMA[8E] <- AH
00432C | 002196: 4C00 0292 	BRA	0292			;PC <- 0524
004330 | 002198: 033F      	LD	r3, ptrBF		;AH <- dp_B3
004332 | 002199: 6307      	CMP	r3, ptrB7		;ACC == dp_B1
004334 | 00219A: 4C70 02EA 	BRA	ns, 02EA		;PC <- 05D4
004338 | 00219C: 0317      	LD	r1, ptrB7		;X <- dp_B1
00433A | 00219D: 0537      	LD	ptrB7, r3		;dp_B1 <- AH
00433C | 00219E: 051F      	LD	ptrBF, r1		;dp_B3 <- X
00433E | 00219F: 033B      	LD	r3, ptrBB		;AH <- dp_B2
004340 | 0021A0: 0313      	LD	r1, ptrB3		;X <- dp_B0
004342 | 0021A1: 0533      	LD	ptrB3, r3		;dp_B0 <- AH
004344 | 0021A2: 051B      	LD	ptrBB, r1		;dp_B2 <- X
004346 | 0021A3: A000      	AND	r3, r0		;ACC &= R0
004348 | 0021A4: 023F      	LD	r3, ptrAF		;AH <- dp_A3
00434A | 0021A5: 6307      	CMP	r3, ptrB7		;ACC == dp_B1
00434C | 0021A6: 4D50 030B 	BRA	z, 030B		;PC <- 0616
004350 | 0021A8: 630F      	CMP	r3, ptrBF		;ACC == dp_B3
004352 | 0021A9: 4D50 030D 	BRA	z, 030D		;PC <- 061A
004356 | 0021AB: 0333      	LD	r3, ptrB3		;AH <- dp_B0
004358 | 0021AC: 830B      	ADD	r3, ptrBB		;ACC += dp_B2
00435A | 0021AD: 9801      	ADD	r3, #01		;ACC += #01
00435C | 0021AE: 9002      	SHR	ACC			;
00435E | 0021AF: 0013      	LD	r1, r3		;X <- AH
004360 | 0021B0: 0337      	LD	r3, ptrB7		;AH <- dp_B1
004362 | 0021B1: 830F      	ADD	r3, ptrBF		;ACC += dp_B3
004364 | 0021B2: 9801      	ADD	r3, #01		;ACC += #01
004366 | 0021B3: 9002      	SHR	ACC			;
004368 | 0021B4: 0023      	LD	r2, r3		;Y <- AH
00436A | 0021B5: A000      	AND	r3, r0		;ACC &= R0
00436C | 0021B6: 620F      	CMP	r3, ptrAF		;ACC == dp_A3
00436E | 0021B7: 4D50 030A 	BRA	z, 030A		;PC <- 0614
004372 | 0021B9: 4C70 0306 	BRA	ns, 0306		;PC <- 060C
004376 | 0021BB: 0513      	LD	ptrB3, r1		;dp_B0 <- X
004378 | 0021BC: 0527      	LD	ptrB7, r2		;dp_B1 <- Y
00437A | 0021BD: 4C00 02F2 	BRA	02F2			;PC <- 05E4
00437E | 0021BF: 051B      	LD	ptrBB, r1		;dp_B2 <- X
004380 | 0021C0: 052F      	LD	ptrBF, r2		;dp_B3 <- Y
004382 | 0021C1: 4C00 02F2 	BRA	02F2			;PC <- 05E4
004386 | 0021C3: 0065      	LD	r6, r5		;PC <- STACK
004388 | 0021C4: 0313      	LD	r1, ptrB3		;X <- dp_B0
00438A | 0021C5: 0065      	LD	r6, r5		;PC <- STACK
00438C | 0021C6: 031B      	LD	r1, ptrBB		;X <- dp_B2
00438E | 0021C7: 0065      	LD	r6, r5		;PC <- STACK
004390 | 0021C8: 1A00      	LD	pA2, #00		;pA2 <- #00
004392 | 0021C9: 0230      	LD	r3, ptrA0		;AH <- [p_A0]
004394 | 0021CA: 7800      	CMP	r3, #00		;ACC == #00
004396 | 0021CB: 4C70 0315 	BRA	ns, 0315		;PC <- 062A
00439A | 0021CD: 1A01      	LD	pA2, #01		;pA2 <- #01
00439C | 0021CE: 78FF      	CMP	r3, #FF		;ACC == #FF
00439E | 0021CF: 4D70 0319 	BRA	s, 0319		;PC <- 0632
0043A2 | 0021D1: 1A02      	LD	pA2, #02		;pA2 <- #02
0043A4 | 0021D2: 1232      	LD	r3, pA2		;AH <- p_A2
0043A6 | 0021D3: 0F08      	LD	RAMB[08], r3	;RAMB[08] <- AH
0043A8 | 0021D4: 0535      	LD	ptrB5, r3		;[p_B1++] <- AH
0043AA | 0021D5: 0214      	LD	r1, ptrA4		;X <- [p_A0++]
0043AC | 0021D6: 0224      	LD	r2, ptrA4		;Y <- [p_A0++]
0043AE | 0021D7: A000      	AND	r3, r0		;ACC &= R0
0043B0 | 0021D8: 4C50 0323 	BRA	nz, 0323		;PC <- 0646
0043B4 | 0021DA: 0514      	LD	ptrB4, r1		;[p_B0++] <- X
0043B6 | 0021DB: 0524      	LD	ptrB4, r2		;[p_B0++] <- Y
0043B8 | 0021DC: 1A00      	LD	pA2, #00		;pA2 <- #00
0043BA | 0021DD: 0230      	LD	r3, ptrA0		;AH <- [p_A0]
0043BC | 0021DE: 7800      	CMP	r3, #00		;ACC == #00
0043BE | 0021DF: 4C70 0329 	BRA	ns, 0329		;PC <- 0652
0043C2 | 0021E1: 1A01      	LD	pA2, #01		;pA2 <- #01
0043C4 | 0021E2: 78FF      	CMP	r3, #FF		;ACC == #FF
0043C6 | 0021E3: 4D70 032D 	BRA	s, 032D		;PC <- 065A
0043CA | 0021E5: 1A02      	LD	pA2, #02		;pA2 <- #02
0043CC | 0021E6: 1232      	LD	r3, pA2		;AH <- p_A2
0043CE | 0021E7: 0F09      	LD	RAMB[09], r3	;RAMB[09] <- AH
0043D0 | 0021E8: A708      	AND	r3, RAMB[08]	;ACC &= RAMB[08]
0043D2 | 0021E9: 4C50 0344 	BRA	nz, 0344		;PC <- 0688
0043D6 | 0021EB: 0708      	LD	r3, B[08]		;AH <- B[08]
0043D8 | 0021EC: C709      	OR	r3, RAMB[09]	;ACC |= RAMB[09]
0043DA | 0021ED: 4D50 0340 	BRA	z, 0340		;PC <- 0680
0043DE | 0021EF: 0708      	LD	r3, B[08]		;AH <- B[08]
0043E0 | 0021F0: 4800 0353 	CALL	0353			;PC <- 06A6
0043E4 | 0021F2: 0709      	LD	r3, B[09]		;AH <- B[09]
0043E6 | 0021F3: 4800 0353 	CALL	0353			;PC <- 06A6
0043EA | 0021F5: 0709      	LD	r3, B[09]		;AH <- B[09]
0043EC | 0021F6: A000      	AND	r3, r0		;ACC &= R0
0043EE | 0021F7: 4C50 0344 	BRA	nz, 0344		;PC <- 0688
0043F2 | 0021F9: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
0043F4 | 0021FA: 0534      	LD	ptrB4, r3		;[p_B0++] <- AH
0043F6 | 0021FB: 0238      	LD	r3, ptrA8		;AH <- [p_A0--!]
0043F8 | 0021FC: 0534      	LD	ptrB4, r3		;[p_B0++] <- AH
0043FA | 0021FD: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
0043FC | 0021FE: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
0043FE | 0021FF: 0205      	LD	r0, ptrA5		;R0 <- [p_A1++]
004400 | 002200: 0205      	LD	r0, ptrA5		;R0 <- [p_A1++]
004402 | 002201: 0709      	LD	r3, B[09]		;AH <- B[09]
004404 | 002202: 0F08      	LD	RAMB[08], r3	;RAMB[08] <- AH
004406 | 002203: 0204      	LD	r0, ptrA4		;R0 <- [p_A0++]
004408 | 002204: 0238      	LD	r3, ptrA8		;AH <- [p_A0--!]
00440A | 002205: 6000      	CMP	r3, r0		;ACC == R0
00440C | 002206: 4C50 0323 	BRA	nz, 0323		;PC <- 0646
004410 | 002208: 0500      	LD	ptrB0, r0		;[p_B0] <- R0
004412 | 002209: 0709      	LD	r3, B[09]		;AH <- B[09]
004414 | 00220A: 0535      	LD	ptrB5, r3		;[p_B1++] <- AH
004416 | 00220B: 0065      	LD	r6, r5		;PC <- STACK
004418 | 00220C: 0C0F 0000 	LD	ptrAF, #0000	;dp_A3 <- #0000
00441C | 00220E: 7801      	CMP	r3, #01		;ACC == #01
00441E | 00220F: 4D50 035D 	BRA	z, 035D		;PC <- 06BA
004422 | 002211: 0C0F 00FF 	LD	ptrAF, #00FF	;dp_A3 <- #00FF
004426 | 002213: 7802      	CMP	r3, #02		;ACC == #02
004428 | 002214: 4C50 036A 	BRA	nz, 036A		;PC <- 06D4
00442C | 002216: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
00442E | 002217: 0537      	LD	ptrB7, r3		;dp_B1 <- AH
004430 | 002218: 0238      	LD	r3, ptrA8		;AH <- [p_A0--!]
004432 | 002219: 0533      	LD	ptrB3, r3		;dp_B0 <- AH
004434 | 00221A: 0235      	LD	r3, ptrA5		;AH <- [p_A1++]
004436 | 00221B: 053F      	LD	ptrBF, r3		;dp_B3 <- AH
004438 | 00221C: 0239      	LD	r3, ptrA9		;AH <- [p_A1--!]
00443A | 00221D: 053B      	LD	ptrBB, r3		;dp_B2 <- AH
00443C | 00221E: 4800 02DF 	CALL	02DF			;PC <- 05BE
004440 | 002220: 023F      	LD	r3, ptrAF		;AH <- dp_A3
004442 | 002221: 0534      	LD	ptrB4, r3		;[p_B0++] <- AH
004444 | 002222: 0514      	LD	ptrB4, r1		;[p_B0++] <- X
004446 | 002223: 0065      	LD	r6, r5		;PC <- STACK
004448 | 002224: 0214      	LD	r1, ptrA4		;X <- [p_A0++]
00444A | 002225: 0234      	LD	r3, ptrA4		;AH <- [p_A0++]
00444C | 002226: A000      	AND	r3, r0		;ACC &= R0
00444E | 002227: 4D70 037B 	BRA	s, 037B		;PC <- 06F6
004452 | 002229: 0031      	LD	r3, r1		;AH <- X
004454 | 00222A: 6706      	CMP	r3, RAMB[06]	;ACC == RAMB[06]
004456 | 00222B: 4C70 0375 	BRA	ns, 0375		;PC <- 06EA
00445A | 00222D: 0F06      	LD	RAMB[06], r3	;RAMB[06] <- AH
00445C | 00222E: 6707      	CMP	r3, RAMB[07]	;ACC == RAMB[07]
00445E | 00222F: 4D70 036B 	BRA	s, 036B		;PC <- 06D6
004462 | 002231: 0F07      	LD	RAMB[07], r3	;RAMB[07] <- AH
004464 | 002232: 4C00 036B 	BRA	036B			;PC <- 06D6
004468 | 002234: 0065      	LD	r6, r5		;PC <- STACK

L_I037c:
00446A | 002235: 0038      	LD	r3, r8		;AH <- EXT0
00446C | 002236: 3801      	SUB	r3, #01		;ACC -= #01
00446E | 002237: 4D70 0399 	BRA	s, 0399		;PC <- 0732
004472 | 002239: 0EFC      	LD	RAMA[FC], r3	;RAMA[FC] <- AH
004474 | 00223A: 003E      	LD	r3, rE		;AH <- EXT6
004476 | 00223B: 000E      	LD	r0, rE		;R0 <- EXT6
004478 | 00223C: 86FD      	ADD	r3, RAMA[FD]	;ACC += RAMA[FD]
00447A | 00223D: 00E3      	LD	rE, r3		;EXT6 <- AH
00447C | 00223E: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
004480 | 002240: 0080      	LD	r8, r0		;EXT0 <- R0
004482 | 002241: 0880 0000 	LD	r8, #0000		;EXT0 <- #0000
004486 | 002243: 000E      	LD	r0, rE		;R0 <- EXT6
004488 | 002244: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
00448C | 002246: 0009      	LD	r0, r9		;R0 <- EXT1
L_I038E:
00448E | 002247: 0039      	LD	r3, r9		;AH <- EXT1
004490 | 002248: 00E3      	LD	rE, r3		;EXT6 <- AH
004492 | 002249: 000E      	LD	r0, rE		;R0 <- EXT6
004494 | 00224A: 000C      	LD	r0, rC		;R0 <- EXT4
004496 | 00224B: 4800 0097 	CALL	0097			;PC <- 012E
00449A | 00224D: 06FC      	LD	r3, A[FC]		;AH <- A[FC]
00449C | 00224E: 3801      	SUB	r3, #01		;ACC -= #01
00449E | 00224F: 0EFC      	LD	RAMA[FC], r3	;RAMA[FC] <- AH
0044A0 | 002250: 4C70 038E 	BRA	ns, 038E		;PC <- 071C
L_I0399:
0044A4 | 002252: 06FA      	LD	r3, A[FA]		;AH <- A[FA]
0044A6 | 002253: 3801      	SUB	r3, #01		;ACC -= #01
0044A8 | 002254: 0EFA      	LD	RAMA[FA], r3	;RAMA[FA] <- AH
0044AA | 002255: 4C70 037C 	BRA	ns, 037C		;PC <- 06F8
0044AE | 002257: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
0044B0 | 002258: 1531      	LD	pB1, r3		;p_B1 <- AH
0044B2 | 002259: 9801      	ADD	r3, #01		;ACC += #01
0044B4 | 00225A: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
0044B6 | 00225B: 0361      	LD	r6, ptrB1		;PC <- [p_B1]
0044B8 | 00225C: 07E3      	LD	r3, B[E3]		;AH <- B[E3]
0044BA | 00225D: 3801      	SUB	r3, #01		;ACC -= #01
0044BC | 00225E: 0FE3      	LD	RAMB[E3], r3	;RAMB[E3] <- AH
0044BE | 00225F: 4800 0097 	CALL	0097			;PC <- 012E
0044C2 | 002261: 07E3      	LD	r3, B[E3]		;AH <- B[E3]
0044C4 | 002262: 3801      	SUB	r3, #01		;ACC -= #01
0044C6 | 002263: 0FE3      	LD	RAMB[E3], r3	;RAMB[E3] <- AH
0044C8 | 002264: 4C70 03A6 	BRA	ns, 03A6		;PC <- 074C
0044CC | 002266: 07F0      	LD	r3, B[F0]		;AH <- B[F0]
0044CE | 002267: 1531      	LD	pB1, r3		;p_B1 <- AH
0044D0 | 002268: 9801      	ADD	r3, #01		;ACC += #01
0044D2 | 002269: 0FF0      	LD	RAMB[F0], r3	;RAMB[F0] <- AH
0044D4 | 00226A: 0361      	LD	r6, ptrB1		;PC <- [p_B1]





L_2784:
004F08 | 002784: 08E0 7F03 	LD	rE, #7F03		;EXT6 <- #7F03
004F0C | 002786: 08E0 0018 	LD	rE, #0018		;EXT6 <- #0018
004F10 | 002788: 000C      	LD	r0, rC		;R0 <- EXT4
004F12 | 002789: 003C      	LD	r3, rC		;AH <- EXT4
004F14 | 00278A: A000      	AND	r3, r0		;ACC &= R0
004F16 | 00278B: 4D50 2789 	BRA	z, 2789		;PC <- 4F12
004F1A | 00278D: 000E      	LD	r0, rE		;R0 <- EXT6
004F1C | 00278E: 08E0 0018 	LD	rE, #0018		;EXT6 <- #0018
004F20 | 002790: 00C0      	LD	rC, r0		;EXT4 <- R0
004F22 | 002791: 08C0 0000 	LD	rC, #0000		;EXT4 <- #0000
004F26 | 002793: 0065      	LD	r6, r5		;PC <- STACK

L_2794:
004F28 | 002794: 08E0 7F01 	LD	rE, #7F01		;EXT6 <- #7F01
004F2C | 002796: 08E0 0018 	LD	rE, #0018		;EXT6 <- #0018
004F30 | 002798: 00C0      	LD	rC, r0		;EXT4 <- R0
004F32 | 002799: 08C0 0001 	LD	rC, #0001		;EXT4 <- #0001
004F36 | 00279B: 0065      	LD	r6, r5		;PC <- STACK

004F38 | 00279C: 02E3      	LD	rE, ptrA3		;EXT6 <- dp_A0
004F3A | 00279D: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
004F3E | 00279F: 00C0      	LD	rC, r0		;EXT4 <- R0
004F40 | 0027A0: 0237      	LD	r3, ptrA7		;AH <- dp_A1
004F42 | 0027A1: 8800 27AB 	ADD	r3, #27AB		;ACC += #27AB
004F46 | 0027A3: 4A10      	LD	r1, (r3)		;X <- (AH)
004F48 | 0027A4: 0417      	LD	ptrA7, r1		;dp_A1 <- X
004F4A | 0027A5: 0A37      	LD	r3, *ptrA7		;AH <- ???
004F4C | 0027A6: 00C3      	LD	rC, r3		;EXT4 <- AH
004F4E | 0027A7: A000      	AND	r3, r0		;ACC &= R0
004F50 | 0027A8: 4C50 27A5 	BRA	nz, 27A5		;PC <- 4F4A
004F54 | 0027AA: 0065      	LD	r6, r5		;PC <- STACK



L_C004:								:start test mode
018008 | 00C004: 4C00 C200 	BRA	C200			;PC <- 18400

L_C200:
018400 | 00C200: 08E0 00E5 	LD	rE, #00E5		;EXT6 <- #00E5
018404 | 00C202: 08E0 0800 	LD	rE, #0800		;EXT6 <- #0800
018408 | 00C204: 000C      	LD	r0, rC		;R0 <- EXT4
01840A | 00C205: 003C      	LD	r3, rC		;AH <- EXT4
01840C | 00C206: A800 1C00 	AND	r3, #1C00		;ACC &= #1C00
018410 | 00C208: 0FCB      	LD	RAMB[CB], r3	;RAMB[CB] <- AH
018412 | 00C209: 0840 0000 	LD	r4, #0000		;ST <- #0000
018416 | 00C20B: 0083      	LD	r8, r3		;EXT0 <- AH
018418 | 00C20C: 1EF8      	LD	pB2, #F8		;pB2 <- #F8
01841A | 00C20D: 0D02 FFFC 	LD	ptrB2, #FFFC	;[p_B2] <- #FFFC
01841E | 00C20F: 0B32      	LD	r3, *ptrB2		;AH <- ([p_B2]++)
018420 | 00C210: 0B32      	LD	r3, *ptrB2		;AH <- ([p_B2]++)
018422 | 00C211: 0B32      	LD	r3, *ptrB2		;AH <- ([p_B2]++)
018424 | 00C212: 0B32      	LD	r3, *ptrB2		;AH <- ([p_B2]++)
018426 | 00C213: 0830 0000 	LD	r3, #0000		;AH <- #0000
01842A | 00C215: 1430      	LD	pA0, r3		;p_A0 <- AH
01842C | 00C216: 1431      	LD	pA1, r3		;p_A1 <- AH
01842E | 00C217: 1432      	LD	pA2, r3		;p_A2 <- AH
018430 | 00C218: 1530      	LD	pB0, r3		;p_B0 <- AH
018432 | 00C219: 1531      	LD	pB1, r3		;p_B1 <- AH
018434 | 00C21A: 1EF8      	LD	pB2, #F8		;pB2 <- #F8
018436 | 00C21B: 08E0 83FA 	LD	rE, #83FA		;EXT6 <- #83FA
01843A | 00C21D: 08E0 081C 	LD	rE, #081C		;EXT6 <- #081C
01843E | 00C21F: 00C0      	LD	rC, r0		;EXT4 <- R0
018440 | 00C220: 0830 0860 	LD	r3, #0860		;AH <- #0860
018444 | 00C222: 00C3      	LD	rC, r3		;EXT4 <- AH
018446 | 00C223: 08C0 C8F6 	LD	rC, #C8F6		;EXT4 <- #C8F6
01844A | 00C225: 00C3      	LD	rC, r3		;EXT4 <- AH
01844C | 00C226: 08C0 C906 	LD	rC, #C906		;EXT4 <- #C906
018450 | 00C228: 00C3      	LD	rC, r3		;EXT4 <- AH
018452 | 00C229: 08C0 C912 	LD	rC, #C912		;EXT4 <- #C912
018456 | 00C22B: 0830 0000 	LD	r3, #0000		;AH <- #0000
01845A | 00C22D: 0FF8      	LD	RAMB[F8], r3	;RAMB[F8] <- AH
01845C | 00C22E: 0FF9      	LD	RAMB[F9], r3	;RAMB[F9] <- AH
01845E | 00C22F: 0FFA      	LD	RAMB[FA], r3	;RAMB[FA] <- AH
018460 | 00C230: 0FFB      	LD	RAMB[FB], r3	;RAMB[FB] <- AH
018462 | 00C231: 0840 0000 	LD	r4, #0000		;ST <- #0000
L_C233:
018466 | 00C233: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018468 | 00C234: 0D02 C238 	LD	ptrB2, #C238	;[p_B2] <- #C238		param for L_C289 to jump 
01846C | 00C236: 0860 C289 	LD	r6, #C289		;PC <- #C289		goto L_C289

L_C238:
018470 | 00C238: 0013      	LD	r1, r3		;X <- AH			command 
018472 | 00C239: 0830 FFFF 	LD	r3, #FFFF		;AH <- #FFFF
018476 | 00C23B: E001      	EOR	r3, r1		;ACC ^= X
018478 | 00C23C: 4D50 C265 	BRA	z, C265		;PC <- 184CA		goto L_C265 if command  == FFFF
01847C | 00C23E: 0830 474F 	LD	r3, #474F		;AH <- #474F
018480 | 00C240: E001      	EOR	r3, r1		;ACC ^= X
018482 | 00C241: 4D50 C26E 	BRA	z, C26E		;PC <- 184DC		goto L_C26E if command  == "GO"
018486 | 00C243: 0830 5356 	LD	r3, #5356		;AH <- #5356		
01848A | 00C245: E001      	EOR	r3, r1		;ACC ^= X
01848C | 00C246: 4D50 C251 	BRA	z, C251		;PC <- 184A2		goto L_C251 if command  == "SV"
018490 | 00C248: 0031      	LD	r3, r1		;AH <- X
018492 | 00C249: A800 FF00 	AND	r3, #FF00		;ACC &= #FF00
018496 | 00C24B: E800 5400 	EOR	r3, #5400		;ACC ^= #5400
01849A | 00C24D: 4D50 C255 	BRA	z, C255		;PC <- 184AA		goto L_C255 if command  == "T?"
01849E | 00C24F: 0860 C233 	LD	r6, #C233		;PC <- #C233
L_C251:
0184A2 | 00C251: 0830 4F4B 	LD	r3, #4F4B		;AH <- #4F4B
0184A6 | 00C253: 0860 C267 	LD	r6, #C267		;PC <- #C267
L_C255:
0184AA | 00C255: 0031      	LD	r3, r1		;AH <- X
0184AC | 00C256: A800 00FF 	AND	r3, #00FF		;ACC &= #00FF
0184B0 | 00C258: 8003      	ADD	r3, r3		;ACC += AH
0184B2 | 00C259: 8800 C27D 	ADD	r3, #C27D		;ACC += #C27D
0184B6 | 00C25B: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
0184B8 | 00C25C: 0D02 C25F 	LD	ptrB2, #C25F	;[p_B2] <- #C25F
0184BC | 00C25E: 0063      	LD	r6, r3		;PC <- AH			call L_C27D+(X*2)
0184BE | 00C25F: A800 00FF 	AND	r3, #00FF		;ACC &= #00FF
0184C2 | 00C261: C800 5300 	OR	r3, #5300		;ACC |= #5300
0184C6 | 00C263: 0860 C267 	LD	r6, #C267		;PC <- #C267		goto L_C267 
L_C265:
0184CA | 00C265: 0830 0000 	LD	r3, #0000		;AH <- #0000
L_C267:
0184CE | 00C267: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
0184D0 | 00C268: 0D02 C26C 	LD	ptrB2, #C26C	;[p_B2] <- #C26C
0184D4 | 00C26A: 0860 C299 	LD	r6, #C299		;PC <- #C299		call L_C299
0184D8 | 00C26C: 0860 C233 	LD	r6, #C233		;PC <- #C233		goto L_C233
L_C26E:
0184DC | 00C26E: 0830 4F4B 	LD	r3, #4F4B		;AH <- #4F4B
0184E0 | 00C270: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
0184E2 | 00C271: 0D02 C275 	LD	ptrB2, #C275	;[p_B2] <- #C275
0184E6 | 00C273: 0860 C299 	LD	r6, #C299		;PC <- #C299		call L_C299
0184EA | 00C275: 0860 C275 	LD	r6, #C275		;PC <- #C275		goto L_C275 
L_C277:
0184EE | 00C277: 0830 0000 	LD	r3, #0000		;AH <- #0000
0184F2 | 00C279: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
0184F4 | 00C27A: 0830 FFFF 	LD	r3, #FFFF		;AH <- #FFFF
0184F8 | 00C27C: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
L_C27D:
0184FA | 00C27D: 0860 C5A3 	LD	r6, #C5A3		;PC <- #C5A3
0184FE | 00C27F: 0860 C5F2 	LD	r6, #C5F2		;PC <- #C5F2
018502 | 00C281: 0860 C739 	LD	r6, #C739		;PC <- #C739
018506 | 00C283: 0860 C2A3 	LD	r6, #C2A3		;PC <- #C2A3
01850A | 00C285: 0860 C7BF 	LD	r6, #C7BF		;PC <- #C7BF
01850E | 00C287: 0860 C277 	LD	r6, #C277		;PC <- #C277

L_C289:								; (addr func in [p_B2])
018512 | 00C289: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018514 | 00C28A: 0542      	LD	ptrB2, r4		;[p_B2] <- ST
018516 | 00C28B: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018518 | 00C28C: 0512      	LD	ptrB2, r1		;[p_B2] <- X
01851A | 00C28D: 0840 0000 	LD	r4, #0000		;ST <- #0000
01851E | 00C28F: 0038      	LD	r3, r8		;AH <- EXT0
018520 | 00C290: A800 0002 	AND	r3, #0002		;ACC &= #0002
018524 | 00C292: 4D50 C28F 	BRA	z, C28F		;PC <- 1851E
018528 | 00C294: 001B      	LD	r1, rB		;X <- EXT3
01852A | 00C295: 0031      	LD	r3, r1		;AH <- X			command from 68000
01852C | 00C296: 031E      	LD	r1, ptrBE		;X <- [p_B2++!]
01852E | 00C297: 034E      	LD	r4, ptrBE		;ST <- [p_B2++!]
018530 | 00C298: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]		jump to addr func

L_C299:
018532 | 00C299: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018534 | 00C29A: 0532      	LD	ptrB2, r3		;[p_B2] <- AH
018536 | 00C29B: 0840 0000 	LD	r4, #0000		;ST <- #0000
01853A | 00C29D: 0038      	LD	r3, r8		;AH <- EXT0
01853C | 00C29E: E800 0000 	EOR	r3, #0000		;ACC ^= #0000
018540 | 00C2A0: 033E      	LD	r3, ptrBE		;AH <- [p_B2++!]
018542 | 00C2A1: 00B3      	LD	rB, r3		;EXT3 <- AH
018544 | 00C2A2: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]







L_I0000:								;test ROM 0800-FFFF main
018B54 | 00C5AA: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018B56 | 00C5AB: 0512      	LD	ptrB2, r1		;[p_B2] <- X
018B58 | 00C5AC: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018B5A | 00C5AD: 0522      	LD	ptrB2, r2		;[p_B2] <- Y
018B5C | 00C5AE: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018B5E | 00C5AF: 0542      	LD	ptrB2, r4		;[p_B2] <- ST
018B60 | 00C5B0: 0840 0060 	LD	r4, #0060		;ST <- #0060
018B64 | 00C5B2: 0810 000A 	LD	r1, #000A		;X <- #000A
L_I000A:
018B68 | 00C5B4: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018B6A | 00C5B5: 0512      	LD	ptrB2, r1		;[p_B2] <- X
018B6C | 00C5B6: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018B6E | 00C5B7: 0D02 0011 	LD	ptrB2, #0011	;[p_B2] <- #0011
018B72 | 00C5B9: 0860 0028 	LD	r6, #0028		;PC <- #0028		call L_I0028
018B76 | 00C5BB: E800 0001 	EOR	r3, #0001		;ACC ^= #0001
018B7A | 00C5BD: 4C50 0021 	BRA	nz, 0021		;PC <- 0042			goto L_I0021
018B7E | 00C5BF: 033E      	LD	r3, ptrBE		;AH <- [p_B2++!]
018B80 | 00C5C0: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018B84 | 00C5C2: 0013      	LD	r1, r3		;X <- AH
018B86 | 00C5C3: 4C50 000A 	BRA	nz, 000A		;PC <- 0014			goto L_I000A
018B8A | 00C5C5: 034E      	LD	r4, ptrBE		;ST <- [p_B2++!]
018B8C | 00C5C6: 032E      	LD	r2, ptrBE		;Y <- [p_B2++!]
018B8E | 00C5C7: 031E      	LD	r1, ptrBE		;X <- [p_B2++!]
018B90 | 00C5C8: 0830 0001 	LD	r3, #0001		;AH <- #0001
018B94 | 00C5CA: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]		return 1 PASS
L_I0021:
018B96 | 00C5CB: 031E      	LD	r1, ptrBE		;X <- [p_B2++!]
018B98 | 00C5CC: 034E      	LD	r4, ptrBE		;ST <- [p_B2++!]
018B9A | 00C5CD: 032E      	LD	r2, ptrBE		;Y <- [p_B2++!]
018B9C | 00C5CE: 031E      	LD	r1, ptrBE		;X <- [p_B2++!]
018B9E | 00C5CF: 0830 0002 	LD	r3, #0002		;AH <- #0002
018BA2 | 00C5D1: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]		return 2 FAIL

L_I0028:								;test ROM 0800-FFFF sub
018BA4 | 00C5D2: 1800      	LD	pA0, #00		;pA0 <- #00
018BA6 | 00C5D3: 0C00 0400 	LD	ptrA0, #0400	;[p_A0] <- #0400
018BAA | 00C5D5: 08E0 0400 	LD	rE, #0400		;EXT6 <- #0400
018BAE | 00C5D7: 08E0 0800 	LD	rE, #0800		;EXT6 <- #0800
018BB2 | 00C5D9: 0009      	LD	r0, r9		;R0 <- EXT1
018BB4 | 00C5DA: 0810 7C00 	LD	r1, #7C00		;X <- #7C00
018BB8 | 00C5DC: 08F0 0000 	LD	rF, #0000		;AL <- #0000
L_I0034:
018BBC | 00C5DE: 0039      	LD	r3, r9		;AH <- EXT1
018BBE | 00C5DF: EA00      	EOR	r3, *ptrA0		;ACC ^= ([p_A0]++)
018BC0 | 00C5E0: 4C50 0045 	BRA	nz, 0045		;PC <- 008A			goto L_I0045
018BC4 | 00C5E2: 0039      	LD	r3, r9		;AH <- EXT1
018BC6 | 00C5E3: EA00      	EOR	r3, *ptrA0		;ACC ^= ([p_A0]++)
018BC8 | 00C5E4: 4C50 0045 	BRA	nz, 0045		;PC <- 008A			goto L_I0045
018BCC | 00C5E6: 0031      	LD	r3, r1		;AH <- X
018BCE | 00C5E7: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018BD2 | 00C5E9: 0013      	LD	r1, r3		;X <- AH
018BD4 | 00C5EA: 4C50 0034 	BRA	nz, 0034		;PC <- 0068			goto L_I0034
L_I0042:								
018BD8 | 00C5EC: 0830 0001 	LD	r3, #0001		;AH <- #0001
018BDC | 00C5EE: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]		return 1
L_I0045:
018BDE | 00C5EF: 0830 0002 	LD	r3, #0002		;AH <- #0002
018BE2 | 00C5F1: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]		return 2
018BE4 | 00C5F2: 0830 C5F6 	LD	r3, #C5F6		;AH <- #C5F6
018BE8 | 00C5F4: 0860 C8DA 	LD	r6, #C8DA		;PC <- #C8DA

L_C5F6:
018BEC | 00C5F6: C5F9
018BEE | 00C5F7: 0140
018BF0 | 00C5F8: 0000
L_I0000:
018BF2 | 00C5F9: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018BF4 | 00C5FA: 0512      	LD	ptrB2, r1		;[p_B2] <- X
018BF6 | 00C5FB: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018BF8 | 00C5FC: 0522      	LD	ptrB2, r2		;[p_B2] <- Y
018BFA | 00C5FD: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018BFC | 00C5FE: 0542      	LD	ptrB2, r4		;[p_B2] <- ST
018BFE | 00C5FF: 0840 0060 	LD	r4, #0060		;ST <- #0060
018C02 | 00C601: 0810 0004 	LD	r1, #0004		;X <- #0004
018C06 | 00C603: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018C08 | 00C604: 0512      	LD	ptrB2, r1		;[p_B2] <- X
018C0A | 00C605: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018C0C | 00C606: 0D02 0011 	LD	ptrB2, #0011	;[p_B2] <- #0011
018C10 | 00C608: 0860 0032 	LD	r6, #0032		;PC <- #0032		goto L_I0032


018C14 | 00C60A: E800 0001 	EOR	r3, #0001		;ACC ^= #0001
018C18 | 00C60C: 4C50 0026 	BRA	nz, 0026		;PC <- 004C
018C1C | 00C60E: 033E      	LD	r3, ptrBE		;AH <- [p_B2++!]
018C1E | 00C60F: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018C22 | 00C611: 0013      	LD	r1, r3		;X <- AH
018C24 | 00C612: 4C50 000A 	BRA	nz, 000A		;PC <- 0014
018C28 | 00C614: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018C2A | 00C615: 0D02 0020 	LD	ptrB2, #0020	;[p_B2] <- #0020
018C2E | 00C617: 0860 0127 	LD	r6, #0127		;PC <- #0127		call L_I0127
018C32 | 00C619: 034E      	LD	r4, ptrBE		;ST <- [p_B2++!]
018C34 | 00C61A: 032E      	LD	r2, ptrBE		;Y <- [p_B2++!]
018C36 | 00C61B: 031E      	LD	r1, ptrBE		;X <- [p_B2++!]
018C38 | 00C61C: 0830 0001 	LD	r3, #0001		;AH <- #0001
018C3C | 00C61E: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
018C3E | 00C61F: 031E      	LD	r1, ptrBE		;X <- [p_B2++!]
018C40 | 00C620: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018C42 | 00C621: 0D02 002C 	LD	ptrB2, #002C	;[p_B2] <- #002C
018C46 | 00C623: 0860 0127 	LD	r6, #0127		;PC <- #0127		call L_I0127
018C4A | 00C625: 034E      	LD	r4, ptrBE		;ST <- [p_B2++!]
018C4C | 00C626: 032E      	LD	r2, ptrBE		;Y <- [p_B2++!]
018C4E | 00C627: 031E      	LD	r1, ptrBE		;X <- [p_B2++!]
018C50 | 00C628: 0830 0002 	LD	r3, #0002		;AH <- #0002
018C54 | 00C62A: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]

L_I0032:
018C56 | 00C62B: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018C58 | 00C62C: 0D02 0037 	LD	ptrB2, #0037	;[p_B2] <- #0037
018C5C | 00C62E: 0860 0127 	LD	r6, #0127		;PC <- #0127		call L_I0127	clear DRAM
018C60 | 00C630: 08E0 0000 	LD	rE, #0000		;EXT6 <- #0000
018C64 | 00C632: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
018C68 | 00C634: 0009      	LD	r0, r9		;R0 <- EXT1
018C6A | 00C635: 0810 4000 	LD	r1, #4000		;X <- #4000
018C6E | 00C637: 08F0 0000 	LD	rF, #0000		;AL <- #0000
L_I0040:
018C72 | 00C639: 0820 0004 	LD	r2, #0004		;Y <- #0004
L_I0042:
018C76 | 00C63B: 0039      	LD	r3, r9		;AH <- EXT1
018C78 | 00C63C: E800 0000 	EOR	r3, #0000		;ACC ^= #0000
018C7C | 00C63E: 4C50 0124 	BRA	nz, 0124		;PC <- 0248			goto L_I0124
018C80 | 00C640: 0032      	LD	r3, r2		;AH <- Y
018C82 | 00C641: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018C86 | 00C643: 0023      	LD	r2, r3		;Y <- AH
018C88 | 00C644: 4C50 0042 	BRA	nz, 0042		;PC <- 0084			goto L_I0042
018C8C | 00C646: 0031      	LD	r3, r1		;AH <- X
018C8E | 00C647: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018C92 | 00C649: 0013      	LD	r1, r3		;X <- AH
018C94 | 00C64A: 4C50 0040 	BRA	nz, 0040		;PC <- 0080			goto L_I0040
018C98 | 00C64C: 08E0 0002 	LD	rE, #0002		;EXT6 <- #0002
018C9C | 00C64E: 08E0 0800 	LD	rE, #0800		;EXT6 <- #0800
018CA0 | 00C650: 0008      	LD	r0, r8		;R0 <- EXT0
018CA2 | 00C651: 08E0 0002 	LD	rE, #0002		;EXT6 <- #0002
018CA6 | 00C653: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
018CAA | 00C655: 0080      	LD	r8, r0		;EXT0 <- R0
018CAC | 00C656: 0810 3FFE 	LD	r1, #3FFE		;X <- #3FFE
018CB0 | 00C658: 08F0 0000 	LD	rF, #0000		;AL <- #0000
L_I0061:
018CB4 | 00C65A: 0820 0004 	LD	r2, #0004		;Y <- #0004
L_I0063:
018CB8 | 00C65C: 0038      	LD	r3, r8		;AH <- EXT0
018CBA | 00C65D: 0083      	LD	r8, r3		;EXT0 <- AH
018CBC | 00C65E: 0032      	LD	r3, r2		;AH <- Y
018CBE | 00C65F: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018CC2 | 00C661: 0023      	LD	r2, r3		;Y <- AH
018CC4 | 00C662: 4C50 0063 	BRA	nz, 0063		;PC <- 00C6
018CC8 | 00C664: 0031      	LD	r3, r1		;AH <- X
018CCA | 00C665: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018CCE | 00C667: 0013      	LD	r1, r3		;X <- AH
018CD0 | 00C668: 4C50 0061 	BRA	nz, 0061		;PC <- 00C2
018CD4 | 00C66A: 08E0 0002 	LD	rE, #0002		;EXT6 <- #0002
018CD8 | 00C66C: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
018CDC | 00C66E: 0008      	LD	r0, r8		;R0 <- EXT0
018CDE | 00C66F: 08E0 0002 	LD	rE, #0002		;EXT6 <- #0002
018CE2 | 00C671: 08E0 0800 	LD	rE, #0800		;EXT6 <- #0800
018CE6 | 00C673: 0009      	LD	r0, r9		;R0 <- EXT1
018CE8 | 00C674: 0810 3FFE 	LD	r1, #3FFE		;X <- #3FFE
018CEC | 00C676: 08F0 0000 	LD	rF, #0000		;AL <- #0000
018CF0 | 00C678: 0820 0004 	LD	r2, #0004		;Y <- #0004
018CF4 | 00C67A: 0039      	LD	r3, r9		;AH <- EXT1
018CF6 | 00C67B: E008      	EOR	r3, r8		;ACC ^= EXT0
018CF8 | 00C67C: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018CFC | 00C67E: 0032      	LD	r3, r2		;AH <- Y
018CFE | 00C67F: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018D02 | 00C681: 0023      	LD	r2, r3		;Y <- AH
018D04 | 00C682: 4C50 0081 	BRA	nz, 0081		;PC <- 0102
018D08 | 00C684: 0031      	LD	r3, r1		;AH <- X
018D0A | 00C685: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018D0E | 00C687: 0013      	LD	r1, r3		;X <- AH
018D10 | 00C688: 4C50 007F 	BRA	nz, 007F		;PC <- 00FE
018D14 | 00C68A: 08E0 0002 	LD	rE, #0002		;EXT6 <- #0002
018D18 | 00C68C: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
018D1C | 00C68E: 0080      	LD	r8, r0		;EXT0 <- R0
018D1E | 00C68F: 0810 2AA8 	LD	r1, #2AA8		;X <- #2AA8
018D22 | 00C691: 08F0 0000 	LD	rF, #0000		;AL <- #0000
018D26 | 00C693: 0880 000F 	LD	r8, #000F		;EXT0 <- #000F
018D2A | 00C695: 0880 00FF 	LD	r8, #00FF		;EXT0 <- #00FF
018D2E | 00C697: 0880 00F0 	LD	r8, #00F0		;EXT0 <- #00F0
018D32 | 00C699: 0880 0FF0 	LD	r8, #0FF0		;EXT0 <- #0FF0
018D36 | 00C69B: 0880 0F00 	LD	r8, #0F00		;EXT0 <- #0F00
018D3A | 00C69D: 0880 0F0F 	LD	r8, #0F0F		;EXT0 <- #0F0F
018D3E | 00C69F: 0031      	LD	r3, r1		;AH <- X
018D40 | 00C6A0: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018D44 | 00C6A2: 0013      	LD	r1, r3		;X <- AH
018D46 | 00C6A3: 4C50 009A 	BRA	nz, 009A		;PC <- 0134
018D4A | 00C6A5: 08E0 0002 	LD	rE, #0002		;EXT6 <- #0002
018D4E | 00C6A7: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
018D52 | 00C6A9: 0008      	LD	r0, r8		;R0 <- EXT0
018D54 | 00C6AA: 0810 2AA8 	LD	r1, #2AA8		;X <- #2AA8
018D58 | 00C6AC: 08F0 0000 	LD	rF, #0000		;AL <- #0000
018D5C | 00C6AE: 0038      	LD	r3, r8		;AH <- EXT0
018D5E | 00C6AF: E800 000F 	EOR	r3, #000F		;ACC ^= #000F
018D62 | 00C6B1: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018D66 | 00C6B3: 0038      	LD	r3, r8		;AH <- EXT0
018D68 | 00C6B4: E800 00FF 	EOR	r3, #00FF		;ACC ^= #00FF
018D6C | 00C6B6: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018D70 | 00C6B8: 0038      	LD	r3, r8		;AH <- EXT0
018D72 | 00C6B9: E800 00F0 	EOR	r3, #00F0		;ACC ^= #00F0
018D76 | 00C6BB: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018D7A | 00C6BD: 0038      	LD	r3, r8		;AH <- EXT0
018D7C | 00C6BE: E800 0FF0 	EOR	r3, #0FF0		;ACC ^= #0FF0
018D80 | 00C6C0: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018D84 | 00C6C2: 0038      	LD	r3, r8		;AH <- EXT0
018D86 | 00C6C3: E800 0F00 	EOR	r3, #0F00		;ACC ^= #0F00
018D8A | 00C6C5: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018D8E | 00C6C7: 0038      	LD	r3, r8		;AH <- EXT0
018D90 | 00C6C8: E800 0F0F 	EOR	r3, #0F0F		;ACC ^= #0F0F
018D94 | 00C6CA: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018D98 | 00C6CC: 0031      	LD	r3, r1		;AH <- X
018D9A | 00C6CD: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018D9E | 00C6CF: 0013      	LD	r1, r3		;X <- AH
018DA0 | 00C6D0: 4C50 00B5 	BRA	nz, 00B5		;PC <- 016A
018DA4 | 00C6D2: 08E0 0002 	LD	rE, #0002		;EXT6 <- #0002
018DA8 | 00C6D4: 08E0 0C18 	LD	rE, #0C18		;EXT6 <- #0C18
018DAC | 00C6D6: 0080      	LD	r8, r0		;EXT0 <- R0
018DAE | 00C6D7: 0810 2AA8 	LD	r1, #2AA8		;X <- #2AA8
018DB2 | 00C6D9: 08F0 0000 	LD	rF, #0000		;AL <- #0000
018DB6 | 00C6DB: 0880 000F 	LD	r8, #000F		;EXT0 <- #000F
018DBA | 00C6DD: 0880 00FF 	LD	r8, #00FF		;EXT0 <- #00FF
018DBE | 00C6DF: 0880 00F0 	LD	r8, #00F0		;EXT0 <- #00F0
018DC2 | 00C6E1: 0880 0FF0 	LD	r8, #0FF0		;EXT0 <- #0FF0
018DC6 | 00C6E3: 0880 0F00 	LD	r8, #0F00		;EXT0 <- #0F00
018DCA | 00C6E5: 0880 0F0F 	LD	r8, #0F0F		;EXT0 <- #0F0F
018DCE | 00C6E7: 0031      	LD	r3, r1		;AH <- X
018DD0 | 00C6E8: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018DD4 | 00C6EA: 0013      	LD	r1, r3		;X <- AH
018DD6 | 00C6EB: 4C50 00E2 	BRA	nz, 00E2		;PC <- 01C4
018DDA | 00C6ED: 08E0 0002 	LD	rE, #0002		;EXT6 <- #0002
018DDE | 00C6EF: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
018DE2 | 00C6F1: 0008      	LD	r0, r8		;R0 <- EXT0
018DE4 | 00C6F2: 0810 2AA8 	LD	r1, #2AA8		;X <- #2AA8
018DE8 | 00C6F4: 08F0 0000 	LD	rF, #0000		;AL <- #0000
018DEC | 00C6F6: 0038      	LD	r3, r8		;AH <- EXT0
018DEE | 00C6F7: E800 000F 	EOR	r3, #000F		;ACC ^= #000F
018DF2 | 00C6F9: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018DF6 | 00C6FB: 0038      	LD	r3, r8		;AH <- EXT0
018DF8 | 00C6FC: E800 00FF 	EOR	r3, #00FF		;ACC ^= #00FF
018DFC | 00C6FE: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018E00 | 00C700: 0038      	LD	r3, r8		;AH <- EXT0
018E02 | 00C701: E800 00F0 	EOR	r3, #00F0		;ACC ^= #00F0
018E06 | 00C703: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018E0A | 00C705: 0038      	LD	r3, r8		;AH <- EXT0
018E0C | 00C706: E800 0FF0 	EOR	r3, #0FF0		;ACC ^= #0FF0
018E10 | 00C708: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018E14 | 00C70A: 0038      	LD	r3, r8		;AH <- EXT0
018E16 | 00C70B: E800 0F00 	EOR	r3, #0F00		;ACC ^= #0F00
018E1A | 00C70D: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018E1E | 00C70F: 0038      	LD	r3, r8		;AH <- EXT0
018E20 | 00C710: E800 0F0F 	EOR	r3, #0F0F		;ACC ^= #0F0F
018E24 | 00C712: 4C50 0124 	BRA	nz, 0124		;PC <- 0248
018E28 | 00C714: 0031      	LD	r3, r1		;AH <- X
018E2A | 00C715: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018E2E | 00C717: 0013      	LD	r1, r3		;X <- AH
018E30 | 00C718: 4C50 00FD 	BRA	nz, 00FD		;PC <- 01FA
018E34 | 00C71A: 0830 0001 	LD	r3, #0001		;AH <- #0001
018E38 | 00C71C: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]		return 2 PASS
L_I0124:
018E3A | 00C71D: 0830 0002 	LD	r3, #0002		;AH <- #0002
018E3E | 00C71F: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]		return 2 FAIL

L_I0127:								;clear all DRAM
018E40 | 00C720: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018E42 | 00C721: 0512      	LD	ptrB2, r1		;[p_B2] <- X
018E44 | 00C722: 08E0 0000 	LD	rE, #0000		;EXT6 <- #0000
018E48 | 00C724: 08E0 0818 	LD	rE, #0818		;EXT6 <- #0818
018E4C | 00C726: 00C0      	LD	rC, r0		;EXT4 <- R0
018E4E | 00C727: 0830 4000 	LD	r3, #4000		;AH <- #4000
018E52 | 00C729: 08F0 0000 	LD	rF, #0000		;AL <- #0000
018E56 | 00C72B: 0810 0000 	LD	r1, #0000		;X <- #0000
L_I0134:
018E5A | 00C72D: 00C1      	LD	rC, r1		;EXT4 <- X
018E5C | 00C72E: 00C1      	LD	rC, r1		;EXT4 <- X
018E5E | 00C72F: 00C1      	LD	rC, r1		;EXT4 <- X
018E60 | 00C730: 00C1      	LD	rC, r1		;EXT4 <- X
018E62 | 00C731: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018E66 | 00C733: 4C50 0134 	BRA	nz, 0134		;PC <- 0268			goto L_I0134
018E6A | 00C735: 0830 0000 	LD	r3, #0000		;AH <- #0000
018E6E | 00C737: 031E      	LD	r1, ptrBE		;X <- [p_B2++!]
018E70 | 00C738: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]		ret

018E72 | 00C739: 0840 0060 	LD	r4, #0060		;ST <- #0060
018E76 | 00C73B: 0820 0100 	LD	r2, #0100		;Y <- #0100
018E7A | 00C73D: 08E0 0000 	LD	rE, #0000		;EXT6 <- #0000
018E7E | 00C73F: 08E0 0800 	LD	rE, #0800		;EXT6 <- #0800
018E82 | 00C741: 000C      	LD	r0, rC		;R0 <- EXT4
018E84 | 00C742: 08E0 8000 	LD	rE, #8000		;EXT6 <- #8000
018E88 | 00C744: 08E0 081C 	LD	rE, #081C		;EXT6 <- #081C
018E8C | 00C746: 00C0      	LD	rC, r0		;EXT4 <- R0
018E8E | 00C747: 0830 03F8 	LD	r3, #03F8		;AH <- #03F8
018E92 | 00C749: 08F0 0000 	LD	rF, #0000		;AL <- #0000
018E96 | 00C74B: 001C      	LD	r1, rC		;X <- EXT4
018E98 | 00C74C: 00C1      	LD	rC, r1		;EXT4 <- X
018E9A | 00C74D: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018E9E | 00C74F: 4C50 C74B 	BRA	nz, C74B		;PC <- 18E96
018EA2 | 00C751: 1800      	LD	pA0, #00		;pA0 <- #00
018EA4 | 00C752: 0C00 0000 	LD	ptrA0, #0000	;[p_A0] <- #0000
018EA8 | 00C754: 0810 03F8 	LD	r1, #03F8		;X <- #03F8
018EAC | 00C756: 08E0 0000 	LD	rE, #0000		;EXT6 <- #0000
018EB0 | 00C758: 08E0 0800 	LD	rE, #0800		;EXT6 <- #0800
018EB4 | 00C75A: 000C      	LD	r0, rC		;R0 <- EXT4
018EB6 | 00C75B: 003C      	LD	r3, rC		;AH <- EXT4
018EB8 | 00C75C: EA00      	EOR	r3, *ptrA0		;ACC ^= ([p_A0]++)
018EBA | 00C75D: 4C50 C78C 	BRA	nz, C78C		;PC <- 18F18
018EBE | 00C75F: 0031      	LD	r3, r1		;AH <- X
018EC0 | 00C760: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018EC4 | 00C762: 0013      	LD	r1, r3		;X <- AH
018EC6 | 00C763: 4C50 C75B 	BRA	nz, C75B		;PC <- 18EB6
018ECA | 00C765: 1800      	LD	pA0, #00		;pA0 <- #00
018ECC | 00C766: 0C00 C78F 	LD	ptrA0, #C78F	;[p_A0] <- #C78F
018ED0 | 00C768: 08E0 8300 	LD	rE, #8300		;EXT6 <- #8300
018ED4 | 00C76A: 08E0 081C 	LD	rE, #081C		;EXT6 <- #081C
018ED8 | 00C76C: 00C0      	LD	rC, r0		;EXT4 <- R0
018EDA | 00C76D: 08F0 0000 	LD	rF, #0000		;AL <- #0000
018EDE | 00C76F: 0810 0080 	LD	r1, #0080		;X <- #0080
018EE2 | 00C771: 0A30      	LD	r3, *ptrA0		;AH <- ([p_A0]++)
018EE4 | 00C772: 00C3      	LD	rC, r3		;EXT4 <- AH
018EE6 | 00C773: 0031      	LD	r3, r1		;AH <- X
018EE8 | 00C774: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018EEC | 00C776: 0013      	LD	r1, r3		;X <- AH
018EEE | 00C777: 4C50 C771 	BRA	nz, C771		;PC <- 18EE2
018EF2 | 00C779: 1800      	LD	pA0, #00		;pA0 <- #00
018EF4 | 00C77A: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018EF6 | 00C77B: 0D02 C77F 	LD	ptrB2, #C77F	;[p_B2] <- #C77F
018EFA | 00C77D: 0860 0300 	LD	r6, #0300		;PC <- #0300
018EFE | 00C77F: 6800 0000 	CMP	r3, #0000		;ACC == #0000
018F02 | 00C781: 4C50 C78C 	BRA	nz, C78C		;PC <- 18F18
018F06 | 00C783: 0032      	LD	r3, r2		;AH <- Y
018F08 | 00C784: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018F0C | 00C786: 0023      	LD	r2, r3		;Y <- AH
018F0E | 00C787: 4C50 C73D 	BRA	nz, C73D		;PC <- 18E7A
018F12 | 00C789: 0830 0001 	LD	r3, #0001		;AH <- #0001
018F16 | 00C78B: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
018F18 | 00C78C: 0830 0002 	LD	r3, #0002		;AH <- #0002
018F1C | 00C78E: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
018F1E | 00C78F: 08E0 0000 	LD	rE, #0000		;EXT6 <- #0000
018F22 | 00C791: 08E0 0800 	LD	rE, #0800		;EXT6 <- #0800
018F26 | 00C793: 000C      	LD	r0, rC		;R0 <- EXT4
018F28 | 00C794: 08E0 8000 	LD	rE, #8000		;EXT6 <- #8000
018F2C | 00C796: 08E0 081C 	LD	rE, #081C		;EXT6 <- #081C
018F30 | 00C798: 00C0      	LD	rC, r0		;EXT4 <- R0
018F32 | 00C799: 0830 0300 	LD	r3, #0300		;AH <- #0300
018F36 | 00C79B: 08F0 0000 	LD	rF, #0000		;AL <- #0000
018F3A | 00C79D: 001C      	LD	r1, rC		;X <- EXT4
018F3C | 00C79E: 00C1      	LD	rC, r1		;EXT4 <- X
018F3E | 00C79F: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018F42 | 00C7A1: 4C50 030E 	BRA	nz, 030E		;PC <- 061C
018F46 | 00C7A3: 1800      	LD	pA0, #00		;pA0 <- #00
018F48 | 00C7A4: 0C00 0000 	LD	ptrA0, #0000	;[p_A0] <- #0000
018F4C | 00C7A6: 0810 0300 	LD	r1, #0300		;X <- #0300
018F50 | 00C7A8: 08E0 0000 	LD	rE, #0000		;EXT6 <- #0000
018F54 | 00C7AA: 08E0 0800 	LD	rE, #0800		;EXT6 <- #0800
018F58 | 00C7AC: 000C      	LD	r0, rC		;R0 <- EXT4
018F5A | 00C7AD: 003C      	LD	r3, rC		;AH <- EXT4
018F5C | 00C7AE: EA00      	EOR	r3, *ptrA0		;ACC ^= ([p_A0]++)
018F5E | 00C7AF: 4C50 032C 	BRA	nz, 032C		;PC <- 0658
018F62 | 00C7B1: 0031      	LD	r3, r1		;AH <- X
018F64 | 00C7B2: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018F68 | 00C7B4: 0013      	LD	r1, r3		;X <- AH
018F6A | 00C7B5: 4C50 031E 	BRA	nz, 031E		;PC <- 063C
018F6E | 00C7B7: 0830 0000 	LD	r3, #0000		;AH <- #0000
018F72 | 00C7B9: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
018F74 | 00C7BA: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
018F76 | 00C7BB: 0830 FFFF 	LD	r3, #FFFF		;AH <- #FFFF
018F7A | 00C7BD: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
018F7C | 00C7BE: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
018F7E | 00C7BF: 0830 C7C3 	LD	r3, #C7C3		;AH <- #C7C3
018F82 | 00C7C1: 0860 C8DA 	LD	r6, #C8DA		;PC <- #C8DA
018F86 | 00C7C3: C7C6      	OR	r3, RAMB[C6]	;ACC |= RAMB[C6]
018F88 | 00C7C4: 0114      	???	
018F8A | 00C7C5: 0000      	LD	r0, r0		;R0 <- R0
018F8C | 00C7C6: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018F8E | 00C7C7: 0512      	LD	ptrB2, r1		;[p_B2] <- X
018F90 | 00C7C8: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018F92 | 00C7C9: 0522      	LD	ptrB2, r2		;[p_B2] <- Y
018F94 | 00C7CA: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018F96 | 00C7CB: 0542      	LD	ptrB2, r4		;[p_B2] <- ST
018F98 | 00C7CC: 0840 0060 	LD	r4, #0060		;ST <- #0060
018F9C | 00C7CE: 0810 000A 	LD	r1, #000A		;X <- #000A
018FA0 | 00C7D0: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018FA2 | 00C7D1: 0512      	LD	ptrB2, r1		;[p_B2] <- X
018FA4 | 00C7D2: 030A      	LD	r0, ptrBA		;R0 <- [p_B2--!]
018FA6 | 00C7D3: 0D02 0011 	LD	ptrB2, #0011	;[p_B2] <- #0011
018FAA | 00C7D5: 0860 0028 	LD	r6, #0028		;PC <- #0028
018FAE | 00C7D7: E800 0001 	EOR	r3, #0001		;ACC ^= #0001
018FB2 | 00C7D9: 4C50 0021 	BRA	nz, 0021		;PC <- 0042
018FB6 | 00C7DB: 033E      	LD	r3, ptrBE		;AH <- [p_B2++!]
018FB8 | 00C7DC: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
018FBC | 00C7DE: 0013      	LD	r1, r3		;X <- AH
018FBE | 00C7DF: 4C50 000A 	BRA	nz, 000A		;PC <- 0014
018FC2 | 00C7E1: 034E      	LD	r4, ptrBE		;ST <- [p_B2++!]
018FC4 | 00C7E2: 032E      	LD	r2, ptrBE		;Y <- [p_B2++!]
018FC6 | 00C7E3: 031E      	LD	r1, ptrBE		;X <- [p_B2++!]
018FC8 | 00C7E4: 0830 0001 	LD	r3, #0001		;AH <- #0001
018FCC | 00C7E6: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
018FCE | 00C7E7: 031E      	LD	r1, ptrBE		;X <- [p_B2++!]
018FD0 | 00C7E8: 034E      	LD	r4, ptrBE		;ST <- [p_B2++!]
018FD2 | 00C7E9: 032E      	LD	r2, ptrBE		;Y <- [p_B2++!]
018FD4 | 00C7EA: 031E      	LD	r1, ptrBE		;X <- [p_B2++!]
018FD6 | 00C7EB: 0830 0002 	LD	r3, #0002		;AH <- #0002
018FDA | 00C7ED: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
018FDC | 00C7EE: 1800      	LD	pA0, #00		;pA0 <- #00
018FDE | 00C7EF: 1910      	LD	pA1, #10		;pA1 <- #10
018FE0 | 00C7F0: 1A20      	LD	pA2, #20		;pA2 <- #20
018FE2 | 00C7F1: 1C00      	LD	pB0, #00		;pB0 <- #00
018FE4 | 00C7F2: 1D10      	LD	pB1, #10		;pB1 <- #10
018FE6 | 00C7F3: 0C00 0400 	LD	ptrA0, #0400	;[p_A0] <- #0400
018FEA | 00C7F5: 0C01 0400 	LD	ptrA1, #0400	;[p_A1] <- #0400
018FEE | 00C7F7: 0C02 0400 	LD	ptrA2, #0400	;[p_A2] <- #0400
018FF2 | 00C7F9: 0D00 0400 	LD	ptrB0, #0400	;[p_B0] <- #0400
018FF6 | 00C7FB: 0D01 0400 	LD	ptrB1, #0400	;[p_B1] <- #0400
018FFA | 00C7FD: 08E0 0400 	LD	rE, #0400		;EXT6 <- #0400
018FFE | 00C7FF: 08E0 0800 	LD	rE, #0800		;EXT6 <- #0800




019102 | 00C881: 08F0 0000 	LD	rF, #0000		;AL <- #0000
019106 | 00C883: 0038      	LD	r3, r8		;AH <- EXT0
019108 | 00C884: 0435      	LD	ptrA5, r3		;[p_A1++] <- AH
01910A | 00C885: 0535      	LD	ptrB5, r3		;[p_B1++] <- AH
01910C | 00C886: 0031      	LD	r3, r1		;AH <- X
01910E | 00C887: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
019112 | 00C889: 0013      	LD	r1, r3		;X <- AH
019114 | 00C88A: 4C50 00BD 	BRA	nz, 00BD		;PC <- 017A
019118 | 00C88C: 0810 0100 	LD	r1, #0100		;X <- #0100
01911C | 00C88E: 0235      	LD	r3, ptrA5		;AH <- [p_A1++]
01911E | 00C88F: E305      	EOR	r3, ptrB5		;ACC ^= [p_B1++]
019120 | 00C890: 4C50 0103 	BRA	nz, 0103		;PC <- 0206
019124 | 00C892: 0031      	LD	r3, r1		;AH <- X
019126 | 00C893: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
01912A | 00C895: 0013      	LD	r1, r3		;X <- AH
01912C | 00C896: 4C50 00C8 	BRA	nz, 00C8		;PC <- 0190
019130 | 00C898: 08E0 2000 	LD	rE, #2000		;EXT6 <- #2000
019134 | 00C89A: 08E0 0800 	LD	rE, #0800		;EXT6 <- #0800
019138 | 00C89C: 0008      	LD	r0, r8		;R0 <- EXT0
01913A | 00C89D: 1A00      	LD	pA2, #00		;pA2 <- #00
01913C | 00C89E: 1E00      	LD	pB2, #00		;pB2 <- #00
01913E | 00C89F: 0810 0100 	LD	r1, #0100		;X <- #0100
019142 | 00C8A1: 08F0 0000 	LD	rF, #0000		;AL <- #0000
019146 | 00C8A3: 0038      	LD	r3, r8		;AH <- EXT0
019148 | 00C8A4: 0436      	LD	ptrA6, r3		;[p_A2++] <- AH
01914A | 00C8A5: 0536      	LD	ptrB6, r3		;[p_B2++] <- AH
01914C | 00C8A6: 0031      	LD	r3, r1		;AH <- X
01914E | 00C8A7: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
019152 | 00C8A9: 0013      	LD	r1, r3		;X <- AH
019154 | 00C8AA: 4C50 00DD 	BRA	nz, 00DD		;PC <- 01BA
019158 | 00C8AC: 0810 0100 	LD	r1, #0100		;X <- #0100
01915C | 00C8AE: 0236      	LD	r3, ptrA6		;AH <- [p_A2++]
01915E | 00C8AF: E306      	EOR	r3, ptrB6		;ACC ^= [p_B2++]
019160 | 00C8B0: 4C50 0103 	BRA	nz, 0103		;PC <- 0206
019164 | 00C8B2: 0031      	LD	r3, r1		;AH <- X
019166 | 00C8B3: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
01916A | 00C8B5: 0013      	LD	r1, r3		;X <- AH
01916C | 00C8B6: 4C50 00E8 	BRA	nz, 00E8		;PC <- 01D0
019170 | 00C8B8: 1C00      	LD	pB0, #00		;pB0 <- #00
019172 | 00C8B9: 0810 0100 	LD	r1, #0100		;X <- #0100
019176 | 00C8BB: 08F0 0000 	LD	rF, #0000		;AL <- #0000
01917A | 00C8BD: 0039      	LD	r3, r9		;AH <- EXT1
01917C | 00C8BE: 053C      	LD	ptrBC, r3		;[p_B0++!] <- AH
01917E | 00C8BF: 0031      	LD	r3, r1		;AH <- X
019180 | 00C8C0: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
019184 | 00C8C2: 0013      	LD	r1, r3		;X <- AH
019186 | 00C8C3: 4C50 00F7 	BRA	nz, 00F7		;PC <- 01EE
01918A | 00C8C5: 1592      	LD	pB2, r9		;p_B2 <- EXT1
01918C | 00C8C6: 0830 0001 	LD	r3, #0001		;AH <- #0001
019190 | 00C8C8: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]
019192 | 00C8C9: 1C00      	LD	pB0, #00		;pB0 <- #00
019194 | 00C8CA: 0810 0100 	LD	r1, #0100		;X <- #0100
019198 | 00C8CC: 08F0 0000 	LD	rF, #0000		;AL <- #0000
01919C | 00C8CE: 0039      	LD	r3, r9		;AH <- EXT1
01919E | 00C8CF: 053C      	LD	ptrBC, r3		;[p_B0++!] <- AH
0191A0 | 00C8D0: 0031      	LD	r3, r1		;AH <- X
0191A2 | 00C8D1: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
0191A6 | 00C8D3: 0013      	LD	r1, r3		;X <- AH
0191A8 | 00C8D4: 4C50 0108 	BRA	nz, 0108		;PC <- 0210
0191AC | 00C8D6: 1592      	LD	pB2, r9		;p_B2 <- EXT1
0191AE | 00C8D7: 0830 0002 	LD	r3, #0002		;AH <- #0002
0191B2 | 00C8D9: 036E      	LD	r6, ptrBE		;PC <- [p_B2++!]


0191B4 | 00C8DA: 1800      	LD	pA0, #00		;pA0 <- #00
0191B6 | 00C8DB: 0430      	LD	ptrA0, r3		;[p_A0] <- AH
0191B8 | 00C8DC: 08E0 8000 	LD	rE, #8000		;EXT6 <- #8000
0191BC | 00C8DE: 08E0 081C 	LD	rE, #081C		;EXT6 <- #081C
0191C0 | 00C8E0: 00C0      	LD	rC, r0		;EXT4 <- R0
0191C2 | 00C8E1: 08F0 0000 	LD	rF, #0000		;AL <- #0000
0191C6 | 00C8E3: 0810 01FF 	LD	r1, #01FF		;X <- #01FF
0191CA | 00C8E5: 0A30      	LD	r3, *ptrA0		;AH <- ([p_A0]++)
0191CC | 00C8E6: 0023      	LD	r2, r3		;Y <- AH
0191CE | 00C8E7: 0A30      	LD	r3, *ptrA0		;AH <- ([p_A0]++)
0191D0 | 00C8E8: 0013      	LD	r1, r3		;X <- AH
0191D2 | 00C8E9: 0A30      	LD	r3, *ptrA0		;AH <- ([p_A0]++)
0191D4 | 00C8EA: 0420      	LD	ptrA0, r2		;[p_A0] <- Y
0191D6 | 00C8EB: 0023      	LD	r2, r3		;Y <- AH
0191D8 | 00C8EC: 0A30      	LD	r3, *ptrA0		;AH <- ([p_A0]++)
0191DA | 00C8ED: 00C3      	LD	rC, r3		;EXT4 <- AH
0191DC | 00C8EE: 0031      	LD	r3, r1		;AH <- X
0191DE | 00C8EF: 2800 0001 	SUB	r3, #0001		;ACC -= #0001
0191E2 | 00C8F1: 0013      	LD	r1, r3		;X <- AH
0191E4 | 00C8F2: 4C50 C8EC 	BRA	nz, C8EC		;PC <- 191D8
0191E8 | 00C8F4: 1800      	LD	pA0, #00		;pA0 <- #00
0191EA | 00C8F5: 0062      	LD	r6, r2		;PC <- Y


