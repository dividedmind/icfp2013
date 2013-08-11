#define _GNU_SOURCE

#include <curl/curl.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "webapi.h"

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

bv_problem get_training_problem(int size)
{
  static CURL *curl = NULL;
  CURLcode res;

  if (!curl) {
    curl_global_init(CURL_GLOBAL_ALL);
    curl = curl_easy_init();
  }
  
  if(curl) {
    curl_easy_setopt(curl, CURLOPT_URL, "http://icfp2013lf.herokuapp.com/train?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H");
    char * request;
    if (asprintf(&request, "{\"size\": %d}", size) == -1) {
      puts("error asprintfing");
      return;
    }
    
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, request);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, data_read); 
    buf = BUF;

    res = curl_easy_perform(curl);
    /* Check for errors */
    if(res != CURLE_OK)
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(res));
    
    *buf = 0;
    
    free(request);
  }
  
  puts(BUF);
}
