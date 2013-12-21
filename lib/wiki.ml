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
open Date

(* category, subcategory, see list of them below *)
type category = string * string

type body =
  | File of string
  | Html of Html.t

type entry = {
  updated    : date;
  author     : Atom.author;
  subject    : string;
  categories : category list;
  body       : body;
  permalink  : string;
}

let html_of_author author =
  match author.Atom.uri with
  | None     -> <:html<Last modified by $str:author.Atom.name$>>
  | Some uri -> <:html<Last modified by <a href=$str:uri$>$str:author.Atom.name$</a>&>>

let atom_date d =
  ( d.year, d.month, d.day, d.hour, d.min)

let short_html_of_date d =
  <:xml<last modified on $int:d.day$ $xml_of_month d.month$ $int:d.year$>>

let body_of_entry read_file e =
  match e.body with
  | File x -> read_file x
  | Html x -> return x

let compare_dates e1 e2 =
  let d1 = e1.updated in let d2 = e2.updated in
  compare (d1.year,d1.month,d1.day) (d2.year,d2.month,d2.day)

(* Convert a wiki record into an Html.t fragment *)
let html_of_entry ?(want_date=true) read_file e =
  let permalink = sprintf "/wiki/%s" e.permalink in
  lwt body = body_of_entry read_file e in
  return <:xml<
    <div class="wiki_entry">
      $if want_date then Date.html_of_date e.updated else []$
      <div class="wiki_entry_heading">
        <div class="wiki_entry_title">
          <a href=$str:permalink$>$str:e.subject$</a>
        </div>
        <div class="wiki_entry_info">
          <i>$html_of_author e.author$</i>
        </div>
     </div>
     <div class="wiki_entry_body">$body$</div>
   </div>
 >>

let html_of_index read_file =
  lwt body = read_file "index.md" in
  return <:xml<
    <div class="wiki_entry">
     <div class="wiki_entry_body">$body$</div>
   </div>
 >>


type num = {
  l1 : string -> int;
  l2 : string -> string -> int;
}

(* XXX: the num_li functions can be optimized *)
let num_of_entries entries =
  let num_l1 l1 =
    List.fold_left (fun a e ->
      List.fold_left (fun a (l1',_) ->
        if l1' = l1 then a+1 else a
      ) 0 e.categories + a
    ) 0 entries in

  let num_l2 l1 l2 =
    List.fold_left (fun a e ->
      List.fold_left (fun a (l1',l2') ->
        if l1'=l1 && l2'=l2 then a+1 else a
      ) 0 e.categories + a
    ) 0 entries in

  {
    l1 = num_l1;
    l2 = num_l2;
  }

(* One categorie on the right column *)
let short_html_of_category num (l1, l2l) =
  let l2h = List.map (fun l2 ->
    match num.l2 l1 l2 with
      | 0   -> <:xml<<div class="wiki_bar_l2">$str:l2$</div>&>>
      | nl2 ->
        let num = <:xml<<i>$str:sprintf " (%d)" nl2$</i>&>> in
        let url = sprintf "/wiki/tag/%s/%s" l1 l2 in
        <:xml<<div class="wiki_bar_l2"><a href=$str:url$>$str:l2$</a>$num$</div>&>>
  ) l2l in
  let url = sprintf "/wiki/tag/%s" l1 in
  let l1h = match num.l1 l1 with
    | 0   -> <:xml<<div class="wiki_bar_l1">$str:l1$</div>&>>
    | nl1 -> <:xml<<div class="wiki_bar_l1"><a href=$str:url$>$str:l1$</a></div>&>> in
  <:xml<
    $l1h$
    $list:l2h$
  >>

(* The full right bar in wiki *)
let short_html_of_categories entries categories =
  let num = num_of_entries entries in
  let url = "/wiki/" in
  <:xml<
    <div class="wiki_bar">
      <div class="wiki_bar_l0"><a href=$str:url$>Index</a></div>
      $list:List.map (short_html_of_category num) categories$
    </div>
 >>

let permalink e =
  sprintf "/wiki/%s" e.permalink

let html_of_category entries (l1, l2) =
  let equal (ll1, ll2) = match l2 with
    | None    -> ll1=l1
    | Some l2 -> ll1=l1 && ll2=l2 in
  let l2_str = match l2 with
    | None    -> ""
    | Some l2 -> "/ " ^ l2 in
  let entries = List.filter (fun e -> List.exists equal e.categories) entries in
  let aux e = <:xml<<li><a href=$str:permalink e$>$str:e.subject$</a> ($short_html_of_date e.updated$)</li>&>> in
  match entries with
  | []      -> []
  | entries ->
      <:xml<
        <div class="category_index">
          <h3>$str:l1$ $str:l2_str$</h3>
          <ul>$list:List.map aux entries$</ul>
        </div>
      >>

let html_of_categories entries categories =
  let categories =
    List.fold_left
      (fun accu (l1, ll2) -> List.map (fun l2 -> l1, Some l2) ll2 @ accu)
      [] categories in
  let categories = List.rev categories in
  <:xml<$list:List.map (html_of_category entries) categories$>>

let html_of_recent_updates entries =
  let ents = List.rev (List.sort compare_dates entries) in
  let html_of_ent e = <:xml<
    <a href=$str:permalink e$>$str:e.subject$</a>
    <i>($short_html_of_date e.updated$)</i>
    <br />
  >> in
  <:xml<
    <div class="wiki_updates">
    <p><b>Recently Updated</b><br />
    $list:List.map html_of_ent ents$
    </p>
    </div>
  >>

(* Main wiki page; disqus comments are for full entry pages *)
let html_of_page ?disqus ~left_column ~right_column =

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

  lwt left_column = left_column in
  return <:xml<
    <div class="left_column_wiki">
      <div class="summary_information">$left_column$</div>
    </div>
    <div class="right_column_wiki">$right_column$</div>
    <div style="clear:both;"></div>
    <h2>Comments</h2>
    $dh$
  >>
