(define-module (cl functions)
  #:use-module (ice-9 iconv)
  #:use-module ((srfi srfi-1) #:select (filter-map any))
  #:use-module ((srfi srfi-4) #:prefix har:)
  #:use-module (srfi srfi-26)
  #:use-module (ice-9 match)
  #:use-module (ice-9 peg)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 iconv)
  #:use-module (rnrs bytevectors)
  #:use-module (cl ffi)
  #:use-module (cl types info)
  #:use-module (cl types basic)
  #:use-module ((cl types opaque) #:prefix opq:)
  #:use-module ((cl types opaque)
		#:select (unwrap wrap generic-unwrap))
  #:use-module (cl types error)
  #:use-module (cl types derived)
  #:use-module ((cl enums) #:prefix cln:)
  #:use-module ((system foreign) #:prefix ffi:)
  #:use-module ((system foreign-library) #:prefix ffl:))

(define (list->bv type l)
  (let ([bv (allocate type (length l))])
    (for-each (lambda (ix v)
		(setbv! type bv ix v))
	      (iota (length l))
	      l)
    bv))
(define* (bv->list type bv #:key (count (/ (bytevector-length bv)
					   (sizeof type))))
  (map (lambda (ix)
	 (refbv type bv ix))
       (iota count)))
(define bytevector->pointer ffi:bytevector->pointer)
(define make-pointer ffi:make-pointer)
(define sizeof ffi:sizeof)
(define %null-pointer ffi:%null-pointer)
(define pointer-address ffi:pointer-address)
(define string->pointer ffi:string->pointer)

