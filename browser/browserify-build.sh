#!/bin/sh

# This mechanism could offer simple variations on the build.
# Features could be productively grouped for smaller file size
# eg: I/O, Affine Transforms, Bitmap Operations, Gamma Curves, and Layers
# Initial Build includes everything except file IO, which is browser-incompatible
cd ${0%/*}
echo "Browserifying browser/jimp.js..."
ENVIRONMENT=BROWSER \
browserify -t envify -t uglifyify ../index.js > tmp1.js
echo "Translating for ES5..."
babel tmp1.js -o tmp.js --presets es2015,stage-0


# A TRUE hack. Use strict at the top seems to cause problems for ie10 interpreting this line from bmp-js:
# https://github.com/shaozilee/bmp-js/blob/master/lib/decoder.js
# module.exports = decode = function(bmpData) { ...
# For some reason, babeljs misses this "error" but IE can parse the code fine without strict mode.
echo "Removing Strict Mode."
sed "s/^\"use strict\";//" tmp.js > tmp-nostrict.js

echo "Adding Web Worker wrapper functions..."
cat tmp-nostrict.js src/jimp-wrapper.js > lib/jimp.js
echo "Minifying browser/jimp.min.js..."
uglifyjs lib/jimp.js --compress warnings=false --mangle -o lib/jimp.min.js
echo "Cleaning up...."
rm tmp*