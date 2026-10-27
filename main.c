#include <stdio.h>
#include "libasm.h"

#define GREEN	"\033[32m"
#define RED		"\033[31m"
#define RESET	"\033[0m"

/*
** Pas d'equivalent dans la libc : on compare a une valeur attendue
** fournie a la main.
*/
static void	test_atoi_base(char *str, char *base, int expected)
{
	int	got;

	got = ft_atoi_base(str, base);
	printf("[%s] ft_atoi_base(\"%s\", \"%s\") = %d (attendu %d)\n",
		got == expected ? GREEN "OK" RESET : RED "KO" RESET,
		str, base, got, expected);
}

int	main(void)
{
	// test_atoi_base("123", "", 0);
	// test_atoi_base("123", "a", 0);
	// test_atoi_base("123", "adfd", 0);
	// test_atoi_base("123", "+qwert", 0);
	// test_atoi_base("123", "-qwert", 0);
	// test_atoi_base("123", "0123456789", 123);
	// test_atoi_base("ff", "0123456789abcdef", 255);
	// test_atoi_base("+123", "0123456789", 123);
	test_atoi_base("-ffz", "0123456789abcdef", -255);
	test_atoi_base("", "01", 0);
	return (0);
}
