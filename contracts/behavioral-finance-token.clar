;; Import the fungible token trait
(impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sip-010-trait.sip-010-trait)

;; Define token
(define-fungible-token behavioral-finance-token)

;; Token Metadata
(define-constant token-name "Behavioral Finance Token")
(define-constant token-symbol "BFT")
(define-constant token-decimals u6)

;; Token Supply Tracking
(define-data-var total-supply uint u0)

;; SIP-010 Required Functions

;; Transfer
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err u1))
    (try! (ft-transfer? behavioral-finance-token amount sender recipient))
    (match memo 
      some-memo (begin
                  (print some-memo)
                  (ok true))
      (ok true))))

;; Get Token Name
(define-read-only (get-name)
  (ok token-name))

;; Get Token Symbol
(define-read-only (get-symbol)
  (ok token-symbol))

;; Get Token Decimals
(define-read-only (get-decimals)
  (ok token-decimals))

;; Get Token URI
(define-read-only (get-token-uri)
  (ok none))

;; Get Total Supply
(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

;; Get Balance
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance behavioral-finance-token owner)))