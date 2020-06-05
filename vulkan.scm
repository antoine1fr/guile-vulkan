(define-module (vulkan)
  #:use-module (system foreign)
  #:use-module (rnrs bytevectors))

(define-public create-instance
  (let ([instance (make-bytevector 8)])
    (lambda (instance-create-info)
      (ffi:create-instance instance-create-info
			  %null-pointer
			  (bytevector->pointer instance))
      (bytevector-u64-ref instance 0 (native-endianness)))))

