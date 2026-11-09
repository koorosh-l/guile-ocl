(use-modules (guix build-system gnu)
	     (guix git)
	     (guix licenses)
	     (guix packages)
	     (gnu packages)
	     (gnu packages autotools)
	     (gnu packages guile)
	     (gnu packages pkg-config)
	     (gnu packages opencl))

(package
 (name "guile-ocl")
 (version "0.0.1")
 (source (git-checkout (url (dirname (current-filename)))))
 (build-system gnu-build-system)
 (arguments
  '(#:make-flags
    '("GUILE_AUTO_COMPILE=0")
    #:phases
    (modify-phases %standard-phases
		   (add-after 'unpack 'bootstrap
			      (lambda _ (invoke "sh" "autoreconf" "-vif"))))))
 (native-inputs (list autoconf automake pkg-config opencl-icd-loader opencl-headers))
 (inputs (list  guile-3.0.11 opencl-icd-loader))
 (synopsis "OpenCL bindings for guile")
 (description "guile-ocl is a minimal set of modules that provide
access to the OpenCl bindings")
 (home-page "https://github.com/koorosh-l/guile-ocl")
 (license lgpl3+))
