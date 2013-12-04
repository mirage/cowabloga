---
title: A 21st Century IDE
layout: default
---

# A 21st Century IDE<br /><small>Merlin, Tuareg and <code>ocp-indent</code></small>

I finally decided to sit down and get the shiny new [merlin][] mode for OCaml working with my emacs configuration. Basically, really rather simple in the end although (in the usual fashion!) I did end up spending considerable time tweaking various other customisations...

Most of the information below is based on the following sources:

+ <http://github.com/def-lkb/merlin#emacs-interface>
+ <http://zheng.li/buzzlogs-ocaml/2013/08/23/irc.html>
+ <http://www.ocamlpro.com/blog/2013/03/18/monthly-03.html>

Before we begin, install `merlin`:

    $ opam install merlin

The complete [commit][] change is in my [github][] account (combined with a large cleanup of various other aborted OCaml configurations). Breaking it down a bit, first setup some paths: where to find `ocp-indent`,  `merlin.el` for `merlin-mode`, and the `ocamlmerlin` command itself. Note that this relies on the current state of `opam`, so when you start `emacs` be sure to have selected the `opam` compiler-switch that you installed the `merlin` package into, above.

{% highlight common-lisp %}
;; ocp-indent
(load-file (concat
            (substring (shell-command-to-string "opam config var prefix") 0 -1)
            "/share/typerex/ocp-indent/ocp-indent.el"
            ))

;; merlin-mode
(push (concat
       (substring (shell-command-to-string "opam config var share") 0 -1)
       "/emacs/site-lisp"
       )
      load-path)

(setq merlin-command
      (concat
       (substring (shell-command-to-string "opam config var bin") 0 -1)
       "/ocamlmerlin"
       ))
(autoload 'merlin-mode "merlin" "Merlin mode" t)
{% endhighlight %}

Now the meat: when we select `tuareg-mode`, use `ocp-indent` to indent lines, turn on `merlin` auto-complete, and finally set a couple of local key bindings so that I can fix up `merlin` to not conflict with my now-neurologically-hardwired navigation keys.

{% highlight common-lisp %}
(add-hook 'tuareg-mode-hook
          '(lambda ()
             (merlin-mode)
             (setq indent-line-function 'ocp-indent-line)
             (setq merlin-use-auto-complete-mode t)
             (local-set-key (kbd "C-S-<up>") 'merlin-type-enclosing-go-up)
             (local-set-key (kbd "C-S-<down>") 'merlin-type-enclosing-go-down)
             ))
{% endhighlight %}

Finally, do the usual to use `tuareg-mode` for OCaml/F# editing.

{% highlight common-lisp %}
(push'("\\.ml[iylp]?" . tuareg-mode) auto-mode-alist)
(push '("\\.fs[ix]?" . tuareg-mode) auto-mode-alist)
{% endhighlight %}

And that's it!

[merlin]: http://kiwi.iuwt.fr/~asmanur/blog/merlin/
[commit]: https://github.com/mor1/rc-files/commit/4a2b0be59081d6df0640af39b48c75c20443c8dc
[github]: http://github.com/mor1
