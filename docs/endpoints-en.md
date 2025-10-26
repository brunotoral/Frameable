
# API Endpoints Documentation

This document provides a simple and clear explanation of each endpoint defined in the API.

## `/circles`

### GET

**Summary:** List and filter circles

**Parameters:**

- `center_x` (query, string) - Optional - Center X coordinate for the search radius
- `center_y` (query, string) - Optional - Center Y coordinate for the search radius
- `radius` (query, string) - Optional - Radius for the search area
- `frame_id` (query, string) - Optional - Optional frame ID to filter circles

**Responses:**

- **200**: ok

---

## `/circles/{id}`

### PUT

**Summary:** Update Circle

**Parameters:**

- `id` (path, integer) - Required -

**Responses:**

- **200**: ok
- **422**: unprocessable entity
- **404**: Not Found

---

### DELETE

**Summary:** Delete Circle

**Parameters:**

- `id` (path, integer) - Required -

**Responses:**

- **204**: No Content
- **404**: Not Found

---

## `/frames/{frame_id}/circles`

### POST

**Summary:** create circle

**Parameters:**

- `frame_id` (path, integer) - Required -

**Responses:**

- **201**: creted
- **422**: unprocessable entity

---

## `/frames`

### GET

**Summary:** list frames


**Responses:**

- **200**: ok

---

### POST

**Summary:** create frame


**Responses:**

- **201**: created
- **422**: unprocessable entity

---

## `/frames/{id}`

### GET

**Summary:** show frame

**Parameters:**

- `id` (path, integer) - Required -

**Responses:**

- **200**: ok
- **404**: not found

---

### PUT

**Summary:** update frame

**Parameters:**

- `id` (path, integer) - Required -

**Responses:**

- **200**: ok

---

### DELETE

**Summary:** delete frame

**Parameters:**

- `id` (path, integer) - Required -

**Responses:**

- **204**: No Content
- **409**: Conflict
- **404**: Not Found

---
