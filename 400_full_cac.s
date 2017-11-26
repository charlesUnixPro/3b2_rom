##
# This is the disassembled 3B2 Model 400 ROM. I'm attempting to trace it to
# the best of my ability to understand what the 3B2 does at startup.
#
# Disassembled with:
#
#    we32dis.rb -s 0x1274 -i 400_full.bin > disassembled.txt
#
# $ od -Ax -v -t x4 --endian=big 400_full.bin | awk '{printf "\t.word\t 0x%s, 0x%s, 0x%s, 0x%s\t# %s\n", $2, $3, $4, $5, $1}' | less > cac.tmp
# $ od -Ax -v -t x1 -w4 --endian=big 400_full.bin | awk '{printf "\t.byte\t 0x%s, 0x%s, 0x%s, 0x%s\t# %s\n", $2, $3, $4, $5, $1}' | less > cacb.tmp
##

####
##
#   cac's notes:
#
#     Much information in uts/3b2/firmware.h
#
#     Many instructions are replaced with '.byte ....' due to 'as' generating different code then is in the
#     ROM.
#
#       Several instructions has operands that fit in 16 bits, but the ROM code uses 32 bit operands.
#       as seems to produce a MOVB instruction for the MULB3 opcode; and a MOVW for a MULW3.
#       TSTB seems to add a NOP.
#       Subroutines allocate stack frame space with 'ADDW2  &val,%sp', the ROM code has a 32 bit operand.
#
#

# The following snippets were extracted from System V Release 3 include files;
# they are marked:
#
#/*        Copyright (c) 1984 AT&T       */
#/*          All Rights Reserved         */
#
#/*        THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T         */
#/*        The copyright notice above does not evidence any            */
#/*        actual or intended publication of such source code.         */


#  /* gives contents of run flag */
#  #define RUNFLG (*(((struct vectors *)BASE)->p_runflg))
#  #define SAFE 0L
#  #define FATAL 0xFEEDBEEFL   /* fatal error, reset system */
#  #define INIT  0x3B02F1D0L   /* MAS has been init'ed */
#  #define VECTOR 0xA11C0DEDL  /* reset goes to rst_handler */
#  #define REBOOT 0x8BADF00DL  /* reboot w/o diags for UN*X */
#  #define REENTRY 0xADEBAC1EL /* reenter fw from a reset w/o failure mesage */

	.set	SAFE,0
	.set	FATAL,0xfeedbeef
	.set	INIT,0x3b02f1d0
	.set	VECTOR,0xa11c0ded
	.set	REBOOT,0x8badf00d
	.set	REENTRY,0xadebac1e

#  /* floppy motor and select controls */
#  
#  #define FIRST 0         /* initial xfer of multiple xfer (select,spin-up) */
#  #define NOCHANGE 1      /* subsequent xfers except for final */
#  #define LAST 2          /* final xfer (deselect,spin-down) */
#  #define SINGLE 3        /* one xfer (select,spin-up then deselect,spin-down) */
#  
#  /* indication to hd_acs, fd_acs, and ioblk_acs routines of read or write */
#  #define BLKRD 0
#  #define BLKWT 1
#  #define DISKRD 0
#  #define DISKWT 1
#  
#  #define FW_CQ_ADDR 0x20037ec  /* 0x814 from BOOTADDR for min comp and req Qs */
#  #define FW_RQ_ADDR 0x20037f4  /* min for req and comp Q overlap */
#  

	.set	FW_CQ_ADDR,0x20037ec
	.set	FW_RQ_ADDR,0x20037f4

#  
#  struct duart
#  {
#  	unsigned char mr1_2a;	/* Mode Register A Channels 1 & 2 */
#  	unsigned char a_sr_csr;	/* Status Reg A/Clock Select Reg A */
#  	unsigned char a_cmnd;	/* Command Reg A */
#  	unsigned char a_data;	/* RX Holding/TX Holding Reg A */
#  
#  	unsigned char ipc_acr;	/* Input Port Change/Aux Cntrl Reg A */
#  	unsigned char is_imr;	/* Intrupt Status/Intrupt Mask Reg A */
#  	unsigned char ctur;	/* Counter/Timer Upper Reg */
#  	unsigned char ctlr;	/* Counter/Timer Lower Reg */
#  
#  	unsigned char mr1_2b;	/* Mode Reg B Channels 1 & 2 */
#  	unsigned char b_sr_csr;	/* Status Reg B/Clock Select Reg B */
#  	unsigned char b_cmnd;	/* Command Reg B */
#  	unsigned char b_data;	/* RX Holding/TX Holding Reg B */
#  
#  	int :8;			/* RESERVED */
#  
#  	unsigned char ip_opcr;	/* Input Port/Output Port Conf Reg */
#  	unsigned char scc_sopbc;/* Start Counter Command/Set Output */
#  				/* Port Bits Command */
#  	unsigned char scc_ropbc;/* Stop Counter Command/Reset Output */
#  				/* Port Bits Command */
#  	unsigned char pad;
#  	unsigned char c_uartdma;/* location read to clear DMAC intr in UART */
#  };
#  
#  /* Register Bit Format Defines	*/
#  
#  /*
#   *	Mode Register 1 Channel A and B Defines
#   */
#  
#  #define	ENB_RX_RTS	0x80
#  #define ENB_RXINT	0x40
#  #define BLCK_ERR	0x20
#  #define CHAR_ERR	0x00
#  #define PENABLE		0x00
#  #define	FRC_PAR		0x08
#  #define	NO_PAR		0x10
#  #define	SPECIAL		0x18
#  #define EPAR		0x00
#  #define OPAR		0x04
#  #define BITS5		0x00
#  #define	BITS6		0x01
#  #define	BITS7		0x02
#  #define	BITS8		0x03
#  
#  /*
#   *	Mode Register 2 Channel A and B Defines
#   */
#   
#  #define	NRML_MOD	0x00
#  #define	ENBECHO		0x40
#  #define	LCL_LOOP	0x80
#  #define	REM_LOOP	0xc0
#  
#  #define	ENB_TXRTS	0x20
#  #define	ENB_CTSTX	0x10
#  
#  #define	ZEROP563SB	0x00
#  #define	ZEROP625SB	0x01
#  #define	ZEROP688SB	0x02
#  #define	ZEROP750SB	0x03
#  #define	ZEROP813SB	0x04
#  #define	ZEROP875SB	0x05
#  #define	ZEROP938SB	0x06
#  
#  #define	ONESB		0x07
#  #define	ONEP563SB	0x08
#  #define	ONEP625SB	0x09
#  #define	ONEP688SB	0x0a
#  #define	ONEP750SB	0x0b
#  #define	ONEP813SB	0x0c
#  #define	ONEP875SB	0x0d
#  #define	ONEP938SB	0x0e
#  
#  #define	TWOSB		0x0f
#  
#  /*
#   *	Baud Rate Select Register Defines
#   */
#  
#  #define	B50BPS		0x00
#  #define	B75BPS		0x00
#  #define	B110BPS		0x11
#  #define	B134BPS		0x22
#  #define	B150BPS		0x33
#  #define	B200BPS		0x33
#  #define	B300BPS		0x44
#  #define	B600BPS		0x55
#  #define	B1200BPS	0x66
#  #define	B1050BPS	0x77
#  #define	B1800BPS	0xaa
#  #define	B2000BPS	0x77
#  #define	B2400BPS	0x88
#  #define	B4800BPS	0x99
#  #define	B7200BPS	0xaa
#  #define	B9600BPS	0xbb
#  #define	B19200BPS	0xcc
#  #define	B38400BPS	0xcc
#  
#  /*
#   *	Auxillary Command Register Defines
#   */
#  
#  #define	B50ACR		0x00
#  #define	B75ACR		0x80
#  #define	B110ACR		0x00
#  #define	B134ACR		0x00
#  #define	B150ACR		0x80
#  #define	B200ACR		0x00
#  #define	B300ACR		0x00
#  #define	B600ACR		0x00
#  #define	B1200ACR	0x00
#  #define	B1050ACR	0x00
#  #define	B1800ACR	0x80
#  #define	B2000ACR	0x80
#  #define	B2400ACR	0x00
#  #define	B4800ACR	0x00
#  #define	B7200ACR	0x00
#  #define	B9600ACR	0x00
#  #define	B19200ACR	0x80
#  #define	B38400ACR	0x00
#  
#  /*
#   *	Miscellaneous Commands for CRA/CRB
#   */
#  
#  #define	NO_OP		0x00
#  #define	RESET_MR	0x10
#  #define	RESET_RECV	0x20
#  #define	RESET_TRANS	0x30
#  #define	RESET_ERR	0x40
#  #define	RST_A_BCI	0x50
#  #define	STRT_BRK	0x60
#  #define	STOP_BRK	0x70
#  #define	DIS_TX		0x08
#  #define	ENB_TX		0x04
#  #define	DIS_RX		0x02
#  #define	ENB_RX		0x01
#  
#  /*
#   *	Status Register Defines for SRA/SRB
#   */
#  
#  #define	RCVD_BRK	0x80
#  #define	FE		0x40
#  #define	PARERR		0x20
#  #define	OVRRUN		0x10
#  #define	XMTEMT		0x08
#  #define	XMTRDY		0x04
#  #define	FIFOFULL	0x02
#  #define	RCVRDY		0x01
#  
#  /*
#   *	Register Defines for IPCR/OPCR
#   */
#  
#  /* Inputs */
#  #define	DCDA		0x01
#  #define	DCDB		0x02
#  #define SFLOP		0x04
#  
#  /* Outputs */
#  #define	DTRA		0x01
#  #define	DTRB		0x02
#  #define KILLPWR		0x04
#  #define PWRLED		0x08
#  #define F_LOCK		0x10
#  #define F_SEL		0x20
#  
#  #define	OIDUART		0x00049000L
#  #define	IDUART		((struct duart *)OIDUART)
#  

#  
#  
#  /*
#   *	Control and Status Register
#   *
#   *  Write-only status register mapping
#   *
#   *				       7      0
#   *				      +--------+
#   *	(struct	wcsr *)	-> pir9c      |	       |
#   *				      +--------+
#   *
#   *			-> pir9s
#   *			     :
#   *			-> sanityc
#   *
#   */
#  struct wcsr {
#  	int :24; unsigned char c_sanity;
#  	int :24; unsigned char c_parity;
#  	int :24; unsigned char s_reqrst;
#  	int :24; unsigned char c_align;
#  	int :24; unsigned char s_led;
#  	int :24; unsigned char c_led;
#  	int :24; unsigned char s_flop;
#  	int :24; unsigned char c_flop;
#  	int :24; unsigned char s_timers;
#  	int :24; unsigned char c_timers;
#  	int :24; unsigned char s_inhibit;
#  	int :24; unsigned char c_inhibit;
#  	int :24; unsigned char s_pir9;
#  	int :24; unsigned char c_pir9;
#  	int :24; unsigned char s_pir8;
#  	int :24; unsigned char c_pir8;
#  };
#  
#  
#  /*
#   *  Read-only status register mapping
#   *
#   *				      15              0
#   *				      +----------------+
#   *	short rcsr 		      |	               |
#   *				      +----------------+
#   */
#  
#  #define CSRTIMO	0x8000
#  #define CSRPARE	0x4000
#  #define CSRRRST	0x2000
#  #define CSRALGN	0x1000
#  #define CSRLED	0x0800
#  #define CSRFLOP	0x0400
#  #define CSRITIM	0x0100
#  #define CSRIFLT	0x0080
#  #define CSRCLK	0x0040
#  #define CSRPIR8	0x0020
#  #define CSRPIR9	0x0010
#  #define CSRUART	0x0008
#  #define CSRDISK	0x0004
#  #define CSRDMA	0x0002
#  #define CSRIOF	0x0001
#  
#  #define	OCSR		0x00044000L
#  #define SBDRCSR		(((struct r16 *)OCSR)->data)
#  #define SBDWCSR		((struct wcsr *)OCSR)
#  #define Rcsr		(((struct r16 *)&sbdrcsr)->data)
#  #define Wcsr		((struct wcsr *)&sbdwcsr)
#  
#  
#  
#  
#  /*
#   *	9517 DMA Controller
#   */
#  
#  struct	dma	{
#  	unsigned char	C0CA;		/* channel 0 current address reg */
#  	unsigned char	C0WC;		/* channel 0 word current count reg */
#  	unsigned char	C1CA;		/* channel 1 current address reg */
#  	unsigned char	C1WC;		/* channel 1 word current count reg */
#  	unsigned char	C2CA;		/* channel 2 current address reg */
#  	unsigned char	C2WC;		/* channel 2 word current count reg */
#  	unsigned char	C3CA;		/* channel 3 current address reg */
#  	unsigned char	C3WC;		/* channel 3 word current count reg */
#  	unsigned char	RSR_CMD;	/* read status - write CMD reg */
#  	unsigned char	WRR;		/* write request reg */
#  	unsigned char	WMKR;		/* write channel mask reg */
#  	unsigned char	WMODR;		/* write mode reg */
#  	unsigned char	CBPFF;		/* clear byte pointer flip/flop */
#  	unsigned char	RTR_WMC;	/* read temp reg */
#  	unsigned char	pad;		/* N/A */
#  	unsigned char	WAMKR;		/* write all mask reg */
#  	unsigned char	CLR_INT;	/* location read to clear DMAC intr */
#  };
#  
#  extern struct dma	dmac;		/* The real thing.	*/
#  
#  #define	OIDMAC		0x00048000L
#  #define	IDMAC		((struct dma *)OIDMAC)
#  
#  #define DMNDMOD	0x00	/* demand transfer mode used by idisk */
#  #define SNGLMOD	0x40	/* single transfer mode used by iflop, iuartA, iuartB */
#  #define	RDMA	0x8	/* read DMA command */
#  #define	WDMA	0x4	/* write DMA command */
#  #define	RSTDMA	0x0	/* reset DMA command */
#  
#  #define CH0IHD	0x00	/* channel 0 integral hard disk */
#  #define CH1IFL	0x01	/* channel 1 integral floppy disk */
#  #define CH2IUA	0x02	/* channel 2 integral uart A */
#  #define CH3IUB	0x03	/* channel 3 integral uart B */
#  
#  /*
#   *	DMA Page Registers
#   */
#  
#  /*	The external symbols are defined in the vuifile.
#  */
#  
#  #define	OIDMAPHD	0x00045000L	/* hard disk */
#  #define	IDMAPHD		(((struct r8 *)OIDMAPHD)->data)
#  extern int		dmaid;
#  
#  #define	OIDMAPUA	0x00046000L	/* uart A */
#  #define	IDMAPUA		(((struct r8 *)OIDMAPUA)->data)
#  extern int		dmaiuA;
#  
#  #define	OIDMAPUB	0x00047000L	/* uart B */
#  #define	IDMAPUB		(((struct r8 *)OIDMAPUB)->data)
#  extern int		dmaiuB;
#  
#  #define	OIDMAPFD	0x0004E000L	/* floppy disk */
#  #define	IDMAPFD		(((struct r8 *)OIDMAPFD)->data)
#  extern int		dmaif;
#  
#  #define RPAGE		0x80
#  #define WPAGE		0x00
#  
#  #define MSK64K 0xffff	/* 64K byte address mask - used by disk drivers */
#  #define BND64K 0x10000
#  
#  
#  
#  
#  /************************************************************/
#  /*    Structures for the Equipped Device Table              */
#  /************************************************************/
#  
#  #define EDTSBD 0
#  
#  #define E_SINGLE  0
#  #define E_DOUBLE  1
#  
#  #define E_8BIT  0
#  #define E_16BIT  1
#  
#  #define E_DUMB 0
#  #define E_SMART 1
#  
#  #define E_NAMLEN  10
#  
#  #define MAX_IO  12
#  
#  struct subdevice {
#  	unsigned short opt_code;	/* sixteen bit option code for	*/
#  					/* subdevice stored as a short	*/
#  	unsigned char name[E_NAMLEN];	/* ASCII name of subdevice	*/
#  };
#  
#  struct edt {
#  	unsigned opt_code:16;		/* sixteen bit option code	*/
#  	unsigned opt_slot:4;		/* slot in which this board is  */
#  	unsigned opt_num:4;		/* which of given option type	*/
#  					/* this board is		*/
#  	unsigned rq_size:8;		/* request queue entry size	*/
#  	unsigned cq_size:8;		/* completion queue entry size	*/
#  	unsigned resrvd:13;		/* (reserved for future use)	*/
#  	unsigned indir_dev:1;
#  	unsigned cons_cap:1;		/* one = can support console	*/
#  					/* zero = cannot support cons   */
#  	unsigned cons_file:1;		/* zero = device has no pump    */
#  					/* file for floating console    */
#  					/* one = device has a floating  */
#  					/* console pump file            */
#  	unsigned boot_dev:1;		/* one for possible boot device	*/
#  	unsigned word_size:1;		/* zero = 8 bit ; one = 16 bit	*/
#  	unsigned brd_size:1;		/* zero = single width;		*/
#  					/* one = double width		*/
#  	unsigned smrt_brd:1;		/* zero = dumb board		*/
#  					/* one = intelligent board	*/
#  	unsigned n_subdev:4;		/* subdevice count		*/
#  	struct subdevice *subdev;	/* pointer to array of n_subdev	*/
#  					/* subdevice structures		*/
#  	char dev_name[E_NAMLEN];	/* ASCII name of device		*/
#  	char diag_file[E_NAMLEN];	/* Name of UN*X resident file   */
#  					/* containing diagnostic phases	*/
#  };
#  
#  
#  
#  
#  /* 3B2 Integral Winchester Disk Definitions */
#  
#  #define IDNULL		0
#  #define IDSET		1
#  #define IDFRSTBLK	0
#  
#  #define	IDIDLE		0x01
#  #define	IDSEEK0		0x02
#  #define	IDSEEK1		0x04
#  #define	IDXFER		0x08
#  #define IDBUSY		0x10
#  #define	IDWAITING		0x20
#  
#  #define IDSEEKMSK (IDRDYCHG|IDDRVNRDY|IDSEEKERR|IDEQUIPT|IDSEEKEND)
#  
#  /*  Function return states  */
#  #define	IDPASS	0
#  #define	IDFAIL	1
#  
#  /*  Number of disk operation retries  */
#  #define	IDRETRY	16
#  #define	IDRESEEK	3
#  
#  /*  Interrupt definitions to idldcmd  */
#  #define	IDINTON		1
#  #define	IDINTOFF	0
#  
#  /* special block numbers */
#  #define IDPDBLKNO	0x00
#  #define IDVTOCBLK	0x01
#  
#  /* Minor number macros */
#  #define	iddn(x)		((x>>4)&1)	/* extract drive number */
#  #define	idmkmin(dn)	((dn)<<4)	/* make minor from drive number */
#  #define	idslice(x)	(x&0x0f)	/* extract drive partition no. */
#  #define	idnodev(x)	((x>>5)&1)	/* test for physical r/w */
#  #define idspecdev(x)	((x>>6)&1)	/* test for special device */
#  
#  /* save contents of buffer header */
#  struct idsave {
#  	caddr_t	b_addr;
#  	daddr_t b_blkno;
#  	unsigned int b_bcount;
#  	int	b_pad;		/* round size to 2^n */
#  } ;
#  
#  /* disk address structures */
#  struct partaddr {
#  	unsigned char pcnh;	/* physical cylinder number high */
#  	unsigned char pcnl;	/* physical cylinder number low */
#  	unsigned char phn;	/* physical head number */
#  	unsigned char psn;	/* physical sector number */
#  } ;
#  
#  union diskaddr {
#  	unsigned long full;	/* full physical disk address */
#  	struct partaddr part;	/* allows referencing of partial addresses */
#  } ;
#  
#  /* defect maps */
#  #define IDDEFSIZ	2048
#  #define IDDEFCNT	256
#  
#  struct defect {
#  	union diskaddr bad;
#  	union diskaddr good;
#  } ;
#  
#  struct defstruct	{
#  	struct defect map[IDDEFCNT];
#  };
#  
#  
#  /* Manufacturer's Defect Table */
#  struct mfgdef	{
#  	unsigned short length;
#  	unsigned short indexbytes;
#  	unsigned short cylinder;
#  	unsigned short head;
#  };
#  
#  /* seek parameter structure */
#  struct idseekstruct {
#  	unsigned char pcnh;	/* physical cylinder number high */
#  	unsigned char pcnl;	/* physical cylinder number low */
#  };
#  
#  #define IDSEEKCNT	2
#  
#  /* transfer parameter structure */
#  struct idxferstruct {
#  	unsigned char	phn;	/* physical head number */
#  	unsigned char	lcnh;	/* logical cylinder number high */
#  	unsigned char	lcnl;	/* logical cylinder number low */
#  	unsigned char	lhn;	/* logical head number */
#  	unsigned char	lsn;	/* logical sector number */
#  	unsigned char	scnt;	/* sector count */
#  	unsigned int	bcnt;	/* byte count */
#  	unsigned char	necop;	/* disk controller command opcode */
#  	unsigned char	dmacop;	/* dmac command opcode */
#  	unsigned int	b_addr; /* memory address */
#  	unsigned int	unitno; /* drive number */
#  	int		pad[2];	/* round size to 2^n */
#  };
#  
#  #define IDXFERCNT 	6
#  
#  /*  controller initialization - specify parameter structure  */
#  struct idspecparam {
#  	unsigned char	mode;	/* operational mode of controller */
#  	unsigned char	dtlh;	/* sector data length high byte */
#  	unsigned char	dtll;	/* sector data length low byte */
#  	unsigned char	etn;	/* end track number:last track on cyl */
#  	unsigned char	esn;	/* end sector number: last sector on track */
#  	unsigned char	gpl2;	/* gap length 2 */
#  	unsigned char	rwch;	/* reduced write current start cyl: high byte */
#  	unsigned char	rwcl;	/* reduced write current start cyl: low byte */
#  } ;
#  
#  #define IDSPECCNT	8
#  
#  #define IDNOPARAMCNT	0
#  
#  /*    drive status bytes    */
#  struct idstatstruct {
#  	unsigned int 	state;		/*  internal per-drive driver state */
#  	unsigned char	open;		/*  flag marking first open */
#  	unsigned char 	equipped;	/*  drive equipped flag */
#  	unsigned char 	drvtype;	/*  drive equipped flag */
#  	unsigned char	statreg;	/*  controller state register (STR)  */
#  	unsigned char	estbyte;	/*  error status byte (EST)  */
#  	unsigned char	istbyte;	/*  interrupt status byte (IST)  */
#  	unsigned char	ustbyte;	/*  unit status byte (UST)  */
#  	unsigned char	phn;		/*  physical head number */
#  	unsigned char	lcnh;		/* logical cylinder number high */
#  	unsigned char	lcnl; 		/* logical cylinder number low */
#  	unsigned char	lhn;		/* logical head number */
#  	unsigned char	lsn;		/* logical sector number */
#  	unsigned char	scnt;		/* sector count */
#  	int		retries;	/* number of retries left */
#  	unsigned char	reseeks;	/* number of reseeks left */
#  	int		idpad;		/* round size to 2^n */
#  };
#  
#  /* open states and special not-a-device partition definitions */
#  #define IDADDEV		0x02
#  #define IDMAXHD		0x08
#  #define IDNODEV		0x20
#  #define IDNOUNIT	0x40
#  #define IDNOTOPEN	0x00
#  #define IDISOPEN	0x01
#  #define IDOPENING	0x02
#  
#  struct iddev {
#  	unsigned char fifo;
#  	unsigned char statcmd;
#  };
#  
#  #define	OIDISK		0x0004A000L
#  #define	IDISK		((struct iddev *)OIDISK)
#  
#  
#  /*   Disk Controller Status Register Layout
#  
#  	Bit #	  Definition
#  	 7	Controller Busy
#  	 6	Command End High 
#  	 5	Command End Low 
#  	 4	Sense Interrupt Status Request
#  	 3	Reset Request
#  	 2	ID Error
#  	 1	Not Coincident
#  	 0	Data Request
#  
#  */
#  
#  #define	IDCBUSY		0x80		/* controller busy */
#  #define	IDCMDINP	0x00		/* command in progress */
#  #define	IDCMDABT	0x20		/* abnormal command termination */
#  #define	IDCMDNRT	0x40		/* normal command termination */
#  #define	IDCMDINV	0x60		/* command invalid */
#  #define	IDSINTRQ	0x10		/* sense interrupt request status */
#  #define	IDRESETRQ	0x08		/* reset request */
#  #define	IDERROR		0x04		/* ID error */
#  #define	IDNCOIN		0x02		/* not coincident */
#  #define	IDDATARQ	0x01		/* data request */
#  #define	IDENDMASK	0x60		/* mask for command end bits */
#  
#  
#  /*   Disk Error Status Byte (EST) Layout
#  
#  	Bit #	  Definition
#  	 7	End of Cylinder
#  	 6	Overrun
#  	 5	Data Error
#  	 4	Equiptment Check
#  	 3	Not Ready
#  	 2	Not Data
#  	 1	Not Writable
#  	 0	Missing Data Mark
#  
#  */
#  
#  #define	IDENDCYL	0x80		/* end of cylinder */
#  #define	IDDMAOVR	0x40		/* DMA overrun */
#  #define	IDDATAERR	0x20		/* data error */
#  #define	IDEQUIPTC	0x10		/* equiptment check */
#  #define	IDDRVNRDY	0x08		/* drive not ready */
#  #define	IDNODATA	0x04		/* not data */
#  #define	IDWTPROT	0x02		/* not writable */
#  #define	IDMISSMRK	0x01		/* missing data mark */
#  
#  
#  /*   Disk Interrupt Status (IST) Byte Layout
#  
#  	Bit #	  Definition
#  	 7	Seek End
#  	 6	Ready Change
#  	 5	Seek Error
#  	 4	Equiptment Check
#  	 3	Not Ready
#  	 2	Unit Address Most Significant
#  	 1	Unit Address
#  	 0	Unit Address Least Significant
#  
#  */
#  
#  #define	IDSEEKEND	0x80		/* seek end */
#  #define	IDRDYCHG	0x40		/* ready change */
#  #define	IDSEEKERR	0x20		/* seek error */
#  #define	IDEQUIPT	0x10		/* equiptment check */
#  #define	IDDRVNRDY	0x08		/* drive not ready */
#  #define	IDUNITADD	0x07		/* unit address mask */
#  
#  /*   Disk Unit Status (UST) Byte Layout
#  
#  	Bit #	  Definition
#  	 4	Drive Selected
#  	 3	Seek Complete
#  	 2	Track 0
#  	 1	Ready
#  	 0	Write Fault
#  
#  */
#  
#  #define	IDDRIVESL	0x10		/* drive selected */
#  #define	IDSEEKCMP	0x08		/* seek complete */
#  #define	IDTRACK0	0x04		/* track 0 */
#  #define IDREADY		0x02		/* ready */
#  #define	IDWTFAULT	0x01		/* write fault */
#  
#  /*   Auxiliary Disk Commands   */
#  
#  #define	IDRESET		0x01		/* reset the disk controller */
#  #define	IDCLFIFO	0x02		/* clear the data FIFO */
#  #define	IDMASKSRQ	0x04		/* mask the SRQ interrupt */
#  #define	IDCLCMNDEND	0x08		/* clear command end bits */
#  
#  /* Drive IDs */
#  
#  #define IDRV0		0x00
#  #define IDRV1		0x01
#  
#  /*   Disk Command Definitions   */
#  
#  #define	IDRECAL		0x50	/* position the R/W heads to cylinder 0 */
#  #define	IDSEEK		0x60	/* position the R/W heads to the specified cylinder */
#  #define	IDWTFORMAT	0x70	/* write a track format to the disk */
#  #define	IDVERID		0x80	/* compare sector ID fields */
#  #define	IDREADID	0x90	/* read a sector ID field   */
#  #define	IDREAD		0xb0	/* read a sector data field */
#  #define IDCHECK		0xc0	/* check CRC of a specified sector */
#  #define	IDSCAN		0xd0	/* find a sector with specified data */
#  #define	IDVERDT		0xe0	/* compare sector data fields */
#  #define	IDWRITE		0xf0	/* write sector data fields */
#  #define	IDSPECIFY	0x20	/* sets the operation mode and format */
#  #define	IDSENSEINT	0x10	/* checks status information */
#  #define	IDSENSEUS	0x30	/* checks the disk drive status */
#  #define	IDDETERROR	0x40	/* checks the error pattern */
#  
#  /*   Disk Command Modifier Definitions   */
#  
#  #define	IDBUFFERED	0x08
#  #define	IDSKEWED	0x08
#  
#  #define	VALIDINFO	0xFEEDBEEF	/* disk info is valid non-vtoc */
#  #define	VALIDVTOC	0xFEEDF00D	/* disk info is valid vtoc */
#  
#  /*   Parameter values for an ST-412 Disk Drive   */
#  
#  #define IDNDRV		2		/*  number of drives in system  */
#  #define	IDNUM_CYLINDER	306		/* number of disk cylinders */
#  #define	IDNUM_HEADS	4		/* number of disk heads 4 */
#  #define	IDRED_WRITE	128		/* reduce write cylinder */
#  #define	IDWT_PRECOM	64		/* write precomp cylinder */
#  #define	IDNUMSECT	18		/* number of sectors per track */
#  #define	IDBYTESCT	512		/* number of bytes per sector */
#  
#  /*   Track ID Format Specification   */
#  
#  struct	ididfmat	{
#  		unsigned char LCNH;	/* logical cylinder number high byte */
#  		unsigned char LCNL;	/* logical cylinder number low byte */
#  		unsigned char LHN;	/* logical head number */
#  		unsigned char LSN;	/* logical sector number */
#  		};
#  
#  struct	idtrkfmat	{
#  		struct ididfmat idtrkimage[IDNUMSECT];
#  		};
#  
#  /*   GAP Definitions for FORMAT   */
#  
#  /* #define	IDGAP3	15 */
#  #define IDGAP1_SIZE 16
#  #define IDSYNC_SIZE 13
#  #define IDPAD_SIZE 3
#  #define	IDDPAD	0
#  #define IDIRG_SIZE 15
#  #define IDIDCRC_SIZE 2
#  
#  #ifdef ECC
#  #define IDGAP4_SIZE 104
#  #define IDCHKSM_SIZE 4
#  #else
#  #define IDGAP4_SIZE 140
#  #define IDCHKSM_SIZE 2
#  #endif
#  
#  /* raw sector format for hard disk */
#  
#  struct idsect {
#  	char idsync[IDSYNC_SIZE];
#  	char idam;
#  	char lcnh;
#  	char lcnl;
#  	char lhn;
#  	char lsn;
#  	char idcrc[IDIDCRC_SIZE];
#  	char idpad[IDPAD_SIZE];
#  	char dsync[IDSYNC_SIZE];
#  	char dam;
#  	char dm;
#  	char data[IDBYTESCT];
#  	char chksm[IDCHKSM_SIZE];
#  	char dpad[IDPAD_SIZE];
#  	char irgap[IDIRG_SIZE];
#  };
#  
#  /* raw track format for integral disk */
#  
#  struct idtrk {
#  	char gap1[IDGAP1_SIZE];
#  	struct idsect idsect[IDNUMSECT];
#  	char gap4[IDGAP4_SIZE];
#  };
#  
#  union iddskadr {			/* disk address */
#  	unsigned long all;
#  	struct part {
#  		unsigned char pcnh;
#  		unsigned char pcnl;
#  		unsigned char phn;
#  		unsigned char psn;
#  	} part;
#  };
#  
#  /* first disk sector info */
#  
#  struct iddeftab {
#  	union iddskadr bad;
#  	union iddskadr good;
#  };
#  
#  /*
#   *  The following sector 0 structure should not be used by any other programs
#   *  other than those used for conversion from 1.0 to later releases.
#   */
#  #define IDDEFTAB 61
#  
#  struct idsector0 {
#  	unsigned long driveid;
#  	unsigned long reserved;
#  	unsigned long cyls;
#  	unsigned long tracks;
#  	unsigned long sectors;
#  	unsigned long bytes;
#  	struct iddeftab iddeftab[IDDEFTAB];
#  };
#  
#  
#  
#  
#  
#  
#  /* This file contains the command and status information needed 
#     to initialize structure definitions for the 3B2 product 
#     floppy disk subsystem utilizing the Western Digital 2797
#     floppy controller.  */
#  
#  struct ifdev {
#  	unsigned char statcmd;
#  	unsigned char track;
#  	unsigned char sector;
#  	unsigned char data;
#  } ;
#  
#  struct ifformat {
#  	char iftrack;
#  	char ifsector;
#  	char ifside;
#  	caddr_t	data;
#  	int size;
#  	unsigned char retval;
#  } ;
#  
#  struct ifccmd {			/* structure to track disk requests */
#  	char trknum;		/* track number */
#  	char sectnum;   	/* sector number */
#  	char c_opc;		/* command opcode */
#  	char c_bkcnt;		/* request block count */
#  	daddr_t b_blkno; 	/* disk block number */
#  	paddr_t baddr; 		/* physical data buffer address */
#  	unsigned int bcnt;	/* request byte count */
#  } ;
#  
#  
#  #define	OIFLOPY		0x0004D000L
#  #define	IFLOPY		((struct ifdev *)OIFLOPY)
#  
#  #define IFNTRAC 	2	/* Number of tracks per cylinder */
#  #define IFNHD		2	/* Number of heads per cylinder */	
#  #define IFNDRV		0	/* Number of integral floppy disk drives */
#  #define IFPTN 		0x8	/* Fake partition for full floppy access */
#  #define IFNODEV		0x10	/* Non-partition - allows full disk access */
#  #define IFPDBLKNO	1422	/* Physical description sector number */
#  
#  /* ioctl commands */
#  #define FIOC		('F'<<8)
#  #define IFFORMAT	(FIOC|1)
#  #define IFBCHECK	(FIOC|2)
#  #define IFCONFIRM	(FIOC|3)
#  
#  #define IFIDLEF 	0	/* Defines used for semaphore communication */
#  #define IFWAITF 	1	/* between the integral winchester and */
#  #define IFBUSYF 	2	/* the integral floppy to avoid I/O bus */
#  #define IFFMAT0 	4	/*    contention    */
#  #define IFFMAT1 	8	
#  #define IFDMACNT	511	/* dma byte count for floppy transfer */
#  
#  #define IFRESTORE 	1	/* Used for interrupt cases */
#  #define IFSEEKATT	2
#  #define IFXFER 		3
#  #define IFNONACTIVE 	0
#  
#  #define IFMAXSEEK 5	/* Maximum retries on various requests */
#  #define IFMAXXFER 15
#  #define IFMAXLSTD 1024
#  
#  
#  /* The command opcodes ARE dependent on drive configuration.
#     The following commands are set for a TANDON floppy drive
#     with stepping rates of 6 mS and head load upon spin up. */
#  
#  /* Controller Command Opcodes */
#  
#  #define IFREST 		0x00	/* Recal */
#  #define IFSEEK 		0x10	/* Seek without verify-with verify is 14 */	
#  #define IFSTEP		0x20	/* STEP RATES 0=6 ms, 1=12ms, 2=20ms, 3=30ms */
#  #define IFSTEPI		0x40	/* Step in */
#  #define IFSTEPO		0x60	/* Step out */
#  #define IFRDS 		0x80	/* Read Sector */
#  #define IFWTS		0xA0	/* Write Sector */
#  #define IFRDADD		0xC0	/* Read Address */
#  #define IFRDTRK		0xE0	/* Read Track */
#  #define IFWRTRK		0xF0	/* Write Track */
#  #define IFFRCINT  	0xD0 	/* Force Interrupt Dependent upon int type */
#  
#  /* Disk Command Modifiers */
#  
#  #define IFSTEPRATE	0x00	/* 0=6ms,1=12ms,2=20ms,3=30ms */
#  #define IFVERIFY	0x04	/* Verify Track Address */
#  #define IFLDHEAD	0x08	/* Load Disk Head */
#  #define IFUPTRACK	0x10	/* Update Track Register */
#  #define IFF8DAM		0x01	/* Deleted Data Address Mark */
#  #define IFUPDSSO1	0x02	/* Update Side Select */
#  #define IFMSDELAY	0x04	/* 15ms Delay for Head Settling */
#  #define IFSLENGRP1	0x08	/* Sector Length */
#  #define IFMRECORD	0x10 	/* Multi Record Field */
#  
#  /* Command Status for REST SEEK STEP */
#  
#  #define IFBUSY		0x01	/* Controller Busy Status */
#  #define IFINDPUL	0x02	/* Index Mark Detected form Drive */
#  #define IFTRK00		0x04	/* Head is at Track 00 */
#  #define IFCRCERR	0x08	/* CRC Error */
#  #define IFSKERR		0x10	/* Desired Track was not Verified */
#  #define IFHDLOAD	0x20	/* Head Loaded */
#  #define IFWRPT		0x40	/* Write Protect */
#  #define IFNRDY		0x80	/* Drive Not Ready */
#  
#  /* Status Information for Read / Write Sector Track Commands */
#  
#  #define IFBUSY		0x01	/* Controller Busy */
#  #define IFDRQ		0x02	/* Synonymous with Data Request Output */
#  #define IFLSTDATA 	0x04	/* No Data Response from CPU Within ONE Byte Time */
#  #define IFCRCERR	0x08	/* Error in Data Field */
#  #define IFRECNF		0x10	/* Track Sector Side Were Not Found */
#  #define IFRECT		0x20	/* Zero On WRITE Indicates Record Type on Read */
#  #define IFWRPT		0x40	/* Indicates Write Protection */
#  #define IFNRDY		0x80	/* Drive not Ready */
#  
#  #define	IFIDSIZE	6	/*  size of id field */
#  #define IFTRACKS 	160	/*  total number of tracks  */
#  #define	IFTRKSIDE	80	/*  number of tracks per side  */
#  #define	IFNUMSECT	9	/*  number of sectors per track  */
#  #define	IFBYTESCT	512	/*  number of bytes per sector  */
#  
#  
#  /*    IBM Standard Dual-Density Format Specification - 
#             (512 bytes/sector  9 sectors/track)
#  */
#  
#  #define IFGAP4a_SIZE	80		/* preamble field sizes */
#  #define IFPRSYNC_SIZE	12
#  #define IFIDXMRK_SIZE	4
#  #define IFGAP1_SIZE	52
#  
#  #define IFSYNC1_SIZE	12		/*  sector field sizes  */
#  #define IFIDAMRK_SIZE	4
#  #define IFGAP2_SIZE	22
#  #define IFSYNC2_SIZE	12
#  #define IFDMRK_SIZE	4
#  #define	IFGAP3_SIZE	84
#  
#  #define	IFGAP4_SIZE	316		/*  postamble field size  */
#  
#  /*    Layout of Track Preamble Field    */
#  
#  struct	ifpreamfmat	{
#  	unsigned char GAP4a[IFGAP4a_SIZE];
#  	unsigned char PRSYNC[IFPRSYNC_SIZE];
#  	unsigned char INDEX_MARK[IFIDXMRK_SIZE];
#  	unsigned char GAP1[IFGAP1_SIZE];
#  } ;
#  
#  /*    Layout of Sector Field    */
#  
#  struct	ifsectfmat	{
#  	unsigned char SYNC1[IFSYNC1_SIZE];
#  	unsigned char IDADD_MARK[IFIDAMRK_SIZE];
#  	unsigned char TRACK;
#  	unsigned char SIDE;
#  	unsigned char SECTOR;
#  	unsigned char SECTLEN;
#  	unsigned char CRC1;
#  	unsigned char GAP2[IFGAP2_SIZE];
#  	unsigned char SYNC2[IFSYNC2_SIZE];
#  	unsigned char DATA_MARK[IFDMRK_SIZE];
#  	unsigned char DATA[IFBYTESCT];
#  	unsigned char CRC2;
#  	unsigned char GAP3[IFGAP3_SIZE];
#  } ;
#  
#  /*    Layout of Postamble Field    */
#  
#  struct	ifpostfmat	{
#  	unsigned char GAP4b[IFGAP4_SIZE];
#  } ;
#  
#  /*    Layout of a Complete Track    */
#  
#  struct	iftrkfmat	{
#  	struct ifpreamfmat dskpream;
#  	struct ifsectfmat dsksct[IFNUMSECT];
#  	struct ifpostfmat dskpost;
#  } ;
#  
#  
#  
#  
#  /*
#   * Page Descriptor (Table) Entry Definitions
#   */
#  
#  typedef union pde {    /*  page descriptor (table) entry  */
#  /*    	                                                */
#  /*  +---------------------+---+--+--+--+-+--+-+-+-+-+  */
#  /*  |        pfn          |lck|nr|  |  |r|cw| |l|m|p|  */
#  /*  +---------------------+---+--+--+--+-+--+-+-+-+-+  */
#  /*             21            1  1  1  2 1  1 1 1 1 1   */
#  /*                                                      */
#  	struct {
#  		uint pg_pfn	: 21,	/* Physical page frame number */
#  		     pg_lock	:  1,	/* Lock in core (software) */
#  		     pg_ndref	:  1,	/* Needs reference (software).	*/
#  				:  1,	/* Unused software bit.		*/
#  				:  2,	/* Reserved by hardware.	*/
#  		     pg_ref	:  1,	/* Page has been referenced */
#  		     pg_cw	:  1,	/* Copy on write (fault) */
#  		     		:  1,	/* Reserved by hardware.	*/
#  		     pg_last	:  1,	/* Last (partial) page in segment */
#  		     pg_mod	:  1,	/* Page has been modified */
#  		     pg_pres	:  1;	/* Page is present in memory */
#  	} pgm;
#  
#  	struct {
#  		uint	pg_pde;		/* Full page descriptor (table) entry */
#  	} pgi;
#  } pde_t;
#  
#  #define pg_v	pg_pres		/* present bit = valid bit */
#  
#  /*
#   *	Page Table
#   */
#  
#  #define NPGPT		64		/* Nbr of pages per page table (seg). */
#  typedef union ptbl {
#  	int page[NPGPT];
#  } ptbl_t;
#  
#  /* Page descriptor (table) entry dependent constants */
#  
#  #define	NBPP		2048		/* Number of bytes per page */
#  #define	NBPPT		256		/* Number of bytes per page table */
#  #define	BPTSHFT		8 		/* LOG2(NBPPT) if exact */
#  #define NDPP		4		/* Number of disk blocks per page */
#  #define DPPSHFT		2		/* Shift for disk blocks per page. */
#  
#  #define PNUMSHFT	11		/* Shift for page number from addr. */
#  #define PNUMMASK	0x3F		/* Mask for page number in segment. */
#  #define POFFMASK        0x7FF		/* Mask for offset into page. */
#  #define	PNDXMASK	0x7FFFF		/* Mask for page index into section.*/
#  #define PGFNMASK	0x1FFFFF	/* Mask page frame nbr after shift. */
#  
#  #define	NPTPP		8		/* Nbr of page tables per page.	*/
#  #define	NPTPPSHFT	3		/* Shift for NPTPP. */
#  
#  /* Page descriptor (table) entry field masks */
#  
#  #define PG_ADDR		0xFFFFF800	/* physical page address */
#  #define PG_LOCK		0x00000400	/* page lock bit (software) */
#  #define PG_NDREF	0x00000200	/* need reference bit (software) */
#  #define PG_REF		0x00000020	/* reference bit */
#  #define PG_COPYW	0x00000010	/* copy on write bit */
#  #define PG_LAST		0x00000004	/* Last page bit */
#  #define PG_M		0x00000002	/* modify bit */
#  #define PG_P		0x00000001	/* page present bit */
#  
#  #define ONEPAGE		255
#  #define DZ_PAGE		(unsigned char) 8
#  
#  #define PTSIZE		256		/* page table size in bytes */
#  #define PTSZSHFT	8		/* page table size shift count */
#  
#  
#  /* byte addr to virtual page */
#  
#  #define pnum(X)   ((uint)(X) >> PNUMSHFT) 
#  
#  /* page offset */
#  
#  #define poff(X)   ((uint)(X) & POFFMASK)
#  
#  /*	The page number within a section.
#  */
#  
#  #define pgndx(X)	(((X) >> PNUMSHFT) & PNDXMASK)
#  
#  /* Round up page table address */
#  
#  #define ptround(p)	((int *) (((int)p + PTSIZE-1) & ~(PTSIZE-1)))
#  
#  /* Round down page table address */
#  
#  #define ptalign(p)	((int *) ((int)p & ~(PTSIZE-1)))
#  
#  /*	Disk blocks (sectors) and pages.
#  */
#  
#  #define	ptod(PP)	((PP) << DPPSHFT)
#  #define	dtop(DD)	(((DD) + NDPP - 1) >> DPPSHFT)
#  #define dtopt(DD)	((DD) >> DPPSHFT)
#  
#  /*	Disk blocks (sectors) and bytes.
#  */
#  
#  #define	dtob(DD)	((DD) << SCTRSHFT)
#  #define	btod(BB)	(((BB) + NBPSCTR - 1) >> SCTRSHFT)
#  #define	btodt(BB)	((BB) >> SCTRSHFT)
#  
#  /*	Page tables (64 entries == 256 bytes) to pages.
#  */
#  
#  #define	pttopgs(X)	((X + NPTPP - 1) >> NPTPPSHFT)
#  #define	pttob(X)	((X) << BPTSHFT)
#  #define	btopt(X)	(((X) + NBPPT - 1) >> BPTSHFT)
#  
#  union ptbl *getptbl();		/* page table allocator */
#  
#  extern int		nptalloced;
#  extern int		nptfree;
#  
#  /* Form page descriptor (table) entry from modes and page frame
#  ** number
#  */
#  
#  #define	mkpde(mode,pfn)	(mode | ((pfn) << PNUMSHFT))
#  
#  /*	The following macros are used to check the value
#   *	of the bits in a page descriptor (table) entry 
#   */
#  
#  #define pg_isvalid(pde) 	((pde)->pgm.pg_pres)
#  #define pg_islocked(pde)	((pde)->pgm.pg_lock)
#  
#  /*	The following macros are used to set the value
#   *	of the bits in a page descrptor (table) entry 
#   *
#   *	Atomic instruction is available to clear the present bit,
#   *	other bits are set or cleared in a word operation.
#   */
#  
#  #define pg_setvalid(P)	((P)->pgi.pg_pde |= PG_P) /* Set valid bit.	*/
#  #define pg_clrvalid(P)	((P)->pgi.pg_pde &= ~PG_P) /* Clear valid bit.	*/
#  
#  #define pg_setndref(P)	((P)->pgi.pg_pde |= PG_NDREF)
#  						/* Set need ref bit.	*/
#  #define pg_clrndref(P)	((P)->pgi.pg_pde &= ~PG_NDREF)
#  						/* Clr need ref bit.	*/
#  
#  #define pg_setlock(P)	((P)->pgi.pg_pde |= PG_LOCK)	
#  						/* Set lock bit.	*/
#  #define pg_clrlock(P)	((P)->pgi.pg_pde &= ~PG_LOCK) /* Clear lock bit.	*/
#  
#  #define pg_setmod(P)	((P)->pgi.pg_pde |= PG_M)	
#  						/* Set modify bit.	*/
#  #define pg_clrmod(P)	((P)->pgi.pg_pde &= ~PG_M)	
#  						/* Clear modify bit.	*/
#  
#  #define pg_setcw(P)	((P)->pgi.pg_pde |= PG_COPYW) /* Set copy on write.*/
#  #define pg_clrcw(P)	((P)->pgi.pg_pde &= ~PG_COPYW) /* Clr copy on write.*/
#  
#  #define pg_setref(P)	((P)->pgi.pg_pde |= PG_REF) 	/* Set ref bit.	*/
#  #define pg_clrref(P)	((P)->pgi.pg_pde &= ~PG_REF) /* Clear ref bit.	*/
#  
#  #define pg_setprot(P,b)	
#  
#  /*
#   * Segment Descriptor (Table) Entry Definitions
#   */
#  
#  typedef struct sde {    /*  segment descriptor (table) entry  */
#  /*                                                                            */
#  /*  +--------+--------------+--+--------+ +--------------------------------+  */
#  /*  |  prot  |     len      |  |  flags | |             address            |  */
#  /*  +--------+--------------+--+--------+ +--------------------------------+  */
#  /*       8          14        2     8                      32                 */
#  /*                                                                            */
#  /*					  +--------------------------+-+-+-+  */
#  /*			   (V0):	  |                          |N|W|S|  */
#  /*					  +--------------------------+-+-+-+  */
#  /*						       29             1 1 1   */
#  /*                                                                            */
#  	uint seg_prot	:  8,	/* Segment protection bits */
#  	     seg_len	: 14,	/* Segment length in doublewords */
#  			:  2,	/* Reserved */
#  	     seg_flags	:  8;	/* Segment descriptor flags */
#  	union {
#  		uint address;	/* Address of PDT or physical segment (cont.) */
#  		struct {
#  			uint		: 29,	/* Not used */
#  			     wanted	:  1,	/* "N" bit  */
#  			     shmswap	:  1,	/* "W" bit  */
#  			     sanity	:  1;	/* "S" bit  */
#  		} V0;
#  	} wd2;
#  } sde_t;
#  
#  /*  access modes  */
#  
#  #define KNONE  (unsigned char)  0x00
#  #define KEO    (unsigned char)  0x40	/* KRO on WE32000	*/
#  #define KRE    (unsigned char)  0x80
#  #define KRWE   (unsigned char)  0xC0	/* KRW on WE32000	*/
#  
#  #define UNONE  (unsigned char)  0x00
#  #define UEO    (unsigned char)  0x01	/* URO on WE32000	*/
#  #define URE    (unsigned char)  0x02
#  #define URWE   (unsigned char)  0x03	/* URW on WE32000	*/
#  
#  #define UACCESS (unsigned char) 0x03
#  #define KACCESS (unsigned char) 0xC0
#  
#  #define SEG_RO	(KRWE|URE)
#  #define SEG_RW	(KRWE|URWE)
#  
#  /* descriptor bits */
#  
#  #define SDE_I_bit	(unsigned char) 0x80
#  #define SDE_V_bit	(unsigned char) 0x40
#  #define SDE_T_bit	(unsigned char) 0x10
#  #define	SDE_C_bit	(unsigned char) 0x04
#  #define	SDE_P_bit	(unsigned char) 0x01
#  #define SDE_flags	(unsigned char) 0x41   /*  sets V_bit and P_bit  */
#  #define SDE_kflags	(unsigned char) 0x45   /*  sets V_bit, C_bit and */
#  					       /*  P_bit.		 */
#  
#  #define SDE_SOFT        7
#  
#  #define isvalid(sde)    ((sde)->seg_flags & SDE_V_bit)
#  #define indirect(sde)   ((sde)->seg_flags & SDE_I_bit)
#  #define	iscontig(sde)   ((sde)->seg_flags & SDE_C_bit)
#  #define	istrap(sde)     ((sde)->seg_flags & SDE_T_bit)
#  #define segbytes(sde)   (int)((((sde)->seg_len) + 1) << 3)
#  #define lastpg(sde)     (((sde)->seg_len) >> 8)
#  #define u_access(sde)   (((sde)->seg_prot) & UACCESS)
#  #define k_access(sde)   (((sde)->seg_prot) & KACCESS)
#  #define segindex(addr)	((int)addr & MSK_IDXSEG)
#  
#  #define sde_clrvalid(sde)	((sde)->seg_flags &= ~SDE_V_bit)
#  
#  /*	Segment descriptor (table) dependent constants.	*/
#  
#  #define NBPS		0x20000 /* Number of bytes per segment */
#  #define SNUMSHFT	17	/* Shift for segment number from address. */
#  #define SNUMMASK	0x1FFF	/* Mask for segment number after shift. */
#  #define SOFFMASK	0x1FFFF	/* Mask for offset into segment. */
#  #define PPSSHFT		6	/* Shift for pages per segment. */
#  
#  #define snum(X)   (((uint)(X) >> SNUMSHFT) & SNUMMASK)
#  #define soff(X)   ((uint)(X) & SOFFMASK)
#  
#  
#  /*
#   * Memory Management Unit Definitions
#   */
#  
#  typedef struct _VAR {	/*  virtual address     */
#  	uint v_sid	:  2,	/*  section number      */
#  	     v_ssl	: 13,	/*  segment number      */
#  	     v_psl	:  6,	/*  page number         */
#  	     v_byte	: 11;	/*  offset within page  */
#  } VAR;
#  
#  /*  masks to extract portions of a VAR  */
#  
#  #define MSK_IDXSEG  0x1ffff  /*  lower 17 bits == PSL || BYTE  */
#  
#  typedef struct  _FLTCR { /*  fault code register  */
#  	uint		: 21,
#  	     reqacc	:  4,
#  	     xlevel	:  2,
#  	     ftype	:  5;
#  } FLTCR;
#  
#  /*  access types */
#  
#  #define	AT_SPOPWRITE	 1
#  #define AT_SPOPFTCH	 3
#  #define	AT_ADFTCH	 8
#  #define	AT_OPFTCH	 9
#  #define	AT_WRITE	11
#  #define	AT_IFTCH	13
#  #define	AT_IFAD		12
#  #define	AT_IPFTCH	14
#  #define	AT_MT		 0
#  
#  /*  access execution level */
#  
#  #define	XLVL_K		0
#  #define	XLVL_U		3
#  
#  /*  Fault types  */
#  
#  #define F_NONE       0x0
#  #define F_MPROC	     0x1
#  #define F_RMUPDATE   0x2
#  #define F_SDTLEN     0x3
#  #define F_PWRITE     0x4
#  #define F_PDTLEN     0x5
#  #define F_INVALID    0x6
#  #define F_SEG_N_P    0x7
#  #define F_OBJECT     0x8
#  #define F_PDT_N_P    0x9
#  #define F_P_N_P      0xa
#  #define F_INDIRECT   0xb
#  #define F_ACCESS     0xd
#  #define F_OFFSET     0xe
#  #define F_ACC_OFF    0xf
#  #define F_D_P_HIT    0x1f
#  
#  typedef struct _CONFIG { /*  configuration register  */
#  	uint		: 30,
#  	     ref	:  1,
#  	     mod	:  1;
#  } CR;
#  
#  typedef int SRAMA;		/* Segment descriptor table address */
#  
#  typedef struct _SRAMB {		/* SRAMB Area		*/
#  
#  /*
#   *	+---------+-------------+----------+
#   *	| reserve | # segs      | reserve  |
#   *	+---------+-------------+----------+
#   *	    9		13	   10
#   */
#  	unsigned int		:  9;	/* reserved */
#  	unsigned int	SDTlen	: 13;	/* number of segments in section */
#  	unsigned int		: 10;	/* reserved */
#  } SRAMB;
#  
#  /* Virtual start address of sections */
#  
#  #define VSECT0		0x00000000
#  #define VSECT1		0x40000000
#  #define VSECT2		0x80000000
#  #define VSECT3		0xC0000000
#  
#  #define SRAMBSHIFT	10
#  #define MAXSDTSEG	8192	/* Maxmum number of SDT entries */
#  
#  #define OFF 0
#  #define ON  1
#  
#  /*  MMU-specific addresses  */
#  
#  extern char *mmusrama, *mmusramb, *mmufltcr, *mmufltar, *mmucr, *mmuvar;
#  
#  #define srama  ((SRAMA *) (&mmusrama))
#  #define sramb  ((SRAMB *) (&mmusramb))
#  #define fltcr  ((FLTCR *) (&mmufltcr))
#  #define fltar  ((int *)   (&mmufltar))
#  #define crptr  ((CR *)    (&mmucr))
#  #define varptr ((int *)   (&mmuvar))
#  
#  /*
#   * Peripheral mode functions
#   */
#  
#  #define flushaddr(vaddr)	(*((int *)(varptr)) = (int)(vaddr))
#  #define flushsect(sectno)	(*((SRAMA *)(srama + (sectno))) = \
#  					(*(SRAMA *)(srama + (sectno))))
#  
#  /*	The following variables describe the memory managed by
#  **	the kernel.  This includes all memory above the kernel
#  **	itself.
#  */
#  
#  extern int	kpbase;		/* The address of the start of	*/
#  				/* the first physical page of	*/
#  				/* memory above the kernel.	*/
#  				/* Physical memory from here to	*/
#  				/* the end of physical memory	*/
#  				/* is represented in the pfdat.	*/
#  extern int	syssegs[];	/* Start of the system segment	*/
#  				/* from which kernel space is	*/
#  				/* allocated.  The actual value	*/
#  				/* is defined in the vuifile.	*/
#  extern int	win_ublk[];	/* A window into which a	*/
#  				/* u-block can be mapped.	*/
#  extern pde_t	*kptbl;		/* Kernel page table.  Used to	*/
#  				/* map sysseg.			*/
#  extern int	maxmem;		/* Maximum available free	*/
#  				/* memory.			*/
#  extern int	freemem;	/* Current free memory.		*/
#  extern int	availrmem;	/* Available resident (not	*/
#  				/* swapable) memory in pages.	*/
#  extern int	availsmem;	/* Available swapable memory in	*/
#  				/* pages.			*/
#  
#  /*	Conversion macros
#  */
#  
#  /*	Get page number from system virtual address.  */
#  
#  #define	svtop(X)	((uint)(X) >> PNUMSHFT) 
#  
#  /*	Get system virtual address from page number.  */
#  
#  #define	ptosv(X)	((uint)(X) << PNUMSHFT)
#  
#  
#  /*	These macros are used to map between kernel virtual
#  **	and physical address.  Note that all of physical
#  **	memory is mapped into kernel virtual address space
#  **	in segment zero at the actual physical address of
#  **	the start of memory which is MAINSTORE.
#  */
#  
#  #define kvtophys(vaddr) (svirtophys(vaddr))
#  #define phystokv(paddr) (paddr)
#  
#  /*	Between kernel virtual address and physical page frame number.
#  */
#  
#  #define kvtopfn(vaddr) (svirtophys(vaddr) >> PNUMSHFT)
#  #define pfntokv(pfn)   ((pfn) << PNUMSHFT)
#  
#  /*	Between kernel virtual addresses and the kernel
#  **	segment table entry.
#  */
#  
#  #define	kvtokstbl(vaddr) (&((sde_t *)(*(srama + 1)))[snum(vaddr)])
#  
#  /*	Between kernel virtual addresses and the kernel page
#  **	table.
#  */
#  
#  #define	kvtokptbl(X)	(&kptbl[pgndx((uint)(X) - (uint)syssegs)])
#  
#  /*	The following routines are involved with the pfdat
#  **	table described in pfdat.h
#  */
#  
#  #define	kvtopfdat(kv)	(&pfdat[kvtopfn(kv) - btoc(kpbase)])
#  #define	pfntopfdat(pfn)	(&pfdat[pfn - btoc(kpbase)])
#  #define	pfdattopfn(pfd)	(pfd - pfdat + btoc(kpbase))
#  
#  /*	Test whether a virtual address is in the kernel dynamically
#  **	allocated area.
#  */
#  
#  #define	iskvir(va)	((secnum((uint)va) == SCN1)  &&  \
#  			 (uint)va >= (uint)syssegs)
#  
#  /*
#   * vatosde(v)
#   * returns the segment descriptor entry location
#   * of the virtual address v.
#   */
#  
#  sde_t *vatosde();
#  
#  /*
#   * pde_t *
#   * svtopde(v)
#   * returns the pde entry location of v.
#   *
#   * This macro works only with paged virtual address.
#   */
#  
#  #define svtopde(v) ((pde_t *)(phystokv(vatosde(v)->wd2.address)) + pnum(soff(v)))
#  /*
#   * svtopfn(v)
#   */
#  
#  #define svtopfn(v) (pnum(svirtophys(v)))
#  
#  /*	Page frame number to kernel pde.
#  */
#  
#  #define	pfntokptbl(P)	(kvtokptbl(pfntokv(P)))
#  
#  /* flags used in ptmemall() call
#  */
#  
#  #define PHYSCONTIG 02
#  #define NOSLEEP    01
#  
#  /* Section Id used in flushsect() and loadmmu() */
#  
#  #define SCN0	0
#  #define SCN1	1
#  #define SCN2	2
#  #define SCN3	3
#  
#  
#  /*	Load the mmu registers for a section with the address
#  **	and length found in the proc table.  This is a macro
#  **	rather than a function since it speeds up context
#  **	switches by eliminating the subroutine linkage.
#  */
#  
#  #define loadmmu(p, section) \
#  {	\
#  	register int	index;	\
#  	register int	ipl;	\
#  				\
#  	ipl = spl7();		\
#  	index = (section) - SCN2;	\
#  				\
#  	if (((int *)(p)->p_sramb)[index] != -1) {		\
#  		srama[section] = (p)->p_srama[index];	\
#  		sramb[section] = (p)->p_sramb[index];	\
#  	}		\
#  	splx(ipl);	\
#  }
#  
#  
#  
#  
#  
#  
#  /*
#   *	WE 32106 MAU
#   */
#  
#  /*
#   * MAU ASR (Auxiliary Status Register)
#   */
#  
#  typedef union {
#  	int		word;
#  	struct {
#  		unsigned ra	:1;	/* 31:result available		*/
#  		unsigned	:5;	/* <unused>			*/
#  		unsigned ecp	:1;	/* 25:exception present		*/
#  		unsigned ntnc	:1;	/* 24:non-trapping NAN cntl	*/
#  		unsigned rc	:2;	/* 22-23:rounding control	*/
#  		unsigned n	:1;	/* 21:negative result(indicator)*/
#  		unsigned z	:1;	/* 20:zero result    (indicator)*/
#  		unsigned io	:1;	/* 19:integer overflw(indicator)*/
#  		unsigned pss	:1;	/* 18:inexact	     (sticky)	*/
#  		unsigned csc	:1;	/* 17:context switch cntl	*/
#  		unsigned uo	:1;	/* 16:unordered	     (indicator)*/
#  		unsigned	:1;	/* <unused>			*/
#  		unsigned im	:1;	/* 14:invalid op     (mask)	*/
#  		unsigned om	:1;	/* 13:overflow	     (mask)	*/
#  		unsigned um	:1;	/* 12:underflow	     (mask)	*/
#  		unsigned qm	:1;	/* 11:zerodivide     (mask)	*/
#  		unsigned pm	:1;	/* 10:inexact	     (mask)	*/
#  		unsigned is	:1;	/* 09:invalid op     (sticky)	*/
#  		unsigned os	:1;	/* 08:overflow	     (sticky)	*/
#  		unsigned us	:1;	/* 07:underflow	     (sticky)	*/
#  		unsigned qs	:1;	/* 06:zerodivide     (sticky)	*/
#  		unsigned pr	:1;	/* 05:partial rem.   (indicator)*/
#  		unsigned	:5;	/* <unused>			*/
#  	} bits;
#  } asr_t;
#  
#  /*
#   * Misc. MAU defines
#   */
#  #define	MAU_ID	0		/* support processor id for MAU */
#  #define	JBIT	0x80000000	/* J-bit in double extended format */
#  #define	MAU_SPECIAL	2	/* denotes opcode that requires
#  				 * special page fault handling */
#  #define	SPOPD2	0x03		/* WE32100 SPOPD2 opcode */
#  #define	SPOPT2	0x07		/* WE32100 SPOPT2 opcode */
#  				/* the following are passed as the first
#  				 * arg to mau_pfault */
#  #define	MAU_NOPROBE	0	/* disassemble inst and complete op */
#  #define	MAU_PROBESF	1	/* probe inst on stack fault */
#  #define	MAU_PROBESB	2	/* probe inst on stack bounds fault */
#  #define MAU_WRONLY	3	/* write result only */
#  
#  /*
#   * Round Control (RC) values
#   */
#  
#  #define MRC_RN	0	/* Round to Nearest */
#  #define MRC_RP	1	/* Round towards Plus infinity */
#  #define MRC_RM	2	/* Round towards Minus infinity */
#  #define MRC_RZ	3	/* Round towards Zero (trunctation) */
#  
#  /*
#   *  MAU CR (Command Register)
#   */
#  
#  typedef union {
#  	int	word;			/* for easy manipulation */
#  	struct {
#  		unsigned id	:8;	/* MAU processor id == 0 */
#  		unsigned	:9;	/* <unused>		 */
#  		unsigned opcode	:5;	/* MAU operation	 */
#  		unsigned op1	:3;	/* operand 1		 */
#  		unsigned op2	:3;	/* operand 2		 */
#  		unsigned op3	:4;	/* operand 3 (result)	 */
#  	} mau;
#      } cr_t;
#  
#  
#  /*
#   * Source Operand specifiers
#   */
#  
#  #define MSO_REG0	0	/* MAU register F0 */
#  #define MSO_REG1	1	/* MAU register F1 */
#  #define MSO_REG2	2	/* MAU register F2 */
#  #define MSO_REG3	3	/* MAU register F3 */
#  #define MSO_MEM1	4	/* One word memory */
#  #define MSO_MEM2	5	/* Two word memory */
#  #define MSO_MEM3	6	/* Three word memory */
#  #define MSO_NONE	7	/* No operand */
#  
#  /*
#   * Destination Operand specifiers
#   */
#  
#  #define MDO_SR0		0	/* MAU register F0 (Single-precision) */
#  #define MDO_SR1		1	/* MAU register F1 (Single-precision) */
#  #define MDO_SR2		2	/* MAU register F2 (Single-precision) */
#  #define MDO_SR3		3	/* MAU register F3 (Single-precision) */
#  #define MDO_DR0		4	/* MAU register F0 (Double-precision) */
#  #define MDO_DR1		5	/* MAU register F1 (Double-precision) */
#  #define MDO_DR2		6	/* MAU register F2 (Double-precision) */
#  #define MDO_DR3		7	/* MAU register F3 (Double-precision) */
#  #define MDO_TR0		8	/* MAU register F0 (Triple-precision) */
#  #define MDO_TR1		9	/* MAU register F1 (Triple-precision) */
#  #define MDO_TR2		0xa	/* MAU register F2 (Triple-precision) */
#  #define MDO_TR3		0xb	/* MAU register F3 (Triple-precision) */
#  #define MDO_SMEM	0xc	/* Memory-based (Single-precision) */
#  #define MDO_DMEM	0xd	/* Memory-based (Double-precision) */
#  #define MDO_TMEM	0xe	/* Memory-based (Triple-precision) */
#  #define MDO_NONE	0xf	/* No Operand */
#  
#  /*
#   * ASR bit field defines.
#   */
#  
#  #define ASR_RA		0x80000000
#  #define ASR_ECP		0x2000000
#  #define ASR_NTNC	0x1000000
#  #define ASR_RC		0xC00000
#  #define ASR_N		0x200000
#  #define ASR_Z		0x100000
#  #define ASR_IO		0x80000
#  #define ASR_PSS		0x40000
#  #define ASR_CSC		0x20000
#  #define ASR_UO		0x10000
#  #define ASR_IM		0x4000
#  #define ASR_OM		0x2000
#  #define ASR_UM		0x1000
#  #define ASR_QM		0x800
#  #define ASR_PM		0x400
#  #define ASR_IS		0x200
#  #define ASR_OS		0x100
#  #define ASR_US		0x80
#  #define ASR_QS		0x40
#  #define ASR_PR		0x20
#  
#  /*
#   * in-line asm functions for MAU instructions
#   */
#  
#  asm	void
#  movta(p)
#  {
#  %	mem	p;
#  	mmovta	p
#  }
#  
#  asm	void
#  movfa(p)
#  {
#  %	mem	p;
#  	mmovfa	p;
#  }
#  
#  asm	void
#  movtd(p)
#  {
#  %	mem	p;
#  	mmovtd	p
#  }
#  
#  asm	void
#  movt0(p)
#  {
#  %	mem	p;
#  	mmovxx	p,%x0
#  }
#  
#  asm	void
#  movt1(p)
#  {
#  %	mem	p;
#  	mmovxx	p,%x1
#  }
#  
#  asm	void
#  movt2(p)
#  {
#  %	mem	p;
#  	mmovxx	p,%x2
#  }
#  
#  asm	void
#  movt3(p)
#  {
#  %	mem	p;
#  	mmovxx	p,%x3
#  }
#  
#  asm	void
#  movf0(p)
#  {
#  %	mem	p;
#  	mmovxx	%x0,p
#  }
#  
#  asm	void
#  movf1(p)
#  {
#  %	mem	p;
#  	mmovxx	%x1,p
#  }
#  
#  asm	void
#  movf2(p)
#  {
#  %	mem	p;
#  	mmovxx	%x2,p
#  }
#  
#  asm	void
#  movf3(p)
#  {
#  %	mem	p;
#  	mmovxx	%x3,p
#  }
#  
#  asm	void
#  movf32(p)
#  {
#  %	mem	p;
#  	mmovxd	%x3,p
#  }
#  
#  asm	void
#  movfd(p)
#  {
#  %	mem	p;
#  	mmovfd	p
#  }
#  
#  
#  
#  
#  
#  
#  /*
#   *	Non-Volatile RAM
#   */
#  #define	ONVRAM		0x00043000L
#  #define	NVRSIZ		0x400L
#  
#  #define PASS 1		/* read or write of nvram had no checksum error */
#  #define FAIL 0
#  
#  /* firmware section (256 nibbles) */
#  
#  #define NVRBNAM 45
#  
#  struct fw_nvr {
#  	char passwd[9];			/* interactive mcp password */
#  	unsigned char cons_def;		/* console slot and port #'s */
#  	unsigned short link;		/* download link baud rate */
#  	unsigned char b_dev;		/* default boot device */
#  	char b_name[NVRBNAM];		/* default boot path name */
#  	char dsk_chk;			/* flag to check for second disk */
#  };

	.set	fw_nvr_passwd,0
	.set	fw_nvr_cons_def,9
	.set	fw_nvr_link,10	# a
	.set	fw_nvr_bdev,12	# c
	.set	fw_nvr_dname,13	# d
	.set	fm_nvr_dsk_chk,58 # 3a

#  
#  #define FW_OFSET 0
#  #define FW_NVR ((struct fw_nvr *)(ONVRAM + FW_OFSET))
#  
#  /* UN*X section (256 nibbles) */
#  
#  struct unx_nvr {
#  	unsigned short consflg;
#  	unsigned char nv_month ;
#  	unsigned char nv_year ;
#  	int spmem;
#  	char sys_name[9];
#  	char rootdev;
#  	unsigned long ioslotinfo[12] ;
#  };
#  
#  #define UNX_OFSET 0x80
#  #define UNX_NVR ((struct unx_nvr *)(ONVRAM + UNX_OFSET))
#  

	.set	unx_nvr_consflg,0x80
	.set	unx_nvr_nv_month,0x80+2
	.set	unx_nvr_nv_year,0x80+3
	.set	unx_nvr_spmem,0x80+4
	.set	unx_nvr_sysname,0x80+8
	.set	unx_nvr_rootdev,0x80+17
	.set	unx_nvr_ioslotinfo,0x80+18

#  /* checksum section (4 nibbles) */
#  
#  #define CHKS_OFSET 0x100
#  #define CHKS_NVR (ONVRAM + CHKS_OFSET)
#  

	.set	nvr_chsk,0x100

#  /* extra section (508 nibbles, no chksum calc */
#  
#  # define NERRLOG	4
#  # define NVSANITY	0x372e245f
#  
#  #ifndef fw3b2			/* since types.h is not included in firmware */
#  struct xtra_nvr
#  {
#  	int	nvsanity ;
#  	struct	systate
#  	{
#  		short	csr ;
#  		psw_t	psw ;
#  		int	r3 ;
#  		int	r4 ;
#  		int	r5 ;
#  		int	r6 ;
#  		int	r7 ;
#  		int	r8 ;
#  		int	oap ;
#  		int	opc ;
#  		int	osp ;
#  		int	ofp ;
#  		int	isp ;
#  		int	pcbp ;
#  		FLTCR	mmufltcr ;
#  		int	mmufltar ;
#  		SRAMA	mmusrama[4] ;
#  		SRAMB	mmusramb[4] ;
#  		int	lfp ;
#  	} systate ;
#  	struct	errlog
#  	{
#  		char	*message ;
#  		int	param1 ;
#  		int	param2 ;
#  		int	param3 ;
#  		int	param4 ;
#  		int	param5 ;
#  		time_t	time ;
#  	} errlog[NERRLOG] ;
#  };
#  #endif
#  
#  #define XTRA_OFSET (CHKS_OFSET + 2)
#  #define XTRA_NVR ((struct xtra_nvr *)(ONVRAM + XTRA_OFSET))
#  
#  /* Panic auto reboot control */
#  struct mtc_nvr {
#  	char flags;                      /* status flags */
#  	char dynamic_cnt;                /* current reboot counter */
#  	char static_cnt;                 /* administrator set threshold */
#  	char dynamic_timer;              /* current reboot timer */
#  	char static_timer;               /* administrator set threshold */
#  };
#  
#  #define MTC_OFSET (XTRA_OFSET + sizeof(struct xtra_nvr))
#  #define MTC_NVR ((struct mtc_nvr *)(ONVRAM + MTC_OFSET))
#  
#  /* for fw chnvram routine only! */
#  #define NVR_RD 0	/* only read checksum, don't recalculate it */
#  #define NVR_WR 1	/* recalculate checksum and update it */
#  
#  /* extended firmware error message information */
#  
#  struct fwerr_nvr {
#  	unsigned long gooderror;	/* flag that info is good */
#  	unsigned long errno;		/* errno accumulated till printed */
#  	unsigned long psw;		/* pswstore when flt/int occurred */
#  	unsigned long pc;		/* pcstore when flt/int occurred */
#  	unsigned long misc;		/* info specific to error type */
#  };
#  
#  #define FWERR_OFSET ((NVRSIZ / 2) - sizeof(struct fwerr_nvr))
#  #define FWERR_NVR ((struct fwerr_nvr *)(ONVRAM + FWERR_OFSET))
#  
#  
#  
#  
#  
#  
#  
#  /*
#   * WE32000 process control block
#   */
#  
#  #define MOVEDATA	2	/* size of map moves */
#  
#  struct moveblk
#  	{
#  	int  movesize;		/* size of move */
#  	int *moveaddr;		/* address of target */
#  	int  movedata[MOVEDATA];/* data to be moved */
#  	};
#  
#  /*
#   * Process Control Block (PCB) 
#   */
#  
#  #define MAPINFO		2	/* number of map blocks in PCB */
#  
#  typedef struct ipcb
#  	{
#  	psw_t psw;		/* initial PSW */
#  	int (*pc)();		/* initial program counter (PC) */
#  	int *sp;		/* initial stack pointer (SP) */
#  } ipcb_t;
#  
#  typedef struct pcb
#  	{
#  	psw_t psw;		/* PSW */
#  	int (*pc)();		/* PC */
#  	int *sp;		/* SP */
#  	int *slb;		/* stack lower bound */
#  	int *sub;		/* stack upper bound */
#  	int regsave[11];	/* registers AP,FP,R0-R8 save area */
#  	struct moveblk mapinfo[MAPINFO];	/* map information */
#  } pcb_t;
#  
#  typedef struct kpcb			/* Interrupt pcb */
#  	{
#  	struct ipcb ipcb;	/* initial PCB */
#  	psw_t psw;		/* PSW */
#  	int (*pc)();		/* PC */
#  	int *sp;		/* SP */
#  	int *slb;		/* stack lower bound */
#  	int *sub;		/* stack upper bound */
#  	int regsave[11];	/* registers AP,FP,R0-R8 save area */
#  	int movesize;		/* no map information */
#  } kpcb_t;
#  
#  /*
#   * Symbolic locations of registers in pcb relative to regsave[0]
#   * Usage: u.u_pcb.regsave[K_XX] == u.u_ar0[XX]
#   */
#  
#  #define	K_R0	2
#  #define	K_R1	3
#  #define	K_R2	4
#  #define	K_R3	5
#  #define	K_R4	6
#  #define	K_R5	7
#  #define	K_R6	8
#  #define	K_R7	9
#  #define	K_R8	10
#  #define	K_FP	1	/* FP == R9  */
#  #define	K_AP	0	/* AP == R10 */
#  #define	K_PS	-5	/* PS == R11 */
#  #define	K_SP	-3	/* SP == R12 */
#  #define	K_PC	-4	/* PC == R15 */
#  
#  
#  
#  
#  
#  #define R0      0
#  #define R1      1
#  #define R2      2
#  #define R3      3
#  #define R4      4
#  #define R5      5
#  #define R6      6
#  #define R7      7
#  #define R8      8
#  #define FP      -1      /* FP == R9  */
#  #define AP      -2      /* AP == R10 */
#  #define PS      -7      /* PS == R11 */
#  #define SP      -5      /* SP == R12 */
#  #define PC      -6      /* PC == R15 */
#  
#  
#  
#  
#  
#  
#  /*
#   *  3B2 Internal System Board Data Definitions
#   */
#  
#  /*
#   *	Internal ROM
#   */
#  #define	SBDROM		0x0L
#  #define	ROMSIZE		0x10000L
#  
#  /*
#   *	Memory Size Register
#   */
#  
#  #define DRDEVL		0x01		/* large DRAM devices on memory array */
#  #define MBNK2		0x02		/* number of banks equipped on array */
#  #define DRSIZL		0x100000 	/* large devs in one bank total 1 M */
#  #define DRSIZS		0x40000  	/* small devs in one bank total 256 K */
#  #define	OMEMSIZ		0x0004C003L
#  #define	MEMSIZ		*((char *)OMEMSIZ)
#  
#  /*
#   *	Mainstore Memory Space
#   */
#  #define	MAINSTORE	0x2000000L
#  #define SPMEM		0x2004000L
#  #define EPMEM		0x2100000L
#  /*
#   *  User address space offsets
#   *
#   *****************************  NOTE - NOTE  *********************************
#   *
#   *	 ANY CHANGES THE THE FOLLOWING DEFINES, NEED TO BE REFLECTED IN
#   *	    EITHER ml/misc.s, OR ml/ttrap.s, OR BOTH.
#   */
#  
#  #define UVBASE		((unsigned)0x80000000L)
#  #define UVTEXT		((unsigned)0x80800000L)
#  #define UVUBLK		((unsigned)0xc0000000L)
#  #define UVSTACK		((unsigned)0xc0020000L)
#  #define UVSHM		((unsigned)0xc1000000L)
#  
#  
#  
#  
#  
#  
#  
#  /*
#   *	Programmable Interval Timer (8253)
#   *
#   *				     7	    0
#   *				    +--------+
#   *	(struct	sit *) -> count0    |	     |
#   *				    +--------+
#   *
#   *				     7	    0
#   *				    +--------+
#   *		       -> count1    |	     |
#   *				    +--------+
#   *
#   *				     7	    0
#   *				    +--------+
#   *	               -> count2    |	     |
#   *				    +--------+
#   *
#   *				     7	    0
#   *				    +--------+
#   *	               -> command   |	     |
#   *				    +--------+
#   *
#   * 16 bit counters, loaded and read 1 byte at a time.
#   *
#   */
#  
#  struct	sit {
#  	int :24; unsigned char count0;
#  	int :24; unsigned char count1;
#  	int :24; unsigned char count2;
#  	int :24; unsigned char command;
#  	int :24; unsigned char c_latch;
#  	};
#  
#  /*
#   *	control word format:
#   *		  7   6   5   4  3  2  1   0
#   *		SC1 SC0 RL1 RL0 M2 M1 M0 BCD
#   */
#  #define SITSC	0xc0				/* SC mask */
#  #define SITRL	0x30				/* RL mask */
#  #define SITMD	0x0e				/* M mask */
#  
#  #define SITCT0	0x00				/* select counter (SC) */
#  #define SITCT1	0x40
#  #define SITCT2	0x80
#  #define SITILL	0xc0
#  
#  #define SITLAT	0x00				/* read/load (RL) */
#  #define SITLSB	0x10
#  #define SITMSB	0x20
#  #define SITLMB	0x30
#  
#  #define SITMD0	0x00				/* mode (M) */
#  #define SITMD1	0x02
#  #define SITMD2	0x04
#  #define SITMD3	0x06
#  #define SITMD4	0x08
#  #define SITMD5	0x0a
#  
#  #define SITBIN	0x00				/* BCD */
#  #define SITBCD	0x01
#  
#  #define MAXMS	0x00				/* maximum time - 640ms */
#  
#  #define ITINIT	SITCT1|SITLMB|SITMD2|SITBIN	/* init interval timer */
#  #define ITLSB	0xe8		    		/* least sig byte - 10ms */
#  #define ITMSB	0x03		    		/* most  sig byte - 10ms */
#  
#  #define STINIT	SITCT0|SITLMB|SITMD4|SITBIN	/* init sanity timer */
#  #define STLSB	MAXMS				/* least sig byte - 640ms */
#  #define STMSB	MAXMS				/* most  sig byte - 640ms */
#  
#  #define SITST	0x00;				/* sanity timer - sublev0 */
#  #define SITIT	0x05;				/* interval timer - sublev5 */
#  
#  #define	OSIT		0x00042000L
#  #define	SBDSIT		((struct sit *)OSIT)
#  
#  
#  
#  
#  
#  


# Memory map

#    00000000  ROM
#    00008000
#    00040000  MMU
#    00041000  TOD
#    00042000  TIMER
#    00043000  NVRAM
#    00044000  CSR
#    00045000  DMAID
#    00046000  DMAIUA
#    00047000  DMAIUB
#    00048000  DMAC
#    00049000  IU
#    0004A000  ID
#    0004d000  IF
#    0004e000  DMAIF

#     2000008 STACK0
#     2000808 INTR_STACK0
#     2000858         -- scratch?
#     200085c         -- scratch?
#     2000860
#     2000864 runflag
#     2000868         -- scratch?
#     200086c         -- scratch?
#     2000870         -- scratch?

	.set	mmu_base,0x40000
	.set	mmu_scdl,mmu_base+0x0
	.set	mmu_scdh,mmu_base+0x1
	.set	mmu_pdcrl,mmu_base+0x2
	.set	mmu_pdcrh,mmu_base+0x3
	.set	mmu_pdcll,mmu_base+0x4
	.set	mmu_pdclh,mmu_base+0x5
	.set	mmu_srama,mmu_base+0x6
	.set	mmu_sramb,mmu_base+0x7
	.set	mmu_fc,mmu_base+0x8
	.set	mmu_fa,mmu_base+0x9
	.set	mmu_conf,mmu_base+0xa
	.set	mmu_var,mmu_base+0xb

	.set	timer_base,0x42000
	.set	timer_diva,timer_base+0x3
	.set	timer_divb,timer_base+0x7
	.set	timer_divc,timer_base+0xb
	.set	timer_ctrl,timer_base+0xf
	.set	timer_latch,timer_base+0x13

	.set	nvram_base,0x43000

	.set	csr_base,0x44000
	# Read
	.set	csr_datal,csr_base+2
	.set	csr_datah,csr_base+3
	# Write
	.set	csr_clr_bto,csr_base+0x3	# clear bus timeout error
	.set	csr_clr_mpe,csr_base+0x7	# clear memory parity error
	.set	csr_reset,csr_base+0xb		# system reset request
	.set	csr_clr_maf,csr_base+0xf	# clear memory alignment fault
	.set	csr_set_fled,csr_base+0x13	# set failure LED
	.set	csr_clr_fled,csr_base+0x17	# clear failure LED
	.set	csr_fm_on,csr_base+0x1b		# floppy motor on
	.set	csr_fm_off,csr_base+0x1f	# floppy motor off
	.set	csr_set_inht,csr_base+0x23	# set inhibit timers
	.set	csr_clr_inht,csr_base+0x27	# clr inhibit timers
	.set	csr_set_inhf,csr_base+0x2b	# set inhibit faults
	.set	csr_clr_inhf,csr_base+0x2f	# clr inhibit faults
	.set	csr_set_pir9,csr_base+0x33	# set pir9
	.set	csr_clr_pir9,csr_base+0x37	# clr pir9
	.set	csr_set_pir8,csr_base+0x3b	# set pir8
	.set	csr_clr_pir8,csr_base+0x3f	# clr pir8

	.set	dmaid_base,0x45000

	.set	dmac_base,0x48000

	.set	iu_base,0x49000
	# Read/Write
	.set	iu_mr12a,iu_base+0x0
	.set	iu_mr12b,iu_base+0x8
	# Read
	.set	iu_sra,iu_base+1
	.set	iu_rhra,iu_base+3
	.set	iu_ipcr,iu_base+4
	.set	iu_isr,iu_base+5
	.set	iu_ctu,iu_base+6
	.set	iu_ctl,iu_base+7
	.set	iu_srb,iu_base+9
	.set	iu_rhrb,iu_base+11
	.set	iu_inprt,iu_base+13
	.set	iu_start_ctr,iu_base+14
	.set	iu_stop_ctr,iu_base+15
	# Write
	.set	iu_csra,iu_base+1
	.set	iu_cra,iu_base+2
	.set	iu_thra,iu_base+3
	.set	iu_acr,iu_base+4
	.set	iu_imr,iu_base+5
	.set	iu_ctur,iu_base+6
	.set	iu_ctlr,iu_base+7
	.set	iu_csrb,iu_base+9
	.set	iu_crb,iu_base+10
	.set	iu_thrb,iu_base+11
	.set	iu_ocpr,iu_base+13
	.set	iu_sopr,iu_base+14
	.set	iu_ropr,iu_base+15

	.set	id_base,0x4a000
	.set	id_data,id_base+0x0
	.set	id_cmd_stat,id_base+0x1

	.set	mem_size,0x4c003

	.set	if_base,0x4d000
	.set	if_data,if_base+0x0
	.set	if_cmd_stat,if_base+0x1


	.set	dmaif_base,0x4e000

	.set	symtell,   0x81e100

	.set	stack0,    0x2000008
	.set	istack0,   0x2000808
	.set	rsthand,   0x2000858
	.set	runflg,    0x2000864
	.set	meminit,   0x200086c
	.set	hdcspec,   0x2000a74
	.set	physinfo,  0x2000a80
	.set	release,   0x0001168
	.set	console,   0x20011e8
	.set	memsize,   0x20011ec
	.set	num_edt,   0x20011f0
	.set	exchand,   0x20011f4
	.set	inthand,   0x20011f8
	.set	dmn_vexc,  0x20012dc
	.set	dmn_vgate, 0x20012e0
	.set	dmn_vsint, 0x20012e4
	.set	edt,       0x2001514
	.set	cmdqueue,  0x2001200
	.set	pswstore,  0x2001258
	.set	pcstore,   0x200125c
	.set	save_r0,   0x2001264
	.set	access,	   0x2001268
	.set	option,	   0x200126c
	.set	fl_cons,   0x20012a8
	.set	spwrinh,   0x20012d0
	.set	bpthand,   0x20012d8
	.set	memstart,  0x2001504
	.section	.text, "x"
l0:
	.word	0x00000548, 0xffffffff

l8:	.word	0xffffffff, 0xffffffff
	.word	0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff	# 000010
	.word	0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff	# 000020
	.word	0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff	# 000030
	.word	0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff	# 000040
l50:
	.word	0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff	# 000050
	.word	0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff	# 000060
	.word	0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff	# 000070
l80:
	.word	0x000005d8, 0x02000b78, 0x02000b78            	# 000080

### Exception Vector Table
### ----------------------
###
### Normal Exception Vector = 0x00000548 which points to 0x421F
###
### Interrupt Vector Table Pointers
### -------------------------------
###
### NMI Interrupt Handler
###
###   0x8C = 02000bc8

	.word	                                     0x02000bc8	# 000080

###
### Auto Vector Interrupts
###
###   0x090:  02000bc8
###   0x094:  02000bc8
###   0x098:  02000bc8
###   0x09C:  02000bc8
###   0x0A0:  02000bc8
###   0x0A4:  02000bc8
###   0x0A8:  02000bc8
###   0x0AC:  02000c18
###   0x0B0:  02000c68
###   0x0B4:  02000cb8
###   0x0B8:  02000d08
###   0x0BC:  02000d58
###   0x0C0:  0x200da8
###   0x0C4:  0x200da8
###   0x0C8:  0x200e48
###   0x0CC:  0x200bc8
###   0x0D0:  0x200bc8
###    ... [same] ...
###   0x104:  0x200bc8
###   0x108:  0x200bc8

	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000090
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000c18	# 0000a0
	.word	0x02000c68, 0x02000cb8, 0x02000d08, 0x02000d58	# 0000b0
	.word	0x02000da8, 0x02000da8, 0x02000e48, 0x02000bc8	# 0000c0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0000d0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0000e0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0000f0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8            	# 000100
###
### Device Interrupt Handlers
###
###   0x10c:  0x200bc8
###   0x110:  0x200bc8
###    ... [same] ...
###   0x484:  0x200bc8
###   0x488:  0x200bc8
###
	.word	                                     0x02000bc8	# 000100
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000110
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000120
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000130
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000140
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000150
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000160
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000170
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000180
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000190
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0001a0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0001b0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0001c0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0001d0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0001e0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0001f0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000200
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000210
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000220
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000230
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000240
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000250
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000260
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000270
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000280
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000290
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0002a0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0002b0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0002c0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0002d0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0002e0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0002f0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000300
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000310
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000320
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000330
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000340
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000350
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000360
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000370
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000380
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000390
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0003a0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0003b0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0003c0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0003d0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0003e0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 0003f0
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000400
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000410
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000420
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000430
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000440
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000450
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000460
	.word	0x02000bc8, 0x02000bc8, 0x02000bc8, 0x02000bc8	# 000470
	.word	0x02000bc8, 0x02000bc8                        	# 000480

###
### In all, there are 8 distinct interrupt PCBPs:
###
###    02000bc8
###    02000c18
###    02000c68
###    02000d08
###    02000cb8
###    02000d58
###    02000da8
###    02000e48

	.word	                         0x02000bc8

#  #define BASE    0x48C   /* The physical address of the vector table     */
#                          /* in system board rom.  Fixed address.         */
#  #define VBASE   ((struct vectors *)(VROM + BASE))
#  
#  /*************************/
#  /* TRANSFER VECTOR TABLE */
#  /*************************/
#  
#          struct vectors {
#                  long *p_runflg;         /* flag indicating whether */
#                                          /* system is safe for booting */
#                                          /* 0xFEEDBEEF = fatal error */
#                  struct edt *p_edt;      /* ptr to equipped device table */
#                  long (**p_inthand)();   /* ptr to location containing */
#                                          /* address of int. handlers */
#                  long (**p_exchand)();   /* ptr to locationcontaining */
#                                          /* address of exc. handler */
#                  long (**p_rsthand)();   /* ptr to location containing */
#                                          /* address of reset handler */
#                  struct bootcmd *p_cmdqueue;     /* ptr to command queue */
#                                                  /* for boot command */
#                  struct fl_cons *p_fl_cons;      /* ptr to float cons struct */
#  
#                  /* Commonly used routines available to firmware */
#  
#                  long *p_option;         /* ptr to ptr to option */
#                                          /* number (for getedt) */
#                  char (*p_getedt)();     /* routine to fill edt structure */
#                  char (*p_printf)();     /* location of printf routine */
#                  char (*p_gets)();       /* location of gets routine */
#                  char (*p_sscanf)();     /* location of sscanf routine */
#                  char (*p_strcmp)();     /* location of strcmp routine */
#                  char (*p_excret)();     /* routine to set up a return */
#                                          /* point for exceptions */
#                  char *p_access;         /* access permiss for printf etc. */
#                  char (*p_getstat)();    /* routine to check console for */
#                                          /* a character present */
#                  char (*p_chknvram)();   /* location of routine to verify */
#                                          /* checksum over non-volatile RAM */
#                  char (*p_rnvram)();     /* location of routine to read */
#                                          /* non-volatile RAM */
#                  char (*p_wnvram)();     /* location of routine to write */
#                                          /* non-volatile RAM */
#                  char (*p_hd_acs)();     /* location of routine to access */
#                                          /* hard disk */
#                  char (*p_fd_acs)();     /* location of routine to access */
#                                          /* floppy disk */
#                  char *p_num_edt;        /* ptr to location containing */
#                                          /* number of devices in edt */
#                  long *p_memsize;        /* ptr to location containing */                                        /* size of main memory */
#                  long *p_memstart;       /* ptr to location containing */
#                                          /* start of main memory for UN*X */
#                  char *p_release;        /* ptr to location containing */
#                                          /* release of code */
#                  struct pdinfo *p_physinfo;      /* ptr to disk phys info */
#                  long *p_pswstore;       /* ptr to psw before exc or interrupt */
#                  long *p_pcstore;        /* ptr to pc before exc or interrupt */
#                  struct duart **p_console;       /* ptr to ptr to console uart */
#                  char (*p_setbaud)();    /* ptr to setbaud routine */
#                  long *p_save_r0;        /* ptr to r0 before exc */
#                  struct serno *p_serno;  /* ptr to serial number struct */
#                  long (**p_bpthand)();   /* ptr to location containing address */
#                                          /* of bpt and trace exc handler */
#                  char *p_spwrinh;        /* location for soft power inhibit */
#                  long *p_meminit;        /* location for memory init flag */
#                  long (*p_bzero)();      /* ptr to memory zero routine */
#                  long (*p_setjmp)();     /* ptr to setjmp routine */
#                  long (*p_longjmp)();    /* ptr to longjmp routine */
#                  char (*p_dispedt)();    /* ptr to display edt routine */
#                  long (*p_hwcntr)();     /* ptr to duart counter delay routine */
#                  long *dmn_vexc;         /* demon virt proc/stk excep hdlr pcb */
#                  long *dmn_vgate;        /* demon virtual gate table location */
#                  long *dmn_vsint;        /* demon virt stray intrpt pcb loc */
#                  char (*p_fw_sysgen)();  /* ptr to generic sysgen routine */
#                  char (*p_ioblk_acs)();  /* ptr to ioblk_acs routine */
#                  char (*p_brkinh)();     /* ptr to break inhibit routine */
#                  char *p_hdcspec;        /* location of fw hdc spec params */
#                  int  (*p_symtell)();    /* Function to tell xmcp where  */
#                                          /* the symbol table is.         */
#                  int (*p_demon)();       /* Function to enter demon w/o init */
#          };
#  

VBASE:

	.word	runflg		# long *p_runflg;
p_edt:	.word	edt		# struct edt *p_edt; 
p_inthand:
	.word	inthand		# long (**p_inthand)();
# 498
p_exchand:
	.word	exchand		# long (**p_exchand)();
# 49c
	.word	rsthand		# long (**p_rsthand)();
# 4a0
p_cmdqueue:
	.word	cmdqueue	# struct bootcmd *p_cmdqueue;
# 4a4
p_fl_cons:
	.word	fl_cons		# struct fl_cons *p_fl_cons;
# 4a8
	.word	option		# long *p_option;
# 4ac
	.word	getedt		# char (*p_getedt)();
# 4b0
p_printf:
	.word	printf		# char (*p_printf)();
# 4b4
p_gets:
	.word	gets		# char (*p_gets)();
#4b8
	.word	sscanf		# char (*p_sscanf)();
# 4bc
	.word	strcmp		# char (*p_strcmp)();
# 4c0
p_excret:
	.word	excret		# char (*p_excret)();
# 4c4
p_access:
	.word	access		# char *p_access;
# 4c8
p_getstat:
	.word	getstat		# char (*p_getstat)(); 
# 4cd
	.word	chknvram	# char (*p_chknvram)();
# 4d0
	.word	rnvram		# char (*p_rnvram)();
# 4d4
	.word	wnvram		# char (*p_wnvram)();
# 4d8
	.word	hd_acs		# char (*p_hd_acs)(); 
# 4dc
	.word	fd_acs		# char (*p_fd_acs)();
# 4e0
p_num_edt:
	.word	num_edt		# char *p_num_edt;
# 4e4
p_memsize:
	.word	memsize		# long *p_memsize; 
# 4e8
p_memstart:
	.word	memstart	# long *p_memstart;
# 4ec
	.word	release		# char *p_release;
# 4f0
	.word	physinfo	# struct pdinfo *p_physinfo;
# 4f4
	.word	pswstore	# long *p_pswstore;
# 4f8
	.word	pcstore		# long *p_pcstore;
# 4fc
p_console:
	.word	console		# struct duart **p_console;
# 500
	.word	setbaud		# char (*p_setbaud)();
# 504
	.word	save_r0		# long *p_save_r0;
# 508
p_serno:
	.word	serno		# struct serno *p_serno;
# 50c
p_bpthand:
	.word	bpthand		# long (**p_bpthand)();
# 510
p_spwrinh:
	.word	spwrinh		# char *p_spwrinh;
# 514
p_meminit:
	.word	meminit	# long *p_meminit; 
# 518
p_bzero:
	.word	bzero		# long (*p_bzero)();
# 51c
p_setjmp:
	.word	setjmp		# long (*p_setjmp)();
# 520
	.word	longjmp		# long (*p_longjmp)();
# 524
	.word	l4e14		# char (*p_dispedt)();
# 528
p_hwcntr:
	.word	hwcntr		# long (*p_hwcntr)();
# 52c
	.word	dmn_vexc	# long *dmn_vexc;
# 530
	.word	dmn_vgate	# long *dmn_vgate;
# 534
	.word	dmn_vsint	# long *dmn_vsint;
# 538
	.word	fw_sysgen	# char (*p_fw_sysgen)();
# 53c
	.word	ioblk_acs	# char (*p_ioblk_acs)(); 
# 540
p_brkinh:
	.word	brkinh		# char (*p_brkinh)(); 
# 544
	.word	hdcspec		# char *p_hdcspec; 
# 548
	.word	symtell		# int  (*p_symtell)();
# 54c
	.word	demon		# int (*p_demon)();
# 550
	.word	symtell		# 
# 554
	.word	l4259		# 
# 558
	.word	symtell		# 
	.word	demon		# 
# 560
	.word	symtell		# 
	.word	demon		# 
	.word	symtell		# 
	.word	demon		# 
# 570
	.word	symtell		# 
	.word	demon		# 
	.word	symtell		# 
	.word	demon		# 
# 580
	.word	symtell		# 
	.word	demon		# 
	.word	symtell		# 
	.word	demon		# 
# 590
	.word	symtell		# 
	.word	demon		# 
	.word	symtell		# 
	.word	demon		# 
# 5a0
	.word	symtell		# 
	.word	demon		# 
	.word	symtell		# 
	.word	demon		# 
# 5b0
	.word	symtell		# 
	.word	demon		# 
	.word	symtell		# 
	.word	l4259		# 
# 5c0
	.word	symtell		# 
	.word	demon		# 

l5c8:
	.word	0x2f66696c, 0x6c656474
l5d0:
	.byte	0x00
l5d1:
	.byte	0x46
	.byte	0x44
	.byte	0x35

	.word	            0x00000000, 0x0081e180
	.word	reset
	.word	0x02000008

l5e4:
	.word	0x00000000, 0x00000000, 0x00000000
	.word	0x02000008, 0x02000808, 0x00000000, 0x00000000	# 0005f0
	.word	0x00000000, 0x00000000, 0x00000000, 0x00000000	# 000600
	.word	0x00000000, 0x00000000, 0x00000000, 0x00000000	# 000610
	.word	0x00000000, 0x00000000                        	# 000620

### Strings

# 628:	"SBD"
l628:
	.byte	0x53, 0x42, 0x44, 0x00	# 000628

# 62c:	"\nEnter name of program to execute [ %s ]: "
l62c:
	.byte	0x0a, 0x45, 0x6e, 0x74	# 00062c
	.byte	0x65, 0x72, 0x20, 0x6e	# 000630
	.byte	0x61, 0x6d, 0x65, 0x20	# 000634
	.byte	0x6f, 0x66, 0x20, 0x70	# 000638
	.byte	0x72, 0x6f, 0x67, 0x72	# 00063c
	.byte	0x61, 0x6d, 0x20, 0x74	# 000640
	.byte	0x6f, 0x20, 0x65, 0x78	# 000644
	.byte	0x65, 0x63, 0x75, 0x74	# 000648
	.byte	0x65, 0x20, 0x5b, 0x20	# 00064c
	.byte	0x25, 0x73, 0x20, 0x5d	# 000650
	.byte	0x3a, 0x20, 0x00

# 657:	"\n"
l657:
	.byte	0x0a, 0	# 000654


# 659:	"passwd"
l659:
	.byte	       0x70, 0x61, 0x73	# 000658
	.byte	0x73, 0x77, 0x64, 0x00	# 00065c


# 660:	"\nenter old password: "
l660:
	.byte	0x0a, 0x65, 0x6e, 0x74	# 000660
	.byte	0x65, 0x72, 0x20, 0x6f	# 000664
	.byte	0x6c, 0x64, 0x20, 0x70	# 000668
	.byte	0x61, 0x73, 0x73, 0x77	# 00066c
	.byte	0x6f, 0x72, 0x64, 0x3a	# 000670
	.byte	0x20, 0x00            	# 000674

# 676:	"\nenter new password: "
l676:
	.byte	             0x0a, 0x65	# 000674
	.byte	0x6e, 0x74, 0x65, 0x72	# 000678
	.byte	0x20, 0x6e, 0x65, 0x77	# 00067c
	.byte	0x20, 0x70, 0x61, 0x73	# 000680
	.byte	0x73, 0x77, 0x6f, 0x72	# 000684
	.byte	0x64, 0x3a, 0x20, 0x00	# 000688


# 68c:	"\nconfirmation: "
l68c:
	.byte	0x0a, 0x63, 0x6f, 0x6e	# 00068c
	.byte	0x66, 0x69, 0x72, 0x6d	# 000690
	.byte	0x61, 0x74, 0x69, 0x6f	# 000694
	.byte	0x6e, 0x3a, 0x20, 0x00	# 000698


# 69c:	"\n"
l69c:
	.byte	0x0a, 0x00            	# 00069c

# 69e:	"newkey"
l69e:
	.byte	             0x6e, 0x65	# 00069c
	.byte	0x77, 0x6b, 0x65, 0x79	# 0006a0
	.byte	0x00                  	# 0006a4

# 6a5:	"\nCreating a floppy key to enable clearing of saved NVRAM information.\n\n"
l6a5:
	.byte	       0x0a, 0x43, 0x72	# 0006a4
	.byte	0x65, 0x61, 0x74, 0x69	# 0006a8
	.byte	0x6e, 0x67, 0x20, 0x61	# 0006ac
	.byte	0x20, 0x66, 0x6c, 0x6f	# 0006b0
	.byte	0x70, 0x70, 0x79, 0x20	# 0006b4
	.byte	0x6b, 0x65, 0x79, 0x20	# 0006b8
	.byte	0x74, 0x6f, 0x20, 0x65	# 0006bc
	.byte	0x6e, 0x61, 0x62, 0x6c	# 0006c0
	.byte	0x65, 0x20, 0x63, 0x6c	# 0006c4
	.byte	0x65, 0x61, 0x72, 0x69	# 0006c8
	.byte	0x6e, 0x67, 0x20, 0x6f	# 0006cc
	.byte	0x66, 0x20, 0x73, 0x61	# 0006d0
	.byte	0x76, 0x65, 0x64, 0x20	# 0006d4
	.byte	0x4e, 0x56, 0x52, 0x41	# 0006d8
	.byte	0x4d, 0x20, 0x69, 0x6e	# 0006dc
	.byte	0x66, 0x6f, 0x72, 0x6d	# 0006e0
	.byte	0x61, 0x74, 0x69, 0x6f	# 0006e4
	.byte	0x6e, 0x0a, 0x0a, 0x00	# 0006e8


# 6ec:	"go"
l6ec:
	.byte	0x67, 0x6f, 0x00      	# 0006ec

# 6ef:	"Insert a formatted floppy, then type 'go' (q to quit): "
l6ef:
	.byte	                   0x49	# 0006ec
	.byte	0x6e, 0x73, 0x65, 0x72	# 0006f0
	.byte	0x74, 0x20, 0x61, 0x20	# 0006f4
	.byte	0x66, 0x6f, 0x72, 0x6d	# 0006f8
	.byte	0x61, 0x74, 0x74, 0x65	# 0006fc
	.byte	0x64, 0x20, 0x66, 0x6c	# 000700
	.byte	0x6f, 0x70, 0x70, 0x79	# 000704
	.byte	0x2c, 0x20, 0x74, 0x68	# 000708
	.byte	0x65, 0x6e, 0x20, 0x74	# 00070c
	.byte	0x79, 0x70, 0x65, 0x20	# 000710
	.byte	0x27, 0x67, 0x6f, 0x27	# 000714
	.byte	0x20, 0x28, 0x71, 0x20	# 000718
	.byte	0x74, 0x6f, 0x20, 0x71	# 00071c
	.byte	0x75, 0x69, 0x74, 0x29	# 000720
	.byte	0x3a, 0x20, 0x00      	# 000724

# 727:	"\nCreation of floppy key complete\n\n"
l727:
	.byte	                   0x0a	# 000724
	.byte	0x43, 0x72, 0x65, 0x61	# 000728
	.byte	0x74, 0x69, 0x6f, 0x6e	# 00072c
	.byte	0x20, 0x6f, 0x66, 0x20	# 000730
	.byte	0x66, 0x6c, 0x6f, 0x70	# 000734
	.byte	0x70, 0x79, 0x20, 0x6b	# 000738
	.byte	0x65, 0x79, 0x20, 0x63	# 00073c
	.byte	0x6f, 0x6d, 0x70, 0x6c	# 000740
	.byte	0x65, 0x74, 0x65, 0x0a	# 000744
	.byte	0x0a, 0x00            	# 000748

# 74a:	"sysdump"
l74a:
	.byte	             0x73, 0x79	# 000748
	.byte	0x73, 0x64, 0x75, 0x6d	# 00074c
	.byte	0x70, 0x00            	# 000750

# 752:	"version"
l752:
	.byte	             0x76, 0x65	# 000750
	.byte	0x72, 0x73, 0x69, 0x6f	# 000754
	.byte	0x6e, 0x00            	# 000758

# 75a:	"\nCreated: %s\n"
l75a:
	.byte	             0x0a, 0x43	# 000758
	.byte	0x72, 0x65, 0x61, 0x74	# 00075c
	.byte	0x65, 0x64, 0x3a, 0x20	# 000760
	.byte	0x25, 0x73, 0x0a, 0x00	# 000764

# 768:	"Issue: %08lx\n"
l768:
	.byte	0x49, 0x73, 0x73, 0x75	# 000768
	.byte	0x65, 0x3a, 0x20, 0x25	# 00076c
	.byte	0x30, 0x38, 0x6c, 0x78	# 000770
	.byte	0x0a, 0x00            	# 000774

# 776:	"Release: %s\nLoad: %s\n"
l776:
	.byte	             0x52, 0x65	# 000774
	.byte	0x6c, 0x65, 0x61, 0x73	# 000778
	.byte	0x65, 0x3a, 0x20, 0x25	# 00077c
	.byte	0x73, 0x0a, 0x4c, 0x6f	# 000780
	.byte	0x61, 0x64, 0x3a, 0x20	# 000784
	.byte	0x25, 0x73, 0x0a, 0x00	# 000788


# 78c:	"Serial Number: %08lx\n\n"
l78c:
	.byte	0x53, 0x65, 0x72, 0x69	# 00078c
	.byte	0x61, 0x6c, 0x20, 0x4e	# 000790
	.byte	0x75, 0x6d, 0x62, 0x65	# 000794
	.byte	0x72, 0x3a, 0x20, 0x25	# 000798
	.byte	0x30, 0x38, 0x6c, 0x78	# 00079c
	.byte	0x0a, 0x0a, 0x00      	# 0007a0

# 7a3:	"q"
l7a3:
	.byte	                   0x71	# 0007a0
	.byte	0x00                  	# 0007a4

# 7a5:	"edt"
l7a5:
	.byte	       0x65, 0x64, 0x74	# 0007a4
	.byte	0x00                  	# 0007a8

# 7a9:	"error info"
l7a9:
	.byte	       0x65, 0x72, 0x72	# 0007a8
	.byte	0x6f, 0x72, 0x20, 0x69	# 0007ac
	.byte	0x6e, 0x66, 0x6f, 0x00	# 0007b0

# 7b4:	"baud"
l7b4:
	.byte	0x62, 0x61, 0x75, 0x64	# 0007b4
	.byte	0x00                  	# 0007b8

# 7b9:	"?"
l7b9:
	.byte	       0x3f, 0x00      	# 0007b8

# 7bb:	"\nEnter an executable or system file, a directory name,\n"
l7bb:
	.byte	                   0x0a	# 0007b8
	.byte	0x45, 0x6e, 0x74, 0x65	# 0007bc
	.byte	0x72, 0x20, 0x61, 0x6e	# 0007c0
	.byte	0x20, 0x65, 0x78, 0x65	# 0007c4
	.byte	0x63, 0x75, 0x74, 0x61	# 0007c8
	.byte	0x62, 0x6c, 0x65, 0x20	# 0007cc
	.byte	0x6f, 0x72, 0x20, 0x73	# 0007d0
	.byte	0x79, 0x73, 0x74, 0x65	# 0007d4
	.byte	0x6d, 0x20, 0x66, 0x69	# 0007d8
	.byte	0x6c, 0x65, 0x2c, 0x20	# 0007dc
	.byte	0x61, 0x20, 0x64, 0x69	# 0007e0
	.byte	0x72, 0x65, 0x63, 0x74	# 0007e4
	.byte	0x6f, 0x72, 0x79, 0x20	# 0007e8
	.byte	0x6e, 0x61, 0x6d, 0x65	# 0007ec
	.byte	0x2c, 0x0a, 0x00      	# 0007f0

# 7f3:	"or one of the possible firmware program names:\n\n"
l7f3:
	.byte	                   0x6f	# 0007f0
	.byte	0x72, 0x20, 0x6f, 0x6e	# 0007f4
	.byte	0x65, 0x20, 0x6f, 0x66	# 0007f8
	.byte	0x20, 0x74, 0x68, 0x65	# 0007fc
	.byte	0x20, 0x70, 0x6f, 0x73	# 000800
	.byte	0x73, 0x69, 0x62, 0x6c	# 000804
	.byte	0x65, 0x20, 0x66, 0x69	# 000808
	.byte	0x72, 0x6d, 0x77, 0x61	# 00080c
	.byte	0x72, 0x65, 0x20, 0x70	# 000810
	.byte	0x72, 0x6f, 0x67, 0x72	# 000814
	.byte	0x61, 0x6d, 0x20, 0x6e	# 000818
	.byte	0x61, 0x6d, 0x65, 0x73	# 00081c
	.byte	0x3a, 0x0a, 0x0a, 0x00	# 000820

# 824:	"baud    edt    newkey    passwd    sysdump    version    q(uit)\n\n"
l824:
	.byte	0x62, 0x61, 0x75, 0x64	# 000824
	.byte	0x20, 0x20, 0x20, 0x20	# 000828
	.byte	0x65, 0x64, 0x74, 0x20	# 00082c
	.byte	0x20, 0x20, 0x20, 0x6e	# 000830
	.byte	0x65, 0x77, 0x6b, 0x65	# 000834
	.byte	0x79, 0x20, 0x20, 0x20	# 000838
	.byte	0x20, 0x70, 0x61, 0x73	# 00083c
	.byte	0x73, 0x77, 0x64, 0x20	# 000840
	.byte	0x20, 0x20, 0x20, 0x73	# 000844
	.byte	0x79, 0x73, 0x64, 0x75	# 000848
	.byte	0x6d, 0x70, 0x20, 0x20	# 00084c
	.byte	0x20, 0x20, 0x76, 0x65	# 000850
	.byte	0x72, 0x73, 0x69, 0x6f	# 000854
	.byte	0x6e, 0x20, 0x20, 0x20	# 000858
	.byte	0x20, 0x71, 0x28, 0x75	# 00085c
	.byte	0x69, 0x74, 0x29, 0x0a	# 000860
	.byte	0x0a, 0x00            	# 000864

# 866:	"*VOID*"
l866:
	.byte	             0x2a, 0x56	# 000864
	.byte	0x4f, 0x49, 0x44, 0x2a	# 000868
	.byte	0x00                  	# 00086c

# 86d:	"\tPossible load devices are:\n\n"
l86d:
	.byte	       0x09, 0x50, 0x6f	# 00086c
	.byte	0x73, 0x73, 0x69, 0x62	# 000870
	.byte	0x6c, 0x65, 0x20, 0x6c	# 000874
	.byte	0x6f, 0x61, 0x64, 0x20	# 000878
	.byte	0x64, 0x65, 0x76, 0x69	# 00087c
	.byte	0x63, 0x65, 0x73, 0x20	# 000880
	.byte	0x61, 0x72, 0x65, 0x3a	# 000884
	.byte	0x0a, 0x0a, 0x00      	# 000888

# 88b:	"Option Number    Slot     Name\n"
l88b:
	.byte	                   0x4f	# 000888
	.byte	0x70, 0x74, 0x69, 0x6f	# 00088c
	.byte	0x6e, 0x20, 0x4e, 0x75	# 000890
	.byte	0x6d, 0x62, 0x65, 0x72	# 000894
	.byte	0x20, 0x20, 0x20, 0x20	# 000898
	.byte	0x53, 0x6c, 0x6f, 0x74	# 00089c
	.byte	0x20, 0x20, 0x20, 0x20	# 0008a0
	.byte	0x20, 0x4e, 0x61, 0x6d	# 0008a4
	.byte	0x65, 0x0a, 0x00      	# 0008a8

# 8ab:	"---------------------------------------\n"
l8ab:
	.byte	                   0x2d	# 0008a8
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0008ac
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0008b0
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0008b4
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0008b8
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0008bc
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0008c0
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0008c4
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0008c8
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0008cc
	.byte	0x2d, 0x2d, 0x0a, 0x00	# 0008d0

# 8d4:	"      %2d         %2d"
l8d4:
	.byte	0x20, 0x20, 0x20, 0x20	# 0008d4
	.byte	0x20, 0x20, 0x25, 0x32	# 0008d8
	.byte	0x64, 0x20, 0x20, 0x20	# 0008dc
	.byte	0x20, 0x20, 0x20, 0x20	# 0008e0
	.byte	0x20, 0x20, 0x25, 0x32	# 0008e4
	.byte	0x64, 0x00            	# 0008e8

# 8ea:	"*VOID*"
l8ea:
	.byte	             0x2a, 0x56	# 0008e8
	.byte	0x4f, 0x49, 0x44, 0x2a	# 0008ec
	.byte	0x00                  	# 0008f0

# 8f1:	"     %10s\n"
l8f1:
	.byte	       0x20, 0x20, 0x20	# 0008f0
	.byte	0x20, 0x20, 0x25, 0x31	# 0008f4
	.byte	0x30, 0x73, 0x00      	# 0008f8

# 8fb:	"\n"
l8fb:

	.byte	                   0x0a	# 0008f8
	.byte	0x00                  	# 0008fc

# 8fd:	"\nEnter Load Device Option Number "
l8fd:
	.byte	       0x0a, 0x45, 0x6e	# 0008fc
	.byte	0x74, 0x65, 0x72, 0x20	# 000900
	.byte	0x4c, 0x6f, 0x61, 0x64	# 000904
	.byte	0x20, 0x44, 0x65, 0x76	# 000908
	.byte	0x69, 0x63, 0x65, 0x20	# 00090c
	.byte	0x4f, 0x70, 0x74, 0x69	# 000910
	.byte	0x6f, 0x6e, 0x20, 0x4e	# 000914
	.byte	0x75, 0x6d, 0x62, 0x65	# 000918
	.byte	0x72, 0x20, 0x00      	# 00091c

# 91f:	"[%d"
l91f:
	.byte	                   0x5b	# 00091c
	.byte	0x25, 0x64, 0x00      	# 000920

# 923:	"*VOID*"
l923:
	.byte	                   0x2a	# 000920
	.byte	0x56, 0x4f, 0x49, 0x44	# 000924
	.byte	0x2a, 0x00            	# 000928

# 92a:	" (%s)"
l92a:
	.byte	             0x20, 0x28	# 000928
	.byte	0x25, 0x73, 0x29, 0x00	# 00092c

# 930:	"]: "
l930:
	.byte	0x5d, 0x3a, 0x20, 0x00	# 000930

# 934:    "\n"
l934:
	.byte	0x0a, 0x00            	# 000934

# 936:	"\n%s is not a valid option number.\n"
l936:
	.byte	             0x0a, 0x25	# 000934
	.byte	0x73, 0x20, 0x69, 0x73	# 000938
	.byte	0x20, 0x6e, 0x6f, 0x74	# 00093c
	.byte	0x20, 0x61, 0x20, 0x76	# 000940
	.byte	0x61, 0x6c, 0x69, 0x64	# 000944
	.byte	0x20, 0x6f, 0x70, 0x74	# 000948
	.byte	0x69, 0x6f, 0x6e, 0x20	# 00094c
	.byte	0x6e, 0x75, 0x6d, 0x62	# 000950
	.byte	0x65, 0x72, 0x2e, 0x0a	# 000954
	.byte	0x00                  	# 000958

# 959:	"Possible subdevices are:\n\n"
l959:
	.byte	       0x50, 0x6f, 0x73	# 000958
	.byte	0x73, 0x69, 0x62, 0x6c	# 00095c
	.byte	0x65, 0x20, 0x73, 0x75	# 000960
	.byte	0x62, 0x64, 0x65, 0x76	# 000964
	.byte	0x69, 0x63, 0x65, 0x73	# 000968
	.byte	0x20, 0x61, 0x72, 0x65	# 00096c
	.byte	0x3a, 0x0a, 0x0a, 0x00	# 000970

# 974:	"Option Number   Subdevice    Name\n"
l974:
	.byte	0x4f, 0x70, 0x74, 0x69	# 000974
	.byte	0x6f, 0x6e, 0x20, 0x4e	# 000978
	.byte	0x75, 0x6d, 0x62, 0x65	# 00097c
	.byte	0x72, 0x20, 0x20, 0x20	# 000980
	.byte	0x53, 0x75, 0x62, 0x64	# 000984
	.byte	0x65, 0x76, 0x69, 0x63	# 000988
	.byte	0x65, 0x20, 0x20, 0x20	# 00098c
	.byte	0x20, 0x4e, 0x61, 0x6d	# 000990
	.byte	0x65, 0x0a, 0x00      	# 000994

# 997:	"--------------------------------------------\n"
l997:
	.byte	                   0x2d	# 000994
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 000998
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 00099c
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0009a0
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0009a4
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0009a8
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0009ac
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0009b0
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0009b4
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0009b8
	.byte	0x2d, 0x2d, 0x2d, 0x2d	# 0009bc
	.byte	0x2d, 0x2d, 0x2d, 0x0a	# 0009c0
	.byte	0x00                  	# 0009c4

l9c5: # "      %2d         %2d"
	.byte	0x20, 0x20, 0x20
	.byte	0x20, 0x20, 0x20, 0x25, 0x32, 0x64, 0x20, 0x20	
	.byte	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x25, 0x32, 0x64, 0x00                      

l9dc: # "*VOID*"
	.byte	0x2a, 0x56, 0x4f, 0x49	# 0009dc
	.byte	0x44, 0x2a, 0x00

l9e3: # "         %10s"
	.byte	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x25, 0x31, 0x30, 0x73	# 0009e3
	.byte	0x00

l9f1: # "\n"
	.byte	0x0a, 0x00

l9f3: # "Enter Subdevice Option Number "
	.byte	0x0a, 0x45, 0x6e, 0x74, 0x65, 0x72, 0x20, 0x53
	.byte	0x75, 0x62, 0x64, 0x65, 0x76
	.byte	0x69, 0x63, 0x65, 0x20, 0x4f, 0x70, 0x74, 0x69
	.byte	0x6f, 0x6e, 0x20, 0x4e, 0x75, 0x6d, 0x62, 0x65
	.byte	0x72, 0x20, 0x00

la13: # "[%d"
	.byte	0x5b, 0x25, 0x64, 0x00

la17: # "*VOID*"
	.byte	0x2a, 0x56, 0x4f, 0x49, 0x44, 0x2a, 0x00

la1e: # "(%s)"
	.byte	0x28, 0x25
	.byte	0x73, 0x29, 0x00

la23: # "]: "
	.byte	0x5d, 0x3a, 0x20, 0x00

la27: # "\n"
	.byte	0x0a, 0x00

la29: # "\n%s is not a valid option number\n"
	.byte	0x0a, 0x25, 0x73, 0x20, 0x69, 0x73, 0x20
	.byte	0x6e, 0x6f, 0x74, 0x20, 0x61, 0x20, 0x76, 0x61
	.byte	0x6c, 0x69, 0x64, 0x20, 0x6f, 0x70, 0x74, 0x69
	.byte	0x6f, 0x6e, 0x20, 0x6e, 0x75, 0x6d, 0x62, 0x65
	.byte	0x72, 0x2e, 0x0a, 0x00

la4c: # "\nSORRY!\n"
	.byte	0x0a, 0x53, 0x4f, 0x52
	.byte	0x52, 0x59, 0x21, 0x0a, 0x00

# 0a55:
	.byte	0x00, 0x00, 0x00

la58:	.byte	0x00, 0x00

la5a:	.byte	0x00

la5b:	.byte	0x00

la5c:	.byte	0x00, 0x00, 0x00, 0x00

	.word	0x00320100, 0x00000000, 0x004b0200, 0x80000000	# 000a60
	.word	0x006e0311, 0x00000000, 0x00860422, 0x00000000	# 000a70
	.word	0x00960533, 0x80000000, 0x00c80633, 0x00000000	# 000a80
	.word	0x012c0744, 0x00000000, 0x02580855, 0x00000000	# 000a90
	.word	0x04b00966, 0x00000000, 0x07080aaa, 0x80000000	# 000aa0
	.word	0x09600b88, 0x00000000, 0x12c00c99, 0x00000000	# 000ab0
	.word	0x25800dbb, 0x00000000, 0x4b000ecc, 0x80000000	# 000ac0
	.word	0x96000fcc, 0x00000000                        	# 000ad0

lad8: # "Unsupported Baud Rate: %d\n"
	.byte	0x55, 0x6e, 0x73, 0x75, 0x70, 0x70, 0x6f, 0x72
	.byte	0x74, 0x65, 0x64, 0x20, 0x42, 0x61, 0x75, 0x64
	.byte	0x20, 0x52, 0x61, 0x74, 0x65, 0x3a, 0x20, 0x25
	.byte	0x64, 0x0a, 0x00

laf3: # "Enter new rate [%d]: "
	.byte	0x45, 0x6e, 0x74, 0x65, 0x72
	.byte	0x20, 0x6e, 0x65, 0x77, 0x20, 0x72, 0x61, 0x74
	.byte	0x65, 0x20, 0x5b, 0x25, 0x64, 0x5d, 0x3a, 0x20
	.byte	0x00

lb09: # "%d"
	.byte	0x25, 0x64, 0x00

lb0c: # "Change baud rate to %d\n"
	.byte	0x43, 0x68, 0x61, 0x6e
	.byte	0x67, 0x65, 0x20, 0x62, 0x61, 0x75, 0x64, 0x20
	.byte	0x72, 0x61, 0x74, 0x65, 0x20, 0x74, 0x6f, 0x20	
	.byte	0x25, 0x64, 0x0a, 0x00

lb24: # " \b"
	.byte	0x20, 0x08, 0x00

lb27: # "\nmax input of %d characters, re-enter entire line\n"
	.byte	0x0a, 0x6d, 0x61, 0x78, 0x20, 0x69, 0x6e, 0x70, 0x75	# 000b20
	.byte	0x74, 0x20, 0x6f, 0x66, 0x20, 0x25, 0x64, 0x20
	.byte	0x63, 0x68, 0x61, 0x72, 0x61, 0x63, 0x74, 0x65
	.byte	0x72, 0x73, 0x2c, 0x20, 0x72, 0x65, 0x2d, 0x65
	.byte	0x6e, 0x74, 0x65, 0x72, 0x20, 0x65, 0x6e, 0x74
	.byte	0x69, 0x72, 0x65, 0x20, 0x6c, 0x69, 0x6e, 0x65
	.byte	0x0a, 0x00

lb5a:
	.byte	0x00, 0x00

# cac: binary to hex conversion
lb5c: # "0123456789abcdef"
	.byte	0x30, 0x31, 0x32, 0x33
	.byte	0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x00

lb6d:
	.byte	0x00, 0x00, 0x00

lb70: # "(null pointer)"
	.byte	0x28, 0x6e, 0x75, 0x6c, 0x6c, 0x20, 0x70, 0x6f, 0x69, 0x6e, 0x74, 0x65, 0x72, 0x29, 0x00

lb7f:
	.byte	0x00

lb80: # "\n\nCurrent System Configuration\n\n"
	.byte	0x0a, 0x0a, 0x43, 0x75	# 000b80
	.byte	0x72, 0x72, 0x65, 0x6e	# 000b84
	.byte	0x74, 0x20, 0x53, 0x79	# 000b88
	.byte	0x73, 0x74, 0x65, 0x6d	# 000b8c
	.byte	0x20, 0x43, 0x6f, 0x6e	# 000b90
	.byte	0x66, 0x69, 0x67, 0x75	# 000b94
	.byte	0x72, 0x61, 0x74, 0x69	# 000b98
	.byte	0x6f, 0x6e, 0x0a, 0x0a	# 000b9c
	.byte	0x00

lba1: # "System Board memory size: "
	.byte	0x53, 0x79, 0x73
	.byte	0x74, 0x65, 0x6d, 0x20	# 000ba4
	.byte	0x42, 0x6f, 0x61, 0x72	# 000ba8
	.byte	0x64, 0x20, 0x6d, 0x65	# 000bac
	.byte	0x6d, 0x6f, 0x72, 0x79	# 000bb0
	.byte	0x20, 0x73, 0x69, 0x7a	# 000bb4
	.byte	0x65, 0x3a, 0x20, 0x00	# 000bb8

lbbc: # "%d megabyte(s)"
	.byte	0x25, 0x64, 0x20, 0x6d	# 000bbc
	.byte	0x65, 0x67, 0x61, 0x62	# 000bc0
	.byte	0x79, 0x74, 0x65, 0x28	# 000bc4
	.byte	0x73, 0x29, 0x00

lbcb: # "%d kilobytes"
	.byte	0x25
	.byte	0x64, 0x20, 0x6b, 0x69	# 000bcc
	.byte	0x6c, 0x6f, 0x62, 0x79	# 000bd0
	.byte	0x74, 0x65, 0x73, 0x00	# 000bd4

lbd8: # "\n\n%02d - device name = %-9s, "
	.byte	0x0a, 0x0a, 0x25, 0x30	# 000bd8
	.byte	0x32, 0x64, 0x20, 0x2d	# 000bdc
	.byte	0x20, 0x64, 0x65, 0x76	# 000be0
	.byte	0x69, 0x63, 0x65, 0x20	# 000be4
	.byte	0x6e, 0x61, 0x6d, 0x65	# 000be8
	.byte	0x20, 0x3d, 0x20, 0x25	# 000bec
	.byte	0x2d, 0x39, 0x73, 0x2c	# 000bf0
	.byte	0x20, 0x00

lbf6: # "occurrence = %2d, slot = %02d, ID code = 0x%02x\n"
	.byte	0x6f, 0x63
	.byte	0x63, 0x75, 0x72, 0x72	# 000bf8
	.byte	0x65, 0x6e, 0x63, 0x65	# 000bfc
	.byte	0x20, 0x3d, 0x20, 0x25	# 000c00
	.byte	0x32, 0x64, 0x2c, 0x20	# 000c04
	.byte	0x73, 0x6c, 0x6f, 0x74	# 000c08
	.byte	0x20, 0x3d, 0x20, 0x25	# 000c0c
	.byte	0x30, 0x32, 0x64, 0x2c	# 000c10
	.byte	0x20, 0x49, 0x44, 0x20	# 000c14
	.byte	0x63, 0x6f, 0x64, 0x65	# 000c18
	.byte	0x20, 0x3d, 0x20, 0x30	# 000c1c
	.byte	0x78, 0x25, 0x30, 0x32	# 000c20
	.byte	0x78, 0x0a, 0x00

lc27: # "     boot device = %c, board width = %s, word width = %d byte(s),\n"
	.byte	0x20
	.byte	0x20, 0x20, 0x20, 0x20	# 000c28
	.byte	0x62, 0x6f, 0x6f, 0x74	# 000c2c
	.byte	0x20, 0x64, 0x65, 0x76	# 000c30
	.byte	0x69, 0x63, 0x65, 0x20	# 000c34
	.byte	0x3d, 0x20, 0x25, 0x63	# 000c38
	.byte	0x2c, 0x20, 0x62, 0x6f	# 000c3c
	.byte	0x61, 0x72, 0x64, 0x20	# 000c40
	.byte	0x77, 0x69, 0x64, 0x74	# 000c44
	.byte	0x68, 0x20, 0x3d, 0x20	# 000c48
	.byte	0x25, 0x73, 0x2c, 0x20	# 000c4c
	.byte	0x77, 0x6f, 0x72, 0x64	# 000c50
	.byte	0x20, 0x77, 0x69, 0x64	# 000c54
	.byte	0x74, 0x68, 0x20, 0x3d	# 000c58
	.byte	0x20, 0x25, 0x64, 0x20	# 000c5c
	.byte	0x62, 0x79, 0x74, 0x65	# 000c60
	.byte	0x28, 0x73, 0x29, 0x2c	# 000c64
	.byte	0x0a, 0x00

lc6a: # "double"
	.byte	0x64, 0x6f
	.byte	0x75, 0x62, 0x6c, 0x65	# 000c6c
	.byte	0x00

lc71: # "single"
	.byte	0x73, 0x69, 0x6e
	.byte	0x67, 0x6c, 0x65, 0x00	# 000c74

lc78: # "     req Q size = 0x%02x, comp Q size = 0x%02x, "
	.byte	0x20, 0x20, 0x20, 0x20	# 000c78
	.byte	0x20, 0x72, 0x65, 0x71	# 000c7c
	.byte	0x20, 0x51, 0x20, 0x73	# 000c80
	.byte	0x69, 0x7a, 0x65, 0x20	# 000c84
	.byte	0x3d, 0x20, 0x30, 0x78	# 000c88
	.byte	0x25, 0x30, 0x32, 0x78	# 000c8c
	.byte	0x2c, 0x20, 0x63, 0x6f	# 000c90
	.byte	0x6d, 0x70, 0x20, 0x51	# 000c94
	.byte	0x20, 0x73, 0x69, 0x7a	# 000c98
	.byte	0x65, 0x20, 0x3d, 0x20	# 000c9c
	.byte	0x30, 0x78, 0x25, 0x30	# 000ca0
	.byte	0x32, 0x78, 0x2c, 0x20	# 000ca4
	.byte	0x00

lca9: # "console ability = %c"
	.byte	0x63, 0x6f, 0x6e
	.byte	0x73, 0x6f, 0x6c, 0x65	# 000cac
	.byte	0x20, 0x61, 0x62, 0x69	# 000cb0
	.byte	0x6c, 0x69, 0x74, 0x79	# 000cb4
	.byte	0x20, 0x3d, 0x20, 0x25	# 000cb8
	.byte	0x63, 0x00

lcbe: # ", pump file = %c"
	.byte	0x2c, 0x20
	.byte	0x70, 0x75, 0x6d, 0x70	# 000cc0
	.byte	0x20, 0x66, 0x69, 0x6c	# 000cc4
	.byte	0x65, 0x20, 0x3d, 0x20	# 000cc8
	.byte	0x25, 0x63, 0x00

lccf: # "               "
	.byte	0x20
	.byte	0x20, 0x20, 0x20, 0x20	# 000cd0
	.byte	0x20, 0x20, 0x20, 0x20	# 000cd4
	.byte	0x20, 0x20, 0x20, 0x20	# 000cd8
	.byte	0x20, 0x20, 0x00

lcdf: # "\n     subdevice(s)"
	.byte	0x0a
	.byte	0x20, 0x20, 0x20, 0x20	# 000ce0
	.byte	0x20, 0x73, 0x75, 0x62	# 000ce4
	.byte	0x64, 0x65, 0x76, 0x69	# 000ce8
	.byte	0x63, 0x65, 0x28, 0x73	# 000cec
	.byte	0x29, 0x00

lcf2: # "%s#%02d = %-9s, ID code = 0x%02x"
	.byte	0x25, 0x73
	.byte	0x23, 0x25, 0x30, 0x32	# 000cf4
	.byte	0x64, 0x20, 0x3d, 0x20	# 000cf8
	.byte	0x25, 0x2d, 0x39, 0x73	# 000cfc
	.byte	0x2c, 0x20, 0x49, 0x44	# 000d00
	.byte	0x20, 0x63, 0x6f, 0x64	# 000d04
	.byte	0x65, 0x20, 0x3d, 0x20	# 000d08
	.byte	0x30, 0x78, 0x25, 0x30	# 000d0c
	.byte	0x32, 0x78, 0x00

ld13: # "\n     "
	.byte	0x0a
	.byte	0x20, 0x20, 0x20, 0x20	# 000d14
	.byte	0x20, 0x00

ld1a: # ", "
	.byte	0x2c, 0x20	# 000d18
	.byte	0x00

ld1d: # "\n\nPress any key to continue"
	.byte	0x0a, 0x0a, 0x50
	.byte	0x72, 0x65, 0x73, 0x73	# 000d20
	.byte	0x20, 0x61, 0x6e, 0x79	# 000d24
	.byte	0x20, 0x6b, 0x65, 0x79	# 000d28
	.byte	0x20, 0x74, 0x6f, 0x20	# 000d2c
	.byte	0x63, 0x6f, 0x6e, 0x74	# 000d30
	.byte	0x69, 0x6e, 0x75, 0x65	# 000d34
	.byte	0x0a, 0x00

ld3a: # "\nDONE\n"
	.byte	0x0a, 0x44
	.byte	0x4f, 0x4e, 0x45, 0x0a	# 000d3c
	.byte	0x0a, 0x00

ld42:
	.byte	0x00, 0x00

ld44: # "PERIPHERAL I/O %s ERROR AT BLOCK %d, SUBDEVICE %d, SLOT %d\n"
	.byte	0x50, 0x45, 0x52, 0x49	# 000d44
	.byte	0x50, 0x48, 0x45, 0x52	# 000d48
	.byte	0x41, 0x4c, 0x20, 0x49	# 000d4c
	.byte	0x2f, 0x4f, 0x20, 0x25	# 000d50
	.byte	0x73, 0x20, 0x45, 0x52	# 000d54
	.byte	0x52, 0x4f, 0x52, 0x20	# 000d58
	.byte	0x41, 0x54, 0x20, 0x42	# 000d5c
	.byte	0x4c, 0x4f, 0x43, 0x4b	# 000d60
	.byte	0x20, 0x25, 0x64, 0x2c	# 000d64
	.byte	0x20, 0x53, 0x55, 0x42	# 000d68
	.byte	0x44, 0x45, 0x56, 0x49	# 000d6c
	.byte	0x43, 0x45, 0x20, 0x25	# 000d70
	.byte	0x64, 0x2c, 0x20, 0x53	# 000d74
	.byte	0x4c, 0x4f, 0x54, 0x20	# 000d78
	.byte	0x25, 0x64, 0x0a, 0x00	# 000d7c

ld80: # "READ"
	.byte	0x52, 0x45, 0x41, 0x44	# 000d80
	.byte	0x00

ld85: # "WRITE"
	.byte	0x57, 0x52, 0x49
	.byte	0x54, 0x45, 0x00

ld8b:
	.byte	0x00

ld8c: # "\nFW ERROR 1-%s\n"
	.byte	0x0a, 0x46, 0x57, 0x20	# 000d8c
	.byte	0x45, 0x52, 0x52, 0x4f	# 000d90
	.byte	0x52, 0x20, 0x31, 0x2d	# 000d94
	.byte	0x25, 0x73, 0x0a, 0x00	# 000d98

ld9c: # "               EXECUTION HALTED\n"
	.byte	0x20, 0x20, 0x20, 0x20	# 000d9c
	.byte	0x20, 0x20, 0x20, 0x20	# 000da0
	.byte	0x20, 0x20, 0x20, 0x20	# 000da4
	.byte	0x20, 0x20, 0x20, 0x45	# 000da8
	.byte	0x58, 0x45, 0x43, 0x55	# 000dac
	.byte	0x54, 0x49, 0x4f, 0x4e	# 000db0
	.byte	0x20, 0x48, 0x41, 0x4c	# 000db4
	.byte	0x54, 0x45, 0x44, 0x0a	# 000db8
	.byte	0x00

ldbd:
	.byte	0x00, 0x00, 0x00	# 000dbd

ldc0: # "01: NVRAM SANITY FAILURE"
	.byte	0x30, 0x31, 0x3a, 0x20	# 000dc0
	.byte	0x4e, 0x56, 0x52, 0x41	# 000dc4
	.byte	0x4d, 0x20, 0x53, 0x41	# 000dc8
	.byte	0x4e, 0x49, 0x54, 0x59	# 000dcc
	.byte	0x20, 0x46, 0x41, 0x49	# 000dd0
	.byte	0x4c, 0x55, 0x52, 0x45	# 000dd4
	.byte	0x00

ldd9: # "               DEFAULT VALUES ASSUMED\n               IF REPEATED, CHECK THE BATTERY\n"
	.byte	0x20, 0x20, 0x20
	.byte	0x20, 0x20, 0x20, 0x20	# 000ddc
	.byte	0x20, 0x20, 0x20, 0x20	# 000de0
	.byte	0x20, 0x20, 0x20, 0x20	# 000de4
	.byte	0x44, 0x45, 0x46, 0x41	# 000de8
	.byte	0x55, 0x4c, 0x54, 0x20	# 000dec
	.byte	0x56, 0x41, 0x4c, 0x55	# 000df0
	.byte	0x45, 0x53, 0x20, 0x41	# 000df4
	.byte	0x53, 0x53, 0x55, 0x4d	# 000df8
	.byte	0x45, 0x44, 0x0a, 0x20	# 000dfc
	.byte	0x20, 0x20, 0x20, 0x20	# 000e00
	.byte	0x20, 0x20, 0x20, 0x20	# 000e04
	.byte	0x20, 0x20, 0x20, 0x20	# 000e08
	.byte	0x20, 0x20, 0x49, 0x46	# 000e0c
	.byte	0x20, 0x52, 0x45, 0x50	# 000e10
	.byte	0x45, 0x41, 0x54, 0x45	# 000e14
	.byte	0x44, 0x2c, 0x20, 0x43	# 000e18
	.byte	0x48, 0x45, 0x43, 0x4b	# 000e1c
	.byte	0x20, 0x54, 0x48, 0x45	# 000e20
	.byte	0x20, 0x42, 0x41, 0x54	# 000e24
	.byte	0x54, 0x45, 0x52, 0x59	# 000e28
	.byte	0x0a, 0x00

le2e: # "\nFW WARNING: NVRAM DEFAULT VALUES ASSUMED\n\n"
	.byte	0x0a, 0x46
	.byte	0x57, 0x20, 0x57, 0x41	# 000e30
	.byte	0x52, 0x4e, 0x49, 0x4e	# 000e34
	.byte	0x47, 0x3a, 0x20, 0x4e	# 000e38
	.byte	0x56, 0x52, 0x41, 0x4d	# 000e3c
	.byte	0x20, 0x44, 0x45, 0x46	# 000e40
	.byte	0x41, 0x55, 0x4c, 0x54	# 000e44
	.byte	0x20, 0x56, 0x41, 0x4c	# 000e48
	.byte	0x55, 0x45, 0x53, 0x20	# 000e4c
	.byte	0x41, 0x53, 0x53, 0x55	# 000e50
	.byte	0x4d, 0x45, 0x44, 0x0a	# 000e54
	.byte	0x0a, 0x00

le5a: # "02: DISK SANITY FAILURE"
	.byte	0x30, 0x32
	.byte	0x3a, 0x20, 0x44, 0x49	# 000e5c
	.byte	0x53, 0x4b, 0x20, 0x53	# 000e60
	.byte	0x41, 0x4e, 0x49, 0x54	# 000e64
	.byte	0x59, 0x20, 0x46, 0x41	# 000e68
	.byte	0x49, 0x4c, 0x55, 0x52	# 000e6c
	.byte	0x45, 0x00

le72: # "05: SELF-CONFIGURATION FAILURE"
	.byte	0x30, 0x35
	.byte	0x3a, 0x20, 0x53, 0x45	# 000e74
	.byte	0x4c, 0x46, 0x2d, 0x43	# 000e78
	.byte	0x4f, 0x4e, 0x46, 0x49	# 000e7c
	.byte	0x47, 0x55, 0x52, 0x41	# 000e80
	.byte	0x54, 0x49, 0x4f, 0x4e	# 000e84
	.byte	0x20, 0x46, 0x41, 0x49	# 000e88
	.byte	0x4c, 0x55, 0x52, 0x45	# 000e8c
	.byte	0x00

le91: # "06: BOOT FAILURE"
	.byte	0x30, 0x36, 0x3a
	.byte	0x20, 0x42, 0x4f, 0x4f	# 000e94
	.byte	0x54, 0x20, 0x46, 0x41	# 000e98
	.byte	0x49, 0x4c, 0x55, 0x52	# 000e9c
	.byte	0x45, 0x00

lea2: # "07: FLOPPY KEY CREATE FAILURE"
	.byte	0x30, 0x37
	.byte	0x3a, 0x20, 0x46, 0x4c	# 000ea4
	.byte	0x4f, 0x50, 0x50, 0x59	# 000ea8
	.byte	0x20, 0x4b, 0x45, 0x59	# 000eac
	.byte	0x20, 0x43, 0x52, 0x45	# 000eb0
	.byte	0x41, 0x54, 0x45, 0x20	# 000eb4
	.byte	0x46, 0x41, 0x49, 0x4c	# 000eb8
	.byte	0x55, 0x52, 0x45, 0x00	# 000ebc

lec0: # "08: MEMORY TEST FAILURE"
	.byte	0x30, 0x38, 0x3a, 0x20	# 000ec0
	.byte	0x4d, 0x45, 0x4d, 0x4f	# 000ec4
	.byte	0x52, 0x59, 0x20, 0x54	# 000ec8
	.byte	0x45, 0x53, 0x54, 0x20	# 000ecc
	.byte	0x46, 0x41, 0x49, 0x4c	# 000ed0
	.byte	0x55, 0x52, 0x45, 0x00	# 000ed4

led8: # "09: DISK FORMAT NOT COMPATIBLE WITH SYSTEM"
	.byte	0x30, 0x39, 0x3a, 0x20	# 000ed8
	.byte	0x44, 0x49, 0x53, 0x4b	# 000edc
	.byte	0x20, 0x46, 0x4f, 0x52	# 000ee0
	.byte	0x4d, 0x41, 0x54, 0x20	# 000ee4
	.byte	0x4e, 0x4f, 0x54, 0x20	# 000ee8
	.byte	0x43, 0x4f, 0x4d, 0x50	# 000eec
	.byte	0x41, 0x54, 0x49, 0x42	# 000ef0
	.byte	0x4c, 0x45, 0x20, 0x57	# 000ef4
	.byte	0x49, 0x54, 0x48, 0x20	# 000ef8
	.byte	0x53, 0x59, 0x53, 0x54	# 000efc
	.byte	0x45, 0x4d, 0x00

lf03: # "%s"
	.byte	0x25
	.byte	0x73, 0x00

lf06: # "\n\nSELF-CHECK\n"
	.byte	0x0a, 0x0a
	.byte	0x53, 0x45, 0x4c, 0x46	# 000f08
	.byte	0x2d, 0x43, 0x48, 0x45	# 000f0c
	.byte	0x43, 0x4b, 0x0a, 0x00	# 000f10

lf14: # "\nNONE\n\n"
	.byte	0x0a, 0x4e, 0x4f, 0x4e	# 000f14
	.byte	0x45, 0x0a, 0x0a, 0x00	# 000f18

lf1c: # "\nEXCEPTION, PC = 0x%08x, PSW = 0x%08x, CSR = 0x%04x\n\n"
	.byte	0x0a, 0x45, 0x58, 0x43	# 000f1c
	.byte	0x45, 0x50, 0x54, 0x49	# 000f20
	.byte	0x4f, 0x4e, 0x2c, 0x20	# 000f24
	.byte	0x50, 0x43, 0x20, 0x3d	# 000f28
	.byte	0x20, 0x30, 0x78, 0x25	# 000f2c
	.byte	0x30, 0x38, 0x78, 0x2c	# 000f30
	.byte	0x20, 0x50, 0x53, 0x57	# 000f34
	.byte	0x20, 0x3d, 0x20, 0x30	# 000f38
	.byte	0x78, 0x25, 0x30, 0x38	# 000f3c
	.byte	0x78, 0x2c, 0x20, 0x43	# 000f40
	.byte	0x53, 0x52, 0x20, 0x3d	# 000f44
	.byte	0x20, 0x30, 0x78, 0x25	# 000f48
	.byte	0x30, 0x34, 0x78, 0x0a	# 000f4c
	.byte	0x0a, 0x00

lf52: # "\nINTERRUPT, PC = 0x%08x, PSW = 0x%08x, CSR = 0x%04x, LVL = %d\n\n"
	.byte	0x0a, 0x49
	.byte	0x4e, 0x54, 0x45, 0x52	# 000f54
	.byte	0x52, 0x55, 0x50, 0x54	# 000f58
	.byte	0x2c, 0x20, 0x50, 0x43	# 000f5c
	.byte	0x20, 0x3d, 0x20, 0x30	# 000f60
	.byte	0x78, 0x25, 0x30, 0x38	# 000f64
	.byte	0x78, 0x2c, 0x20, 0x50	# 000f68
	.byte	0x53, 0x57, 0x20, 0x3d	# 000f6c
	.byte	0x20, 0x30, 0x78, 0x25	# 000f70
	.byte	0x30, 0x38, 0x78, 0x2c	# 000f74
	.byte	0x20, 0x43, 0x53, 0x52	# 000f78
	.byte	0x20, 0x3d, 0x20, 0x30	# 000f7c
	.byte	0x78, 0x25, 0x30, 0x34	# 000f80
	.byte	0x78, 0x2c, 0x20, 0x4c	# 000f84
	.byte	0x56, 0x4c, 0x20, 0x3d	# 000f88
	.byte	0x20, 0x25, 0x64, 0x0a	# 000f8c
	.byte	0x0a, 0x00

lf92: # "\nSANITY ON DISK %d, ERROR %d\n"
	.byte	0x0a, 0x53
	.byte	0x41, 0x4e, 0x49, 0x54	# 000f94
	.byte	0x59, 0x20, 0x4f, 0x4e	# 000f98
	.byte	0x20, 0x44, 0x49, 0x53	# 000f9c
	.byte	0x4b, 0x20, 0x25, 0x64	# 000fa0
	.byte	0x2c, 0x20, 0x45, 0x52	# 000fa4
	.byte	0x52, 0x4f, 0x52, 0x20	# 000fa8
	.byte	0x25, 0x64, 0x0a, 0x00	# 000fac

lfb0: # "COMMAND = 0x%02x, UNIT STATUS = 0x%02x, ERROR STATUS = 0x%02x, STATUS = 0x%02x"
	.byte	0x43, 0x4f, 0x4d, 0x4d	# 000fb0
	.byte	0x41, 0x4e, 0x44, 0x20	# 000fb4
	.byte	0x3d, 0x20, 0x30, 0x78	# 000fb8
	.byte	0x25, 0x30, 0x32, 0x78	# 000fbc
	.byte	0x2c, 0x20, 0x55, 0x4e	# 000fc0
	.byte	0x49, 0x54, 0x20, 0x53	# 000fc4
	.byte	0x54, 0x41, 0x54, 0x55	# 000fc8
	.byte	0x53, 0x20, 0x3d, 0x20	# 000fcc
	.byte	0x30, 0x78, 0x25, 0x30	# 000fd0
	.byte	0x32, 0x78, 0x2c, 0x20	# 000fd4
	.byte	0x45, 0x52, 0x52, 0x4f	# 000fd8
	.byte	0x52, 0x20, 0x53, 0x54	# 000fdc
	.byte	0x41, 0x54, 0x55, 0x53	# 000fe0
	.byte	0x20, 0x3d, 0x20, 0x30	# 000fe4
	.byte	0x78, 0x25, 0x30, 0x32	# 000fe8
	.byte	0x78, 0x2c, 0x20, 0x53	# 000fec
	.byte	0x54, 0x41, 0x54, 0x55	# 000ff0
	.byte	0x53, 0x20, 0x3d, 0x20	# 000ff4
	.byte	0x30, 0x78, 0x25, 0x30	# 000ff8
	.byte	0x32, 0x78, 0x00

lfff: # "\n\n"
	.byte	0x0a
	.byte	0x0a, 0x00

l1002: # "\n\nNONE\n\n"
	.byte	0x0a, 0x4e	# 001000
	.byte	0x4f, 0x4e, 0x45, 0x0a	# 001004
	.byte	0x0a, 0x00

l100a:
	.byte	0x00, 0x00

l100c: # "04: UNEXPECTED INTERRUPT\n"
	.byte	0x30, 0x34, 0x3a, 0x20	# 00100c
	.byte	0x55, 0x4e, 0x45, 0x58	# 001010
	.byte	0x50, 0x45, 0x43, 0x54	# 001014
	.byte	0x45, 0x44, 0x20, 0x49	# 001018
	.byte	0x4e, 0x54, 0x45, 0x52	# 00101c
	.byte	0x52, 0x55, 0x50, 0x54	# 001020
	.byte	0x0a, 0x00

l1026:
	.byte	0x00, 0x00

l1028: # "03: UNEXPECTED FAULT\n"
	.byte	0x30, 0x33, 0x3a, 0x20	# 001028
	.byte	0x55, 0x4e, 0x45, 0x58	# 00102c
	.byte	0x50, 0x45, 0x43, 0x54	# 001030
	.byte	0x45, 0x44, 0x20, 0x46	# 001034
	.byte	0x41, 0x55, 0x4c, 0x54	# 001038
	.byte	0x0a, 0x00

l103e:
	.byte	0x00, 0x00

l1040: # "mcp"
	.byte	0x6d, 0x63, 0x70, 0x00	# 001040

l1044: # "/filledt"
	.byte	0x2f, 0x66, 0x69, 0x6c	# 001044
	.byte	0x6c, 0x65, 0x64, 0x74	# 001048
	.byte	0x00

l104d: # "\nSYSTEM FAILURE: CONSULT YOUR SYSTEM ADMINISTRATION UTILITIES GUIDE\n\n"
	.byte	0x0a, 0x53, 0x59
	.byte	0x53, 0x54, 0x45, 0x4d	# 001050
	.byte	0x20, 0x46, 0x41, 0x49	# 001054
	.byte	0x4c, 0x55, 0x52, 0x45	# 001058
	.byte	0x3a, 0x20, 0x43, 0x4f	# 00105c
	.byte	0x4e, 0x53, 0x55, 0x4c	# 001060
	.byte	0x54, 0x20, 0x59, 0x4f	# 001064
	.byte	0x55, 0x52, 0x20, 0x53	# 001068
	.byte	0x59, 0x53, 0x54, 0x45	# 00106c
	.byte	0x4d, 0x20, 0x41, 0x44	# 001070
	.byte	0x4d, 0x49, 0x4e, 0x49	# 001074
	.byte	0x53, 0x54, 0x52, 0x41	# 001078
	.byte	0x54, 0x49, 0x4f, 0x4e	# 00107c
	.byte	0x20, 0x55, 0x54, 0x49	# 001080
	.byte	0x4c, 0x49, 0x54, 0x49	# 001084
	.byte	0x45, 0x53, 0x20, 0x47	# 001088
	.byte	0x55, 0x49, 0x44, 0x45	# 00108c
	.byte	0x0a, 0x0a, 0x00

l1093: # "\nFIRMWARE MODE\n\n"
	.byte	0x0a
	.byte	0x46, 0x49, 0x52, 0x4d	# 001094
	.byte	0x57, 0x41, 0x52, 0x45	# 001098
	.byte	0x20, 0x4d, 0x4f, 0x44	# 00109c
	.byte	0x45, 0x0a, 0x0a, 0x00	# 0010a0

l10a4: # "/filledt"
	.byte	0x2f, 0x66, 0x69, 0x6c	# 0010a4
	.byte	0x6c, 0x65, 0x64, 0x74	# 0010a8
	.byte	0x00

l10ad: # "/dgmon"
	.byte	0x2f, 0x64, 0x67
	.byte	0x6d, 0x6f, 0x6e, 0x00	# 0010b0

l10b4: # "/unix"
	.byte	0x2f, 0x75, 0x6e, 0x69	# 0010b4
	.byte	0x78, 0x00

l10ba:
	.byte	0x00, 0x00

l10bc: # "04: UNEXPECTED INTERRUPT"
	.byte	0x30, 0x34, 0x3a, 0x20	# 0010bc
	.byte	0x55, 0x4e, 0x45, 0x58	# 0010c0
	.byte	0x50, 0x45, 0x43, 0x54	# 0010c4
	.byte	0x45, 0x44, 0x20, 0x49	# 0010c8
	.byte	0x4e, 0x54, 0x45, 0x52	# 0010cc
	.byte	0x52, 0x55, 0x50, 0x54	# 0010d0
	.byte	0x00

l10d5: # "03: UNEXPECTED FAULT"
	.byte	0x30, 0x33, 0x3a
	.byte	0x20, 0x55, 0x4e, 0x45	# 0010d8
	.byte	0x58, 0x50, 0x45, 0x43	# 0010dc
	.byte	0x54, 0x45, 0x44, 0x20	# 0010e0
	.byte	0x46, 0x41, 0x55, 0x4c	# 0010e4
	.byte	0x54, 0x00

l10ea:
	.byte	0x00, 0x00

# Lookup table?
l10ec:
	.byte	0x18, 0xf2, 0x00

l10ef:
	.byte	0x03
	.byte	0x11, 0x0d, 0x00

l10f3:
	.byte	0x80

l10f4: # "id%d CRC error at disk address %08x (%d retries)\n"
	.byte	0x69, 0x64, 0x25, 0x64	# 0010f4
	.byte	0x20, 0x43, 0x52, 0x43	# 0010f8
	.byte	0x20, 0x65, 0x72, 0x72	# 0010fc
	.byte	0x6f, 0x72, 0x20, 0x61	# 001100
	.byte	0x74, 0x20, 0x64, 0x69	# 001104
	.byte	0x73, 0x6b, 0x20, 0x61	# 001108
	.byte	0x64, 0x64, 0x72, 0x65	# 00110c
	.byte	0x73, 0x73, 0x20, 0x25	# 001110
	.byte	0x30, 0x38, 0x78, 0x20	# 001114
	.byte	0x28, 0x25, 0x64, 0x20	# 001118
	.byte	0x72, 0x65, 0x74, 0x72	# 00111c
	.byte	0x69, 0x65, 0x73, 0x29	# 001120
	.byte	0x0a, 0x00

l1126:
	.byte	0x00, 0x00	# 001124

l1128: # "if CRC error at disk address %08x (%d retries)\n"
	.byte	0x69, 0x66, 0x20, 0x43	# 001128
	.byte	0x52, 0x43, 0x20, 0x65	# 00112c
	.byte	0x72, 0x72, 0x6f, 0x72	# 001130
	.byte	0x20, 0x61, 0x74, 0x20	# 001134
	.byte	0x64, 0x69, 0x73, 0x6b	# 001138
	.byte	0x20, 0x61, 0x64, 0x64	# 00113c
	.byte	0x72, 0x65, 0x73, 0x73	# 001140
	.byte	0x20, 0x25, 0x30, 0x38	# 001144
	.byte	0x78, 0x20, 0x28, 0x25	# 001148
	.byte	0x64, 0x20, 0x72, 0x65	# 00114c
	.byte	0x74, 0x72, 0x69, 0x65	# 001150
	.byte	0x73, 0x29, 0x0a, 0x00	# 001154

l1158: # "05/31/85"
	.byte	0x30, 0x35, 0x2f, 0x33, 0x31, 0x2f, 0x38, 0x35, 0x00

# 1161:
	.byte	0x00

# 1162:
	.byte	0x00

# 1163:
	.byte	0x00

l1164: # "PF3"
	.byte	0x50, 0x46, 0x33, 0x00

l1168: # "1.2.1"
	.byte	0x31, 0x2e, 0x32, 0x2e, 0x31, 0x00

# 116e:
	.byte	0x00, 0x00

l1170:
	.word	0x00202020, 0x20202020, 0x20202828, 0x28282820	# 001170
	.word	0x20202020, 0x20202020, 0x20202020, 0x20202020	# 001180
	.word	0x20481010, 0x10101010, 0x10101010, 0x10101010	# 001190
	.word	0x10848484, 0x84848484, 0x84848410, 0x10101010	# 0011a0
	.word	0x10108181, 0x81818181, 0x01010101, 0x01010101	# 0011b0
	.word	0x01010101, 0x01010101, 0x01010101, 0x10101010	# 0011c0
	.word	0x10108282, 0x82828282, 0x02020202, 0x02020202	# 0011d0
	.word	0x02020202, 0x02020202, 0x02020202, 0x10101010	# 0011e0
	.word	0x20000000, 0x00000000, 0x00000000, 0x00000000	# 0011f0
	.word	0x00000000, 0x00000000, 0x00000000, 0x00000000	# 001200
	.word	0x00000000, 0x00000000, 0x00000000, 0x00000000	# 001210
	.word	0x00000000, 0x00000000, 0x00000000, 0x00000000	# 001220
	.word	0x00000000, 0x00000000, 0x00000000, 0x00000000	# 001230
	.word	0x00000000, 0x00000000, 0x00000000, 0x00000000	# 001240
	.word	0x00000000, 0x00000000, 0x00000000, 0x00000000	# 001250
	.word	0x00000000, 0x00000000, 0x00000000, 0x00000000	# 001260
	.word	0x00000000                                    	# 001270

	.section	.text2,"x"
#################################################################################
# Reset entry point. We start running here at power-up.
#
#################################################################################


# Set up the stack pointer, frame pointer, argument pointer,
# and the interrupt stack pointer.

reset:
# 00001274:
	MOVAW	stack0,%sp
	MOVAW	stack0,%fp
	MOVAW	stack0,%ap
	MOVAW	istack0,%isp
 

# Next we set some timers. These commands write to the 8253 programmable
# timer chip and configure Counter 0 and Counter 2. It is as yet unknown what
# these timers are used for or what they're connected to.

# Send 0x16 to the command register of the 8253.
# BCD=0, M=011, RL=01, SC=00
# This selects counter 0, sets Read/Load to "Lest significant byte only",
# and sets mode to "Mode 3" (Square Wave generator)


	MOVB	&0x16,timer_ctrl

# Put 0x64 (SITINIT in firmware.h) into Counter 0
 
	MOVB	&0x64,timer_diva
 
# Send 0x94 to the command register of the 8253.
# BCD=0, M=010, RL=01, SC=10
# This selects counter 2, sets Read/Load to "Least significant byte only",
# and sets mode to "Mode 2" (Rate generator)

	MOVB	&0x94,timer_ctrl
 
# Puts 0xa into Counter 2

	MOVB	&0xa,timer_divc

# Send 0x74 to the command register of the 8253.
# BCD=0, M=010, RL=11, SC=01
# Select counter 1, sets Read/Load to "Least, then most SB",
# then sets mode to "Mode 2" (Rate generator)

	MOVB	&0x74,timer_ctrl
 
# ... but oddly, we don't seem to do anything with timer 1, we just let it
# sit there without loading any data into it, so its period is unknown.
# Counter 1 (0x42007 timer_diva) is unused in the rest of the ROM!

# Unconditional jump to 0x12d5 -- basically we skip the next block

	JMP	l12d5
 
################################################################################
#
# Unknown Entry Point. Who jumps here?
#

	.align	4
# 000012c4:
l12c4:
	SAVE	%r3
	ADDW2	&l8,%sp
	MOVB	&0x1,csr_fm_on	# turn floppy motor on
 
#
# Unknown Entry Point, but my current guess is that this is some
# kind of sanity check or power-on self-test of the CPU.
# 

# Set the PSW's NZCV flags to all '0's, leaving the rest of the PSW
# unaffected.

l12d5:
	MOVW	%psw,%r0
	ANDW2	&0xffc3ffff,%r0
	.byte	0x84, 0x40, 0x4b	# MOVW	%r0,%psw # as generates a NOP


# Branches based on the state of the PSW after clearing
# the NZCV bits. In short, each check looks to see if one
# of the bits is set when it should not be set. If they
# are, we jump to 0x1923. If not, we branch to the next
# check.

# If (Z == 0), branch to 0x12e8
	BNEB	l12e8
# No, branch to 0x1923
	BRH	l1923
 
# If ((N|Z) == 0), branch to 0x12ed
l12e8:	BGB	l12ed
# No, branch to 0x1923
	BRH	l1923
 
# If ((N == 0)|(Z == 1)), branch to 0x12f2
l12ed:	BGEB	l12f2
# No, branch to 0x1923
	BRH	l1923

# If ((C|Z) == 0), branch to 0x12f7
l12f2:	BGUB	l12f7
# No, branch to 0x1923
	BRH	l1923
 
# If (C == 0) branch to 0x12fc
l12f7:	BGEUB	l12fc
# No, branch to 0x1923
	BRH	l1923
 
# if (C == 0) branch to 0x12fc
# Why are we repeating this check?
# CAC: To make sure that the test does not clear or set the flag as a side effect?
l12fc:	BGEUB	l1301
# No, branch to 0x1923
	BRH	l1923
 
# if (V == 0) branch to 0x1306
l1301:	BVCB	l1306
# No, branch to 0x1923
	BRH	l1923
 
# We've fallen through.
# Now we set the PSW's NZCV flags to all 1's.

l1306:
	MOVW	%psw,%r0
	ORW2 &0x3c0000,%r0
	.byte	0x84, 0x40, 0x4b	# MOVW %r0,%psw # as inserts a NOP

# Now we do another check of the flags, very similar to
# the behavior above. Each check looks to see if a flag
# is clear when it should not be clear.

 
# If (Z == 1), branch to 0x1319
	BEB	l1319
# No, branch to 0x1923
	BRH	l1923
 
# If ((N|Z) == 1), branch to 0x131e
l1319:	BLEB	l131e
# No, branch to 0x1923
	BRH	l1923
 
# If ((N == 0) | (Z == 1)), branch to 0x1323
l131e:	BGEB	l1323
# No, branch to 0x1923
	BRH	l1923
 
# If ((C|Z) == 1), branch to 0x1328
l1323:	BLEUB	l1328
# No, branch to 0x1923
	BRH	l1923
 
# If (C == 1), branch to 0x132d
l1328:	BLUB	l132d
# No, branch to 0x1923
	BRH	l1923
 
# If (C == 1), branch to 0x1332.
# Again, we repeat a check -- why?
l132d:	BLUB	l1332
# No, branch to 0x1923
	BRH	l1923
 
# If (V == 1), branch to 0x1337
l1332:	BVSB	l1337
# No, branch to 0x1923
	BRH	l1923
 
# We've fallen through.
# Time for some more self-testing!
 
l1337:	NOP
	.byte	0x84, 0x4b, 0x40	# MOVW %psw,%r0 # as inserts a NOP
	ANDW2	&0xffc3ffff,%r0
	ORW2	&0x100000,%r0
	.byte	0x84, 0x40, 0x4b	# MOVW %r0,%psw # as inserts a NOP
	BGEB	l1351
	BRH	l1923

l1351:
	NOP
	.byte	0x84, 0x4b, 0x40	# MOVW %psw,%r0 # as inserts a NOP
	ANDW2	&0xffc3ffff,%r0
	ORW2	&mmu_scdl,%r0
	.byte	0x84, 0x40, 0x4b	# MOVW %r0,%psw # as inserts a NOP
	BLEUH	l136c
	BRH	l1923

l136c:
	NOP
	.byte	0x84, 0x4b, 0x40	# MOVW %psw,%r0 # as inserts a NOP
	ANDW2	&0xffc3ffff,%r0
	ORW2	&0x200000,%r0
	.byte	0x84, 0x40, 0x4b	# MOVW %r0,%psw # as inserts a NOP
	BLB	l1386
	BRH	l1923

# Put 0xff into R0, then rotate it through R1-R8

l1386:
	MOVW &-1,%r0
l1389:
	MOVW %r0,%r1
	MOVW %r1,%r2
	MOVW %r2,%r3
	MOVW %r3,%r4
	MOVW %r4,%r5
	MOVW %r5,%r6
	MOVW %r6,%r7
	MOVW %r7,%r8
	CMPW %r0,%r8

# If R0 != R8, fail.
	BNEH l1923
 
# Success. Now left-shift R0 by 1, store in R0
	LLSW3 &0x1,%r0,%r0
 
# Is zero flag set?
	BGEB l13af
# No, it's not, jump back and keep left-shifting until it is.
	BRB l1389

# Next check:
l13af:	MOVW &-2,%r0

l13b2:
	MCOMW %r0,%r1
	MCOMW %r1,%r2
	MCOMW %r2,%r3
	MCOMW %r3,%r4
	MCOMW %r4,%r5
	MCOMW %r5,%r6
	MCOMW %r6,%r7
	MCOMW %r7,%r8
	MCOMW %r0,%r8
	MCOMW %r1,%r7
	MCOMW %r2,%r6
	MCOMW %r3,%r5
	MCOMW %r8,%r1
	MCOMW %r7,%r2
	MCOMW %r6,%r3
	MCOMW %r4,%r0
	MCOMW %r1,%r4
	CMPW %r0,%r8
	BNEH l1923
	LLSW3 &0x1,%r0,%r0
	BLB l13f6
	MCOMW %r0,%r0
	BRB l13b2




l13f6:
	MOVW %fp,%r1
	MOVW %ap,%r2
	MOVW %sp,%r3
	MOVW %pcbp,%r4
	MOVW %isp,%r5
	MOVW &-1,%r0
l1408:
	MOVW %r0,%fp
	MOVW %fp,%ap
	MOVW %ap,%sp
	MOVW %sp,%pcbp
	MOVW %pcbp,%isp
	CMPW %fp,%isp
	BNEH l1466
	LLSW3 &0x1,%r0,%r0
	BGEB l1425
	BRB l1408


l1425:
	MOVW &0x1,%r0
l1428:
	MCOMW %r0,%fp
	MCOMW %fp,%ap
	MCOMW %ap,%sp
	MCOMW %sp,%pcbp
	MCOMW %pcbp,%isp
	MCOMW %fp,%isp
	MCOMW %ap,%pcbp
	MCOMW %sp,%fp
	MCOMW %isp,%ap
	MCOMW %pcbp,%sp
	CMPW %fp,%isp
	BNEH l1466
	LLSW3 &0x1,%r0,%r0
	BLB l1454
	BRB l1428

l1454:
	MOVW %r1,%fp
	MOVW %r2,%ap
	MOVW %r3,%sp
	MOVW %r4,%pcbp
	MOVW %r5,%isp

	BRH l1478
l1466:
	MOVW %r1,%fp
	MOVW %r2,%ap
	MOVW %r3,%sp
	MOVW %r4,%pcbp
	MOVW %r5,%isp

	BRH l1923

l1478:
	CLRH %r8
	MOVW &0x7fee,%r5
	CLRW %r7

# Tests for the carry bit (I think)
 
# First jump to 14c0 to start the test...
	BRB l14c0
 
 
# While r5 < r7...
l1483:
	MOVH {uhalf}%r8,{uword}%r0
	MOVB (%r7),{uhalf}%r1
	ANDH2 &0xff,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ADDW2 %r1,%r0
	MOVH %r0,%r8
	MOVH {uhalf}%r8,{uword}%r0
	LLSW3 &0x1,%r0,%r0
	MOVH {uhalf}%r0,{uword}%r0
	MOVH {uhalf}%r8,{uword}%r1
	LRSW3 &0xf,%r1,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ORW2 %r1,%r0
	MOVH %r0,%r8
	INCW %r7
l14c0:
	CMPW %r5,%r7
	BLUB l1483
 
	MOVH {uhalf}%r8,{uword}%r0
	MCOMW %r0,%r0
	MOVH %r0,%r8
	MOVH {uhalf}%r8,{uword}%r0
	MOVB (%r7),{uword}%r1
	MOVB 1(%r7),{uword}%r2
	LLSW3 &0x8,%r2,%r2
	ORW2 %r2,%r1
	CMPW %r1,%r0
	BNEB l14f0

	JMP l156e
l14f0:
 
	MOVH {uhalf}%r8,{uword}%r0
	MCOMW %r0,%r0
	MOVH %r0,%r8
	ADDW2 &0x8000,%r5
	BRB l1541
l1504:
	MOVH {uhalf}%r8,{uword}%r0
	MOVB (%r7),{uhalf}%r1
	ANDH2 &0xff,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ADDW2 %r1,%r0
	MOVH %r0,%r8
	MOVH {uhalf}%r8,{uword}%r0
	LLSW3 &0x1,%r0,%r0
	MOVH {uhalf}%r0,{uword}%r0
	MOVH {uhalf}%r8,{uword}%r1
	LRSW3 &0xf,%r1,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ORW2 %r1,%r0
	MOVH %r0,%r8
	INCW %r7
l1541:
	CMPW %r5,%r7
	BLUB l1504
	MOVH {uhalf}%r8,{uword}%r0
	MCOMW %r0,%r0
	MOVH %r0,%r8
	MOVH {uhalf}%r8,{uword}%r0
	MOVB (%r7),{uword}%r1
	MOVB 1(%r7),{uword}%r2
	LLSW3 &0x8,%r2,%r2
	ORW2 %r2,%r1
	CMPW %r1,%r0
	BEB l156e
	BRH l192c
l156e:
	CMPW &VECTOR,$runflg
	BEB l158e
	CMPW &REBOOT,$runflg
	BEB l158e
	JMP l16bc
l158e:
	CALL (%sp),$0x3b90
	ADDW3 &0x1,p_cmdqueue,%r0
	CMPB &0x2,(%r0)
	BNEB l15a7
	MOVW &0x1,%r0
	BRB l15a9
l15a7:
	CLRW %r0
l15a9:
	PUSHW %r0
	CALL -4(%sp),$0x732c
	PUSHW &0x0
	CALL -4(%sp),$0x798c
	MOVB $if_data,{uword}%r5
	MOVB &0x1,csr_fm_off	# turn floppy motor off
	MOVB &0x10,iu_ropr
	MOVB &0x20,iu_ropr
	MOVB &0x1,$0x2000868
	ADDW3 &0x2,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds a NOP
	BEB l15ff
	CALL (%sp),$0x5f72
	CALL (%sp),$0x6378
l15ff:
	ADDW3 &0x4,p_fl_cons,%r0
	CMPB &0x1,(%r0)
	BNEB l1612
	JMP l16a0
l1612:
	CALL (%sp),$0x5f72
	PUSHW &nvram_base+fw_nvr_bdev
	ADDW3 &0x1,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &0x1

# Read NVRAM
	CALL -12(%sp),rnvram
	TSTW %r0
	BNEB l165d
	ADDW3 &0x1,p_cmdqueue,%r0
	MOVB &0x1,(%r0)
	ADDW3 &0x1,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &nvram_base+fw_nvr_bdev
	PUSHW &0x1
	CALL -12(%sp),wnvram
l165d:
	MOVW $runflg,(%fp)
	CLRB *p_cmdqueue
	ADDW3 &0x2,p_cmdqueue,%r0

# Copy string "/filledt" (to where?)
	PUSHW %r0
	PUSHW &l5c8
	CALL -8(%sp),$0x7fb0
	CALL (%sp),$0x6970
	CMPW &FATAL,$runflg
	BEB l16a0
	MOVW (%fp),$runflg

l16a0:
	CMPW &VECTOR,$runflg
	BNEB l16b6
	CALL (%sp),*$rsthand
	BRB l16bc
l16b6:
	JMP l65f0
l16bc:
	CMPW &INIT,$meminit
	BEB l16f1
	MOVB &0x70,iu_acr
	MOVB &0x40,iu_ctur
	CLRB iu_ctlr
	MOVB &0x4,iu_ocpr
	CLRW $0x200085c
l16f1:
	MOVW $runflg,%r5
	MOVW $meminit,%r4
	MOVW $0x200085c,%r3
	MOVW &0x2000000,%r7
	MOVW &0x2001504,%r6
l1714:
	BRB l175f
l1716:
	MOVB &0xff,(%r7)
	CMPB &0xff,(%r7)
	BEB l1729
	JMP l1935
l1729:
	MOVB &0xaa,(%r7)
	CMPB &0xaa,(%r7)
	BEB l173c
	JMP l1935
l173c:
	MOVB &0x55,(%r7)
	CMPB &0x55,(%r7)
	BEB l174d
	JMP l1935
l174d:
	CLRB (%r7)
	MOVW %r7,%r0
	INCW %r7
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds a NOP
	BEB l175f
	JMP l1935
l175f:
	CMPW %r6,%r7
	BLUB l1716
	CMPW &0x2004000,%r7
	BLB l176f
	BRB l17ad
l176f:
	CMPW &FATAL,%r5
	BEB l179c
	CMPW &INIT,%r5
	BEB l179c
	CMPW &REBOOT,%r5
	BEB l179c
	CMPW &REENTRY,%r5
	BEB l179c
	CMPW &VECTOR,%r5
	BNEB l17a3
l179c:
	MOVW &0x2003000,%r7
l17a3:
	MOVW &0x2004000,%r6
	BRH l1714
l17ad:
	MOVW %r4,$meminit
	MOVW %r5,$runflg
	MOVW %r3,$0x200085c
	MOVB &0x1,$0x2000868
	CLRH %r8
 
# Put $43800 into R5. This is the top of NVRAM, and the stopping
# point for the upcoming block that clears NVRAM.
 
	MOVW &nvram_base+0x800,%r5
 
# Put $43000 into R7. This is the base of NVRAM.
	MOVW &nvram_base+0x00,%r7
 

	BRB l181d
l17df:
	MOVH {uhalf}%r8,{uword}%r0
# Read NVRAM address + 2 into R1
	MOVH {uhalf}2(%r7),{uword}%r1
# Mask the low nybble of R1
	ANDH2 &0xf,%r1
# Zero-extend the halfword into a word
	MOVH {uhalf}%r1,{uword}%r1
# Add R1 to R0, store in R0
	ADDW2 %r1,%r0
# Move R0 to R8
	MOVH %r0,%r8
	MOVH {uhalf}%r8,{uword}%r0
# Left-shift R0 by 1
	LLSW3 &0x1,%r0,%r0
	MOVH {uhalf}%r0,{uword}%r0
	MOVH {uhalf}%r8,{uword}%r1
	LRSW3 &0xf,%r1,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ORW2 %r1,%r0
	MOVH %r0,%r8
 
# Increment the address in R7 by 4 bytes
	ADDW2 &0x4,%r7
 
# While R5 < R7, keep going
l181d:
	CMPW %r5,%r7
	BLUB l17df

# Now we do something odd with 43800, 43804, 43808, and 4380c. What
# is this? Serial number structure of some kind?

	MOVH {uhalf}%r8,{uword}%r0
	MCOMW %r0,%r0
	MOVH %r0,%r8
	MOVH {uhalf}%r8,{uword}%r0
	ANDW3 &0xf,(%r7),%r1
	ANDW3 &0xf,4(%r7),%r2
	LLSW3 &0x4,%r2,%r2
	ORW2 %r2,%r1
	ANDW3 &0xf,8(%r7),%r2
	LLSW3 &0x8,%r2,%r2
	ORW2 %r2,%r1
	ANDW3 &0xf,12(%r7),%r2
	LLSW3 &0xc,%r2,%r2
	ORW2 %r2,%r1
	CMPW %r1,%r0

# If R1 != R0, we clear out the NVRAM. Othwerise, jump to 191d
	BNEB l1865
	JMP l191d

# Load the NVRAM base address into R7
l1865:
	MOVW &nvram_base+0x00,%r7
	BRB l1874

# Clear the NVRAM memory location stored in %r7
l186e:
	CLRW (%r7)

# Add 4 bytes to the address
	ADDW2 &0x4,%r7

# Is %r7 == %r5?
l1874:
	CMPW %r5,%r7

# No, jump back and keep zeroing NVRAM.
	BLUB l186e

# Yes, we're done.

# Store 01 in $43060
	MOVW &0x1,$nvram_base+0x60

# Store 00 in $43064
	CLRW $nvram_base+0x64
	CLRH %r8
	MOVW &nvram_base+0x00,%r7
	BRB l18d1
l1893:
	MOVH {uhalf}%r8,{uword}%r0
	MOVH {uhalf}2(%r7),{uword}%r1
	ANDH2 &0xf,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ADDW2 %r1,%r0
	MOVH %r0,%r8
	MOVH {uhalf}%r8,{uword}%r0
	LLSW3 &0x1,%r0,%r0
	MOVH {uhalf}%r0,{uword}%r0
	MOVH {uhalf}%r8,{uword}%r1
	LRSW3 &0xf,%r1,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ORW2 %r1,%r0
	MOVH %r0,%r8
	ADDW2 &0x4,%r7


l18d1:
	CMPW %r5,%r7
	BLUB l1893
	MOVH {uhalf}%r8,{uword}%r0
	MCOMW %r0,%r0
	MOVH %r0,%r8
	MOVH {uhalf}%r8,{uword}(%r7)
	MOVH {uhalf}%r8,{uword}%r0
	LRSW3 &0x4,%r0,%r0
	MOVW %r0,4(%r7)
	MOVH {uhalf}%r8,{uword}%r0
	LRSW3 &0x8,%r0,%r0
	MOVW %r0,8(%r7)
	MOVH {uhalf}%r8,{uword}%r0
	LRSW3 &0xc,%r0,%r0
	MOVW %r0,12(%r7)
	ORW2 &0x20000000,$0x200085c

l191d:
	JMP l21b1

##
# Test failure entry points, I think.
#
# Set %r4 based on the entry point. %r4 will be either: 2, 3, 4 or 5.
##
l1923:

# Set %r4 to 2, then jump to 0x1941
	MOVW &0x2,%r4
	JMP l1941

# Set %r4 to 3, then jump to 0x1941
l192c:
	MOVW &0x3,%r4
	JMP l1941

## Set %r4 to 4, then jump to 0x1941
l1935:
	MOVW &0x4,%r4
	JMP l1941

## Set %r4 to 5, fall through to 0x1941
	MOVW &0x5,%r4

## Set 0x4900d (iu_ocpr) to 0. This is 2681 UART.
l1941:
	CLRB iu_ocpr
	MOVB &0x8,iu_ropr

	MOVB &0x1,csr_clr_fled	# Clear failure LED
	MOVB &0x1,csr_clr_bto	# Clear bus timeout error

l1960:
	CLRW %r5
	BRB l1994
l1964:
	CLRW %r3
	BRB l196a
l1968:
	INCW %r3
l196a:
	CMPW &0xc350,%r3
	BLEUB l1968
	MOVB &0x1,csr_set_fled	# set failure LED
	CLRW %r3
	BRB l1981
l197f:
	INCW %r3
l1981:
	CMPW &0xc350,%r3
	BLEUB l197f

## Write to the CSR (what register?)
	MOVB &0x1,csr_clr_fled	# clear failure LED
	INCW %r5
l1994:
	CMPW %r4,%r5
	BLUB l1964
	CMPB &0x1,*p_spwrinh
	BEB l19cb
	CMPB &0x64,timer_diva

## If *0x42003 (timer_diva) == 0x64, jump over the up-coming infinite loop...
	BEB l19cb

## Otherwise, we're terminal. Set some state...
	CLRW *$0x48c
	CLRW *p_meminit
	CLRB iu_ocpr
	MOVB &0x4,iu_sopr

## ... and then die in an infinite loop (BRB 0)
l19c9:
	BRB l19c9

## R3 = 0
l19cb:
	CLRW %r3

## Skip first increment, so R3 still = 0. Go to 19d1
	BRB l19d1

l19cf:
	INCW %r3

## Multiply R4 by 0xC350 (50000d) and store in R0.
l19d1:
	# cac: No matter what I do, as generates a MOVW instead of a MULW3
	.byte	0xe8, 0x4f, 0x50, 0xc3, 0x00, 0x00, 0x44, 0x40	#MULW3 &0xc350,%r4,%r0

## While R3 < R0, keep incremting R3.
	CMPW %r0,%r3
	BLEUB l19cf

	JMP l1960

## OK, I don't actually see how any code can reach this point. The
## unconditional jump above catches everything, and I don't see any
## other branches to this location. Weird.
	MOVAW (%fp),%sp
	POPW %r8
	POPW %r7
	POPW %r6
	POPW %r5
	POPW %r4
	POPW %r3
	POPW %fp
	RET
	NOP
	NOP

################################################################################
## Unknown Routine - in fact, nothing calls this code! It looks unreachable.
##
# 000019f8:
l19f8:
	SAVE %r3
## cac: as shortens the 0x0 to 1 byte.
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
## Jump point from 0x25d3
l1a01:
	MOVB &0xd0,$if_data
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	MOVB &0x1,$0x2000870
	MOVB &0xff,$0x2000871
	MOVW &0x43800,%r3
	PUSHW &0x0
	PUSHW &0x2000874
	PUSHW &0x0
	PUSHW &0x3
	CALL -16(%sp),fd_acs
	TSTW %r0
	BNEB l1a4c
	JMP l1b67
l1a4c:
	ADDW3 &0x3,p_serno,%r0
	CMPB (%r0),$0x2000874
	BEB l1a63
	JMP l1b67
l1a63:
	ADDW3 &0x7,p_serno,%r0
	CMPB (%r0),$0x2000875
	BEB l1a7a
	JMP l1b67
l1a7a:
	ADDW3 &0xb,p_serno,%r0
	CMPB (%r0),$0x2000876
	BEB l1a91
	JMP l1b67
l1a91:
	ADDW3 &0xf,p_serno,%r0
	CMPB (%r0),$0x2000877
	BEB l1aa8
	JMP l1b67
l1aa8:
	MOVW &nvram_base+0x00,%r8
	BRB l1ab7
l1ab1:
	CLRW (%r8)
	ADDW2 &0x4,%r8
l1ab7:
	CMPW %r3,%r8
	BLUB l1ab1
	MOVW &0x1,$nvram_base+0x60
	CLRW $nvram_base+0x64
	CLRH %r4
	MOVW &nvram_base+0x00,%r8
	BRB l1b14
l1ad6:
	MOVH {uhalf}%r4,{uword}%r0
	MOVH {uhalf}2(%r8),{uword}%r1
	ANDH2 &0xf,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ADDW2 %r1,%r0
	MOVH %r0,%r4
	MOVH {uhalf}%r4,{uword}%r0
	LLSW3 &0x1,%r0,%r0
	MOVH {uhalf}%r0,{uword}%r0
	MOVH {uhalf}%r4,{uword}%r1
	LRSW3 &0xf,%r1,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ORW2 %r1,%r0
	MOVH %r0,%r4
	ADDW2 &0x4,%r8
l1b14:
	CMPW %r3,%r8
	BLUB l1ad6
	MOVH {uhalf}%r4,{uword}%r0
	MCOMW %r0,%r0
	MOVH %r0,%r4
	MOVH {uhalf}%r4,{uword}(%r8)
	MOVH {uhalf}%r4,{uword}%r0
	LRSW3 &0x4,%r0,%r0
	MOVW %r0,4(%r8)
	MOVH {uhalf}%r4,{uword}%r0
	LRSW3 &0x8,%r0,%r0
	MOVW %r0,8(%r8)
	MOVH {uhalf}%r4,{uword}%r0
	LRSW3 &0xc,%r0,%r0
	MOVW %r0,12(%r8)
	ORW2 &0x40000000,$0x200085c
	CALL (%sp),$0x5de0
l1b67:
	PUSHW &nvram_base+fw_nvr_bdev
	PUSHW &0x2000861
	PUSHW &0x1
	CALL -12(%sp),rnvram
	TSTW %r0
	BNEB l1b9f
	MOVB &0x1,$0x2000861
	PUSHW &0x2000861
	PUSHW &nvram_base+fw_nvr_bdev
	PUSHW &0x1
	CALL -12(%sp),wnvram
l1b9f:
	CMPB &0x1,$0x2000861
	BEB l1bb1
	CMPB &0x2,$0x2000861
	BNEB l1bc1
l1bb1:
	MOVB &0x1,%r5
	SUBB3 &0x1,$0x2000861,%r0
	MOVB %r0,%r7
	BRB l1bc5
l1bc1:
	CLRB %r5
	CLRB %r7
l1bc5:
	CLRB $0x2000860
	CLRH %r4
	BRB l1be8
l1bd0:
	MOVH {uhalf}%r4,{uword}%r0
	MOVH {uhalf}%r4,{uword}%r1
# l10ec lookup table?
	MOVB	l10ec(%r1),hdcspec(%r0)
	INCH %r4
l1be8:
	MOVH {uhalf}%r4,{uword}%r0
	CMPW &0x8,%r0
	BLUB l1bd0
	CLRH %r4
	BRB l1c17
l1bf6:
	MOVB %r7,{uword}%r0
	PUSHW %r0
	CALL -4(%sp),$0x732c
	TSTW %r0
	BEB l1c0a
	BRB l1c21
l1c0a:
	PUSHW &0x64
	CALL -4(%sp),*p_hwcntr # DUART Delay
	INCH %r4
l1c17:
	MOVH {uhalf}%r4,{uword}%r0
	CMPW &0x3c,%r0
	BLUB l1bf6
l1c21:
	MOVB %r7,{uword}%r0
	PUSHW %r0
## XXX Call to 6e28
	CALL -4(%sp),$0x6e28
	TSTW %r0
	BNEB l1c6a
## Here we seem to be setting 0x2 in r0
	ORW3 &0x2,$0x2000a7c,%r0
	MOVB %r7,{uword}%r1
	LLSW3 &0x17,%r1,%r1
	ORW2 %r1,%r0
	PUSHW %r0
	CALL -4(%sp),$0x61c0
	MOVB &0x1,csr_set_fled	# set failure LED
	MOVW &FATAL,*$0x48c
	JMP l1e37
l1c6a:
	# cac: as generates a MOVB
	.byte	0xeb, 0x6f, 0x54, 0x47, 0x40	# MULB3 &0x54,%r7,%r0
	CMPW &0xca5e600d,0x2000a84(%r0)
	BEB l1c82
	JMP l1da0
l1c82:
	ADDB3 &0x1,%r7,%r0
	ORB2 %r0,$0x2000860
	ANDB2 &0xf0,$0x2000a75
	.byte	0xeb, 0x6f, 0x54, 0x47, 0x40	# MULB3 &0x54,%r7,%r0
	LRSW3 &0x8,0x2000aa4(%r0),%r0
	ORB2 %r0,$0x2000a75
	.byte	0xeb, 0x6f, 0x54, 0x47, 0x40	# MULB3 &0x54,%r7,%r0
	MOVB 0x2000aa7(%r0),$0x2000a76
	.byte	0xeb, 0x6f, 0x54, 0x47, 0x40	# MULB3 &0x54,%r7,%r0
	SUBB3 &0x1,0x2000a9f(%r0),%r0
	MOVB %r0,$0x2000a77
	.byte	0xeb, 0x6f, 0x54, 0x47, 0x40	# MULB3 &0x54,%r7,%r0
	SUBB3 &0x1,0x2000aa3(%r0),%r0
	MOVB %r0,$0x2000a78
	.byte	0xeb, 0x6f, 0x54, 0x47, 0x40	# MULB3 &0x54,%r7,%r0
	LRSW3 &0x9,0x2000a98(%r0),%r0
	MOVB %r0,$0x2000a7a
	.byte	0xeb, 0x6f, 0x54, 0x47, 0x40	# MULB3 &0x54,%r7,%r0
	LRSW3 &0x1,0x2000a98(%r0),%r0
	MOVB %r0,$0x2000a7b
	MOVB %r7,{uword}%r0
	PUSHW %r0
	CALL -4(%sp),$0x732c
	TSTW %r0
	BNEB l1d57
	TSTB %r5
	BEB l1d57
	MOVB %r7,{uword}%r0
	LLSW3 &0x17,%r0,%r0
	ORW2 &mmu_pdcrl,%r0
	PUSHW %r0
	CALL -4(%sp),$0x61c0
	MOVB &0x1,csr_set_fled	# set failure LED
	MOVW &FATAL,*$0x48c
	BRB l1d9a
l1d57:
	TSTB %r5
	BEB l1d9a
	MOVB %r7,{uword}%r0
	PUSHW %r0
	CALL -4(%sp),$0x78d4
	TSTW %r0
	BNEB l1d9a
	MOVB %r7,{uword}%r0
	LLSW3 &0x17,%r0,%r0
	ORW2 &0x50002,%r0
	PUSHW %r0
	CALL -4(%sp),$0x61c0
	MOVB &0x1,csr_set_fled	# set failure LED
	MOVW &FATAL,*$0x48c
l1d9a:
	JMP l1e37
l1da0:
	CMPW &FATAL,$0x2000878
	BNEB l1e06
	MOVW &0x3d,$runflg
	PUSHW &runflg
	PUSHW &nvram_base+fw_nvr_link
	PUSHW &0x2
	CALL -12(%sp),wnvram
	CALL (%sp),$0x3b90
	MOVB &0x1,$0x2000861
	PUSHW &0x2000861
	PUSHW &nvram_base+fw_nvr_bdev
	PUSHW &0x1
	CALL -12(%sp),wnvram
	MOVW &REENTRY,$runflg
	ORW2 &0x10,$0x200085c
	BRB l1e37
l1e06:
	TSTB %r5
	BEB l1e37
	MOVB %r7,{uword}%r0
	LLSW3 &0x17,%r0,%r0
	ORW2 &0x20002,%r0
	PUSHW %r0
	CALL -4(%sp),$0x61c0
	MOVB &0x1,csr_set_fled	# set failure LED
	MOVW &FATAL,*$0x48c
l1e37:
	XORB3 &0x1,%r7,%r0
	MOVB %r0,%r6
	PUSHW &nvram_base+0x3a
	PUSHW &0x2000861
	PUSHW &0x1
	CALL -12(%sp),rnvram
	TSTW %r0
	BNEB l1e75
	CLRB $0x2000861
	PUSHW &0x2000861
	PUSHW &nvram_base+0x3a
	PUSHW &0x1
	CALL -12(%sp),wnvram
l1e75:
	CMPB &0x1,$0x2000861
	BNEB l1e81
	MOVH &0x3b,%r4
l1e81:
	PUSHW &0x64
	CALL -4(%sp),*p_hwcntr # DUART Delay
	MOVB %r6,{uword}%r0
	PUSHW %r0
	CALL -4(%sp),$0x7380
	TSTW %r0
	BEB l1ea0
	BRB l1eac
l1ea0:
	INCH %r4
	MOVH {uhalf}%r4,{uword}%r0
	CMPW &0x3c,%r0
	BLUB l1e81
l1eac:
	MOVH {uhalf}%r4,{uword}%r0
	CMPW &0x3c,%r0
	BLUB l1eda
	MOVB &0x1,$0x2000861
	PUSHW &0x2000861
	PUSHW &nvram_base+0x3a
	PUSHW &0x1
	CALL -12(%sp),wnvram
	JMP l20a9
l1eda:
	MOVB %r6,{uword}%r0
	PUSHW %r0
	CALL -4(%sp),$0x6e28
	TSTW %r0
	BNEB l1f23
	ORW3 &0x2,$0x2000a7c,%r0
	MOVB %r6,{uword}%r1
	LLSW3 &0x17,%r1,%r1
	ORW2 %r1,%r0
	PUSHW %r0
	CALL -4(%sp),$0x61c0
	MOVB &0x1,csr_set_fled	# set failure LED
	MOVW &FATAL,*$0x48c
	JMP l20a9
l1f23:
	.byte	0xeb, 0x6f, 0x54, 0x46, 0x40	# MULB3 &0x54,%r6,%r0
	CMPW &0xca5e600d,0x2000a84(%r0)
	BEB l1f68
	MOVB %r6,{uword}%r0
	LLSW3 &0x17,%r0,%r0
	ORW2 &0x20002,%r0
	PUSHW %r0
	CALL -4(%sp),$0x61c0
	MOVB &0x1,csr_set_fled	# set failure LED
	MOVW &FATAL,*$0x48c
	JMP l20a9
l1f68:
	ADDB3 &0x1,%r6,%r0
	ORB2 %r0,$0x2000860
	CLRW %r3
	.byte	0xeb, 0x6f, 0x54, 0x46, 0x40	# MULB3 &0x54,%r6,%r0
	.byte	0xeb, 0x6f, 0x54, 0x47, 0x41	# MULB3 &0x54,%r7,%r0
	CMPW 0x2000aa4(%r1),0x2000aa4(%r0)
	BLEUB l1fc0
	ANDB2 &0xf0,$0x2000a75
	.byte	0xeb, 0x6f, 0x54, 0x46, 0x40	# MULB3 &0x54,%r6,%r0
	LRSW3 &0x8,0x2000aa4(%r0),%r0
	ORB2 %r0,$0x2000a75
	.byte	0xeb, 0x6f, 0x54, 0x46, 0x40	# MULB3 &0x54,%r6,%r0
	MOVB 0x2000aa7(%r0),$0x2000a76
	MOVW &0x1,%r3
l1fc0:
	.byte	0xeb, 0x6f, 0x54, 0x46, 0x40	# MULB3 &0x54,%r6,%r0
	.byte	0xeb, 0x6f, 0x54, 0x47, 0x41	# MULB3 &0x54,%r7,%r0
	CMPW 0x2000a9c(%r1),0x2000a9c(%r0)
	BLEUB l1fef
	.byte	0xeb, 0x6f, 0x54, 0x46, 0x40	# MULB3 &0x54,%r6,%r0
	SUBB3 &0x1,0x2000a9f(%r0),%r0
	MOVB %r0,$0x2000a77
	MOVW &0x1,%r3
l1fef:
	.byte	0xeb, 0x6f, 0x54, 0x46, 0x40	# MULB3 &0x54,%r6,%r0
	.byte	0xeb, 0x6f, 0x54, 0x47, 0x41	# MULB3 &0x54,%r7,%r0
	CMPW 0x2000aa0(%r1),0x2000aa0(%r0)
	BLEUB l201e
	.byte	0xeb, 0x6f, 0x54, 0x46, 0x40	# MULB3 &0x54,%r6,%r0
	SUBB3 &0x1,0x2000aa3(%r0),%r0
	MOVB %r0,$0x2000a78
	MOVW &0x1,%r3
l201e:
	.byte	0xeb, 0x6f, 0x54, 0x46, 0x40	# MULB3 &0x54,%r6,%r0
	.byte	0xeb, 0x6f, 0x54, 0x47, 0x41	# MULB3 &0x54,%r7,%r0
	CMPW 0x2000a98(%r1),0x2000a98(%r0)
	BLEUB l2062
	.byte	0xeb, 0x6f, 0x54, 0x46, 0x40	# MULB3 &0x54,%r6,%r0
	LRSW3 &0x9,0x2000a98(%r0),%r0
	MOVB %r0,$0x2000a7a
	.byte	0xeb, 0x6f, 0x54, 0x46, 0x40	# MULB3 &0x54,%r6,%r0
	LRSW3 &0x1,0x2000a98(%r0),%r0
	MOVB %r0,$0x2000a7b
	MOVW &0x1,%r3
l2062:
	TSTW %r3
	BEB l20a9
	MOVB %r6,{uword}%r0
	PUSHW %r0
	CALL -4(%sp),$0x732c
	TSTW %r0
	BNEB l20a9
	TSTB %r5
	BEB l20a9
	MOVB %r6,{uword}%r0
	LLSW3 &0x17,%r0,%r0
	ORW2 &mmu_pdcrl,%r0
	PUSHW %r0
	CALL -4(%sp),$0x61c0
	MOVB &0x1,csr_set_fled	# set failure LED
	MOVW &FATAL,*$0x48c
l20a9:
	CALL (%sp),$0x5de0
	CMPB &0x2,$0x2000860
	BLEB l20c9
	MOVB $0x2000860,{uhalf}%r0
	SUBH2 &0x1,%r0
	MOVH %r0,%r4
	BRB l20d4
l20c9:
	MOVB $0x2000860,{uhalf}%r0
	MOVH %r0,%r4
l20d4:
	ADDW3 &0x4,p_edt,%r0
	MOVH {uhalf}%r4,{uword}%r1
	INCW %r1
	INSFW &0x3,&0x0,%r1,(%r0)
	ADDW3 &0x8,p_edt,%r0
	MOVW *p_memstart,(%r0)
	ADDW3 &0x4,p_edt,%r0
	EXTFW &0x3,&0x0,(%r0),%r0
	MULW2 &0xc,%r0
	ADDW2 %r0,*p_memstart
	ADDW3 &0x8,p_edt,%r0
	MOVH &0x1,*0(%r0)
	ADDW3 &0x8,p_edt,%r0
	ADDW3 &0x2,(%r0),%r0
	PUSHW %r0
	PUSHW &l5d1
	CALL -8(%sp),$0x7fb0
	BITB $0x2000860,&0x1
	BEB l2164
	CMPW &0xca5e600d,$0x2000a84
	BNEB l2164
	ADDW3 &0x8,p_edt,%r0
	MOVW (%r0),%r0
	MOVH $0x2000a82,12(%r0)
l2164:
	BITB $0x2000860,&0x2
	BEB l218e
	CMPW &0xca5e600d,$0x2000ad8
	BNEB l218e
	ADDW3 &0x8,p_edt,%r0
	MOVW (%r0),%r0
	MOVH $0x2000ad6,24(%r0)
l218e:
	JMP l65f0
	MOVAW (%fp),%sp
	POPW %r8
	POPW %r7
	POPW %r6
	POPW %r5
	POPW %r4
	POPW %r3
	POPW %fp
	RET
	NOP
	NOP

################################################################################

l21a8:
	SAVE %r5
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
## Jump point from 0x191d
l21b1:
	MOVW &0x2000b28,%r8
	MOVW &l5e4,%r7
	CLRW %r5
	BRB l21d3
l21c3:
	MOVW %r8,%r0
	INCW %r8
	MOVW %r7,%r1
	INCW %r7
	MOVB (%r1),(%r0)
	INCW %r5
l21d3:
	CMPW &0x44,%r5
	BLUB l21c3

### Stick initial PSW 0x81e180 into PCB at 0x2000b78
	MOVW &0x81e180,$0x2000b78
### Stick PC 0x41f8 into PCB at 0x2000b78
	MOVW &l41f8,$0x2000b7c
	MOVW &0x2000ee8,$0x2000b80
	MOVW &0x2000ee8,$0x2000b90
	MOVW &0x20010e8,$0x2000b94
	CLRW $0x2000bc4
	CLRW %r5

### GOTO 2258
	BRB l2258

### Each time through this loop, we're incrementing the PCBP by 50, to
### point at the next PCBP.
###    Loop 0: r5 = 0
###    Loop 1: r5 = 1
###    Loop 2: r5 = 2, etc...
###
### %r0 accumulates the new PCBP, which we stuff into R6.

l2220:
	.byte	0xe8, 0x6f, 0x50, 0x45, 0x40	# MULW3 &0x50,%r5,%r0
	ADDW2 &0x2000bc8,%r0
	MOVW %r0,%r6
	MOVW &0x81e180,(%r6)
	MOVW &0x20010e8,8(%r6)
	MOVW &0x20010e8,24(%r6)
	MOVW &console,28(%r6)
	CLRW 76(%r6)
	INCW %r5

### If R5 < 9, GOTO 2220
l2258:
	CMPW &0x9,%r5
	BLB l2220

### After the loop, PCBPs look like this:
###
###     PSW = 0x81e180
###     PC = Undefined (filled out below)
###     Stack Pointer = 0x20010e8
###     Stack Lower Bound = 0x200010e8
###     Stack Upper Bound = 0x200011e8
###


### Now, fill the Interrupt PCB Program Counters
###
### Each interrupt vector in the ROM interrupt vectors table (located at
### 0x090 through 0x108) points to a PCB in RAM, consisting of
### at least a PSW/PC/SP "initial context". This set of MOVs appears
### to fill the PCB PC's
###

### PCBP = 0x2000bc8. Handler = 0x40a0
	MOVW &l40a0,$0x2000bcc

### PCBP = 0x2000c18. Handler = 0x40c6
	MOVW &l40c6,$0x2000c1c

### PCBP = 0x2000c68. Handler = 0x40ec
	MOVW &l40ec,$0x2000c6c

### PCBP = 0x2000cb8. Handler = 0x4112
	MOVW &l4112,$0x2000cbc

### PCBP = 0x2000d08. Handler = 0x4138
	MOVW &l4138,$0x2000d0c

### PCBP = 0x2000d58. Handler = 0x415e
	MOVW &l415e,$0x2000d5c

### PCBP = 0x2000da8. Handler = 0x4184
	MOVW &l4184,$0x2000dac

### PCBP = 0x2000df8. Handler = 0x41aa
### (n.b.: This PCBP doesn't seem to appear in the vector table. Mysterious!)
	MOVW &l41aa,$0x2000dfc

### PCBP = 0x2000e48. Handler = 0x41d0
	MOVW &l41d0,$0x2000e4c

### PCBP = 0x2000e90. PSW = 0x81e180.
### (n.b.: This PCBP doesn't seem to appear in the vector table, either.)
	MOVW &0x81e180,$0x2000e98


	MOVW &l428e,$0x2000e9c
	MOVW &0x2000ee8,$0x2000ea0
	MOVW &0x2000ee8,$0x2000eb0
	MOVW &0x20010e8,$0x2000eb4
	CLRW $0x2000ee4
	MOVAW $0x2000b28,%pcbp
	JMP l2331
	MOVAW -8(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %r6
	POPW %r5
	POPW %fp
	RET


################################################################################

## Who jumps here?
l2328:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x08, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x8,%sp

## Jumped to from $0x2313
l2331:
	MOVW &iu_base,$console
	CALL (%sp),$0x3b90
	CALL (%sp),0x37c(%pc)
	MOVB %r0,(%fp)
	.byte	0x2b, 0x59	# TSTB (%fp) # as adding NOP
	BNEB l2359
## If the contents of the address pointed to by %fp are == 0,
## jump to a failure point.
	.byte	0x24, 0x7f, 0x3e, 0x19, 0x00, 0x00	# JMP $l193e # as adding NOP
	BRB l2364
l2359:
	CMPB &0x2,(%fp)

	BNEB l2364
	JMP l12d5

## Set the fatal "EXECUTION HALTED" bit in 2000085C
l2364:
	ORW2 &0x80000000,$0x200085c
	CALL (%sp),$0x5de0
	CALL (%sp),l297c
	MOVW %r0,*p_memsize
	MOVW &edt,*p_memstart
	ADDW2 &0x20,*p_memstart
	MOVB &0x0,{uword}%r0
	INSFW &0x3,&0xc,%r0,*p_edt
	MOVB &0x1,{uword}%r0
	INSFW &0xf,&0x10,%r0,*p_edt
	ADDW3 &0x4,p_edt,%r0
	MOVB &0x1,{uword}%r1
	INSFW &0x0,&0x5,%r1,(%r0)
	ADDW3 &0x4,p_edt,%r0
	MOVB &0x1,{uword}%r1
	INSFW &0x0,&0x6,%r1,(%r0)
	ADDW3 &0xc,p_edt,%r0
	PUSHW %r0
	PUSHW &l628	# "SBD"
	CALL -8(%sp),$0x7fb0
	ADDW3 &0x4,p_edt,%r0
	MOVB &0x1,{uword}%r1
	INSFW &0x0,&0x7,%r1,(%r0)
	ADDW3 &0x4,p_edt,%r0
	MOVB &0x1,{uword}%r1
	INSFW &0x0,&0x9,%r1,(%r0)
	MOVW &l65a4,*p_exchand
	MOVW &l65a4,*p_bpthand
	CALL (%sp),$0x5f72
	MOVB &0x1,csr_fm_off	# floppy motor off
	MOVB &0x1,*p_num_edt
	CLRB $0x20011f1
	MOVW &l25e0,*p_exchand
	MOVW &l25e0,*p_bpthand
	CALL (%sp),*p_excret
	JMP l253a
l2471:
	MOVB $0x20011f1,{uword}%r0
	LLSW3 &0x15,%r0,%r0
	CLRB 5(%r0)
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	MOVB *p_num_edt,{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	MOVB $0x20011f1,{uword}%r1
	LLSW3 &0x15,%r1,%r1
	MOVB 1(%r1),{uword}%r2
	INSFW &0xf,&0x10,%r2,(%r0)
	ADDW2 &0x20,*p_memstart
	MOVB *p_num_edt,%r0
	INCB *p_num_edt
	MOVB %r0,{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	MOVB $0x20011f1,{uword}%r1
	INSFW &0x3,&0xc,%r1,(%r0)
	MOVB $0x20011f1,{uword}%r0
	LLSW3 &0x15,%r0,%r0
	MOVB (%r0),{uhalf}%r0
	MOVH %r0,2(%fp)
	DECB *p_num_edt
	MOVB *p_num_edt,{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	MOVW %r0,4(%fp)
	EXTFW &0xf,&0x10,*4(%fp),%r0
	MOVH {uhalf}2(%fp),{uword}%r1
	LLSW3 &0x8,%r1,%r1
	ORW2 %r1,%r0
	INSFW &0xf,&0x10,%r0,*4(%fp)
	INCB *p_num_edt
l253a:
	INCB $0x20011f1
	CMPB &0xc,$0x20011f1
	BLEH l2471
	MOVW &l65a4,*p_exchand
	MOVW &l65a4,*p_bpthand
	ADDW3 &0x2,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds NOP
	BEB l2595
	CALL (%sp),$0x5f72
	CALL (%sp),$0x6378
	CMPW &0x1,%r0
	BNEB l2595
	ORW2 &0x80000000,$0x200085c
	CALL (%sp),$0x5de0
l2595:
	CMPW &FATAL,$runflg
	BEB l25cc
	CMPW &REBOOT,$runflg
	BEB l25cc
	CMPW &REENTRY,$runflg
	BEB l25cc
	CALL (%sp),0x80(%pc)
	TSTW %r0
	BNEB l25cc
	CALL (%sp),$0x5de0
l25cc:
	CALL (%sp),$0x5f72
	JMP l1a01
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################
## Routine that sets the "Self-config failure" flag in 0x200085C
##
l25e0:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVH {uhalf}csr_datal,{uword}%r0
	BITW %r0,&0x8000
	BEB l2605
	MOVB &0x1,csr_clr_inht
	BRB l2635
l2605:
	MOVW &FATAL,*$0x48c
	CALL (%sp),$0x5f72
	MOVB &0x1,csr_fm_off # floppy motor off
## This appears to set a flag meaning "Self-config failure" in the
## failure flags.
	ORW2 &0x1,$0x200085c
	CALL (%sp),$0x5de0
	JMP l65f0
l2635:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################

l263c:
	SAVE %r7
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVW &0x2004000,%r8
	MOVW &0x2040000,%r7
	BRB l268e
l2655:
	MOVB &0xff,(%r8)
	CMPB &0xff,(%r8)
	BEB l2664
	BRB l2693
l2664:
	MOVB &0xaa,(%r8)
	CMPB &0xaa,(%r8)
	BEB l2673
	BRB l2693
l2673:
	MOVB &0x55,(%r8)
	CMPB &0x55,(%r8)
	BEB l2680
	BRB l2693
l2680:
	CLRB (%r8)
	MOVW %r8,%r0
	INCW %r8
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds NOP
	BEB l268e
	BRB l2693
l268e:
	CMPW %r7,%r8
	BLUB l2655
l2693:
	CMPW %r7,%r8
	BGEUB l26b0
	ORW2 &0x8,$0x200085c
	MOVW &FATAL,$runflg
	CLRW %r0
	BRB l26b5
l26b0:
	MOVW &0x1,%r0
	BRB l26b5
l26b5:
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET

################################################################################
## These look like UART tests, specifically testing the Tx/Rx buffer
##
l26c0:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp

## Set up the UART for our test. These three commands are as follows:
## 0x20 = Reset Receiver (Disable receiver, flush FIFO)
## 0x30 = Start Break (Forces TxDA output low)
## 0x10 = Reset MR pointer. Causes channel A MR pointer to point to
##        channel 1.

	MOVB &0x20,iu_cra
	MOVB &0x30,iu_cra
	MOVB &0x10,iu_cra

## Now set bit 4 of the MRA (no parity)
	MOVB iu_mr12a,{uhalf}%r0
	MOVH %r0,(%fp)
	ORB2 &0x80,iu_mr12a

## Now reset chanel a break change interrupt.
	MOVB &0x5,iu_cra

## Run the UART delay clock for 14 clock cycles
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay

## Write 0x55 into the UART's buffer.
	MOVB &0x55,iu_thra

## Run the UART delay clock for 14 clock cycles
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay

## Check to see if UART status bit RxRDY is set. If it is, go to next
## check. If not, return.
	BITB iu_sra,&0x1
	BNEB l272d
	CLRW %r0
	JMP l2973

## Check if 0x55 is in the UART's buffer. If it is, go to next check.
## If not, return.
l272d:
	CMPB &0x55,iu_thra
	BEB l273f
	CLRW %r0
	JMP l2973

## Check to see if UART status bit RxRDY is set. If it is, go to next
## check. If not, return.
l273f:
	BITB iu_sra,&0x1
	BEB l2750
	CLRW %r0

## Write 0xAA to the TX buffer
	JMP l2973

l2750:
	MOVB &0xaa,iu_thra

## Call UART delay for 14 clock cycles
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay

## Check to see if RxRDY is set again
	BITB iu_sra,&0x1
	BNEB l2775
	CLRW %r0
	JMP l2973
l2775:
	CMPB &0xaa,iu_thra
	BEB l2788
	CLRW %r0
	JMP l2973
l2788:
	MOVB &0x20,iu_cra
	MOVB &0x30,iu_cra
	MOVB &0x10,iu_cra
	MOVB iu_base,{uhalf}%r0
	MOVH %r0,(%fp)
	ANDB2 &0x7f,iu_base
	MOVB &0x5,iu_cra
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	MOVB &0x20,iu_crb
	MOVB &0x30,iu_crb
	MOVB &0x10,iu_crb
	MOVB iu_mr12b,{uhalf}%r0
	MOVH %r0,(%fp)
	ORB2 &0x80,iu_mr12b
	MOVB &0x5,iu_crb
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	MOVB &0x55,iu_thrb

	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	BITB iu_srb,&0x1
	BNEB l282b
	CLRW %r0
	JMP l2973

l282b:
	CMPB &0x55,iu_thrb
	BEB l283d
	CLRW %r0
	JMP l2973

l283d:
	BITB iu_srb,&0x1
	BEB l284e
	CLRW %r0
	JMP l2973

l284e:
	MOVB &0xaa,iu_thrb
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	BITB iu_srb,&0x1
	BNEB l2873
	CLRW %r0
	JMP l2973
l2873:
	CMPB &0xaa,iu_thrb
	BEB l2886
	CLRW %r0
	JMP l2973
l2886:
	MOVB &0x20,iu_crb
	MOVB &0x30,iu_crb
	MOVB &0x10,iu_crb
	MOVB iu_mr12b,{uword}%r0
	LLSW3 &0x8,%r0,%r0
	MOVH {uhalf}%r0,{uword}%r0
	MOVB iu_mr12b,{uword}%r1
	MOVW &0xff7f,%r2
	MOVH {uhalf}%r2,{uword}%r2
	ANDW2 %r2,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ORW2 %r1,%r0
	MOVH %r0,(%fp)
	MOVB &0x10,iu_cra
	MOVB &0x10,iu_crb
	MOVB iu_mr12a,iu_mr12b
	MOVB iu_mr12a,iu_mr12b
	MOVB &0x5,iu_crb
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	MOVB &0x20,iu_thra
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	BITB iu_srb,&0x1
	BEB l2935
	CMPB &0x20,iu_thrb
	BNEB l2935
	MOVW &0x2,%r0
	BRB l2973
l2935:
	MOVB &0x20,iu_crb
	MOVB &0x30,iu_crb
	MOVB &0x10,iu_crb
	MOVH {uhalf}(%fp),{uword}%r0
	LRSW3 &0x8,%r0,%r0
	MOVB %r0,iu_mr12b
	MOVB 1(%fp),iu_mr12b
	MOVB &0x5,iu_crb
	MOVW &0x1,%r0
	BRB l2973

l2973:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################
## Unknown procedure
##

l297c:
	SAVE %r5
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVW &l2ac4,$exchand
	MOVW &l2adc,$inthand
	CLRB *p_access
	CLRB $0x20011f2
	CLRW %r6
	BITB mem_size,&0x1
	BEB l29c2
	MOVW &0x100000,%r8
	MOVW %r8,%r0
	BRB l29cc
l29c2:
	MOVW &mmu_scdl,%r8
	MOVW %r8,%r0
l29cc:
	BITB mem_size,&0x2
	BEB l29d9
	LLSW3 &0x1,%r8,%r8
l29d9:
	CALL (%sp),*p_excret
	.byte	0x2b, 0x7f, 0xf2, 0x11, 0x00, 0x02	# TSTB $0x20011f2 # as adds NOP
	BEB l29ee
	JMP l2a97
l29ee:
	CMPW &INIT,$meminit
	BNEB l2a02
	MOVW 0x2000000(%r8),%r7
l2a02:
	MOVW &FATAL,0x2000000(%r8)
	CMPW &FATAL,0x2000000(%r8)
	BNEB l2a1e
	MOVW &0x1,%r6
l2a1e:
	MOVW %r7,0x2000000(%r8)
	TSTW %r6
	BEB l2a97
	CMPW &0x200000,%r8
	BNEB l2a97
	.byte	0xe8, 0x03, 0x48, 0x40	# MULW3 &0x3,%r8,%r0
	DIVW2 &0x4,%r0
	MOVW %r0,%r8
	LLSW3 &0x1,%r8,%r0
	MOVW %r0,%r5
	CLRB $0x20011f2
	CALL (%sp),*p_excret
	.byte	0x2b, 0x7f, 0xf2, 0x11, 0x00, 0x02	# TSTB $0x20011f2
	BNEB l2a97
	CMPW &INIT,$meminit
	BNEB l2a6f
	MOVW 0x2000000(%r5),%r7
l2a6f:
	MOVW &FATAL,0x2000000(%r5)
	CMPW &FATAL,0x2000000(%r5)
	BNEB l2a8f
	MOVW &0x200000,%r8
l2a8f:
	MOVW %r7,0x2000000(%r5)
l2a97:
	MOVW &l65a4,$exchand
	MOVW &l6504,$inthand
	LLSW3 %r6,%r8,%r0
	BRB l2ab5
l2ab5:
	MOVAW -8(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %r6
	POPW %r5
	POPW %fp
	RET

################################################################################

l2ac4:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVB &0x1,$0x20011f2
	MOVAW -24(%fp),%sp
	POPW %fp
	RET


################################################################################

l2adc:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVW &symtell,12(%pcbp)
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP
	NOP

################################################################################
## Exception Return Point Routine (excret)
##

excret:
#l2af8:
	MOVW -8(%sp),$0x20011fc
	RET
	NOP
	NOP

################################################################################
## Unknown Routine
##
l2b04:
	SAVE %fp
	.byte	0x9c, 0x4f, 0xb8, 0x01, 0x00, 0x00, 0x4c	# ADDW2 &0x1b8,%sp
l2b0d:
	PUSHW &nvram_base+fw_nvr_dname
	PUSHAW (%fp)
	PUSHW &0x2d
	CALL -12(%sp),rnvram

## printf ("\nEnter name of program to execute [ %s ]: ")
	PUSHW &l62c
	PUSHAW (%fp)
	CALL -8(%sp),printf

	PUSHW &0x0
	CALL -4(%sp),*p_brkinh
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	CALL -4(%sp),gets
	CMPW &-1,%r0
	BNEB l2b6e
	PUSHW &0x1
	CALL -4(%sp),*p_brkinh

## printf ("\n")
	PUSHW &l657
	CALL -4(%sp),printf
	JMP l3aab
l2b6e:
	PUSHW &0x1
	CALL -4(%sp),*p_brkinh
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l659
	CALL -8(%sp),strcmp
	TSTW %r0
	BEB l2b9a
	JMP l2c6b


l2b9a:
## printf ("\nenter old password: ")
	PUSHW &l660
	CALL -4(%sp),printf

	PUSHAW 80(%fp)
	CALL -4(%sp),0xf09(%pc)
	TSTW %r0
	BNEB l2bba
	CALL (%sp),0xf59(%pc)
l2bba:
	PUSHW &nvram_base+0x00
	PUSHAW 90(%fp)
	PUSHW &0x9
	CALL -12(%sp),rnvram
	PUSHAW 80(%fp)
	PUSHAW 90(%fp)
	CALL -8(%sp),strcmp
	TSTW %r0
	BEB l2be4
	CALL (%sp),0xf2f(%pc)

l2be4:
## printf ("\nenter new password: ")
	PUSHW &l676
	CALL -4(%sp),printf

	PUSHAW (%fp)
	CALL -4(%sp),0xec0(%pc)
	TSTW %r0
	BNEB l2c03
	CALL (%sp),0xf10(%pc)

l2c03:
## printf ("\nconfirmation: ")
	PUSHW &l68c
	CALL -4(%sp),printf

	PUSHAW 80(%fp)
	CALL -4(%sp),0xea0(%pc)
	TSTW %r0
	BNEB l2c23
	CALL (%sp),0xef0(%pc)
l2c23:
	PUSHAW 80(%fp)
	PUSHAW (%fp)
	CALL -8(%sp),strcmp
	TSTW %r0
	BEB l2c39
	CALL (%sp),0xeda(%pc)

l2c39:
## printf ("\n")
	PUSHW &l69c
	CALL -4(%sp),printf

	PUSHAW (%fp)
	PUSHW &nvram_base+0x00
	PUSHAW (%fp)
	CALL -4(%sp),$0x7f98
	INCW %r0
	PUSHW %r0
	CALL -12(%sp),wnvram
	JMP l3aa8

l2c6b:
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l69e	# "newkey"
	CALL -8(%sp),strcmp
	TSTW %r0
	BEB l2c8d
	JMP l2d52

l2c8d:
## printf ("\nCreating a floppy key to enable clearing of saved NVRAM information.\n\n")
	PUSHW &l6a5
	CALL -4(%sp),printf

	CLRB (%fp)
	BRB l2cc4

l2ca0:
## printf ("Insert a formatted floppy, then type 'go' (q to quit): ")
	PUSHW &l6ef
	CALL -4(%sp),printf

	PUSHAW (%fp)
	CALL -4(%sp),gets
	CMPB &0x71,(%fp)
	BNEB l2cc4
	JMP l3aab
l2cc4:
	PUSHAW (%fp)
	PUSHW &l6ec	# "go"
	CALL -8(%sp),strcmp
	TSTW %r0
	BNEB l2ca0
	ADDW3 &0x3,p_serno,%r0
	MOVB (%r0),90(%fp)
	ADDW3 &0x7,p_serno,%r0
	MOVB (%r0),91(%fp)
	ADDW3 &0xb,p_serno,%r0
	MOVB (%r0),92(%fp)
	ADDW3 &0xf,p_serno,%r0
	MOVB (%r0),93(%fp)
	PUSHW &0x0
	PUSHAW 90(%fp)
	PUSHW &0x1
	PUSHW &0x3
	CALL -16(%sp),fd_acs
	TSTW %r0
	BNEB l2d3e
	ORW2 &0x20,$0x200085c
	CALL (%sp),$0x5de0
	PUSHW &FATAL
	CALL -4(%sp),$0x6322

l2d3e:
## printf ("\nCreation of floppy key complete\n\n")
	PUSHW &l727	
	CALL -4(%sp),printf

	JMP l3aa8

l2d52:
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l74a	# "sysdump"
	CALL -8(%sp),strcmp
	TSTW %r0
	BNEB l2d89
	CALL (%sp),$0x2004000
	PUSHW &FATAL
	CALL -4(%sp),$0x6322
	JMP l3aa8
l2d89:
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l752	# "version"
	CALL -8(%sp),strcmp
	TSTW %r0
	BEB l2dab
	JMP l2e38

l2dab:
## printf ("\nCreated: %s\n", "05/31/85")
	PUSHW &l75a
	PUSHW &l1158	# "05/31/85"
	CALL -8(%sp),printf

## printf ("Issue: %08lx")
	PUSHW &l768
	PUSHW $0x7ff0
	CALL -8(%sp),printf

## printf ("Release: %s\nLoad: %s\n", "1.2.1", "PF3")
	PUSHW &l776
	PUSHW &l1168	# "1.2.1"
	PUSHW &l1164	# "PF3"
	CALL -12(%sp),printf

## printf ("Serial Number: %08lx\n\n")
	PUSHW &l78c	# "Serial Number: %08lx\n\n"

	MOVB $0x7ff3,{uword}%r0
	LLSW3 &0x8,%r0,%r0
	MOVB $0x7ff7,{uword}%r1
	ORW2 %r1,%r0
	LLSW3 &0x8,%r0,%r0
	MOVB $0x7ffb,{uword}%r1
	ORW2 %r1,%r0
	LLSW3 &0x8,%r0,%r0
	MOVB $0x7fff,{uword}%r1
	ORW2 %r1,%r0
	PUSHW %r0

	CALL -8(%sp),printf




	JMP l3aa8
l2e38:
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l7a3	# "q"
	CALL -8(%sp),strcmp
	TSTW %r0
	BNEB l2e5a
	JMP l3aab
l2e5a:
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l7a5	# "edt"
	CALL -8(%sp),strcmp
	TSTW %r0
	BNEB l2e83
	CALL (%sp),l4e14
	JMP l3aa8
l2e83:
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l7a9	# ""error info"
	CALL -8(%sp),strcmp
	TSTW %r0
	BNEB l2eac
	CALL (%sp),$0x5fe6
	JMP l3aa8
l2eac:
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l7b4	# "baud"
	CALL -8(%sp),strcmp
	TSTW %r0
	BNEB l2ed5
	CALL (%sp),$0x3fcc
	JMP l3aa8
l2ed5:
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l7b9	# "?"
	CALL -8(%sp),strcmp
	TSTW %r0
	BNEB l2f21

## printf "\nEnter an executable or system file, a directory name,\n"
	PUSHW &l7bb
	CALL -4(%sp),printf

## printf ("or one of the possible firmware program names:\n\n"
	PUSHW &l7f3
	CALL -4(%sp),printf

## printf ("baud    edt    newkey    passwd    sysdump    version    q(uit)\n\n")
	PUSHW &l824
	CALL -4(%sp),printf

	JMP l3aa8
l2f21:
	ADDW3 &0x2,p_cmdqueue,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds NOP
	BNEB l2f41
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHAW (%fp)
	CALL -8(%sp),$0x7fb0
l2f41:
	CLRH 0xb4(%fp)
	BRB l2fa4
l2f48:
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb4(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	CLRH (%r0)
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb4(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	CLRH 2(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb4(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	CLRH 4(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb4(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	CLRB 6(%r0)
	INCH 0xb4(%fp)
l2fa4:
	CMPH &0x10,0xb4(%fp)
	BLB l2f48
	CLRB 0xac(%fp)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
	ADDW3 &0x8,p_edt,%r0
	ADDW3 &0x2,(%r0),%r0
	PUSHW %r0
	CALL -8(%sp),$0x7fb0
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH &0x1,2(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),%r1
	INCB 0xac(%fp)
	MOVB %r1,{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	CLRH (%r0)
	MOVB $0x2000860,{uword}%r0
	JMP l31b5
l301f:
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
	ADDW3 &0x8,p_edt,%r0
	ADDW3 &0xe,(%r0),%r0
	PUSHW %r0
	CALL -8(%sp),$0x7fb0
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH &0x1,2(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),%r1
	INCB 0xac(%fp)
	MOVB %r1,{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH &0x1,(%r0)
	JMP l31c7
l3087:
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
	ADDW3 &0x8,p_edt,%r0
	ADDW3 &0x1a,(%r0),%r0
	PUSHW %r0
	CALL -8(%sp),$0x7fb0
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH &0x1,2(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),%r1
	INCB 0xac(%fp)
	MOVB %r1,{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH &0x2,(%r0)
	JMP l31c7
l30ef:
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
	ADDW3 &0x8,p_edt,%r0
	ADDW3 &0xe,(%r0),%r0
	PUSHW %r0
	CALL -8(%sp),$0x7fb0
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH &0x1,2(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),%r1
	INCB 0xac(%fp)
	MOVB %r1,{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH &0x1,(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
	ADDW3 &0x8,p_edt,%r0
	ADDW3 &0x1a,(%r0),%r0
	PUSHW %r0
	CALL -8(%sp),$0x7fb0
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH &0x1,2(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),%r1
	INCB 0xac(%fp)
	MOVB %r1,{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH &0x2,(%r0)
	BRB l31c7
l31b5:
	CMPW %r0,&0x1
	BEH l301f
	CMPW %r0,&0x2
	BEH l3087
	CMPW %r0,&0x3
	BEH l30ef
l31c7:
	MOVH &0x1,0xb4(%fp)
	JMP l3339
l31d3:
	MOVH 0xb4(%fp),{word}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x0,&0x7,4(%r0),%r0
	CMPW &0x0,%r0
	BNEB l31f5
	JMP l3293
l31f5:
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
	MOVH 0xb4(%fp),{word}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	ADDW2 &0xc,%r0
	PUSHW %r0
	CALL -8(%sp),$0x7fb0
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	CLRH 2(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH 0xb4(%fp),{word}%r1
	LLSW3 &0x5,%r1,%r1
	ADDW2 p_edt,%r1
	EXTFW &0x3,&0xc,(%r1),%r1
	MOVH %r1,4(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),%r1
	INCB 0xac(%fp)
	MOVB %r1,{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH 0xb4(%fp),(%r0)
	JMP l3334
l3293:
	MOVH 0xb4(%fp),{word}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	.byte	0x2b, 0xc0, 0x0c	# TSTB 12(%r0)
	BEB l32d1
	MOVH 0xb4(%fp),{word}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	ADDW2 &0xc,%r0
	PUSHW %r0
	PUSHW &l866	# "*VOID*"
	CALL -8(%sp),strcmp
	TSTW %r0
	BNEB l3334
l32d1:
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	CLRH 2(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH 0xb4(%fp),{word}%r1
	LLSW3 &0x5,%r1,%r1
	ADDW2 p_edt,%r1
	EXTFW &0x3,&0xc,(%r1),%r1
	MOVH %r1,4(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xac(%fp),%r1
	INCB 0xac(%fp)
	MOVB %r1,{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH 0xb4(%fp),(%r0)
l3334:
	INCH 0xb4(%fp)
l3339:
	MOVH 0xb4(%fp),{word}%r0
	MOVB *p_num_edt,{uword}%r1
	CMPW %r1,%r0
	BLH l31d3

## printf ("\tPossible load devices are:\n\n")
	PUSHW &l86d
	CALL -4(%sp),printf

## printf ("Option Number    Slot     Name\n")
	PUSHW &l88b
	CALL -4(%sp),printf

## printf ("------------------------------\n")
	PUSHW &l8ab
	CALL -4(%sp),printf

	CLRH 0xb4(%fp)
	JMP l3413

l3382:

## printf ("%2d         %2d")
	PUSHW &l8d4
	MOVH 0xb4(%fp),{word}%r0
	PUSHW %r0
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb4(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH {uhalf}4(%r0),{uword}%r0
	PUSHW %r0
	CALL -12(%sp),printf

	MOVAW 0xb8(%fp),%r0
	MOVH 0xb4(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
	PUSHW &l8ea	# "*VOID*"
	CALL -8(%sp),strcmp
	TSTW %r0
	BEB l3400


## printf ("     %10s\n")
	PUSHW &l8f1

	MOVAW 0xb8(%fp),%r0
	MOVH 0xb4(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0

	CALL -8(%sp),printf


l3400:
## printf ("\n")
	PUSHW &l8fb
	CALL -4(%sp),printf

	INCH 0xb4(%fp)
l3413:
	MOVH 0xb4(%fp),{word}%r0
	MOVB 0xac(%fp),{uword}%r1
	CMPW %r1,%r0
	BLUH l3382
	PUSHW &nvram_base+fw_nvr_bdev
	ADDW3 &0x1,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &0x1
	CALL -12(%sp),rnvram
	CLRB 0xaa(%fp)
	CLRH 0xb4(%fp)
	JMP l34d5
l344f:
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb4(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH {uhalf}2(%r0),{uword}%r0
	BEB l349b
	ADDW3 &0x1,p_cmdqueue,%r0
	MOVB (%r0),{uword}%r0
	MOVAW 0xb8(%fp),%r1
	MOVH 0xb4(%fp),{word}%r2
	LLSW3 &0x4,%r2,%r2
	ADDW2 %r2,%r1
	MOVH {uhalf}(%r1),{uword}%r1
	CMPW %r1,%r0
	BNEB l3499
	MOVB &0x1,0xaa(%fp)
	BRB l34e7
l3499:
	BRB l34d0
l349b:
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb4(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH {uhalf}4(%r0),{uword}%r0
	ADDW3 &0x1,p_cmdqueue,%r1
	MOVB (%r1),{uword}%r1
	LRSW3 &0x4,%r1,%r1
	CMPW %r1,%r0
	BNEB l34d0
	MOVB &0x1,0xaa(%fp)
	BRB l34e7
l34d0:
	INCH 0xb4(%fp)
l34d5:
	MOVH 0xb4(%fp),{word}%r0
	MOVB 0xac(%fp),{uword}%r1
	CMPW %r1,%r0
	BLUH l344f
l34e7:
	.byte	0x2b, 0xa9, 0xaa, 0x00	# TSTB 0xaa(%fp)
	BNEB l34f4
	CLRB 0xaf(%fp)
	BRB l34fc
l34f4:
	MOVB 0xb5(%fp),0xaf(%fp)
l34fc:

## printf ("\nEnter Load Device Option Number ")
	PUSHW &l8fd
	CALL -4(%sp),printf

## printf ("[%d")
	PUSHW &l91f

	MOVB 0xaf(%fp),{uword}%r0
	PUSHW %r0

	CALL -8(%sp),printf


	MOVAW 0xb8(%fp),%r0
	MOVB 0xaf(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
	PUSHW &l923	# "*VOID*
	CALL -8(%sp),strcmp
	TSTW %r0
	BEB l356e

# printf (" (%s)")
	PUSHW &l92a

	MOVAW 0xb8(%fp),%r0
	MOVB 0xaf(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0

	CALL -8(%sp),printf


l356e:

## printf ("]: ")
	PUSHW &l930
	CALL -4(%sp),printf

	PUSHW &0x0
	CALL -4(%sp),*p_brkinh
	PUSHAW 90(%fp)
	CALL -4(%sp),gets
	CMPW &-1,%r0
	BNEB l35b4
	PUSHW &0x1
	CALL -4(%sp),*p_brkinh

## printf ("\n");
	PUSHW &l934
	CALL -4(%sp),printf

	JMP l3aab
l35b4:
	PUSHW &0x1
	CALL -4(%sp),*p_brkinh
	.byte	0x83, 0xa9, 0xaa, 0x00	# CLRB 0xaa(%fp) # as adds NOP
	NOP
	.byte	0x2b, 0xc9, 0x5a	# TSTB 90(%fp)
	BEB l3625
	CLRH 0xb4(%fp)
	BRB l35f0
l35cf:
	PUSHAW 90(%fp)
	CALL -4(%sp),0x568(%pc)
	MOVH 0xb4(%fp),{word}%r1
	CMPW %r0,%r1
	BNEB l35eb
	MOVB &0x1,0xaa(%fp)
	BRB l3601
l35eb:
	INCH 0xb4(%fp)
l35f0:
	MOVH 0xb4(%fp),{word}%r0
	MOVB 0xac(%fp),{uword}%r1
	CMPW %r1,%r0
	BLUB l35cf
l3601:
	.byte	0x2b, 0xa9, 0xaa, 0x00	# TSTB 0xaa(%fp) # as adds NOP
	BNEB l361b

## printf ("\n%s is not a valid option number.\n")
	PUSHW &l936

	PUSHAW 90(%fp)

	CALL -8(%sp),printf


	BRH l34fc
l361b:
	MOVB 0xb5(%fp),0xae(%fp)
	BRB l362d
l3625:
	MOVB 0xaf(%fp),0xae(%fp)
l362d:
	MOVAW 0xb8(%fp),%r0
	MOVB 0xae(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH {uhalf}2(%r0),{uword}%r0
	BEB l366c
	ADDW3 &0x1,p_cmdqueue,%r0
	MOVAW 0xb8(%fp),%r1
	MOVB 0xae(%fp),{uword}%r2
	LLSW3 &0x4,%r2,%r2
	ADDW2 %r2,%r1
	MOVB 1(%r1),(%r0)
	JMP l3a78
l366c:
	CMPB 0xaf(%fp),0xae(%fp)
	BNEB l3689
	ADDW3 &0x1,p_cmdqueue,%r0
	ANDB3 &0xf,(%r0),%r0
	MOVB %r0,0xad(%fp)
	BRB l368e
l3689:
	CLRB 0xad(%fp)
l368e:
	ADDW3 &0x1,p_cmdqueue,%r0
	MOVAW 0xb8(%fp),%r1
	MOVB 0xae(%fp),{uword}%r2
	LLSW3 &0x4,%r2,%r2
	ADDW2 %r2,%r1
	MOVH {uhalf}4(%r1),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	MOVB %r1,(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVB 0xae(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH (%r0),0xb4(%fp)
	CLRH 0xb6(%fp)
	BRB l3731
l36d5:
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb6(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	CLRH (%r0)
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb6(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	CLRH 2(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb6(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	CLRH 4(%r0)
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb6(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	CLRB 6(%r0)
	INCH 0xb6(%fp)
l3731:
	CMPH &0x10,0xb6(%fp)
	BLB l36d5
	MOVB &0x1,0xab(%fp)
	MOVH 0xb4(%fp),{word}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x3,&0x0,4(%r0),%r0
	MOVB %r0,0xac(%fp)
	.byte	0x2b, 0xa9, 0xac, 0x00	# TSTB 0xac(%fp) # as adds NOP
	BNEB l376c
	MOVB &0xf,0xac(%fp)
	CLRB 0xab(%fp)
l376c:
	CLRH 0xb6(%fp)
	BRB l37d1
l3773:
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb6(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
	MOVH 0xb4(%fp),{word}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	.byte	0xea, 0x0c, 0xa9, 0xb6, 0x00, 0x41  	# MULH3 &0xc,0xb6(%fp),%r1
	ADDW3 %r1,8(%r0),%r0
	ADDW2 &0x2,%r0
	PUSHW %r0
	CALL -8(%sp),$0x7fb0
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb6(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH 0xb6(%fp),4(%r0)
	INCH 0xb6(%fp)
l37d1:
	MOVH 0xb6(%fp),{word}%r0
	MOVB 0xac(%fp),{uword}%r1
	CMPW %r1,%r0
	BLUB l3773


## printf ("Possible subdevices are:\n\n")
	PUSHW &l959
	CALL -4(%sp),printf

## printf ("Option Number   Subdevice    Name\n")
	PUSHW &l974
	CALL -4(%sp),printf

# printf ("----------------------------\n")
	PUSHW &l997
	CALL -4(%sp),printf
	CLRH 0xb6(%fp)
	JMP l38ae
l3817:

## printf ("      %2d         %2d")
	PUSHW &l9c5

	MOVH 0xb6(%fp),{word}%r0
	PUSHW %r0

	MOVAW 0xb8(%fp),%r0
	MOVH 0xb6(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH {uhalf}4(%r0),{uword}%r0
	PUSHW %r0

	CALL -12(%sp),printf


	MOVAW 0xb8(%fp),%r0
	MOVH 0xb6(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
	PUSHW &l9dc	# "*VOID*"
	CALL -8(%sp),strcmp
	TSTW %r0
	BEB l389b
	.byte	0x2b, 0xa9, 0xab, 0x00	# TSTB 0xab(%fp)
	BEB l389b

## printf ("         %10s")
	PUSHW &l9e3

	MOVAW 0xb8(%fp),%r0
	MOVH 0xb6(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0

	CALL -8(%sp),printf

l389b:

## printf ("\n")
	PUSHW &l9f1

	CALL -4(%sp),printf


	INCH 0xb6(%fp)
l38ae:
	MOVH 0xb6(%fp),{word}%r0
	MOVB 0xac(%fp),{uword}%r1
	CMPW %r1,%r0
	BLUH l3817
	CLRB 0xaa(%fp)
	CLRH 0xb6(%fp)
	BRB l38fc
l38cc:
	MOVAW 0xb8(%fp),%r0
	MOVH 0xb6(%fp),{word}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	MOVH {uhalf}4(%r0),{uword}%r0
	MOVB 0xad(%fp),{uword}%r1
	CMPW %r1,%r0
	BNEB l38f7
	MOVB &0x1,0xaa(%fp)
	BRB l390d
l38f7:
	INCH 0xb6(%fp)
l38fc:
	MOVH 0xb6(%fp),{word}%r0
	MOVB 0xac(%fp),{uword}%r1
	CMPW %r1,%r0
	BLUB l38cc
l390d:
	.byte	0x2b, 0xa9, 0xaa, 0x00	# TSTB 0xaa(%fp)
	BNEB l391a
	CLRB 0xaf(%fp)
	BRB l3922
l391a:
	MOVB 0xb7(%fp),0xaf(%fp)
l3922:

## printf ("Enter Subdevice Option Number ")
	PUSHW &l9f3
	CALL -4(%sp),printf

## printf ("[%d")
	PUSHW &la13

	MOVB 0xaf(%fp),{uword}%r0
	PUSHW %r0

	CALL -8(%sp),printf


	MOVAW 0xb8(%fp),%r0
	MOVB 0xaf(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
	PUSHW &la17	# "*VOID*"
	CALL -8(%sp),strcmp
	TSTW %r0
	BEB l399a
	.byte	0x2b, 0xa9, 0xab, 0x00	# TSTB 0xab(%fp) # as adds NOP
	BEB l399a
	PUSHW &la1e	# "(%s)"
	MOVAW 0xb8(%fp),%r0
	MOVB 0xaf(%fp),{uword}%r1
	LLSW3 &0x4,%r1,%r1
	ADDW2 %r1,%r0
	ADDW2 &0x6,%r0
	PUSHW %r0
l3992:
	CALL -8(%sp),printf
l399a:

## printf ("]:")
	PUSHW &la23
	CALL -4(%sp),printf

	PUSHW &0x0
	CALL -4(%sp),*p_brkinh
	PUSHAW 90(%fp)
	CALL -4(%sp),gets
	CMPW &-1,%r0
	BNEB l39e0
	PUSHW &0x1
	CALL -4(%sp),*p_brkinh

## printf ("\n")
	PUSHW &la27
	CALL -4(%sp),printf

	JMP l3aab
l39e0:
	PUSHW &0x1
	CALL -4(%sp),*p_brkinh
	CLRB 0xaa(%fp)
	.byte	0x2b, 0xc9, 0x5a	# TSTB 90(%fp)
	BEB l3a51
	CLRH 0xb6(%fp)
	BRB l3a1c
l39fb:
	PUSHAW 90(%fp)
	CALL -4(%sp),0x13c(%pc)
	MOVH 0xb6(%fp),{word}%r1
	CMPW %r0,%r1
	BNEB l3a17
	MOVB &0x1,0xaa(%fp)
	BRB l3a2d
l3a17:
	INCH 0xb6(%fp)
l3a1c:
	MOVH 0xb6(%fp),{word}%r0
	MOVB 0xac(%fp),{uword}%r1
	CMPW %r1,%r0
	BLUB l39fb
l3a2d:
	.byte	0x2b, 0xa9, 0xaa, 0x00	# TSTB 0xaa(%fp)
	BNEB l3a47

## printf ("\n%s is not a valid option number\n")
	PUSHW &la29
	PUSHAW 90(%fp)
	CALL -8(%sp),printf
	BRH l3922
l3a47:
	MOVB 0xb7(%fp),0xae(%fp)
	BRB l3a59
l3a51:
	MOVB 0xaf(%fp),0xae(%fp)
l3a59:
	ADDW3 &0x1,p_cmdqueue,%r0
	MOVAW 0xb8(%fp),%r1
	MOVB 0xae(%fp),{uword}%r2
	LLSW3 &0x4,%r2,%r2
	ADDW2 %r2,%r1
	ORB2 5(%r1),(%r0)
l3a78:
	MOVB &0x1,*p_cmdqueue
	CALL (%sp),$0x6970
	TSTW %r0
	BNEB l3aa8
## Sets the "Boot Failure" flag in 0x200085c
	ORW2 &0x4,$0x200085c
	CALL (%sp),$0x5de0
	PUSHW &FATAL
	CALL -4(%sp),$0x6322
l3aa8:
	BRH l2b0d
l3aab:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP


################################################################################
## Unknown Routine - maybe get input of some kind? It calls 0x4484,
## which checks to see if a character is available as input.

l3ab4:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	CLRH (%fp)
	BRB l3af7
l3ac2:
	BRB l3ac4
l3ac4:
	CALL (%sp),getstat
	MOVB %r0,*0(%ap)
	TSTB %r0
	BEB l3ac4
	CMPB &0xd,*0(%ap)
	BEB l3ae0
	CMPB &0xa,*0(%ap)
	BNEB l3af1
l3ae0:
	.byte	0x2a, 0x59	# TSTH (%fp) # as adds NOP
	BNEB l3ae8
	CLRW %r0
	BRB l3b05
l3ae8:
	CLRB *0(%ap)
	MOVW &0x1,%r0
	BRB l3b05
l3af1:
	INCW (%ap)
	INCH (%fp)
l3af7:
	CMPH &0x8,(%fp)
	BLB l3ac2
	CLRB *0(%ap)
	MOVW &0x1,%r0
	BRB l3b05
l3b05:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP


################################################################################

l3b0e:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp

## printf ("\nSORRY!\n")
	PUSHW &la4c
	CALL -4(%sp),printf
	PUSHW &REENTRY
	CALL -4(%sp),$0x6322
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	SAVE %fp
	.byte	0x9c, 0x4f, 0x08, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x8,%sp
	CLRH 4(%fp)
	MOVH 4(%fp),2(%fp)
	BRB l3b73
l3b4c:
	CMPB &0x30,(%fp)
	BLB l3b63
	CMPB &0x39,(%fp)
	BGB l3b63
	MOVB (%fp),{uhalf}%r0
	SUBH2 &0x30,%r0
	MOVH %r0,4(%fp)
	BRB l3b68
l3b63:
	MOVW &-1,%r0
	BRB l3b87
l3b68:
	.byte	0xea, 0x0a, 0x62, 0x40	# MULH3 &0xa,2(%fp),%r0
	ADDH2 4(%fp),%r0
	MOVH %r0,2(%fp)
l3b73:
	MOVW (%ap),%r0
	INCW (%ap)
	MOVB (%r0),(%fp)
	.byte	0x2b, 0x59	# TSTB (%fp)
	BNEB l3b4c
	MOVH 2(%fp),{word}%r0
	BRB l3b87
l3b87:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################
## Unknown Procedure
##

l3b90:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	ADDW3 &0x4,p_fl_cons,%r0
	CLRB (%r0)
	PUSHW &nvram_base+fw_nvr_cons_def
	ADDW3 &0x3,p_fl_cons,%r0
	PUSHW %r0
	PUSHW &0x1
## Call 'rnvram'
	CALL -12(%sp),rnvram
	CMPW &0x1,%r0
	BNEB l3c12
	ADDW3 &0x2,p_fl_cons,%r0
	ADDW3 &0x3,p_fl_cons,%r1
	ANDB3 &0xf0,(%r1),%r1
	LRSW3 &0x4,%r1,%r1
	MOVB %r1,(%r0)
	ADDW3 &0x3,p_fl_cons,%r0
	ANDB2 &0xf,(%r0)
	CMPW &0x8000,p_serno
	BLEB l3c10
	ADDW3 &0x3,p_fl_cons,%r0
	CLRB (%r0)
	ADDW3 &0x2,p_fl_cons,%r0
	CLRB (%r0)
l3c10:
	BRB l3c28
l3c12:
	ADDW3 &0x2,p_fl_cons,%r0
	CLRB (%r0)
	ADDW3 &0x3,p_fl_cons,%r0
	CLRB (%r0)
l3c28:
	PUSHW &nvram_base+unx_nvr_consflg
	PUSHAW (%fp)
	PUSHW &0x2
	CALL -12(%sp),rnvram
	TSTW %r0
	BEB l3c45
	MOVH {uhalf}(%fp),{uword}%r0
	BNEB l3c5d
l3c45:
	MOVH &0x4bd,(%fp)
	PUSHAW (%fp)
	PUSHW &nvram_base+unx_nvr_consflg
	PUSHW &0x2
	CALL -12(%sp),wnvram
l3c5d:
	MOVH (%fp),*p_fl_cons
	ADDW3 &0x2,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds NOP
	BEB l3c77
	MOVH &0x4bd,(%fp)
l3c77:
	MOVH {uhalf}(%fp),{uword}%r0
	PUSHW %r0
	PUSHW &iu_mr12a
	CALL -8(%sp),l3e84
	ADDW3 &0x2,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds NOP
	BNEB l3caf
	ADDW3 &0x3,p_fl_cons,%r0
	CMPB &0x1,(%r0)
	BNEB l3caf
	MOVH *p_fl_cons,(%fp)
	BRB l3ce2
l3caf:
	PUSHW &nvram_base+fw_nvr_link
	PUSHAW (%fp)
	PUSHW &0x2
	CALL -12(%sp),rnvram
	TSTW %r0
	BEB l3ccc
	MOVH {uhalf}(%fp),{uword}%r0
	BNEB l3ce2
l3ccc:
	MOVH &0x3d,(%fp)
	PUSHAW (%fp)
	PUSHW &nvram_base+fw_nvr_link
	PUSHW &0x2
	CALL -12(%sp),wnvram
l3ce2:
	MOVH {uhalf}(%fp),{uword}%r0
	PUSHW %r0
	PUSHW &iu_mr12b
	CALL -8(%sp),l3e84
	ADDW3 &0x2,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds NOP
	BNEB l3d6c
	ADDW3 &0x3,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds NOP
	BNEB l3d1b
	MCOMB iu_inprt,%r0
	BITW %r0,&0x1
	BNEB l3d34
l3d1b:
	ADDW3 &0x3,p_fl_cons,%r0
	CMPB &0x1,(%r0)
	BNEB l3d6c
	MCOMB iu_inprt,%r0
	BITW %r0,&0x2
	BEB l3d6c
l3d34:
	ADDW3 &0x4,p_fl_cons,%r0
	MOVB &0x1,(%r0)
	ADDW3 &0x3,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds NOP
	BEB l3d5d
	MOVW &iu_mr12b,%r0
	MOVW %r0,*p_console
	BRB l3d6c
l3d5d:
	MOVW &iu_mr12a,%r0
	MOVW %r0,*p_console
l3d6c:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################
## 'setbaud' - Routine to set baud rate. This is a full process,
## ending with a "RETPS". It makes me wonder if this is a full-on
## exception handler? If so, who calls it? It doesn't appear in any
## interrupt vector tables.

setbaud:
#l3d74:
	SAVE %r8
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	MOVH &0x1,%r8
	BRB l3da3
l3d82:
	CMPH &0x10,%r8
	BLUB l3da1

## printf (# "Unsupported Baud Rate: %d\n")
	PUSHW &lad8

	MOVH 2(%ap),{word}%r0
	PUSHW %r0

	CALL -8(%sp),printf


	JMP l3e7a
l3da1:
	INCH %r8
l3da3:
	MOVH %r8,{word}%r0
	LLSW3 &0x3,%r0,%r0
	CMPH 2(%ap),la58(%r0)
	BNEB l3d82
	CMPW &iu_mr12b,4(%ap)
	BNEB l3dec
	MOVH %r8,{word}%r0
	LLSW3 &0x3,%r0,%r0
	MOVB la5a(%r0),{uhalf}%r0
	ORH2 &0x30,%r0
	MOVH %r0,(%fp)
	PUSHAW (%fp)
	PUSHW &nvram_base+fw_nvr_link
	PUSHW &0x2
	CALL -12(%sp),wnvram
	JMP l3e6b
l3dec:
	PUSHW &nvram_base+unx_nvr_consflg
	PUSHAW (%fp)
	PUSHW &0x2
	CALL -12(%sp),rnvram
	MOVH {uhalf}(%fp),{uword}%r0
	BEB l3e3b
	MOVH {uhalf}(%fp),{uword}%r0
	MOVW &0xfff0,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ANDW2 %r1,%r0
	MOVH %r0,(%fp)
	MOVH {uhalf}(%fp),{uword}%r0
	MOVH %r8,{word}%r1
	LLSW3 &0x3,%r1,%r1
	MOVB la5a(%r1),{uword}%r1
	ORW2 %r1,%r0
	MOVH %r0,(%fp)
	BRB l3e59
l3e3b:
	MOVH %r8,{word}%r0
	LLSW3 &0x3,%r0,%r0
	MOVB la5a(%r0),{uhalf}%r0
	ORH2 &0x430,%r0
	ORH2 &0x80,%r0
	MOVH %r0,(%fp)
l3e59:
	PUSHAW (%fp)
	PUSHW &nvram_base+unx_nvr_consflg
	PUSHW &0x2
	CALL -12(%sp),wnvram
l3e6b:
	MOVH {uhalf}(%fp),{uword}%r0
	PUSHW %r0
	PUSHW 4(%ap)
	.byte	0x2c, 0xcc, 0xf8, 0xaf, 0x10, 0x00	# CALL -8(%sp),0x10(%pc)
l3e7a:
	MOVAW -20(%fp),%sp
	POPW %r8
	POPW %fp
	RET
	NOP

################################################################################

l3e84:
	SAVE %r7
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVH &0x1,%r8
	BRB l3ea7
l3e92:
	MOVH {uhalf}%r8,{uword}%r0
	CMPW &0x10,%r0
	BLUB l3ea5
	MOVH &0xd,%r8
	MOVH &0x30,2(%ap)
	BRB l3ec5
l3ea5:
	INCH %r8
l3ea7:
	MOVH {uhalf}%r8,{uword}%r0
	LLSW3 &0x3,%r0,%r0
	MOVB la5a(%r0),{uword}%r0
	MOVH {uhalf}2(%ap),{uword}%r1
	ANDW2 &0xf,%r1
	CMPW %r1,%r0
	BNEB l3e92
l3ec5:
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x1a,(%r0)
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x20,(%r0)
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x30,(%r0)
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x40,(%r0)
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x70,(%r0)
	MOVH {uhalf}2(%ap),{uword}%r0
	BITW %r0,&0x100
	BEB l3f13
	MOVH {uhalf}2(%ap),{uword}%r0
	BITW %r0,&0x200
	BEB l3f0c
	MOVW &0x4,%r0
	BRB l3f0e
l3f0c:
	CLRW %r0
l3f0e:
	ORW2 &0x0,%r0
	BRB l3f16
l3f13:
	MOVW &0x10,%r0
l3f16:
	ORB2 &0x0,%r0
	MOVB %r0,%r7
	MOVH {uhalf}2(%ap),{uword}%r0
	ANDW2 &0x30,%r0
	BRB l3f37
l3f26:
	BRB l3f48
l3f28:
	ORB2 &0x1,%r7
	BRB l3f48
l3f2d:
	ORB2 &0x2,%r7
	BRB l3f48
l3f32:
	ORB2 &0x3,%r7
	BRB l3f48
l3f37:
	CMPW %r0,&0x0
	BEB l3f26
	CMPW %r0,&0x10
	BEB l3f28
	CMPW %r0,&0x20
	BEB l3f2d
	BRB l3f32
l3f48:
	MOVB %r7,*4(%ap)
	MOVH {uhalf}2(%ap),{uword}%r0
	BITW %r0,&0x40
	BEB l3f5d
	MOVW &0xf,%r0
	BRB l3f60
l3f5d:
	MOVW &0x7,%r0
l3f60:
	ORB2 &0x0,%r0
	MOVB %r0,*4(%ap)
	ADDW3 &0x1,4(%ap),%r0
	MOVH {uhalf}%r8,{uword}%r1
	LLSW3 &0x3,%r1,%r1
	MOVB la5b(%r1),(%r0)
	MOVH {uhalf}%r8,{uword}%r0
	LLSW3 &0x3,%r0,%r0
	MOVB la5c(%r0),$0x2001254
	ADDW3 &0x4,4(%ap),%r0
	MOVB $0x2001254,(%r0)
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x15,(%r0)
	MOVB &0x3,iu_sopr
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	ADDW3 &0x3,4(%ap),%r0
	MOVB &0x20,(%r0)
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET
	NOP

################################################################################

l3fcc:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x54, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x54,%sp
	PUSHW &nvram_base+unx_nvr_consflg
	PUSHAW (%fp)
	PUSHW &0x2
	CALL -12(%sp),rnvram

## printf ("Enter new rate [%d]: ")
	PUSHW &laf3

	MOVH {uhalf}(%fp),{uword}%r0
	ANDW2 &0xf,%r0
	LLSW3 &0x3,%r0,%r0
	MOVH la58(%r0),{word}%r0
	PUSHW %r0

	CALL -8(%sp),printf


	PUSHAW 2(%fp)
	CALL -4(%sp),*p_gets
	.byte	0x2b, 0x62	# TSTB 2(%fp) # as adds NOP
	BEB l4053
	PUSHAW 2(%fp)
	PUSHW &lb09	# "%d"
	PUSHAW (%fp)
	CALL -12(%sp),sscanf

## printf (# "Change baud rate to %d\n")
	PUSHW &lb0c

	MOVH {uhalf}(%fp),{uword}%r0
	PUSHW %r0

	CALL -8(%sp),printf


	MOVH {uhalf}(%fp),{uword}%r0
	PUSHW %r0
	PUSHW &iu_mr12a
	.byte	0x2c, 0xcc, 0xf8, 0xaf, 0x27, 0xfd	# CALL -8(%sp),0xfd27(%pc)
l4053:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################

l405c:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################

l406c:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	MOVB timer_latch,(%fp)
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	.byte	0x28, 0x5d	# TSTW (%pcbp)
	NOP
	NOP
	NOP
	NOP

################################################################################

l408a:
	SAVE %fp
	MOVW (%ap),%r2
	MOVW 4(%ap),%r1
	MOVW 8(%ap),%r0
	MOVBLW
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP


################################################################################
## Main interrupt handler during ROM startup. This is pointed at by
## the PCBP at 0x2000bc8 during at least part of ROM startup.
##
## The clever part of this is the call to 0x64ec, which will then call
## whatever function is currently registered at 0x494 p_inthand.
##

l40a0:
	MOVW -4(%isp),%r0
	MOVW (%r0),$pswstore
	MOVW 4(%r0),$pcstore
	MOVB &0x0,$0x2001260
## Call the code that calls the registered handler
	CALL (%sp),$0x64ec
	RETPS


## Interrupt handler 40c6

l40c6:
	MOVW -4(%isp),%r0
	MOVW (%r0),$pswstore
	MOVW 4(%r0),$pcstore
	MOVB &0x8,$0x2001260
	CALL (%sp),$0x64ec
	RETPS

## Interrupt handler 40ec

l40ec:
	MOVW -4(%isp),%r0
	MOVW (%r0),$pswstore
	MOVW 4(%r0),$pcstore
	MOVB &0x9,$0x2001260
	CALL (%sp),$0x64ec
	RETPS

l4112:
	MOVW -4(%isp),%r0
	MOVW (%r0),$pswstore
	MOVW 4(%r0),$pcstore
	MOVB &0xa,$0x2001260
	CALL (%sp),$0x64ec
	RETPS

l4138:
	MOVW -4(%isp),%r0
	MOVW (%r0),$pswstore
	MOVW 4(%r0),$pcstore
	MOVB &0xb,$0x2001260
	CALL (%sp),$0x64ec
	RETPS

l415e:
	MOVW -4(%isp),%r0
	MOVW (%r0),$pswstore
	MOVW 4(%r0),$pcstore
	MOVB &0xc,$0x2001260
	CALL (%sp),$0x64ec
	RETPS

l4184:
	MOVW -4(%isp),%r0
	MOVW (%r0),$pswstore
	MOVW 4(%r0),$pcstore
	MOVB &0xd,$0x2001260
	CALL (%sp),$0x64ec
	RETPS

l41aa:
	MOVW -4(%isp),%r0
	MOVW (%r0),$pswstore
	MOVW 4(%r0),$pcstore
	MOVB &0xe,$0x2001260
	CALL (%sp),$0x64ec
	RETPS

l41d0:
	MOVW -4(%isp),%r0
	MOVW (%r0),$pswstore
	MOVW 4(%r0),$pcstore
	MOVB &0xf,$0x2001260
	CALL (%sp),$0x64ec
	RETPS
	NOP
	NOP

l41f8:
	MOVW -4(%isp),%r0
	MOVW (%r0),$pswstore
	MOVW 4(%r0),$pcstore
	MOVW 28(%r0),$save_r0
	CALL (%sp),$0x6550
	RETPS

################################################################################
## 'demon' - Routine to enter demon without init
##
## This appears to be an interrupt handler, but what?
## It calls 0x6550, which is currently an unknown procedure.

demon:
	MOVW -4(%sp),$pswstore
	MOVW -8(%sp),$pcstore
	MOVW %r0,$save_r0
## Load the PSW with 81E100
	.byte	0x84, 0x4f, 0x00, 0xe1, 0x81, 0x00, 0x4b	# MOVW &symtell,%psw # as adds NOP
## Call unknown procedure at 0x6550
	CALL (%sp),l6550
	MOVW $0x20011fc,-8(%sp)
	.byte	0x84, 0x7f, 0x58, 0x12, 0x00, 0x02, 0x4b	# MOVW $pswstore,%psw # as adds NOP
	RETG

################################################################################
## Unknown Interrupt Handler
##

l4259:
	MOVW %r0,$save_r0
	MOVW -4(%sp),$pswstore
	MOVW -8(%sp),$pcstore
	MOVAW $0x2000e98,%r0
	CALLPS
	MOVW $0x20011fc,-8(%sp)
	.byte	0x84, 0x7f, 0x58, 0x12, 0x00, 0x02, 0x4b	# MOVW $pswstore,%psw # as adds NOP
	RETG

l428e:
	.byte	0x84, 0x4f, 0x00, 0xe1, 0x81, 0x00, 0x4b	# MOVW &symtell,%psw # as adds NOP
	CALL (%sp),$0x6550
	RETPS
	NOP
	NOP

################################################################################

l42a0:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	ADDW3 &0x2,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds #NOP
	BEB l42c8
	ADDW3 &0x4,p_fl_cons,%r0
	CMPB &0x1,(%r0)
	BNEB l42c8
	JMP l4348
l42c8:
	BRB l42d1
l42ca:
	CALL (%sp),$0x62de
l42d1:
	ADDW3 &0x1,(%ap),%r0
	BITB (%r0),&0x1
	BEB l42ca
	CMPW $console,(%ap)
	BNEB l433a
	.byte	0x2b, 0x7f, 0x68, 0x08, 0x00, 0x02	# TSTB $0x2000868 # as adds NOP
	BNEB l433a
	ADDW3 &0x1,(%ap),%r0
	BITB (%r0),&0x80
	BEB l433a
	ADDW3 &0x2,(%ap),%r0
	MOVB &0x40,(%r0)
	ADDW3 &0x2,(%ap),%r0
	MOVB &0x50,(%r0)
	ADDW3 &0x3,(%ap),%r0
	MOVB (%r0),(%fp)
	BRB l432c
l4312:
	ADDW3 &0x2,(%ap),%r0
	MOVB &0x40,(%r0)
	ADDW3 &0x2,(%ap),%r0
	MOVB &0x50,(%r0)
	ADDW3 &0x3,(%ap),%r0
	MOVB (%r0),(%fp)
l432c:
	ADDW3 &0x1,(%ap),%r0
	BITB (%r0),&0x1
	BNEB l4312
	MOVW &-1,%r0
	BRB l4358
l433a:
	ADDW3 &0x3,(%ap),%r0
	MOVB (%r0),(%fp)
	MOVB (%fp),{uword}%r0
	BRB l4358
l4348:
	PUSHW &0x0
	CALL -4(%sp),$0x56f8
	MOVH %r0,{word}%r0
	BRB l4358
l4358:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################
## 'gets' Routine
##

gets:
#l4360:
	SAVE %r7
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	.byte	0x2b, 0xef, 0xc4, 0x04, 0x00, 0x00	# TSTB *p_access
	BNEB l4380
	CALL (%sp),$0x62de
	CLRW %r0
	JMP l4478
l4380:
	MOVW (%ap),%r8
l4383:
	JMP l4455
l4389:
	PUSHW $console
	CALL -4(%sp),l42a0
	MOVW %r0,%r7
	BGEB l43a5
	MOVW &-1,%r0
	JMP l4478
l43a5:
	ANDW3 &0xff,%r7,{ubyte}%r0
	MOVB %r0,*0(%ap)
	CMPB &0xa,*0(%ap)
	BEB l43bd
	CMPB &0xd,*0(%ap)
	BNEB l43e7
l43bd:
	CLRB *0(%ap)
	PUSHW &0xa
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l43de
	MOVW &-1,%r0
	JMP l4478
l43de:
	MOVW &0x1,%r0
	JMP l4478
l43e7:
	MOVB *0(%ap),{uword}%r0
	PUSHW %r0
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l4405
	MOVW &-1,%r0
	BRB l4478
l4405:
	CMPB &0x8,*0(%ap)
	BNEB l442c
	CMPW %r8,(%ap)
	BEB l442a

## printf (" \b")
	PUSHW &lb24
	CALL -4(%sp),printf

	TSTW %r0
	BGEB l4427
	MOVW &-1,%r0
	BRB l4478
l4427:
	DECW (%ap)
l442a:
	BRB l4455
l442c:
	CMPB &0x40,*0(%ap)
	BNEB l4452
	MOVW %r8,(%ap)
	PUSHW &0xa
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l4450
	MOVW &-1,%r0
	BRB l4478
l4450:
	BRB l4455
l4452:
	INCW (%ap)
l4455:
	SUBW3 %r8,(%ap),%r0
	CMPW &0x50,%r0
	BLH l4389

## printf ("\nmax input of %d characters, re-enter entire line\n")
	PUSHW &lb27
	PUSHW &0x50
	CALL -8(%sp),printf

	MOVW %r8,(%ap)
	BRH l4383
l4478:
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET
	NOP
 
#############################################################################
## 'getstat' - Routine to check console for character present
##

getstat:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp

## Call soft-power inhibit/timer function.
	CALL (%sp),$0x62de
	ADDW3 &0x2,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds #NOP
	BEB l44ad
	ADDW3 &0x4,p_fl_cons,%r0
	CMPB &0x1,(%r0)
	BEB l44cc
 
## R0 = 0x49001 (iu_sra, UART port A status)
l44ad:
	ADDW3 &0x1,$console,%r0
## If BIT 1 (RxRDY) is set, jump to 44C8
	BITB (%r0),&0x1
	BEB l44c8

## If not, grab the data in 49003
## R0 = 0x49004 (iu_sra, UART port A data)
	ADDW3 &0x3,$console,%r0
	MOVB (%r0),{uword}%r0
	BRB l44dc

l44c8:
	CLRW %r0
	BRB l44dc
l44cc:
	PUSHW &0x1

	CALL -4(%sp),$0x56f8
	MOVB %r0,{uword}%r0
	BRB l44dc
l44dc:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################
## 'printf' Routine
##

#l44e4:
printf:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x38, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x38,%sp
	.byte	0x2b, 0xef, 0xc4, 0x04, 0x00, 0x00	# TSTB *p_access # as adds NOP
	BNEB l4504
	CALL (%sp),$0x62de
	CLRW %r0
	JMP l48ae
l4504:
	ADDW3 &0x2,$console,%r0
	MOVB &0x15,(%r0)
	CLRW 40(%fp)
	MOVAW 4(%ap),(%fp)
	JMP l4888
l451e:
	CMPB &0x25,*0(%ap)
	BEB l452a
	JMP l4867
l452a:
	MOVW &0x20,8(%fp)
	CLRW 4(%fp)
	CLRW 24(%fp)
	CLRW 28(%fp)
	INCW (%ap)
	CMPB &0x2d,*0(%ap)
	BNEB l4549
	MOVW &0x1,4(%fp)
	INCW (%ap)
l4549:
	CMPB &0x30,*0(%ap)
	BNEB l455a
	.byte	0x28, 0x64	# TSTW 4(%fp) # as adds NOP
	BNEB l4557
	MOVW &0x30,8(%fp)
l4557:
	INCW (%ap)
l455a:
	BRB l4571
l455c:
	.byte	0xe8, 0x0a, 0xc9, 0x1c, 0x40	# MULW3 &0xa,28(%fp),%r0
	SUBB3 &0x30,*0(%ap),%r1
	ADDW2 %r1,%r0
	MOVW %r0,28(%fp)
	INCW (%ap)
l4571:
	CMPB &0x30,*0(%ap)
	BLB l457d
	CMPB &0x39,*0(%ap)
	BLEB l455c
l457d:
	CMPB &0x6c,*0(%ap)
	BEB l458b
	CMPB &0x68,*0(%ap)
	BNEB l458e
l458b:
	INCW (%ap)
l458e:
	MOVB *0(%ap),{uword}%r0
	JMP l4812
l4599:
	ADDW3 &0x3,(%fp),%r0
	MOVB (%r0),16(%fp)
	ADDW2 &0x4,(%fp)
	.byte	0x2b, 0xc9, 0x10 	# TSTB 16(%fp) # as adds NOP
	BEB l45c9
	MOVB 16(%fp),{uword}%r0
	PUSHW %r0
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l45c9
	MOVW &0x1,40(%fp)
l45c9:
	JMP l4865
l45cf:
	MOVW *0(%fp),20(%fp)
	ADDW2 &0x4,(%fp)
	.byte	0x28, 0xc9, 0x14	# TSTW 20(%fp) # as adds NOP
	BNEB l45e7
	MOVW &lb70,20(%fp) # lb70: "(null pointer)"
l45e7:
	CLRW 12(%fp)
	BRB l4614
l45ec:
	INCW 12(%fp)
	MOVW 20(%fp),%r0
	INCW 20(%fp)
	MOVB (%r0),{uword}%r0
	PUSHW %r0
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l4614
	MOVW &0x1,40(%fp)
l4614:
	.byte	0x2b, 0xd9, 0x14	# TSTB *20(%fp) # as adds NOP
	BNEB l45ec
	BRB l4634
l461b:
	PUSHW &0x20
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l4634
	MOVW &0x1,40(%fp)
l4634:
	MOVW 12(%fp),%r0
	INCW 12(%fp)
	CMPW 28(%fp),%r0
	BLB l461b
	JMP l4865
l4646:
	MOVW &0x10,36(%fp)
	BRB l465e
l464d:
	MOVW &0x1,24(%fp)
l4652:
	MOVW &0xa,36(%fp)
	BRB l465e
l4659:
	MOVW &0x8,36(%fp)
l465e:
	MOVW *0(%fp),32(%fp)
	ADDW2 &0x4,(%fp)
	.byte	0x28, 0xc9, 0x20	# TSTW 32(%fp) # as adds NOP
	BNEB l4680
	MOVW &0x1,12(%fp)
	MOVB $0xb5c,44(%fp)  # l5bc: "0123456789abcdef"
	CLRW 24(%fp)
	BRB l46f2
l4680:
	CMPW &0x1,24(%fp)
	BNEB l469b
	LRSW3 &0x1f,32(%fp),%r0
	BEB l469b
	MCOMW 32(%fp),%r0
	ADDW2 &0x1,%r0
	MOVW %r0,32(%fp)
	BRB l469f
l469b:
	CLRW 24(%fp)
l469f:
	CLRW 12(%fp)
	BRB l46c4
l46a4:
	MOVAW 44(%fp),%r0
	ADDW2 12(%fp),%r0
	.byte	0xe4, 0xe0, 0xc9, 0x24, 0xc9, 0x20, 0x41	# MODW3 {uword}36(%fp),32(%fp),%r1
## cac: binary to hex conversion
	MOVB lb5c(%r1),(%r0)
	DIVW2 {uword}36(%fp),32(%fp)
	INCW 12(%fp)
l46c4:
	.byte	0x28, 0xc9, 0x20	# TSTW 32(%fp) # as adds NOP
	BEB l46ce
	CMPW &0xc,12(%fp)
	BLB l46a4
l46ce:
	CMPW &0xc,12(%fp)
	BLB l46f2
	PUSHW &0x3f
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l46ec
	MOVW &0x1,40(%fp)
l46ec:
	JMP l4865
l46f2:
	.byte	0x28, 0x64	# TSTW 4(%fp) # as adds NOP
	BNEB l476c
	CMPW &0x1,24(%fp)
	BNEB l471e
	DECW 28(%fp)
	CMPW &0x30,8(%fp)
	BNEB l471e
	PUSHW &0x2d
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l471e
	MOVW &0x1,40(%fp)
l471e:
	BRB l4739
l4720:
	PUSHW 8(%fp)
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l4739
	MOVW &0x1,40(%fp)
l4739:
	MOVW 28(%fp),%r0
	DECW 28(%fp)
	CMPW 12(%fp),%r0
	BGB l4720
	CMPW &0x1,24(%fp)
	BNEB l476a
	CMPW &0x20,8(%fp)
	BNEB l476a
	PUSHW &0x2d
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l476a
	MOVW &0x1,40(%fp)
l476a:
	BRB l4794
l476c:
	CMPW &0x1,24(%fp)
	BNEB l478f
	DECW 28(%fp)
	PUSHW &0x2d
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l478f
	MOVW &0x1,40(%fp)
l478f:
	SUBW2 12(%fp),28(%fp)
l4794:
	BRB l47ba
l4796:
	MOVAW 44(%fp),%r0
	ADDW2 12(%fp),%r0
	MOVB (%r0),{uword}%r0
	PUSHW %r0
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l47ba
	MOVW &0x1,40(%fp)
l47ba:
	DECW 12(%fp)
	BGEB l4796
	CMPW &0x1,4(%fp)
	BNEB l47f0
	BRB l47df
l47c6:
	PUSHW 8(%fp)
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l47df
	MOVW &0x1,40(%fp)
l47df:
	MOVW 28(%fp),%r0
	DECW 28(%fp)
	ADDW3 &0x1,12(%fp),%r1
	CMPW %r1,%r0
	BGB l47c6
l47f0:
	BRB l4865
l47f2:
	MOVB *0(%ap),{uword}%r0
	PUSHW %r0
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l4810
	MOVW &0x1,40(%fp)
l4810:
	BRB l4865
l4812:
	CMPW &0x6f,%r0
	BEH l4659
	BGB l4848
	CMPW &0x63,%r0
	BEH l4599
	BGB l483f
	CMPW &0x4f,%r0
	BEH l4659
	BGB l4836
	CMPW &0x44,%r0
	BEH 0x464d
	BRB l47f2
l4836:
	CMPW &0x58,%r0
	BEH l4646
	BRB l47f2
l483f:
	CMPW &0x64,%r0
	BEH l464d
	BRB l47f2
l4848:
	CMPW &0x75,%r0
	BEH l4652
	BGB l485a
	CMPW &0x73,%r0
	BEH l45cf
	BRB l47f2
l485a:
	CMPW &0x78,%r0
	BEH l4646
	BRB l47f2
	BRB l47f2
l4865:
	BRB l4885
l4867:
	MOVB *0(%ap),{uword}%r0
	PUSHW %r0
	PUSHW $console
	CALL -8(%sp),$0x48b8
	TSTW %r0
	BGEB l4885
	MOVW &0x1,40(%fp)
l4885:
	INCW (%ap)
l4888:
	.byte	0x2b, 0xda, 0x00	# TSTB *0(%ap) # as adds NOP
	BNEH l451e
	CMPW &0x1,40(%fp)
	BNEB l48a9
	PUSHW &0xa
	PUSHW $console
	CALL -8(%sp),$0x48b8
	MOVW &-1,%r0
	BRB l48ae
l48a9:
	MOVW &0x1,%r0
	BRB l48ae
l48ae:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP
	NOP
 
 
###############################################################################
## Unknown routine, but used by 'printf'
##
l48b8:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c # ADDW2 &0x4,%sp
	CALL (%sp),$0x62de
	ADDW3 &0x2,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds #NOP
	BEB l48e7
	ADDW3 &0x4,p_fl_cons,%r0
	CMPB &0x1,(%r0)
	BNEB l48e7
	JMP l4a63
l48e7:
	MOVB 3(%ap),{uhalf}%r0
	MOVH %r0,2(%fp)
	CMPW $console,4(%ap)
	BEB l48fe
	JMP l49f0
l48fe:
	.byte	0x2b, 0x7f, 0x68, 0x08, 0x00, 0x02	# TSTB $0x2000868 # as adds NOP
	BEB l490c
	JMP l49f0
l490c:
	ADDW3 &0x1,4(%ap),%r0
	BITB (%r0),&0x1
	BNEB l491b
	JMP l49f0
l491b:
	ADDW3 &0x1,4(%ap),%r0
	BITB (%r0),&0x80
	BEB l4973
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x40,(%r0)
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x50,(%r0)
	ADDW3 &0x3,4(%ap),%r0
	MOVB (%r0),{uhalf}%r0
	MOVH %r0,(%fp)
	BRB l4964
l4946:
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x40,(%r0)
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x50,(%r0)
	ADDW3 &0x3,4(%ap),%r0
	MOVB (%r0),{uhalf}%r0
	MOVH %r0,(%fp)
l4964:
	ADDW3 &0x1,4(%ap),%r0
	BITB (%r0),&0x1
	BNEB l4946
	MOVH &-1,2(%fp)
	BRB l49f0
l4973:
	ADDW3 &0x3,4(%ap),%r0
	CMPB &0x13,(%r0)
	BNEB l49f0
	BRB l4985
l497e:
	CALL (%sp),$0x62de
l4985:
	ADDW3 &0x1,4(%ap),%r0
	BITB (%r0),&0x1
	BEB l497e
	ADDW3 &0x1,4(%ap),%r0
	BITB (%r0),&0x80
	BEB l49e4
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x40,(%r0)
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x50,(%r0)
	ADDW3 &0x3,4(%ap),%r0
	MOVB (%r0),{uhalf}%r0
	MOVH %r0,(%fp)
	BRB l49d7
l49b9:
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x40,(%r0)
	ADDW3 &0x2,4(%ap),%r0
	MOVB &0x50,(%r0)
	ADDW3 &0x3,4(%ap),%r0
	MOVB (%r0),{uhalf}%r0
	MOVH %r0,(%fp)
l49d7:
	ADDW3 &0x1,4(%ap),%r0
	BITB (%r0),&0x1
	BNEB l49b9
	MOVH &-1,2(%fp)
l49e4:
	ADDW3 &0x3,4(%ap),%r0
	MOVB (%r0),{uhalf}%r0
	MOVH %r0,(%fp)
l49f0:
	BRB l49f9
l49f2:
	CALL (%sp),$0x62de
l49f9:
	ADDW3 &0x1,4(%ap),%r0
	BITB (%r0),&0x4

	BEB l49f2
	CMPW $console,4(%ap)
	BNEB l4a34
	ADDW3 &0x3,4(%ap),%r0

## Write a single character out (R0 here contains address 49003)
	MOVB 3(%ap),(%r0)
	CMPB &0xa,3(%ap)
	BNEB l4a32
	BRB l4a21
l4a1a:
	CALL (%sp),$0x62de
l4a21:
	ADDW3 &0x1,4(%ap),%r0
	BITB (%r0),&0x4
	BEB l4a1a
	ADDW3 &0x3,4(%ap),%r0
	MOVB &0xd,(%r0)
l4a32:
	BRB l4a4b
l4a34:
	CMPB &0xa,3(%ap)
	BNEB l4a43
	ADDW3 &0x3,4(%ap),%r0
	MOVB &0xd,(%r0)
	BRB l4a4b
l4a43:
	ADDW3 &0x3,4(%ap),%r0
	MOVB 3(%ap),(%r0)
l4a4b:
	BRB l4a54
l4a4d:
	CALL (%sp),$0x62de
l4a54:
	ADDW3 &0x1,4(%ap),%r0
	BITB (%r0),&0x4
	BEB l4a4d
	MOVH 2(%fp),{word}%r0
	BRB l4adc
l4a63:
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	CALL -4(%sp),$0x586a
	MOVH %r0,(%fp)
	CMPH &-1,(%fp)
	BNEB l4a80
	MOVH (%fp),{word}%r0
	BRB l4adc
l4a80:
	CMPH &0x13,(%fp)
	BNEB l4a9c
	BRB l4a8e
l4a87:
	CALL (%sp),$0x62de
l4a8e:
	PUSHW &0x1
	CALL -4(%sp),$0x56f8
	TSTW %r0
	BEB l4a87
l4a9c:
	CMPB &0xa,3(%ap)
	BNEB l4ad6
	PUSHW &0xd
	CALL -4(%sp),$0x586a
	MOVH %r0,(%fp)
	CMPH &-1,(%fp)
	BNEB l4aba
	MOVH (%fp),{word}%r0
	BRB l4adc
l4aba:
	CMPH &0x13,(%fp)
	BNEB l4ad6
	BRB l4ac8
l4ac1:
	CALL (%sp),$0x62de
l4ac8:
	PUSHW &0x1
	CALL -4(%sp),$0x56f8
	TSTW %r0
	BEB l4ac1
l4ad6:
	MOVH (%fp),{word}%r0
	BRB l4adc
l4adc:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

##############################################################################
## 'sscanf' Routine
##

sscanf:
#l4ae4:
	SAVE %r5
	.byte	0x9c, 0x4f, 0x1c, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x1c,%sp
	MOVAW 8(%ap),8(%fp)
	JMP l4cc4
l4af7:
	CLRW %r6
	BRB l4b08
l4afb:
	.byte	0x2b, 0xda, 0x04	# TSTB *4(%ap) # as adds NOP
	BNEB l4b05
	MOVW &0x1,%r6
	BRB l4b0e
l4b05:
	INCW 4(%ap)
l4b08:
	CMPB &0x25,*4(%ap)
	BNEB l4afb
l4b0e:
	TSTW %r6
	BEB l4b18
	JMP l4cca
l4b18:
	BRB l4b1d
l4b1a:
	INCW (%ap)
l4b1d:
	CMPB &0x20,*0(%ap)
	BNEB l4b28
	MOVW &0x1,%r0
	BRB l4b2a
l4b28:
	CLRW %r0
l4b2a:
	MOVW %r0,12(%fp)
	CMPB &0x9,*0(%ap)
	BNEB l4b39
	MOVW &0x1,%r0
	BRB l4b3b
l4b39:
	CLRW %r0
l4b3b:
	MOVW %r0,16(%fp)
	CMPB &0x2d,*0(%ap)
	BNEB l4b4b
	MOVW &0x1,%r0
	BRB l4b4d
l4b4b:
	CLRW %r0
l4b4d:
	MOVW %r0,20(%fp)
	CMPB &0x2c,*0(%ap)
	BNEB l4b5d
	MOVW &0x1,%r0
	BRB l4b5f
l4b5d:
	CLRW %r0
l4b5f:
	MOVW %r0,24(%fp)
	CMPB &0x3d,*0(%ap)
	BNEB l4b6f
	MOVW &0x1,%r0
	BRB l4b71
l4b6f:
	CLRW %r0
l4b71:
	ORW3 16(%fp),12(%fp),%r1
	ORW2 20(%fp),%r1
	ORW2 24(%fp),%r1
	ORW2 %r1,%r0
	BNEB l4b1a
	INCW 4(%ap)
	MOVB *4(%ap),{uword}%r0
	JMP l4c96
l4b91:
	MOVW (%ap),%r8
	PUSHAW (%ap)
	CALL -4(%sp),0x146(%pc)
	BRB l4bb0
l4b9e:
	MOVW *8(%fp),%r0
	MOVW %r8,%r1
	INCW %r8
	MOVB (%r1),(%r0)
	INCW *8(%fp)
l4bb0:
	CMPW (%ap),%r8
	BNEB l4b9e
	MOVW *8(%fp),%r0
	CLRB (%r0)
	JMP l4cc0
l4bc2:
	MOVW *8(%fp),%r0
	MOVB *0(%ap),(%r0)
	INCW (%ap)
	JMP l4cc0
l4bd4:
	MOVW &0x7,%r6
	BRB l4be5
l4bd9:
	MOVAW (%fp),%r0
	ADDW2 %r6,%r0
	MOVB &0x30,(%r0)
	DECW %r6
l4be5:
	TSTW %r6
	BGEB l4bd9
	MOVW (%ap),%r8
	MOVAW 7(%fp),%r7
	PUSHAW (%ap)
	CALL -4(%sp),0xeb(%pc)
	DECW (%ap)
l4bfa:
	MOVB *0(%ap),(%r7)
	CMPW %r8,(%ap)
	BNEB l4c06
	BRB l4c0d
l4c06:
	DECW %r7
	DECW (%ap)
	BRB l4bfa
l4c0d:
	CLRW %r5
	MOVAW (%fp),%r7
	MOVW &0x7,%r6
	BRB l4c32
l4c17:
	MOVB (%r7),{uword}%r0
	PUSHW %r0
	CALL -4(%sp),0x15f(%pc)
	LLSW3 &0x2,%r6,%r1
	LLSW3 %r1,%r0,%r0
	ORW2 %r0,%r5
	INCW %r7
	DECW %r6
l4c32:
	TSTW %r6
	BGEB l4c17
	PUSHAW (%ap)
	CALL -4(%sp),0xa4(%pc)
	CMPB &0x78,*4(%ap)
	BNEB l4c55
	.byte	0x84, 0xd9, 0x08, 0x40	# MOVW *8(%fp),%r0 # as adds NOP
	MOVW %r5,%r1
	MOVH %r1,%r1
	MOVH %r1,(%r0)
	BRB l4c5d
l4c55:
	MOVW *8(%fp),%r0
	MOVW %r5,(%r0)
l4c5d:
	BRB l4cc0
l4c5f:
	CMPB &0x64,*4(%ap)
	BNEB l4c7a
	PUSHW (%ap)
	CALL -4(%sp),$0x7ed0
	MOVW *8(%fp),%r1
	MOVH %r0,(%r1)
	BRB l4c8c
l4c7a:
	PUSHW (%ap)
	CALL -4(%sp),$0x7e38
	MOVW *8(%fp),%r1
	MOVW %r0,(%r1)
l4c8c:
	PUSHAW (%ap)
	.byte	0x2c, 0xcc, 0xfc, 0xaf, 0x4e, 0x00 	# CALL -4(%sp),0x4e(%pc)
l4c94:
	BRB l4cc0
l4c96:
	CMPW %r0,&0x44
	BEB l4c5f
	CMPW %r0,&0x58
	BEH l4bd4
	CMPW %r0,&0x63
	BEH l4bc2
	CMPW %r0,&0x64
	BEB l4c5f
	CMPW %r0,&0x73
	BEH l4b91
	CMPW %r0,&0x78
	BEH l4bd4
	BRB l4c94
l4cc0:
	ADDW2 &0x4,8(%fp)
l4cc4:
	.byte	0x2b, 0xda, 0x04	# TSTB *4(%ap) # as adds NOP
	BNEH l4af7
l4cca:
	MOVAW -8(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %r6
	POPW %r5
	POPW %fp
	RET
	NOP
	NOP
	NOP

################################################################################

l4cdc:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x14, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x14,%sp
	BRB l4ceb
l4ce7:
	INCW *0(%ap)
l4ceb:
	MOVW *0(%ap),%r0
	CMPB &0x20,(%r0)
	BEB l4cf9
	MOVW &0x1,%r0
	BRB l4cfb
l4cf9:
	CLRW %r0
l4cfb:
	MOVW %r0,(%fp)
	MOVW *0(%ap),%r0
	CMPB &0x9,(%r0)
	BEB l4d0d
	MOVW &0x1,%r0
	BRB l4d0f
l4d0d:
	CLRW %r0
l4d0f:
	MOVW %r0,4(%fp)
	MOVW *0(%ap),%r0
	CMPB &0x2d,(%r0)
	BEB l4d21
	MOVW &0x1,%r0
	BRB l4d23
l4d21:
	CLRW %r0
l4d23:
	MOVW %r0,8(%fp)
	MOVW *0(%ap),%r0
	CMPB &0x2c,(%r0)
	BEB l4d35
	MOVW &0x1,%r0
	BRB l4d37
l4d35:
	CLRW %r0
l4d37:
	MOVW %r0,12(%fp)
	MOVW *0(%ap),%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds #NOP
	BEB l4d48
	MOVW &0x1,%r0
	BRB l4d4a
l4d48:
	CLRW %r0
l4d4a:
	MOVW %r0,16(%fp)
	MOVW *0(%ap),%r0
	CMPB &0x3d,(%r0)
	BEB l4d5d
	MOVW &0x1,%r0
	BRB l4d5f
l4d5d:
	CLRW %r0
l4d5f:
	ANDW3 4(%fp),(%fp),%r1
	ANDW2 8(%fp),%r1
	ANDW2 12(%fp),%r1
	ANDW2 16(%fp),%r1
	BITW %r1,%r0
	BNEH l4ce7
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################
l4d7c:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	CMPB &0x39,3(%ap)
	BGUB l4d8f
	MOVW &0x1,%r0
	BRB l4d91
l4d8f:
	CLRW %r0
l4d91:
	MOVW %r0,(%fp)
	CMPB &0x30,3(%ap)
	BLUB l4d9f
	MOVW &0x1,%r0
	BRB l4da1
l4d9f:
	CLRW %r0
l4da1:
	BITW %r0,(%fp)
	BEB l4db0
	SUBB3 &0x30,3(%ap),%r0
	MOVB %r0,{uword}%r0
	BRB l4dcb
l4db0:
	CMPB &0x61,3(%ap)
	BLUB l4dc1
	SUBB3 &0x57,3(%ap),%r0
	MOVB %r0,{uword}%r0
	BRB l4dcb
l4dc1:
	SUBB3 &0x37,3(%ap),%r0
	MOVB %r0,{uword}%r0
	BRB l4dcb
l4dcb:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################
## 'getedt' Routine
## 
 
getedt:
#l4dd4:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x08, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x8,%sp
	MOVB 7(%ap),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	MOVW %r0,4(%fp)
	CLRW (%fp)
	BRB l4e08
l4df5:
	MOVW (%ap),%r0
	INCW (%ap)
	MOVW 4(%fp),%r1
	INCW 4(%fp)
	MOVB (%r1),(%r0)
	INCW (%fp)
l4e08:
	CMPW &0x20,(%fp)
	BLUB l4df5
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################

l4e14:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x08, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x8,%sp
	PUSHW &0x0
	CALL -4(%sp),0x3b3(%pc)

## printf ("\n\nCurrent System Configuration\n\n")
	PUSHW &lb80
	CALL -4(%sp),printf

	TSTW %r0
	BGEB l4e3d
	JMP l51c0
l4e3d:
	MOVW *p_memsize,4(%fp)

## printf ("System Board memory size: ")
	PUSHW &lba1
	CALL -4(%sp),printf
	TSTW %r0
	BGEB l4e5d
	JMP l51c0
l4e5d:
	CMPW &0x100000,4(%fp)
	BLB l4e8a

## printf ("%d megabyte(s)")
	PUSHW &lbbc # lbbc: "%d megabyte(s)"

	LRSW3 &0x14,*p_memsize,%r0
	PUSHW %r0

	CALL -8(%sp),printf



	TSTW %r0
	BGEB l4e88
	JMP l51c0
l4e88:
	BRB l4eac
l4e8a:

## printf ("%d kilobytes")
	PUSHW &lbcb

	LRSW3 &0xa,*p_memsize,%r0
	PUSHW %r0

	CALL -8(%sp),printf


	TSTW %r0
	BGEB l4eac
	JMP l51c0
l4eac:
	CLRB (%fp)
	JMP l51a8
l4eb5:

## printf ("\n\n%02d - device name = %-9s, ")
	PUSHW &lbd8

	MOVB (%fp),{uword}%r0
	PUSHW %r0

	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 $p_edt,%r0
	ADDW2 &0xc,%r0
	PUSHW %r0

	CALL -12(%sp),printf


	TSTW %r0
	BGEB l4ee7
	JMP l51c0
l4ee7:

## printf ("occurrence = %2d, slot = %02d, ID code = 0x%02x\n")
	PUSHW &lbf6

	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x3,&0x8,(%r0),%r0
	PUSHW %r0

	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x3,&0xc,(%r0),%r0
	PUSHW %r0

	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0xf,&0x10,(%r0),%r0
	PUSHW %r0

	CALL -16(%sp),printf



	TSTW %r0
	BGEB l4f41
	JMP l51c0
l4f41:

## printf ("     boot device = %c, board width = %s, word width = %d byte(s),\n")
	PUSHW &lc27

	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x0,&0x7,4(%r0),%r0
	CMPW &0x0,%r0
	BEB l4f67
	MOVW &0x79,%r0
	BRB l4f6b
l4f67:
	MOVW &0x6e,%r0
l4f6b:
	PUSHW %r0

	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x0,&0x5,4(%r0),%r0
	CMPW &0x0,%r0
	BEB l4f90
	MOVW &lc6a,%r0	# "double"
	BRB l4f97
l4f90:
	MOVW &lc71,%r0	# "single"
l4f97:
	PUSHW %r0

	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x0,&0x6,4(%r0),%r0
	ADDW2 &0x1,%r0
	PUSHW %r0

	CALL -16(%sp),printf



	TSTW %r0
	BGEB l4fc5
	JMP l51c0
l4fc5:

## printf ("     req Q size = 0x%02x, comp Q size = 0x%02x, ")
	PUSHW &lc78

	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x7,&0x0,(%r0),%r0
	PUSHW %r0

	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x7,&0x18,4(%r0),%r0
	PUSHW %r0

	CALL -12(%sp),printf



	TSTW %r0
	BGEB l500a
	JMP l51c0
l500a:

## printf ("console ability = %c")
	PUSHW &lca9
	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x0,&0x9,4(%r0),%r0
	CMPW &0x0,%r0
	BEB l5030
	MOVW &0x79,%r0
	BRB l5034
l5030:
	MOVW &0x6e,%r0
l5034:
	PUSHW %r0
	CALL -8(%sp),printf
	TSTW %r0
	BGEB l5048
	JMP l51c0
l5048:
	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x0,&0x9,4(%r0),%r0
	CMPW &0x0,%r0
	BEB l50a2
	PUSHW &lcbe	# ", pump file = %c"
	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x0,&0x8,4(%r0),%r0
	CMPW &0x0,%r0
	BEB l5088
	MOVW &0x79,%r0
	BRB l508c
l5088:
	MOVW &0x6e,%r0
l508c:
	PUSHW %r0
	CALL -8(%sp),printf
	TSTW %r0
	BGEB l50a0
	JMP l51c0
l50a0:
	BRB l50ba
l50a2:

## printf ("               ")
	PUSHW &lccf
	CALL -4(%sp),printf
	TSTW %r0
	BGEB l50ba
	JMP l51c0
l50ba:
	CLRB 1(%fp)
	JMP l5154
l50c3:
	.byte	0x2b, 0x61	# TSTB 1(%fp) as adds NOP
	BNEB l50df

## printf ("\n     subdevice(s)")
	PUSHW &lcdf
	CALL -4(%sp),printf


	TSTW %r0
	BGEB l50df
	JMP l51c0
l50df:


## printf ("%s#%02d = %-9s, ID code = 0x%02x")
	PUSHW &lcf2

	MOVB 1(%fp),{uword}%r0
	MODW2 {uword}&0x2,%r0
	BNEB l50f8
	MOVW &ld13,%r0	# "\n     "
	BRB l50ff
l50f8:
	MOVW &ld1a,%r0	# ", "
l50ff:
	PUSHW %r0

	MOVB 1(%fp),{uword}%r0
	PUSHW %r0
	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	.byte	0xeb, 0x0c, 0x61, 0x41	# MULB3 &0xc,1(%fp),%r1
	ADDW3 %r1,8(%r0),%r0
	ADDW2 &0x2,%r0
	PUSHW %r0

	MOVB (%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	.byte	0xeb, 0x0c, 0x61, 0x41	# MULB3 &0xc,1(%fp),%r1
	ADDW3 %r1,8(%r0),%r0
	MOVH {uhalf}(%r0),{uword}%r0
	PUSHW %r0

	CALL -20(%sp),printf



	TSTW %r0
	BGEB l5151
	BRB l51c0
l5151:
	INCB 1(%fp)
l5154:
	MOVB 1(%fp),{uword}%r0
	MOVB (%fp),{uword}%r1
	LLSW3 &0x5,%r1,%r1
	ADDW2 p_edt,%r1
	EXTFW &0x3,&0x0,4(%r1),%r1
	CMPW %r1,%r0
	BLUH l50c3
	MOVB (%fp),{uword}%r0
	SUBB3 &0x1,*p_num_edt,%r1
	CMPW %r1,%r0
	BGEUB l51a5

## printf ("\n\nPress any key to continue")
	PUSHW &ld1d
	CALL -4(%sp),printf

	TSTW %r0
	BGEB l5198
	BRB l51c0
l5198:
	BRB l519a
l519a:
	CALL (%sp),*p_getstat
	TSTW %r0
	BEB l519a
l51a5:
	INCB (%fp)
l51a8:
	CMPB *p_num_edt,(%fp)
	BLUH l4eb5

## printf ("\nDONE\n")
	PUSHW &ld3a
	CALL -4(%sp),printf



l51c0:
	PUSHW &0x1
	.byte	0x2c, 0xcc, 0xfc, 0xaf, 0x10, 0x00	# CALL -4(%sp),0x10(%pc)
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP
	NOP

################################################################################
## 'brkinh' - Break Inhibit routine
##

brkinh:
#l51d2:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	MOVB 3(%ap),$0x2000868
	.byte	0x2b, 0x73	# TSTB 3(%ap) # as adds NOP
	BNEB l521c
	BRB l520f
l51e9:
	ADDW3 &0x2,$console,%r0
	MOVB &0x40,(%r0)
	ADDW3 &0x2,$console,%r0
	MOVB &0x50,(%r0)
	ADDW3 &0x3,$console,%r0
	MOVB (%r0),(%fp)
l520f:
	ADDW3 &0x1,$console,%r0
	BITB (%r0),&0x1
	BNEB l51e9
l521c:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################
## 'rnvram' - Routine to read NVRAM
##
##  (%ap) = NVRAM address to read from
## 4(%ap) = Address to write to
## 8(%ap) = Length
 
rnvram:
#l5224:
	SAVE %r8
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	.byte	0xf8, 0x5f, 0x00, 0xf0, 0x5a, 0x40	# ANDW3 &0xf000,(%ap),%r0

	ANDW3 &0xfff,(%ap),%r1
	LLSW3 &0x3,%r1,%r1
	ADDW2 %r1,%r0
	MOVW %r0,%r8
	BRB l526d
l5245:
	MOVW %r8,%r0
	ADDW2 &0x4,%r8
	ANDB3 &0xf,3(%r0),%r0
	MOVB %r0,*4(%ap)
	MOVW 4(%ap),%r0
	INCW 4(%ap)
	MOVW %r8,%r1
	ADDW2 &0x4,%r8
	ANDW3 &0xf,(%r1),%r1
	LLSW3 &0x4,%r1,%r1
	ORB2 %r1,(%r0)
l526d:
	MOVH 10(%ap),%r0
	DECH 10(%ap)
	MOVH {uhalf}%r0,{uword}%r0
	BNEB l5245
	CLRW $0x2001270
	PUSHW $0x2001270
	BSBB l528b
	BRB l5294
l528b:
	PUSHW %ap
	SUBW3 &0xc,%sp,%ap
## Call "chknvram"
	BRH chknvram
l5294:
	BRB l5296
l5296:
	MOVAW -20(%fp),%sp
	POPW %r8
	POPW %fp
	RET
	NOP
 
################################################################################
## 'wnvram' - Routine to write NVRAM
##

wnvram:
#l52a0:
	SAVE %r8
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	.byte	0xf8, 0x5f, 0x00, 0xf0, 0x74, 0x40	# ANDW3 &0xf000,4(%ap),%r0
	ANDW3 &0xfff,4(%ap),%r1
	LLSW3 &0x3,%r1,%r1
	ADDW2 %r1,%r0
	MOVW %r0,%r8
	BRB l52ea
l52c1:
	MOVW %r8,%r0
	ADDW2 &0x4,%r8
	ANDB3 &0xf,*0(%ap),%r1
	MOVW %r1,(%r0)
	MOVW %r8,%r0
	ADDW2 &0x4,%r8
	MOVW (%ap),%r1
	INCW (%ap)
	ANDB3 &0xf0,(%r1),%r1
	LRSW3 &0x4,%r1,%r1
	MOVW %r1,(%r0)
l52ea:
	MOVH 10(%ap),%r0
	DECH 10(%ap)
	MOVH {uhalf}%r0,{uword}%r0
	BNEB l52c1
	MOVW &0x1,$0x2001270
	PUSHW $0x2001270
	BSBB l5309
	BRB l5312
l5309:
	PUSHW %ap
	SUBW3 &0xc,%sp,%ap
	BRH chknvram
l5312:
	BRB l5314
l5314:
	MOVAW -20(%fp),%sp
	POPW %r8
	POPW %fp
	RET
	NOP
	NOP
	NOP

################################################################################ 
## 'chknvram' - Routine to check NVRAM
##
## This appears to be called only from 'rnvram' and 'wnvram'
##
 
chknvram:
#l5320:
	SAVE %r7
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	CLRH %r8
	MOVW &nvram_base+0x00,%r7
	BRB l5372
l5334:
	MOVH {uhalf}%r8,{uword}%r0
	MOVH {uhalf}2(%r7),{uword}%r1
	ANDH2 &0xf,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ADDW2 %r1,%r0
	MOVH %r0,%r8
	MOVH {uhalf}%r8,{uword}%r0
	LLSW3 &0x1,%r0,%r0
	MOVH {uhalf}%r0,{uword}%r0
	MOVH {uhalf}%r8,{uword}%r1
	LRSW3 &0xf,%r1,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ORW2 %r1,%r0
	MOVH %r0,%r8
	ADDW2 &0x4,%r7
l5372:
	CMPW &0x43800,%r7
	BLUB l5334
	MOVH {uhalf}%r8,{uword}%r0
	MCOMW %r0,%r0
	MOVH %r0,%r8
	CMPB &0x1,3(%ap)
	BNEB l53ca
	MOVH {uhalf}%r8,{uword}%r0
	ANDW2 &0xf,%r0
	MOVW %r0,(%r7)
	MOVH {uhalf}%r8,{uword}%r0
	LRSW3 &0x4,%r0,%r0
	ANDW2 &0xf,%r0
	MOVW %r0,4(%r7)
	MOVH {uhalf}%r8,{uword}%r0
	LRSW3 &0x8,%r0,%r0
	ANDW2 &0xf,%r0
	MOVW %r0,8(%r7)
	MOVH {uhalf}%r8,{uword}%r0
	LRSW3 &0xc,%r0,%r0
	ANDW2 &0xf,%r0
	MOVW %r0,12(%r7)
l53ca:
	MOVH {uhalf}%r8,{uword}%r0
	MOVH {uhalf}2(%r7),{uword}%r1
	ANDH2 &0xf,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ANDW3 &0xf,4(%r7),%r2
	LLSW3 &0x4,%r2,%r2
	MOVH {uhalf}%r2,{uword}%r2
	ORW2 %r2,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ANDW3 &0xf,8(%r7),%r2
	LLSW3 &0x8,%r2,%r2
	MOVH {uhalf}%r2,{uword}%r2
	ORW2 %r2,%r1
	MOVH {uhalf}%r1,{uword}%r1
	ANDW3 &0xf,12(%r7),%r2
	LLSW3 &0xc,%r2,%r2
	MOVH {uhalf}%r2,{uword}%r2
	ORW2 %r2,%r1
	MOVH {uhalf}%r1,{uword}%r1
	CMPW %r1,%r0
	BNEB l5429
	MOVW &0x1,%r0
	BRB l542d
l5429:
	CLRW %r0
	BRB l542d
l542d:
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET

################################################################################
## 'bzero' - Routine to zero memory
##

bzero:
#l5438
	MOVW (%ap),%r0
	MOVW 4(%ap),%r2
	ARSW3 &0x2,%r2,%r2
	CLRW (%r0)
	DECW %r2
	BLEB l544f
	MOVAW 4(%r0),%r1
	MOVBLW
l544f:
	RET

################################################################################
## 'setjmp' Routine
##

setjmp:
#l5450:
	MOVW (%ap),%r0
	TSTW %r0
	BNEB l545f
	MOVAW $0x2001274,%r0
l545f:
	MOVW %r3,(%r0)
	MOVW %r4,4(%r0)
	MOVW %r5,8(%r0)
	MOVW %r6,12(%r0)
	MOVW %r7,16(%r0)
	MOVW %r8,20(%r0)
	MOVW -4(%sp),24(%r0)
	MOVW -8(%sp),28(%r0)
	MOVW %ap,32(%r0)
	MOVW %fp,36(%r0)
	MOVW 12(%pcbp),40(%r0)
	MOVW 16(%pcbp),44(%r0)
	CLRW %r0
	RET

################################################################################
## 'longjmp' Routine
##

longjmp:
#l54a1:
	MOVW (%ap),%r0
	TSTW %r0
	BNEB l54b0
	MOVAW $0x2001274,%r0
l54b0:
	MOVW (%r0),%r3
	MOVW 4(%r0),%r4
	MOVW 8(%r0),%r5
	MOVW 12(%r0),%r6
	MOVW 16(%r0),%r7
	MOVW 20(%r0),%r8
	MOVW 24(%r0),%ap
	MOVW 28(%r0),%r1
	MOVW 32(%r0),%sp
	MOVW 36(%r0),%fp
	MOVW 40(%r0),12(%pcbp)
	MOVW 44(%r0),16(%pcbp)
	CLRW %r0
	INCW %r0
	JMP (%r1)
	NOP
	NOP
	NOP

################################################################################
## Interrupt handler inserted by the UART delay routine
## at 0x552c.  If interrupted, put 1 into 20012a4
 
l54ec:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVB &0x1,$0x20012a4
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
 
################################################################################
## 'hwcntr' - DUART Delay Routine
##

hwcntr:
#l5504:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVH {uhalf}2(%ap),{uword}%r0
	PUSHW %r0
	PUSHW &0x8ff
	.byte	0x2c, 0xcc, 0xf8, 0xaf, 0x14, 0x00	# CALL -8(%sp),0x14(%pc)
	MOVH {uhalf}%r0,{uword}%r0
	BRB l5525
l5525:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################
## Run the UART counter for a specific delay, waiting for an interrupt.
##
## On interrupt, transfer control to the routine pointed at by the
## pointer held in l494 (p_inthand) (i.e., l494 is a pointer-to-a-pointer)
##
 
l552c:
	SAVE %fp
## Increment stack pointer by 2 words.
	.byte	0x9c, 0x4f, 0x08, 0x00, 0x00, 0x00, 0x4c # ADDW2 &0x8,%sp
## Clear the byte at 0x20012a4
	CLRB $0x20012a4
## Move current interrupt handler to fp + 1 word
	MOVW *p_inthand,4(%fp)
## Set interrupt handler to 0x54ec
	MOVW &l54ec,*p_inthand

## 2001254
## R0 = (*0x2001254 | 0x30) (setting bits 5 & 6)
	ORB3 &0x30,$0x2001254,%r0

## Put a word into the auxiliary control register of the UART.
## Assuming this value is 0x30, that means we're asking the
## counter/timer to be a counter with an external source,
## divided by 16.
	MOVB %r0,iu_acr

##
	BRB l55c2
## Stop the UART timer (read from reg 15 = "Stop Counter"
l5562:
	MOVB iu_stop_ctr,(%fp)

##
## The next block of code sets the UART counter value to 0x8ff
##

## Put the argument (0x8ff) into r0
	MOVH {uhalf}6(%ap),{uword}%r0
## Shift it right by 8 bits (get the high byte)
	LRSW3 &0x8,%r0,%r0
## Write it to the upper-value of the timer (it gets 0x8)
	MOVB %r0,iu_ctur
## Mask the lower byte of the timer (0xff)
	ANDB3 &0xff,7(%ap),%r0
## Write it to the lower-value of the timer
	MOVB %r0,iu_ctlr
## Start the timer again (write to register 14 = "Start Counter")
	MOVB iu_start_ctr,(%fp)
## Go off to check the timer interrupt status
	BRB l55b9

## Jump point. Calls our mysterious timer / soft power inhibit routine 0x62de
l5593:
	CALL (%sp),$0x62de
## Set Z and N based on contents of 0x20012a4
	.byte	0x2b, 0x7f, 0xa4, 0x12, 0x00, 0x02	# TSTB $0x20012a4 # as adds NOP
## If 20012a4 == 0, jump to 0x55b9
	BEB l55b9
## On the other hand, if it's not 0, start the counter
	MOVB iu_stop_ctr,(%fp)
## Write the new interrupt handler
	MOVW 4(%fp),*p_inthand
## Store the argument into R0
	MOVH {uhalf}2(%ap),{uword}%r0
## Branch to 0x55e3 and return.
	BRB l55e3

## See if bit 3 ("Counter Ready") is set in the UART's interrupt
## status register.
l55b9:
	BITB iu_isr,&0x8

## If it isn't, jump back to 0x5593
	BEB l5593

## If it's not, it means the timer is expired....
l55c2:
	MOVH 2(%ap),%r0
	DECH 2(%ap)
## Check the value of R0.
	MOVH {uhalf}%r0,{uword}%r0
## If R0 != 0, jump back to 5562
	BNEB l5562
## On the other hand, if R0 == 0, we return.
	MOVB iu_stop_ctr,(%fp)
	MOVW 4(%fp),*p_inthand
	CLRW %r0
	BRB l55e3
l55e3:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################
## 'fw_sysgen' - Generic 'sysgen' routine
##
 
fw_sysgen:
#l55ec:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x08, 0x00, 0x00, 0x00, 0x4c # ADDW2 &0x8,%sp
	CLRB 4(%fp)
	MOVW *p_inthand,$0x20012c8
	MOVW &l5d00,*p_inthand
	EXTFW &0x3,&0xd,%psw,$0x20012c4
	.byte	0xc8, 0x03, 0x0d, 0x0f, 0x4b	# INSFW &0x3,&0xd,&0xf,%psw # as adds NOP
	MOVW &0x20012b8,$0x2000000
	MOVW &FW_RQ_ADDR,$0x20012b8
	MOVW &FW_CQ_ADDR,$0x20012bc
	MOVB &0x2,$0x20012c0
	MOVB &0x2,$0x20012c1
	MOVB &0x1,$0x20012c3
	PUSHW &FW_CQ_ADDR
	PUSHW &0x814
	CALL -8(%sp),*p_bzero
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	LLSW3 &0x15,(%ap),%r0
	MOVB 1(%r0),{uword}(%fp)
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	LLSW3 &0x15,(%ap),%r0
	MOVB 3(%r0),{uword}(%fp)
	CLRW (%fp)
	BRB l56b7
l569b:
	CMPB &0x3,$0x20037ef
	BNEB l56aa
	MOVB &0x1,4(%fp)
	BRB l56bd
l56aa:
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	INCW (%fp)
l56b7:
	CMPW &0x64,(%fp)
	BLUB l569b
l56bd:
	CMPW &0x64,(%fp)
	BLUB l56dc
	LLSW3 &0x15,(%ap),%r0
	MOVB &0x1,5(%r0)
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	MOVB 4(%fp),{uword}%r0
	BRB l56ef
## Call 0x5D3E
l56dc:
	CALL (%sp),0x662(%pc)
	CMPW &0x1,%r0
	BEB l56e9
	CLRB 4(%fp)
l56e9:
	MOVB 4(%fp),{uword}%r0
	BRB l56ef
l56ef:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################

l56f8:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	MOVW *p_inthand,$0x20012c8
	MOVW &l5d00,*p_inthand
	EXTFW &0x3,&0xd,%psw,$0x20012c4
	.byte	0xc8, 0x03, 0x0d, 0x0f, 0x4b	# INSFW &0x3,&0xd,&0xf,%psw # as adds NOP
	MOVB &0x8,$0x20037f7
	CMPB &0x1,3(%ap)
	BNEB l574c
	ADDW3 &0x3,p_fl_cons,%r0
	ORB3 &0x20,(%r0),%r0
	MOVB %r0,$0x20037f6
	BRB l5763
l574c:
	ADDW3 &0x3,p_fl_cons,%r0
	MOVB (%r0),$0x20037f6
	MOVB $0x20037f6,%r0
l5763:
	MOVB $0x2000868,{uword}$0x20037f8
	MOVB &0xff,$0x20037ef
	ADDW3 &0x2,p_fl_cons,%r0
	MOVB (%r0),{uword}%r0
	LLSW3 &0x15,%r0,%r0
	MOVB 1(%r0),{uhalf}%r0
	MOVH %r0,(%fp)
	CLRH (%fp)
	JMP l5856
l579c:
	PUSHW &0x1
	PUSHW &0xe6
	CALL -8(%sp),$0x552c
	CMPB &0xff,$0x20037ef
	BEB l581d
	.byte	0x2b, 0x7f, 0xef, 0x37, 0x00, 0x02	# TSTB $0x20037ef # as adds NOP
	BNEB l5807
	CALL (%sp),0x581(%pc)
	CMPW &0x1,%r0
	BEB l57dd
	MOVW &FATAL,*$0x48c
	MOVB &0x1,csr_reset	# system reset request
# Should not execute past reset
	BRB .	# loop on reset


l57dd:
	MOVH {uhalf}$FW_CQ_ADDR,{uword}%r0
	ANDH2 &0xff,%r0
	MOVH %r0,2(%fp)
	MOVH {uhalf}2(%fp),{uword}%r0
	CMPW &0xff,%r0
	BNEB l5800
	MOVW &-1,%r0
	BRB l5805
l5800:
	MOVH {uhalf}2(%fp),{uword}%r0
l5805:
	BRB l5862
l5807:
	MOVW &FATAL,*$0x48c
	MOVB &0x1,csr_reset	# system reset request
# Should not execute past reset
	BRB .	# loop on reset


l581d:
	MOVH {uhalf}(%fp),{uword}%r0
	CMPW &0x64,%r0
	BLUB l5845
	CALL (%sp),$0x62de
	MOVW &FATAL,*$0x48c
	MOVB &0x1,csr_reset	# system reset request
# Should not execute past reset
	BRB .	# loop on reset
l5845:
	CMPB &0x1,3(%ap)
	BNEB l584f
	INCH (%fp)
	BRB l5856
l584f:
	CALL (%sp),$0x62de
l5856:
	MOVH {uhalf}(%fp),{uword}%r0
	CMPW &0x64,%r0
	BLUH l579c
l5862:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################

l586a:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	MOVW *p_inthand,$0x20012c8
	MOVW &l5d00,*p_inthand
	EXTFW &0x3,&0xd,%psw,$0x20012c4
	.byte	0xc8, 0x03, 0x0d, 0x0f, 0x4b	# INSFW &0x3,&0xd,&0xf,%psw # as adds NOP
	MOVB &0x9,$0x20037f7
	ADDW3 &0x3,p_fl_cons,%r0
	MOVB (%r0),$0x20037f6
	MOVB 3(%ap),{uhalf}%r0
	MOVH %r0,$FW_RQ_ADDR
	MOVB &0xff,$0x20037ef
	MOVB $0x2000868,{uword}$0x20037f8
	ADDW3 &0x2,p_fl_cons,%r0
	MOVB (%r0),{uword}%r0
	LLSW3 &0x15,%r0,%r0
	MOVB 1(%r0),{uhalf}%r0
	MOVH %r0,(%fp)
	CLRH (%fp)
	JMP l59b2
l58f8:
	PUSHW &0x1
	PUSHW &0xe6
	CALL -8(%sp),$0x552c
	CMPB &0xff,$0x20037ef
	BEB l5987
	.byte	0x2b, 0x7f, 0xef, 0x37, 0x00, 0x02	# TSTB $0x20037ef # as adds NOP
	BNEB l596a
	CALL (%sp),0x425(%pc)
	CMPW &0x1,%r0
	BEB l5940
	CALL (%sp),$0x62de
	MOVW &FATAL,*$0x48c
	MOVB &0x1,csr_reset	# system reset request
# Should not execute past reset
	BRB .	# loop on reset



l5940:
	MOVH {uhalf}$FW_CQ_ADDR,{uword}%r0
	ANDH2 &0xff,%r0
	MOVH %r0,2(%fp)
	MOVH {uhalf}2(%fp),{uword}%r0
	CMPW &0xff,%r0
	BNEB l5963
	MOVW &-1,%r0
	BRB l5968
l5963:
	MOVH {uhalf}2(%fp),{uword}%r0
l5968:
	BRB l59be
l596a:
	CALL (%sp),$0x62de
	MOVW &FATAL,*$0x48c
	MOVB &0x1,csr_reset	# system reset request
# Should not execute past reset
	BRB .	# loop on reset



l5987:
	MOVH {uhalf}(%fp),{uword}%r0
	CMPW &0x64,%r0
	BLUB l59af
	CALL (%sp),$0x62de
	MOVW &FATAL,*$0x48c
	MOVB &0x1,csr_reset	# system reset request
# Should not execute past reset
	BRB .	# loop on reset




l59af:
	INCH (%fp)
l59b2:
	MOVH {uhalf}(%fp),{uword}%r0
	CMPW &0x64,%r0
	BLUH l58f8
l59be:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################

l59c6:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x10, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x10,%sp
	CLRB 4(%fp)
	MOVW *p_inthand,$0x20012c8
	MOVW &l5d00,*p_inthand
	EXTFW &0x3,&0xd,%psw,$0x20012c4
	.byte	0xc8, 0x03, 0x0d, 0x0f, 0x4b	# INSFW &0x3,&0xd,&0xf,%psw # as adds NOP
	MOVB &0x7,$0x20037f7
	MOVB 7(%ap),$0x20037f6
	MOVB &0xff,$0x20037ef
	MOVAW 8(%fp),$0x20037f8
	MOVH *p_fl_cons,8(%fp)
	CLRB 12(%fp)
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x15,%r0,%r0
	MOVB 1(%r0),{uword}(%fp)
	CLRW (%fp)
	BRB l5a95
l5a3a:
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	.byte	0x2b, 0x7f, 0xef, 0x37, 0x00, 0x02	# TSTB $0x20037ef # as adds NOP
	BNEB l5a72
	MOVB &0x1,4(%fp)
	ADDW3 &0x3,p_fl_cons,%r0
	MOVB 11(%fp),(%r0)
	ADDW3 &0x4,p_fl_cons,%r0
	MOVB &0x1,(%r0)
	MOVH 8(%fp),*p_fl_cons
	BRB l5a9b
l5a72:
	CMPW &0x64,(%fp)
	BLUB l5a92
	CLRB 4(%fp)
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x15,%r0,%r0
	MOVB &0x1,5(%r0)
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
l5a92:
	INCW (%fp)
l5a95:
	CMPW &0x64,(%fp)
	BLUB l5a3a
l5a9b:
	CALL (%sp),0x2a3(%pc)
	CMPW &0x1,%r0
	BEB l5abf
	CLRB 4(%fp)
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x15,%r0,%r0
	MOVB &0x1,5(%r0)
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
l5abf:
	MOVB 4(%fp),{uword}%r0
	BRB l5ac5
l5ac5:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################

l5ace:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x08, 0x00, 0x00, 0x00, 0x4c # ADDW2 &0x8,%sp
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x15,%r0,%r0
	MOVB &0x1,5(%r0)
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	.byte	0x2c, 0xcc, 0xfc, 0xaf, 0xf8, 0xfa	# CALL -4(%sp),0xfaf8(%pc)
	TSTW %r0
	BNEB l5b06
	CLRW %r0
	JMP l5ba3
l5b06:
	MOVW *p_inthand,$0x20012c8
	MOVW &l5d00,*p_inthand
	EXTFW &0x3,&0xd,%psw,$0x20012c4
	.byte	0xc8,0x03,0x0d,0x0f,0x4b	# INSFW &0x3,&0xd,&0xf,%psw # as adds NOP
	MOVB &0xa,$0x20037f7
	MOVB 7(%ap),$0x20037f6
	MOVB &0xff,$0x20037ef
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x15,%r0,%r0
	MOVB 1(%r0),{uword}4(%fp)
	CLRW 4(%fp)
	BRB l5b8a
l5b5b:
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	CMPB &0xff,$0x20037ef
	BEB l5b87
	.byte	0x2b, 0x7f, 0xef, 0x37, 0x00, 0x02	# TSTB $0x20037ef # as adds NOP
	BNEB l5b82
	MOVW $0x20037f0,(%fp)
	BRB l5b91
l5b82:
	CLRW (%fp)
	BRB l5b91
l5b87:
	INCW 4(%fp)
l5b8a:
	CMPW &0x7530,4(%fp)
	BLB l5b5b
l5b91:
	CALL (%sp),0x1ad(%pc)
	TSTW %r0
	BEB l5b9f
	MOVW (%fp),%r0
	BRB l5ba3
l5b9f:
	CLRW %r0
	BRB l5ba3
l5ba3:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################
## 'ioblk_acs' Routine
##
 
ioblk_acs:
#l5baa:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x08, 0x00, 0x00, 0x00, 0x4c # ADDW2 &0x8,%sp
	EXTFW &0x3,&0xd,%psw,$0x20012c4
	.byte	0xc8, 0x03, 0x0d, 0x0f, 0x4b	# INSFW &0x3,&0xd,&0xf,%psw # as adds NOP
	MOVW *p_inthand,$0x20012c8
	MOVW &l5d00,*p_inthand
	CLRB (%fp)
	MOVW 4(%ap),$0x20012b0
	MOVW 8(%ap),$0x20012b4
	CMPB &0x1,15(%ap)
	BNEB l5bfe
	MOVB &0xc,$0x20037f7
	BRB l5c2b
l5bfe:
	.byte	0x2b, 0xca, 0x0f	# TSTB 15(%ap) # as adds NOP
	BNEB l5c0d
	MOVB &0xb,$0x20037f7
	BRB l5c2b
l5c0d:
	MOVW $0x20012c8,*p_inthand
	.byte	0xc8, 0x03, 0x0d, 0x7f, 0xc4, 0x12, 0x00, 0x02, 0x4b	# INSFW &0x3,&0xd,$0x20012c4,%psw # as adds NOP
	MOVW &0x0,%r0
	JMP l5cf9
l5c2b:
	ANDB3 &0xf0,3(%ap),%r0
	LRSW3 &0x4,%r0,%r0
	MOVB %r0,2(%fp)
	.byte	0x2b, 0x62	# TSTB 2(%fp) # as adds NOP
	BNEB l5c45
	CLRW %r0
	JMP l5cf9
l5c45:
	ANDB3 &0xf,3(%ap),%r0
	MOVB %r0,1(%fp)
	MOVB 1(%fp),$0x20037f6
	MOVW &0x20012b0,$0x20037f8
	MOVB &0xff,$0x20037ef
	MOVB 2(%fp),{uword}%r0
	LLSW3 &0x15,%r0,%r0
	MOVB 1(%r0),{uword}4(%fp)
	CLRW 4(%fp)
	BRB l5ca9
l5c7e:
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	CMPB &0xff,$0x20037ef
	BEB l5ca6
	.byte	0x2b, 0x7f, 0xef, 0x37, 0x00, 0x02	# TSTB $0x20037ef # as adds NOP
	BNEB l5ca1
	MOVB &0x1,(%fp)
	BRB l5cb0
l5ca1:
	CLRB (%fp)
	BRB l5cb0
l5ca6:
	INCW 4(%fp)
l5ca9:
	CMPW &0x2328,4(%fp)
	BLB l5c7e
l5cb0:
	CALL (%sp),0x8e(%pc)
	TSTW %r0
	BEB l5cbd
	.byte	0x2b, 0x59	# TSTB (%fp) # as adds NOP
	BNEB l5cf4
l5cbd:

## printf ("PERIPHERAL I/O %s ERROR AT BLOCK %d, SUBDEVICE %d, SLOT %d\n")
	PUSHW &ld44

## read/write?
	.byte	0x2b, 0xca, 0x0f	# TSTB 15(%ap) # as adds NOP
	BNEB l5cd1
	MOVW &ld80,%r0	# "READ"
	BRB l5cd8
l5cd1:
	MOVW &ld85,%r0	# "WRITE"
l5cd8:
	PUSHW %r0

## block #
	PUSHW 4(%ap)

## subdevice #
	MOVB 1(%fp),{uword}%r0
	PUSHW %r0

## slot #
	MOVB 2(%fp),{uword}%r0
	PUSHW %r0

	CALL -20(%sp),printf


	CLRW %r0
	BRB l5cf9
l5cf4:
	MOVW &0x1,%r0
	BRB l5cf9
l5cf9:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################
## Unknown Routine
##

l5d00:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	.byte	0xc8, 0x03, 0x0d, 0x0f, 0x4b	# INSFW &0x3,&0xd,&0xf,%psw # as adds NOP
	CALL (%sp),$0x62de
	MOVH {uhalf}csr_datal,{uword}%r0
	BITW %r0,&0x7e
	BEB l5d2e
	MOVH &0x1,$0x20012ce
	BRB l5d35
l5d2e:
	CLRH $0x20012cc
l5d35:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################
## Routine that appears to print error messages during sysgen.
## Called by: 0x56DC (fw_sysgen)

l5d3e:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	MOVH &0x1,$0x20012cc
	CLRW (%fp)
	CLRH $0x20012ce
l5d59:
	.byte	0xc8, 0x03, 0x0d, 0x00, 0x4b	# INSFW &0x3,&0xd,&0x0,%psw # as adds NOP
	NOP
	NOP
	NOP
	NOP
	.byte	0xc8, 0x03, 0x0d, 0x0f, 0x4b	# INSFW &0x3,&0xd,&0xf,%psw # as adds NOP
	MOVH {uhalf}$0x20012cc,{uword}%r0
	BNEB l5d8c
	MOVW $0x20012c8,*p_inthand
	.byte	0xc8, 0x03, 0x0d, 0x7f, 0xc4, 0x12, 0x00, 0x02, 0x4b	# INSFW &0x3,&0xd,$0x20012c4,%psw # as adds NOP
	MOVW &0x1,%r0
	BRB l5dd7
l5d8c:
	CMPW &0xff,(%fp)
	BLEB l5dad
	MOVW $0x20012c8,*p_inthand
	.byte	0xc8, 0x03, 0x0d, 0x7f, 0xc4, 0x12, 0x00, 0x02, 0x4b	# INSFW &0x3,&0xd,$0x20012c4,%psw # as adds NOP
	MOVW &0x0,%r0
	BRB l5dd7
l5dad:
	MOVH {uhalf}$0x20012ce,{uword}%r0
	BEB l5dd2
	MOVW $0x20012c8,*p_inthand
	.byte	0xc8, 0x03, 0x0d, 0x7f, 0xc4, 0x12, 0x00, 0x02, 0x4b	# INSFW &0x3,&0xd,$0x20012c4,%psw # as adds NOP
	MOVW &0x0,%r0
	BRB l5dd7
l5dd2:
	INCW (%fp)
	BRB l5d59
l5dd7:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP


################################################################################
## Unknown Routine
##

l5de0:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	CALL (%sp),0x189(%pc)
	MOVB &0x1,*p_access
	BITW $0x200085c,&0x20000000
	BEB l5e25

## printf ("\nFW ERROR 1-%s\n")
	PUSHW &ld8c

	PUSHW &ldc0	# "01: NVRAM SANITY FAILURE"

	CALL -8(%sp),printf


## printf ("               DEFAULT VALUES ASSUMED\n               IF REPEATED, CHECK THE BATTERY\n")
	PUSHW &ldd9
	CALL -4(%sp),printf


l5e25:
	BITW $0x200085c,&0x40000000
	BEB l5e40

## printf ("\nFW WARNING: NVRAM DEFAULT VALUES ASSUMED\n\n")
	PUSHW &le2e
	CALL -4(%sp),printf
l5e40:
	BITW $0x200085c,&0x2
	BEB l5e5d

## printf ("\nFW ERROR 1-%s\n")
	PUSHW &ld8c

	PUSHW &le5a	# "02: DISK SANITY FAILURE"
	CALL -8(%sp),printf

l5e5d:
	BITW $0x200085c,&0x1
	BEB l5e7a

## printf ("\nFW ERROR 1-%s\n")
	PUSHW &ld8c
	PUSHW &le72	# "05: SELF-CONFIGURATION FAILURE"
	CALL -8(%sp),printf

l5e7a:
	BITW $0x200085c,&0x4
	BEB l5e97

## printf ("\nFW ERROR 1-%s\n")
	PUSHW &ld8c
	PUSHW &le91	# "06: BOOT FAILURE"
	CALL -8(%sp),printf


l5e97:
	BITW $0x200085c,&0x20
	BEB l5eb4

## printf ("\nFW ERROR 1-%s\n", "07: FLOPPY KEY CREATE FAILURE")
	PUSHW &ld8c
	PUSHW &lea2	# "07: FLOPPY KEY CREATE FAILURE"
	CALL -8(%sp),printf

l5eb4:
	BITW $0x200085c,&0x8
	BEB l5ed1

## printf ("\nFW ERROR 1-%s\n", "08: MEMORY TEST FAILURE")
	PUSHW &ld8c
	PUSHW &lec0	# "08: MEMORY TEST FAILURE"
	CALL -8(%sp),printf
l5ed1:
	BITW $0x200085c,&0x10
	BEB l5eee

## printf ("\nFW ERROR 1-%s\n", "09: DISK FORMAT NOT COMPATIBLE WITH SYSTEM")
	PUSHW &ld8c
	PUSHW &led8	# "09: DISK FORMAT NOT COMPATIBLE WITH SYSTEM"
	CALL -8(%sp),printf

l5eee:
	.byte	0x28, 0x7f, 0x5c, 0x08, 0x00, 0x02	# TSTW $0x200085c # as adds NOP
	BEB l5f17
	CMPW &0x1000000,$0x200085c # as adds NOP
	BGEUB l5f17

## printf ("%s", "               EXECUTION HALTED\n")
	PUSHW &lf03	# "%s"
	PUSHW &ld9c	# "               EXECUTION HALTED\n"
	CALL -8(%sp),printf

l5f17:
	CMPW &0x80000000,$0x200085c
	BNEB l5f4b
	CMPW &FATAL,$runflg
	BEB l5f4b

## printf ("\n\nSELF-CHECK\n")
	PUSHW &lf06
	CALL -4(%sp),printf

	ANDW2 &0x7fffffff,$0x200085c
l5f4b:
	ADDW3 &0x4,p_fl_cons,%r0
	CMPB &0x1,(%r0)
	BNEB l5f5f
	CLRW $0x200085c
l5f5f:
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################
## Unknown Routine
##

l5f72:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	MOVB &0x1,csr_clr_bto
	MOVB &0x1,csr_clr_mpe
	MOVB &0x1,csr_clr_maf
	MOVB &0x1,csr_clr_pir8
	MOVB &0x1,csr_clr_pir9
	MOVB &0x1,$dmac_base+0x0d
	MOVB $0x49011,(%fp)	# iu_base + 0x11	??? 
	MOVB $if_data,(%fp)
	MOVB &0x56,timer_ctrl
	MOVB timer_latch,(%fp)
	MOVB &0x1,csr_clr_inht
	MOVB &0x1,csr_clr_inhf
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP
	NOP

################################################################################
## Unknown Routine
##

l5fe6:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x10, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x10,%sp
	PUSHW &0x431ec
	PUSHAW (%fp)
	PUSHW &0x4
	CALL -12(%sp),rnvram
	CMPW &0x600dbeef,(%fp)
	BEB l6010
	JMP l614e
l6010:
	PUSHW &0x431f0
	PUSHAW (%fp)
	PUSHW &0x4
	CALL -12(%sp),rnvram
	.byte	0x28, 0x59	# TSTW (%fp) # as adds NOP
	BNEB l603a

## printf ("\nNONE\n\n")
	PUSHW &lf14
	CALL -4(%sp),printf

	JMP l61b9
l603a:
	BITW (%fp),&0x40
	BNEB l604d
	BITW (%fp),&0x80
	BNEB l604d
	JMP l60d0
l604d:
	PUSHW &0x431f4
	PUSHAW 8(%fp)
	PUSHW &0x4
	CALL -12(%sp),rnvram
	PUSHW &0x431f8
	PUSHAW 4(%fp)
	PUSHW &0x4
	CALL -12(%sp),rnvram
	PUSHW &0x431fc
	PUSHAW 12(%fp)
	PUSHW &0x4
	CALL -12(%sp),rnvram
	BITW (%fp),&0x40
	BEB l60a7

## printf ("\nEXCEPTION, PC = 0x%08x, PSW = 0x%08x, CSR = 0x%04x\n\n")
	PUSHW &lf1c
## PC
	PUSHW 4(%fp)
## PSW
	PUSHW 8(%fp)
## CSR
	ANDW3 &0xffff,12(%fp),%r0
	PUSHW %r0

	CALL -16(%sp),printf



	BRB l60ce
l60a7:

## printf ("\nINTERRUPT, PC = 0x%08x, PSW = 0x%08x, CSR = 0x%04x, LVL = %d\n\n")
	PUSHW &lf52
# PC
	PUSHW 4(%fp)
# PSW
	PUSHW 8(%fp)
# CSR
	ANDW3 &0xffff,12(%fp),%r0
	PUSHW %r0
# LVL
	LRSW3 &0x10,12(%fp),%r0
	ANDW2 &0xff,%r0
	PUSHW %r0

	CALL -20(%sp),printf



l60ce:
	BRB l614c
l60d0:
	BITW (%fp),&0x2
	BEB l614c

## printf ("\nSANITY ON DISK %d, ERROR %d\n")
	PUSHW &lf92

# disk #
	LRSW3 &0x17,(%fp),%r0
	ANDW2 &0x1,%r0
	PUSHW %r0
# error #
	LRSW3 &0x10,(%fp),%r0
	ANDW2 &0x7f,%r0
	PUSHW %r0

	CALL -12(%sp),printf



	PUSHW &0x431fc
	PUSHAW 12(%fp)
	PUSHW &0x4
	CALL -12(%sp),rnvram
	.byte	0x28, 0x6c	# TSTW 12(%fp) # as adds NOP
	BEB l613e

## printf ("COMMAND = 0x%02x, UNIT STATUS = 0x%02x, ERROR STATUS = 0x%02x, STATUS = 0x%02x")
	PUSHW &lfb0
# command
	LRSW3 &0x18,12(%fp),%r0
	PUSHW %r0
# unit status
	LRSW3 &0x10,12(%fp),%r0
	ANDW2 &0xff,%r0
	PUSHW %r0
# error status
	LRSW3 &0x8,12(%fp),%r0
	ANDW2 &0xff,%r0
	PUSHW %r0
#status
	ANDW3 &0xff,12(%fp),%r0
	PUSHW %r0

	CALL -20(%sp),printf



l613e:

## printf ("\n\n")
	PUSHW &lfff
	CALL -4(%sp),printf

l614c:
	BRB l615c

## printf ("\n\nNONE\n\n")
l614e:
	PUSHW &l1002
	CALL -4(%sp),printf

l615c:
	CLRW (%fp)
	PUSHAW (%fp)
	PUSHW &0x431f0
	PUSHW &0x4
	CALL -12(%sp),wnvram
	PUSHAW (%fp)
	PUSHW &0x431f4
	PUSHW &0x4
	CALL -12(%sp),wnvram
	PUSHAW (%fp)
	PUSHW &0x431f8
	PUSHW &0x4
	CALL -12(%sp),wnvram
	PUSHAW (%fp)
	PUSHW &0x431fc
	PUSHW &0x4
	CALL -12(%sp),wnvram
	PUSHAW (%fp)
	PUSHW &0x431ec
	PUSHW &0x4
	CALL -12(%sp),wnvram
l61b9:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################
## Unknown Routine
##

## We're called with the flag for "DISK SANITY FAILURE" (0x10000) already
## set in %ap. Seems to get set at 0x6e93
##

l61c0:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x0c, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0xc,%sp
	PUSHW &0x431ec
	PUSHAW 4(%fp)
	PUSHW &0x4
	CALL -12(%sp),rnvram
	CMPW &0x600dbeef,4(%fp)
	BNEB l61f8
	PUSHW &0x431f0
	PUSHAW (%fp)
	PUSHW &0x4
	CALL -12(%sp),rnvram
	BRB l6200
l61f8:
	MOVW $0x200085c,(%fp)
l6200:
	CLRW 4(%fp)
	PUSHAW 4(%fp)
	PUSHW &0x431ec
	PUSHW &0x4
	CALL -12(%sp),wnvram
	ORW2 (%ap),(%fp)
	MOVW (%fp),$0x200085c
	PUSHAW (%fp)
	PUSHW &0x431f0
	PUSHW &0x4
	CALL -12(%sp),wnvram
	BITW (%ap),&0x40
	BNEB l6240
	BITW (%ap),&0x80
	BEB l62a1
l6240:
	PUSHW &pswstore
	PUSHW &0x431f4
	PUSHW &0x4
	CALL -12(%sp),wnvram
	PUSHW &pcstore
	PUSHW &0x431f8
	PUSHW &0x4
	CALL -12(%sp),wnvram
	MOVH {uhalf}csr_datal,{uword}8(%fp)
	BITW (%ap),&0x80
	BEB l628d
	MOVB $0x2001260,{uword}%r0
	LLSW3 &0x10,%r0,%r0
	ORW2 %r0,8(%fp)
l628d:
	PUSHAW 8(%fp)
	PUSHW &0x431fc
	PUSHW &0x4
	CALL -12(%sp),wnvram
	BRB l62bc
l62a1:
	BITW (%ap),&0x2
	BEB l62bc
	PUSHW &0x20012d4
	PUSHW &0x431fc
	PUSHW &0x4
	CALL -12(%sp),wnvram
l62bc:
	MOVW &0x600dbeef,4(%fp)
	PUSHAW 4(%fp)
	PUSHW &0x431ec
	PUSHW &0x4
	CALL -12(%sp),wnvram
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP


################################################################################
## Unknown Routine -- checks interval timer and soft power inhibit.
##
 
l62de:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
 
## Check soft power inhibit (*510 = 020012d0)
	CMPB &0x1,*$0x510
	BEB l6319
 
## Check programmable interval timer (8253)
	CMPB &0x64,timer_diva
## Interval timer is OK, skip terminal condition and return.
	BEB l6319
 
## Clear some state and enter a terminal condition
	CLRW *$0x48c
	CLRW *p_meminit
	CLRB iu_ocpr
	MOVB &0x4,iu_sopr
## Terminal condition - infinite loop
l6317:
	BRB l6317

## Return
l6319:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################
## Terminal Halt. Enter an infinite loop on 0x633F.
##
 
l6322:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	CALL (%sp),-77(%pc)
	MOVW (%ap),*$0x48c
	MOVB &0x1,csr_reset	# system reset request
# Should not execute past reset
	BRB .	# loop on reset




	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################
## Terminal Halt. Enter an infinite loop on 0x6363.
##

l634a:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVW &FATAL,*$0x48c
	.byte	0x2c, 0x5c, 0xaf, 0x81, 0xfa	# CALL (%sp),0xfa81(%pc)
	MOVB &0x1,csr_reset	# system reset request
# Should not execute past reset
	BRB . # loop on reset

	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP
	NOP

################################################################################

l6378:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	ADDW3 &0x2,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds NOP
	BNEB l6396
	MOVW &0x1,%r0
	JMP l64e5
l6396:
	MOVH &0x1,(%fp)
	BRB l63c7
l639c:
	MOVH {uhalf}(%fp),{uword}%r0
	LLSW3 &0x5,%r0,%r0
	ADDW2 p_edt,%r0
	EXTFW &0x3,&0xc,(%r0),%r0
	ADDW3 &0x2,p_fl_cons,%r1
	MOVB (%r1),{uword}%r1
	CMPW %r1,%r0
	BNEB l63c4
	BRB l63d9
l63c4:
	INCH (%fp)
l63c7:
	MOVH {uhalf}(%fp),{uword}%r0
	MOVB *p_num_edt,{uword}%r1
	CMPW %r1,%r0
	BLUB l639c
l63d9:
	MOVH {uhalf}(%fp),{uword}%r0
	MOVB *p_num_edt,{uword}%r1
	CMPW %r1,%r0
	BLUB l6413
	ADDW3 &0x2,p_fl_cons,%r0
	CLRB (%r0)
	ADDW3 &0x3,p_fl_cons,%r0
	CLRB (%r0)
	MOVH &0x4bd,*p_fl_cons
	CLRW %r0
	JMP l64e5
l6413:
	ADDW3 &0x2,p_fl_cons,%r0
	MOVB (%r0),{uword}%r0
	LLSW3 &0x15,%r0,%r0
	MOVB &0x1,5(%r0)
	PUSHW &0x14
	CALL -4(%sp),*p_hwcntr # DUART Delay
	ADDW3 &0x2,p_fl_cons,%r0
	MOVB (%r0),{uword}%r0
	PUSHW %r0
	CALL -4(%sp),fw_sysgen
	CMPW &0x1,%r0
	BEB l6453
	JMP l64e1
l6453:
	ADDW3 &0x2,p_fl_cons,%r0
	MOVB (%r0),{uword}%r0
	PUSHW %r0
	ADDW3 &0x3,p_fl_cons,%r0
	MOVB (%r0),{uword}%r0
	PUSHW %r0
	CALL -8(%sp),$0x59c6
	CMPW &0x1,%r0
	BNEB l64e1
	ADDW3 &0x4,p_fl_cons,%r0
	MOVB &0x1,(%r0)
	MOVH *p_fl_cons,(%fp)
	PUSHAW (%fp)
	PUSHW &nvram_base+unx_nvr_consflg
	PUSHW &0x2
	CALL -12(%sp),wnvram
	ADDW3 &0x2,p_fl_cons,%r0
	MOVB (%r0),{uword}%r0
	LLSW3 &0x4,%r0,%r0
	ANDB2 &0xf0,%r0
	ADDW3 &0x3,p_fl_cons,%r1
	ANDB3 &0xf,(%r1),%r1
	ORB2 %r1,%r0
	MOVB %r0,2(%fp)
	PUSHAW 2(%fp)
	PUSHW &nvram_base+fw_nvr_cons_def
	PUSHW &0x1
	CALL -12(%sp),wnvram
	MOVW &0x1,%r0
	BRB l64e5
l64e1:
	CLRW %r0
	BRB l64e5
l64e5:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################

l64ec:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	CALL (%sp),*$inthand
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################

l6504:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	PUSHW &0x80
	CALL -4(%sp),$0x61c0

## printf ("\nFW ERROR 1-%s\n")
	PUSHW &ld8c

## printf ("04: UNEXPECTED INTERRUPT\n")
	PUSHW &l100c
	CALL -8(%sp),printf


# ; Print the string "EXECUTION HALTED"
	PUSHW &ld9c	# "               EXECUTION HALTED\n"
	CALL -4(%sp),printf
	PUSHW &FATAL
	CALL -4(%sp),$0x6322
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################
## Unknown procedure. Currently of interest becuase it is called by
## the only 100% confirmed interrupt handler, "demon", at 0x421f.
##

l6550:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	ANDW3 &0x3,$pswstore,%r0
	CMPW &0x3,%r0
	BNEB l6595
	ANDW3 &0x78,$pswstore,%r0
	CMPW &0x70,%r0
	BEB l6583
	ANDW3 &0x78,$pswstore,%r0
	CMPW &0x8,%r0
	BNEB l658c
l6583:
	CALL (%sp),*$bpthand
	BRB l6593
l658c:
	CALL (%sp),*$exchand
l6593:
	BRB l659c
l6595:
	CALL (%sp),*$exchand
l659c:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################
## Unknown Exception Handler
##

l65a4:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	PUSHW &0x40
	CALL -4(%sp),$0x61c0

## printf ("\nFW ERROR 1-%s\n", "03: UNEXPECTED FAULT\n")
	PUSHW &ld8c
	PUSHW &l1028	# "03: UNEXPECTED FAULT\n"
	CALL -8(%sp),printf


## Print the string "EXECUTION HALTED"
	PUSHW &ld9c	# "               EXECUTION HALTED\n"
	CALL -4(%sp),printf
	PUSHW &FATAL
	CALL -4(%sp),$0x6322
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################
##
##

l65f0:
	SAVE %r8
	.byte	0x9c, 0x4f, 0x74, 0x00, 0x00, 0x00, 0x4c 	# ADDW2 &0x74,%sp
	MOVB &0x1,*p_access
	MOVW &l6504,$inthand
	MOVW &l65a4,$exchand
	MOVW $exchand,$bpthand
	CMPW &FATAL,$runflg
	BEB l6639
	.byte	0x84, 0x4f, 0x00, 0x00, 0x80, 0x00, 0x4b	# MOVW &0x800000,%psw # as adds NOP
l6639:
	MOVW $runflg,%r8
	CMPW &FATAL,$runflg
	BEB l6660
	CMPW &REENTRY,$runflg
	BEB l6660
	JMP l6838
l6660:
	MOVW &INIT,$runflg
	PUSHW &nvram_base+0x00
	PUSHAW 100(%fp)
	PUSHW &0x9
## Call 'rnvram'
	CALL -12(%sp),rnvram
	.byte	0x2b, 0xc9, 0x64	# TSTB 100(%fp) # as adds NOP
	BNEB l66a8
	PUSHAW 100(%fp)
## This is the pointer to the default password, 'mcp'
	PUSHW &l1040	# "mcp"
	CALL -8(%sp),$0x7fb0
	PUSHAW 100(%fp)
	PUSHW &nvram_base+0x00
	PUSHW &0x9
	CALL -12(%sp),wnvram
## Jumped back to this point from 0x6835
l66a8:
	CMPW &REBOOT,%r8
	BNEB l66b7
	JMP l673c
l66b7:
	CMPW &FATAL,%r8
	BEB l673c
	ADDW3 &0x4,p_fl_cons,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds NOP
	BNEB l673c
	PUSHW &nvram_base+fw_nvr_bdev
	PUSHAW 110(%fp)
	PUSHW &0x1
	CALL -12(%sp),rnvram
	TSTW %r0
	BNEB l6709
	MOVB &0x1,110(%fp)
	PUSHAW 110(%fp)
	PUSHW &nvram_base+fw_nvr_bdev
	PUSHW &0x1
	CALL -12(%sp),wnvram
	ADDW3 &0x1,p_cmdqueue,%r0
	MOVB &0x1,(%r0)
	BRB l6716
l6709:
	ADDW3 &0x1,p_cmdqueue,%r0
	MOVB 110(%fp),(%r0)
l6716:
	CLRB *p_cmdqueue
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l1044	# "/filledt"
	CALL -8(%sp),$0x7fb0
	CALL (%sp),$0x6970
l673c:
	BRB l6793
l673e:
	ADDW3 &0x2,p_fl_cons,%r0
	CLRB (%r0)
	ADDW3 &0x3,p_fl_cons,%r0
	CLRB (%r0)
	MOVB &0x1,csr_set_fled	# set failure LED
	CLRW 112(%fp)
	BRB l6766
l6762:
	INCW 112(%fp)
l6766:
	CMPW &0xc350,112(%fp)
	BLB l6762
	MOVB &0x1,csr_clr_fled	# clear failure LED
	CLRW 112(%fp)
	BRB l6782
l677e:
	INCW 112(%fp)
l6782:
	CMPW &0x249f0,112(%fp)
	BLB l677e
	CALL (%sp),$0x62de
l6793:
	ADDW3 &0x4,p_fl_cons,%r0
	CMPB &0x1,(%r0)
	BEB l67af
	MCOMB iu_inprt,%r0
	ANDW2 &0x1,%r0
	CMPW &0x1,%r0
	BNEB l673e
l67af:
	CALL (%sp),$0x5de0
	CMPW &FATAL,%r8
	BNEB l67d7
	MOVB &0x1,csr_set_fled	# set failure LED

## printf ("\nSYSTEM FAILURE: CONSULT YOUR SYSTEM ADMINISTRATION UTILITIES GUIDE\n\n")
	PUSHW &l104d
	CALL -4(%sp),printf


	BRB l67ed
l67d7:
	MOVB &0x1,csr_clr_fled	# clear failure LED

## printf ("\nFIRMWARE MODE\n\n")
	PUSHW &l1093
	CALL -4(%sp),printf

## Call 3ab4 XXX
l67ed:
	PUSHAW (%fp)
	CALL -4(%sp),$0x3ab4
	PUSHAW (%fp)
	PUSHAW 100(%fp)
	CALL -8(%sp),strcmp
	TSTW %r0
	BNEB l6835
	MOVW &FATAL,$runflg
	CALL (%sp),$0x2b04
	MOVW $runflg,%r8
	PUSHW &nvram_base+0x00
	PUSHAW 100(%fp)
	PUSHW &0x9
	CALL -12(%sp),rnvram
## Jump back to 0x66A8
l6835:
	BRH l66a8
l6838:
	PUSHW &nvram_base+fw_nvr_bdev
	PUSHAW 110(%fp)
	PUSHW &0x1
	CALL -12(%sp),rnvram
	TSTW %r0
	BNEB l6875
	MOVB &0x1,110(%fp)
	PUSHAW 110(%fp)
	PUSHW &nvram_base+fw_nvr_bdev
	PUSHW &0x1
	CALL -12(%sp),wnvram
	ADDW3 &0x1,p_cmdqueue,%r0
	MOVB &0x1,(%r0)
	BRB l6882
l6875:
	ADDW3 &0x1,p_cmdqueue,%r0
	MOVB 110(%fp),(%r0)
l6882:
	CLRB *p_cmdqueue
	CMPW &REBOOT,%r8
	BEB l68e6
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l10a4	# "/filledt"
	CALL -8(%sp),$0x7fb0
	CALL (%sp),$0x6970
	TSTW %r0
	BNEB l68bc
	CALL (%sp),$0x634a
l68bc:
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l10ad	# "/dgmon"
	CALL -8(%sp),$0x7fb0
	CALL (%sp),$0x6970
	TSTW %r0
	BNEB l68e6
	CALL (%sp),$0x634a
l68e6:
	CMPW &FATAL,$runflg
	BEB l68fb
	MOVB &0x1,csr_clr_fled	# clear failure LED
l68fb:
	PUSHW &nvram_base+fw_nvr_dname
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &0x2d
	CALL -12(%sp),rnvram
	TSTW %r0
	BNEB l694b
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &l10b4	# "/unix"
	CALL -8(%sp),$0x7fb0
	ADDW3 &0x2,p_cmdqueue,%r0
	PUSHW %r0
	PUSHW &nvram_base+fw_nvr_dname
	PUSHW &0x2d
	CALL -12(%sp),wnvram
l694b:
	MOVB &0x2,*p_cmdqueue
	CALL (%sp),$0x6970
	CALL (%sp),$0x634a
	BRH l6639
	MOVAW -20(%fp),%sp
	POPW %r8
	POPW %fp
	RET
	NOP
	NOP
	NOP


################################################################################
## Unknown Routine
##

l6970:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x10, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x10,%sp
	CMPB &0x1,*p_cmdqueue
	BNEB l698f
	CMPW &0xfff0,p_serno
	BEB l69b3
l698f:
	MOVW &l6c52,$inthand
	MOVW &l6c9e,$bpthand
	MOVW $bpthand,$exchand
l69b3:
	CMPW &INIT,$meminit
	BEB l6a13
	MOVW &INIT,$meminit
	MOVW *p_memsize,(%fp)
	ADDW3 &0x2000000,*p_memsize,%r0
	SUBW2 *p_memstart,%r0
	LRSW3 &0x2,%r0,%r0
	MOVW %r0,(%fp)
	MOVW *p_memstart,%r0
	CLRW (%r0)
	PUSHW (%fp)
	ADDW3 &0x4,*p_memstart,%r0
	PUSHW %r0
	PUSHW *p_memstart
	CALL -12(%sp),$0x4084
l6a13:
	CLRB iu_ocpr
	MOVB &0x8,iu_ropr
	CALL (%sp),$0x5f72
	PUSHW &0x0
	CALL -4(%sp),*p_brkinh
	.byte	0x2b, 0xef, 0xa0, 0x04, 0x00, 0x00	# TSTB *p_cmdqueue # as adds NOP
	BEB l6a48
	CMPW &0x8000,p_serno
	BGEB l6a56
l6a48:
	MOVW &FATAL,*$0x48c
	BRB l6a62
l6a56:
	MOVW &VECTOR,*$0x48c
l6a62:
	MOVW &0x2004000,4(%fp)
	ADDW3 &0x1,p_cmdqueue,%r0
	MOVB (%r0),{uword}%r0
	LRSW3 &0x4,%r0,%r0
	MOVB %r0,9(%fp)
	ADDW3 &0x1,p_cmdqueue,%r0
	CMPB &0x1,(%r0)
	BNEB l6ad3
	MOVB &0x1,csr_fm_off # floppy motor off
	PUSHW &0x0
	CALL -4(%sp),$0x732c
	TSTW %r0
	BNEB l6aa9
	CLRW %r0
	JMP l6c4b
l6aa9:
	PUSHW &0x0
	PUSHW $0x2000aa8
	PUSHW &0x2004000
	PUSHW &0x0
	CALL -16(%sp),hd_acs
	TSTW %r0
	BNEB l6acd
	CLRW %r0
	JMP l6c4b
l6acd:
	JMP l6b99
l6ad3:
	ADDW3 &0x1,p_cmdqueue,%r0
	CMPB &0x2,(%r0)
	BNEB l6b24
	MOVB &0x1,csr_fm_off # floppy motor off
	PUSHW &0x1
	CALL -4(%sp),$0x732c
	TSTW %r0
	BNEB l6afe
	CLRW %r0
	JMP l6c4b
l6afe:
	PUSHW &0x1
	PUSHW $0x2000afc
	PUSHW &0x2004000
	PUSHW &0x0
	CALL -16(%sp),hd_acs
	TSTW %r0
	BNEB l6b22
	CLRW %r0
	JMP l6c4b
l6b22:
	BRB l6b99
l6b24:
	ADDW3 &0x1,p_cmdqueue,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds #NOP
	BNEB l6b59
	PUSHW &0x0
	PUSHW &0x2004000
	PUSHW &0x0
	PUSHW &0x0
	CALL -16(%sp),fd_acs
	TSTW %r0
	BNEB l6b57
	CALL (%sp),$0x7a34
	CLRW %r0
	JMP l6c4b
l6b57:
	BRB l6b99
l6b59:
	ADDW3 &0x1,p_cmdqueue,%r0
	ANDB3 &0xf,(%r0),%r0
	MOVB %r0,8(%fp)
	MOVB 9(%fp),{uword}%r0
	PUSHW %r0
	MOVB 8(%fp),{uword}%r0
	PUSHW %r0
	CALL -8(%sp),$0x5ace
	MOVW %r0,4(%fp)
	.byte	0x28, 0x64	# TSTW 4(%fp) # as adds NOP
	BNEB l6b99
	MOVB 9(%fp),{uword}%r0
	LLSW3 &0x15,%r0,%r0
	CLRB 5(%r0)
	CLRW %r0
	JMP l6c4b
l6b99:
	PUSHW &0x0
	CALL -4(%sp),*p_setjmp
	TSTW %r0
	BEB l6bec
	PUSHW &0x1
	CALL -4(%sp),*p_brkinh
	ADDW3 &0x1,p_cmdqueue,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds NOP
	BNEB l6bc6
	CALL (%sp),$0x7a34
	BRB l6bd6
l6bc6:
	.byte	0x2b, 0x69	# TSTB 9(%fp) # as adds NOP
	BEB l6bd6
	MOVB 9(%fp),{uword}%r0
	LLSW3 &0x15,%r0,%r0
	CLRB 5(%r0)
l6bd6:
	CMPW &FATAL,$runflg
	BNEB l6be7
	CLRW %r0
	BRB l6bea
l6be7:
	MOVW &0x1,%r0
l6bea:
	BRB l6c4b
l6bec:
	ADDW3 &0x4,4(%fp),%r0
	CMPW (%r0),*4(%fp)
	BNEB l6c14
	ADDW3 &0x4,4(%fp),%r0
	ADDW3 &0x8,4(%fp),%r1
	CMPW (%r1),(%r0)
	BNEB l6c14
	ADDW3 &0x8,4(%fp),%r0
	ADDW3 &0xc,4(%fp),%r1
	CMPW (%r1),(%r0)
	BNEB l6c14
	CLRW %r0
	BRB l6c4b
l6c14:
	CALL (%sp),*4(%fp)
	ADDW3 &0x1,p_cmdqueue,%r0
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds #NOP
	BNEB l6c2b
	CALL (%sp),$0x7a34
l6c2b:
	PUSHW &0x1
	CALL -4(%sp),*p_brkinh
	CMPW &FATAL,$runflg
	BNEB l6c46
	CLRW %r0
	BRB l6c49
l6c46:
	MOVW &0x1,%r0
l6c49:
	BRB l6c4b
l6c4b:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET


################################################################################

l6c52:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp

## *p_printf ("\nFW ERROR 1-%s\n", "04: UNEXPECTED INTERRUPT")
	PUSHW &ld8c
	PUSHW &l10bc	# "04: UNEXPECTED INTERRUPT"
	CALL -8(%sp),*p_printf

## *p_printf ("               EXECUTION HALTED\n")
	PUSHW &ld9c	# "               EXECUTION HALTED\n"
	CALL -4(%sp),*p_printf

	PUSHW &0x80
	CALL -4(%sp),$0x61c0
	PUSHW &FATAL
	CALL -4(%sp),$0x6322
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################

l6c9e:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp

## *p_printf ("\nFW ERROR 1-%s\n", "03: UNEXPECTED FAULT")
	PUSHW &ld8c
	PUSHW &l10d5
	CALL -8(%sp),*p_printf

## *p_printf ("               EXECUTION HALTED\n")
	PUSHW &ld9c	# "               EXECUTION HALTED\n"
	CALL -4(%sp),*p_printf

	PUSHW &0x40
	CALL -4(%sp),$0x61c0
	PUSHW &FATAL
	CALL -4(%sp),$0x6322
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP
	NOP

################################################################################

l6cec:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	.byte	0xec, 0x4f, 0x00, 0x00, 0x01, 0x00, 0x5a, 0x40	# DIVW3 &0x10000,(%ap),%r0
	MOVH {uhalf}10(%ap),{uword}%r1
	ADDW2 (%ap),%r1
	SUBW2 &0x1,%r1
	DIVW2 {uword}&0x10000,%r1
	CMPW %r1,%r0
	BGEUB l6d1d
	CLRW %r0
	JMP l6e1f
l6d1d:
	CLRB $dmac_base+0x0d
	CLRB $dmac_base+0x08
	CLRB $dmac_base+0x0c
	BITB 7(%ap),&0x1
	BEB l6d6a
	MOVB 3(%ap),$dmac_base+0x02
	MOVB 2(%ap),$dmac_base+0x02
	BITB 7(%ap),&0x8
	BEB l6d5c
	ORB3 &0x80,1(%ap),%r0
	MOVB %r0,$dmaif_base+3
	BRB l6d68
l6d5c:
	ORB3 &0x0,1(%ap),%r0
	MOVB %r0,$dmaif_base+3
l6d68:
	BRB l6d9b
l6d6a:
	MOVB 3(%ap),$dmac_base+0x00
	MOVB 2(%ap),$dmac_base+0x00
	BITB 7(%ap),&0x8
	BEB l6d8f
	ORB3 &0x80,1(%ap),%r0
	MOVB %r0,$dmaid_base+0x03
	BRB l6d9b
l6d8f:
	ORB3 &0x0,1(%ap),%r0
	MOVB %r0,$dmaid_base+0x03
l6d9b:
	CLRB $dmac_base+0x0c
	BITB 7(%ap),&0x1
	BEB l6dd3
	SUBB3 &0x1,11(%ap),%r0
	ANDB2 &0xff,%r0
	MOVB %r0,$dmac_base+0x03
	MOVH {uhalf}10(%ap),{uword}%r0
	SUBW2 &0x1,%r0
	LRSW3 &0x8,%r0,%r0
	ANDB2 &0xff,%r0
	MOVB %r0,$dmac_base+0x03
	BRB l6dfd
l6dd3:
	SUBB3 &0x1,11(%ap),%r0
	ANDB2 &0xff,%r0
	MOVB %r0,$dmac_base+0x01
	MOVH {uhalf}10(%ap),{uword}%r0
	SUBW2 &0x1,%r0
	LRSW3 &0x8,%r0,%r0
	ANDB2 &0xff,%r0
	MOVB %r0,$dmac_base+0x01
l6dfd:
	MOVB 7(%ap),$dmac_base+0x0b
	ANDB3 &0x3,7(%ap),%r0
	ADDB2 &0x1,%r0
	MCOMB %r0,%r0
	ANDB2 &0xf,%r0
	MOVB %r0,$dmac_base+0x0f
	MOVW &0x1,%r0
	BRB l6e1f
l6e1f:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################

l6c28:
	SAVE %r4
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	CLRB $0x20014f0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	MOVW &0x200,0x2000aa4(%r0)
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	MOVW &0x12,0x2000aa0(%r0)
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	MOVW &0x4,0x2000a9c(%r0)
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	MOVW &0x132,0x2000a98(%r0)
	CLRW $0x2000a7c
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	PUSHW &0x0
	PUSHW &0x2000874
	PUSHW &0x0
## Access the hard drive.
	CALL -16(%sp),hd_acs
## If %r0
	TSTW %r0
	BNEB l6ea7
	MOVW &0x10000,$0x2000a7c
	CLRW %r0
	JMP l70ec
l6ea7:
	CMPW &0xca5e600d,$0x2000878
	BEB l6ec8
	MOVW &0x20000,$0x2000a7c
	CLRW %r0
	JMP l70ec
l6ec8:
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	ADDW2 &physinfo,%r0
	MOVW %r0,%r8
	MOVW &0x2000874,%r7
	CLRH %r6
	BRB l6ef2
l6ee2:
	MOVW %r8,%r0
	INCW %r8
	MOVW %r7,%r1
	INCW %r7
	MOVB (%r1),(%r0)
	INCH %r6
l6ef2:
	MOVH {uhalf}%r6,{uword}%r0
	CMPW &0x54,%r0
	BLUB l6ee2
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x41	# MULB3 &0x54,3(%ap),%r1
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x42	# MULB3 &0x54,3(%ap),%r2
	.byte	0xec, 0xe0, 0x82, 0xa4, 0x0a, 0x00, 0x02, 0x81, 0xc0, 0x0a, 0x00, 0x02, 0x41  # DIVW3 {uword}0x2000aa4(%r2),0x2000ac0(%r1),%r1
	MOVH %r1,0x20014e8(%r0)
	CLRH %r6
	BRB l6f44
l6f28:
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x8,%r0,%r0
	ADDW2 &0x20012e8,%r0
	MOVH {uhalf}%r6,{uword}%r1
	ADDW2 %r1,%r0
	CLRB (%r0)
	INCH %r6
l6f44:
	MOVH {uhalf}%r6,{uword}%r0
	CMPW &0x100,%r0
	BLUB l6f28
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	.byte	0xec, 0xe0, 0x08, 0x80, 0xa4, 0x0a, 0x00, 0x02, 0x40	# DIVW3 {uword}&0x8,0x2000aa4(%r0),%r0
	MOVH %r0,%r4
	MOVB &0xff,$0x2000871
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	CLRH 0x20014ec(%r0)
	JMP l708b
l6f80:
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	MOVB 3(%ap),{uword}%r1
	LLSW3 &0x1,%r1,%r1
	MOVH {uhalf}0x20014ec(%r1),{uword}%r1
	ADDW3 %r1,0x2000abc(%r0),%r0
	PUSHW %r0
	PUSHW &0x2000874
	PUSHW &0x0
	CALL -16(%sp),hd_acs
	TSTW %r0
	BNEB l6fe2
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	MOVH {uhalf}0x20014ec(%r0),{uword}%r0
	ADDW2 &0x6,%r0
	LLSW3 &0x10,%r0,%r0
	MOVW %r0,$0x2000a7c
	CLRW %r0
	JMP l70ec
l6fe2:
	CLRH %r5
	BRB l705b
l6fe6:
	MOVH {uhalf}%r5,{uword}%r0
	LLSW3 &0x3,%r0,%r0
	CMPB &0xff,0x2000874(%r0)
	BNEB l6ffc
	BRB l706b
l6ffc:
	MOVH {uhalf}%r5,{uword}%r0
	LLSW3 &0x3,%r0,%r0
	MOVB 0x2000874(%r0),{uword}%r0
	LLSW3 &0x8,%r0,%r0
	MOVH {uhalf}%r0,{uword}%r0
	MOVH {uhalf}%r5,{uword}%r1
	LLSW3 &0x3,%r1,%r1
	MOVB 0x2000875(%r1),{uword}%r1
	ADDW2 %r1,%r0
	MOVH %r0,%r6
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x8,%r0,%r0
	ADDW2 &0x20012e8,%r0
	MOVH {uhalf}%r6,{uword}%r1
	DIVW2 {uword}&0x8,%r1
	ADDW2 %r1,%r0
	MOVH {uhalf}%r6,{uword}%r1
	MODW2 {uword}&0x8,%r1
	LLSW3 %r1,&0x1,%r1
	ORB2 %r1,(%r0)
	INCH %r5
l705b:
	MOVH {uhalf}%r5,{uword}%r0
	MOVH {uhalf}%r4,{uword}%r1
	CMPW %r1,%r0
	BLUH l6fe6
l706b:
	MOVH {uhalf}%r5,{uword}%r0
	MOVH {uhalf}%r4,{uword}%r1
	CMPW %r1,%r0
	BGEUB l707c
	BRB l70b3
l707c:
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	INCH 0x20014ec(%r0)
l708b:
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	MOVH {uhalf}0x20014ec(%r0),{uword}%r0
	MOVB 3(%ap),{uword}%r1
	LLSW3 &0x1,%r1,%r1
	MOVH {uhalf}0x20014e8(%r1),{uword}%r1
	CMPW %r1,%r0
	BLUH l6f80
l70b3:
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	MOVB 3(%ap),{uword}%r1
	LLSW3 &0x1,%r1,%r1
	MOVH {uhalf}0x20014e8(%r1),{uword}%r1
	SUBH2 &0x1,%r1
	MOVH %r1,0x20014ec(%r0)
	MOVB 3(%ap),$0x2000871
	MOVB &0x1,$0x20014f0
	MOVW &0x1,%r0
	BRB l70ec
l70ec:
	MOVAW -4(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %r6
	POPW %r5
	POPW %r4
	POPW %fp
	RET
	NOP
	NOP
	NOP

################################################################################

l7100:
	SAVE %r8
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	.byte	0x2b, 0x7f, 0xf0, 0x14, 0x00, 0x02	# TSTB $0x20014f0 # as adds NOP
	BNEB l711a
	MOVW &0x1,%r0
	JMP l7322
l711a:
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	CMPW &0xca5e600d,0x2000a84(%r0)
	BEB l7134
	CLRW %r0
	JMP l7322
l7134:
	MOVB *4(%ap),{uword}%r0
	LLSW3 &0x8,%r0,%r0
	ADDW3 &0x1,4(%ap),%r1
	MOVB (%r1),{uhalf}%r1
	ADDH2 %r1,%r0
	MOVH %r0,%r8
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x8,%r0,%r0
	ADDW2 &0x20012e8,%r0
	MOVH %r8,{word}%r1
	DIVW2 &0x8,%r1
	ADDW2 %r1,%r0
	MOVB (%r0),{uword}%r0
	MOVH %r8,{word}%r1
	MODW2 &0x8,%r1
	LLSW3 %r1,&0x1,%r1
	BITW %r0,%r1
	BNEB l7181
	MOVW &0x1,%r0
	JMP l7322
l7181:
	CMPB 3(%ap),$0x2000871
	BEB l71ce
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	PUSHW 0x2000abc(%r0)
	PUSHW &0x2000874
	PUSHW &0x0
	CALL -16(%sp),hd_acs
	TSTW %r0
	BNEB l71b7
	CLRW %r0
	JMP l7322
l71b7:
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	CLRH 0x20014ec(%r0)
	MOVB 3(%ap),$0x2000871
l71ce:
	CMPW *4(%ap),$0x2000874
	BGUB l71de
	JMP l7270
l71de:
	BRB l724d
l71e0:
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	MOVH {uhalf}0x20014ec(%r0),{uword}%r0
	BNEB l71fc
	MOVW &0x1,%r0
	JMP l7322
l71fc:
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	DECH 0x20014ec(%r0)
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	MOVB 3(%ap),{uword}%r1
	LLSW3 &0x1,%r1,%r1
	MOVH {uhalf}0x20014ec(%r1),{uword}%r1
	ADDW3 %r1,0x2000abc(%r0),%r0
	PUSHW %r0
	PUSHW &0x2000874
	PUSHW &0x0
	CALL -16(%sp),hd_acs
	TSTW %r0
	BNEB l724d
	CLRW %r0
	JMP l7322
l724d:
	CMPW *4(%ap),$0x2000874
	BGUB l71e0
	PUSHW 4(%ap)
	PUSHW &0x2000874
	CALL -8(%sp),$0x7dd6
	MOVW &0x1,%r0
	JMP l7322

l7270:
	PUSHW 4(%ap)
	PUSHW &0x2000874
	CALL -8(%sp),$0x7dd6
	TSTW %r0
	BEB l728d
	MOVW &0x1,%r0
	JMP l7322
l728d:
	BRB l72f5
l728f:
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	MOVB 3(%ap),{uword}%r1
	LLSW3 &0x1,%r1,%r1
	MOVH {uhalf}0x20014ec(%r1),{uword}%r1
	ADDW3 %r1,0x2000abc(%r0),%r0
	PUSHW %r0
	PUSHW &0x2000874
	PUSHW &0x0
	CALL -16(%sp),hd_acs
	TSTW %r0
	BNEB l72cd
	CLRW %r0
	BRB l7322
l72cd:
	PUSHW 4(%ap)
	PUSHW &0x2000874
	CALL -8(%sp),$0x7dd6
	TSTW %r0
	BEB l72e6
	MOVW &0x1,%r0
	BRB l7322
l72e6:
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	INCH 0x20014ec(%r0)
l72f5:
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	MOVH {uhalf}0x20014ec(%r0),{uword}%r0
	MOVB 3(%ap),{uword}%r1
	LLSW3 &0x1,%r1,%r1
	MOVH {uhalf}0x20014e8(%r1),{uword}%r1
	CMPW %r1,%r0
	BLUH l728f
	MOVW &0x1,%r0
	BRB l7322
l7322:
	MOVAW -20(%fp),%sp
	POPW %r8
	POPW %fp
	RET
	NOP

################################################################################
## Unknown Procedure
##

l732c:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVB &0x1,id_cmd_stat
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	PUSHW &0x20
	PUSHW &hdcspec
	PUSHW &0x8
	CALL -12(%sp),0x83(%pc)
	TSTW %r0
	BEB l7374
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	.byte	0x2c, 0xcc, 0xfc, 0xaf, 0x1f, 0x00	# CALL -4(%sp),0x1f(%pc)
	TSTW %r0
	BEB l7370
	MOVW &0x1,%r0
	BRB l7378
l7370:
	CLRW %r0
	BRB l7378
l7374:
	CLRW %r0
	BRB l7378
l7378:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################
## Unknown Procedure
##

l7380:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	CALL -4(%sp),0x2a1(%pc)
	TSTW %r0
	BNEB l739d
	CLRW %r0
	BRB l73cc
l739d:
	ORB3 &0x58,3(%ap),%r0
	PUSHW %r0
	PUSHW &0x0
	PUSHW &0x0
	.byte	0x2c, 0xcc, 0xf4, 0xaf, 0x2c, 0x00 # CALL -12(%sp),0x2c(%pc)
	ORB3 &0x58,3(%ap),%r0
	PUSHW %r0
	PUSHW &0x0
	PUSHW &0x0
	.byte	0x2c, 0xcc, 0xf4, 0xaf, 0x1b, 0x00 # CALL -12(%sp),0x1b(%pc)
	TSTW %r0
	BEB l73c8
	MOVW &0x1,%r0
	BRB l73cc
l73c8:
	CLRW %r0
	BRB l73cc
l73cc:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################
## Unknown Procedure, but something to do with accessing the hard disk.
##

l73d4:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x08, 0x00, 0x00, 0x00, 0x4c # ADDW2 &0x8,%sp
	NOP

## Save the current PSW into 20014FC
	.byte	0x84, 0x4b, 0x7f, 0xfc, 0x14, 0x00, 0x02	# MOVW %psw,$0x20014fc
	NOP
	NOP
	.byte 0xb0, 0x4f, 0x00, 0xe1, 0x01, 0x00, 0x4b	# ORW2 &0x1e100,%psw # as adds NOP

## Read the disk controller status.
	MOVB id_cmd_stat,{uword}%r0
	MOVW %r0,$0x20012d4

## If the controller available, GOTO 742D
	BITW %r0,&0x80
	BEB l742d

## If the controller is busy, move the argument into R0
	MOVB 3(%ap),{uword}%r0

## Shift it left 24 (0x18) bits (so it occupies the top byte)
	LLSW3 &0x18,%r0,%r0
	ORW2 %r0,$0x20012d4

##
	MOVB &0x8,id_cmd_stat
	.byte	0x84, 0x7f, 0xfc, 0x14, 0x00, 0x02, 0x4b	# MOVW $0x20014fc,%psw # as adds NOP
	MOVW &0x0,%r0
	JMP l7626


## Send a CLEAR BUFFER
l742d:
	MOVB &0x2,id_cmd_stat
## Send a CLEAR CE BITS
	MOVB &0x8,id_cmd_stat
## GOTO 0x7450
	BRB l7450


l743f:
	MOVW 4(%ap),%r0
	INCW 4(%ap)

## Write to data buffer
## (e.g., write 00 then 48
	MOVB (%r0),id_data
	DECB 11(%ap)

##
l7450:
	.byte	0x2b, 0x7b	# TSTB 11(%ap) # as adds NOP
	BNEB l743f

## Disk Command
	MOVB 3(%ap),id_cmd_stat
	CLRH (%fp)
	BRB l746e
l7461:
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	INCH (%fp)
l746e:
	MOVH {uhalf}(%fp),{uword}%r0
	CMPW &0xc8,%r0
	BGEUB l7485
	BITB id_cmd_stat,&0x80
	BNEB l7461
l7485:
	MOVB id_cmd_stat,{uword}%r0
	MOVW %r0,$0x20012d4
## Is the controller busy? If so jump to 74c4
	BITW %r0,&0x80
	BEB l74c4
## It's not, so...
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x18,%r0,%r0
	ORW2 %r0,$0x20012d4
	MOVB &0x8,id_cmd_stat
	.byte	0x84, 0x7f, 0xfc, 0x14, 0x00, 0x02, 0x4b	# MOVW $0x20014fc,%psw # as adds NOP
	MOVW &0x0,%r0
## Just return.
	JMP l7626

## Are any of the top bits set in our argument?
l74c4:
	BITB 3(%ap),&0xf0
	BEB l74f3
	CLRH (%fp)
	BRB l74dd
l74d0:
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	INCH (%fp)
l74dd:
	MOVH {uhalf}(%fp),{uword}%r0
	CMPW &0x5,%r0
	BGEUB l74f1
	BITB id_cmd_stat,&0x60
	BEB l74d0
l74f1:
	BRB l7512
l74f3:
	CLRW $0x20012d4
	MOVB &0x8,id_cmd_stat
	.byte	0x84, 0x7f, 0xfc, 0x14, 0x00, 0x02, 0x4b	# MOVW $0x20014fc,%psw
	MOVW &0x1,%r0
	JMP l7626
l7512:
	MOVB id_cmd_stat,{uword}%r0
	MOVW %r0,$0x20012d4

## Check for CE flags
	ANDW2 &0x60,%r0
	CMPW &0x40,%r0
## If CEH/CEL != 0x40, go to 7532
	BNEB l7532

## GOTO 0x75b7
	JMP l75b7
l7532:
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x18,%r0,%r0
	MOVB id_data,{uword}%r1
	LLSW3 &0x8,%r1,%r1
	ORW2 %r1,%r0
	ORW2 %r0,$0x20012d4
	BITW $0x20012d4,&0x2000
	BEB l756b
	BITB 3(%ap),&0xb0
	BEB l756b
	MOVB &0x1,$0x2001500
l756b:
	BITW $0x20012d4,&0x8
	BEB l75a3
	MOVW $0x20012d4,4(%fp)
	ANDB3 &0x1,3(%ap),%r0
	PUSHW %r0
	.byte	0x2c, 0xcc, 0xfc, 0xaf, 0xaa, 0xfd	# CALL -4(%sp),0xfdaa(%pc)
	TSTW %r0
	BEB l759b
	ANDB3 &0x1,3(%ap),%r0
	XORW2 &0x1,%r0
	PUSHW %r0
	.byte	0x2c, 0xcc, 0xfc, 0xaf, 0xeb, 0xfd	# CALL -4(%sp),0xfdeb(%pc)
l759b:
	MOVW 4(%fp),$0x20012d4
l75a3:
	MOVB &0x8,id_cmd_stat
	.byte	0x84, 0x7f, 0xfc, 0x14, 0x00, 0x02, 0x4b	# MOVW $0x20014fc,%psw # as adds NOP
	MOVW &0x0,%r0
	BRB l7626

l75b7:
	BITW $0x20012d4,&0x8
	BEB l760b
	MOVB 3(%ap),{uword}%r0
	LLSW3 &0x18,%r0,%r0
	ORW2 %r0,$0x20012d4
	MOVW $0x20012d4,4(%fp)
	ANDB3 &0x1,3(%ap),%r0
	PUSHW %r0
	.byte	0x2c, 0xcc, 0xfc, 0xaf, 0x4e, 0xfd	# CALL -4(%sp),0xfd4e(%pc)
	TSTW %r0
	BEB l75f7
	ANDB3 &0x1,3(%ap),%r0
	XORW2 &0x1,%r0
	PUSHW %r0
	.byte	0x2c, 0xcc, 0xfc, 0xaf, 0x8f, 0xfd	# CALL -4(%sp),0xfd8f(%pc)
l75f7:
	MOVW 4(%fp),$0x20012d4
	.byte	0x84, 0x7f, 0xfc, 0x14, 0x00, 0x02, 0x4b	# MOVW $0x20014fc,%psw
	MOVW &0x0,%r0
	BRB l7626
l760b:
	MOVB &0x8,id_cmd_stat
	CLRW $0x20012d4
	.byte	0x84, 0x7f, 0xfc, 0x14, 0x00, 0x02, 0x4b	# MOVW $0x20014fc,%psw # as adds NOP

## Why are we flagging R0?
	MOVW &0x1,%r0
	BRB l7626

l7626:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP
	NOP

################################################################################
##  Unknown Procedure
##

l7630:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	ORB3 &0x30,3(%ap),%r0
	PUSHW %r0
	PUSHW &0x0
	PUSHW &0x0
	.byte	0x2c, 0xcc, 0xf4, 0xaf, 0x91, 0xfd	# CALL -12(%sp),0xfd91(%pc)
	TSTW %r0
	BNEB l7651
	CLRW %r0
	BRB l768f
l7651:
	MOVB id_data,{uword}%r0
	MOVW %r0,$0x20012d4
	BITW %r0,&0x2
	BEB l7672
	CLRW $0x20012d4
	MOVW &0x1,%r0
	BRB l768f
l7672:
	LLSW3 &0x10,$0x20012d4,$0x20012d4
	ORW2 &0x30000000,$0x20012d4
	CLRW %r0
	BRB l768f
l768f:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP

################################################################################
## 'hd_acs' - Routine to access hard disk
##

## Here, argument 1 seems to get some kind of failure code if we can't
## access the hard drive -- I'm trying to figure out what that is.

hd_acs:
#l7698:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x14, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x14,%sp
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x41	# MULB3 &0x54,3(%ap),%r1
	.byte	0xe8, 0x81, 0xa0, 0x0a, 0x00, 0x02, 0x80, 0x9c, 0x0a, 0x00, 0x02, 0x40 # MULW3 0x2000aa0(%r1),0x2000a9c(%r0),%r0
	.byte	0xec, 0xe0, 0x40, 0x74, 0x40	# DIVW3 {uword}%r0,4(%ap),%r0
	MOVW %r0,4(%fp)
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x41	# MULB3 &0x54,3(%ap),%r1
	CMPW 0x2000a98(%r1),%r0
	BLUB l76d6
	CLRW %r0
	JMP l7879
l76d6:
	LRSW3 &0x8,4(%fp),%r0
	ANDB2 &0xff,%r0
	MOVB %r0,12(%fp)
	ANDB3 &0xff,7(%fp),%r0
	MOVB %r0,13(%fp)
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x41	# MULB3 &0x54,3(%ap),%r1
	.byte	0xe8, 0x81, 0xa0, 0x0a, 0x00, 0x02, 0x80, 0x9c, 0x0a, 0x00, 0x02, 0x40	# MULW3 0x2000aa0(%r1),0x2000a9c(%r0),%r0
	.byte	0xe4, 0xe0, 0x40, 0x74, 0x40	# MODW3 {uword}%r0,4(%ap),%r0
	MOVW %r0,(%fp)
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	.byte	0xec, 0xe0, 0x80, 0xa0, 0x0a, 0x00, 0x02, 0x59, 0x40	# DIVW3 {uword}0x2000aa0(%r0),(%fp),%r0
	MOVB %r0,14(%fp)
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	.byte	0xe4, 0xe0, 0x80, 0xa0, 0x0a, 0x00, 0x02, 0x59, 0x40	# MODW3 {uword}0x2000aa0(%r0),(%fp),%r0
	MOVB %r0,15(%fp)
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	PUSHAW 12(%fp)
## Call 0x7100
	CALL -8(%sp),$0x7100
	TSTW %r0
	BNEB l774d
	CLRW %r0
	JMP l7879
l774d:
	CMPB &0x7,14(%fp)
	BLEUB l775d
	ADDB3 &0x2,3(%ap),%r0
	MOVB %r0,17(%fp)
	BRB l7762
l775d:
	MOVB 3(%ap),17(%fp)
l7762:
	CLRH 8(%fp)
	JMP l7843
l776b:
	MOVH {uhalf}8(%fp),{uword}%r0
	BEB l7780
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
## Call 0x7380
	CALL -4(%sp),$0x7380
l7780:
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	PUSHAW 12(%fp)
## Call 0x7880
	CALL -8(%sp),0xf8(%pc)
	TSTW %r0
	BNEB l7798
	JMP l7840
l7798:
	MOVB 14(%fp),$0x20014f4
	MCOMB 12(%fp),%r0
	MOVB %r0,$0x20014f5
	MOVB 13(%fp),$0x20014f6
	MOVB 14(%fp),$0x20014f7
	MOVB 15(%fp),$0x20014f8
	MOVB &0x1,$0x20014f9
	.byte	0x2b, 0xca, 0x0f	# TSTB 15(%ap) # as adds NOP
	BNEB l77d6
	MOVW &0x4,%r0
	BRB l77d9
l77d6:
	MOVW &0x8,%r0
l77d9:
	ORB2 &0x0,%r0
	MOVB %r0,16(%fp)
	PUSHW 8(%ap)
	MOVB 16(%fp),{uword}%r0
	PUSHW %r0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	PUSHW 0x2000aa4(%r0)
## Call 0x6cec
	CALL -12(%sp),$0x6cec
	TSTW %r0
	BNEB l7805
	CLRW %r0
	BRB l7879
l7805:
	CLRB $0x2001500
	.byte	0x2b, 0xca, 0x0f	# TSTB 15(%ap) # as adds NOP
	BNEB l7818
	MOVW &0xb0,%r0
	BRB l781d
l7818:
	MOVW &0xf0,%r0
l781d:
	MOVB 17(%fp),{uword}%r1
	ORW2 %r1,%r0
	PUSHW %r0
	PUSHW &0x20014f4
	PUSHW &0x6
	CALL -12(%sp),$0x73d4
	TSTW %r0
	BEB l7840
	MOVW &0x1,%r0
	BRB l7879
l7840:
	INCH 8(%fp)
l7843:
	MOVH {uhalf}8(%fp),{uword}%r0
	CMPW &0x10,%r0
	BLUH l776b
	.byte	0x2b, 0x7f, 0x00, 0x15, 0x00, 0x02	# TSTB $0x2001500 # as adds NOP
	BEB l7875
	PUSHW &l10f4	# "id%d CRC error at disk address %08x (%d retries)\n"
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	PUSHW 12(%fp)
	PUSHW &0x10
	CALL -16(%sp),*p_printf
	CLRB $0x2001500
l7875:
	CLRW %r0
	BRB l7879
l7879:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################
## Unknown Procedure

l7880:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	CALL -4(%sp),$0x7630
	TSTW %r0
	BNEB l789f
	CLRW %r0
	BRB l78cd
l789f:
	MOVB *4(%ap),$0x20014f4
	ADDW3 &0x1,4(%ap),%r0
	MOVB (%r0),$0x20014f5
	ORB3 &0x68,3(%ap),%r0
	PUSHW %r0
	PUSHW &0x20014f4
	PUSHW &0x2
	CALL -12(%sp),$0x73d4
	BRB l78cd
l78cd:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################
## Unknown Procedure

l78d4:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x0c, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0xc,%sp
	MOVW &0x2000874,8(%fp)
	MOVB &0xff,$0x2000871
	MOVB 3(%ap),{uword}%r0
	PUSHW %r0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	SUBW3 &0x1,0x2000a98(%r0),%r0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x41	# MULB3 &0x54,3(%ap),%r1
	MULW2 0x2000a9c(%r1),%r0
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x41	# MULB3 &0x54,3(%ap),%r1
	MULW2 0x2000aa0(%r1),%r0
	PUSHW %r0
	PUSHW 8(%fp)
	PUSHW &0x0
	CALL -16(%sp),hd_acs
	TSTW %r0
	BNEB l7930
	CLRW %r0
	BRB l7982
l7930:
	CLRW (%fp)
	BRB l796b
l7935:
	CLRW 4(%fp)
	BRB l7961
l793a:
	.byte	0xe4, 0x02, 0x59, 0x40	# MODW3 &0x2,(%fp),%r0
	BEB l7948
	SUBW3 4(%fp),&0xff,%r0
	BRB l794b
l7948:
	MOVW 4(%fp),%r0
l794b:
	MOVW 8(%fp),%r1
	INCW 8(%fp)
	MOVB (%r1),{uword}%r1
	CMPW %r0,%r1
	BEB l795e
	CLRW %r0
	BRB l7982
l795e:
	INCW 4(%fp)
l7961:
	CMPW &0x100,4(%fp)
	BLB l793a
	INCW (%fp)
l796b:
	.byte	0xeb, 0x6f, 0x54, 0x73, 0x40	# MULB3 &0x54,3(%ap),%r0
	LRSW3 &0x8,0x2000aa4(%r0),%r0
	CMPW %r0,(%fp)
	BLUB l7935
	MOVW &0x1,%r0
	BRB l7982
l7982:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP
	NOP


################################################################################

l798c:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	MOVB &0x10,iu_sopr
	MOVB &0x20,iu_sopr
	MOVH {uhalf}csr_datal,{uword}%r0
	ANDW2 &0x400,%r0
	CMPW &0x400,%r0
	BEB l79ce
	MOVB &0x1,csr_fm_on	# turn floppy motor on
	PUSHW &0x12c
	CALL -4(%sp),*p_hwcntr # DUART Delay
l79ce:
	PUSHW &0xc8
	CALL -4(%sp),*p_hwcntr # DUART Delay
	MOVB &0xd0,$if_data
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	BITB $if_data,&0x80
	BEB l7a02
	.byte	0x2c, 0x5c, 0xaf, 0x3b, 0x00	# CALL (%sp),0x3b(%pc)
	CLRW %r0
	BRB l7a2d
l7a02:
	CMPB &0x1,3(%ap)
	BNEB l7a0c
	MOVW &0x4,%r0
	BRB l7a0e
l7a0c:
	CLRW %r0
l7a0e:
	ORW2 &0x8,%r0
	PUSHW %r0
	PUSHW &0x10
	.byte	0x2c, 0xcc, 0xf8, 0xaf, 0x47, 0x00	# CALL -8(%sp),0x47(%pc)
	TSTW %r0
	BEB l7a24
	MOVW &0x1,%r0
	BRB l7a2d
l7a24:
	.byte	0x2c, 0x5c, 0xaf, 0x10, 0x00	# CALL (%sp),0x10(%pc)
	CLRW %r0
	BRB l7a2d
l7a2d:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################

l7a34:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	MOVB &0x1,csr_fm_off # floppy motor off
	MOVB &0x10,iu_ropr
	MOVB &0x20,iu_ropr
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

################################################################################

l7a5c:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	BITB $if_data,&0x1
	BEB l7a76
	CLRW %r0
	JMP l7b24
l7a76:
	NOP
	.byte	0x84, 0x4b, 0x7f, 0xfc, 0x14, 0x00, 0x02	# MOVW %psw,$0x20014fc
	NOP
	NOP
	.byte	0xb0, 0x4f, 0x00, 0xe1, 0x01, 0x00, 0x4b	# ORW2 &0x1e100,%psw # as adds NOP
	MOVB 3(%ap),$if_data
	PUSHW &0x1
	PUSHW &0xe6
	CALL -8(%sp),$0x552c
	CLRW (%fp)
	BRB l7ac1
l7aa2:
	CMPW &0x64,(%fp)
	BLEB l7ab4
	.byte	0x84, 0x7f, 0xfc, 0x14, 0x00, 0x02, 0x4b	# MOVW $0x20014fc,%psw # as adds NOP
	MOVW &0x0,%r0
	BRB l7b24
l7ab4:
	PUSHW &0x1
	CALL -4(%sp),*p_hwcntr # DUART Delay
	INCW (%fp)
l7ac1:
	BITB $if_data,&0x1
	BNEB l7aa2
	ANDB3 &0xa0,3(%ap),%r0
	CMPW &0xa0,%r0
	BEB l7ae4
	ANDB3 &0xf0,3(%ap),%r0
	CMPW &0xf0,%r0
	BNEB l7af2
l7ae4:
	PUSHW &0x1
	PUSHW &0xe6
	CALL -8(%sp),$0x552c
l7af2:
	BITB $if_data,7(%ap)
	BEB l7b18
	BITB $if_data,&0x8
	BEB l7b0c
	MOVB &0x1,$0x2001500
l7b0c:
	.byte	0x84, 0x7f, 0xfc, 0x14, 0x00, 0x02, 0x4b	# MOVW $0x20014fc,%psw # as adds NOP
	MOVW &0x0,%r0
	BRB l7b24
l7b18:
	#MOVW $0x20014fc,%psw
	.byte	0x84, 0x7f, 0xfc, 0x14, 0x00, 0x02, 0x4b	# MOVW $0x20014fc,%psw # as adds NOP
	MOVW &0x1,%r0
	BRB l7b24
l7b24:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################
## 'fd_acs' - Routine to access floppy disk
##

fd_acs:
#l7b2c:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x0c, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0xc,%sp
	.byte	0xec, 0xe0, 0x12, 0x5a, 0x40	# DIVW3 {uword}&0x12,(%ap),%r0
	CMPW &0x50,%r0
	BLUB l7b48
	CLRW %r0
	JMP l7d94
l7b48:
	.byte	0x2b, 0xca, 0x0f	# TSTB 15(%ap) # as adds NOP
	BEB l7b53
	CMPB &0x3,15(%ap)
	BNEB l7bca
l7b53:
	PUSHW &0x1
	CALL -4(%sp),$0x798c
	TSTW %r0
	BNEB l7b69
	CLRW %r0
	JMP l7d94
l7b69:
	MOVB &0xff,$0x2000871
	CLRB $0x2000870
	PUSHW &0x58e
	PUSHW &0x2000874
	PUSHW &0x0
	PUSHW &0x1
	CALL -16(%sp),-92(%pc)
	TSTW %r0
	BNEB l7b99
	CLRW %r0
	JMP l7d94
l7b99:
	CMPW &0xca5e600d,$0x2000878
	BNEB l7bbc
	MOVH $0x20008b2,$0x2001502
	MOVB &0x1,$0x2000870
	BRB l7bca
l7bbc:
	CLRH $0x2001502
	CLRB $0x2000870
l7bca:
	CLRB 8(%fp)
	.byte	0xec, 0xe0, 0x12, 0x5a, 0x40	# DIVW3 {uword}&0x12,(%ap),%r0
	MOVB %r0,9(%fp)
	.byte	0xe4, 0xe0, 0x12, 0x5a, 0x40	# MODW3 {uword}&0x12,(%ap),%r0
	DIVW2 {uword}&0x9,%r0
	MOVB %r0,10(%fp)
	.byte	0xe4, 0xe0, 0x09, 0x5a, 0x40	# MODW3 {uword}&0x9,(%ap),%r0
	MOVB %r0,11(%fp)
	.byte	0x2b, 0x7f, 0x70, 0x08, 0x00, 0x02	# TSTB $0x2000870 # as adds NOP
	BEB l7c52
	CMPB &0x2,$0x2000871
	BEB l7c44
	MOVB &0xff,$0x2000871
	CLRB $0x2000870
	MOVH $0x2001502,{word}%r0
	PUSHW %r0
	PUSHW &0x2000874
	PUSHW &0x0
	PUSHW &0x1
	.byte	0x2c, 0xcc, 0xf0, 0xaf, 0x0a, 0xff	# CALL -16(%sp),0xff0a(%pc)
	TSTW %r0
	BNEB l7c34
	CLRW %r0
	JMP l7d94
l7c34:
	MOVB &0x2,$0x2000871
	MOVB &0x1,$0x2000870
l7c44:
	PUSHAW 8(%fp)
	PUSHW &0x2000874
	CALL -8(%sp),0x18a(%pc)
l7c52:
	MOVB &0x9c,6(%fp)
	CMPB &0x1,11(%ap)
	BNEB l7c6f
	MOVB &0x49,4(%fp)
	MOVB &0xa0,5(%fp)
	ORB2 &0x40,6(%fp)
	BRB l7c7a
l7c6f:
	MOVB &0x45,4(%fp)
	MOVB &0x80,5(%fp)
l7c7a:
	MOVB 10(%fp),{uword}%r0
	LLSW3 &0x1,%r0,%r0
	ORB2 &0x8,%r0
	ORB2 %r0,5(%fp)
	CLRH 2(%fp)
	CLRH (%fp)
	JMP l7d30
l7c95:
	MOVB 9(%fp),{uword}%r0
	PUSHW %r0
	CALL -4(%sp),0x101(%pc)
	TSTW %r0
	BNEB l7cbd
	PUSHW &0x1
	CALL -4(%sp),$0x798c
	TSTW %r0
	BNEB l7cbb
	CLRW %r0
	JMP l7d94
l7cbb:
	BRB l7d2d
l7cbd:
	ADDB3 &0x1,11(%fp),%r0
	MOVB %r0,$if_base+2
	PUSHW 4(%ap)
	MOVB 4(%fp),{uword}%r0
	PUSHW %r0
	PUSHW &0x200
	CALL -12(%sp),$0x6cec
	TSTW %r0
	BNEB l7ce9
	CLRW %r0
	JMP l7d94
l7ce9:
	CLRB $0x2001500
	MOVB 5(%fp),{uword}%r0
	PUSHW %r0
	MOVB 6(%fp),{uword}%r0
	PUSHW %r0
	CALL -8(%sp),$0x7a5c
	TSTW %r0
	BEB l7d0e
	MOVH &0x1,2(%fp)
	BRB l7d36
l7d0e:
	BITB $if_data,&0x80
	BEB l7d1b
	BRB l7d36
l7d1b:
	PUSHW &0x1
	CALL -4(%sp),$0x798c
	TSTW %r0
	BNEB l7d2d
	CLRW %r0
	BRB l7d94
l7d2d:
	INCH (%fp)
l7d30:
	CMPH &0x10,(%fp)
	BLH l7c95
l7d36:
	.byte	0x2b, 0x7f, 0x00, 0x15, 0x00, 0x02	# TSTB $0x2001500
	BEB l7d57
	PUSHW &l1128	# "if CRC error at disk address %08x (%d retries)\n"
	PUSHW 8(%fp)
	PUSHW &0x10
	CALL -12(%sp),*p_printf
	CLRB $0x2001500
l7d57:
	.byte	0x2a, 0x62	# TSTH 2(%fp) # as adds NOP
	BEB l7d67
	CMPB &0x2,15(%ap)
	BEB l7d67
	CMPB &0x3,15(%ap)
	BNEB l7d8e
l7d67:
	.byte	0x2b, 0x7f, 0x70, 0x08, 0x00, 0x02	# TSTB $0x2000870
	BEB l7d87
	CLRB $0x2000870
	CLRH $0x2001502
	MOVB &0xff,$0x2000871
l7d87:
	CALL (%sp),$0x7a34
l7d8e:
	MOVH 2(%fp),{word}%r0
	BRB l7d94
l7d94:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP


################################################################################

l7d9c:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x0,%sp
	CMPB 3(%ap),$if_cmd_stat
	BNEB l7db3
	MOVW &0x1,%r0
	BRB l7dce
l7db3:
	MOVB 3(%ap),$if_base+3
	PUSHW &0x1c
	PUSHW &0x10
	CALL -8(%sp),$0x7a5c
	MOVH {uhalf}%r0,{uword}%r0
	BRB l7dce
l7dce:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP

################################################################################

l7dd6:
	SAVE %fp
	.byte	0x9c, 0x4f, 0x04, 0x00, 0x00, 0x00, 0x4c	# ADDW2 &0x4,%sp
	CLRH (%fp)
	BRB l7e24
l7de4:
	MOVH (%fp),{word}%r0
	LLSW3 &0x3,%r0,%r0
	ADDW2 4(%ap),%r0
	CMPW *0(%ap),(%r0)
	BNEB l7e0b
	MOVH (%fp),{word}%r0
	LLSW3 &0x3,%r0,%r0
	ADDW2 4(%ap),%r0
	MOVW 4(%r0),*0(%ap)
	MOVW &0x1,%r0
	BRB l7e2e
l7e0b:
	MOVH (%fp),{word}%r0
	LLSW3 &0x3,%r0,%r0
	ADDW2 4(%ap),%r0
	CMPW *0(%ap),(%r0)
	BLEUB l7e21
	MOVW &0x1,%r0
	BRB l7e2e
l7e21:
	INCH (%fp)
l7e24:
	CMPH &0x40,(%fp)
	BLB l7de4
	CLRW %r0
	BRB l7e2e
l7e2e:
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP
	NOP

################################################################################

l73e8:
	SAVE %r7
	MOVW (%ap),%r1
	MOVW &0x0,%r7
	MOVB (%r1),{uword}%r8
	.byte	0x3b, 0x88, 0x71, 0x11, 0x00, 0x00, 0x04	# BITB 0x1171(%r8),&0x4
	BNEB l7e91
	BRB l7e60
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET
l7e5a:
	INCW %r1
	MOVB (%r1),{uword}%r8
l7e60:
	.byte	0x3b, 0x88, 0x71, 0x11, 0x00, 0x00, 0x08	# BITB 0x1171(%r8),&0x8
	BNEB l7e5a
	CMPW %r8,&0x2b
	BEB l7e75
	CMPW %r8,&0x2d
	BNEB l7e7b
	INCW %r7
l7e75:
	INCW %r1
	MOVB (%r1),{uword}%r8
l7e7b:
	.byte	0x3b, 0x88, 0x71, 0x11, 0x00, 0x00, 0x04	# BITB 0x1171(%r8),&0x4
	BNEB l7e91
	CLRW %r0
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET
l7e91:
	SUBW3 %r8,&0x30,%r2
	BRB l7ea1
l7e97:
	MULW2 &0xa,%r2
	SUBW3 %r8,&0x30,%r0
	ADDW2 %r0,%r2
l7ea1:
	INCW %r1
	MOVB (%r1),{uword}%r8
	.byte	0x3b, 0x88, 0x71, 0x11, 0x00, 0x00, 0x04	# BITB 0x1171(%r8),&0x4
	BNEB l7e97
	TSTW %r7
	BEB l7ec2
	MOVW %r2,%r0
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET
l7ec2:
	MNEGW %r2,%r0
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET

################################################################################

l7ed0:
	SAVE %r7
	MOVW (%ap),%r1
	MOVW &0x0,%r7
	MOVB (%r1),{uword}%r8
	.byte	0x3b, 0x88, 0x71, 0x11, 0x00, 0x00, 0x04	# BITB 0x1171(%r8),&0x4
	BNEB l7f29
	BRB l7ef8
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET
l7ef2:
	INCW %r1
	MOVB (%r1),{uword}%r8
l7ef8:
	.byte	0x3b, 0x88, 0x71, 0x11, 0x00, 0x00, 0x08	# BITB 0x1171(%r8),&0x8
	BNEB l7ef2
	CMPW %r8,&0x2b
	BEB l7f0d
	CMPW %r8,&0x2d
	BNEB l7f13
	INCW %r7
l7f0d:
	INCW %r1
	MOVB (%r1),{uword}%r8
l7f13:
	.byte	0x3b, 0x88, 0x71, 0x11, 0x00, 0x00, 0x04	# BITB 0x1171(%r8),&0x4
	BNEB l7f29
	CLRW %r0
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET
l7f29:
	SUBW3 %r8,&0x30,%r2
	BRB l7f39
l7f2f:
	MULW2 &0xa,%r2
	SUBW3 %r8,&0x30,%r0
	ADDW2 %r0,%r2
l7f39:
	INCW %r1
	MOVB (%r1),{uword}%r8
	.byte	0x3b, 0x88, 0x71, 0x11, 0x00, 0x00, 0x04	# BITB 0x1171(%r8),&0x4
	BNEB l7f2f
	TSTW %r7
	BEB l7f5a
	MOVW %r2,%r0
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET
l7f5a:
	MNEGW %r2,%r0
	MOVAW -16(%fp),%sp
	POPW %r8
	POPW %r7
	POPW %fp
	RET

################################################################################
## 'strcmp' Routine
##

strcmp:
#l7f68:
	SAVE %fp
	MOVW (%ap),%r0
	MOVW 4(%ap),%r1
	CMPW %r1,%r0
	BNEB l7f7b
	BRB l7f85
l7f77:
	INCW %r0
	INCW %r1
l7f7b:
	CMPB (%r1),(%r0)
	BNEB l7f85
	CMPB (%r0),&0x0
	BNEB l7f77
l7f85:
	SUBB3 (%r1),(%r0),%r0
	MOVB {sbyte}%r0,{word}%r0
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP
	NOP
	NOP

################################################################################

l7f98:
	SAVE %fp
	MOVW (%ap),%r0
	BRB l7fa1
l7f9f:
	INCW %r0
l7fa1:
	.byte	0x2b, 0x50	# TSTB (%r0) # as adds #NOP
	BNEB l7f9f
	SUBW2 (%ap),%r0
	MOVAW -24(%fp),%sp
	POPW %fp
	RET
	NOP


################################################################################
## Unknown routine.
##

l7fb0:
	SAVE %fp
	MOVW (%ap),%r1
	MOVW 4(%ap),%r0
	STRCPY
	MOVW (%ap),%r0
	MOVAW -24(%fp),%sp
	POPW %fp
	RET

## Filling bytes

	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0x25
	.byte	0x72

## Serial Number Structure

#  struct serno {
#                  char fill0;
#                  char fill1;
#                  char fill2;
#                  char serial0;
#                  char fill4;
#                  char fill5;
#                  char fill6;
#                  char serial1;
#                  char fill8;
#                  char fill9;
#                  char filla;
#                  char serial2;
#                  char fillc;
#                  char filld;
#                  char fille;
#                  char serial3;
#  } ;
#  

serno:
#l7ff0:
	.byte	0x22	# fill0
	.byte	0x22	# fill1
	.byte	0x22	# fill2
	.byte	0x22	# serial0
	.byte	0x03	# fill4
	.byte	0x02	# fill5
	.byte	0x01	# fill6
	.byte	0x30	# serial1
	.byte	0x03	# fill8
	.byte	0x02	# fill9
	.byte	0x01	# filla
	.byte	0x0e	# serial2
	.byte	0x03	# fillc
	.byte	0x02	# filld
	.byte	0x01	# fille
	.byte	0x0b	# serial3

