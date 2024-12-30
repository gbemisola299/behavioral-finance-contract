;; Import the fungible token trait (SIP-010 standard)
(impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sip-010-trait.sip-010-trait)

;; Define token
(define-fungible-token behavioral-finance-token)

;; Fungible Token Metadata
(define-constant token-name "Behavioral Finance Token")
(define-constant token-symbol "BFT")
(define-constant token-decimals u6)

;; Admin variable
(define-data-var admin principal tx-sender)

;; Reward and Penalty Rates
(define-data-var reward-rate uint u10)
(define-data-var penalty-rate uint u5)

;; User Goal Structure
(define-map user-goals
  { user: principal, goal-id: uint }
  { goal-type: (string-ascii 50), 
    target-amount: uint, 
    progress: uint, 
    achieved: bool, 
    deadline: uint })

;; User Goal Counters
(define-map user-goal-counter
  { user: principal }
  { next-id: uint })

;; Token Supply Tracking
(define-data-var total-supply uint u0)

;; SIP-010 Required Functions

;; Transfer
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err u1)) ;; Sender must be the transaction sender
    (asserts! (> amount u0) (err u2)) ;; Amount must be positive
    (asserts! (not (is-eq sender recipient)) (err u3)) ;; Cannot transfer to self
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

;; Mint Reward Tokens (Private)
(define-private (mint-reward (user principal))
  (let ((amount (var-get reward-rate)))
    (var-set total-supply (+ (var-get total-supply) amount))
    (ft-mint? behavioral-finance-token amount user)))

;; Public Functions

;; Set a Financial Goal
(define-public (set-goal (goal-type (string-ascii 50)) (target-amount uint) (deadline uint))
  (begin
    (asserts! (not (is-eq goal-type "")) (err u399)) ;; Goal type cannot be empty
    (asserts! (> target-amount u0) (err u400)) ;; Target must be positive
    (asserts! (>= deadline block-height) (err u401)) ;; Deadline must be in the future
    (asserts! (<= deadline (+ block-height u52560)) (err u402)) ;; Deadline must be within 1 year
    (let ((user-counter (default-to { next-id: u0 } (map-get? user-goal-counter { user: tx-sender })))
          (goal-id (get next-id user-counter)))
      ;; Update goal counter
      (map-set user-goal-counter { user: tx-sender } { next-id: (+ goal-id u1) })
      ;; Add new goal
      (map-set user-goals
        { user: tx-sender, goal-id: goal-id }
        { goal-type: goal-type, 
          target-amount: target-amount, 
          progress: u0, 
          achieved: false, 
          deadline: deadline })
      (ok { goal-id: goal-id }))))

;; Update Goal Progress
(define-public (update-progress (goal-id uint) (amount uint))
  (let ((goal (map-get? user-goals { user: tx-sender, goal-id: goal-id })))
    (match goal 
      goal-data (let ((current-progress (get progress goal-data))
                     (target-amount (get target-amount goal-data))
                     (deadline (get deadline goal-data)))
                  (asserts! (<= block-height deadline) (err u402)) ;; Deadline passed
                  (asserts! (not (get achieved goal-data)) (err u403)) ;; Goal already achieved
                  (let ((new-progress (+ current-progress amount)))
                    (map-set user-goals
                      { user: tx-sender, goal-id: goal-id }
                      { goal-type: (get goal-type goal-data),
                        target-amount: target-amount,
                        progress: new-progress,
                        achieved: (>= new-progress target-amount),
                        deadline: deadline })
                    ;; Reward on achieving goal
                    (if (>= new-progress target-amount)
                      (begin
                        (try! (mint-reward tx-sender))
                        (ok true))
                      (ok true))))
      (err u404)))) ;; Goal not found

;; Apply Penalty for Missed Deadlines
(define-public (apply-penalty (goal-id uint))
  (let ((goal (map-get? user-goals { user: tx-sender, goal-id: goal-id })))
    (match goal 
      goal-data (let ((deadline (get deadline goal-data))
                     (achieved (get achieved goal-data)))
                  (asserts! (not achieved) (err u403)) ;; Goal achieved
                  (asserts! (> block-height deadline) (err u401)) ;; Deadline not passed
                  (let ((penalty-amount (var-get penalty-rate)))
                    (try! (transfer penalty-amount tx-sender (var-get admin) none))
                    (map-delete user-goals { user: tx-sender, goal-id: goal-id })
                    (ok { penalty-applied: penalty-amount })))
      (err u404)))) ;; Goal not found