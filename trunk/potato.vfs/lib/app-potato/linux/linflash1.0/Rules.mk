OBJS-linflash := $(linflash_dir)/flash.o
TARGETS-linflash := $(linflash_dir)/flash.so 

$(TARGETS-linflash):: $(OBJS-linflash)
	@$(echo_link_so_addlibs)
	@$(link_so_addlibs)


all:: $(TARGETS-linflash)

clean:: clean-linflash

clean-linflash::
	rm -f $(TARGETS-linflash) $(OBJS-linflash)

