# new CUI.XHR\(Options\)

CUI.XHR is a wrapper around XMLHttpRequest and can be used for Ajax-Callbacks, as well as for loading files from and uploading files to a server.

## Options

### method

The **method** used for the Request. This needs to be one of _GET_, _POST_, _PUT_, _DELETE_, or _OPTIONS_.

### url

The **url** used for the Request.

### user

Optionally, a **user** can be given. This is used for Basic HTTP Authentication.

### password

Optionally, a **password** can be given. This is used for Basic HTTP Authentication.

### responseType

The expected type of the response. Accepted are _""_, _text_, _json_, _blob_, _arraybuffer_. Defaults to _json_.

### timeout

**timeout** is passed to the XMLHttpRequest, and is given in **ms**.

### form

**form** is a PlainObject. new FormData\(\) is used to build the body of the request.

### url\_data

**url\_data** is a PlainObject. It can be used to pass parameters to be appended to the **url**.

### body

**body** can be any data used as body for the request.

### json\_data

**json\_data** is a PlainObject which JSON.stringified to be sent in the request body.

### json\_pretty

**json\_pretty** is a Boolean which can be used to pretty print the JSON sent to the server if given by **json\_data**.

### headers

**headers** is a PlainObject which can be used to set HTTP-Headers for the Request.

### withCredentials

If set to _true_, the request is done with sending credentials. That usually means that Cookies are sent for Ajax-Requests.

## abort\(\)

Method to abort a running Request. This can be useful if CUI.XHR is used for uploading big files and the user decides to cancel the upload.

## start\(\)

After creating the CUI.XHR, the request needs to be initiated, using **start**. This returns a CUI.Promise. The Promise is **resolved** if the request succeeds, **rejected** if it fails. During an upload, the Promise progresses and calls back **notify**.

## status\(\)

Returns the current status of the CUI.XHR. There are the following possibilities:

| Status | Text |
| :--- | :--- |
| -1 | abort |
| -2 | timeout |
| -3 | network failure |

The Status &lt; 0 are CUI.XHR status, Status &gt;= 0 are HTTP response status of the underlying XMLHttpRequest.

## statusText\(\)

Returns the text of the current status.

## readyState\(\)

Returns the ready state text of the underlying XMLHttpRequest.

| Status | Text |
| :--- | :--- |
| 0 | UNSENT |
| 1 | OPENED |
| 2 | HEADERS\_RECEIVED |
| 3 | LOADING |
| 4 | DONE |

### response\(\)

Retrieve the response of the finished request.

### getXHR\(\)

Returns the underlying XMLHttpRequest instance.

### isSuccess\(\)

Returns _true_, if the request is considered to be a success. States &gt;= 200, &lt; 300 and == 304 are considered to be a success. For files \(using the file:///\) URL, success is _true_ if all ready states has been seen.

### getAllResponseHeaders\(\)

Returns a PlainObject of all response headers. The keys are lower cased, the values are inside an Array.

### getResponseHeader\(key\)

Returns the first item of the given **key** from the response headers.

