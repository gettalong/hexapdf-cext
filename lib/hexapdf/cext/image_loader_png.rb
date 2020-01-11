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
        ideflater = Zlib::Deflate.new(HexaPDF::GlobalConfiguration['filter.flate_compression'],
                                     Zlib::MAX_WBITS,
                                     HexaPDF::GlobalConfiguration['filter.flate_memory'])
        mdeflater = Zlib::Deflate.new(HexaPDF::GlobalConfiguration['filter.flate_compression'],
                                     Zlib::MAX_WBITS,
                                     HexaPDF::GlobalConfiguration['filter.flate_memory'])
        data = ''.b
        mresult = ''.b
        iresult = ''.b
        while source.alive? && (new_data = source.resume)
          data << new_data
          iresult.clear
          mresult.clear
          HexaPDFCExt.separate_alpha_channel_loop(data, bytes_per_row, bytes_per_colors,
                                                  bytes_per_alpha, iresult, mresult)
          data = data[-(data.length % bytes_per_row)..-1]
          image_data << ideflater.deflate(iresult)
          mask_data << mdeflater.deflate(mresult)
        end
        image_data << ideflater.finish
        mask_data << mdeflater.finish

        return [image_data, mask_data]
      end

    end
  end
end

HexaPDF::ImageLoader::PNG.prepend(HexaPDF::CExt::ImageLoaderPNG)
