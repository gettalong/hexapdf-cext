require 'hexapdf/image_loader/png'

module HexaPDF
  module CExt
    module ImageLoaderPNG

      # Faster version of this method by moving the inner loop to C.
      def separate_alpha_channel(offset, decode_parms)
        bytes_per_colors = (decode_parms[:BitsPerComponent] * decode_parms[:Colors] + 7) / 8
        bytes_per_alpha = (decode_parms[:BitsPerComponent] + 7) / 8
        bytes_per_row = (decode_parms[:Columns] * decode_parms[:BitsPerComponent] *
          (decode_parms[:Colors] + 1) + 7) / 8 + 1
        image_data = ''.b
        mask_data = ''.b

        flate_decode = @document.config.constantize('filter.map', :FlateDecode)
        source = flate_decode.decoder(Fiber.new(&image_data_proc(offset)))
        image_deflate = Zlib::Deflate.new(HexaPDF::GlobalConfiguration['filter.flate_compression'],
                                          Zlib::MAX_WBITS,
                                          HexaPDF::GlobalConfiguration['filter.flate_memory'])
        mask_deflate = Zlib::Deflate.new(HexaPDF::GlobalConfiguration['filter.flate_compression'],
                                         Zlib::MAX_WBITS,
                                         HexaPDF::GlobalConfiguration['filter.flate_memory'])
        data = ''.b
        image_temp = ''.b
        mask_temp = ''.b
        while source.alive? && (new_data = source.resume)
          data << new_data
          image_temp.clear
          mask_temp.clear
          HexaPDFCExt.separate_alpha_channel_loop(data, bytes_per_row, bytes_per_colors,
                                                  bytes_per_alpha, image_temp, mask_temp)
          image_data << image_deflate.deflate(image_temp)
          mask_data << mask_deflate.deflate(mask_temp)
        end
        image_data << image_deflate.finish
        mask_data << mask_deflate.finish

        return [image_data, mask_data]
      end

    end
  end
end

HexaPDF::ImageLoader::PNG.prepend(HexaPDF::CExt::ImageLoaderPNG)
