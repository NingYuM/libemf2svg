#include <emf2svg.h>
#include <emscripten/emscripten.h>
#include <stdlib.h>
#include <string.h>

EMSCRIPTEN_KEEPALIVE
char *emf2svg_convert(char *emf_data, int emf_length) {
    char *svg_out = NULL;
    size_t svg_out_len = 0;

    generatorOptions options;
    options.nameSpace = NULL;
    options.verbose = false;
    options.emfplus = true;
    options.svgDelimiter = true;
    options.imgHeight = 0;
    options.imgWidth = 0;

    int ret = emf2svg(emf_data, (size_t)emf_length, &svg_out, &svg_out_len,
                      &options);
    if (ret != 0) {
        free(svg_out);
        return NULL;
    }

    return svg_out;
}

EMSCRIPTEN_KEEPALIVE
void emf2svg_free(char *ptr) {
    free(ptr);
}
