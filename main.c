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

static int	sign(int n)
{
	return ((n > 0) - (n < 0));
}

static void	test_strcmp(const char *s1, const char *s2)
{
	int	expected;
	int	got;

	got = ft_strcmp(s1, s2);
	expected = strcmp(s1, s2);
	printf("[%s] ft_strcmp(\"%s\", \"%s\") = %d (attendu %d)\n",
		sign(got) == sign(expected) ? "OK" : "KO", s1, s2, got, expected);
}

int	main(void)
{
	test_strlen("");
	test_strlen("a");
	test_strlen("hello");
	test_strlen("une chaine un peu plus longue que les autres");
	test_strcmp("", "");
	test_strcmp("Tripouille", "Tripouille");
	test_strcmp("Tripouille", "tripouille");
	test_strcmp("Tripouille", "TriPouille");
	test_strcmp("Tripouille", "TripouillE");
	test_strcmp("Tripouille", "TripouilleX");
	test_strcmp("Tripouille", "Tripouill");
	return (0);
}
