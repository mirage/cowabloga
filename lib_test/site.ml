open Cowabloga
open Lwt

let read_entry ent =
  match Mirage_entries.read ent with
  | None -> return <:html<$str:"???"$>>
  | Some b ->
    let md = Cow.Markdown.of_string b in
    return (Cow.Markdown.to_html md)

let config = { 
  Blog.base_uri="http://localhost:8081";
  title = "OpenMirage";
  subtitle = Some "the development blog";
  rights = Mirage_people.rights;
  read_entry
}

let posts =
  Lwt_unix.run (Blog.entries_to_html config Mirage_blog.entries)

let t =
  let uri = Uri.of_string in
  let nav_links = [
    "home",    uri "/";
    "blog",    uri "/blog";
    "contact", uri "/contact" ]
  in
  let side_links = Blog.recent_posts config Mirage_blog.entries in
  let copyright = <:html<Anil Madhavapeddy>> in
  let { Blog.title; subtitle } = config in
  Blog_template.t ~title ~subtitle ~nav_links ~side_links ~posts ~copyright ()

let blog =
  let body = Foundation.body ~title:"Mirage Musings" ~content:t in
  Foundation.page ~body
