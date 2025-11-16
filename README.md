# kmail

Kmail lets users share content to other users. It's like email without email!

## Sender API

### `POST /share/payable/from/<sender>/to/<receiver>`

#### Headers

Content-Type: <content type, for example application/pdf>

#### Example request

```
POST /share/payable/from/1/to/2
Content-Type: application/pdf
```

#### Example response

`{"result": "success"}`

### `POST /share/nonpayable/from/<sender>/to/<receiver>`

#### Example request

```
POST /share/nonpayable/from/1/to/2
Content-Type: application/pdf
```

#### Example response

`{"result": "success"}`

## Consumer API

### `GET /share/<receiver>`

Get a list of shares to this receiver.

#### Example output

`GET /share/100`

```
[
  {
    "id": "1",
    "content-type": "application/pdf",
    "paid": false,
    "links": {"download": "/share/100/1"}
  }
]
```

### `GET /share/<receiver>/<share>`

Get a particular share.

## Deploying
