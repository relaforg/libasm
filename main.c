#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
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

static int	is_zeroed(const unsigned char *p, size_t n)
{
	size_t	i;

	i = 0;
	while (i < n)
	{
		if (p[i] != 0)
			return (0);
		i++;
	}
	return (1);
}

/*
** On salit d'abord un bloc de meme taille puis on le libere : malloc
** a de grandes chances de le redonner a ft_calloc. Sans ca, la memoire
** fraiche venant du noyau est deja a zero et le test passerait a tort.
*/
static void	test_calloc_zeroed(size_t nmemb, size_t size)
{
	void	*dirty;
	void	*got;
	size_t	total;

	total = nmemb * size;
	dirty = malloc(total);
	if (dirty)
		memset(dirty, 0xAA, total);
	free(dirty);
	got = ft_calloc(nmemb, size);
	printf("[%s] ft_calloc(%zu, %zu) : non NULL et rempli de zeros\n",
		got != NULL && is_zeroed(got, total) ? "OK" : "KO", nmemb, size);
	free(got);
}

/*
** Taille totale nulle : NULL ou pointeur unique sont tous deux permis,
** on exige juste le meme choix que la libc (et free doit l'accepter).
*/
static void	test_calloc_empty(size_t nmemb, size_t size)
{
	void	*expected;
	void	*got;

	expected = calloc(nmemb, size);
	got = ft_calloc(nmemb, size);
	printf("[%s] ft_calloc(%zu, %zu) = %s (attendu %s)\n",
		(got == NULL) == (expected == NULL) ? "OK" : "KO", nmemb, size,
		got ? "ptr" : "NULL", expected ? "ptr" : "NULL");
	free(expected);
	free(got);
}

/*
** nmemb * size depasse SIZE_MAX : calloc doit renvoyer NULL et mettre
** errno a ENOMEM, pas allouer le resultat tronque de la multiplication.
*/
static void	test_calloc_overflow(size_t nmemb, size_t size)
{
	void	*got;
	int		err;

	errno = 0;
	got = ft_calloc(nmemb, size);
	err = errno;
	printf("[%s] ft_calloc(%zu, %zu) = %p, errno = %d (attendu NULL, %d)\n",
		got == NULL && err == ENOMEM ? "OK" : "KO", nmemb, size, got, err,
		ENOMEM);
	free(got);
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
	test_calloc_zeroed(1, 1);
	test_calloc_zeroed(10, sizeof(int));
	test_calloc_zeroed(3, 7);
	test_calloc_zeroed(1, 1 << 20);
	test_calloc_empty(0, 0);
	test_calloc_empty(0, 42);
	test_calloc_empty(42, 0);
	test_calloc_overflow(SIZE_MAX, 2);
	test_calloc_overflow(SIZE_MAX / 2 + 1, 2);
	test_calloc_overflow((size_t)1 << 32, (size_t)1 << 32);
	return (0);
}
