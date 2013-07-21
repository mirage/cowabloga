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

val link : ?cl:string -> link -> Cow.Xml.t


val mk_ul_links : cl:string -> links:('a Cow.Xml.frag as 'a) list list -> Cow.Xml.t

val button_group : links -> Cow.Xml.t

val side_nav : links -> Cow.Xml.t

val bottom_nav : links -> Cow.Xml.t

val post :
  title:string * Uri.t ->
  author:string * Uri.t -> content:('a Cow.Xml.frag as 'a) list -> Cow.Xml.t

val t :
  title:Cow.Xml.t ->
  nav_links:links ->
  side_links:links ->
  posts:('a Cow.Xml.frag as 'a) Cow.Xml.frag list list ->
  copyright:'a Cow.Xml.frag list -> unit -> Cow.Xml.t
