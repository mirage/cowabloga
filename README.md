Helper OCaml libraries for setting up a blog and wiki, using
the Zurb Foundation CSS/HTML templates.

If you want to extend an oasis generated Makefile rule, you need to edit the rule in the Makefile to be a double-colon rule; you can then put your additions in Makefile.local (and any environment/variable setup in Makefile.env). As this edits the oasis generated portion, this will cause whining by oasis if you ask it to regenerate it's setup (`make configure`) -- just make sure you copy any changes across from the Makefile.bak that oasis creates.

Added rules include

    setup-clean -- remove all `oasis` droppings
    setup -- rerun `oasis` to reconstruct setup infrastructure
    site -- build entire `site`
    run -- run `site` once built
