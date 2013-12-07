(*
 * Copyright (c) 2013 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

let body ~title ~headers ~content =
  <:html<
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width"/>
      <title>$str:title$</title>
      <link rel="stylesheet" href="/css/foundation.min.css"> </link>
      <link rel="stylesheet" href="/css/site.css"> </link>
      <script src="/js/vendor/custom.modernizr.js"> </script>

      $headers$
    </head>
    <body>
      $content$
    </body>
  >>

let page ~body =
  Printf.sprintf "\
<!DOCTYPE html>
  <!--[if IE 8]><html class=\"no-js lt-ie9\" lang=\"en\" ><![endif]-->
  <!--[if gt IE 8]><!--><html class=\"no-js\" lang=\"en\" ><!--<![endif]-->
  %s
</html>" (Cow.Html.to_string body)
