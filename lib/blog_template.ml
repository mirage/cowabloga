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

let post ~title ~author ~content =
  let (title_text, title_uri) = title in
  <:html<
  <article>
    <h3><a href=$uri:title_uri$>$str:title_text$</a></h3>
    <h6>Written by $link author$ on August 12, 2012.</h6>
    $content$
  </article>
 >>

let t ~title ~nav_links ~side_links ~posts ~copyright() =
  <:html<
  <div class="row">
    <div class="large-12 columns">
      <div class="nav-bar right">$button_group nav_links$</div>
      <h1>Blog <small>$title$</small></h1>
      <hr />
    </div>
  </div>
  <!-- End Nav -->
  <!-- Main Page Content and Sidebar -->
  <div class="row">
    <!-- Main Blog Content -->
    <div class="large-9 columns" role="content">
      $list:posts$
    </div>
    <!-- End Main Content -->
 
    <!-- Sidebar -->
    <aside class="large-3 columns">
      <h5>Categories</h5>
      $side_nav side_links$
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
