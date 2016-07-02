CC=gcc
LD=ld
OBJCOPY=objcopy

CFLAGS=-g -c
TRIM_FLAGS=-R .pdr -R .comment -R.note -S -O binary

LDFILE_BOOT=solrex_x86_boot.ld
LDFILE_DOS=solrex_x86_dos.ld
LDFLAGS_BOOT=-T$(LDFILE_BOOT)
LDFLAGS_DOS=-T$(LDFILE_DOS)

all: boot.img LOADER.BIN
	@echo '#################################################################'
	@echo '# Compiling work finished, now you can use "sudo make copy" to'
	@echo '# copy LOADER.BIN into boot.img'
	@echo '#################################################################'

boot.bin: boot.S
	$(CC) $(CFLAGS) boot.S
	$(LD) boot.o -o boot.elf $(LDFLAGS_BOOT)
	$(OBJCOPY) $(TRIM_FLAGS) boot.elf $@

LOADER.BIN: loader.S
	$(CC) $(CFLAGS) loader.S
	$(LD) loader.o -o loader.elf $(LDFLAGS_DOS)
	$(OBJCOPY) $(TRIM_FLAGS) loader.elf $@

boot.img: boot.bin
	@dd if=boot.bin of=boot.img bs=512 count=1
	@dd if=/dev/zero of=boot.img skip=1 seek=1 bs=512 count=2879

# You must have the authority to do mount, or you must use "su root" or
# "sudo" command to do "make copy"
copy: boot.img LOADER.BIN
	@sudo mkdir -p /tmp/floppy;\
	sudo mount -o loop boot.img /tmp/floppy/ -o fat=12;\
	sudo cp LOADER.BIN /tmp/floppy/;\
	sudo umount /tmp/floppy/;\
	sudo rm -rf /tmp/floppy/;

clean: 
	rm -f *.o *.elf *.bin *.BIN

distclean: clean
	rm -f *.img
	rm -f *.zip 

release: clean copy 
		@mv boot.img solrex.img

zip: release
		-rm *.zip
			-zip -rq solrex.zip solrex.img

send: zip 
		@scp solrex.zip wushan@lindc.rhrk.uni-kl.de:tmp/solrex/
			@ssh -l wushan lindc.rhrk.uni-kl.de prepare

