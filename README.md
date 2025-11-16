# kmail

Kmail lets users share content to other users. It's like email without email!

## Sender API

### `POST /share/payable/from/<sender>/to/<receiver>`

#### Headers

Content-Type: <content type, for example application/pdf>

#### Example request

```
POST /share/payable/from/1/to/89A523DC-56D2-4C0B-AFA1-4B78D9FA824B
Content-Type: application/pdf
```

#### Example response

`{"result": "success"}`

### `POST /share/nonpayable/from/<sender>/to/<receiver>`

#### Example request

```
POST /share/nonpayable/from/1/to/89A523DC-56D2-4C0B-AFA1-4B78D9FA824B
Content-Type: application/pdf
```

#### Example response

`{"result": "success"}`

## Consumer API

### `POST /consumer`

Register a consumer

#### Example output

`POST /consumer`

```
{
  "id": "89A523DC-56D2-4C0B-AFA1-4B78D9FA824B",
  "password": "ggqiqyvzisplodhkeravcdzwfwxuhduyrbxzlbbgnlzrylwz"
}
```

### `GET /share/<receiver>`

#### Headers

`Password: ggqiqyvzisplodhkeravcdzwfwxuhduyrbxzlbbgnlzrylwz`

Get a list of shares to this receiver.

#### Example output

`GET /share/89A523DC-56D2-4C0B-AFA1-4B78D9FA824B`

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

## Developer tooling

### Auto code reloading

Start the app with `rebar3 shell --eval "sync:go()."`
