open Cowabloga
open Lwt

let read_entry ent =
  match Mirage_entries.read ent with
  | None -> return <:html<$str:"???"$>>
  | Some b -> return (Cow.Markdown.of_string b)

let config = {
  Blog.base_uri="http://localhost:8081";
  id = "";
  title = "The Mirage Blog";
  subtitle = Some "programming functional systems";
  rights = Mirage_people.rights;
  read_entry
}

let posts =
  Lwt_unix.run (Blog.to_html config Mirage_blog.entries)

let t ~nav_links =
  let recent_posts = Blog.recent_posts config Mirage_blog.entries in
  let sidebar = Blog_template.Sidebar.t ~title:"Recent Posts" ~content:recent_posts in
  let copyright = <:html<Anil Madhavapeddy>> in
  let { Blog.title; subtitle } = config in
  Blog_template.t ~title ~subtitle ~nav_links ~sidebar ~posts ~copyright ()

let blog =
  let uri = Uri.of_string in
  let nav_links = [
    "Blog", uri "/";
    "Docs", uri "/blog";
    "API", uri "/api";
    "Community", uri "/community";
    "About", uri "/about";
  ]
  in
  let headers = <:html< >> in
  let content =
    Foundation.top_nav ~title:"Mirage OS" ~title_uri:(Uri.of_string "/") ~nav_links:(Blog_template.top_nav nav_links)
    @ t ~nav_links
  in
  let body = Foundation.body ~title:"Mirage Musings" ~headers ~content in
  Foundation.page ~body
