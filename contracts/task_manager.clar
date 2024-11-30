;; Task Manager Smart Contract
;; This contract enables users to create, update, and retrieve their personal to-do tasks on the blockchain.

;; Define a map to store tasks, keyed by the user's principal (address).
;; Each task contains a title (string) and a completed status (boolean).
(define-map tasks
    principal
    {
        title: (string-ascii 100),
        completed: bool
    }
)

;; Define custom error constants to handle specific error conditions
(define-constant ERR-NOT-FOUND (err u404))  ;; Task not found error
(define-constant ERR-ALREADY-EXISTS (err u409))  ;; Task already exists error
(define-constant ERR-INVALID-TITLE (err u400))  ;; Invalid task title error

;; Public function to create a new task for the caller (user).
;; This function takes a title for the task as input and stores it in the task map.
(define-public (create-task 
    (title (string-ascii 100)))
    (let
        (
            ;; Get the caller's address (principal)
            (caller tx-sender)
            ;; Check if a task already exists for this caller
            (existing-task (map-get? tasks caller))
        )
        ;; Ensure the task does not already exist for this caller
        (if (is-none existing-task)
            (begin
                ;; Validate the title input, ensuring it is not empty
                (if (is-eq title "")
                    (err ERR-INVALID-TITLE)  ;; Error if the title is empty
                    (begin
                        ;; Store the new task with an initial "completed" status of false
                        (map-set tasks caller
                            {
                                title: title,
                                completed: false
                            }
                        )
                        ;; Return a success message
                        (ok "Task created successfully.")
                    )
                )
            )
            ;; Return an error if the task already exists
            (err ERR-ALREADY-EXISTS)
        )
    )
)
