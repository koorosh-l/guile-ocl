(use-modules ((guix licenses) #:prefix license:)
	     (gnu packages gcc)
	     (gnu packages guile)
	     ((srfi srfi-1) #:hide (zip))
	     (gnu packages base)
	     (gnu packages gawk)
	     (gnu packages opencl)
	     (gnu packages less)
	     (gnu packages autotools)
	     (gnu packages bison)
	     (gnu packages build-tools)
	     (gnu packages check)
	     (gnu packages cmake)
	     (gnu packages compression)
	     (gnu packages documentation)
	     (gnu packages elf)
	     (gnu packages flex)
	     (gnu packages fontutils)
	     (gnu packages freedesktop)
	     (gnu packages gettext)
	     (gnu packages guile)
	     (gnu packages image)
	     (gnu packages linux)
	     (gnu packages llvm)
	     (gnu packages pkg-config)
	     (gnu packages python)
	     (gnu packages python-build)
	     (gnu packages python-xyz)
	     (gnu packages rust)
	     (gnu packages rust-apps)
	     (gnu packages tls)
	     (gnu packages video)
	     (gnu packages vulkan)
	     (gnu packages xdisorg)
	     (gnu packages xml)
	     (gnu packages xorg)
	     (gnu packages)
	     (guix build-system cmake)
	     (guix build-system gnu)
	     (guix build-system meson)
	     (guix build-system pyproject)
	     (guix build-system python)
	     (guix download)
	     (guix gexp)
	     (guix git)
	     (guix git-download)
	     (guix hg-download)
	     (guix packages)
	     (guix utils)
	     (ice-9 match)
	     (srfi srfi-26))
;; guix shell --file=mesa.scm --container --emulate-fhs --share=/dev/ --share=/sys --expose=/home/quasikote/.guile --share=/home/quasikote/proj/scheme-ocl/ -- ./pre-inst-env sh repl.scm
1
;; make clean && autoreconf -vif && ./configure  --prefix=/home/quasikote/proj/scheme-ocl/build && make -j8 install

;; (define ocl
;;   (package
;;    (name "guile-ocl")
;;    (version "0.0.1")
;;    (source (git-checkout (url (dirname (current-filename)))))
;;    (build-system gnu-build-system)
;;    (arguments
;;     '(#:make-flags '("GUILE_AUTO_COMPILE=0")
;;		   #:phases
;;		   (modify-phases %standard-phases
;;				  (add-after 'unpack 'bootstrap
;;					     (lambda _ (invoke "sh" "autoreconf" "-vif"))))))
;;    (native-inputs (list autoconf automake pkg-config))
;;    (inputs (list guile-3.0))
;;    (synopsis "OpenCL bindings for guile")
;;    (description "guile-ocl is a minimal set of modules that provide
;; access to the OpenCl bindings")
;;    (home-page "https://github.com/koorosh-l/guile-ocl")
;;    (license lgpl3+)))

(define libva-without-mesa
  ;; Delay to work around circular import problem.
  (delay
    (package
     (inherit libva)
     (name "libva-without-mesa")
     (inputs (fold alist-delete (package-inputs libva)
		   '("mesa" "wayland")))
     (arguments
      (strip-keyword-arguments
       '(#:make-flags)
       (substitute-keyword-arguments (package-arguments libva)
				     ((#:configure-flags flags)
				      '(list "--disable-glx"))))))))
(define-public mesa-comp
  (package
   (name "mesa-asahi")
   (version "25.3.6")
   ;;TODO fix source
   (source
    (origin
     (method url-fetch)
     (uri (list (string-append "https://archive.mesa3d.org/"
			       "mesa-" version ".tar.xz")))
     (sha256
      (base64
       "WSF+/qw7ZOfO2VgyS523SU8eB0Gusi14AnZRTMG48gY="))))
   (build-system meson-build-system)
   (propagated-inputs
    (list libdrm
	  libvdpau
	  libx11
	  libxdamage
	  libxfixes
	  libxshmfence
	  libxxf86vm
	  xorgproto))
   (inputs
    (list elfutils
	  expat
	  (force libva-without-mesa)
	  libxml2
	  libxrandr
	  libxvmc
	  llvm-for-mesa
	  vulkan-loader
	  wayland
	  wayland-protocols
	  rust
	  (module-ref (resolve-interface '(gnu packages rust-apps))
		      'rust-bindgen-cli)
	  (module-ref (resolve-interface '(gnu packages rust-apps))
		      'rust-cbindgen-0.26)
	  `(,zstd "lib")))
   (native-inputs
    (append
     (list bison
	   clang-18
	   flex
	   gettext-minimal
	   glslang
	   libclc
	   pkg-config
	   python-mako
	   python-packaging
	   python-ply
	   python-pyyaml
	   python-wrapper
	   (@ (gnu packages base) which))
     (if (target-arm?)
	 (list python-pycparser)
	 '())
     (if (%current-target-system)
	 (list cmake-minimal-cross
	       pkg-config-for-build
	       wayland
	       wayland-protocols)
	 '())
     (if (target-x86-64?)
	 ;; NVK dependencies
	 (list rust
	       (module-ref (resolve-interface '(gnu packages rust-apps))
			   'rust-bindgen-cli)
	       (module-ref (resolve-interface '(gnu packages rust-apps))
			   'rust-cbindgen-0.26))
	 '())))
   (outputs '("out" "bin"))
   (arguments
    (list
     #:configure-flags
     #~(list
	"-Dgallium-drivers=asahi,llvmpipe,virgl"
	"-Dgallium-rusticl=true"
	"-Dplatforms=x11,wayland"
	"-Dglx=dri"
	;; "-Dopencl=true"
	;; "-Domx=true"
	"-Dgles2=enabled"
	"-Dgbm=enabled"
	"-Dshared-glapi=enabled"
	"--wrap-mode=nodownload"
	"-Dvulkan-drivers=asahi"
	"-Dvulkan-layers=device-select,overlay"
	"-Dzstd=enabled"
	"-Dopengl=true"
	"-Dgbm=enabled"
	"-Dglx=dri"
	"-Degl=enabled"
	"-Dmicrosoft-clc=disabled"
	;; "-Dbuild-tests=true"
	;; Re-enable X11 protocol support for the DRI2 extension.
	;; "-Dlegacy-x11=dri2"
	"-Dllvm=enabled")
     #:build-type "release"
     #:modules '((ice-9 match)
		 (srfi srfi-1)
		 (guix build utils)
		 (guix build meson-build-system)
		 (ice-9 textual-ports))
     #:phases
     #~(modify-phases %standard-phases
		      #$@(if (%current-target-system)
			     #~((add-after 'unpack 'fix-cross-compiling
					   (lambda* (#:key native-inputs #:allow-other-keys)
					     ;; When cross compiling, we use cmake to find llvm, not
					     ;; llvm-config, because llvm-config cannot be executed
					     ;; see https://github.com/llvm/llvm-project/issues/58984
					     (substitute* "meson.build"
							  (("method : host_machine\\.system.*")
							   "method : 'cmake',\n"))
					     (setenv "CMAKE"
						     (search-input-file
						      native-inputs "/bin/cmake")))))
			     #~())
		      (add-after 'unpack 'disable-failing-test
				 (lambda _
				   ;; Disable the intel vulkan (anv_state_pool) tests, as they may
				   ;; fail in a nondeterministic fashion (see:
				   ;; https://gitlab.freedesktop.org/mesa/mesa/-/issues/5446).
				   (substitute* "src/intel/vulkan/meson.build"
						(("if with_tests")
						 "if false"))
				   #$@(match (%current-system)
					("aarch64-linux"
					 `((substitute* "src/gallium/drivers/llvmpipe/meson.build"
							(("'lp_test_format', ") ""))))
					("armhf-linux"
					 ;; Disable some of the llvmpipe tests.
					 `((substitute* "src/gallium/drivers/llvmpipe/meson.build"
							(("'lp_test_arit', ") ""))))
					(_
					 '((display "No tests to disable on this architecture.\n"))))))
		      #$@(if (target-x86-64?)
			     #~((add-after 'unpack 'patch-subproject-sources
					   (lambda _
					     ;; Patch each relevant subproject source URL in wrapfiles to
					     ;; use the store, which avoids an attempt to download them
					     ;; mid-build.
					     (for-each
					      (match-lambda
						((name source)
						 (let ((wrap-file (string-append
								   "subprojects/" name ".wrap"))
						       (subproject-dest (string-append
									 "subprojects/" name))
						       (overlay-dir (string-append
								     "subprojects/packagefiles/" name)))
						   (mkdir-p subproject-dest)
						   (invoke "tar" "xf" source "-C" subproject-dest
							   "--strip-components=1")
						   ;; Normally when the patch_directory wrap file property
						   ;; is specified, meson automatically copies from
						   ;; packagefiles, but this is not the case here (only
						   ;; happens when downloading source?) so we manually copy
						   ;; overlay-dir to subproject-dest.
						   (when (file-exists? overlay-dir)
						     (copy-recursively overlay-dir subproject-dest))
						   (call-with-output-file wrap-file
						     (lambda (port)
						       (format port "[wrap-file]
directory = ~a
"
							       name))))))
					      '#+(module-ref (resolve-interface
							      '(gnu packages rust-crates))
							     'mesa-cargo-inputs)))))
			     #~())
		      (add-after 'unpack 'set-home-directory
				 ;; Build tries to use a shader cache (non-fatal error).
				 (lambda _ (setenv "HOME" "/tmp")))
		      (add-before 'configure 'fix-dlopen-libnames
				  (lambda* (#:key inputs #:allow-other-keys)
				    (let ((out #$output))
				      ;; Remain agnostic to .so.X.Y.Z versions while doing
				      ;; the substitutions so we're future-safe.
				      (substitute* "src/glx/meson.build"
						   (("-DGL_LIB_NAME=\"lib@0@\\.so\\.@1@\"")
						    (string-append "-DGL_LIB_NAME=\"" out
								   "/lib/lib@0@.so.@1@\"")))
				      (substitute* "src/gbm/backends/dri/gbm_dri.c"
						   (("\"libglapi\\.so")
						    (string-append "\"" out "/lib/libglapi.so")))
				      (substitute* "src/gbm/main/backend.c"
						   ;; No need to patch the gbm_gallium_drm.so reference;
						   ;; it's never installed since Mesa removed its
						   ;; egl_gallium support.
						   (("\"gbm_dri\\.so")
						    (string-append "\"" out "/lib/dri/gbm_dri.so")))
				      (substitute* "src/gallium/drivers/zink/zink_screen.c"
						   (("util_dl_open\\(VK_LIBNAME\\)")
						    (format #f "util_dl_open(\"~a\")"
							    (search-input-file inputs
									       "lib/libvulkan.so.1")))))))
		      (add-after 'install 'split-outputs
				 (lambda _
				   (let ((out #$output)
					 (bin #$output:bin))
				     ;; Not all architectures have the Vulkan overlay control script.
				     (mkdir-p (string-append out "/bin"))
				     (call-with-output-file (string-append out "/bin/.empty")
				       (const #t))
				     (copy-recursively (string-append out "/bin")
						       (string-append bin "/bin"))
				     (delete-file-recursively (string-append out "/bin")))))
		      (add-after 'install 'symlinks-instead-of-hard-links
				 (lambda _
				   ;; All the drivers and gallium targets create hard links upon
				   ;; installation (search for "hardlink each megadriver instance"
				   ;; in the makefiles).  This is no good for us since we'd produce
				   ;; nars that contain several copies of these files.  Thus, turn
				   ;; them into symlinks, which saves ~124 MiB.
				   (let* ((out    #$output)
					  (lib    (string-append out "/lib"))
					  (files  (find-files lib
							      (lambda (file stat)
								(and (string-contains file ".so")
								     (eq? 'regular
									  (stat:type stat))))))
					  (inodes (map (compose stat:ino stat) files)))
				     (for-each (lambda (inode)
						 (match (filter-map (match-lambda
								      ((file ino)
								       (and (= ino inode) file)))
								    (zip files inodes))
						   ((_)
						    #f)
						   ((reference others ..1)
						    (format #t "creating ~a symlinks to '~a'~%"
							    (length others) reference)
						    (for-each delete-file others)
						    (for-each (lambda (file)
								(if (string=? (dirname file)
									      (dirname reference))
								    (symlink (basename reference)
									     file)
								    (symlink reference file)))
							      others))))
					       (delete-duplicates inodes)))))
		      (add-after 'install 'set-layer-path-in-manifests
				 (lambda _
				   (let* ((out #$output)
					  (implicit-path (string-append
							  out
							  "/share/vulkan/implicit_layer.d/"))
					  (explicit-path (string-append
							  out
							  "/share/vulkan/explicit_layer.d/"))
					  (fix-layer-path
					   (lambda (layer-name)
					     (let* ((explicit (string-append explicit-path layer-name ".json"))
						    (implicit (string-append implicit-path layer-name ".json"))
						    (manifest (if (file-exists? explicit)
								  explicit
								  implicit)))
					       (substitute* manifest
							    (((string-append "\"lib" layer-name ".so\""))
							     (string-append "\"" out "/lib/lib" layer-name ".so\"")))))))
				     (for-each fix-layer-path '("VkLayer_MESA_device_select"
								"VkLayer_MESA_overlay")))))
		      (add-after 'install 'use-absolute-file-name-in-rusticl.icd
				 (lambda _
				   (let* ((out #$output)
					  (rusticl.icd (string-append
							out "/etc/OpenCL/vendors/rusticl.icd"))
					  (old-path (call-with-input-file rusticl.icd
						      get-string-all))
					  (new-path (string-append out "/lib/"
								   (string-trim-both old-path))))
				     (if (file-exists? new-path)
					 (call-with-output-file rusticl.icd
					   (lambda (port) (format port "~a\n" new-path))))))))
     ))
   (native-search-paths
    (list (search-path-specification
	   ;; Ensure the Mesa VDPAU drivers can be found.
	   (variable "VDPAU_DRIVER_PATH")
	   (separator #f)
	   (files '("lib/vdpau")))))
   (home-page "https://mesa3d.org/")
   (synopsis "OpenGL and Vulkan implementations")
   (description "Mesa is a free implementation of the OpenGL and Vulkan
specifications - systems for rendering interactive 3D graphics.  A variety of
device drivers allows Mesa to be used in many different environments ranging
from software emulation to complete hardware acceleration for modern GPUs.")
   (license license:x11)))


(list
 mesa-comp
 gnu-make
 guile-3.0.11
 autoconf
 automake
 sed
 gawk
 pocl
 opencl-icd-loader
 clinfo
 pkg-config
 coreutils
 grep
 opencl-headers
 less
 gcc
 binutils)
mesa-comp
