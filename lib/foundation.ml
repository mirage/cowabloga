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

module Link = struct
  type t = string * Uri.t
  type links = t list
  let link ?(cl="") (txt,uri) =
    <:html<<a href=$uri:uri$ class=$str:cl$>$str:txt$</a>&>>

  let mk_ul_links ~cl ~links =
    let items = List.map (fun l -> <:html<<li>$l$</li>&>>) links in
    <:html<<ul class=$str:cl$>$list:items$</ul>&>>

  let top_nav ?(align=`Right) (links:links) =
    let links = List.map link links in
    let cl = match align with `Right -> "right" | `Left -> "left" in
    mk_ul_links ~cl ~links

  let button_group (links:links) =
    let links = List.map (link ~cl:"button") links in
    mk_ul_links ~cl:"button-group" ~links

  let side_nav (links:links) =
    let links = List.map link links in
    mk_ul_links ~cl:"side-nav" ~links

  let bottom_nav (links:links) =
    let links = List.map link links in
    mk_ul_links ~cl:"inline-list right" ~links
end

module Sidebar = struct
  type t = [
   | `link of Link.t
   | `active_link of Link.t
   | `divider
   | `text of string
   | `html of Cow.Xml.t
  ]

  let t ~title ~content =
    let to_html (x:t) =
      match x with
      |`link l -> <:html<<li>$Link.link l$</li>&>>
      |`active_link l -> <:html<<li class="active">$Link.link l$</li>&>>
      |`divider -> <:html<<li class="divider" />&>>
      |`html h -> <:html<<li>$h$</li>&>>
      |`text t -> <:html<<li>$str:t$</li>&>>
    in
    let rec make = function
      |[] -> Cow.Html.nil
      |hd::tl -> <:html<$to_html hd$$make tl$>> in
    <:html<<h5>$str:title$</h5>
    <ul class="side-nav">
    $make content$
    </ul>
     >>
end

let body ?google_analytics ~title ~headers ~content () =
  (* Cannot be inlined below as the $ is interpreted as an antiquotation *)
  let js_init = [`Data "$(document).foundation(); hljs.initHighlightingOnLoad();"] in
  let ga =
    match google_analytics with
    | None -> []
    | Some a -> <:html<
         <script type="text/javascript">
           //<![CDATA[
           var _gaq = _gaq || [];
           _gaq.push(['_setAccount', '$[`Data a]$']);
           _gaq.push(['_setDomainName', 'openmirage.org']);
           _gaq.push(['_trackPageview']);

           (function() {
              var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
              ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
              var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            })();
           //]]>
         </script> >>
  in
  <:html<
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width"/>
      <title>$str:title$</title>
      <link rel="stylesheet" href="/css/foundation.min.css"> </link>
      <link rel="stylesheet" href="/css/magula.css"> </link>
      <link rel="stylesheet" href="/css/site.css"> </link> 
      <script src="/js/vendor/custom.modernizr.js"> </script>
      $ga$
      $headers$
    </head>
    <body>
      $content$
      <script src="/js/vendor/jquery.js"> </script>
      <script src="/js/foundation.js"> </script>
      <script src="/js/foundation/foundation.topbar.js"> </script>
      <script src="/js/vendor/highlight.pack.js"> </script>
      <script> $js_init$ </script> 
    </body>
  >>

let top_nav ~title ~title_uri ~nav_links =
  <:html<
    <div class="contain-to-grid fixed">
    <nav class="top-bar" data-topbar="">
    <ul class="title-area">
    <li class="name"><h1><a href="$uri:title_uri$">$title$</a></h1></li>
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
