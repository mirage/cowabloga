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
  (* Cannot be inlined below as the $ is interpreted as an antiquotation *)
  let js_init = [`Data "$(document).foundation(); hljs.initHighlightingOnLoad();"] in
  <:html<
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width"/>
      <title>$str:title$</title>
      <link rel="stylesheet" href="/css/foundation.min.css"> </link>
      <link rel="stylesheet" href="/css/magula.css"> </link>
      <link rel="stylesheet" href="/css/site.css"> </link> 
      <script src="https://google-code-prettify.googlecode.com/svn/loader/run_prettify.js?lang=ml"></script>
      <script src="/js/vendor/custom.modernizr.js"> </script>
      <script src="/js/vendor/highlight.pack.js"> </script>
      <script src="/js/vendor/jquery.js"> </script>
      <script src="/js/foundation.js"> </script>
      <script src="/js/foundation/foundation.topbar.js"> </script>
      $headers$
    </head>
    <body>
      $content$
      <script> $js_init$ </script> 
    </body>
  >>

let top_nav ~title ~title_uri ~nav_links =
  <:html<
  <div class="contain-to-grid fixed">
  <nav class="top-bar" data-topbar="">
  <ul class="title-area">
    <li class="name">
      <h1><a href="$uri:title_uri$">$str:title$</a></h1>
    </li>
    <li class="toggle-topbar menu-icon"><a href="#"><span>Menu</span></a></li>
  </ul>
  <section class="top-bar-section">
      $nav_links$
  </section>
  </nav>
  </div>
  >>

let page ~body =
  Printf.sprintf "\
<!DOCTYPE html>
  <!--[if IE 8]><html class=\"no-js lt-ie9\" lang=\"en\" ><![endif]-->
  <!--[if gt IE 8]><!--><html class=\"no-js\" lang=\"en\" ><!--<![endif]-->
  %s
</html>" (Cow.Html.to_string body)
