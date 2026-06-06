(define-module (cl array)
  #:use-module ((system foreign) #:prefix ffi:)
  #:use-module (rnrs bytevectors))

(display
 "!!!FUNCTIONS IN THIS MODULE DIRECTLY MODIFY THE TYPE HEADERS OF GUILE,
YOU SHOULD BE CAREFUL OF THE LENGTH OF THE BYTEVECTOR,
THIS CAN BE VERY INCONSISTENT AND DANGEROUS USE AT YOUR OWN RISK!!!!\n")
;; (setbv! uint8_t header 0 77) (setbv! uint8_t header 1 132)
(eval-when (expand)
    (define (find-sig ar)
      (let ([bv (ffi:pointer->bytevector
		 (ffi:scm->pointer ar)
		 2)])
	(bytevector-u16-native-ref bv 0))))
(define (set-header-to bv sig)
  (let ([header (ffi:pointer->bytevector
		 (ffi:scm->pointer bv) 2)])
    (bytevector-u16-native-set! header 0 sig)))
(define types '(u8 s8 u16 s16 u32 s32 u64 s64 f32 f64 c32 c64))

(define-macro (gen-sig . tag)
  `(begin
     ,@(map
	(lambda (t)
	  `(define-public ,(symbol-append t '-sig)
	     ,(find-sig (make-typed-array t 99 1))))
	tag)))
(gen-sig u8 s8 u16 s16 u32 s32 u64 s64 f32 f64 c32 c64)

(define-macro (make-caster . tag)
  `(begin
     ,@(map (lambda (t)
	      `(define-public (,(symbol-append 'bv-> t 'vector!) bv)
		 (set-header-to bv ,(symbol-append t '-sig))))
	    tag)))

(make-caster u8 s8 u16 s16 u32 s32 u64 s64 f32 f64 c32 c64)
