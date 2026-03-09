#! /bin/sh
# -*- mode: scheme; coding: utf-8 -*-
exec guile -L ./src -s "$0"
!#

(use-modules (sxml simple)
	     (sxml match)
	     (ice-9 match)
	     (ice-9 peg)
	     (system foreign)
	     ((srfi srfi-1) #:select (filter-map)))
(define xml-path "./cl.xml")
(define output "./src/")

(match (command-line)
  [(path) #t]
  [(path x out) (set! xml-path x) (set! output out) #t])

(define types-path
  (string-append output "cl/" "types.scm"))
(define consts-path
  (string-append output "cl/" "consts.scm"))
(define enums-path
  (string-append output "cl/" "enums.scm"))
(define ffi-path
  (string-append output "cl/" "ffi.scm"))

(when (not (file-exists? xml-path))
  (format (current-error-port) "file does not exits ~a\n" xml-path)
  (exit -1))

(when (and (file-exists? output)
	   (not (equal? 'directory (stat:type (stat output)))))
  (format (current-error-port) "output path is occupied ~a\n" xml-path)
  (exit -1))
(when (not (file-exists? output))
  (mkdir output)
  (mkdir (string-append output "cl")))

(define (uniq l)
  (define (inner l res)
    (cond
     [(null? l) res]
     [(member (car l) res) (inner (cdr l) res)]
     [else (inner (cdr l) (cons (car l) res))]))
  (inner l '()))


(define cl
  (sxml-match
   (call-with-input-file "./cl.xml"
     (lambda (p)
       (xml->sxml p
		  #:trim-whitespace? #t)))
   [(*TOP* ,_1 (registry ,_2 ,_3 ,rest ...)) rest]))

(define types
  (filter-map
   (lambda (x)
     (sxml-match x
		 [(type (@ (category ,cat)) ,rest ...) x]
		 ;; [(type )]
		 [,_ #f]))
   (apply append
	  (filter-map (match-lambda
			[('types ('@ _ ...) rest ...) rest]
			[else #f])
		      cl))))
(define type-categories
  (uniq (filter-map
	 (lambda (x)
	   (sxml-match x
		       [(type (@ (category ,cat)) ,rest ...) cat]
		       [,_ #f]))
	 types)))
(define base-types
  (filter (lambda (x)
	    (sxml-match x
			[(type (@ (category "basetype")) ,rest ...) x]
			[,_ #f]))
	  types))
(define defines
  (filter (lambda (x)
	    (sxml-match
	     x
	     [(type (@ (category "define")) ,rest ...) x]
	     [,_ #f]))
	  types))
(define structs
  (filter (lambda (x)
	    (sxml-match
	     x
	     [(type (@ (category "struct")) ,rest ...) x]
	     [,_ #f]))
	  types))

(define (ttype? str)
  (let ([i0 (1- (string-length str))]
	[i1 (1- (1- (string-length str)))])
    (and (char=? (string-ref str i0) #\t)
	 (char=? (string-ref str i1) #\_))))
(define (gen-base-type t)
  (sxml-match-let ([(type (@ (name ,n)))  t])
		  `(define-public ,(string->symbol
				    (cond
				     [(string=? n "unsigned char") "unsigned char"]
				     [(string=? n "unsigned int") "unsigned int"]
				     [else n]))
		     ,(cond
		       [(string=? n "char") 'int8]
		       [(string=? n "unsigned char") 'uint8]
		       [(string=? n "unsigned int") 'unsigned-int]
		       [(defined? (string->symbol n)) (string->symbol n)]
		       [(ttype? n) (primitive-eval (string-drop-right n 2))]
		       [else ptrdiff_t]))))

(define (get-name l)
  (let ([t (assoc 'name (filter list? l))])
    (and t (string->symbol (cadr t)))))
(define (get-type l)
  (let ([t (assoc 'type (filter list? l))])
    (and t (string->symbol (cadr t)))))
(define (simple-define? x)
  (and (get-name x) (get-type x)
       `(define-public ,(get-name x) ,(get-type x))))
(define (typedef? x)
  (and (not (get-type x))
       (not (null?
	     (filter (lambda (s)
		       (string-contains s "typedef"))
		     (filter string? x))))
       `(define-public ,(get-name x) ,size_t)))
(define (cmacro? . a) #f)

(define (gen-define def)
  (or (typedef? def)
      (simple-define? def)
      (cmacro? def)))
;;
(define enums
  (filter-map
   (lambda (x)
     (sxml-match x
		 [(enum (@ (name ,name) (value ,v))) x]
		 [(enum (@ (bitpos ,name))) x]
		 [,_ #f]))
   (apply append
	  (filter-map (match-lambda
			[('enums ('@ _ ...) rest ...) rest]
			[else #f])
		      cl))))
(define (gen-const x)
  (define (s->n s)
    (if (and (>= (string-length s) 2)
	     (char=? (string-ref s 0) #\0)
	     (char=? (string-ref s 1) #\x))
	(string->number (string-drop s 2) 16)
	(string->number s)))
  (sxml-match x
	      [(enum (@ (name ,name) (value ,v)))
	       `(define-public ,(string->symbol name) ,(s->n v))]
	      [(enum (@ (name ,name) (bitpos ,c)))
	       `(define-public ,(string->symbol name) ,(ash 1 (s->n c)))]
	      [,_ #f]))
;;(comment bitpos name value)
(define commands
  (filter-map
   (lambda (x)
     (sxml-match x
		 [(command ,rest ...) x]
		 [,_ (format (current-error-port)
			     "ignoring ~a\n" x)
		     #f]))
   (apply append (filter-map
		  (lambda (x)
		    (sxml-match x
				[(commands ,rest ...) rest]
				[,_ #f]))
		  cl))))
(define (gen-func x)
  (define proto (assoc 'proto (cdr x)))
  (define func-name (car (assoc-ref (cdr proto) 'name)))
  (define func-type (car (assoc-ref (cdr proto) 'type)))
  (define params
    (filter-map (match-lambda
		  [('param rest ...) rest]
		  [('param "const "  rest ...) rest]
		  [else #f])
		x))
  (define arg-names
    (map (lambda (x) (match x
		  [(('type t) ('name n)) (string->symbol n)]
		  [(('type t) (? ptr* str) ('name n))
		   (string->symbol (string-append n "*"))]
		  [("const "('type t) ('name n)) (string->symbol n)]
		  [("const "('type t) (? ptr* str) ('name n))
		   (string->symbol (string-append n "*"))]
		  [else (format (current-error-port)
				"arg-name: didn't match ~a\n" func-name)
			#f]))
	 params))
  (define (ptr* s) (and (string? s) (string-contains s "*")))
  (define arg-types
    (map (lambda (y)
	   (match y
	     [(('type t) ('name n)) (string->symbol t)]
	     [(('type t) (? ptr* str) ('name n)) '*]
	     [("const " ('type t) ('name n)) (string->symbol t)]
	     [("const " ('type t) (? ptr* str) ('name n)) '*]
	     [else (format (current-error-port)
			   "arg-type: didn't match ~a\n" func-name)
		   size_t]))
	 params))
  `(define-public (,(string->symbol func-name) ,@arg-names)
     (foreign-library-function
      (load-foreign-library)
      ,func-name
      #:return-type ,(string->symbol func-type)
      #:arg-types ,arg-types)))
;;
(define features
  (filter-map
   (lambda (x)
     (sxml-match x
		 [(feature ,rest ...) x]
		 [,_ #f]))
   cl))
;;
(define extensions
  (apply append (filter-map
		 (lambda (x)
		   (sxml-match x
			       [(extensions ,rest ...) rest]
			       [,_ #f]))
		 cl)))

;;generation
;; (with-output-to-file types-path
;;   (lambda ()
;;     (display "(define-module (cl types) #:use-module (system foreign))\n\n")
;;     (for-each (lambda (x)
;;		(display x)
;;		(newline))
;;	      (filter-map gen-base-type base-types))))

;; (with-output-to-file consts-path
;;   (lambda ()
;;     (display "(define-module (cl consts) #:use-module (system foreign) #:use-module (cl types))\n\n")
;;     (for-each (lambda (x)
;;		(display x)
;;		(newline))
;;	      (filter-map gen-define defines))))

;; (with-output-to-file enums-path
;;   (lambda ()
;;     (display "(define-module (cl enums) #:use-module (system foreign) #:use-module (cl types))\n\n")
;;     (for-each (lambda (x)
;;		(display x)
;;		(newline))
;;	      (filter-map gen-const enums))))

;; (with-output-to-file ffi-path
;;   (lambda ()
;;     (display
;;      "(define-module (cl ffi)
;;   #:use-module (system foreign)
;;   #:use-module (cl types)
;;   #:use-module (system foreign-library)
;;   #:use-module (rnrs bytevectors)
;;   #:use-module (system foreign))\n")
;;     (for-each (lambda (x)
;;		(display x)
;;		(newline))
;;	      (filter-map gen-func commands))))
