# Task Manager Smart Contract

This smart contract, written in Clarity 2.0, enables users to manage personal to-do tasks directly on the blockchain. It ensures task uniqueness per user, supports error handling for invalid actions, and provides a decentralized approach to task management.

---

## Features

### Core Functionalities:
- **Create Task:** Add a new to-do task.
- **Update Task:** Modify an existing task's title and/or completion status.
- **Delete Task:** Remove a task from the blockchain.
- **Retrieve Task Details:** Access information about a specific task.

### Read-Only Operations:
- Check task status (e.g., completed, active, or pending).
- Retrieve all tasks for a user.
- Get task metadata (e.g., title length, completion percentage).
- Verify task existence.

---

## Data Structures

### Tasks Map
Stores tasks keyed by the user's principal (address):
```clarity
(define-map tasks
    principal
    {
        title: (string-ascii 100),
        completed: bool
    }
)
```

### Error Constants
Defines errors for specific invalid operations:
- `ERR-NOT-FOUND (err u404)`: Task not found.
- `ERR-ALREADY-EXISTS (err u409)`: Task already exists.
- `ERR-INVALID-TITLE (err u400)`: Invalid task title.

---

## Public Functions

### 1. `create-task (title (string-ascii 100))`
Creates a new task with the specified title. The task is marked as incomplete by default.
- **Errors:**  
  - `ERR-ALREADY-EXISTS`: Task already exists.
  - `ERR-INVALID-TITLE`: Title is empty.

### 2. `update-task (title (string-ascii 100)) (completed bool)`
Updates the title and/or completion status of an existing task.
- **Errors:**  
  - `ERR-NOT-FOUND`: Task not found.
  - `ERR-INVALID-TITLE`: Title is empty or status is invalid.

### 3. `delete-task ()`
Deletes the caller's task.
- **Errors:**  
  - `ERR-NOT-FOUND`: Task not found.

---

## Read-Only Functions

### Task Information
- **`get-task (user principal)`**: Returns the task object (title and status).
- **`get-task-title (user principal)`**: Retrieves the task title.
- **`get-task-status (user principal)`**: Retrieves the task's completion status.
- **`get-task-info (user principal)`**: Returns the task's title and completion status.

### Task Existence and Count
- **`does-task-exist (user principal)`**: Checks if a task exists for the user.
- **`get-task-count (user principal)`**: Returns `1` if a task exists, `0` otherwise.

### Task Status
- **`is-task-completed (user principal)`**: Checks if the task is completed.
- **`is-task-active (user principal)`**: Checks if the task is active (not completed).
- **`is-task-pending (user principal)`**: Checks if the task is pending (not completed).

### Advanced Metadata
- **`get-task-title-length (user principal)`**: Retrieves the length of the task title.
- **`get-task-completion-percentage (user principal)`**: Returns `100%` if completed, `0%` otherwise.

---

## Error Handling

The contract ensures robust error handling:
- Tasks must be unique for each user.
- Titles cannot be empty.
- Task actions (update/delete) require task existence.

---

## Example Usage

### Creating a Task
```clarity
(create-task (title "Write Smart Contract"))
```

### Updating a Task
```clarity
(update-task (title "Finalize Smart Contract") (completed true))
```

### Deleting a Task
```clarity
(delete-task)
```

### Retrieving Task Details
```clarity
(get-task tx-sender)
```

---

## Benefits
- **Decentralized:** Tasks are stored on the blockchain, ensuring data transparency and immutability.
- **Error-Proof:** Provides detailed error handling for invalid inputs and operations.
- **User-Friendly:** Offers clear task management operations.

---

## Development Notes

### Requirements
- **Clarity Version:** 2.0
- **Blockchain Environment:** Stacks

### Deployment
To deploy the contract, ensure compatibility with the Stacks network and follow standard deployment practices.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
```