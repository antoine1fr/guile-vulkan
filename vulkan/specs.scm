(define-module (vulkan specs)
  #:use-module (srfi srfi-9)
  #:use-module (sxml ssax)
  #:use-module (sxml xpath)
  #:export (make-enum-value
	    enum-value-name
	    enum-value-value

	    make-enum-value
	    enum-type-name
	    enum-type-values

	    enum-types))

(define specs
  (let ([port (open-input-file "/Users/cuicui/Downloads/vk.xml")])
    (ssax:xml->sxml port '())))

(define-record-type <enum-value>
  (make-enum-value name value)
  enum-value?
  (name enum-value-name)
  (value enum-value-value))

(define-record-type <enum-type>
  (make-enum-type name values)
  enum-type?
  (name enum-type-name)
  (values enum-type-values))

(define (node->enum-value node)
  (let* ([name (cadar ((sxpath '(// @ name)) node))]
	 [value-string (cadar ((sxpath '(// @ value)) node))]
	 [value (string->number value-string)])
    (make-enum-value name value)))

(define (node->enum-type node)
  (let* ([name (cadar ((sxpath '(// @ name)) node))]
	 [value-nodes ((sxpath '(// (enum (@ value)))) node)]
	 [values (map node->enum-value value-nodes)])
    (make-enum-type name values)))

(define (enum-types)
  (let* ([nodes ((sxpath '(// enums)) specs)])
    (map node->enum-type nodes)))
