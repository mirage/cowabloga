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
open Cow
open Lwt

module Authors = struct
  let mort = {
    Atom.name = "Richard Mortier";
    uri       = Some "http://mort.io/";
    email     = Some "mort@cantab.net";
  }
end

module Entries = struct
  let t =
    let open Cowabloga in
    [ { Blog.updated = Date.date (2013, 10, 14, 10, 46);
        author = Authors.mort;
        subject = "A 21st Century IDE";
        body = "posts/21st-century-ide.md";

        (* XXX permalink will have /blog/ prepended due to embedded string
           fragments throughout lib/blog.ml; fix later though *)
        permalink = "2013/10/13/21st-century-ide/";
      };
    ]
end

let read_entry ent =
  match_lwt Store.read ent with
  | None -> return <:html<$str:"???"$>>
  | Some b ->
    let string_of_stream s = Lwt_stream.to_list s >|= Cstruct.copyv in
    lwt str = string_of_stream b in
    return (Markdown_omd.of_string str)

let config = Config.({ Blog.title; subtitle; base_uri; rights; read_entry })

let page =
  let posts = Lwt_unix.run (Blog.entries_to_html config Entries.t) in
  let content =
    let sidebar =
      let recent_posts = Blog.recent_posts config Entries.t in
      Blog_template.Sidebar.t ~title:"recent posts" ~content:recent_posts
    in
    Config.(
      Blog_template.t ~title ~subtitle ~nav_links ~sidebar ~posts ~copyright ()
    )
  in
  let title = config.Blog.title ^ " | myths & legends" in
  let body = Foundation.body ~title ~content in
  Foundation.page ~body

let post path =
  let open Blog in
  let e = List.find
      (fun e ->
         let pl = String.length "/blog/" in
         e.permalink = String.(sub path pl ((length path)-pl))
      )
      Entries.t
  in
  let content =
    let content = Lwt_unix.run (read_entry e.body) in
    let date = Date.html_of_date e.updated in
    let author =
      let open Cow.Atom in
      (e.author.name,
       Uri.of_string (match e.author.uri with Some x -> x | None -> ""))
    in
    let title = (e.subject, Uri.of_string ("/blog/" ^ e.permalink)) in
    (Blog_template.post ~title ~author ~date ~content)
  in
  let sidebar = <:html< >> in

  let content = Config.(
      Blog_template.t
        ~title ~subtitle ~nav_links ~sidebar ~posts:content ~copyright ()
    )
  in
  let body =
    let title = config.title ^ " | " ^ e.subject in
    Foundation.body ~title ~content
  in
  Foundation.page ~body
