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

(** Blog management: entries, ATOM feeds, etc. *)

open Printf
open Lwt
open Cow
open Atom_feed

(** An Atom feed: metadata plus a way to retrieve entries. *)
(** A feed is made up of Entries. *)
module Entry = struct

  (** An entry in a feed: metadata plus a filename [body]. *)
  type t = {
    updated: Date.date;
    author: Atom.author;
    subject: string;
    permalink: string;
    body: string;
  }

  (** [permalink feed entry] returns the permalink URI for [entry] in [feed].
      Until we have URL routing, this assumes /blog as the URI root *)
  let permalink feed entry =
    sprintf "%sblog/%s" feed.base_uri entry.permalink

  (** Compare two entries. *)
  let compare a b =
    compare (Date.atom_date b.updated) (Date.atom_date a.updated)

  (** [to_html feed entry] converts a blog entry in the given feed into an
      Html.t fragment. *)
  let to_html ~feed ~entry =
    lwt content = feed.read_entry entry.body in
    let permalink_disqus = sprintf "/%s#disqus_thread" entry.permalink in
    let author =
      let author_uri = match entry.author.Atom.uri with
        | None -> Uri.of_string "" (* TODO *)
        | Some uri -> Uri.of_string uri
      in
      entry.author.Atom.name, author_uri
    in
    let date = Date.html_of_date entry.updated in
    let title =
      let permalink = Uri.of_string (permalink feed entry) in
      entry.subject, permalink
    in
    return (Blog_template.post ~title ~date ~author ~content)

  (** [to_atom feed entry] *)
  let to_atom feed entry =
    let links = [
      Atom.mk_link ~rel:`alternate ~typ:"text/html"
        (Uri.of_string (permalink feed entry))
    ] in
    let meta = {
      Atom.id = permalink feed entry;
      title = entry.subject;
      subtitle = None;
      author = Some entry.author;
      updated = Date.atom_date entry.updated;
      rights = None;
      links;
    } in
    feed.read_entry entry.body
    >|= fun content ->
    {
      Atom.entry = meta;
      summary = None;
      base = None;
      content
    }

end

(** Entries separated by <hr /> tags *)
let default_separator = <:html< <hr /> >>

(** [to_html ?sep feed entries] renders a series of entries in a feed, separated
    by [sep], defaulting to [default_separator]. *)
let to_html ?(sep=default_separator) ~feed ~entries =
  let rec concat = function
    | [] -> return <:html<&>>
    | hd::tl ->
      lwt hd = Entry.to_html feed hd in
      concat tl
      >|= fun tl -> <:html< $hd$$sep$$tl$ >>
  in
  concat (List.sort Entry.compare entries)


(** [to_atom feed entries] generates a time-ordered ATOM RSS [feed] for a
    sequence of [entries]. *)
let to_atom ~feed ~entries =
  let { title; subtitle; base_uri; id; rights } = feed in
  let entries = List.sort Entry.compare entries in
  let updated = Date.atom_date (List.hd entries).Entry.updated in
  let links = [
    Atom.mk_link (Uri.of_string (base_uri ^ id ^ "/atom.xml"));
    Atom.mk_link ~rel:`alternate ~typ:"text/html" (Uri.of_string base_uri)
  ] in
  let atom_feed = { Atom.id; title; subtitle;
    author=feed.author; rights; updated; links }
  in
  lwt entries = Lwt_list.map_s (Entry.to_atom feed) entries in
  return { Atom.feed=atom_feed; entries }

(** [recent_posts feed entries] . *)
let recent_posts ?(active="") feed entries =
  let entries = List.sort Entry.compare entries in
  List.map (fun e ->
      let link = Entry.(e.subject, Uri.of_string (Entry.permalink feed e)) in
      if e.Entry.subject = active then
        `active_link link
      else
        `link link
    ) entries
