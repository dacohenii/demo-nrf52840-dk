#------------------------------------------
# Project Name
#
PROJECT := demo_nrf52840_dk

#----------------------------------------
# Project Directories
#

# Root directory
PROJ_DIR			:= .
# Nordic SDK
SDK_DIR				:= $(PROJ_DIR)/nRF5_SDK_17

LD_SCRIPT := $(PROJ_DIR)/linker/nrf52.ld


INCLUDES := \
	-I$(PROJ_DIR)/modules \
  	-I$(SDK_DIR)/modules/nrfx \
  	-I$(SDK_DIR)/modules/nrfx/soc \
  	-I$(SDK_DIR)/modules/nrfx/mdk \
  	-I$(SDK_DIR)/modules/nrfx/hal \
  	-I$(SDK_DIR)/modules/nrfx/drivers \
  	-I$(SDK_DIR)/modules/nrfx/drivers/include \
  	-I$(SDK_DIR)/modules/nrfx/drivers/src \
  	-I$(SDK_DIR)/modules/nrfx/drivers/src/prs \
  	-I$(SDK_DIR)/modules/nrfx/templates \
  	-I$(SDK_DIR)/modules/nrfx/templates/nRF52840 \
  	-I$(SDK_DIR)/modules/nrfx/helpers \
  	-I$(SDK_DIR)/components/toolchain/cmsis/include



#------------------------------------------
# Files
#




# Assembler Source Files
STARTUP_SRCS +=

ASM_SRCS +=

# C source files
C_SRCS   += \
	$(PROJ_DIR)/app/main.c \
	$(PROJ_DIR)/modules/ledctrl.c \
	$(PROJ_DIR)/modules/ticks.c \


# C++ source Files
CXX_SRCS +=

# SDK Assembly Files
SDK_ASM_SRCS += \
	$(SDK_DIR)/modules/nrfx/mdk/gcc_startup_nrf52840.S \

# SDK Source Files
SDK_C_SRCS += \
	$(SDK_DIR)/modules/nrfx/mdk/system_nrf52840.c \


LIB_DIRS :=

LIBS := 

# combine all the sources...
ASM_SRCS += $(SDK_ASM_SRCS)
C_SRCS += $(SDK_C_SRCS)
C_SRCS += $(OS_C_SRCS)
CXX_SRCS += $(SDK_CXX_SRCS)

#------------------------------------
# GNU-ARM toolset
# Toolchain commands
CC      := "$(GNU_INSTALL_ROOT)/$(GNU_PREFIX)-gcc"
CXX     := "$(GNU_INSTALL_ROOT)/$(GNU_PREFIX)-c++"
AS      := "$(GNU_INSTALL_ROOT)/$(GNU_PREFIX)-as"
AR      := "$(GNU_INSTALL_ROOT)/$(GNU_PREFIX)-ar" -r
LD      := "$(GNU_INSTALL_ROOT)/$(GNU_PREFIX)-ld"
NM      := "$(GNU_INSTALL_ROOT)/$(GNU_PREFIX)-nm"
OBJDUMP := "$(GNU_INSTALL_ROOT)/$(GNU_PREFIX)-objdump"
OBJCOPY := "$(GNU_INSTALL_ROOT)/$(GNU_PREFIX)-objcopy"
SIZE    := "$(GNU_INSTALL_ROOT)/$(GNU_PREFIX)-size"

$(if $(shell $(CC) --version),,$(info Cannot find: $(CC).) \
$(info Please set values in: "$(abspath $(TOOLCHAIN_CONFIG_FILE))") \
$(info according to the actual configuration of your system.) \
$(error Cannot continue))
########################################################################################
# Typically, you should not need to change anything below this line

MKDIR	:= mkdir
RM		:= rm -rf

# echo suspend
ifeq ($(VERBOSE),1)
NO_ECHO :=
else
NO_ECHO := @
endif


#FLAGS-----------------------------------------


# Assembler flags common to all targets
ASMFLAGS += -x assembler-with-cpp
ASMFLAGS += -mcpu=cortex-m4
ASMFLAGS += -mthumb -mabi=aapcs
ASMFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
ASMFLAGS += -DBOARD_PCA10056
ASMFLAGS += -DFLOAT_ABI_HARD
ASMFLAGS += -DNRF52840_XXAA
ASMFLAGS += -D__HEAP_SIZE=8192
ASMFLAGS += -D__STACK_SIZE=8192


CFLAGS += -DBOARD_PCA10056
CFLAGS += -DFLOAT_ABI_HARD
CFLAGS += -DNRF52840_XXAA
CFLAGS += -mcpu=cortex-m4
CFLAGS += -mthumb -mabi=aapcs
CFLAGS += -Wall -Werror
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
# keep every function in a separate section, this allows linker to discard unused ones
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin -fshort-enums
CFLAGS += -ffile-prefix-map=\app=.





