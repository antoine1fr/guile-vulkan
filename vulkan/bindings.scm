(define-module (vulkan bindings)
  #:use-module (system foreign)
  #:use-module (ice-9 exceptions)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:export (handle))

(eval-when (expand)
  (include-from-path "vulkan/syntax.scm"))

(define (load-vulkan names)
  (match names
    [()
     (let* ([error (make-external-error)]
            [message (make-exception-with-message "can't find vulkan")]
            [exception (make-exception error message)])
       (raise-exception exception))]
    [(name . tail)
     (call/cc
      (lambda (k)
        (with-exception-handler
            (lambda (x) (k (try-dynamic-link tail)))
          (lambda ()
            (dynamic-link name)))))]))

(load-vulkan '("libMoltenVK.dylib"
               "libvulkan"))

(define lib-molten-vk
  (dynamic-link "libMoltenVK.dylib"))

(define-syntax generate-enum-types
  (lambda (stx)
    (syntax-case stx ()
      [(_) (enum-types->syntax stx)])))

(generate-enum-types)

;; (define-public result int)

;; (define-public handle uint64)
;; (define-wrapped-pointer-type handle
;;   handle?
;;   wrap-handle
;;   unwrap-handle
;;   (lambda (handle p)
;;     (format p "#<vkHandle ~x>" (pointer-address (unwrap-handle handle)))))

;; (define-public structure-type-instance-create-info 1)
;; (define-public structure-type int)
;; (define-public instance-create-flags int)
;; (define-public instance-create-info
;;   (list structure-type
;; 	'*
;; 	instance-create-flags
;; 	'*
;; 	uint32
;; 	'*
;; 	uint32
;; 	'*))

;; (define-public create-instance
;;   (pointer->procedure result
;; 		      (dynamic-func "vkCreateInstance" lib-molten-vk)
;; 		      (list '* '* '*)))
