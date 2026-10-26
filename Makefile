AS := nasm
AS_FLAGS := -f elf64
NAME := libasm.a
BUILD_DIR ?= .build

VPATH = src
SRCS := ft_strlen.s \
		ft_strcpy.s

OBJS := $(addprefix $(BUILD_DIR)/, $(SRCS:.s=.o))
DEPS := $(OBJS:.o=.d)


all: $(NAME)

$(NAME): $(BUILD_DIR) $(OBJS)
	ar rcs $(NAME) $(OBJS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	$(AS) $(AS_FLAGS) -o $@ $<

clean:
	rm -f $(OBJS) $(DEPS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re

-include $(DEPS)
