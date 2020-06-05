(use-modules (ice-9 match)
	     ((srfi srfi-1) #:select (fold))
	     ((vulkan specs) #:prefix specs:))

(define (type->symbol type)
  (match type
    ["int8_t" 'int8]
    ["int16_t" 'int16]
    ["int32_t" 'int32]
    ["int64_t" 'int64]
    ["uint8_t" 'uint8]
    ["uint16_t" 'uint16]
    ["uint32_t" 'uint32]
    ["uint64_t" 'uint64]
    [_ (string->symbol type)]))

(define (base-type->syntax base-type)
  (let* ([name (string->symbol (specs:base-type-name base-type))]
	 [value (type->symbol (specs:base-type-type base-type))])
    `(define-public ,name ,value)))

(define (base-types->syntax stx)
  (let ([types (map base-type->syntax (specs:base-types))])
    (datum->syntax stx `(begin . ,types))))

(define (enum-value->syntax enum-value accu)
  (let* ([name (string->symbol (specs:enum-value-name enum-value))]
	 [value (specs:enum-value-value enum-value)]
	 [stx `(define-public ,name ,value)])
    (cons stx accu)))

;; (enum-value->syntax (specs:make-enum-value "foo" 42) '())

(define (enum-type->syntax enum-type accu)
  (let* ([name (string->symbol (specs:enum-type-name enum-type))]
	 [enum-values (specs:enum-type-values enum-type)]
	 [stx `(define-public ,name unsigned-int)]
	 [accu (cons stx accu)])
    (fold enum-value->syntax accu enum-values)))

;; (enum-type->syntax (specs:make-enum-type "some-enum"
;; 					 (list (specs:make-enum-value "foo" 0)
;; 					       (specs:make-enum-value "bar" 1)))
;; 		   '())

(define (enum-types->syntax stx)
  (let ([enums (fold enum-type->syntax '() (specs:enum-types))])
    (datum->syntax stx `(begin . ,enums))))

;; (enum-types->syntax #'foo)

(define (struct-type-member->syntax member)
  (match member
    [(name '*) `(',(string->symbol name) '*)]
    [(name type-str) `(',(string->symbol name)
			,(type->symbol type-str))]
    [(name type-str size) `(',(string->symbol name)
			     (bs:vector ,(string->symbol size)
					,(type->symbol type-str)))]))

(define (struct-type->syntax struct-type accu)
  (let* ([name (string->symbol (specs:struct-type-name struct-type))]
	 [members (specs:struct-type-members struct-type)]
	 [stx `(define-public ,name
		 (bs:struct . ,(map struct-type-member->syntax members)))])
    (cons stx accu)))

(struct-type->syntax (specs:make-struct-type "VkPhysicalDeviceIDProperties"
					     '(("sType" "VkStructureType")
					       ("pNext" *)
					       ("deviceUUID" "uint8_t" "VK_UUID_SIZE")
					       ("driverUUID" "uint8_t" "VK_UUID_SIZE")
					       ("deviceLUID" "uint8_t" "VK_LUID_SIZE")
					       ("deviceNodeMask" "uint32_t")
					       ("deviceLUIDValid" "VkBool32")))
		     '())

(define (struct-types->syntax stx)
  (let ([structs (fold struct-type->syntax '() (specs:struct-types))])
    (datum->syntax stx `(begin . ,structs))))
