open Printf
open Lwt

let t =
  Cohttp_lwt_unix.Client.get (Uri.of_string (Sys.argv.(1)))
  >>= function
  | None -> failwith "error"
  | Some (r, b) ->
      Cohttp_lwt_body.string_of_body b
      >>= fun buf ->
      print_endline buf;
      return ()

let _ = Lwt_main.run t
