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

open Foundation

let post ~title ~author ~date ~content =
  let open Link in
  let (title_text, title_uri) = title in
  <:html<
    <article>
      $date$
      <h4><a href=$uri:title_uri$>$str:title_text$</a></h4>
      <p><i>By $link author$</i></p>
      $content$
    </article>
  >>

let t ~title ~subtitle ~nav_links ~sidebar ~posts ~copyright() =
  let subtitle =
    match subtitle with
    | None -> <:html<&>>
    | Some s -> <:html<<small>$str:s$</small>&>>
  in
  <:html<

  <div class="row">
    <div class="large-9 columns">
      <h2>$str:title$ $subtitle$</h2>
      <hr />
    </div>
<!--
    <div class="large-3 columns">
      <dl class="right sub-nav">
      <dt>Tags:</dt>
      <dd class="active"><a href="#">All</a></dd>
      <dd><a href="#">Releases</a></dd>
      <dd><a href="#">Events</a></dd>
      <dd><a href="#">Tutorials</a></dd>
      </dl>
    </div>
-->
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
    <aside class="large-3 columns panel">
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
          $Link.bottom_nav nav_links$
        </div>
      </div>
    </div>
  </footer>
>>
