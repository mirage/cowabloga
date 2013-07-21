(*
 * Copyright (c) 2010-2013 Anil Madhavapeddy <anil@recoil.org>
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

open Printf
open Lwt
open Cow

type feed = {
  base_uri   : string;
  rights     : string option;
  read_entry : string -> Cow.Html.t Lwt.t;
}

type entry = {
  updated    : Date.date;
  author     : Atom.author;
  subject    : string;
  body       : string;
  permalink  : string;
}

(* Convert a blog record into an Html.t fragment *)
let html_of_entry {read_entry;base_uri} e =
  read_entry e.body
  >>= fun content ->
  let permalink = Uri.of_string (sprintf "%s/blog/%s" base_uri e.permalink) in
  let permalink_disqus = sprintf "/blog/%s#disqus_thread" e.permalink in
  let author_uri =
    match e.author.Atom.uri with
    | None -> Uri.of_string "" (* TODO *)
    | Some uri -> Uri.of_string uri
  in
  let author = e.author.Atom.name, author_uri in
  let date = Date.html_of_date e.updated in
  let title = e.subject, permalink in
  let post = Blog_template.post ~title ~date ~author ~content in
  return post

let atom_entry_of_ent {base_uri; read_entry} e =
  let permalink e = sprintf "%s/%s" base_uri e.permalink in
  let links = [
    Atom.mk_link ~rel:`alternate ~typ:"text/html"
      (Uri.of_string (permalink e)) 
  ] in
  let meta = {
    Atom.id      = permalink e;
    title        = e.subject;
    subtitle     = None;
    author       = Some e.author;
    updated      = Date.atom_date e.updated;
    rights       = None;
    links;
  } in 
  read_entry e.body
  >|= fun content ->
  {
    Atom.entry = meta;
    summary    = None;
    content
  }
  
let cmp_ent a b =
  compare (Date.atom_date a.updated) (Date.atom_date b.updated)

let atom_feed cfg es =
  let { base_uri; rights } = cfg in
  let mk_uri uri = Uri.of_string (sprintf "%s/%s" base_uri uri) in
  let es = List.rev (List.sort cmp_ent es) in
  let updated = Date.atom_date (List.hd es).updated in
  let id = "/blog/" in
  let title = "openmirage blog" in
  let subtitle = Some "a cloud operating system" in
  let links = [
    Atom.mk_link (mk_uri "blog/atom.xml");
    Atom.mk_link ~rel:`alternate ~typ:"text/html" (mk_uri "blog/")
  ] in
  let feed = { Atom.id; title; subtitle; author=None; rights; updated; links } in
  Lwt_list.map_s (atom_entry_of_ent cfg) es
  >>= fun entries -> return { Atom.feed=feed; entries }
