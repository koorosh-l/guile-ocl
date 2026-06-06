(define-module (cl types basic)
  #:use-module (rnrs bytevectors)
  #:use-module ((system foreign) #:prefix ffi:))

(define-public void ffi:void)
(define-public char ffi:int8)
(define-public int ffi:int)
(define-public #{unsigned char}# ffi:uint8)
(define-public #{unsigned int}# ffi:unsigned-int)
(define-public intptr_t ffi:intptr_t)
(define-public size_t ffi:size_t)
(define-public float ffi:float)
(define-public double ffi:double)
(define-public int8_t ffi:int8)
(define-public int16_t ffi:int16)
(define-public int32_t ffi:int32)
(define-public int64_t ffi:int64)
(define-public uint8_t ffi:uint8)
(define-public uint16_t ffi:uint16)
(define-public uint32_t ffi:uint32)
(define-public uint64_t ffi:uint64)

(define (get-reader td)
  (cond
   [(equal? '* td) (get-reader size_t)]

   [(= td ffi:float) bytevector-ieee-single-native-ref]
   [(= td ffi:double) bytevector-ieee-double-native-ref]

   [(= td ffi:int8) bytevector-s8-ref]
   [(= td ffi:int16) bytevector-s16-native-ref]
   [(= td ffi:int32) bytevector-s32-native-ref]
   [(= td ffi:int64) bytevector-s64-native-ref]

   [(= td ffi:uint8) bytevector-u8-ref]
   [(= td ffi:uint16) bytevector-u16-native-ref]
   [(= td ffi:uint32) bytevector-u32-native-ref]
   [(= td ffi:uint64) bytevector-u64-native-ref]
   [else (error "uknown type (might be void)" td)]))

(define (get-writer td)
  (cond
   [(equal? '* td) (get-writer size_t)]

   [(= td ffi:float) bytevector-ieee-single-native-set!]
   [(= td ffi:double) bytevector-ieee-double-native-set!]

   [(= td ffi:int8) bytevector-s8-set!]
   [(= td ffi:int16) bytevector-s16-native-set!]
   [(= td ffi:int32) bytevector-s32-native-set!]
   [(= td ffi:int64) bytevector-s64-native-set!]

   [(= td ffi:uint8) bytevector-u8-set!]
   [(= td ffi:uint16) bytevector-u16-native-set!]
   [(= td ffi:uint32) bytevector-u32-native-set!]
   [(= td ffi:uint64) bytevector-u64-native-set!]
   [else (error "uknown type (might be void)" td)]))


(define-public (refbv type bv ix)
  ((get-reader type) bv (* ix (ffi:sizeof type))))
(define-public (setbv! type bv ix v)
  ((get-writer type) bv (* ix (ffi:sizeof type)) v))
(define-public (allocate type count)
  (make-bytevector (* count (ffi:sizeof type))))
