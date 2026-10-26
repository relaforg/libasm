#include <stdio.h>
#include <string.h>
#include "libasm.h"

static void	test_strlen(const char *s)
{
	size_t	expected;
	size_t	got;

	expected = strlen(s);
	got = ft_strlen(s);
	printf("[%s] ft_strlen(\"%s\") = %zu (attendu %zu)\n",
		got == expected ? "OK" : "KO", s, got, expected);
}

int	main(void)
{
	test_strlen("");
	test_strlen("a");
	test_strlen("hello");
	test_strlen("une chaine un peu plus longue que les autres");
	return (0);
}
