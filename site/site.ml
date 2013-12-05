(*
 * Copyright (c) 2010-2013 Anil Madhavapeddy <anil@recoil.org>
 * Copyright (c) 2013 Richard Mortier <mort@cantab.net>
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

open Cowabloga
open Lwt
open Cohttp_lwt_unix

let log = Printf.printf
let startswith str pfx = String.(sub str 0 (length pfx)) = pfx

(*

  blog [landing page]
  + posts...

  research
  + papers
  + students
  + for applicants

  codes
  + personal github
  + github organisations

  about
  + teaching: moodle pointers, links
  + expertise

  sidebar [lh margin]
  + contact: online, office
  + navmenu: full

  sidebar [rh margin]
  + recent posts

  footer
  + copyright
  + top-of-page
  + navmenu: top-level only

*)

let callback conn_id ?body req =
  let open Server in

  let path =  Uri.path (Request.uri req) in
  log "# path:'%s'\n%!" path;

  match path with
  | "" | "/" | "/blog" | "/blog/" ->
    respond_string ~status:`OK ~body:Posts.page ()

  | path ->
    if startswith path "/blog/" then
      respond_string ~status:`OK ~body:(Posts.post path) ()
    else
      let fname = resolve_file ~docroot:"site/store" ~uri:(Request.uri req) in
      respond_file ~fname ()
