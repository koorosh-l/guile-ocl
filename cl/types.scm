(define-module (cl types)
  #:use-module ((system foreign) #:prefix ffi:))

;; (eval-when (load compile eval expand)
;;   (begin
;;     ))

(define modules '((cl types opaque)
		  (cl types basic)
		  (cl types derived)))
(for-each
 (lambda (m)
   (module-use! (current-module)
		(resolve-interface m))
   (module-use! (resolve-interface (module-name (current-module)))
		(resolve-interface m)))
 modules)
