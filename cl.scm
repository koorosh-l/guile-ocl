(define-module (cl)
  #:use-module (system foreign-library))

(define-public (cl-link . search-path) ;; make-it optional
  (load-foreign-library
   "libOpenCL"
   #:search-path '("/home/quasikote/proj/scheme-gpgpu/playground/libs/")))
;; (define (primitive-cl-type->guile-type cl-type)
;;   (case cl-type
;;     [(cl_char)   int8]
;;     [(cl_uchar)  uint8]
;;     [(cl_short)  int16]
;;     [(cl_ushort) uint16]
;;     [(cl_int)    int32]
;;     [(cl_uint)   uint32]
;;     [(cl_long)   int64]
;;     [(cl_ulong)  uint64]
;;     [(cl_half)   int16]
;;     [(cl_float)  float]
;;     [(cl_double) double]
;;     [else #f]))
;; (define (cl-type->guile-type cl-type)
;;   (or (primitive-cl-type->guile-type cl-type) ;;buggy?
;;       cl-type))
;; (define (kebab-case str)
;;   (list->string
;;    (reverse (let loop ([l (string->list str)]
;;		       [res '()])
;;	      (cond
;;	       [(null? l) res]
;;	       [(char-upper-case? (car l))
;;		(loop (cdr l)
;;		      `(,(char-downcase (car l)) #\- . ,res))]
;;	       [(char=? (car l) #\_)
;;		(loop (cdr l)
;;		      (cons #\- res))]
;;	       [else (loop (cdr l)
;;			   (cons (car l) res))]))))0)

;; (define-syntax cl-ffi
;;   (lambda (x)
;;     (define (typer syn)
;;       (datum->syntax x (cl-type->guile-type (syntax->datum syn))))
;;     (define (scheme-namer syn)
;;       (datum->syntax x
;;		     (string->symbol
;;		      (kebab-case (syntax->datum syn)))))
;;     (define (stringer syn)
;;       (datum->syntax x (symbol->string (syntax->datum syn)))) ;;unused
;;     (define (arg-name1 syn)
;;       (map (lambda (e) (datum->syntax x e))
;;	   (map (match-lambda
;;		  [(type '* name) name]
;;		  [(type name) name])
;;		(syntax->datum syn))))
;;     (define (ffi-typer syn)
;;       (map (lambda (e) (datum->syntax x e))
;;	   (map (match-lambda
;;		  [(type '* name) type]
;;		  [(type name) type])
;;		(syntax->datum syn))))
;;     (syntax-case x ()
;;       [(_ cname return-type . type-spec)
;;        #`(begin
;;	   (define tmp
;;	     (foreign-library-function
;;	      cl
;;	      cname
;;	      #:return-type return-type
;;	      #:arg-types #,(ffi-typer #'type-spec)
;;	      ))
;;	   (define (#,(scheme-namer #'cname)
;;		    #,@(arg-name1 #'type-spec))
;;	     (tmp #,@(arg-name1 #'type-spec)))
;;	   )])))
