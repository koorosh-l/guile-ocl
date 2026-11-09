#! /bin/sh
# -*- mode: scheme; coding: utf-8 -*-
exec guile -L ./src -s "$0"
!#

(load "/home/quasikote/.guile")
(add-to-load-path "/home/quasikote/proj/scheme-gpgpu/src/")
(use-modules (system repl server))
(run-server (make-tcp-server-socket #:port 9990))
