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

(** Wiki management: entries, ATOM feeds, etc. *)

open Printf
open Lwt
open Cow
open Atom_feed
open Date

type body =
  | File of string
  | Html of Html.t

type entry = {
  updated    : date;
  author     : Atom.author;
  subject    : string;
  body       : body;
  permalink  : string;
}

let html_of_author author =
  match author.Atom.uri with
  | None     ->
    <:html<Last modified by $str:author.Atom.name$>>
  | Some uri ->
    <:html<Last modified by <a href=$str:uri$>$str:author.Atom.name$</a>&>>

let atom_date d =
  ( d.year, d.month, d.day, d.hour, d.min)

let short_html_of_date d =
  <:xml<$int:d.day$ $xml_of_month d.month$ $int:d.year$>>

let body_of_entry {read_entry} e =
  match e.body with
  | File x -> read_entry x
  | Html x -> return x

let compare_dates e1 e2 =
  let d1 = e1.updated in let d2 = e2.updated in
  compare (d1.year,d1.month,d1.day) (d2.year,d2.month,d2.day)

(* Convert a wiki record into an Html.t fragment *)
let html_of_entry ?(want_date=false) read_file e =
  let permalink = sprintf "/wiki/%s" e.permalink in
  lwt body = body_of_entry read_file e in
  return <:xml<
    <h3><a href=$str:permalink$>$str:e.subject$</a></h3>
    $body$ >>

let html_of_index feed =
  lwt body = feed.read_entry "index.md" in
  return <:xml<
    <div class="wiki_entry">
     <div class="wiki_entry_body">$body$</div>
   </div>
 >>

let permalink feed e =
  sprintf "%swiki/%s" feed.base_uri e.permalink

let html_of_recent_updates feed (entries:entry list) =
  let ents = List.rev (List.sort compare_dates entries) in
  let html_of_ent e = <:xml<
    <li><a href=$str:permalink feed e$>$str:e.subject$</a>
    <span class="lastmod">($short_html_of_date e.updated$)</span>
    </li>
  >> in
  <:xml<
    <h6>Recent Updates</h6>
    <ul class="side-nav">
    $list:List.map html_of_ent ents$
    </ul>
  >>

(* Main wiki page; disqus comments are for full entry pages *)
let html_of_page ?disqus ~content ~sidebar =

  (* The disqus comment *)
  let disqus_html permalink = <:xml<
    <div class="wiki_entry_comments">
    <div id="disqus_thread"/>
    <script type="text/javascript">
      var disqus_identifer = '/wiki/$str:permalink$';
      (function() {
        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
         dsq.src = 'http://openmirage.disqus.com/embed.js';
        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
       })()
    </script>
    </div>
  >> in

  let dh = match disqus with
     | Some perm  -> disqus_html perm
     | None      -> <:xml< >> in

  lwt content = content in
  let sidebar =
    match sidebar with 
    | [] -> [] 
    | sidebar ->
       <:xml<
         <aside class="medium-3 large-3 columns panel">
           $sidebar$
         </aside>
       >> in
  return <:xml<
    <div class="row">
      <div class="small-12 medium-10 large-9 columns">
      <h2>Documentation <small> and guides</small></h2>
      </div>
    </div>
    <div class="row">
      <div class="small-12 medium-10 large-9 columns">$content$</div>
      $sidebar$
    </div>
  >>

let cmp_ent a b =
  Atom.compare (atom_date a.updated) (atom_date b.updated)

let permalink_exists x entries =
  List.exists (fun e -> e.permalink = x) entries

let atom_entry_of_ent (feed:Atom_feed.t) e =
  let perma_uri = Uri.of_string (permalink feed e) in
  let links = [ Atom.mk_link ~rel:`alternate ~typ:"text/html" perma_uri ] in
  lwt content = body_of_entry feed e in
  let meta = {
    Atom.id      = Uri.to_string perma_uri;
    title        = e.subject;
    subtitle     = None;
    author       = Some e.author;
    updated      = atom_date e.updated;
    rights =       feed.rights;
    links;
  } in
  return {
    Atom.entry = meta;
    summary    = None;
    base       = None;
    content
  }

let to_atom ~feed ~entries =
  let mk_uri x = Uri.of_string (feed.base_uri ^ x) in
  let es = List.rev (List.sort cmp_ent entries) in
  let updated = atom_date (List.hd es).updated in
  let id = feed.base_uri in
(*
  let title = "openmirage wiki" in
  let subtitle = Some "a cloud operating system" in
*)
  let links = [
    Atom.mk_link (mk_uri "atom.xml");
    Atom.mk_link ~rel:`alternate ~typ:"text/html" (mk_uri "")
  ] in
  lwt entries = Lwt_list.map_s (atom_entry_of_ent feed) es in
  let feed = {
    Atom.id;
    title = feed.title;
    subtitle = feed.subtitle;
    author = feed.Atom_feed.author;
    rights = feed.rights;
    updated;
    links 
  } in
  return { Atom.feed=feed; entries }

