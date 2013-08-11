#define _GNU_SOURCE

#include <curl/curl.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <json.h>

#include "webapi.h"
#include "print.h"

#define BUFSIZE 1024
static char BUF[BUFSIZE];
static char *buf;

static size_t data_read(char *ptr, size_t size, size_t nmemb, void *userdata)
{
  size = size * nmemb;
  if (size + buf > (BUF + BUFSIZE))
    size = BUF - buf + BUFSIZE;
  
  memcpy(buf, ptr, size);
  buf += size;
  
  return size;
}

char * post(char * path, char * payload)
{
  static CURL *curl = NULL;
  CURLcode res;

  if (!curl) {
    curl_global_init(CURL_GLOBAL_ALL);
    curl = curl_easy_init();
  }
  
  if(curl) {
    char url[128];
    snprintf(url, 128, "http://icfp2013lf.herokuapp.com/%s?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H", path);
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, payload);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, data_read); 
    buf = BUF;

    puts(payload);

    res = curl_easy_perform(curl);
    /* Check for errors */
    if(res != CURLE_OK) {
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(res));
      return NULL;
    }
    
    *buf = 0;
    
    puts(BUF);
  }
  
  return BUF;
}

static int download_problem(int size)
{
  char * request;
  if (asprintf(&request, "{\"size\": %d, \"operators\": [\"tfold\"]}", size) == -1) {
    puts("error asprintfing");
    return -1;
  }
  
  post("train", request);
  
  free(request);
  return 0;
}

static bv_mask mask_of_op(const char * op)
{
  if (strcmp(op, "not") == 0)
    return BV_NOT_MASK;
  if (strcmp(op, "shl1") == 0)
    return BV_SHL1_MASK;
  if (strcmp(op, "shr1") == 0)
    return BV_SHR1_MASK;
  if (strcmp(op, "shr4") == 0)
    return BV_SHR4_MASK;
  if (strcmp(op, "shr16") == 0)
    return BV_SHR16_MASK;
  if (strcmp(op, "and") == 0)
    return BV_AND_MASK;
  if (strcmp(op, "or") == 0)
    return BV_OR_MASK;
  if (strcmp(op, "xor") == 0)
    return BV_XOR_MASK;
  if (strcmp(op, "plus") == 0)
    return BV_PLUS_MASK;
  if (strcmp(op, "if0") == 0)
    return BV_IF0_MASK;
  if (strcmp(op, "fold") == 0)
    return BV_FOLD_MASK;
  if (strcmp(op, "tfold") == 0)
    return BV_TFOLD_MASK;
  if (strcmp(op, "bonus") == 0)
    return BV_BONUS_MASK;
  return -1;
}

bv_problem parse_problem(const char * json)
{
  json_object *spec, *id, *size, *ops;

  if (!(spec = json_tokener_parse(json))) goto bad;
  if (!json_object_object_get_ex(spec, "id", &id)) goto bad;
  if (!json_object_object_get_ex(spec, "size", &size)) goto bad;
  if (!json_object_object_get_ex(spec, "operators", &ops)) goto bad;
  
  bv_problem prob;
  
  size_t idlen = json_object_get_string_len(id);
  if (idlen + 1 > sizeof(prob.id)) goto bad;
  memcpy(prob.id, json_object_get_string(id), idlen);
  prob.id[idlen] = 0;
  
  prob.size = json_object_get_int(size);

  prob.ops = 0;
  int opsct = json_object_array_length(ops);
  for (int i = 0; i < opsct; ++i)
    prob.ops |= mask_of_op(json_object_get_string(json_object_array_get_idx(ops, i)));
  
  json_object_put(spec);
  return prob;
  
  bad:
  puts("bad problem");
  prob.size = 0;
  return prob;
}

bv_problem get_training_problem(int _size)
{
  bv_problem prob;
  prob.size = 0;
  
  if (download_problem(_size) != 0) return prob;
  return parse_problem(BUF);
}

char guess_solution(bv_problem problem, bv_expr solution, bv_example *ex)
{
  char sendbuf[1024];
  snprintf(sendbuf, 1024, "{\"id\": \"%s\", \"program\": \"%s\"}", problem.id, bv_print_program(solution));
  if (!post("guess", sendbuf))
    return -3;
  
  json_object *spec, *status, *values;

  if (!(spec = json_tokener_parse(BUF))) return -1;
  
  int result = -2;
  
  if (!json_object_object_get_ex(spec, "status", &status)) goto end;

  const char * status_t = json_object_get_string(status);
  if (strcmp(status_t, "mismatch") == 0) {
    if (ex) {
      if (!json_object_object_get_ex(spec, "values", &values)) goto end;
      ex->input = strtoull(json_object_get_string(json_object_array_get_idx(values, 0)), NULL, 16);
      ex->output = strtoull(json_object_get_string(json_object_array_get_idx(values, 1)), NULL, 16);
    }
    result = 1;
  } else if (strcmp(status_t, "win") == 0)
    result = 0;
  
  end:
  json_object_put(spec);
  return result;
}
