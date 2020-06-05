(use-modules (ice-9 format)
	     (rnrs bytevectors)
	     (bytestructures guile)
	     ((vulkan bindings) #:prefix bindings:)
	     ((vulkan structs) #:prefix structs:))

(format #t "VK_BLEND_FACTOR_ZERO = ~a\n" bindings:VK_BLEND_FACTOR_DST_ALPHA)
(format #t "VkFormat = ~a\n" bindings:VkFormat)
(format #t "VkAabbPositionsKHR = ~a\n" structs:VkAabbPositionsKHR)
(define bs (bytestructure structs:VkAabbPositionsKHR))

;; (define instance-create-info
;;   (make-c-struct ffi:instance-create-info
;; 		 (list ffi:structure-type-instance-create-info
;; 		       %null-pointer
;; 		       0
;; 		       %null-pointer
;; 		       0
;; 		       %null-pointer
;; 		       0
;; 		       %null-pointer)))

;; (define instance-handle
;;   (vk:create-instance instance-create-info))

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
