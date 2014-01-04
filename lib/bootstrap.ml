(*
 * Copyright (c) 2014 Richard Mortier <mort@cantab.net>
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

let body ?google_analytics ~title ~headers content =
  let ga = match google_analytics with
    | None -> []
    | Some (a,d) ->
      <:html<
        <script type="text/javascript">
          //<![CDATA[
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', '$[`Data a]$']);
          _gaq.push(['_setDomainName', '$[`Data d]$']);
          _gaq.push(['_trackPageview']);

          (function() {
             var ga = document.createElement('script');
             ga.type = 'text/javascript'; ga.async = true;
             ga.src =
               ('https:' == document.location.protocol
               ? 'https://ssl'
               : 'http://www') + '.google-analytics.com/ga.js';
             var s = document.getElementsByTagName('script')[0];
             s.parentNode.insertBefore(ga, s);
           })();
          //]]>
        </script>
      >>
  in
  <:html<
    <head>
      <meta charset="utf-8" />
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
      <meta name="viewport"
            content="width=device-width, initial-scale=1, maximum-scale=1" />

      <!-- Le HTML5 shim, for IE6-8 support of HTML elements -->
      <!--[if lt IE 9]>
        <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"> </script>
      <![endif]-->

      <title>$str:title$</title>

      <link rel="stylesheet" media="screen" type="text/css"
            href="/css/bootstrap.min.css"> </link>
      <link rel="stylesheet" media="screen" type="text/css"
            href="/css/bootstrap-responsive.min.css"> </link>
      <link rel="stylesheet" href="/css/site.css"> </link>

      <script src="/js/jquery-1.9.1.min.js"> </script>
      <script src="/js/bootstrap.min.js"> </script>

      $headers$
    </head>
    <body>
      <div class="container-fluid">
        $content$
      </div>

      $ga$
    </body>
  >>

let page ?(ns="") body =
  Printf.sprintf "\
<!DOCTYPE html>
  <html $str:ns$>
  %s
</html>" (Cow.Html.to_string body)
