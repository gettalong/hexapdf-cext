# hexapdf-cext

This library provides implementations of some HexaPDF algorithms in C so as to make HexaPDF still faster.

## Usage

Install the library via Rubygems `gem install hexapdf-cext`. Current versions of HexaPDF automatically look for this gem and activate it if it is found.

To manually activate the library use `require 'hexapdf/cext'`.

## Implemented Algorithms

* Separation of alpha channel from image data for PNG images.

## License

MIT - see LICENSE file.

## Author

Thomas Leitner <t_leitner@gmx.at>
