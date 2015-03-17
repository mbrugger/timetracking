Rest API Documentation for timetracking clients
===
Login
---
`POST /api/v1/login`

using **http basic auth** header for username / password

result:

    {
      token: "some_token"
    }

**Sample:**

`curl -v -i -d "" --user "m@brugger.eu:test1234" -H "Content-Type: application/json" -X POST http://localhost:3000/api/v1/login`


    {
      token: "somerandomtoken"
    }


Retrieve Status
---
`GET /api/v1/status`

HTTP Header "X-API-AUTH-TOKEN: $TOKEN"

result:

	{
    status: "running|stopped",
    duration: "hh:mm",
    pause_duration: "hh:mm"
  }

**Sample:**

`curl -v --header "X-API-AUTH-TOKEN: e413t4Kxz7ysXyxY3w9F" http://localhost:3000/api/v1/status`

    {
      status: "running",
      duration: "0:03",
      pause_duration: "0:10"
    }

Start Timer
---
`POST /api/v1/status/start`

HTTP Header "X-API-AUTH-TOKEN: $TOKEN"

result:

    {
      status: "running|stopped",
      duration: "hh:mm",
      pause_duration: "hh:mm"
    }

**Sample:**

`curl -v -d "" --header "X-API-AUTH-TOKEN: e413t4Kxz7ysXyxY3w9F" http://localhost:3000/api/v1/status/start`


    {
      status: "running",
      duration: "0:03",
      pause_duration: "0:10"
    }

Stop Timer
---
`POST /api/v1/status/stop`

HTTP Header "X-API-AUTH-TOKEN: $TOKEN"

result:

    {
      status: "running|stopped",
      duration: "hh:mm",
      pause_duration: "hh:mm"
    }

**Sample:**

`curl -v -d "" --header "X-API-AUTH-TOKEN: e413t4Kxz7ysXyxY3w9F" http://localhost:3000/api/v1/status/start`

    {
      status: "running",
      duration: "0:03",
      pause_duration: "0:10"
    }
