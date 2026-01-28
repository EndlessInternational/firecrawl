# Get Extract Status (v2)

Retrieves the status of an extract job and (when completed) the extracted data.

## HTTP request

- **Method:** `GET`
- **Path:** `/v2/extract/{id}`
- **Auth:** `Authorization: Bearer <API_KEY>`

## Path params
- `id` (uuid): extract job id returned by `POST /v2/extract`

## Response

Key fields:

- `success` (boolean): whether the request succeeded
- `status`: `processing` | `completed` | `failed` | `cancelled`
- `expiresAt` (datetime): when the extract data expires
- `tokensUsed` (integer): number of tokens used (only available when completed)
- `data` (object): the extracted structured data
- `sources` (array): sources used for extraction (if `showSources` was true)
  - `url` (string): source URL
  - `title` (string): source page title

## Errors
- `402` payment required
- `429` rate limit exceeded
- `500` server error
