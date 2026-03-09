(define-module (cl ffi)
  #:use-module (ice-9 match)
  #:use-module ((system foreign) #:prefix ffi:)
  #:use-module (cl)
  #:use-module (cl types)
  #:use-module (cl consts)
  #:use-module (system foreign-library)
  #:use-module (rnrs bytevectors))

(define UINT ffi:unsigned-int)
(define cl_dx9_media_adapter_set_khr cl_uint)
(define cl_dx9_device_set_intel cl_uint)
(define cl_dx9_device_source_intel cl_uint)
(define cl_dx9_media_adapter_type_khr cl_uint)
(define-syntax-rule (def-cl (func-name arg* ...) body)
  (begin
    (eval-when (load)
      (define tmp
	(with-exception-handler
	    (lambda (e)
	      (format (current-error-port)
		      "looking up ~a failed\n" 'func-name)
	      (lambda (a)
		(format (current-error-port)
			"looking up ~a failed\n" 'func-name)
		#f))
	  (lambda () body)
	  #:unwind? #t)))
    (define-public (func-name arg* ...) (tmp arg* ...))))

(def-cl (clGetDeviceIDsFromD3D10KHR platform
				    d3d_device_source
				    d3d_object*
				    d3d_device_set
				    num_entries
				    devices*
				    num_devices*)
  (foreign-library-function (cl-link)
			    "clGetDeviceIDsFromD3D10KHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_platform_id cl_d3d10_device_source_khr '* cl_d3d10_device_set_khr cl_uint '* '*)))

(def-cl (clCreateFromD3D10BufferKHR context flags resource* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromD3D10BufferKHR"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags '* '*)))

(def-cl (clCreateFromD3D10Texture2DKHR context flags resource* subresource errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromD3D10Texture2DKHR"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags '* UINT '*)))

(def-cl (clCreateFromD3D10Texture3DKHR context flags resource* subresource errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromD3D10Texture3DKHR"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags '* UINT '*)))

(def-cl (clEnqueueAcquireD3D10ObjectsKHR command_queue
					 num_objects
					 mem_objects*
					 num_events_in_wait_list
					 event_wait_list*
					 event*)
  (foreign-library-function (cl-link)
			    "clEnqueueAcquireD3D10ObjectsKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clEnqueueReleaseD3D10ObjectsKHR command_queue
					 num_objects
					 mem_objects*
					 num_events_in_wait_list
					 event_wait_list*
					 event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReleaseD3D10ObjectsKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clGetDeviceIDsFromD3D11KHR platform
				    d3d_device_source
				    d3d_object*
				    d3d_device_set
				    num_entries
				    devices*
				    num_devices*)
  (foreign-library-function (cl-link)
			    "clGetDeviceIDsFromD3D11KHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_platform_id cl_d3d11_device_source_khr '* cl_d3d11_device_set_khr cl_uint '* '*)))

(def-cl (clCreateFromD3D11BufferKHR context
				    flags
				    resource*
				    errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromD3D11BufferKHR"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags '* '*)))

(def-cl (clCreateFromD3D11Texture2DKHR context
				       flags
				       resource*
				       subresource
				       errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromD3D11Texture2DKHR"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags '* UINT '*)))

(def-cl (clCreateFromD3D11Texture3DKHR context
				       flags
				       resource*
				       subresource
				       errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromD3D11Texture3DKHR"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags '* UINT '*)))

(def-cl (clEnqueueAcquireD3D11ObjectsKHR command_queue
					 num_objects
					 mem_objects*
					 num_events_in_wait_list
					 event_wait_list*
					 event*)
  (foreign-library-function (cl-link)
			    "clEnqueueAcquireD3D11ObjectsKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clEnqueueReleaseD3D11ObjectsKHR command_queue
					 num_objects
					 mem_objects*
					 num_events_in_wait_list
					 event_wait_list*
					 event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReleaseD3D11ObjectsKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clGetDeviceIDsFromDX9MediaAdapterKHR platform
					      num_media_adapters
					      media_adapter_type*
					      media_adapters*
					      media_adapter_set
					      num_entries
					      devices*
					      num_devices*)
  (foreign-library-function (cl-link)
			    "clGetDeviceIDsFromDX9MediaAdapterKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_platform_id cl_uint '* '* cl_dx9_media_adapter_set_khr cl_uint '* '*)))

(def-cl (clCreateFromDX9MediaSurfaceKHR context
					flags
					adapter_type
					surface_info*
					plane
					errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromDX9MediaSurfaceKHR"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags cl_dx9_media_adapter_type_khr '* cl_uint '*)))

(def-cl (clEnqueueAcquireDX9MediaSurfacesKHR command_queue
					     num_objects
					     mem_objects*
					     num_events_in_wait_list
					     event_wait_list*
					     event*)
  (foreign-library-function (cl-link)
			    "clEnqueueAcquireDX9MediaSurfacesKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clEnqueueReleaseDX9MediaSurfacesKHR command_queue
					     num_objects
					     mem_objects*
					     num_events_in_wait_list
					     event_wait_list*
					     event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReleaseDX9MediaSurfacesKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clGetDeviceIDsFromDX9INTEL platform
				    dx9_device_source
				    dx9_object*
				    dx9_device_set
				    num_entries
				    devices*
				    num_devices*)
  (foreign-library-function (cl-link)
			    "clGetDeviceIDsFromDX9INTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_platform_id cl_dx9_device_source_intel '* cl_dx9_device_set_intel cl_uint '* '*)))

;; (def-cl (clCreateFromDX9MediaSurfaceINTEL context
;;						 flags
;;						 resource*
;;						 sharedHandle
;;						 plane
;;						 errcode_ret*)
;;   (foreign-library-function (load-foreign-library)
;;			    "clCreateFromDX9MediaSurfaceINTEL"
;;			    #:return-type cl_mem
;;			    #:arg-types (cl_context cl_mem_flags '* HANDLE UINT '*)))
(def-cl (clEnqueueAcquireDX9ObjectsINTEL command_queue
					 num_objects
					 mem_objects*
					 num_events_in_wait_list
					 event_wait_list*
					 event*)
  (foreign-library-function (cl-link)
			    "clEnqueueAcquireDX9ObjectsINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clEnqueueReleaseDX9ObjectsINTEL command_queue
					 num_objects
					 mem_objects*
					 num_events_in_wait_list
					 event_wait_list*
					 event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReleaseDX9ObjectsINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clCreateEventFromEGLSyncKHR context
				     sync
				     display
				     errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateEventFromEGLSyncKHR"
			    #:return-type cl_event
			    #:arg-types (list
					 cl_context CLeglSyncKHR CLeglDisplayKHR '*)))

(def-cl (clCreateFromEGLImageKHR context
				 egldisplay
				 eglimage
				 flags
				 properties*
				 errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromEGLImageKHR"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context CLeglDisplayKHR CLeglImageKHR cl_mem_flags '* '*)))

(def-cl (clEnqueueAcquireEGLObjectsKHR command_queue
				       num_objects
				       mem_objects*
				       num_events_in_wait_list
				       event_wait_list*
				       event*)
  (foreign-library-function (cl-link)
			    "clEnqueueAcquireEGLObjectsKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clEnqueueReleaseEGLObjectsKHR command_queue
				       num_objects
				       mem_objects*
				       num_events_in_wait_list
				       event_wait_list*
				       event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReleaseEGLObjectsKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clLogMessagesToSystemLogAPPLE errstr*
				       private_info*
				       cb
				       user_data*)
  (foreign-library-function (cl-link)
			    "clLogMessagesToSystemLogAPPLE"
			    #:return-type void
			    #:arg-types (list
					 '* '* size_t '*)))

(def-cl (clLogMessagesToStdoutAPPLE errstr*
				    private_info*
				    cb
				    user_data*)
  (foreign-library-function (cl-link)
			    "clLogMessagesToStdoutAPPLE"
			    #:return-type void
			    #:arg-types (list
					 '* '* size_t '*)))

(def-cl (clLogMessagesToStderrAPPLE errstr*
				    private_info*
				    cb
				    user_data*)
  (foreign-library-function (cl-link)
			    "clLogMessagesToStderrAPPLE"
			    #:return-type void
			    #:arg-types (list
					 '* '* size_t '*)))

(def-cl (clIcdGetPlatformIDsKHR num_entries
				platforms*
				num_platforms*)
  (foreign-library-function (cl-link)
			    "clIcdGetPlatformIDsKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_uint '* '*)))

(def-cl (clIcdGetFunctionAddressForPlatformKHR platform func_name*)
  (foreign-library-function (cl-link)
			    "clIcdGetFunctionAddressForPlatformKHR"
			    #:return-type void
			    #:arg-types (list
					 cl_platform_id '*)))

(def-cl (clIcdSetPlatformDispatchDataKHR platform
					 dispatch_data*)
  (foreign-library-function (cl-link)
			    "clIcdSetPlatformDispatchDataKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_platform_id '*)))

(def-cl (clCreateProgramWithILKHR context
				  il*
				  length
				  errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateProgramWithILKHR"
			    #:return-type cl_program
			    #:arg-types (list
					 cl_context '* size_t '*)))

(def-cl (clTerminateContextKHR context)
  (foreign-library-function (cl-link)
			    "clTerminateContextKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context)))

(def-cl (clCreateCommandQueueWithPropertiesKHR context
					       device
					       properties*
					       errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateCommandQueueWithPropertiesKHR"
			    #:return-type cl_command_queue
			    #:arg-types (list
					 cl_context cl_device_id '* '*)))

(def-cl (clReleaseDeviceEXT device)
  (foreign-library-function (cl-link)
			    "clReleaseDeviceEXT"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_device_id)))

(def-cl (clRetainDeviceEXT device)
  (foreign-library-function (cl-link)
			    "clRetainDeviceEXT"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_device_id)))

(def-cl (clCreateSubDevicesEXT in_device
			       properties*
			       num_entries
			       out_devices*
			       num_devices*)
  (foreign-library-function (cl-link)
			    "clCreateSubDevicesEXT"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_device_id '* cl_uint '* '*)))

(def-cl (clEnqueueMigrateMemObjectEXT command_queue
				      num_mem_objects
				      mem_objects*
				      flags
				      num_events_in_wait_list
				      event_wait_list*
				      event*)
  (foreign-library-function (cl-link)
			    "clEnqueueMigrateMemObjectEXT"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_mem_migration_flags_ext cl_uint '* '*)))

(def-cl (clGetDeviceImageInfoQCOM device
				  image_width
				  image_height
				  image_format*
				  param_name
				  param_value_size
				  param_value*
				  param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetDeviceImageInfoQCOM"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_device_id size_t size_t '* cl_image_pitch_info_qcom size_t '* '*)))

(def-cl (clEnqueueAcquireGrallocObjectsIMG command_queue
					   num_objects
					   mem_objects*
					   num_events_in_wait_list
					   event_wait_list*
					   event*)
  (foreign-library-function (cl-link)
			    "clEnqueueAcquireGrallocObjectsIMG"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clEnqueueGenerateMipmapIMG command_queue
				    src_image
				    dst_image
				    mipmap_filter_mode
				    array_region*
				    mip_region*
				    num_events_in_wait_list
				    event_wait_list*
				    event*)
  (foreign-library-function (cl-link)
			    "clEnqueueGenerateMipmapIMG"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_mem cl_mipmap_filter_mode_img '* '* cl_uint '* '*)))

(def-cl (clEnqueueReleaseGrallocObjectsIMG command_queue
					   num_objects
					   mem_objects*
					   num_events_in_wait_list
					   event_wait_list*
					   event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReleaseGrallocObjectsIMG"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clGetKernelSubGroupInfoKHR in_kernel
				    in_device
				    param_name
				    input_value_size
				    input_value*
				    param_value_size
				    param_value*
				    param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetKernelSubGroupInfoKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_device_id cl_kernel_sub_group_info size_t '* size_t '* '*)))

(def-cl (clGetKernelSuggestedLocalWorkSizeKHR command_queue
					      kernel
					      work_dim
					      global_work_offset*
					      global_work_size*
					      suggested_local_work_size*)
  (foreign-library-function (cl-link)
			    "clGetKernelSuggestedLocalWorkSizeKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_kernel cl_uint '* '* '*)))

(def-cl (clCreateSemaphoreWithPropertiesKHR context sema_props* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateSemaphoreWithPropertiesKHR"
			    #:return-type cl_semaphore_khr
			    #:arg-types (list
					 cl_context '* '*)))

(def-cl (clEnqueueWaitSemaphoresKHR command_queue
				    num_sema_objects
				    sema_objects*
				    sema_payload_list*
				    num_events_in_wait_list
				    event_wait_list*
				    event*)
  (foreign-library-function (cl-link)
			    "clEnqueueWaitSemaphoresKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* '* cl_uint '* '*)))

(def-cl (clEnqueueSignalSemaphoresKHR command_queue
				      num_sema_objects
				      sema_objects*
				      sema_payload_list*
				      num_events_in_wait_list
				      event_wait_list*
				      event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSignalSemaphoresKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* '* cl_uint '* '*)))

(def-cl (clGetSemaphoreInfoKHR sema_object
			       param_name
			       param_value_size
			       param_value*
			       param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetSemaphoreInfoKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_semaphore_khr cl_semaphore_info_khr size_t '* '*)))

(def-cl (clReleaseSemaphoreKHR sema_object)
  (foreign-library-function (cl-link)
			    "clReleaseSemaphoreKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_semaphore_khr)))

(def-cl (clRetainSemaphoreKHR sema_object)
  (foreign-library-function (cl-link)
			    "clRetainSemaphoreKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_semaphore_khr)))

(def-cl (clGetSemaphoreHandleForTypeKHR sema_object
					device
					handle_type
					handle_size
					handle_ptr*
					handle_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetSemaphoreHandleForTypeKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_semaphore_khr cl_device_id cl_external_semaphore_handle_type_khr size_t '* '*)))

(def-cl (clReImportSemaphoreSyncFdKHR sema_object reimport_props* fd)
  (foreign-library-function (cl-link)
			    "clReImportSemaphoreSyncFdKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_semaphore_khr '* int)))

(def-cl (clEnqueueAcquireExternalMemObjectsKHR command_queue
					       num_mem_objects
					       mem_objects*
					       num_events_in_wait_list
					       event_wait_list*
					       event*)
  (foreign-library-function (cl-link)
			    "clEnqueueAcquireExternalMemObjectsKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clEnqueueReleaseExternalMemObjectsKHR command_queue
					       num_mem_objects
					       mem_objects*
					       num_events_in_wait_list
					       event_wait_list*
					       event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReleaseExternalMemObjectsKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clImportMemoryARM context
			   flags
			   properties*
			   memory*
			   size
			   errcode_ret*)
  (foreign-library-function (cl-link)
			    "clImportMemoryARM"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags '* '* size_t '*)))

(def-cl (clSVMAllocARM context
		       flags
		       size
		       alignment)
  (foreign-library-function (cl-link)
			    "clSVMAllocARM"
			    #:return-type void
			    #:arg-types (list
					 cl_context cl_svm_mem_flags_arm size_t cl_uint)))

(def-cl (clSVMFreeARM context svm_pointer*)
  (foreign-library-function (cl-link)
			    "clSVMFreeARM"
			    #:return-type void
			    #:arg-types (list
					 cl_context '*)))

(def-cl (clEnqueueSVMFreeARM command_queue
			     num_svm_pointers
			     svm_pointers*
			     pfn_free_func*
			     user_data*
			     num_events_in_wait_list
			     event_wait_list*
			     event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSVMFreeARM"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* '* '* cl_uint '* '*)))

(def-cl (clEnqueueSVMMemcpyARM command_queue
			       blocking_copy
			       dst_ptr*
			       src_ptr*
			       size
			       num_events_in_wait_list
			       event_wait_list*
			       event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSVMMemcpyARM"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_bool '* '* size_t cl_uint '* '*)))

(def-cl (clEnqueueSVMMemFillARM command_queue
				svm_ptr*
				pattern*
				pattern_size
				size
				num_events_in_wait_list
				event_wait_list*
				event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSVMMemFillARM"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue '* '* size_t size_t cl_uint '* '*)))

(def-cl (clEnqueueSVMMapARM command_queue
			    blocking_map
			    flags
			    svm_ptr*
			    size
			    num_events_in_wait_list
			    event_wait_list*
			    event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSVMMapARM"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_bool cl_map_flags '* size_t cl_uint '* '*)))

(def-cl (clEnqueueSVMUnmapARM command_queue
			      svm_ptr*
			      num_events_in_wait_list
			      event_wait_list*
			      event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSVMUnmapARM"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue '* cl_uint '* '*)))

(def-cl (clSetKernelArgSVMPointerARM kernel arg_index arg_value*)
  (foreign-library-function (cl-link)
			    "clSetKernelArgSVMPointerARM"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_uint '*)))

(def-cl (clSetKernelExecInfoARM kernel
				param_name
				param_value_size
				param_value*)
  (foreign-library-function (cl-link)
			    "clSetKernelExecInfoARM"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_kernel_exec_info_arm size_t '*)))

(def-cl (clCreateAcceleratorINTEL context
				  accelerator_type
				  descriptor_size
				  descriptor*
				  errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateAcceleratorINTEL"
			    #:return-type cl_accelerator_intel
			    #:arg-types (list
					 cl_context cl_accelerator_type_intel size_t '* '*)))

(def-cl (clGetAcceleratorInfoINTEL accelerator
				   param_name
				   param_value_size
				   param_value*
				   param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetAcceleratorInfoINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_accelerator_intel cl_accelerator_info_intel size_t '* '*)))

(def-cl (clRetainAcceleratorINTEL accelerator)
  (foreign-library-function (cl-link)
			    "clRetainAcceleratorINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_accelerator_intel)))

(def-cl (clReleaseAcceleratorINTEL accelerator)
  (foreign-library-function (cl-link)
			    "clReleaseAcceleratorINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_accelerator_intel)))

(def-cl (clCreateEventFromGLsyncKHR context sync errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateEventFromGLsyncKHR"
			    #:return-type cl_event
			    #:arg-types (list
					 cl_context cl_GLsync '*)))

(def-cl (clGetGLContextInfoKHR properties*
			       param_name
			       param_value_size
			       param_value*
			       param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetGLContextInfoKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 '* cl_gl_context_info size_t '* '*)))

(def-cl (clCreateFromGLBuffer context flags bufobj errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromGLBuffer"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags cl_GLuint '*)))

(def-cl (clCreateFromGLTexture context
			       flags
			       target
			       miplevel
			       texture
			       errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromGLTexture"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags cl_GLenum cl_GLint cl_GLuint '*)))

(def-cl (clCreateFromGLRenderbuffer context
				    flags
				    renderbuffer
				    errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromGLRenderbuffer"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags cl_GLuint '*)))

(def-cl (clGetGLObjectInfo memobj
			   gl_object_type*
			   gl_object_name*)
  (foreign-library-function (cl-link)
			    "clGetGLObjectInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_mem '* '*)))

(def-cl (clGetGLTextureInfo memobj
			    param_name
			    param_value_size
			    param_value*
			    param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetGLTextureInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_mem cl_gl_texture_info size_t '* '*)))

(def-cl (clEnqueueAcquireGLObjects command_queue
				   num_objects
				   mem_objects*
				   num_events_in_wait_list
				   event_wait_list*
				   event*)
  (foreign-library-function (cl-link)
			    "clEnqueueAcquireGLObjects"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clEnqueueReleaseGLObjects command_queue
				   num_objects
				   mem_objects*
				   num_events_in_wait_list
				   event_wait_list*
				   event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReleaseGLObjects"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clCreateFromGLTexture2D context
				 flags
				 target
				 miplevel
				 texture
				 errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromGLTexture2D"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags cl_GLenum cl_GLint cl_GLuint '*)))

(def-cl (clCreateFromGLTexture3D context
				 flags
				 target
				 miplevel
				 texture
				 errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromGLTexture3D"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags cl_GLenum cl_GLint cl_GLuint '*)))

(def-cl (clGetDeviceIDsFromVA_APIMediaAdapterINTEL platform
						   media_adapter_type
						   media_adapter*
						   media_adapter_set
						   num_entries
						   devices*
						   num_devices*)
  (foreign-library-function (cl-link)
			    "clGetDeviceIDsFromVA_APIMediaAdapterINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_platform_id cl_va_api_device_source_intel '* cl_va_api_device_set_intel cl_uint '* '*)))

(def-cl (clCreateFromVA_APIMediaSurfaceINTEL context flags surface* plane errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateFromVA_APIMediaSurfaceINTEL"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags '* cl_uint '*)))

(def-cl (clEnqueueAcquireVA_APIMediaSurfacesINTEL command_queue
						  num_objects
						  mem_objects*
						  num_events_in_wait_list
						  event_wait_list*
						  event*)
  (foreign-library-function (cl-link)
			    "clEnqueueAcquireVA_APIMediaSurfacesINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clEnqueueReleaseVA_APIMediaSurfacesINTEL command_queue
						  num_objects
						  mem_objects*
						  num_events_in_wait_list
						  event_wait_list*
						  event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReleaseVA_APIMediaSurfacesINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_uint '* '*)))

(def-cl (clHostMemAllocINTEL context
			     properties*
			     size
			     alignment
			     errcode_ret*)
  (foreign-library-function (cl-link)
			    "clHostMemAllocINTEL"
			    #:return-type void
			    #:arg-types (list
					 cl_context '* size_t cl_uint '*)))

(def-cl (clDeviceMemAllocINTEL context
			       device
			       properties*
			       size
			       alignment
			       errcode_ret*)
  (foreign-library-function (cl-link)
			    "clDeviceMemAllocINTEL"
			    #:return-type void
			    #:arg-types (list
					 cl_context cl_device_id '* size_t cl_uint '*)))

(def-cl (clSharedMemAllocINTEL context
			       device
			       properties*
			       size
			       alignment
			       errcode_ret*)
  (foreign-library-function (cl-link)
			    "clSharedMemAllocINTEL"
			    #:return-type void
			    #:arg-types (list
					 cl_context cl_device_id '* size_t cl_uint '*)))

(def-cl (clMemFreeINTEL context ptr*)
  (foreign-library-function (cl-link)
			    "clMemFreeINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context '*)))

(def-cl (clMemBlockingFreeINTEL context ptr*)
  (foreign-library-function (cl-link)
			    "clMemBlockingFreeINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context '*)))

(def-cl (clGetMemAllocInfoINTEL context
				ptr*
				param_name
				param_value_size
				param_value*
				param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetMemAllocInfoINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context '* cl_mem_info_intel size_t '* '*)))

(def-cl (clSetKernelArgMemPointerINTEL kernel arg_index arg_value*)
  (foreign-library-function (cl-link)
			    "clSetKernelArgMemPointerINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_uint '*)))

(def-cl (clEnqueueMemsetINTEL command_queue
			      dst_ptr*
			      value
			      size
			      num_events_in_wait_list
			      event_wait_list*
			      event*)
  (foreign-library-function (cl-link)
			    "clEnqueueMemsetINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue '* cl_int size_t cl_uint '* '*)))

(def-cl (clEnqueueMemFillINTEL command_queue
			       dst_ptr*
			       pattern*
			       pattern_size
			       size
			       num_events_in_wait_list
			       event_wait_list*
			       event*)
  (foreign-library-function (cl-link)
			    "clEnqueueMemFillINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue '* '* size_t size_t cl_uint '* '*)))

(def-cl (clEnqueueMemcpyINTEL command_queue
			      blocking
			      dst_ptr*
			      src_ptr*
			      size
			      num_events_in_wait_list
			      event_wait_list*
			      event*)
  (foreign-library-function (cl-link)
			    "clEnqueueMemcpyINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_bool '* '* size_t cl_uint '* '*)))

(def-cl (clEnqueueMigrateMemINTEL command_queue
				  ptr*
				  size
				  flags
				  num_events_in_wait_list
				  event_wait_list*
				  event*)
  (foreign-library-function (cl-link)
			    "clEnqueueMigrateMemINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue '* size_t cl_mem_migration_flags cl_uint '* '*)))

(def-cl (clEnqueueMemAdviseINTEL command_queue
				 ptr*
				 size
				 advice
				 num_events_in_wait_list
				 event_wait_list*
				 event*)
  (foreign-library-function (cl-link)
			    "clEnqueueMemAdviseINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue '* size_t cl_mem_advice_intel cl_uint '* '*)))

(def-cl (clCreateBufferWithPropertiesINTEL context properties* flags size host_ptr* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateBufferWithPropertiesINTEL"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context '* cl_mem_flags size_t '* '*)))

(def-cl (clCreateCommandBufferKHR num_queues queues* properties* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateCommandBufferKHR"
			    #:return-type cl_command_buffer_khr
			    #:arg-types (list
					 cl_uint '* '* '*)))

(def-cl (clFinalizeCommandBufferKHR command_buffer)
  (foreign-library-function (cl-link)
			    "clFinalizeCommandBufferKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr)))

(def-cl (clRetainCommandBufferKHR command_buffer)
  (foreign-library-function (cl-link)
			    "clRetainCommandBufferKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr)))

(def-cl (clReleaseCommandBufferKHR command_buffer)
  (foreign-library-function (cl-link)
			    "clReleaseCommandBufferKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr)))

(def-cl (clEnqueueCommandBufferKHR num_queues
				   queues*
				   command_buffer
				   num_events_in_wait_list
				   event_wait_list*
				   event*)
  (foreign-library-function (cl-link)
			    "clEnqueueCommandBufferKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_uint '* cl_command_buffer_khr cl_uint '* '*)))

(def-cl (clCommandBarrierWithWaitListKHR command_buffer
					 command_queue
					 properties*
					 num_sync_points_in_wait_list
					 sync_point_wait_list*
					 sync_point*
					 mutable_handle*)
  (foreign-library-function (cl-link)
			    "clCommandBarrierWithWaitListKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_queue '* cl_uint '* '* '*)))

(def-cl (clCommandCopyBufferKHR command_buffer
				command_queue
				properties*
				src_buffer
				dst_buffer
				src_offset
				dst_offset
				size
				num_sync_points_in_wait_list
				sync_point_wait_list*
				sync_point*
				mutable_handle*)
  (foreign-library-function (cl-link)
			    "clCommandCopyBufferKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_queue '* cl_mem cl_mem size_t size_t size_t cl_uint '* '* '*)))

(def-cl (clCommandCopyBufferRectKHR command_buffer
				    command_queue
				    properties*
				    src_buffer
				    dst_buffer
				    src_origin*
				    dst_origin*
				    region*
				    src_row_pitch
				    src_slice_pitch
				    dst_row_pitch
				    dst_slice_pitch
				    num_sync_points_in_wait_list
				    sync_point_wait_list*
				    sync_point*
				    mutable_handle*)
  (foreign-library-function (cl-link)
			    "clCommandCopyBufferRectKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_queue '* cl_mem cl_mem '* '* '* size_t size_t size_t size_t cl_uint '* '* '*)))

(def-cl (clCommandCopyBufferToImageKHR command_buffer
				       command_queue
				       properties*
				       src_buffer
				       dst_image
				       src_offset
				       dst_origin*
				       region*
				       num_sync_points_in_wait_list
				       sync_point_wait_list*
				       sync_point*
				       mutable_handle*)
  (foreign-library-function (cl-link)
			    "clCommandCopyBufferToImageKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_queue '* cl_mem cl_mem size_t '* '* cl_uint '* '* '*)))

(def-cl (clCommandCopyImageKHR command_buffer
			       command_queue
			       properties*
			       src_image
			       dst_image
			       src_origin*
			       dst_origin*
			       region*
			       num_sync_points_in_wait_list
			       sync_point_wait_list*
			       sync_point*
			       mutable_handle*)
  (foreign-library-function (cl-link)
			    "clCommandCopyImageKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_queue '* cl_mem cl_mem '* '* '* cl_uint '* '* '*)))

(def-cl (clCommandCopyImageToBufferKHR command_buffer
				       command_queue
				       properties*
				       src_image
				       dst_buffer
				       src_origin*
				       region*
				       dst_offset
				       num_sync_points_in_wait_list
				       sync_point_wait_list*
				       sync_point*
				       mutable_handle*)
  (foreign-library-function (cl-link)
			    "clCommandCopyImageToBufferKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_queue '* cl_mem cl_mem '* '* size_t cl_uint '* '* '*)))

(def-cl (clCommandFillBufferKHR command_buffer
				command_queue
				properties*
				buffer
				pattern*
				pattern_size
				offset
				size
				num_sync_points_in_wait_list
				sync_point_wait_list*
				sync_point*
				mutable_handle*)
  (foreign-library-function (cl-link)
			    "clCommandFillBufferKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_queue '* cl_mem '* size_t size_t size_t cl_uint '* '* '*)))

(def-cl (clCommandFillImageKHR command_buffer
			       command_queue
			       properties*
			       image
			       fill_color*
			       origin*
			       region*
			       num_sync_points_in_wait_list
			       sync_point_wait_list*
			       sync_point*
			       mutable_handle*)
  (foreign-library-function (cl-link)
			    "clCommandFillImageKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_queue '* cl_mem '* '* '* cl_uint '* '* '*)))

(def-cl (clCommandNDRangeKernelKHR command_buffer
				   command_queue
				   properties*
				   kernel
				   work_dim
				   global_work_offset*
				   global_work_size*
				   local_work_size*
				   num_sync_points_in_wait_list
				   sync_point_wait_list*
				   sync_point*
				   mutable_handle*)
  (foreign-library-function (cl-link)
			    "clCommandNDRangeKernelKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_queue '* cl_kernel cl_uint '* '* '* cl_uint '* '* '*)))

(def-cl (clCommandSVMMemcpyKHR command_buffer
			       command_queue
			       properties*
			       dst_ptr*
			       src_ptr*
			       size
			       num_sync_points_in_wait_list
			       sync_point_wait_list*
			       sync_point*
			       mutable_handle*)
  (foreign-library-function (cl-link)
			    "clCommandSVMMemcpyKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_queue '* '* '* size_t cl_uint '* '* '*)))

(def-cl (clCommandSVMMemFillKHR command_buffer
				command_queue
				properties*
				svm_ptr*
				pattern*
				pattern_size
				size
				num_sync_points_in_wait_list
				sync_point_wait_list*
				sync_point*
				mutable_handle*)
  (foreign-library-function (cl-link)
			    "clCommandSVMMemFillKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_queue '* '* '* size_t size_t cl_uint '* '* '*)))

(def-cl (clGetCommandBufferInfoKHR command_buffer
				   param_name
				   param_value_size
				   param_value*
				   param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetCommandBufferInfoKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_command_buffer_info_khr size_t '* '*)))

(def-cl (clUpdateMutableCommandsKHR command_buffer num_configs config_types* configs*)
  (foreign-library-function (cl-link)
			    "clUpdateMutableCommandsKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_buffer_khr cl_uint '* '*)))

(def-cl (clGetMutableCommandInfoKHR command
				    param_name
				    param_value_size
				    param_value*
				    param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetMutableCommandInfoKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_mutable_command_khr cl_mutable_command_info_khr size_t '* '*)))

(def-cl (clRemapCommandBufferKHR command_buffer
				 automatic
				 num_queues
				 queues*
				 num_handles
				 handles*
				 handles_ret*
				 errcode_ret*)
  (foreign-library-function (cl-link)
			    "clRemapCommandBufferKHR"
			    #:return-type cl_command_buffer_khr
			    #:arg-types (list
					 cl_command_buffer_khr cl_bool cl_uint '* cl_uint '* '* '*)))

(def-cl (clSetContentSizeBufferPoCL buffer content_size_buffer)
  (foreign-library-function (cl-link)
			    "clSetContentSizeBufferPoCL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_mem cl_mem)))

(def-cl (clSVMAllocWithPropertiesKHR context properties* svm_type_index size errcode_ret*)
  (foreign-library-function (cl-link)
			    "clSVMAllocWithPropertiesKHR"
			    #:return-type void
			    #:arg-types (list
					 cl_context '* cl_uint size_t '*)))

(def-cl (clSVMFreeWithPropertiesKHR context properties* flags ptr*)
  (foreign-library-function (cl-link)
			    "clSVMFreeWithPropertiesKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context '* cl_svm_free_flags_khr '*)))

(def-cl (clGetSVMPointerInfoKHR context
				device
				ptr*
				param_name
				param_value_size
				param_value*
				param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetSVMPointerInfoKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context cl_device_id '* cl_svm_pointer_info_khr size_t '* '*)))

(def-cl (clGetSVMSuggestedTypeIndexKHR context
				       required_capabilities
				       desired_capabilities
				       properties*
				       size
				       suggested_svm_type_index*)
  (foreign-library-function (cl-link)
			    "clGetSVMSuggestedTypeIndexKHR"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context cl_svm_capabilities_khr cl_svm_capabilities_khr '* size_t '*)))

(def-cl (clGetPlatformIDs num_entries platforms* num_platforms*)
  (foreign-library-function (cl-link)
			    "clGetPlatformIDs"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_uint '* '*)))

(def-cl (clGetPlatformInfo platform
			   param_name
			   param_value_size
			   param_value*
			   param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetPlatformInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_platform_id cl_platform_info size_t '* '*)))

(def-cl (clGetDeviceIDs platform
			device_type
			num_entries
			devices*
			num_devices*)
  (foreign-library-function (cl-link)
			    "clGetDeviceIDs"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_platform_id cl_device_type cl_uint '* '*)))

(def-cl (clGetDeviceInfo device
			 param_name
			 param_value_size
			 param_value*
			 param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetDeviceInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_device_id cl_device_info size_t '* '*)))

(def-cl (clCreateSubDevices in_device
			    properties*
			    num_devices
			    out_devices*
			    num_devices_ret*)
  (foreign-library-function (cl-link)
			    "clCreateSubDevices"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_device_id '* cl_uint '* '*)))

(def-cl (clRetainDevice device)
  (foreign-library-function (cl-link)
			    "clRetainDevice"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_device_id)))

(def-cl (clReleaseDevice device)
  (foreign-library-function (cl-link)
			    "clReleaseDevice"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_device_id)))

(def-cl (clSetDefaultDeviceCommandQueue context device command_queue)
  (foreign-library-function (cl-link)
			    "clSetDefaultDeviceCommandQueue"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context cl_device_id cl_command_queue)))

(def-cl (clGetDeviceAndHostTimer device device_timestamp* host_timestamp*)
  (foreign-library-function (cl-link)
			    "clGetDeviceAndHostTimer"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_device_id '* '*)))

(def-cl (clGetHostTimer device host_timestamp*)
  (foreign-library-function (cl-link)
			    "clGetHostTimer"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_device_id '*)))

(def-cl (clCreateContext properties*
			 num_devices
			 devices*
			 pfn_notify
			 user_data*
			 errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateContext"
			    #:return-type cl_context
			    #:arg-types (list
					 '* cl_uint '* '* '* '*)))

(def-cl (clCreateContextFromType properties* device_type pfn_notify user_data* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateContextFromType"
			    #:return-type cl_context
			    #:arg-types (list
					 '* cl_device_type '* '* '*)))

(def-cl (clRetainContext context)
  (foreign-library-function (cl-link)
			    "clRetainContext"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context)))

(def-cl (clReleaseContext context)
  (foreign-library-function (cl-link)
			    "clReleaseContext"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context)))

(def-cl (clGetContextInfo context
			  param_name
			  param_value_size
			  param_value*
			  param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetContextInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context cl_context_info size_t '* '*)))

(def-cl (clSetContextDestructorCallback context pfn_notify user_data*)
  (foreign-library-function (cl-link)
			    "clSetContextDestructorCallback"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context '* '*)))

(def-cl (clCreateCommandQueueWithProperties context
					    device
					    properties*
					    errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateCommandQueueWithProperties"
			    #:return-type cl_command_queue
			    #:arg-types (list
					 cl_context cl_device_id '* '*)))

(def-cl (clRetainCommandQueue command_queue)
  (foreign-library-function (cl-link)
			    "clRetainCommandQueue"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue)))

(def-cl (clReleaseCommandQueue command_queue)
  (foreign-library-function (cl-link)
			    "clReleaseCommandQueue"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue)))

(def-cl (clGetCommandQueueInfo command_queue param_name
			       param_value_size
			       param_value*
			       param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetCommandQueueInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_command_queue_info size_t '* '*)))

(def-cl (clCreateBuffer context flags size host_ptr* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateBuffer"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags size_t '* '*)))

(def-cl (clCreateBufferWithProperties context properties* flags size host_ptr* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateBufferWithProperties"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context '* cl_mem_flags size_t '* '*)))

(def-cl (clCreateSubBuffer buffer flags buffer_create_type buffer_create_info* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateSubBuffer"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_mem cl_mem_flags cl_buffer_create_type '* '*)))

(def-cl (clCreateImage context flags image_format* image_desc* host_ptr* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateImage"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags '* '* '* '*)))

(def-cl (clCreateImageWithProperties context
				     properties*
				     flags
				     image_format*
				     image_desc*
				     host_ptr*
				     errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateImageWithProperties"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context '* cl_mem_flags '* '* '* '*)))

(def-cl (clCreatePipe context
		      flags
		      pipe_packet_size
		      pipe_max_packets
		      properties*
		      errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreatePipe"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags cl_uint cl_uint '* '*)))

(def-cl (clRetainMemObject memobj)
  (foreign-library-function (cl-link)
			    "clRetainMemObject"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_mem)))

(def-cl (clReleaseMemObject memobj)
  (foreign-library-function (cl-link)
			    "clReleaseMemObject"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_mem)))

(def-cl (clGetSupportedImageFormats context
				    flags
				    image_type
				    num_entries
				    image_formats*
				    num_image_formats*)
  (foreign-library-function (cl-link)
			    "clGetSupportedImageFormats"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context cl_mem_flags cl_mem_object_type cl_uint '* '*)))

(def-cl (clGetMemObjectInfo memobj
			    param_name
			    param_value_size
			    param_value*
			    param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetMemObjectInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_mem cl_mem_info size_t '* '*)))

(def-cl (clGetImageInfo image
			param_name
			param_value_size
			param_value*
			param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetImageInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_mem cl_image_info size_t '* '*)))

(def-cl (clGetPipeInfo pipe
		       param_name
		       param_value_size
		       param_value*
		       param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetPipeInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_mem cl_pipe_info size_t '* '*)))

(def-cl (clSetMemObjectDestructorCallback memobj pfn_notify user_data*)
  (foreign-library-function (cl-link)
			    "clSetMemObjectDestructorCallback"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_mem '* '*)))

(def-cl (clSetMemObjectDestructorAPPLE memobj pfn_notify user_data*)
  (foreign-library-function (cl-link)
			    "clSetMemObjectDestructorAPPLE"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_mem '* '*)))

(def-cl (clSVMAlloc context flags size alignment)
  (foreign-library-function (cl-link)
			    "clSVMAlloc"
			    #:return-type void
			    #:arg-types (list
					 cl_context cl_svm_mem_flags size_t cl_uint)))

(def-cl (clSVMFree context svm_pointer*)
  (foreign-library-function (cl-link)
			    "clSVMFree"
			    #:return-type void
			    #:arg-types (list
					 cl_context '*)))

(def-cl (clCreateSamplerWithProperties context sampler_properties* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateSamplerWithProperties"
			    #:return-type cl_sampler
			    #:arg-types (list
					 cl_context '* '*)))

(def-cl (clRetainSampler sampler)
  (foreign-library-function (cl-link)
			    "clRetainSampler"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_sampler)))

(def-cl (clReleaseSampler sampler)
  (foreign-library-function (cl-link)
			    "clReleaseSampler"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_sampler)))

(def-cl (clGetSamplerInfo sampler
			  param_name
			  param_value_size
			  param_value*
			  param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetSamplerInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_sampler cl_sampler_info size_t '* '*)))

(def-cl (clCreateProgramWithSource context
				   count
				   strings*
				   lengths*
				   errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateProgramWithSource"
			    #:return-type cl_program
			    #:arg-types (list
					 cl_context cl_uint '* '* '*)))

(def-cl (clCreateProgramWithBinary context
				   num_devices
				   device_list*
				   lengths*
				   binaries*
				   binary_status*
				   errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateProgramWithBinary"
			    #:return-type cl_program
			    #:arg-types (list
					 cl_context cl_uint '* '* '* '* '*)))

(def-cl (clCreateProgramWithBuiltInKernels context
					   num_devices
					   device_list*
					   kernel_names*
					   errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateProgramWithBuiltInKernels"
			    #:return-type cl_program
			    #:arg-types (list
					 cl_context cl_uint '* '* '*)))

(def-cl (clCreateProgramWithIL context il* length errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateProgramWithIL"
			    #:return-type cl_program
			    #:arg-types (list
					 cl_context '* size_t '*)))

(def-cl (clRetainProgram program)
  (foreign-library-function (cl-link)
			    "clRetainProgram"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_program)))

(def-cl (clReleaseProgram program)
  (foreign-library-function (cl-link)
			    "clReleaseProgram"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_program)))

(def-cl (clBuildProgram program
			num_devices
			device_list*
			options*
			pfn_notify
			user_data*)
  (foreign-library-function (cl-link)
			    "clBuildProgram"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_program cl_uint '* '* '* '*)))

(def-cl (clCompileProgram program
			  num_devices
			  device_list*
			  options*
			  num_input_headers
			  input_headers*
			  header_include_names*
			  pfn_notify
			  user_data*)
  (foreign-library-function (cl-link)
			    "clCompileProgram"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_program cl_uint '* '* cl_uint '* '* '* '*)))

(def-cl (clLinkProgram context
		       num_devices
		       device_list*
		       options*
		       num_input_programs
		       input_programs*
		       pfn_notify
		       user_data*
		       errcode_ret*)
  (foreign-library-function (cl-link)
			    "clLinkProgram"
			    #:return-type cl_program
			    #:arg-types (list
					 cl_context cl_uint '* '* cl_uint '* '* '* '*)))

(def-cl (clSetProgramReleaseCallback program pfn_notify user_data*)
  (foreign-library-function (cl-link)
			    "clSetProgramReleaseCallback"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_program '* '*)))

(def-cl (clSetProgramSpecializationConstant program spec_id spec_size spec_value*)
  (foreign-library-function (cl-link)
			    "clSetProgramSpecializationConstant"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_program cl_uint size_t '*)))

(def-cl (clUnloadPlatformCompiler platform)
  (foreign-library-function (cl-link)
			    "clUnloadPlatformCompiler"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_platform_id)))

(def-cl (clGetProgramInfo program
			  param_name
			  param_value_size
			  param_value*
			  param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetProgramInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_program cl_program_info size_t '* '*)))

(def-cl (clGetProgramBuildInfo program
			       device
			       param_name
			       param_value_size
			       param_value*
			       param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetProgramBuildInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_program cl_device_id cl_program_build_info size_t '* '*)))

(def-cl (clCreateKernel program kernel_name* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateKernel"
			    #:return-type cl_kernel
			    #:arg-types (list
					 cl_program '* '*)))

(def-cl (clCreateKernelsInProgram program num_kernels kernels* num_kernels_ret*)
  (foreign-library-function (cl-link)
			    "clCreateKernelsInProgram"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_program cl_uint '* '*)))

(def-cl (clCloneKernel source_kernel errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCloneKernel"
			    #:return-type cl_kernel
			    #:arg-types (list
					 cl_kernel '*)))

(def-cl (clRetainKernel kernel)
  (foreign-library-function (cl-link)
			    "clRetainKernel"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel)))

(def-cl (clReleaseKernel kernel)
  (foreign-library-function (cl-link)
			    "clReleaseKernel"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel)))

(def-cl (clSetKernelArg kernel arg_index arg_size arg_value*)
  (foreign-library-function (cl-link)
			    "clSetKernelArg"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_uint size_t '*)))

(def-cl (clSetKernelArgSVMPointer kernel arg_index arg_value*)
  (foreign-library-function (cl-link)
			    "clSetKernelArgSVMPointer"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_uint '*)))

(def-cl (clSetKernelArgDevicePointerEXT kernel arg_index arg_value)
  (foreign-library-function (cl-link)
			    "clSetKernelArgDevicePointerEXT"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_uint cl_mem_device_address_ext)))

(def-cl (clSetKernelExecInfo kernel param_name param_value_size param_value*)
  (foreign-library-function (cl-link)
			    "clSetKernelExecInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_kernel_exec_info size_t '*)))

(def-cl (clGetKernelInfo kernel param_name param_value_size param_value* param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetKernelInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_kernel_info size_t '* '*)))

(def-cl (clGetKernelArgInfo kernel arg_index param_name param_value_size param_value* param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetKernelArgInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_uint cl_kernel_arg_info size_t '* '*)))

(def-cl (clGetKernelWorkGroupInfo kernel device param_name param_value_size param_value* param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetKernelWorkGroupInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_device_id cl_kernel_work_group_info size_t '* '*)))

(def-cl (clGetKernelSubGroupInfo kernel device param_name input_value_size input_value* param_value_size param_value* param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetKernelSubGroupInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_kernel cl_device_id cl_kernel_sub_group_info size_t '* size_t '* '*)))

(def-cl (clWaitForEvents num_events event_list*)
  (foreign-library-function (cl-link)
			    "clWaitForEvents"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_uint '*)))

(def-cl (clGetEventInfo event param_name param_value_size param_value* param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetEventInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_event cl_event_info size_t '* '*)))

(def-cl (clCreateUserEvent context errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateUserEvent"
			    #:return-type cl_event
			    #:arg-types (list
					 cl_context '*)))

(def-cl (clRetainEvent event)
  (foreign-library-function (cl-link)
			    "clRetainEvent"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_event)))

(def-cl (clReleaseEvent event)
  (foreign-library-function (cl-link)
			    "clReleaseEvent"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_event)))

(def-cl (clSetUserEventStatus event execution_status)
  (foreign-library-function (cl-link)
			    "clSetUserEventStatus"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_event cl_int)))

(def-cl (clSetEventCallback event command_exec_callback_type pfn_notify user_data*)
  (foreign-library-function (cl-link)
			    "clSetEventCallback"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_event cl_int size_t '*)))

(def-cl (clGetEventProfilingInfo event param_name param_value_size param_value* param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetEventProfilingInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_event cl_profiling_info size_t '* '*)))

(def-cl (clFlush command_queue)
  (foreign-library-function (cl-link)
			    "clFlush"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue)))

(def-cl (clFinish command_queue)
  (foreign-library-function (cl-link)
			    "clFinish"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue)))

(def-cl (clEnqueueReadBuffer command_queue buffer blocking_read offset size ptr* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReadBuffer"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_bool size_t size_t '* cl_uint '* '*)))

(def-cl (clEnqueueReadBufferRect command_queue buffer blocking_read buffer_origin* host_origin* region* buffer_row_pitch buffer_slice_pitch host_row_pitch host_slice_pitch ptr* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReadBufferRect"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_bool '* '* '* size_t size_t size_t size_t '* cl_uint '* '*)))

(def-cl (clEnqueueWriteBuffer command_queue buffer blocking_write offset size ptr* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueWriteBuffer"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_bool size_t size_t '* cl_uint '* '*)))

(def-cl (clEnqueueWriteBufferRect command_queue buffer blocking_write buffer_origin* host_origin* region* buffer_row_pitch buffer_slice_pitch host_row_pitch host_slice_pitch ptr* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueWriteBufferRect"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_bool '* '* '* size_t size_t size_t size_t '* cl_uint '* '*)))

(def-cl (clEnqueueFillBuffer command_queue buffer pattern* pattern_size offset size num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueFillBuffer"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem '* size_t size_t size_t cl_uint '* '*)))

(def-cl (clEnqueueCopyBuffer command_queue src_buffer dst_buffer src_offset dst_offset size num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueCopyBuffer"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_mem size_t size_t size_t cl_uint '* '*)))

(def-cl (clEnqueueCopyBufferRect command_queue src_buffer dst_buffer src_origin* dst_origin* region* src_row_pitch src_slice_pitch dst_row_pitch dst_slice_pitch num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueCopyBufferRect"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_mem '* '* '* size_t size_t size_t size_t cl_uint '* '*)))

(def-cl (clEnqueueReadImage command_queue image blocking_read origin* region* row_pitch slice_pitch ptr* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReadImage"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_bool '* '* size_t size_t '* cl_uint '* '*)))

(def-cl (clEnqueueWriteImage command_queue image blocking_write origin* region* input_row_pitch input_slice_pitch ptr* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueWriteImage"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_bool '* '* size_t size_t '* cl_uint '* '*)))

(def-cl (clEnqueueFillImage command_queue image fill_color* origin* region* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueFillImage"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem '* '* '* cl_uint '* '*)))

(def-cl (clEnqueueCopyImage command_queue src_image dst_image src_origin* dst_origin* region* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueCopyImage"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_mem '* '* '* cl_uint '* '*)))

(def-cl (clEnqueueCopyImageToBuffer command_queue src_image dst_buffer src_origin* region* dst_offset num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueCopyImageToBuffer"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_mem '* '* size_t cl_uint '* '*)))

(def-cl (clEnqueueCopyBufferToImage command_queue src_buffer dst_image src_offset dst_origin* region* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueCopyBufferToImage"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem cl_mem size_t '* '* cl_uint '* '*)))

(def-cl (clEnqueueMapBuffer command_queue buffer blocking_map map_flags offset size num_events_in_wait_list event_wait_list* event* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clEnqueueMapBuffer"
			    #:return-type void
			    #:arg-types (list
					 cl_command_queue cl_mem cl_bool cl_map_flags size_t size_t cl_uint '* '* '*)))

(def-cl (clEnqueueMapImage command_queue image blocking_map map_flags origin* region* image_row_pitch* image_slice_pitch* num_events_in_wait_list event_wait_list* event* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clEnqueueMapImage"
			    #:return-type void
			    #:arg-types (list
					 cl_command_queue cl_mem cl_bool cl_map_flags '* '* '* '* cl_uint '* '* '*)))

(def-cl (clEnqueueUnmapMemObject command_queue memobj mapped_ptr* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueUnmapMemObject"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_mem '* cl_uint '* '*)))

(def-cl (clEnqueueMigrateMemObjects command_queue num_mem_objects mem_objects* flags num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueMigrateMemObjects"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* cl_mem_migration_flags cl_uint '* '*)))

(def-cl (clEnqueueNDRangeKernel command_queue kernel work_dim global_work_offset* global_work_size* local_work_size* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueNDRangeKernel"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_kernel cl_uint '* '* '* cl_uint '* '*)))

(def-cl (clEnqueueNativeKernel command_queue user_func args* cb_args num_mem_objects mem_list* args_mem_loc* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueNativeKernel"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue '* '* size_t cl_uint '* '* cl_uint '* '*)))

(def-cl (clEnqueueMarkerWithWaitList command_queue num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueMarkerWithWaitList"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* '*)))

(def-cl (clEnqueueBarrierWithWaitList command_queue num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueBarrierWithWaitList"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* '*)))

(def-cl (clEnqueueSVMFree command_queue num_svm_pointers svm_pointers pfn_free_func user_data* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSVMFree"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* '* '* cl_uint '* '*)))

(def-cl (clEnqueueSVMMemcpy command_queue blocking_copy dst_ptr* src_ptr* size num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSVMMemcpy"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_bool '* '* size_t cl_uint '* '*)))

(def-cl (clEnqueueSVMMemFill command_queue svm_ptr* pattern* pattern_size size num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSVMMemFill"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue '* '* size_t size_t cl_uint '* '*)))


(def-cl (clEnqueueSVMMap command_queue blocking_map flags svm_ptr* size num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSVMMap"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_bool cl_map_flags '* size_t cl_uint '* '*)))

(def-cl (clEnqueueSVMUnmap command_queue svm_ptr* num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSVMUnmap"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue '* cl_uint '* '*)))

(def-cl (clEnqueueSVMMigrateMem command_queue num_svm_pointers svm_pointers* sizes* flags num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueSVMMigrateMem"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '* '* cl_mem_migration_flags cl_uint '* '*)))

(def-cl (clGetExtensionFunctionAddressForPlatform platform func_name*)
  (foreign-library-function (cl-link)
			    "clGetExtensionFunctionAddressForPlatform"
			    #:return-type void
			    #:arg-types (list
					 cl_platform_id '*)))

(def-cl (clSetCommandQueueProperty command_queue properties enable old_properties*)
  (foreign-library-function (cl-link)
			    "clSetCommandQueueProperty"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_command_queue_properties cl_bool '*)))

(def-cl (clCreateImage2D context flags image_format* image_width image_height image_row_pitch host_ptr* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateImage2D"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags '* size_t size_t size_t '* '*)))

(def-cl (clCreateImage3D context flags image_format* image_width image_height image_depth image_row_pitch image_slice_pitch host_ptr* errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateImage3D"
			    #:return-type cl_mem
			    #:arg-types (list
					 cl_context cl_mem_flags '* size_t size_t size_t size_t size_t '* '*)))

(def-cl (clEnqueueMarker command_queue event*)
  (foreign-library-function (cl-link)
			    "clEnqueueMarker"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue '*)))

(def-cl (clEnqueueWaitForEvents command_queue num_events event_list*)
  (foreign-library-function (cl-link)
			    "clEnqueueWaitForEvents"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_uint '*)))

(def-cl (clEnqueueBarrier command_queue)
  (foreign-library-function (cl-link)
			    "clEnqueueBarrier"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue)))

(def-cl (clUnloadCompiler)
  (foreign-library-function (cl-link)
			    "\"clUnloadCompiler\""
			    #:return-type cl_int
			    #:arg-types '()))

(def-cl (clGetExtensionFunctionAddress func_name*)
  (foreign-library-function (cl-link)
			    "clGetExtensionFunctionAddress"
			    #:return-type void
			    #:arg-types (list
					 '*)))

(def-cl (clCreateCommandQueue context device properties errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateCommandQueue"
			    #:return-type cl_command_queue
			    #:arg-types (list
					 cl_context cl_device_id cl_command_queue_properties '*)))

(def-cl (clCreateSampler context normalized_coords addressing_mode filter_mode errcode_ret*)
  (foreign-library-function (cl-link)
			    "clCreateSampler"
			    #:return-type cl_sampler
			    #:arg-types (list
					 cl_context cl_bool cl_addressing_mode cl_filter_mode '*)))

(def-cl (clEnqueueTask command_queue kernel num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueTask"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_kernel cl_uint '* '*)))

(def-cl (clGetLayerInfo param_name param_value_size param_value* param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetLayerInfo"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_layer_info size_t '* '*)))

(def-cl (clInitLayer num_entries target_dispatch* num_entries_ret* layer_dispatch_ret*)
  (foreign-library-function (cl-link)
			    "clInitLayer"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_uint '* '* '*)))

(def-cl (clInitLayerWithProperties num_entries target_dispatch* num_entries_ret* layer_dispatch_ret* properties*)
  (foreign-library-function (cl-link)
			    "clInitLayerWithProperties"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_uint '* '* '* '*)))

(def-cl (clDeinitLayer)
  (foreign-library-function (cl-link)
			    "clDeinitLayer"
			    #:return-type cl_int
			    #:arg-types '()))


(def-cl (clGetICDLoaderInfoOCLICD param_name param_value_size param_value* param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetICDLoaderInfoOCLICD"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_icdl_info size_t '* '*)))

(def-cl (clGetSupportedGLTextureFormatsINTEL context flags image_type num_entries gl_formats* num_texture_formats*)
  (foreign-library-function (cl-link)
			    "clGetSupportedGLTextureFormatsINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context cl_mem_flags cl_mem_object_type cl_uint '* '*)))

(def-cl (clGetSupportedDX9MediaSurfaceFormatsINTEL context flags image_type plane num_entries dx9_formats* num_surface_formats*)
  (foreign-library-function (cl-link)
			    "clGetSupportedDX9MediaSurfaceFormatsINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context cl_mem_flags cl_mem_object_type cl_uint cl_uint '* '*)))

(def-cl (clGetSupportedD3D10TextureFormatsINTEL context flags image_type num_entries d3d10_formats* num_texture_formats*)
  (foreign-library-function (cl-link)
			    "clGetSupportedD3D10TextureFormatsINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context cl_mem_flags cl_mem_object_type cl_uint '* '*)))

(def-cl (clGetSupportedD3D11TextureFormatsINTEL context flags image_type plane num_entries d3d11_formats* num_texture_formats*)
  (foreign-library-function (cl-link)
			    "clGetSupportedD3D11TextureFormatsINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context cl_mem_flags cl_mem_object_type cl_uint cl_uint '* '*)))

(def-cl (clGetSupportedVA_APIMediaSurfaceFormatsINTEL context flags image_type plane num_entries va_api_formats* num_surface_formats*)
  (foreign-library-function (cl-link)
			    "clGetSupportedVA_APIMediaSurfaceFormatsINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context cl_mem_flags cl_mem_object_type cl_uint cl_uint '* '*)))

(def-cl (clEnqueueReadHostPipeINTEL command_queue program pipe_symbol* blocking_read ptr* size num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueReadHostPipeINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_program '* cl_bool '* size_t cl_uint '* '*)))

(def-cl (clEnqueueWriteHostPipeINTEL command_queue program pipe_symbol* blocking_write ptr* size num_events_in_wait_list event_wait_list* event*)
  (foreign-library-function (cl-link)
			    "clEnqueueWriteHostPipeINTEL"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_command_queue cl_program '* cl_bool '* size_t cl_uint '* '*)))

(def-cl (clGetImageRequirementsInfoEXT context properties* flags image_format* image_desc* param_name param_value_size param_value* param_value_size_ret*)
  (foreign-library-function (cl-link)
			    "clGetImageRequirementsInfoEXT"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context '* cl_mem_flags '* '* cl_image_requirements_info_ext size_t '* '*)))

(def-cl (clCancelCommandsIMG event_list* num_events_in_list)
  (foreign-library-function (cl-link)
			    "clCancelCommandsIMG"
			    #:return-type cl_int
			    #:arg-types (list
					 '* size_t)))

(def-cl (clSetPerfHintQCOM context perf_hint)
  (foreign-library-function (cl-link)
			    "clSetPerfHintQCOM"
			    #:return-type cl_int
			    #:arg-types (list
					 cl_context cl_perf_hint_qcom)))