BIN_DIR := _dbg
ASMFLAGS += -g
CFLAGS += -Wall -Werror -g -gstrict-dwarf


# C++ flags common to all targets
CXXFLAGS +=



DEP_DIR := $(BIN_DIR)/.d
#---------------------------------------------------

# Link Flags
LDFLAGS += -mthumb -mabi=aapcs -L$(PROJ_DIR)/linker -T$(LD_SCRIPT)
LDFLAGS += -mcpu=cortex-m4
LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
LDFLAGS += -Wl,--gc-sections
# use newlib in nano version
LDFLAGS += -lc -lm -lnosys --specs=nano.specs



# Create List of required objects and require depedency files
# $1 list of soure files
# $2 Obj variable
define get_object_files
$(foreach src_file, $(1), \
	$(eval obj_file := $(DEP_DIR)/$(strip $(notdir $(src_file))).o) \
	$(eval DEPENDENCIES += $(patsubst %.o,%.d, $(obj_file))) \
	$(eval $(2) += $(obj_file)) \
	$(eval $(obj_file) := $(src_file)))
endef


$(call get_object_files, $(C_SRCS),C_OBJS_EXT)

$(call get_object_files, $(STARTUP_SRCS),STARTUP_OBJS_EXT)

$(call get_object_files, $(ASM_SRCS),ASM_OBJS_EXT)

$(call get_object_files, $(CXX_SRCS),CXX_OBJS_EXT)



TARGET_HEX := $(BIN_DIR)/$(PROJECT).hex
TARGET_BIN := $(BIN_DIR)/$(PROJECT).bin
TARGET_OUT := $(BIN_DIR)/$(PROJECT).out



#----------------------------------------------------------------
# Rules
#



.PHONY : clean all default help $(PROJECT)

all: $(PROJECT)


CLEAN_DIR := _rel _dbg
clean: clean_main

clean_main:
	$(foreach dir,$(CLEAN_DIR), \
	$(RM) $(dir)/*.o \
	$(dir)/*.d \
	$(dir)/*.bin \
	$(dir)/*.out \
	$(dir)/*.map; \
	$(RM) $(dir))



$(PROJECT): $(TARGET_OUT) $(TARGET_HEX) $(TARGET_BIN)


$(TARGET_OUT): $(C_OBJS_EXT) $(STARTUP_OBJS_EXT) $(ASM_OBJS_EXT) $(CXX_OBJS_EXT)



$(DEP_DIR):
	$(shell mkdir -p $@>/dev/null)

DEPFLAGS = -MT $@ -MP -MD -MF $(DEP_DIR)/$*.Td

COMPILE.c = $(NO_ECHO) $(CC) $(DEPFLAGS) -std=c99 $(CFLAGS) $(INCLUDES) -c
COMPILE.cxx = $(NO_ECHO) $(CXX) $(DEPFLAGS) $(CXXFLAGS) $(INCLUDES) -c
COMPILE.S = $(NO_ECHO) $(CC) $(DEPFLAGS) -std=c99 $(ASMFLAGS) $(INCLUDES) -c
POSTCOMPILE = $(NO_ECHO)mv -f $(DEP_DIR)/$*.Td $(@:.o=.d)


$(DEP_DIR)/%.c.o : $(DEP_DIR)/%.c.d | $(DEP_DIR)
	$(COMPILE.c) -o $@ "$($@)"
	$(POSTCOMPILE)

$(DEP_DIR)/%.cpp.o : $(DEP_DIR)/%.cpp.d | $(DEP_DIR)
	$(COMPILE.cxx) -o $@ "$($@)"
	$(POSTCOMPILE)

$(DEP_DIR)/%.S.o : $(DEP_DIR)/%.S.d | $(DEP_DIR)
	$(COMPILE.S) -o $@ "$($@)"
	$(POSTCOMPILE)


export FILE_LIST
DUMP_FILE_LIST := \
"$(MAKE)" -s --no-print-directory -f filelist.mk


%.out:
	$(eval FILE_LIST := $^ $(LIBS))
	$(NO_ECHO)$(DUMP_FILE_LIST) > $(@:.out=.in)
	@echo Linking Target: $@
	@echo Hi everybody!: $^
	$(CC) -Wl,-Map=$(@:.out=.map)  @$(@:.out=.in) $(LDFLAGS) -o $@
	-@echo ''
	$(NO_ECHO)$(SIZE) $@
	-@echo ''


%.bin: %.out
	@echo Preparing: $@
	$(NO_ECHO)$(OBJCOPY) -O binary $< $@

%.hex: %.out
	@echo Preparing: $@
	$(NO_ECHO)$(OBJCOPY) -O ihex $< $@


$(DEP_DIR)/%.d: ;

.PRECIOUS: $(DEP_DIR)/%.d

# include dependency files only if our goal depends on their existence
ifneq ($(MAKECMDGOALS),clean)
-include $(DEPENDENCIES)
endif
