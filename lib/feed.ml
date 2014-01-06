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

(** Generate an aggregated link feed from all the other feeds *)
open Lwt
open Cow

type feed = [
  | `Blog of Atom_feed.t * Blog.Entry.t list
  | `Wiki of Atom_feed.t * Wiki.entry list
  | `Links of Atom_feed.t * Links.t list
]

let feed_icon =
  function
  | `Blog _ -> "fa-comment"
  | `Wiki _ -> "fa-book"
  | `Links _ -> "fa-external-link"

let feed_uri =
  function
  | `Blog f -> f.Atom_feed.base_uri ^ "blog/" (* TODO: Proper URL routing *)
  | `Wiki f -> f.Atom_feed.base_uri ^ "wiki/"
  | `Links f -> f.Atom_feed.base_uri ^ "links/"

let to_atom_entries (feeds:feed list) =
  Lwt_list.map_s (
    function
    | `Blog (feed,entries) ->
        Blog.to_atom ~feed ~entries
        >|= fun c -> List.map (fun e -> (e, `Blog feed)) c.Atom.entries
    | `Wiki (feed,entries) ->
        Wiki.to_atom ~feed ~entries
        >|= fun c -> List.map (fun e -> (e, `Wiki feed)) c.Atom.entries
    | `Links (feed,entries) ->
        Links.to_atom ~feed ~entries
        >|= fun c -> List.map (fun e -> (e, `Links feed)) c.Atom.entries
  ) feeds
  >|= List.flatten
  >|= List.sort (fun (a,_) (b,_) -> Atom.(compare b.entry.updated a.entry.updated))

let to_html ?limit feeds =
  let open Atom in
  to_atom_entries feeds
  >|= List.mapi (fun i ({entry}, info) ->
    let fa = Printf.sprintf "fa-li fa %s" (feed_icon info) in
    (* Find an alternate HTML link *)
    try
      (match limit with |Some x when i > x -> raise Not_found |_ -> ());
      let uri =
        let l = List.find (fun l -> l.rel = `alternate && l.typ = Some "text/html") entry.links in
        l.href in
      let (y,m,d,_,_) = entry.updated in
      let date = Printf.sprintf "(%d %s %d)" d (Date.short_string_of_month m) y in
      <:html<
       <li><a href=$str:feed_uri info$><i class=$str:fa$> </i></a>
        <a href=$uri:uri$>$str:entry.title$</a>
        <i class="front_date">$str:date$</i></li>&>>
    with Not_found ->
      <:html< >>)
  >|= fun fs ->
  <:html<<ul class="fa-ul">$list:fs$</ul>&>>

let permalink feed id = Printf.sprintf "%supdates/%s" feed.Atom_feed.base_uri id
let to_atom ~meta ~feeds =
    let open Atom_feed in
    let { title; subtitle; base_uri; id; rights } = meta in
    let id = base_uri ^ id in
    lwt entries = to_atom_entries feeds >|= List.map fst in
    let updated = (List.hd entries).Atom.entry.Atom.updated in
    let links = [
      Atom.mk_link (Uri.of_string (permalink meta "atom.xml"));
      Atom.mk_link ~rel:`alternate ~typ:"text/html" (Uri.of_string base_uri)
    ] in
    let atom_feed = { Atom.id; title; subtitle; author=meta.author;
      rights; updated; links }
    in
    return { Atom.feed=atom_feed; entries }