(define-public (make-prop-bv type . l)
  (if (zero? (length l))
      %null-pointer
      (bytevector->pointer
       (list->bv type (append l '(0))))))

(eval-when (expand load compile eval)
  (define-peg-pattern num body
    (* (range #\0 #\9)))
  (define-peg-pattern up body
    (+ (or (range #\A #\Z)
	   (range #\0 #\9))))
  (define-peg-pattern dw body
    (+ (or (range #\a #\z)
	   (range #\0 #\9))))
  (define-peg-pattern ca body
    (and (range #\A #\Z)
	 (+ (or (range #\a #\z)
		(range #\0 #\9)))))
  (define-peg-pattern plu body
    (or
     "2D"
     "3D"
     "Texture2D"
     "Texture3D"
     "AMD"
     "ARM"
     "D3D10"
     "D3D11"
     "D3D12"
     "DX9"
     "EGL"
     "GL"
     ;; "Gr"
     "ICD"
     "IDs"
     "IL"
     "INTEL"
     "Image2D"
     "Image3D"
     "KHR"
     "ND"
     "NVIDIA"
     "OCL"
     "SVM"
     "VA"
     ))
  (define-peg-pattern element all (or plu ca dw up))
  (define-peg-pattern name body (+ element))
  (define (kebab-case str)
    (string-append
     (string-downcase
      (string-join
       (cdr (map cadr (peg:tree (match-pattern name str)))) "-")))))

(define-syntax def-cl
  (lambda (x)
    (define (k-case syn)
      (datum->syntax
       x
       (string->symbol (kebab-case (symbol->string (syntax->datum syn))))))
    (syntax-case x ()
      [(_ (name args ...) return body ...)
       #`(begin
	   (define* (#,(k-case #'name) args ...)
	     (let ([#,(datum->syntax x 'api) (@ (cl ffi) name)])
	       body ...))
	   (module-export! (current-module) '(#,(k-case #'name))))])))
(define-syntax-rule (def-get-info name info-key unwrapper)
  (def-cl (name arg param-name count)
    cl_int
    (let* ([pbv (allocate-info-bv 'info-key param-name count)]
	   [ret-size-bv (allocate size_t 1)]
	   [ret (api unwrapper
		     param-name
		     (bytevector-length pbv)
		     (bytevector->pointer pbv)
		     (bytevector->pointer ret-size-bv))]
	   [ret-size (refbv size_t ret-size-bv 0)])
      (if (< ret 0)
	  (find-error ret)
	  (read-info 'info-key param-name pbv
		     (bytes->count 'info-key param-name ret-size))))))

(define-inlinable (ix f bound)
  (let loop ([i 0])
    (when (< i bound)
      (f i)
      (loop (1+ i)))))

(def-cl (clGetPlatformIDs count) cl_int
  (let* ([platforms-bv (allocate cl_platform_id  count)]
	 [ret-count-bv (allocate cl_uint 1)]
	 [ret (clGetPlatformIDs count
				(bytevector->pointer platforms-bv)
				(bytevector->pointer ret-count-bv))])
    (if (< ret 0)
	(find-error ret)
	(begin
	  (map (lambda (i)
		 (wrap 'cl_platform_id
		       (make-pointer
			(bytevector-u64-native-ref platforms-bv
						   (* i (sizeof cl_platform_id))))))
	       (iota (bytevector-u32-native-ref ret-count-bv 0)))))))
(def-cl (clGetPlatformInfo platform-id param-name count) cl_int
  (let* ([pbv (allocate-info-bv 'platform-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_platform_id platform-id)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (bytevector-u64-native-ref ret-size-bv 0)])
    (if (< ret 0)
	(resolve-error 'cl-error ret)
	(read-info 'platform-info
		   param-name
		   pbv
		   (bytes->count 'platform-info param-name ret-size)))))

(def-cl (clGetDeviceIDs platform
			#:key
			(dev-type cln:CL_DEVICE_TYPE_ALL)
			(count 1))
  cl_int
  (let* ([devs-bv (allocate cl_device_id count)]
	 [ret-count-bv (allocate cl_uint 1)]
	 [ret (clGetDeviceIDs (unwrap 'cl_platform_id platform)
			      dev-type
			      count
			      (bytevector->pointer devs-bv)
			      (bytevector->pointer ret-count-bv))])
    ret
    (if (< ret 0)
	(find-error ret)
	(begin
	  (map (lambda (i)
		 (wrap 'cl_device_id
		       (make-pointer
			(bytevector-u64-native-ref devs-bv
						   (* i (sizeof cl_device_id))))))
	       (iota (bytevector-u32-native-ref ret-count-bv 0)))))))
(def-cl (clGetDeviceInfo dev-id param-name count) cl_int
  (let* ([pbv (allocate-info-bv 'device-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_device_id dev-id)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (bytevector-u64-native-ref ret-size-bv 0)])
    (if (< ret 0)
	(resolve-error 'cl-error ret)
	(read-info 'device-info
		   param-name
		   pbv
		   (bytes->count 'device-info param-name ret-size)))))

(def-cl (clCreateSubDevices device properties num-sub-devices)
  cl_int
  (let* ([devs-bv (allocate cl_device_id num-sub-devices)]
	 [ret-count-bv (allocate cl_uint 1)]
	 [ret (clCreateSubDevices
	       (unwrap 'cl_device_id device)
	       properties
	       num-sub-devices
	       (bytevector->pointer devs-bv)
	       (bytevector->pointer ret-count-bv))])
    (if (< ret 0)
	ret
	(begin
	  (map (compose
		(cut wrap 'cl_device_id <>)
		make-pointer
		(cut refbv cl_device_id devs-bv <>))
	       (iota (refbv cl_uint
			    ret-count-bv 0)))))))

(def-cl (clRetainDevice dev) cl_int
  (clRetainDevice (unwrap 'cl_device_id dev)))
(def-cl (clReleaseDevice dev) cl_int
  (clReleaseDevice (unwrap 'cl_device_id dev)))

(def-cl (clSetDefaultDeviceCommandQueue ctx dev q)
  cl_int
  (find-error (api (unwrap 'cl_context ctx)
		   (unwrap 'cl_device_id dev)
		   (unwrap 'cl_command_queue q))))

(def-cl (clGetDeviceAndHostTimer dev)
  cl_int
  (let* ([host-stamp   (allocate cl_ulong 1)]
	 [device-stamp (allocate cl_ulong 1)]
	 [ret (clGetDeviceAndHostTimer
	       (unwrap 'cl_device_id dev)
	       (bytevector->pointer device-stamp)
	       (bytevector->pointer host-stamp))])
    (if (< ret 0)
	(find-error ret)
	(begin
	  (cons (refbv cl_ulong host-stamp   0)
		(refbv cl_ulong device-stamp 0))))))
(def-cl (clGetHostTimer dev) cl_int
  (let* ([host-stamp (allocate cl_ulong 1)]
	 [ret (api (unwrap 'cl_device_id dev)
		   (bytevector->pointer host-stamp))])
    (if (< ret 0)
	(find-error ret)
	(refbv cl_ulong host-stamp 0))))

(def-cl (clCreateContext devs
			 #:key
			 (properties %null-pointer)
			 (notify  %null-pointer)
			 (user-data  %null-pointer))
  cl_context
  (let* ([err-bv (allocate cl_int 1)]
	 [dev-bv (list->bv cl_device_id
			   (map (lambda (did)
				  (ffi:pointer-address
				   (unwrap 'cl_device_id did)))
				devs))]
	 [ctx (api properties
		   (length devs)
		   (bytevector->pointer dev-bv)
		   notify
		   user-data
		   (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(find-error err)
	(wrap 'cl_context ctx))))
(def-cl (clCreateContextFromType dev-type
				 #:key
				 (properties %null-pointer)
				 (notify %null-pointer)
				 (user-data %null-pointer))
  cl_context
  (let* ([err-bv (allocate cl_int 1)]
	 [ctx (api properties
		   dev-type
		   notify
		   user-data
		   (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(find-error err)
	(wrap 'cl_context ctx))))

(def-cl (clRetainContext ctx) cl_int
  (find-error (clRetainContext (unwrap 'cl_context ctx))))
(def-cl (clReleaseContext ctx) cl_int
  (find-error (clReleaseContext (unwrap 'cl_context ctx))))
(def-cl (clGetContextInfo context param-name count) cl_int
  (let* ([pbv (allocate-info-bv 'context-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_context context)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(resolve-error 'cl-error ret)
	(read-info 'context-info param-name pbv
		   (bytes->count 'context-info param-name ret-size)))))
(def-cl (clSetContextDestructorCallback ctx
					#:key
					(notify %null-pointer)
					(user-data %null-pointer))
  cl_int
  (find-error (api (unwrap 'cl_context ctx)
		   notify
		   user-data)))

(def-cl (clCreateCommandQueueWithProperties ctx dev
					    #:key
					    (properties %null-pointer))
  cl_int
  (let* ([err-bv (allocate cl_int 1)]
	 [q (api
	     (unwrap 'cl_context ctx)
	     (unwrap 'cl_device_id dev)
	     properties
	     (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(resolve-error 'cl-error err)
	(wrap 'cl_command_queue q))))
(def-cl (clRetainCommandQueue q) cl_int
  (api (unwrap 'cl_command_queue q)))
(def-cl (clReleaseCommandQueue q) cl_int
  (api (unwrap 'cl_command_queue q)))
(def-cl (clGetCommandQueueInfo q param-name count) cl_int
  (let* ([pbv (allocate-info-bv 'queue-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_command_queue q)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(resolve-error 'cl-error ret)
	(read-info 'queue-info param-name pbv
		   (bytes->count 'queue-info param-name ret-size)))))

(def-cl (clCreateBuffer ctx flags ptr size) cl_mem
  (let* ([err-bv (allocate cl_int 1)]
	 [mem (clCreateBuffer (unwrap 'cl_context ctx)
			      flags
			      size
			      ptr
			      (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(find-error err)
	(wrap 'cl_mem mem))))
(def-cl (clCreateBufferWithProperties ctx properties flags size ptr)
  cl_mem
  (let* ([err-bv (allocate cl_int 1)]
	 [mem (clCreateBufferWithProperties
	       (unwrap 'cl_context ctx)
	       properties
	       flags
	       size
	       ptr
	       (refbv cl_int err-bv 0))]
	 [err (bytevector-s32-native-ref err-bv 0)])
    (if (< err 0)
	(find-error err)
	(wrap 'cl_mem mem))))
(def-cl (clCreateSubBuffer buffer flags
			   #:key
			   (offset %null-pointer)
			   (size %null-pointer))
  cl_mem
  (let* ([err-bv (allocate cl_int 1)]
	 [mem (clCreateSubBuffer (unwrap 'cl_buffer buffer)
				 flags
				 offset
				 size
				 (make-pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(find-error err)
	(wrap 'cl_mem mem))))

(def-cl (clCreateImage ctx flags img-format img-desc ptr) cl_mem
  (let* ([err-bv (allocate cl_int 1)]
	 [mem (api (unwrap 'cl_context ctx)
		   flags
		   (bytevector->pointer img-format)
		   (bytevector->pointer img-desc)
		   ptr
		   (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(find-error err)
	(wrap 'cl_mem mem))))
(def-cl (clCreateImageWithProperties ctx properties
				     flags image-format
				     image-desc ptr)
  cl_mem
  (let* ([err-bv (allocate cl_int 1)]
	 [mem (clCreateImageWithProperties (make-pointer ctx)
					   (make-pointer properties)
					   flags
					   (make-pointer image-format)
					   (make-pointer image-desc)
					   ptr
					   (make-pointer err-bv))]
	 [err (bytevector-s32-native-ref err-bv 0)])
    (if (< err 0)
	err
	mem)))

(def-cl (clCreatePipe ctx flags packet-size max-packets properties)
  cl_mem
  (let* ([err-bv (allocate cl_int 1)]
	 [pipe (clCreatePipe (unwrap 'cl_context ctx)
			     flags
			     packet-size
			     max-packets
			     properties
			     (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(find-error err)
	pipe)))

(def-cl (clRetainMemObject mem) cl_int
  (find-error (clRetainMemObject (unwrap 'cl_mem mem))))
(def-cl (clReleaseMemObject mem) cl_int
  (find-error (clRetainMemObject (unwrap 'cl_mem mem))))

(def-cl (clGetSupportedImageFormats ctx flags image-type num) cl_int
  10)

(def-cl (clGetMemObjectInfo mem param-name count) cl_uint
  (let* ([pbv (allocate-info-bv 'mem-info param-name count)]
	 [ret-size-bv (allocate  size_t 1)]
	 [ret (api (unwrap 'cl_mem mem)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(resolve-error 'cl-error ret)
	(read-info 'mem-info param-name pbv
		   (bytes->count 'mem-info param-name ret-size)))))

(def-cl (clGetImageInfo image param-name count) cl_uint
  (let* ([pbv (allocate-info-bv 'image-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_mem image)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(find-error ret)
	(read-info 'image-info param-name pbv
		   (bytes->count 'image-info param-name ret-size)))))

(def-cl (clGetPipeInfo pipe param-name count) cl_uint
  (let* ([pbv (allocate-info-bv 'pipe-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_mem pipe)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(find-error ret)
	(read-info 'pipe-info param-name pbv
		   (bytes->count 'pipe-info param-name ret-size)))))

(def-cl (clSetMemObjectDestructorCallback mem func data) cl_int
  (find-error (api (unwrap 'cl_mem mem) func data)))

(def-cl (clSVMAlloc ctx flags size alignment)
  *
  (clSVMAlloc (unwrap 'cl_context ctx)
	      flags size alignment))
(def-cl (clSVMFree context ptr)
  void
  (clSVMFree (unwrap 'cl_context context) ptr))

(def-cl (clCreateSamplerWithProperties context sampler_properties errcode_ret )
  cl_sampler
  (let* ([err-bv (allocate cl_int 1)]
	 [ret
	  (clCreateSamplerWithProperties
	   context
	   sampler_properties
	   (make-pointer err-bv))]
	 [err (bytevector-s32-native-ref err-bv 0)])
    (if (< err 0) (find-error err) ret)))
(def-cl (clRetainSampler sampler) cl_int (find-error (api (unwrap 'cl_sampler sampler))))
(def-cl (clReleaseSampler sampler) cl_int (find-error (api (unwrap 'cl_sampler sampler))))
(def-cl (clGetSamplerInfo sampler param-name count) cl_uint
  (let* ([pbv (allocate-info-bv 'pipe-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_sampler sampler)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(find-error ret)
	(read-info 'pipe-info param-name pbv
		   (bytes->count 'pipe-info param-name ret-size)))))

(def-cl (clCreateProgramWithSource ctx sources)
  cl_program
  (let* ([err-bv (allocate cl_int 1)]
	 [count  (length sources)]
	 [lenz   (list->bv size_t (map string-length sources))]
	 [strings (list->bv
		   size_t
		   (map (lambda (s)
			  (pointer-address
			   (bytevector->pointer
			    (string->bytevector (string-append s "\x00") "UTF-8"))))
			sources))]
	 [ret (api
	       (unwrap 'cl_context ctx)
	       count
	       (bytevector->pointer strings)
	       (bytevector->pointer lenz)
	       (bytevector->pointer err-bv))]
	 [err (bytevector-s32-native-ref err-bv 0)])

    (if (< err 0)
	(find-error err)
	(wrap 'cl_program ret))))
(def-cl (clCreateProgramWithBinary ctx devs bins) cl_program
  (let* ([err-bv (allocate cl_int 1)]
	 [dev-count (length devs)]
	 [dev-list  (list->bv size_t devs)]
	 [lenz      (list->bv size_t (map bytevector-length bins))]
	 [bin-list  (list->bv size_t (map (compose
					   pointer-address
					   bytevector->pointer)
					  bins))]
	 [bin-status (allocate cl_int (length devs))]
	 [ret (clCreateProgramWithBinary
	       ctx
	       dev-count
	       (bytevector->pointer dev-list)
	       (bytevector->pointer lenz)
	       (bytevector->pointer bin-list)
	       (bytevector->pointer bin-status)
	       (bytevector->pointer err-bv))]
	 [err (bytevector-s32-native-ref err-bv 0)]
	 [status (map (lambda (ix)
			(bytevector-s32-native-ref
			 bin-status
			 (* ix (sizeof cl_int))))
		      (iota (length devs)))])
    (cond
     [(< err 0) (find-error err)]
     [(any (cut < <> 0) status) (map find-error status)]
     [else ret])))
(def-cl (clCreateProgramWithBuiltInKernels ctx devs kernel-names)
  cl_program
  (let* ([err-bv (allocate cl_int 1)]
	 [dev-list  (list->bv size_t devs)]
	 [ret (clCreateProgramWithBuiltInKernels
	       ctx
	       (length devs)
	       (bytevector->pointer dev-list)
	       (string->pointer
		(string-append (string-join kernel-names ",") "\x00")
		"UTF-8")
	       (bytevector->pointer err-bv))]
	 [err (bytevector-s32-native-ref err-bv 0)])
    (if (< err 0)
	(find-error err)
	ret)))
(def-cl (clCreateProgramWithIL ctx il-bv) cl_program
  (let* ([err-bv (allocate cl_int 1)]
	 [ret (clCreateProgramWithIL
	       (unwrap 'cl_context ctx)
	       (bytevector->pointer il-bv)
	       (bytevector-length il-bv)
	       (bytevector->pointer err-bv))]
	 [err (bytevector-s32-native-ref err-bv 0)])
    (if (< err 0)
	(find-error err)
	(wrap 'cl_program ret))))
(def-cl (clRetainProgram program) cl_int
  (find-error (api (unwrap 'cl_program program))))
(def-cl (clReleaseProgram program) cl_int
  (find-error (api (unwrap 'cl_program program))))
(def-cl (clBuildProgram program devs
			#:key
			(options "")
			(notify %null-pointer)
			(user-data %null-pointer))
  cl_int
  (let* ([dev-list  (list->bv size_t
			      (map
			       (lambda (d)
				 (pointer-address (unwrap 'cl_device_id d)))
			       devs))]
	 [ret (clBuildProgram (unwrap 'cl_program program)
			      (length devs)
			      (bytevector->pointer dev-list)
			      (string->pointer (string-append options "\x00"))
			      notify
			      user-data)])
    (find-error ret)))
(def-cl (clCompileProgram program devs options headers-assoc) cl_int
  (let* ([dev-list  (list->bv size_t
			      (map (lambda (d)
				     (pointer-address
				      (unwrap 'cl_device_id d)))
				   devs))]
	 [input_headers (map car headers-assoc)]
	 [header_include_names (map cdr headers-assoc)]
	 [ret (api (unwrap 'cl_program program)
		   (length devs)
		   (bytevector->pointer dev-list)
		   (string->pointer
		    (string-append options "\x00"))
		   (length headers-assoc)
		   (if (null? headers-assoc)
		       %null-pointer
		       (bytevector->pointer
			(list->bv size_t input_headers)))
		   (if (null? headers-assoc)
		       %null-pointer
		       (bytevector->pointer
			(list->bv size_t header_include_names)))
		   %null-pointer
		   %null-pointer)])
    (find-error ret)))
(def-cl (clLinkProgram ctx devs options programs) cl_program
  (let* ([dev-list  (list->bv size_t
			      (map (lambda (d)
				     (pointer-address
				      (unwrap 'cl_device_id d)))
				   devs))]
	 [err-bv (allocate cl_int 1)]
	 [ret (api (unwrap 'cl_context ctx)
		   (length dev-list)
		   (bytevector->pointer dev-list)
		   (string->pointer
		    (string-append options "\x00"))
		   (length programs)
		   (bytevector->pointer
		    (list->bv size_t
			      (map (lambda (p)
				     (pointer-address
				      (unwrap 'cl_program p)))
				   programs)))
		   %null-pointer
		   %null-pointer
		   (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(find-error err)
	(wrap 'cl_program ret))))
(def-cl (clSetProgramReleaseCallback program pfn_notify user_data)
  cl_int
  (api (unwrap 'cl_program program) pfn_notify user_data))
(def-cl (clSetProgramSpecializationConstant program spec_id spec_size spec_value)
  cl_int
  (clSetProgramSpecializationConstant program spec_id spec_size spec_value))

(def-cl (clUnloadPlatformCompiler platform) cl_int
  (clUnloadPlatformCompiler (unwrap 'cl_platform_id platform)))

(def-cl (clGetProgramInfo program param-name count)
  ;; fix infos: more general CL_PROGRAM_BINARIES
  cl_int
  (let* ([param-bv (allocate-info-bv 'program-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_program program)
		   param-name
		   (bytevector-length param-bv)
		   (bytevector->pointer param-bv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(find-error ret)
	(read-info 'program-info param-name param-bv
		   (bytes->count 'program-info param-name ret-size)))))
(def-cl (clGetProgramBuildInfo program
			       device
			       param-name
			       count)
  cl_int
  (let* ([param-bv (allocate-info-bv 'build-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_program program)
		   (unwrap 'cl_device_id device)
		   param-name
		   (bytevector-length param-bv)
		   (bytevector->pointer param-bv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (bytevector-u64-native-ref ret-size-bv 0)])
    (if (< ret 0)
	(find-error ret)
	(read-info 'build-info param-name param-bv
		   (bytes->count 'build-info param-name ret-size)))))

(def-cl (clCreateKernel program kernel-name)
  cl_kernel
  (let* ([err-bv (allocate cl_int 1)]
	 [ret (api (unwrap 'cl_program program)
		   (string->pointer kernel-name)
		   (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(find-error err)
	(wrap 'cl_kernel ret))))
(def-cl (clCreateKernelsInProgram program count)
  cl_int
  (let* ([num-ret (allocate cl_uint 1)]
	 [kernels (allocate cl_kernel count)]
	 [ret
	  (api (unwrap 'cl_program program)
	       count
	       (bytevector->pointer kernels)
	       (bytevector->pointer num-ret))])
    (if (< ret 0)
	(find-error ret)
	(map (compose (cute wrap 'cl_kernel <>)
		      make-pointer)
	     (bv->list cl_kernel kernels
		       #:count (refbv cl_uint num-ret 0))))))
(def-cl (clCloneKernel kernel)
  cl_kernel
  (let* ([err-bv (allocate cl_int 1)]
	 [ret (clCloneKernel (unwrap 'cl_kernel kernel)
			     (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0) (find-error err) (wrap 'cl_kernel ret))))
(def-cl (clRetainKernel kernel)
  cl_int
  (find-error (api (unwrap 'cl_kernel kernel))))
(def-cl (clReleaseKernel kernel)
  cl_int
  (find-error (api (unwrap 'cl_kernel kernel))))
(def-cl (clSetKernelArg kernel arg-index arg-value) cl_int
  (let* ([len (cond
	       [(bytevector? arg-value) (bytevector-length arg-value)]
	       [(opq:cl_mem? arg-value) (sizeof cl_mem)]
	       [(and (pair? arg-value)
		     (number? (car arg-value))
		     (number? (cdr arg-value)))
		(sizeof (cdr arg-value))]
	       [else (error "invalid arg-value should be a bv, cl_mem or a pair with number and type:" arg-value)])]
	 [ptr (allocate '* 1)]
	 [_
	  (cond
	   [(bytevector? arg-value) (setbv! '* ptr 0 (pointer-address (bytevector->pointer arg-value)))]
	   [(opq:cl_mem? arg-value) (setbv! '* ptr 0 (pointer-address (opq:unwrap-cl_mem arg-value)))]
	   [(and (pair? arg-value)
		 (number? (car arg-value))
		 (number? (cdr arg-value)))
	    (setbv! (cdr arg-value) ptr 0 (car arg-value))])]
	 [ret (api (unwrap 'cl_kernel kernel)
		   arg-index
		   len
		   (bytevector->pointer ptr))])
    (find-error ret)))
(def-cl (clSetKernelArgSVMPointer kernel arg-index arg-value)
  cl_int
  (find-error (api (unwrap 'cl_kernel kernel) arg-index arg-value)))
(def-cl (clSetKernelExecInfo kernel
			     param-name
			     param-value-size
			     param-value)
  cl_int
  (api (unwrap 'cl_kernel kernel)
       param-name param-value-size param-value))
(def-cl (clGetKernelInfo kernel param-name count)
  cl_int
  (let* ([pbv (allocate-info-bv 'kernel-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_kernel kernel)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(find-error ret)
	(read-info 'kernel-info param-name pbv
		   (bytes->count 'kernel-info param-name ret-size)))))
(def-cl (clGetKernelArgInfo kernel index param-name count)
  cl_int
  (let* ([pbv (allocate-info-bv 'kernel-arg-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_kernel kernel)
		   index
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(resolve-error 'cl-error ret)
	(read-info 'kernel-arg-info param-name pbv
		   (bytes->count 'kernel-arg-info
				 param-name ret-size)))))
(def-cl (clGetKernelWorkGroupInfo kernel device param-name count)
  cl_int
  (let* ([pbv (allocate-info-bv 'kernel-work-group-info
				param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_kernel kernel)
		   (unwrap 'cl_device_id device)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(resolve-error 'cl-error ret)
	(read-info 'kernel-work-group-info param-name pbv
		   (bytes->count 'kernel-work-group-info
				 param-name ret-size)))))
;; (def-cl (clGetKernelSubGroupInfo kernel device param-name input-value)
;;   cl_int
;;   (api (unwrap 'cl_kernel kernel)
;;        (unwrap 'cl_device_id device)
;;        param-name
;;        input_value_size
;;        input_value
;;        param_value_size
;;        param_value
;;        param_value_size_ret))
(def-cl (clWaitForEvents events)
  cl_int
  (find-error (api (length events)
		   (bytevector->pointer
		    (list->bv 'cl_event events)))))
(def-cl (clGetEventInfo event param-name count)
  cl_int
  (let* ([pbv (allocate-info-bv 'event-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_event event)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(resolve-error 'cl-error ret)
	(read-info 'event-info
		   param-name
		   pbv
		   (bytes->count 'event-info param-name ret-size)))))
(def-cl (clCreateUserEvent ctx)
  cl_event
  (let* ([err-bv (allocate cl_int 1)]
	 [ev (api (unwrap 'cl_context ctx)
		  (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(resolve-error 'cl-error err)
	(wrap 'cl_event ev))))
(def-cl (clRetainEvent event) cl_int
  (find-error (api (unwrap 'cl_event event))))
(def-cl (clReleaseEvent event) cl_int
  (find-error (api (unwrap 'cl_event event))))
(def-cl (clSetUserEventStatus event status)
  cl_int
  (find-error (api (unwrap 'cl_event event) status)))
(def-cl (clSetEventCallback event type pfn-notify user-data)
  cl_int
  (find-error
   (api (unwrap 'cl_event event)
	type
	pfn-notify
	user-data)))
(def-cl (clGetEventProfilingInfo event param-name count)
  ;; event param_name param_value_size param_value param_value_size_ret
  cl_int
  (let* ([pbv (allocate-info-bv 'event-profiling-info param-name count)]
	 [ret-size-bv (allocate size_t 1)]
	 [ret (api (unwrap 'cl_event event)
		   param-name
		   (bytevector-length pbv)
		   (bytevector->pointer pbv)
		   (bytevector->pointer ret-size-bv))]
	 [ret-size (refbv size_t ret-size-bv 0)])
    (if (< ret 0)
	(resolve-error 'cl-error ret)
	(read-info 'event-profiling-info
		   param-name
		   pbv
		   (bytes->count 'event-profiling-info param-name ret-size)))))

(def-cl (clFlush q) cl_int
  (find-error (api (unwrap 'cl_command_queue q))))
(def-cl (clFinish q) cl_int
  (find-error (api (unwrap 'cl_command_queue q))))

(def-cl (clEnqueueReadBuffer q buffer bv
			     #:key
			     (events '())
			     (block? #t)
			     (offset 0)
			     (size (bytevector-length bv))
			     (ret-event %null-pointer))
  cl_int
  (let* ([block? (if block? cln:CL_FALSE cln:CL_TRUE)]
	 [size (if size size (bytevector-length bv))]
	 [events-bv (list->bv
		     '*
		     (map (lambda (e)
			    (pointer-address (unwrap 'cl_event e)))
			  events))])
    (find-error
     (api (unwrap 'cl_command_queue q)
	  (unwrap 'cl_mem buffer)
	  block?
	  offset
	  size
	  (bytevector->pointer bv)
	  (length events)
	  (if (null? events)
	      %null-pointer
	      (bytevector->pointer events-bv))
	  ret-event))))
(def-cl (clEnqueueReadBufferRect q
				 buffer
				 buffer-origin
				 host-origin
				 region
				 buffer-row-pitch
				 buffer-slice-pitch
				 host-row-pitch
				 host-slice-pitch
				 bv
				 #:key
				 (events '())
				 (block? #t)
				 (ret-event %null-pointer))
  cl_int
  (let* ([events-bv (list->bv '* events)]
	 [block? (if block? cln:CL_TRUE cln:CL_FALSE)]
	 [buffer-origin-bv      (list->bv 'size_t buffer-origin)]
	 [host-origin-bv        (list->bv 'size_t host-origin)]
	 [region-bv             (list->bv 'size_t region)]
	 [host-slice-pitch-bv   (list->bv 'size_t host-slice-pitch)]
	 [host-row-pitch-bv     (list->bv 'size_t host-row-pitch)]
	 [buffer-slice-pitch-bv (list->bv 'size_t buffer-slice-pitch)]
	 [buffer-row-pitch-bv   (list->bv 'size_t buffer-row-pitch)])
    (find-error
     (api
      (unwrap 'cl_command_queue q)
      (unwrap 'cl_mem buffer)
      block?
      (bytevector->pointer buffer-origin-bv)
      (bytevector->pointer host-origin-bv)
      (bytevector->pointer region-bv)
      (bytevector->pointer buffer-row-pitch-bv)
      (bytevector->pointer buffer-slice-pitch-bv)
      (bytevector->pointer host-row-pitch-bv)
      (bytevector->pointer host-slice-pitch-bv)
      (bytevector->pointer bv)
      (length events)
      (if (null? events)
	  %null-pointer
	  (list->bv
	   '*
	   (map (lambda (e)
		  (pointer-address (unwrap 'cl_event e)))
		events)))
      ret-event))))

(def-cl (clEnqueueWriteBuffer q buffer bv
			      #:key
			      (offset 0)
			      (size (bytevector-length bv))
			      (events '())
			      (block? #t)
			      (ret-event %null-pointer))
  cl_int
  (let ([events-bv (list->bv '* events)]
	[block? (if block? cln:CL_TRUE cln:CL_FALSE)])
    (find-error
     (api (unwrap 'cl_command_queue q)
	  (unwrap 'cl_mem buffer)
	  block?
	  offset
	  size
	  (bytevector->pointer bv)
	  (length events)
	  (if (null? events)
	      ffi:%null-pointer
	      (bytevector->pointer events-bv))
	  ret-event))))

(def-cl (clEnqueueWriteBufferRect q
				  buffer
				  buffer-origin
				  host-origin
				  region
				  buffer-row-pitch
				  buffer-slice-pitch
				  host-row-pitch
				  host-slice-pitch
				  ptr
				  #:key
				  (block #t)
				  (events '())
				  (ret-event %null-pointer))
  cl_int
  (let* ([events-bv (list->bv '* events)]
	 [buffer-origin      (list->bv 'size_t buffer-origin)]
	 [host-origin        (list->bv 'size_t host-origin)]
	 [region             (list->bv 'size_t region)]
	 [buffer-row-pitch   (list->bv 'size_t buffer-row-pitch)]
	 [buffer-slice-pitch (list->bv 'size_t buffer-slice-pitch)]
	 [host-row-pitch     (list->bv 'size_t host-row-pitch)]
	 [host-slice-pitch   (list->bv 'size_t host-slice-pitch)])
    (find-error
     (api (unwrap 'cl_command_queue q)
	  (unwrap 'cl_mem buffer)
	  (if block cln:CL_TRUE cln:CL_FALSE)
	  (bytevector->pointer buffer-origin)
	  (bytevector->pointer host-origin)
	  (bytevector->pointer region)
	  (bytevector->pointer buffer-row-pitch)
	  (bytevector->pointer buffer-slice-pitch)
	  (bytevector->pointer host-row-pitch)
	  (bytevector->pointer host-slice-pitch)
	  ptr
	  (length events)
	  (if (null? events)
	      %null-pointer
	      (list->bv
	       '*
	       (map (lambda (e)
		      (pointer-address (unwrap 'cl_event e)))
		    events)))
	  ret-event))))

(def-cl (clEnqueueFillBuffer q buff
			     pattern
			     size
			     #:key
			     (offset 0)
			     (events '())
			     (ret-event %null-pointer))
  cl_int
  (let ([events-bv (list->bv cl_event events)])
    (find-error
     (api (unwrap 'cl_command_queue q)
	  (unwrap 'cl_mem buff)
	  (bytevector->pointer pattern)
	  (bytevector-length pattern)
	  offset
	  size
	  (length events)
	  (if (null? events)
	      %null-pointer
	      (bytevector->pointer events-bv))
	  ret-event))))

(def-cl (clEnqueueCopyBuffer q src-buff dst-buff size
			     #:key
			     (src-offset 0)
			     (dst-offset 0)
			     (events '())
			     (ret-event %null-pointer))
  cl_int
  (find-error
   (api (unwrap 'cl_command_queue q)
	(unwrap 'cl_mem src-buff)
	(unwrap 'cl_mem dst-buff)
	src-offset
	dst-offset
	size
	(length events)
	(if (null? events)
	    %null-pointer
	    (bytevector->pointer (list->bv cl_event events)))
	ret-event)))
(def-cl (clEnqueueCopyBufferRect q src-buffer dst-buffer
				 src-origin
				 dst-origin
				 region
				 src-row-pitch
				 src-slice-pitch
				 dst-row-pitch
				 dst-slice-pitch
				 #:key
				 (events '())
				 (ret-event %null-pointer))
  cl-int
  (let* ([events-bv (list->bv '* events)]
	 [src-origin-bv      (list->bv 'size-t src-origin)]
	 [dst-origin-bv      (list->bv 'size-t dst-origin)]
	 [region-bv          (list->bv 'size-t region)]
	 [src-row-pitch-bv   (list->bv 'size-t src-row-pitch)]
	 [src-slice-pitch-bv (list->bv 'size-t src-slice-pitch)]
	 [dst-row-pitch-bv   (list->bv 'size-t dst-row-pitch)]
	 [dst-slice-pitch-bv (list->bv 'size-t dst-slice-pitch)])
    (find-error
     (api
      (unwrap 'cl-command-queue q)
      (unwrap 'cl-mem src-buffer)
      (unwrap 'cl-mem dst-buffer)
      (bytevector->pointer src-origin)
      (bytevector->pointer dst-origin)
      (bytevector->pointer region)
      (bytevector->pointer src-row-pitch)
      (bytevector->pointer src-slice-pitch)
      (bytevector->pointer dst-row-pitch)
      (bytevector->pointer dst-slice-pitch)
      (length events)
      (if (null? events)
	  %null-pointer
	  (list->bv
	   '*
	   (map (lambda (e)
		  (pointer-address (unwrap 'cl_event e)))
		events)))
      ret-event))))
;; clEnqueueReadImage
;; clEnqueueWriteImage
;; clEnqueueFillImage
;; clEnqueueCopyImage
;; clEnqueueCopyImageToBuffer
;; clEnqueueCopyBufferToImage
(def-cl (clEnqueueMapBuffer q buffer flags size
			    #:key
			    (block? #t)
			    (offset 0)
			    (events '())
			    (ret-event %null-pointer))
  '*
  (let* ([err-bv (allocate '* 1)]
	 [ret (api (unwrap 'cl_command_queue q)
		   (unwrap 'cl_mem buffer)
		   (if block? cln:CL_TRUE cln:CL_FALSE)
		   flags
		   offset
		   size
		   (length events)
		   (if (null? events)
		       %null-pointer
		       (list->bv
			'*
			(map (lambda (e)
			       (pointer-address (unwrap 'cl_event e)))
			     events)))
		   (if (opq:cl_event? ret-event)
		       (unwrap 'cl_event ret-event)
		       %null-pointer)
		   (bytevector->pointer err-bv))]
	 [err (refbv '* err-bv 0)])
    (if (< err 0)
	(find-error err)
	ret)))
(def-cl (clEnqueueMapImage q image flags origin region
			   image-row-pitch
			   image-slice-pitch
			   #:key
			   (events '())
			   (ret-event %null-pointer)
			   (block #t))
  '*
  (let* ([err-bv (allocate '* 1)]
	 [origin-bv (list->bv size_t origin)]
	 [region-bv (list->bv size_t region)]
	 [image-row-pitch-bv (list->bv size_t image-row-pitch)]
	 [image-slice-pitch-bv (list->bv size_t image-slice-pitch)]
	 [ret (api ((unwrap 'cl_command_queue q)
		    (unwrap 'cl_mem image)
		    (if block cln:CL_TRUE cln:CL_FALSE)
		    flags
		    (bytevector->pointer origin-bv)
		    (bytevector->pointer region-bv)
		    (bytevector->pointer image-row-pitch-bv)
		    (bytevector->pointer image-slice-pitch-bv)
		    (length events)
		    (if (null? events)
			%null-pointer
			(list->bv
			 '*
			 (map (lambda (e)
				(pointer-address (unwrap 'cl_event e)))
			      events)))
		    (if (opq:cl_event? ret-event)
			(unwrap 'cl_event ret-event)
			%null-pointer)
		    (bytevector->pointer err-bv)))]
	 [err (refbv '* err-bv 0)])
    (if (< err 0)
	(find-error err)
	ret)))
(def-cl (clEnqueueUnmapMemObject q memobj mapped_ptr
				 #:key
				 (event-wait-list '())
				 (event %null-pointer))
  cl_int
  (find-error
   (api (unwrap 'cl_command_queue q)
	(unwrap 'cl_mem memobj)
	mapped_ptr
	(length event-wait-list)
	(if (null? event-wait-list)
	    %null-pointer
	    (list->bv
	     '*
	     (map (lambda (e)
		    (pointer-address (unwrap 'cl_event e)))
		  event-wait-list)))
	event)))
(def-cl (clEnqueueMigrateMemObjects q mems flags
				    #:key
				    (events '())
				    (ret-event %null-pointer))
  cl_int
  (find-error
   (api q
	(length mems)
	(list->bv cl_mem mems)
	flags
	(length events)
	(if (null? events)
	    %null-pointer
	    (list->bv
	     '*
	     (map (lambda (e)
		    (pointer-address (unwrap 'cl_event e)))
		  events)))
	(if (opq:cl_event? ret-event)
	    (unwrap 'cl_event ret-event)
	    %null-pointer))))
(def-cl (clEnqueueNDRangeKernel q kernel global_work_size
				#:key
				(work_dim (length global_work_size))
				(local-work-size %null-pointer)
				(global_work_offset %null-pointer)
				(events '())
				(ret-event %null-pointer))
  cl_int
  (find-error
   (api
    (unwrap 'cl_command_queue q)
    (unwrap 'cl_kernel kernel)
    work_dim
    (if (ffi:null-pointer? global_work_offset)
	%null-pointer
	(bytevector->pointer (list->bv
			      size_t
			      global_work_offset)))
    (bytevector->pointer (list->bv size_t global_work_size))
    (if (and (ffi:pointer? local-work-size)
	     (ffi:null-pointer? local-work-size))
	%null-pointer
	(bytevector->pointer (list->bv
			      size_t
			      local-work-size)))
    (length events)
    (if (null? events)
	%null-pointer
	(list->bv
	 '*
	 (map (lambda (e)
		(pointer-address (unwrap 'cl_event e)))
	      events)))
    ret-event)))
;; clEnqueueNativeKernel
(def-cl (clEnqueueMarkerWithWaitList q
				     #:key
				     (events '())
				     (ret-event %null-pointer))
  cl_int
  (find-error
   (api
    (unwrap 'cl_command_queue q)
    (length events)
    (if (null? events)
	%null-pointer
	(list->bv
	 '*
	 (map (lambda (e)
		(pointer-address (unwrap 'cl_event e)))
	      events)))
    (if (opq:cl_event? ret-event)
	(unwrap 'cl_event ret-event)
	%null-pointer))))
(def-cl (clEnqueueBarrierWithWaitList q #:key
				      (events '())
				      (ret-event %null-pointer))
  cl_int
  (find-error
   (api (unwrap 'cl_command_queue q)
	(length events)
	(if (null? events)
	    %null-pointer
	    (list->bv
	     '*
	     (map (lambda (e)
		    (pointer-address (unwrap 'cl_event e)))
		  events)))
	(if (opq:cl_event? ret-event)
	    (unwrap 'cl_event ret-event)
	    %null-pointer))))
(def-cl (clEnqueueSVMFree q ptr-list
			  #:key
			  (notify  %null-pointer)
			  (user-data  %null-pointer)
			  (events '())
			  (ret-event %null-pointer))
  cl_int
  (api (unwrap 'cl_command_queue q)
       (length ptr-list)
       (list->bv '* (map pointer-address ptr-list))
       notify
       user-data
       (length events)
       (if (null? events)
	   %null-pointer
	   (list->bv
	    '*
	    (map (lambda (e)
		   (pointer-address (unwrap 'cl_event e)))
		 events)))
       (if (opq:cl_event? ret-event)
	   (unwrap 'cl_event ret-event)
	   %null-pointer)))
(def-cl (clEnqueueSVMMemcpy q dst-ptr src-ptr size
			    #:key
			    (block? #t)
			    (events '())
			    (ret-event %null-pointer))
  cl_int
  (find-error
   (api
    (unwrap 'cl_command_queue q)
    (if block? cln:CL_TRUE cln:CL_FALSE)
    dst-ptr
    src-ptr
    size
    (length events)
    (if (null? events)
	%null-pointer
	(list->bv
	 '*
	 (map (lambda (e)
		(pointer-address (unwrap 'cl_event e)))
	      events)))
    (if (opq:cl_event? ret-event)
	(unwrap 'cl_event ret-event)
	%null-pointer))))
(def-cl (clEnqueueSVMMemFill q ptr pattern size
			     #:key
			     (events '())
			     (ret-event %null-pointer))
  cl_int
  (find-error
   (api (unwrap 'cl_command_queue q)
	ptr
	(bytevector->pointer pattern)
	(bytevector-length pattern)
	size
	(length events)
	(if (null? events)
	    %null-pointer
	    (list->bv
	     '*
	     (map (lambda (e)
		    (pointer-address (unwrap 'cl_event e)))
		  events)))
	(if (opq:cl_event? ret-event)
	    (unwrap 'cl_event ret-event)
	    %null-pointer))))
(def-cl (clEnqueueSVMMap q flags ptr size
			 #:key
			 (block? #t)
			 (events '())
			 (ret-event %null-pointer))
  cl_int
  (find-error
   (api (unwrap 'cl_command_queue q)
	(if block? cln:CL_TRUE cln:CL_FALSE)
	flags
	ptr
	size
	(length events)
	(if (null? events)
	    %null-pointer
	    (list->bv
	     '*
	     (map (lambda (e)
		    (pointer-address (unwrap 'cl_event e)))
		  events)))
	(if (opq:cl_event? ret-event)
	    (unwrap 'cl_event ret-event)
	    %null-pointer))))
(def-cl (clEnqueueSVMUnmap q ptr
			   #:key
			   (events '())
			   (ret-event %null-pointer))
  cl_int
  (find-error
   (api (unwrap 'cl_command_queue q)
	ptr
	(length events)
	(if (null? events)
	    %null-pointer
	    (list->bv
	     '*
	     (map (lambda (e)
		    (pointer-address (unwrap 'cl_event e)))
		  events)))
	(if (opq:cl_event? ret-event)
	    (unwrap 'cl_event ret-event)
	    %null-pointer))))
(def-cl (clEnqueueSVMMigrateMem q ptrs sizes flags
				#:key
				(events '())
				(ret-event %null-pointer))
  cl_int
  (find-error (api (unwrap 'cl_command_queue q)
		   (length ptrs)
		   (bytevector->pointer (list->bv '* (map pointer-address ptrs)))
		   (bytevector->pointer (list->bv size_t sizes))
		   flags
		   (length events)
		   (if (null? events)
		       %null-pointer
		       (list->bv
			'*
			(map (lambda (e)
			       (pointer-address (unwrap 'cl_event e)))
			     events)))
		   (if (opq:cl_event? ret-event)
		       (unwrap 'cl_event ret-event)
		       %null-pointer))))
(def-cl (clGetExtensionFunctionAddressForPlatform platform name-str)
  '*
  (api (unwrap 'cl_platform_id platform)
       (string->pointer name-str)))
;; (def-cl (clSetCommandQueueProperty q prop-bv )
;;   cl_int
;;   (command_queue cl_command_queue no-ptr no-const)
;;   (properties cl_command_queue_properties no-ptr no-const)
;;   (enable cl_bool no-ptr no-const)
;;   (old_properties cl_command_queue_properties ptr no-const))
;; clCreateImage2D
;; clCreateImage3D
(def-cl (clEnqueueMarker q event)
  cl_int
  (find-error (api (unwrap 'cl_command_queue q)
		   event)))
(def-cl (clEnqueueWaitForEvents q events)
  cl_int
  (find-error
   (api (unwrap 'cl_command_queue q)
	(length events)
	(if (null? events)
	    %null-pointer
	    (list->bv
	     '*
	     (map (lambda (e)
		    (pointer-address (unwrap 'cl_event e)))
		  events))))))
(def-cl (clEnqueueBarrier q
			  #:key
			  (events '())
			  (ret-event %null-pointer))
  cl_int
  (find-error
   (api (unwrap 'cl_command_queue q)
	(length events)
	(if (null? events)
	    %null-pointer
	    (list->bv
	     '*
	     (map (lambda (e)
		    (pointer-address (unwrap 'cl_event e)))
		  events)))
	(if (opq:cl_event? ret-event)
	    (unwrap 'cl_event ret-event)
	    %null-pointer))))
(def-cl (clUnloadCompiler)
  cl_int
  (find-error (api)))
(def-cl (clGetExtensionFunctionAddress name) '* (api (string->pointer name)))
(def-cl (clCreateCommandQueue ctx dev #:key (props %null-pointer))
  cl_command_queue
  (let* ([err-bv (allocate cl_int 1)]
	 [q (api (unwrap 'cl_context ctx)
		 (unwrap 'cl_device_id dev)
		 (if (bytevector? props)
		     (bytevector->pointer props)
		     %null-pointer)
		 (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(find-error err)
	(wrap 'cl_command_queue q)))
  props)

(def-cl (clCreateSampler ctx
			 normalized-cords
			 addressing-mode
			 filter-mode)
  cl_sampler
  (let* ([err-bv (allocate cl_int 1)]
	 [samp (api (unwrap 'cl_context ctx)
		    (if normalized-cords cln:CL_TRUE cln:CL_FALSE)
		    addressing-mode
		    filter-mode
		    (bytevector->pointer err-bv))]
	 [err (refbv cl_int err-bv 0)])
    (if (< err 0)
	(find-error err)
	(wrap 'cl_sampler samp))))
(def-cl (clEnqueueTask q kernel
		       #:key
		       (events '())
		       (ret-event %null-pointer))
  cl_int
  (find-error (api (unwrap 'cl_command_queue q)
		   (unwrap 'cl_kernel kernel)
		   (length events)
		   (if (null? events)
		       %null-pointer
		       (list->bv
			'*
			(map (lambda (e)
			       (pointer-address (unwrap 'cl_event e)))
			     events)))
		   (if (opq:cl_event? ret-event)
		       (unwrap 'cl_event ret-event)
		       %null-pointer))))
;; clGetLayerInfo
;; clInitLayer
;; clInitLayerWithProperties
;; clDeinitLayer
;; clGetICDLoaderInfoOCLICD
;; clCancelCommandsIMG
1

;; (def-cl (clEnqueueNativeKernel q
;;			       num-mem-objects
;;			       mem-list
;;			       args-mem-loc
;;			       #:key
;;			       (user-func %null-pointer)
;;			       (args %null-pointer)
;;			       (events '())
;;			       (ret-event %null-pointer))
;;   cl_int
;;   (api q
;;        user-func
;;        args
;;        (bytevector-length args)
;;        num-mem-objects
;;        mem-list
;;        args-mem-loc
;;        (length events)
;;        (bytevector->pointer events (list->bv cl_event ))
;;        ret-event))

;; (let* ([plats (get-platform-ids 10)]
;;        [d (car (get-device-ids (car plats)))]
;;        [ctx (create-context (list d))]
;;        [il-bv (call-with-input-file
;;		  "/home/quasikote/proj/scheme-gpgpu/playground/kernel.spv"
;;		(@ (ice-9 binary-ports) get-bytevector-all))]
;;        [prog (create-program-with-il ctx il-bv)]
;;        [kernel (begin (build-program prog (list d))
;;		      (create-kernel prog "axpy"))]

;;        [ar (har:make-f64vector 1042 0)]
;;        [abuff (create-buffer
;;	       ctx
;;	       (logior cln:CL_MEM_READ_WRITE cln:CL_MEM_USE_HOST_PTR)
;;	       (bytevector->pointer ar)
;;	       (bytevector-length ar))]
;;        [ptr ])
;;   (clSetKernelArg (unwrap 'cl_kernel kernel)
;;		  1
;;		  (sizeof '*)
;;		  (unwrap 'cl_mem abuff)))

;; 1111111
;; (use-modules (cl array))
;; (define count 1024)
;; (define plat
;;   (list-ref (get-platform-ids 10) 0))
;; (define d (car (get-device-ids plat)))
;; (define ctx (create-context (list d)))

;; (define il-bv (call-with-input-file
;;		  "/home/quasikote/proj/scheme-gpgpu/playground/kernel.spv"
;;		(@ (ice-9 binary-ports) get-bytevector-all)))
;; (define prog (create-program-with-il ctx il-bv))
;; (define kernel (begin (build-program
;;		       prog (list d)
;;		       #:options "-cl-fast-relaxed-math")
;;		      (create-kernel prog "axpy")))

;; (define abuff
;;   (create-buffer
;;    ctx
;;    (logior cln:CL_MEM_READ_WRITE cln:CL_MEM_ALLOC_HOST_PTR)
;;    %null-pointer
;;    (* count (sizeof float))))
;; (define bbuff
;;   (create-buffer
;;    ctx
;;    (logior cln:CL_MEM_READ_WRITE cln:CL_MEM_ALLOC_HOST_PTR)
;;    %null-pointer
;;    (* count (sizeof float))))

;; (set-kernel-arg kernel 0 `(10 . ,cl_float))
;; (set-kernel-arg kernel 1 abuff)
;; (set-kernel-arg kernel 2 bbuff)

;; (define q (create-command-queue-with-properties
;;	   ctx d
;;	   #:properties
;;	   (make-prop-bv cl_command_queue_properties
;;			 cln:CL_QUEUE_PROPERTIES
;;			 cln:CL_QUEUE_PROFILING_ENABLE)))

;; (define aptr (enqueue-map-buffer
;;	      q abuff
;;	      (logior cln:CL_MAP_READ cln:CL_MAP_WRITE)
;;	      (* count (sizeof float))))

;; (define bptr (enqueue-map-buffer
;;	      q bbuff
;;	      (logior cln:CL_MAP_READ cln:CL_MAP_WRITE)
;;	      (* count (sizeof float))))
;; (define abv (ffi:pointer->bytevector aptr (* count (sizeof float))))
;; (define bbv (ffi:pointer->bytevector bptr (* count (sizeof float))))
;; (bv->f32vector! abv)
;; (bv->f32vector! bbv)
;; (array-map! abv
;;	    (lambda ()
;;	      (random 10)))
;; (array-map! bbv
;;	    (lambda ()
;;	      (random 10)))
;; (enqueue-unmap-mem-object q abuff aptr)
;; (enqueue-unmap-mem-object q bbuff bptr)
;; (define event (opq:opaque-instance 'cl_event 0))
;; (display "----------------------------------------\n")
;; (enqueue-nd-range-kernel q kernel `(,count)
;;			 #:local-work-size `(32)
;;			 #:ret-event (opq:& event))
;; (finish q)
;; (format (current-output-port)
;;	"~a ~a ~a\n"
;;	(string-take (get-device-info d cln:CL_DEVICE_NAME 128)
;;		     18)
;;	count
;;	(-
;;	 (get-event-profiling-info
;;	  event
;;	  cln:CL_PROFILING_COMMAND_END 8)
;;	 (get-event-profiling-info
;;	  event
;;	  cln:CL_PROFILING_COMMAND_START 8)))
;; (display "----------------------------------------\n")
;; (release-mem-object abuff)
;; (release-mem-object bbuff)
;; (release-command-queue q)
;; (release-program prog)
;; (release-context ctx)
;; (define (test)
;;   (enqueue-nd-range-kernel
;;    q kernel `(,count)
;;    #:ret-event (opq:& event))
;;   (finish q)
;;   (format (current-output-port)
;;	  "~a ~a ~a\n"
;;	  (string-take (get-device-info d cln:CL_DEVICE_NAME 128)
;;		       18)
;;	  count
;;	  (-
;;	   (get-event-profiling-info
;;	    event
;;	    cln:CL_PROFILING_COMMAND_END 8)
;;	   (get-event-profiling-info
;;	    event
;;	    cln:CL_PROFILING_COMMAND_START 8))))
