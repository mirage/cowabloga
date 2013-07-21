open Cowabloga

let post1 =
  let title = "Blog Post 1", Uri.of_string "/post1" in
  let author = "Anil Madhavapeddy", (Uri.of_string "http://anil.recoil.org") in
  let content = <:html<<p>Florble</p><p>Wibble</p>&>> in
  Blog_template.post ~title ~author ~content

let t =
  let title = <:html<My test website>> in
  let uri = Uri.of_string in
  let nav_links = ["home", uri "/"; "blog", uri "/blog"; "contact", uri "/contact"] in
  let side_links = nav_links in
  let posts = [post1] in
  let copyright = <:html<Anil Madhavapeddy>> in
  Blog_template.t ~title ~nav_links ~side_links ~posts ~copyright ()

let blog =
  let body = Foundation.body ~title:"My Blog" ~content:t in
  Foundation.page ~body
