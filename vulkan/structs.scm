(define-module (vulkan structs)
  #:use-module (bytestructures guile))

(eval-when (expand)
  (include-from-path "vulkan/syntax.scm"))

(define-syntax generate-base-types
  (lambda (stx)
    (syntax-case stx ()
      [(_) (base-types->syntax stx)])))

(define-syntax generate-enum-types
  (lambda (stx)
    (syntax-case stx ()
      [(_) (enum-types->syntax stx)])))

(define-syntax generate-struct-types
  (lambda (stx)
    (syntax-case stx ()
      [(_) (struct-types->syntax stx)])))

(generate-base-types)
(generate-enum-types)
(generate-struct-types)
