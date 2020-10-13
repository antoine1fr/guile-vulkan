(define-module (vulkan bindings)
  #:use-module (system foreign)
  #:use-module (ice-9 exceptions)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module ((vulkan structs) #:prefix structs:)
  #:export (handle))

(eval-when (expand)
  (define (handle-type->syntax name)
    (let* ([symbol (string->symbol name)])
      `(define-public ,symbol '*)))

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
            (lambda (x) (k (load-vulkan tail)))
          (lambda ()
            (dynamic-link name)))))]))

(define lib-vk
  (load-vulkan '("libMoltenVK.dylib"
               "libvulkan")))

(define-syntax generate-base-types
  (lambda (stx)
    (syntax-case stx ()
      [(_) (base-types->syntax stx)])))

(define-syntax generate-enum-types
  (lambda (stx)
    (syntax-case stx ()
      [(_) (enum-types->syntax stx)])))

(define-syntax generate-handle-types
  (lambda (stx)
    (syntax-case stx ()
      [(_) (handle-types->syntax stx)])))

;; (define-syntax generate-function-bindings
;;   (lambda (stx)
;;     (syntax-case stx ()
;;       [(_) (functions->syntax stx)])))

(generate-base-types)
(generate-enum-types)
(generate-handle-types)
;; (generate-function-bindings)

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
