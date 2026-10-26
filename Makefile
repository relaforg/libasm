AS := nasm
AS_FLAGS := -f elf64
NAME := libasm.a
BUILD_DIR ?= .build

VPATH = src
SRCS := ft_strlen.s \
		ft_strcpy.s \
		ft_strcmp.s \
		ft_write.s \
		ft_read.s

OBJS := $(addprefix $(BUILD_DIR)/, $(SRCS:.s=.o))
DEPS := $(OBJS:.o=.d)

CC := cc
CFLAGS := -Wall -Wextra -Werror -g -Iinclude
TEST_BIN := $(BUILD_DIR)/test


all: $(NAME)

$(NAME): $(BUILD_DIR) $(OBJS)
	ar rcs $(NAME) $(OBJS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	$(AS) $(AS_FLAGS) -o $@ $<

test: $(TEST_BIN)
	./$(TEST_BIN)

$(TEST_BIN): main.c $(NAME) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ main.c $(NAME)

clean:
	rm -f $(OBJS) $(DEPS) $(TEST_BIN)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re test

-include $(DEPS)
