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

let callback conn_id ?body req =
  let open Server in
  match Uri.path (Request.uri req) with
  | "" | "/" | "/blog" | "/blog/" -> respond_string ~status:`OK ~body:Posts.page ()
  | path ->
    log "# path:'%s'\n%!" path;
    if startswith path "/blog/" then
      let open Blog in
      (* search through Posts.entries to find matching permalink ; return
         rendered entry *)
      let e = List.find
          (fun e ->
            let pl = String.length "/blog/" in
            e.permalink = String.(sub path pl ((length path)-pl))
          )
          Posts.Entries.t
      in
      let title = (e.subject, Uri.of_string e.permalink) in
      let author =
        let open Cow.Atom in
        (e.author.name,
         Uri.of_string (match e.author.uri with Some x -> x | None -> ""))
      in
      let date = Date.html_of_date e.updated in
      lwt content = Posts.read_entry e.body in
      let post = Blog_template.post ~title ~author ~date ~content in
      let body = Cow.Html.to_string post in
      respond_string ~status:`OK ~body ()
    else
      let fname = resolve_file ~docroot:"site/store" ~uri:(Request.uri req) in
      respond_file ~fname ()
