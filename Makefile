AS := nasm
AS_FLAGS := -f elf64 -g -F dwarf
NAME := libasm.a
BUILD_DIR ?= .build

VPATH = src
SRCS := ft_strlen.s \
		ft_strcpy.s \
		ft_strcmp.s \
		ft_write.s \
		ft_read.s \
		ft_strdup.s \
		ft_calloc.s

OBJS := $(addprefix $(BUILD_DIR)/, $(SRCS:.s=.o))
DEPS := $(OBJS:.o=.d)

BONUS_SRCS := ft_atoi_base.s
BONUS_OBJS := $(addprefix $(BUILD_DIR)/, $(BONUS_SRCS:.s=.o))
BONUS_DEPS := $(BONUS_OBJS:.o=.d)
BONUS_STAMP := $(BUILD_DIR)/.bonus

CC := cc
CFLAGS := -Wall -Wextra -Werror -g -Iinclude
TEST_BIN := $(BUILD_DIR)/test

GDB_BREAK ?= main
GDB_FLAGS := -q -tui \
			 -ex 'set disassembly-flavor intel' \
			 -ex 'layout asm' \
			 -ex 'layout regs' \
			 -ex 'break $(GDB_BREAK)' \
			 -ex 'run' \
			 -ex 'set step-mode on'

all: $(NAME)

# rm avant ar : `ar r` ne retire jamais un membre, un vieux bonus resterait dedans
$(NAME): $(OBJS)
	rm -f $@
	ar rcs $@ $^

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	$(AS) $(AS_FLAGS) -MD $(@:.o=.d) -o $@ $<

test: $(TEST_BIN)
	./$(TEST_BIN)

# make debug GDB_BREAK=ft_strlen pour s'arreter directement dans une fonction
debug: $(TEST_BIN)
	gdb $(GDB_FLAGS) $(TEST_BIN)

# On lie les objets directement : make suit chaque .o, archive ou pas a jour
$(TEST_BIN): main.c $(OBJS) $(BONUS_OBJS) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f $(OBJS) $(DEPS) $(BONUS_OBJS) $(BONUS_DEPS) $(TEST_BIN) $(BONUS_STAMP)

fclean: clean
	rm -f $(NAME)

re: fclean all

bonus: $(BONUS_STAMP)

# Fichier temoin : bonus ne refait l'archive que si un objet a change
$(BONUS_STAMP): $(OBJS) $(BONUS_OBJS) | $(BUILD_DIR)
	rm -f $(NAME)
	ar rcs $(NAME) $(OBJS) $(BONUS_OBJS)
	touch $@


.PHONY: all clean fclean re test bonus debug

-include $(DEPS) $(BONUS_DEPS)
