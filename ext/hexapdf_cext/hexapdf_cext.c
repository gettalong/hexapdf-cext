#include <errno.h>
#include "ruby/ruby.h"
#include "string.h"

VALUE HexaPDFCExt = Qnil;

void Init_hexapdf_cext();

VALUE separate_alpha_channel_loop(VALUE self, VALUE data, VALUE bytes_per_row, VALUE bytes_per_colors,
                                  VALUE bytes_per_alpha, VALUE image_data, VALUE mask_data) {
  long bpr = NUM2LONG(bytes_per_row);
  long bpc = NUM2LONG(bytes_per_colors);
  long bpa = NUM2LONG(bytes_per_alpha);
  char* data_ptr = RSTRING_PTR(data);
  long data_length = RSTRING_LEN(data);

  for (char* current = data_ptr; bpr <= data_length; data_length -= bpr) {
    char* end = current + bpr;
    rb_str_cat(image_data, current, 1);
    rb_str_cat(mask_data, current, 1);
    current++;
    while (current < end) {
      rb_str_cat(image_data, current, bpc);
      current += bpc;
      rb_str_cat(mask_data, current, bpa);
      current += bpa;
    }
  }

  return Qnil;
}

void Init_hexapdf_cext() {
    HexaPDFCExt = rb_define_module("HexaPDFCExt");
    rb_define_module_function(HexaPDFCExt, "separate_alpha_channel_loop", separate_alpha_channel_loop, 6);
}
