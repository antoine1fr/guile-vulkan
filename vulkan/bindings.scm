(define-module (vulkan bindings)
  #:use-module (system foreign)
  #:export (handle))

(eval-when (expand)
  (include-from-path "vulkan/syntax.scm"))

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
