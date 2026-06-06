(define-module (cl types opaque)
  #:use-module (ice-9 format)
  #:use-module ((srfi srfi-1) #:select (any))
  #:use-module ((cl enums) #:prefix en:)
  #:use-module ((cl types basic) #:select (setbv! allocate ))
  #:use-module (srfi srfi-9)
  #:use-module (system foreign)
  #:use-module (rnrs bytevectors)
  #:use-module (system foreign-library)
  #:export (opaque-instance **))

;; this implementation assumes that sizeof all opaque types are '*

(define-public opaque-types '())
(define-public opaque-type-preds '())
(define-public opaque-type-apis '())
(define-public opaque-type-apis-name '())
(define-syntax define-opaque-type
  (lambda (x)
    (define (pred-namer syn prefix)
      (datum->syntax x
		     (string->symbol (string-append
				      prefix
				      (format #f "~a?"
					      (symbol->string (syntax->datum syn)))))))
    (define (wrap-namer syn prefix)
      (datum->syntax x
		     (string->symbol (string-append
				      prefix
				      (format #f "wrap-~a"
					      (symbol->string (syntax->datum syn)))))))
    (define (unwrap-namer syn prefix)
      (datum->syntax x
		     (string->symbol (string-append
				      prefix
				      (format #f "unwrap-~a"
					      (symbol->string (syntax->datum syn)))))))
    (define (format-str syn)
      (format #f "<~a #x~~x>"
	      (symbol->string (syntax->datum syn))))
    (syntax-case x ()
      [(_ name)
       #`(begin
	   (set! opaque-types (cons 'name opaque-types))
	   (define-wrapped-pointer-type
	     name
	     #,(pred-namer #'name "p")
	     #,(wrap-namer #'name "p")
	     #,(unwrap-namer #'name "p")
	     (lambda (p port)
	       (format port
		       #,(format-str #'name)
		       (pointer-address (#,(unwrap-namer #'name "p") p)))))
	   (define-public #,(pred-namer #'name "") #,(pred-namer #'name "p"))
	   (define-public #,(wrap-namer #'name "") #,(wrap-namer #'name "p"))
	   (define-public #,(unwrap-namer #'name "") #,(unwrap-namer #'name "p"))
	   (define-public name name)
	   (set! opaque-type-apis
	     (cons `(name ,#,(pred-namer #'name "")
			  ,#,(wrap-namer #'name "")
			  ,#,(unwrap-namer #'name ""))
		   opaque-type-apis))
	   (set! opaque-type-apis-name
	     (cons `(name #,(pred-namer #'name "")
			  #,(wrap-namer #'name "")
			  #,(unwrap-namer #'name ""))
		   opaque-type-apis-name)))])))

(define-public (opaque-type? t)
  (or (and symbol?
	   (any (lambda (i)
		  (equal? i t))
		opaque-types))
      (any (lambda (p)
	     (p t))
	   opaque-type-preds)))
(define-public (get-opaque-type-pred n)
  (and (opaque-type? n) (list-ref (assoc-ref opaque-type-apis n) 0)))
(define-public (get-opaque-type-wraper n)
  (and (opaque-type? n) (list-ref (assoc-ref opaque-type-apis n) 1)))
(define-public (get-opaque-type-unrwaper n)
  (and (opaque-type? n) (list-ref (assoc-ref opaque-type-apis n) 2)))

(define-public (get-opaque-type-pred-name n)
  (and (opaque-type? n) (list-ref (assoc-ref opaque-type-apis-name n) 0)))
(define-public (get-opaque-type-wraper-name n)
  (and (opaque-type? n) (list-ref (assoc-ref opaque-type-apis-name n) 1)))
(define-public (get-opaque-type-unrwaper-name n)
  (and (opaque-type? n) (list-ref (assoc-ref opaque-type-apis-name n) 2)))

(define-public (opaque-array type count)
  (let ([rapper (get-opaque-type-wraper type)]
	[bv  (make-bytevector (* (sizeof '*) count))])
    (rapper (bytevector->pointer bv))))

(define-opaque-type cl_accelerator_intel)
(define-opaque-type cl_GLsync)
(define-opaque-type cl_platform_id)
(define-opaque-type cl_device_id)
(define-opaque-type cl_context)
(define-opaque-type cl_command_queue)
(define-opaque-type cl_mem)
(define-opaque-type cl_program)
(define-opaque-type cl_kernel)
(define-opaque-type cl_event)
(define-opaque-type cl_sampler)
(define-opaque-type cl_semaphore_khr)
(define-opaque-type cl_icd_dispatch)
(define-opaque-type cl_command_buffer_khr)
(define-opaque-type cl_mutable_command_khr)

(define (list->bv type l) ;; find a place for this to refactor
  (let ([bv (make-bytevector (* (sizeof type) (length l)))])
    ;; generic bv setter getters for cl-types
    (for-each (lambda (ix v)
		(bytevector-u64-native-set! bv
					    (* ix (sizeof type))
					    v))
	      (iota (length l))
	      l)
    bv))

;; (define-syntax def-prop
;;   (syntax-rules ()
;;     [(_ prop-type (name type) ...) 1]))
;; check docs
;; (define-public cl_egl_image_properties_khr intptr_t)
;; (define-public cl_import_properties_arm intptr_t)
(define-opaque-type cl_device_partition_property)
(define-opaque-type cl_context_properties)
;; (define-public cl_pipe_properties intptr_t)  not defined by opencl yet
(define (make-cl-property prop-type . props)
  ((get-opaque-type-wraper prop-type)
   (bytevector->pointer
    (list->bv '*
	      (append (apply append props) '(0))))))

(define-public (get-type ptr)
  (let loop ([types opaque-types])
    (cond
     [(null? types) #f]
     [((get-opaque-type-pred (car types)) ptr)
      (car types)]
     [else (loop (cdr types))])))

(define-public (generic-unwrap opq-ptr)
  (if (pointer? opq-ptr)
      opq-ptr
      ((get-opaque-type-unrwaper
	(get-type opq-ptr))
       opq-ptr)))

(define-public (wrap type p)
  ((get-opaque-type-wraper type) p))
(define-public (unwrap type v)
  (if (and (pointer? v) (null-pointer? v))
      %null-pointer
      ((get-opaque-type-unrwaper type) v)))

(define* (opaque-instance type #:optional (v 0))
  (let ([bv (allocate '* 1)])
    (setbv! '* bv 0 v)
    ((get-opaque-type-wraper type)
     (bytevector->pointer bv))))

(define-public (& ptr)
  (when (and (not (pointer? ptr))
	     (not (opaque-type? (get-type ptr))))
    (error "in function *&* argument is not a pointer: " ptr))
  (make-pointer
   (+ 8 (pointer-address (scm->pointer (generic-unwrap ptr))))))
(define* (** ptr #:optional (type #f))
  (if type
      (wrap type (dereference-pointer ptr))
      (dereference-pointer ptr)))
