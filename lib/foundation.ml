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
    let links = List.map (link ~cl:"") links in
    let cl = match align with `Right -> "right" | `Left -> "left" in
    mk_ul_links ~cl ~links

  let button_group (links:links) =
    let links = List.map (link ~cl:"button") links in
    mk_ul_links ~cl:"button-group" ~links

  let side_nav (links:links) =
    let links = List.map (link ~cl:"") links in
    mk_ul_links ~cl:"side-nav" ~links

  let bottom_nav (links:links) =
    let links = List.map (link ~cl:"") links in
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
      | [] -> Cow.Html.nil
      | hd::tl -> <:html<$to_html hd$$make tl$>>
    in
    <:html<<h5>$str:title$</h5>
      <ul class="side-nav">
        $make content$
      </ul>
   >>
end

module Index = struct
  let t ~top_nav =
    let content = <:html<
      $top_nav$
      <br />
      <div class="row">
        <div class="large-12 columns">
          <img src="http://placehold.it/1000x400&amp;text=img"></img>
          <hr />
        </div>
      </div>
    >>
    in
    content
end

let rec intercalate x = function
  | []    -> []
  | [e]   -> [e]
  | e::es -> e :: x :: intercalate x es

module Blog = struct
  let post ~title ~authors ~date ~content =
    let open Link in
    let author = match authors with
      | [] -> <:html< >>
      | _  ->
        let a_nodes =
          intercalate <:html<, >> (List.map (link ~cl:"") authors)
        in
        <:html<By $list: a_nodes$>>
    in
    let title_text, title_uri = title in
    <:html<
      <article>
        $date$
        <h4><a href=$uri:title_uri$>$str:title_text$</a></h4>
        <p><i>$author$</i></p>
        $content$
      </article>
    >>

  let t ~title ~subtitle ~sidebar ~posts ~copyright () =
    let subtitle =
      match subtitle with
      | None -> <:html<&>>
      | Some s -> <:html<<small>$str:s$</small>&>>
    in
    <:html<
    <div class="row">
      <div class="large-9 columns">
        <h2>$str:title$ $subtitle$</h2>
      </div>
    </div>
    <div class="row">
      <div class="small-12 large-9 columns" role="content">
        $posts$
      </div>
      <aside class="small-12 large-3 columns panel">
        $sidebar$
      </aside>
    </div>
    <footer class="row">
      <div class="large-12 columns">
        <hr />
        <div class="row">
          <div class="large-6 columns">
            <p><small>&copy; Copyright $copyright$</small></p>
          </div>
        </div>
      </div>
    </footer>
    >>
end

let body ?google_analytics ?highlight
      ~title ~headers ~content ~trailers () =
  (* Cannot be inlined below as the $ is interpreted as an antiquotation *)
  let js_init = [`Data "$(document).foundation();"] in
  let highlight_css, highlight_trailer = match highlight with
    | None -> <:html< >>, <:html< >>
    | Some style ->
      <:html< <link rel="stylesheet" href="$str:style$"> </link> >>,
      <:html<
        <script src="/js/vendor/highlight.pack.js"> </script>
        <script> hljs.initHighlightingOnLoad(); </script>
      >>
  in
  let ga =
    match google_analytics with
    | None -> []
    | Some (a,d) -> <:html<
         <script type="text/javascript">
           //<![CDATA[
           var _gaq = _gaq || [];
           _gaq.push(['_setAccount', '$[`Data a]$']);
           _gaq.push(['_setDomainName', '$[`Data d]$']);
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
      <link rel="stylesheet" href="/css/site.css"> </link>
      <script src="/js/vendor/custom.modernizr.js"> </script>
      $highlight_css$
      $ga$
      $headers$
    </head>
    <body>
      $content$
      <script src="/js/vendor/jquery.min.js"> </script>
      <script src="/js/foundation/foundation.min.js"> </script>
      <script src="/js/foundation/foundation.topbar.js"> </script>
      <script> $js_init$ </script>
      $highlight_trailer$
      $trailers$
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
  <!--[if IE 8]><html class=\"no-js lt-ie9\" lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\"><![endif]-->
  <!--[if gt IE 8]><!--><html class=\"no-js\" lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\"><!--<![endif]-->
  %s
</html>" (Cow.Html.to_string body)
