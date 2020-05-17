(use-modules (system foreign)
	     (rnrs bytevectors)
	     ((vulkan) #:prefix vk:)
	     ((vulkan low-level) #:prefix ffi:))

(define instance-create-info
  (make-c-struct ffi:instance-create-info
		 (list ffi:structure-type-instance-create-info
		       %null-pointer
		       0
		       %null-pointer
		       0
		       %null-pointer
		       0
		       %null-pointer)))

(define instance-handle
  (vk:create-instance instance-create-info))

;; (define vk-instances
;;   (make-bytevector (* 8 2)))
;; (bytevector-fill! vk-instances 0)
;; (bytevector-u64-ref vk-instances 0 (native-endianness))
;; (bytevector-u64-ref vk-instances 1 (native-endianness))

;; ;; test code
;; (define result
;;   (vk:create-instance instance-create-info
;; 		      %null-pointer
;; 		      (bytevector->pointer vk-instances)))
;; (define result2
;;   (vk:create-instance instance-create-info
;; 		      %null-pointer
;; 		      (bytevector->pointer vk-instances 8)))
