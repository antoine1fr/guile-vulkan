(define-module (vulkan low-level)
  #:use-module (system foreign)
  #:export (handle))

(define lib-molten-vk
  (dynamic-link "libMoltenVK.dylib"))

(eval-when (expand)
  (use-modules (srfi srfi-1)
	       ((vulkan specs) #:prefix specs:))

  (define (enum-value->syntax enum-value accu)
    (let ([name (specs:enum-value-name enum-value)]
	  [value (specs:enum-value-value enum-value)])
      `((define-public ,(string->symbol name) ,value) . ,accu)))

  (define (enum-type->syntax enum-type accu)
    (let ([enum-values (specs:enum-type-values enum-type)])
      (fold enum-value->syntax accu enum-values)))

  (define (enum-types->syntax stx)
    (let ([enums (fold enum-type->syntax '() (specs:enum-types))])
      (datum->syntax stx (cons 'begin enums)))))

(define-syntax generate-enum-types
  (lambda (stx)
    (syntax-case stx ()
      [(_) (enum-types->syntax stx)])))

(generate-enum-types)

(define-public result int)

;; (define-public handle uint64)
(define-wrapped-pointer-type handle
  handle?
  wrap-handle
  unwrap-handle
  (lambda (handle p)
    (format p "#<vkHandle ~x>" (pointer-address (unwrap-handle handle)))))

(define-public structure-type-instance-create-info 1)
(define-public structure-type int)
(define-public instance-create-flags int)
(define-public instance-create-info
  (list structure-type
	'*
	instance-create-flags
	'*
	uint32
	'*
	uint32
	'*))

(define-public create-instance
  (pointer->procedure result
		      (dynamic-func "vkCreateInstance" lib-molten-vk)
		      (list '* '* '*)))
