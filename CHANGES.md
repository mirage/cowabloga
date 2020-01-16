## 0.5.0 (2020-01-10)

* upgrade to dune from jbuilder (@avsm)
* update to opam 2 metadata format (@avsm)

## 0.4.0 (2018-05-13)

* support cow 2.3.0 (#34, @samoht)
* support re 1.7.2 (#32, @rgrinberg)

## 0.3.0 (2017-05-16)

* add a LICENSE file
* build via jbuilder

## 0.2.2 (2017-05-13)

* fix warnings with lwt >= 2.7.0

## 0.2.1 (2016-06-29)

* add some missing spaces to feed rendering

## 0.2.0 (2016-03-16)

* Use cow 2.0.0, do not use camlp4 extensions anymore

## 0.1.0 (2016-02-29)

* Do not use lwt.syntax
* Use magic-mime to set the page headers for assets
* Remove unused disqus support: remove optional `disqus` argument from
  `Wiki.html_of_page`

## 0.0.9 (2014-12-18):

* Compatibility with Cohttp 0.14.x.

## 0.0.8 (2014-11-02):

* Support Conduit 0.6 APIs.

## 0.0.7 (2014-07-12):

* Add support for multi-author blog posts (#19 via @pqwy).

## 0.0.6 (2014-03-26):

* Explicitly depend on `Re_str` instead of a silent dependency on Cohttp.

## 0.0.5 (2014-03-02):

* Compatibility with Cohttp 0.10.x

## 0.0.4 (2014-02-02):

* Refactor Foundation module for more modularity.
* Add a `Page` module.
* Add PDF type to `Headers`.

## 0.0.3 (2014-02-01):

* Add a `Link` module for keeping track of external articles.
* Fix blog template columns to work better on small devices.
* Add a `Feed` module that aggregates together all the other feeds (Blog/Wiki).
* Add a Google Analytics option to `Foundation.body`.

## 0.0.2 (2013-12-24):

* Factor Wiki support to better support independent sites.
* Add an `Atom_feed` module to drive both the blog and wiki modules.

## 0.0.1 (2013-12-22):

* Initial public release.
