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
  let recent_posts = Blog.recent_posts config Mirage_blog.entries in
  let sidebar = Blog_template.Sidebar.t ~title:"Recent Posts" ~content:recent_posts in
  let copyright = <:html<Anil Madhavapeddy>> in
  let { Blog.title; subtitle } = config in
  Blog_template.t ~title ~subtitle ~nav_links ~sidebar ~posts ~copyright ()

let blog =
  let headers = <:html< >> in
  let body = Foundation.body ~title:"Mirage Musings" ~headers ~content:t in
  Foundation.page ~body
