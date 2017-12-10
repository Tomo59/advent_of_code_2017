#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <regex.h>

#include <vpi_user.h>
#include "svdpi.h"

typedef struct regular_expression
{
    regex_t preg;
    char *regex;
} regular_expression_s;

// return 1 if s2 is containt in s1
int dpi_strstr(const char *s1, const char *s2)
{
  return strstr(s1, s2) != NULL;
}

// return a pointer containing the compiled regular expression
// can take a previous pointer to replace what is needed inside
regular_expression_s* dpi_create_regexp(regular_expression_s* exp, const char *regex_string)
{
  regular_expression_s* actual_exp;

  if (exp == NULL)
  {
    actual_exp = (regular_expression_s*) malloc(sizeof(regular_expression_s));
    if (actual_exp == NULL)
    {
      fprintf(stderr, "Couldn't allocate memory\n");
      return NULL;
    }
  }
  else
  {
    // return previous exp if regex_string didn't change
    if (strcmp(exp->regex, regex_string) == 0)
      return exp;

    // free previous regular_expression
    free(exp->regex);
    regfree(&exp->preg);

    actual_exp = exp;
  }

  if (regcomp(&actual_exp->preg, regex_string, REG_NOSUB) != 0)
  {
    fprintf(stderr, "Couldn't create the regexp\n");
    return NULL;
  }

  // copy the string in actual_exp in order to compare to it later
  actual_exp->regex = strdup(regex_string);

  return actual_exp;
}

// return 1 if string match the regular expression contained in exp
int dpi_match_regexp(regular_expression_s* exp, const char *string)
{
  return regexec(&exp->preg, string, 0, NULL, 0) == 0;
}
