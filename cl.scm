(define-module (cl)
  #:use-module (system foreign-library)
  #:use-module (cl config))

(eval-when (eval load compile expand)
  (define-public cl-link ;; make-it optional
    (load-foreign-library so-path)))
(begin
  (define modules '((cl config)
		    (cl enums)
		    (cl functions)
		    (cl types)))
  (for-each
   (lambda (m)
     (module-use! (current-module)
		  (resolve-interface m))
     (module-use! (resolve-interface (module-name (current-module)))
		  (resolve-interface m)))
   modules))
