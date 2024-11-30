;; Task Manager Smart Contract
;; This contract enables users to create, update, and retrieve their personal to-do tasks on the blockchain.
;; Each task consists of a title (string) and a completion status (boolean). 
;; It ensures that tasks are unique for each user and provides error handling for invalid inputs or actions.
;; The contract supports the following operations:
;; - Creating a new task
;; - Updating an existing task (including marking it as completed)
;; - Retrieving task details and completion status
;; Error handling is implemented for scenarios such as missing tasks, duplicate tasks, and invalid input.

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

;; Public function to update an existing task for the caller.
;; This function allows the caller to modify the title and/or completion status of an existing task.
(define-public (update-task
    (title (string-ascii 100))
    (completed bool))
    (let
        (
            ;; Get the caller's address (principal)
            (caller tx-sender)
            ;; Retrieve the existing task for the caller
            (existing-task (map-get? tasks caller))
        )
        ;; Ensure the task exists before attempting to update it
        (if (is-some existing-task)
            (begin
                ;; Validate the title input, ensuring it is not empty
                (if (is-eq title "")
                    (err ERR-INVALID-TITLE)  ;; Error if the title is empty
                    (begin
                        ;; Ensure the "completed" status is a valid boolean
                        (if (or (is-eq completed true) (is-eq completed false))
                            (begin
                                ;; Update the task with the new title and completion status
                                (map-set tasks caller
                                    {
                                        title: title,
                                        completed: completed
                                    }
                                )
                                ;; Return a success message
                                (ok "Task updated successfully.")
                            )
                            ;; Error if the "completed" value is not valid
                            (err ERR-INVALID-TITLE)
                        )
                    )
                )
            )
            ;; Return an error if the task is not found
            (err ERR-NOT-FOUND)
        )
    )
)

;; Public function to delete the task for the caller (user).
;; This function deletes the task if it exists for the user.
(define-public (delete-task)
    (let
        (
            ;; Get the caller's address (principal)
            (caller tx-sender)
            ;; Retrieve the existing task for the caller
            (existing-task (map-get? tasks caller))
        )
        ;; Ensure the task exists before attempting to delete it
        (if (is-some existing-task)
            (begin
                ;; Delete the task from the map
                (map-delete tasks caller)
                ;; Return a success message
                (ok "Task deleted successfully.")
            )
            ;; Return an error if the task is not found
            (err ERR-NOT-FOUND)
        )
    )
)

;; Read-only function to get the completion status of a task for a given user.
;; This function returns the "completed" status of the task if found.
(define-read-only (get-task-status (user principal))
    (match (map-get? tasks user)
        task (ok (get completed task))  ;; Return the completion status if the task exists
        ERR-NOT-FOUND  ;; Return an error if the task is not found
    )
)

;; Read-only function to retrieve the task title for a given user.
;; This function returns the title of the task if found.
(define-read-only (get-task-title (user principal))
    (match (map-get? tasks user)
        task (ok (get title task))  ;; Return the title of the task if found
        ERR-NOT-FOUND  ;; Return an error if no task is found
    )
)

;; Read-only function to check if the task is completed for a given user.
;; This function returns true if the task is completed, false otherwise.
(define-read-only (is-task-completed (user principal))
    (match (map-get? tasks user)
        task (ok (get completed task))  ;; Return the completion status if the task exists
        ERR-NOT-FOUND  ;; Return an error if the task is not found
    )
)

;; Read-only function to retrieve both the title and completion status of a task for a given user.
;; This function returns an object containing the task's title and completion status if found.
(define-read-only (get-task-info (user principal))
    (match (map-get? tasks user)
        task (ok {
            title: (get title task),
            completed: (get completed task)
        })  ;; Return both the title and completion status if the task exists
        ERR-NOT-FOUND  ;; Return an error if no task is found
    )
)

;; Read-only function to check if a task exists for a given user.
;; This function returns true if the task exists, otherwise false.
(define-read-only (does-task-exist (user principal))
    (match (map-get? tasks user)
        task (ok true)  ;; Return true if the task exists
        (ok false)     ;; Return false if no task is found
    )
)

;; Read-only function to check if the task is still active (not completed) for a given user.
;; This function returns true if the task is active, false if completed.
(define-read-only (is-task-active (user principal))
    (match (map-get? tasks user)
        task (ok (not (get completed task)))  ;; Return true if task is not completed
        ERR-NOT-FOUND  ;; Return an error if the task is not found
    )
)

;; Read-only function to retrieve all tasks for a given user.
;; This function returns the title and completion status of the task for the user.
(define-read-only (get-all-tasks (user principal))
    (match (map-get? tasks user)
        task (ok {
            title: (get title task),
            completed: (get completed task)
        })
        ERR-NOT-FOUND
    )
)

;; Read-only function to count tasks for a given user.
;; It will return 1 if a task exists, otherwise 0.
(define-read-only (get-task-count (user principal))
    (match (map-get? tasks user)
        task (ok 1)   ;; Return 1 if the task exists
        (ok 0)        ;; Return 0 if no task exists
    )
)
