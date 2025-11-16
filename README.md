# kmail

Kmail lets users send content to other users. It's like email without email!

## Developing

Use Erlang/OTP 28.1.1. Riak is used for persistence and needs to be running at the local machine. Start the server: `rebar3 shell`. Access the endpoints at http://localhost:4000.

### Auto code reloading

Start the app with `rebar3 shell --eval "sync:go()."`

### Test watcher

`find src test priv rebar.config | entr rebar3 eunit`

### Watch for file changes and auto format

`find src test priv rebar.config | entr rebar3 fmt -w`

## Terminology

- Sender: A user that can send a *package* to a *recipient* via their *mailbox*.
- Package: A collection of data that resides in a *mailbox*. It has a *sender*,
a *recipient*, which owns the mailbox, a *file type*, a *payload* of that type,
and *payable* information.
- Mailbox: A collection of packages that have been sent to a *recipient*. Each
recipient has one mailbox.
- Recipient: A user that has registered a *mailbox*. The recipient also has a
*password* which they need to use for accessing the mailbox.
- Password: A secure string that the recipient receives when registering a
*mailbox*.

## Sender API

### `POST /mailbox/<receiver>/package/from/<sender>`

#### Headers

Content-Type: <content type, for example application/pdf>

#### Example request

```
POST /mailbox/89A523DC-56D2-4C0B-AFA1-4B78D9FA824B/package/from/kalle
Content-Type: application/pdf
```

#### Example response

`{"result": "success"}`

### `POST /mailbox/<receiver>/package/from/<sender>/payable`

#### Example request

```
POST /mailbox/89A523DC-56D2-4C0B-AFA1-4B78D9FA824B/package/from/kalle/payable
Content-Type: application/pdf
```

#### Example response

`{"result": "success"}`

## Consumer API

### `POST /mailbox`

Register a new receiver ("mailbox").

#### Example output

`POST /mailbox`

```
{
  "id": "89A523DC-56D2-4C0B-AFA1-4B78D9FA824B",
  "password": "ggqiqyvzisplodhkeravcdzwfwxuhduyrbxzlbbgnlzrylwz"
}
```

### `GET /mailbox/<receiver>/packages`

#### Headers

`Password: ggqiqyvzisplodhkeravcdzwfwxuhduyrbxzlbbgnlzrylwz`

Get a list of packages for this receiver.

#### Example output

`GET /mailbox/89A523DC-56D2-4C0B-AFA1-4B78D9FA824B`

```
[
  {
    "id": "1",
    "fileType": "application/pdf",
    "sender": "kalle",
    "paid": false,
    "links": {"download": "/mailbox/100/packages/1"}
  }
]
```

### `GET /mailbox/<receiver>/packages/<package>`

Get a package payload.

## Deploying

`rebar3 release` generates a release at `_build/default/rel/kmail`

## Roadmap

There are a few outstanding items that need discovery to clarify the business case and requirements.

- Senders could be authenticated somehow. Company K might need some backoffice
interface to provision allowed senders, or they could be able to self-provision.
- There should be a payment solution by which senders or recipients can pay for
packages before the packages are released.
- We should enforce a low maximum file size or consider using something other
than Riak for storing the package payloads, as Riak does not perform
well when storing large objects.
