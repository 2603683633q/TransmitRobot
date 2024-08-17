##########################################################################################################################
# File automatically-generated by tool: [projectgenerator] version: [4.2.0-B44] date: [Sat Aug 17 14:51:18 CST 2024] 
##########################################################################################################################

# ------------------------------------------------
# Generic Makefile (based on gcc)
#
# ChangeLog :
#	2017-02-10 - Several enhancements + project update mode
#   2015-07-22 - first version
# ------------------------------------------------

######################################
# target
######################################
TARGET = stm32f4_demo


######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization
OPT = -Og


#######################################
# paths
#######################################
# Build path
BUILD_DIR = build

######################################
# source
######################################
PROJ_DIR = Src \
Inc \
Apps \
Modules \
Bsp \
Drivers 

# 快速递归搜索当前目录下的.c文件,需在msys2/MinGW环境使用(Windows下),linux/macOS则可以直接使用
# windows下使用命令行(cmd)或powershell时,替换注释的内容.

# for unix/linux/macOS or Msys2/MinGW bash:
#ALL_DIRS := $(foreach dire, $(PROJ_DIR), $(shell find $(dire) -maxdepth 10 -type d))
#for windows cmd/pwsh:
SHELL = cmd
ALL_DIRS := $(foreach dire, $(PROJ_DIR), $(shell dir $(dire) /s /b /a:d))
ALL_DIRS += $(PROJ_DIR)

C_SOURCES := $(foreach dire, $(ALL_DIRS), $(wildcard $(dire)/*.c))

# ASM sources
ASM_SOURCES =  \
startup_stm32f407xx.s

# ASM sources
ASMM_SOURCES = 


#######################################
# binaries
#######################################
PREFIX = arm-none-eabi-
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)gcc
AS = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
else
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
 
#######################################
# CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m4

# fpu
FPU = -mfpu=fpv4-sp-d16

# float-abi
FLOAT-ABI = -mfloat-abi=hard

# mcu
MCU = $(CPU) -mthumb -mthumb-interwork $(FPU) $(FLOAT-ABI)

# macros for gcc
# AS defines
AS_DEFS = 

# C defines
C_DEFS =  \
-DUSE_HAL_DRIVER \
-DSTM32F407xx \
-DARM_MATH_CM4

# AS includes
AS_INCLUDES =  \
-IInc

# C includes
# 快速递归添加包含目录
C_INCLUDES := $(addprefix -I,$(ALL_DIRS))


# compile gcc flags
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -fdata-sections -ffunction-sections

CFLAGS += $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -fdata-sections -ffunction-sections -fmessage-length=0

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = STM32F407VETx_FLASH.ld

# libraries
LIBS = -lc -lm -lnosys 
LIBDIR = 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASMM_SOURCES:.S=.o)))
vpath %.S $(sort $(dir $(ASMM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@
$(BUILD_DIR)/%.o: %.S Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir $@		

#######################################
# clean up
#######################################
clean:
	rd $(BUILD_DIR) /s/q
  
  
#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)


#######################################
# download directl without debugging
#######################################
download_dap:
	openocd -f openocd_dap.cfg -c init -c halt -c "flash write_image erase $(BUILD_DIR)/$(TARGET).bin 0x08000000" -c reset -c shutdown
download_jlink:
	JFlash -openprj'stm32.jflash' -open'$(BUILD_DIR)/$(TARGET).hex',0x8000000 -auto -startapp -exit

# *** EOF ***
