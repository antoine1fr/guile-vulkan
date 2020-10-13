(define-module (vulkan specs)
  #:use-module (ice-9 match)
  #:use-module ((srfi srfi-1) #:select (map))
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-64)
  #:use-module (sxml ssax)
  #:use-module (sxml xpath)
  #:use-module (system foreign)
  #:export (make-enum-value
	    enum-value-name
	    enum-value-value

	    make-base-type
	    base-type-name
	    base-type-type

	    make-enum-type
	    enum-type-name
	    enum-type-values

	    make-struct-type
	    struct-type-name
	    struct-type-members

	    base-types
	    enum-types
	    struct-types
      handle-types))

(test-begin "vulkan specs")

(define specs
  (let ([port (open-input-file "/home/antoine/repos/guile-vulkan/vk.xml")])
    (ssax:xml->sxml port '())))

(define-record-type <base-type>
  (make-base-type name type)
  base-type?
  (name base-type-name)
  (type base-type-type))

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

(define-record-type <struct-type>
  (make-struct-type name members)
  struct-type?
  (name struct-type-name)
  (members struct-type-members))

(define (get-base-types specs)
  (let* ([path (node-join (sxpath '(// (type (@ (equal? (category "basetype"))))))
			  (node-self (sxpath '((type)))))]
	 [nodeset (path specs)]
	 [names ((sxpath '(name *text*)) nodeset)]
	 [types ((sxpath '(type *text*)) nodeset)])
    (map make-base-type names types)))

(test-equal (list (make-base-type "foo" "int64")
		  (make-base-type "bar" "uint32"))
  (get-base-types '(*TOP* (type (@ (category "basetype"))
				(type "int64")
				(name "foo"))
			  (type (@ (category "basetype"))
				(type "uint32")
				(name "bar"))
			  (type (type "int32")
				(name "baz")))))

(define (base-types) (get-base-types specs))

;; (base-types)

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

(define (filter-pointers nodeset)
  ((filter pointer?) ((sxpath '(// type))) nodeset))

(define (pointer? nodeset)
  (let* ([pred? (lambda (nodeset)
		  (and (string? nodeset)
		       (eqv? (string-ref nodeset 0) #\*)))]
	 [l ((filter pred?) ((sxpath '(*text*))
			     nodeset))])
    (not (null? l))))

(test-equal #t (pointer? '(member (type "float") "* " "foo")))
(test-equal #f (pointer? '(member (type "float") "foo")))

(define (array? nodeset)
  (let ([nodeset ((sxpath '((equal? "["))) nodeset)])
    (< 0 (length nodeset))))

(test-equal #t (array? '(member (type "float")
				(name "foo")
				"[" (enum "FOO") "]")))
(test-equal #f (array? '(member (type "float") "* " "foo")))
(test-equal #f (array? '(member (type "float") "foo")))

(define (node->struct-member node)
  (let ([name (car ((sxpath '(name *text*)) node))]
	[type (car ((sxpath '(type *text*)) node))])
    (cond
     [(pointer? node) (list name '*)]
     [(array? (list name node))
      (let ([size (car ((sxpath '(enum *text*)) node))])
	(list name type size))]
     [else (list name type)])))

(test-equal '("foo" *)
  (node->struct-member '(member (name "foo")
				(type "float")
				"* ")))
(test-equal '("foo" "float")
  (node->struct-member '(member (name "foo")
				(type "float"))))
(test-equal '("deviceUUID" "uint8_t" "VK_UUID_SIZE")
  (node->struct-member '(member (type "uint8_t")
				(name "deviceUUID")
				"[" (enum "VK_UUID_SIZE") "]")))

(define (struct-node->members node)
  (let ([member-nodes ((sxpath '(// member)) node)])
    (map node->struct-member member-nodes)))

(test-equal
  '(("sType" "VkStructureType")
    ("pNext" *)
    ("deviceUUID" "uint8_t" "VK_UUID_SIZE")
    ("deviceNodeMask" "uint32_t")
    ("deviceLUIDValid" "VkBool32"))
  (struct-node->members '(type (member (type "VkStructureType")
				       (name "sType"))
			       (member (type "void")
				       "*                            "
				       (name "pNext"))
			       (member (type "uint8_t")
				       (name "deviceUUID")
				       "[" (enum "VK_UUID_SIZE") "]")
			       (member (type "uint32_t")
				       (name "deviceNodeMask"))
			       (member (type "VkBool32")
				       (name "deviceLUIDValid")))))

(test-equal '(("foo" "float")
	      ("bar" *))
  (struct-node->members '(type (@ (category "struct"))
			       (member (name "foo") (type "float"))
			       (member (name "bar") (type "char") "* "))))

(define (node->struct-type node)
  (let ([name (cadar ((sxpath '(// @ name)) node))]
	[members (struct-node->members node)])
    (make-struct-type name members)))

(test-equal (make-struct-type "VkPhysicalDeviceIDProperties"
			      '(("sType" "VkStructureType")
				("pNext" *)
				("deviceUUID" "uint8_t" "VK_UUID_SIZE")
				("driverUUID" "uint8_t" "VK_UUID_SIZE")
				("deviceLUID" "uint8_t" "VK_LUID_SIZE")
				("deviceNodeMask" "uint32_t")
				("deviceLUIDValid" "VkBool32")))
  (node->struct-type '(type (@ (structextends "VkPhysicalDeviceProperties2")
			       (returnedonly "true")
			       (name "VkPhysicalDeviceIDProperties")
			       (category "struct"))
			    (member (type "VkStructureType")
				    (name "sType"))
			    (member (type "void")
				    "*                            "
				    (name "pNext"))
			    (member (type "uint8_t")
				    (name "deviceUUID")
				    "[" (enum "VK_UUID_SIZE") "]")
			    (member (type "uint8_t")
				    (name "driverUUID")
				    "[" (enum "VK_UUID_SIZE") "]")
			    (member (type "uint8_t")
				    (name "deviceLUID")
				    "[" (enum "VK_LUID_SIZE") "]")
			    (member (type "uint32_t")
				    (name "deviceNodeMask"))
			    (member (type "VkBool32")
				    (name "deviceLUIDValid")))))

(define (struct-types)
  (let* ([nodes ((sxpath '(// (type (@ (equal? (category "struct")))))) specs)])
    (map node->struct-type nodes)))

(define (handle-types)
  ((sxpath '(//
             (type (@ (equal? (category "handle"))))
             name
             *text*)) specs))

;; (define commands ((sxpath '(// command)) specs))

;; ((sxpath '(// proto name *text*)) (car commands))

;; (define (node->command command)
;;   (let* ([name (car ((sxpath '(// proto name *text*)) command))]))

;; (map node->command commands))

(test-end "vulkan specs")
