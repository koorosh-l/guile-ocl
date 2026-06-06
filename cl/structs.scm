(define-module (cl structs)
  #:use-module (system foreign)
  #:use-module (system foreign-library)
  #:use-module (rnrs bytevectors)
  #:use-module (cl types derived)
  #:use-module (ice-9 match))

(define-syntax-rule (gen-struct-cons% name (field type) ...)
  (begin
    (define* (name #:key (field 0) ...)
      (let ([bv (make-bytevector (sizeof (list type ...)))])
	(write-c-struct bv 0 ((field type) ...))
	bv))
    (define-public name name)))
(define-syntax gen-struct-cons
  (lambda (x)
    (define (pand syn)
      (datum->syntax
       x
       (apply append
	      (map
	       (match-lambda
		 [(type name count)
		  (map
		   (lambda (i)
		     `(,(string->symbol (format #f
						"~a~a" name i))
		       ,type))
		   (iota count))]
		 [A (list A)])
	       (syntax->datum syn)))))
    (syntax-case x ()
      [(_ name . l)
       #`(gen-struct-cons%
	  name
	  #,@(pand #'l))])))
(define-syntax-rule (structer name (field type) ...)
  (begin
    (gen-struct-cons name (field type) ...)
    ))
(define image-desc-layout
  `((cl_mem_object_type image_type)
    (size_t             image_width)
    (size_t             image_height)
    (size_t             image_depth)
    (size_t             image_array_size)
    (size_t             image_row_pitch)
    (size_t             image_slice_pitch)
    (cl_uint            num_mip_levels)
    (cl_uint            num_samples)
    (cl_mem             buffer)
    (cl_mem             mem_object)))

(gen-struct-cons image-format
		 (channel-order cl_channel_order)
		 (channel-type  cl_channel_type))
(gen-struct-cons image-desc
		 (image-type        uint64)
		 (image-width       cl_mem_object_type)
		 (image-height      size_t)
		 (image-depth       size_t)
		 (image-array-size  size_t)
		 (image-row-pitch   size_t)
		 (image-slice-pitch size_t)
		 (num-mip-levels    size_t)
		 (num-samples       cl_uint)
		 (buffer            cl_uint))
(gen-struct-cons buffer-origin
		 (origin size_t)
		 (size size_t))
(gen-struct-cons name-version
		 (version cl_version)
		 (cl_char name 64))
