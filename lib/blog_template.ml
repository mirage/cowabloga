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

type link = string * Uri.t
type links = link list
let link ?(cl="") (txt,uri) = <:html<<a href=$uri:uri$ class=$str:cl$>$str:txt$</a>&>>

let mk_ul_links ~cl ~links =
  let items = List.map (fun l -> <:html<<li>$l$</li>&>>) links in
  <:html<<ul class=$str:cl$>$list:items$</ul>&>>

let button_group (links:links) =
  let links = List.map (link ~cl:"button") links in
  mk_ul_links ~cl:"button-group" ~links

let side_nav (links:links) =
  let links = List.map link links in
  mk_ul_links ~cl:"side-nav" ~links

let bottom_nav (links:links) =
  let links = List.map link links in
  mk_ul_links ~cl:"inline-list right" ~links

let post ~title ~author ~date ~content =
  let (title_text, title_uri) = title in
  <:html<
  <article>
    <h3><a href=$uri:title_uri$>$str:title_text$</a></h3>
    <h6>Written by $link author$ on $date$.</h6>
    $content$
  </article>
 >>

module Sidebar = struct
  type t = [
   | `link of link
   | `active_link of link
   | `divider
  ]

  let t ~title ~content =
    let to_html =
      function
      |`link l -> <:html<<li>$link l$</li>&>>
      |`active_link l -> <:html<<li class="active">$link l$</li>&>>
      |`divider -> <:html<<li class="divider" />&>>
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

let t ~title ~subtitle ~nav_links ~sidebar ~posts ~copyright() =
  let subtitle =
    match subtitle with
    | None -> <:html<&>>
    | Some s -> <:html<<small>$str:s$</small>&>>
  in
  <:html<
  <div class="row">
    <div class="large-12 columns">
      <div class="nav-bar right">$button_group nav_links$</div>
      <h1>$str:title$ $subtitle$</h1>
      <hr />
    </div>
  </div>
  <!-- End Nav -->
  <!-- Main Page Content and Sidebar -->
  <div class="row">
    <!-- Main Blog Content -->
    <div class="large-9 columns" role="content">
      $posts$
    </div>
    <!-- End Main Content -->

    <!-- Sidebar -->
    <aside class="large-3 columns">
      $sidebar$
    </aside>
    <!-- End Sidebar -->
  </div>

  <!-- End Main Content and Sidebar -->
  <!-- Footer -->

  <footer class="row">
    <div class="large-12 columns">
      <hr />
      <div class="row">
        <div class="large-6 columns">
          <p>&copy; Copyright $copyright$</p>
        </div>
        <div class="large-6 columns">
          $bottom_nav nav_links$
        </div>
      </div>
    </div>
  </footer>
>>
