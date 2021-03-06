# EL Plano REST API v.1
  
## Basis
  
This API is based on [JSON:API specification](https://jsonapi.org/).
  
Clients MUST send all JSON:API data in request documents with the header `Content-Type: application/vnd.api+json` without any media type parameters.
Otherwise, the server will respond with a `415 Unsupported Media Type` status code  
  
  
### HTTP verbs
  
Where possible, API strives to use appropriate HTTP verbs for each action.
  
| Verb      | Description
| ----------|-------------
| `GET`     | Used for retrieving resources.
| `POST`    | Used for creating resources.
| `PATCH`   | Used for updating resources with partial JSON data. For instance, an Issue resource has title and body attributes. A PATCH request may accept one or more of the attributes to update the resource. PATCH is a relatively new and uncommon HTTP verb, so resource endpoints also accept POST requests.
| `PUT`     | Used for replacing resources or collections. For PUT requests with no body attribute, be sure to set the Content-Length header to zero.
| `DELETE`  | Used for deleting resources.
  
### HTTP status codes
  
The API is designed to return different status codes according to context and action. 
This way, if a request results in an error, the caller is able to get insight into what went wrong.

The following table gives an overview of how the API functions generally behave.
  
| Request type      | Description
|-------------------|---------------------------------------------------------------------------------------------
| `GET`             | Access one or more resources and return the result as JSON.
| `POST`            | Return `201 Created` if the resource is successfully created and return the newly created resource as JSON.
| `GET` / `PUT`     | Return `200 OK` if the resource is accessed or modified successfully. The (modified) result is returned as JSON.
| `DELETE`          | Returns `204 No Content` if the resource was deleted successfully.

&nbsp;

The following table shows the possible return codes for API requests.
  
| Return values             | Description
|---------------------------|-------------------------------------------------------------------------------------------
| `200 OK`                  | The `GET`, `PUT` or `DELETE` request was successful, the resource(s) itself is returned as JSON.
| `201 Created`             | The `POST` request was successful and the resource is returned as JSON.
| `204 No Content`          | The server has successfully fulfilled the request and that there is no additional content to send in the response payload body.
| `304 Not Modified`        | Indicates that the resource has not been modified since the last request.
| `400 Bad Request`         | A required attribute of the API request is missing, e.g., the title of an issue is not given.
| `401 Unauthorized`        | The user is not authenticated, a valid user token is necessary.
| `403 Forbidden`           | The request is not allowed, e.g., the user is not allowed to delete a project.
| `404 Not Found`           | A resource could not be accessed, e.g., an ID for a resource could not be found.
| `415 Unsupported type`    | Indicates that the request has an unsupported type specified in `Content-Type` header.
| `422 Unprocessable`       | The entity could not be processed.
| `429 Too Many Requests`   | Indicates the user has sent too many requests in a given amount of time ("rate limiting").
| `500 Server Error`        | While handling the request something went wrong server-side.

### Errors
 
A server might process multiple attributes and then return multiple validation problems in a single response.

Error objects provide additional information about problems encountered while performing an operation. 
Error objects are returned as an array keyed by errors in the top level of a JSON:API document.

An error object have the following members:

- `status` - The HTTP status code applicable to this problem, expressed as a string value.
- `source` - An object containing references to the source of the error, optionally including any of the following members:
    - `pointer` - A JSON Pointer [RFC6901](https://tools.ietf.org/html/rfc6901) to the associated entity in the request document [e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute].
    - `parameter` - A string indicating which URI query parameter caused the error.
- `detail` - A human-readable explanation specific to this occurrence of the problem.

Response example(model validation):

    {
        "errors": [
            {
                "status": 422,
                "source": {
                    "pointer": "/data/attributes/email"
                },
                "detail": "can't be blank"
            },
            {
                "status": 422,
                "source": {
                    "pointer": "/data/attributes/password"
                },
                "detail": "can't be blank"
            }
        ]
    }

Response example(parameter validation)

    {
        "errors": [
            {
                "status": 400,
                "source": {
                    "parameter": "last_id"
                },
                "detail": "must be an integer"
            }
        ]
    }

### Cross origin resource sharing
The API supports Cross Origin Resource Sharing (CORS) for AJAX requests from any origin. 
You can read the [CORS W3C Recommendation](https://www.w3.org/TR/cors/), or [this intro](https://code.google.com/archive/p/html5security/wikis/CrossOriginRequestSecurity.wiki) from the HTML 5 Security Guide.

Work in progress...

### Localization
The API supports different localizations(English, Espanol, Russian).
Localization can be set via [HTTP headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Language) or obtained from the user's settings(user locale field).

Localization priority:

User locale --> Request locale --> Default locale

### Collections

Collection resources provide access to information about a list of objects of the same type. 
For example, you can use a collection resource to access information about a list of events. 
Collection resources are paged and may be sorted and filtered(depending on availability) - and will always return an list.

<b>NOTE</b> : All collections endpoints available via GET request. 

&nbsp;

#### Filters

Some collections support the ability to filter the results. 
Filtering a collection resource is conducted via the filters parameter using the following notation:


    {
      "filters": {
        "search": "search term",
        "status": "cancelled"
      }
    }

&nbsp;

#### Pagination

Pagination uses filters notation and provides the ability to limit records with cursor-like style.

    {
      "filters": {
        "last_id": 15,
        "limit": 10,
        "direction": "desc",
        "field_name": "email",
        "fiend_value": "wat@email.huh"
      }
    }

<b>NOTE</b> : 

- Default chuck size is equal 15, minimum size is equal 1 and maximum size is equal 100.
- Filters should be url encoded and passed as optional query parameters.

<b>EXAMPLE</b> : 

<code>?filters=%7B%22last_id%22%3A1%2C%22direction%22%3A%22asc%22%7D</code>

To perform page based pagination filters must contains page parameter

    {
      "filters": {
        "page": 2,
        "limit": 10
      }
    }

<b>EXAMPLE</b> :

<code>?filters=%7B%22page%22%3A2%2C%22limit%22%3A10%7D</code>

In the case of page-based pagination additional pagination metadata is provided:

    {
      "meta": {
        "current_page": 2,
        "total_pages": 3
      },
      "links": {
        "self": "https://api.elplano.app/api/v1/users?limit=1&page=2",
        "first": "https://api.elplano.app/api/v1/users?limit=1&page=1",
        "prev": "https://api.elplano.app/api/v1/users?limit=1&page=1",
        "next": "https://api.elplano.app/api/v1/users?limit=1&page=3",
        "last": "https://api.elplano.app/api/v1/users?limit=1&page=3"
      }
    }

## Authentication

API authentication is based on [OAuth 2.0 specification](https://tools.ietf.org/html/rfc6749)
You can use an OAuth2 token to authenticate with the API by passing it in the Authorization header.
  
#### `POST /oauth/token`

Post here with login and password for password grant type, or refresh token for refresh token type.

&nbsp;

#### ACCESS TOKEN

Body: 

    {
      "grant_type":"password",
      "login":"user@example.com",
      "password":"doorkeeper"
    }

Response :

    {
      "access_token": "c94f702057a6c0bd6fe9bb90f1bfd782358bfad2983fb88c8dd93e6e7b841cd6",
      "token_type": "Bearer",
      "expires_in": 3600,
      "refresh_token": "d42ece80c67ad32101aa530cf49147581a357160d6a8a3cb575d2154edef50a1",
      "created_at": 1553776199
    }

&nbsp;

#### REFRESH TOKEN

Body:

    {
      "grant_type":"refresh_token",
      "refresh_token":"49aff0c25d295196656006c2f9400640b742abfc37e468d98a0c86786f53e4e5"
    }

Response:

    {
      "access_token": "2f82b5d9f02a1790c13842e6a53c244b07d7370cd09231a679ed56dafb81d615",
      "token_type": "Bearer",
      "expires_in": 3600,
      "refresh_token": "bf9ad57f8a90442849338b4501d8ab4b11822e5c13944e9bdcba0d9b7dab1d26",
      "created_at": 1553666769,
    }

&nbsp;

#### `POST /oauth/revoke`

Post here with client credentials (in basic auth or in params client_id and client_secret) to revoke an access/refresh token. 
This corresponds to the token endpoint, using the OAuth 2.0 Token Revocation RFC (RFC 7009).

&nbsp;

#### REVOKE ACCESS

Body:

    {
        "token":"49aff0c25d295196656006c2f9400640b742abfc37e468d98a0c86786f53e4e5"
    }

Response:

    {}
