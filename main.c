#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <unistd.h>
#include "libasm.h"

#define GREEN	"\033[32m"
#define RED		"\033[31m"
#define RESET	"\033[0m"
#define OK		GREEN "OK" RESET
#define KO		RED "KO" RESET

/*
** Compare ft_simd_memchr a memchr sur le meme appel.
*/
static void	check(const char *label, const void *s, int c, size_t n)
{
	void	*got;
	void	*expected;

	got = ft_simd_memchr(s, c, n);
	expected = memchr(s, c, n);
	printf("[%s] %-42s got %p, attendu %p\n",
		got == expected ? OK : KO, label, got, expected);
}

static void	test_basics(void)
{
	char	str[] = "Hello, SIMD world! Cette chaine fait plus de 16 octets.";

	check("premier octet", str, 'H', sizeof(str));
	check("au milieu", str, 'S', sizeof(str));
	check("premiere occurrence parmi plusieurs", str, 'o', sizeof(str));
	check("le \\0 final", str, '\0', sizeof(str));
	check("absent", str, 'Z', sizeof(str));
	check("n = 0", str, 'H', 0);
	check("present mais apres n", str, 'w', 5);
	check("pile a l'index n - 1", str, 'o', 5);
}

/*
** c est un int converti en unsigned char : 0x141 cherche 0x41, -1 cherche 0xff.
*/
static void	test_byte_values(void)
{
	unsigned char	all[256];
	int				i;

	for (i = 0; i < 256; i++)
		all[i] = (unsigned char)i;
	check("c = 0x00", all, 0x00, sizeof(all));
	check("c = 0x7f", all, 0x7f, sizeof(all));
	check("c = 0x80 (bit de signe)", all, 0x80, sizeof(all));
	check("c = 0xff", all, 0xff, sizeof(all));
	check("c = -1 (cherche 0xff)", all, -1, sizeof(all));
	check("c = 0x141 (cherche 0x41)", all, 0x141, sizeof(all));
}

/*
** Toutes les combinaisons alignement de s / n / position de la cible.
** Les octets AVANT s valent la cible : une lecture arrondie vers le bas
** dont on n'ignore pas le debut les trouverait a tort.
** pos peut depasser n : la cible est alors hors zone, on attend NULL.
*/
static void	test_exhaustive(void)
{
	static unsigned char	buf[192] __attribute__((aligned(64)));
	size_t					off;
	size_t					n;
	size_t					pos;
	size_t					total;
	size_t					fails;

	total = 0;
	fails = 0;
	for (off = 0; off < 32; off++)
		for (n = 0; n <= 80; n++)
			for (pos = 0; pos <= n + 16; pos++)
			{
				memset(buf, 'A', off);
				memset(buf + off, 'x', sizeof(buf) - off);
				buf[off + pos] = 'A';
				total++;
				if (ft_simd_memchr(buf + off, 'A', n) == memchr(buf + off, 'A', n))
					continue ;
				if (fails++ == 0)
					printf("     1er echec : s %% 64 = %zu, n = %zu, cible a s[%zu]\n",
						off, n, pos);
			}
	printf("[%s] %zu / %zu combinaisons correctes\n",
		fails == 0 ? OK : KO, total - fails, total);
}

/*
** Buffer de len octets colle contre une page PROT_NONE (apres si at_end,
** avant sinon) : toute lecture qui deborde dans cette page fait un SIGSEGV.
** L'appel tourne dans un fils pour survivre au crash et le signaler.
** Si with_target, la cible est le dernier octet du buffer et n peut le depasser.
*/
static void	check_guarded(const char *label, int at_end, size_t len,
	size_t n, int with_target)
{
	size_t			ps;
	unsigned char	*map;
	unsigned char	*s;
	void			*expected;
	pid_t			pid;
	int				status;

	ps = (size_t)sysconf(_SC_PAGESIZE);
	map = mmap(NULL, 3 * ps, PROT_READ | PROT_WRITE,
			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	if (map == MAP_FAILED)
		return (perror("mmap"));
	mprotect(map, ps, PROT_NONE);
	mprotect(map + 2 * ps, ps, PROT_NONE);
	memset(map + ps, 'x', ps);
	s = at_end ? map + 2 * ps - len : map + ps;
	if (with_target)
		s[len - 1] = 'A';
	expected = with_target ? s + len - 1 : NULL;
	fflush(stdout);
	pid = fork();
	if (pid == 0)
		_exit(ft_simd_memchr(s, 'A', n) == expected ? 0 : 1);
	waitpid(pid, &status, 0);
	if (WIFSIGNALED(status))
		printf("[%s] %-42s CRASH (%s)\n", KO, label, strsignal(WTERMSIG(status)));
	else
		printf("[%s] %-42s %s\n", WEXITSTATUS(status) == 0 ? OK : KO, label,
			WEXITSTATUS(status) == 0 ? "" : "mauvais resultat");
	munmap(map, 3 * ps);
}

static void	test_page_boundaries(void)
{
	size_t	ps;

	ps = (size_t)sysconf(_SC_PAGESIZE);
	check_guarded("fin de page, n = 1, absent", 1, 1, 1, 0);
	check_guarded("fin de page, n = 7, absent", 1, 7, 7, 0);
	check_guarded("fin de page, n = 16, absent", 1, 16, 16, 0);
	check_guarded("fin de page, n = 17, absent", 1, 17, 17, 0);
	check_guarded("fin de page, n = 100, absent", 1, 100, 100, 0);
	check_guarded("fin de page, cible au dernier octet", 1, 100, 100, 1);
	check_guarded("debut de page, n = 3, absent", 0, 3, 3, 0);
	check_guarded("page entiere, absent", 0, ps, ps, 0);
	check_guarded("n > buffer, cible au dernier octet", 1, 37, 1000, 1);
	check_guarded("n = SIZE_MAX, cible au dernier octet", 1, 37, SIZE_MAX, 1);
}

int	main(void)
{
	printf("== Cas de base ==\n");
	test_basics();
	printf("\n== Valeurs de c ==\n");
	test_byte_values();
	printf("\n== Alignements x longueurs x positions ==\n");
	test_exhaustive();
	printf("\n== Bords de page (pages PROT_NONE autour) ==\n");
	test_page_boundaries();
	return (0);
}
