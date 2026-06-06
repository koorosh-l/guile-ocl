(define-module (cl ffi)
  #:use-module (cl spec)
  #:use-module ((srfi srfi-1) #:select (filter-map))
  #:use-module (ice-9 match)
  #:use-module (ice-9 format)
  #:use-module ((system foreign) #:prefix ffi:)
  #:use-module ((cl) #:select (cl-link))
  #:use-module (cl config)
  #:use-module (cl types basic)
  #:use-module (cl types derived)
  #:use-module (system foreign-library)
  #:use-module (rnrs bytevectors))

(define-syntax import-func
  (lambda (x)
    (define (namer syn)
      (datum->syntax x (symbol->string (syntax->datum syn))))
    (define (arg-types syn)
      (datum->syntax
       x
       (cons 'list
	     (map (match-lambda
		    [(name type 'no-ptr _)
		     type]
		    [(name type 'ptr _)
		     ''*])
		  (syntax->datum syn)))))
    (define (returner syn)
      (datum->syntax
       x
       (match (syntax->datum syn)
	 [(t *) ''*]
	 [(t) t])))
    (syntax-case x ()
      [(_ name return args)
       #`(eval-when (load eval)
	   (define-public name
	     (with-exception-handler
		 (lambda (e)
		   (format (current-error-port)
			   "looking up ~a failed in ~a\n" 'name cl-link)
		   (lambda a
		     (format (current-error-port)
			     "looking up ~a failed\n" 'name)
		     #f))
	       (lambda ()
		 (foreign-library-function
		  cl-link
		  #,(namer #'name)
		  #:return-type #,(returner #'return)
		  #:arg-types #,(arg-types #'args)))
	       #:unwind? #t)))])))

(define-syntax import-all
  (lambda (x)
    (define (gen)
      (datum->syntax
       x
       (map (lambda (e)
	      `(import-func ,@e))
	    cl2)))
    (syntax-case x ()
      [(_)
       #`(begin
	   #,@(gen))])))

(define UINT ffi:unsigned-int)
(define cl_dx9_media_adapter_set_khr cl_uint)
(define cl_dx9_device_set_intel cl_uint)
(define cl_dx9_device_source_intel cl_uint)
(define cl_dx9_media_adapter_type_khr cl_uint)
(define HANDLE size_t)
(import-all)
