CC=gcc
LD=ld
OBJCOPY=objcopy

CBFLAGS= -g -I boot/include/ -c 
CKFLAGS=-g -I include/ -c -fno-builtin
TRIM_FLAGS=-R .pdr -R .comment -R.note -S -O binary

LDFILE_BOOT=boot/solrex_x86_boot.ld
LDFILE_DOS=boot/solrex_x86_dos.ld
LDFILE_KERNEL=kernel/solrex_x86_kernel.ld

LDFLAGS_BOOT=-T$(LDFILE_BOOT)
LDFLAGS_DOS=-T$(LDFILE_DOS)
LDFLAGS_KERNEL=-s -T$(LDFILE_KERNEL)

BOOTBIN= boot/boot.bin boot/loader.bin
KERNELBIN= kernel.bin
KERNELOBJS= kernel/kernel.o kernel/start.o kernel/i8259.o kernel/global.o kernel/protect.o lib/klib.o lib/kliba.o lib/string.o

.PHONY: all copy clean distclean release zip send 

all: boot.img $(BOOTBIN) $(KERNELBIN)
	@echo '#################################################################'
	@echo '# Compiling work finished, now you can use "sudo make copy" to'
	@echo '# copy KERNEL.BIN into boot.img'
	@echo '#################################################################'

boot/boot.bin: boot/boot.S 
	$(CC) $(CBFLAGS) -o boot/boot.o boot/boot.S
	$(LD) boot/boot.o -o boot/boot.elf $(LDFLAGS_BOOT)
	$(OBJCOPY) $(TRIM_FLAGS) boot/boot.elf $@

boot/loader.bin: boot/loader.S
	$(CC) $(CBFLAGS) -o boot/loader.o boot/loader.S
	$(LD) boot/loader.o -o boot/loader.elf $(LDFLAGS_DOS)
	$(OBJCOPY) $(TRIM_FLAGS) boot/loader.elf $@

$(KERNELBIN) : $(KERNELOBJS)
		$(LD) -o $(KERNELBIN) $(KERNELOBJS) $(LDFLAGS_KERNEL) 

lib/klib.o: lib/klib.c include/type.h include/const.h include/protect.h \
	  include/proto.h include/string.h include/global.h
	$(CC) $(CKFLAGS) -o $@ $<

lib/kliba.o: lib/klib.S
	$(CC) $(CKFLAGS) -o $@ $<

lib/string.o: lib/string.S
	$(CC) $(CKFLAGS) -o $@ $<

kernel/global.o: kernel/global.c include/type.h include/const.h include/proto.h \
	  include/protect.h include/global.h
	$(CC) $(CKFLAGS) -o $@ $<

kernel/i8259.o: kernel/i8259.c include/type.h include/const.h include/proto.h \
		  include/protect.h
	$(CC) $(CKFLAGS) -o $@ $<

kernel/kernel.o: kernel/kernel.S
	$(CC) $(CKFLAGS) -o $@ $<

kernel/protect.o: kernel/protect.c include/type.h include/const.h \
	  include/protect.h include/global.h include/proto.h
	$(CC) $(CKFLAGS) -o $@ $<

kernel/start.o: kernel/start.c include/type.h include/const.h include/protect.h
	$(CC) $(CKFLAGS) -o $@ $<

boot.img: boot/boot.bin
	@dd if=boot/boot.bin of=boot.img bs=512 count=1
	@dd if=/dev/zero of=boot.img skip=1 seek=1 bs=512 count=2879

# You must have the authority to do mount, or you must use "su root" or
# "sudo" command to do "make copy"
copy: all
	@sudo mkdir -p /tmp/floppy;\
	sudo mount -o loop boot.img /tmp/floppy/ -o fat=12;\
	sudo cp boot/loader.bin /tmp/floppy/LOADER.BIN;\
	sudo cp kernel.bin /tmp/floppy/KERNEL.BIN;\
	sudo umount /tmp/floppy/;\
	sudo rm -rf /tmp/floppy/;

clean: 
	@rm -f *.o *.elf *.bin *.BIN
	@rm -f boot/*.o boot/*.elf boot/*.bin boot/*.BIN
	@rm -f lib/*.o lib/*.elf lib/*.bin lib/*.BIN
	@rm -f kernel/*.o kernel/*.elf kernel/*.bin kernel/*.BIN

distclean: clean
	@rm -f *.img
	@rm -f *.zip 

release: clean copy 
	@mv boot.img solrex.img

zip: release
	-rm *.zip
	-zip -rq solrex.zip solrex.img

send: zip 
	@scp solrex.zip wushan@lindc.rhrk.uni-kl.de:tmp/solrex/
	@ssh -l wushan lindc.rhrk.uni-kl.de prepare
