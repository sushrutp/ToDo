# ToDo

# ToDo Web App

ToDo App

[![CI to Docker Hub](https://github.com/sushrutp/ToDo/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/sushrutp/ToDo/actions/workflows/main.yml)

ToDo web app to add todo list and finish it.

# Basic Overview
Todo App lets you add , delete ,complete the todo items.

Its a simple web interface

[![CI to Docker Hub]()]()

## Appendix

Any additional information goes here


## Installation

Install todo app

```bash

git clone https://github.com/sushrutp/ToDo.git

cd Todo/

docker-compose -f docker-compose.yml up --build

```

OR 

using docker hub 

```
docker pull smarthacker/todo

docker run -it smarthacker/todo plackup -p 5000 bin/app.psgi

```

## Running Tests

To run tests, run the following command

```bash

docker pull smarthacker/todo

docker run -it smarthacker/todo prove -vr t/

```

Output

```
All tests successful.
Files=5, Tests=202,  4 wallclock secs ( 0.08 usr  0.00 sys +  2.44 cusr  0.23 csys =  2.75 CPU)
Result: PASS
```

## API Reference

#### Get all todo

```http
  GET /api/v1/todo
```

Example

```bash
curl --location --request GET 'http://localhost:3000/api/v1/todo'

```


output

```
[
    {
        "status": "",
        "description": "TODO_item_1",
        "id": "ref-kmpekxl"
    },
    {
        "status": "",
        "id": "ref-offoyyf",
        "description": "TODO_item_2"
    },
    {
        "status": "",
        "description": "TODO_item_3",
        "id": "ref-bmrfllg"
    },
    {
        "id": "ref-bekzkfe",
        "description": "TODO_item_finished",
        "status": "completed"
    }
]
```

#### Post todo item

```http
  POST /api/v1/todo
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `description`      | `string` | **Required** to create the todo item |


Example

```bash
curl --location --request GET 'http://localhost:3000/api/v1/todo'

```

Example 

```bash
curl --location --request POST 'http://localhost:3000/api/v1/todo' \
--header 'Content-Type: application/json' \
--data-raw '{
    "description" : "Test-Description"
}'

```

output
```
{
    "reference_id": "ref-cjgtist"
}
```


#### complete todo item

```http
  PUT /api/v1/todo/
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `description`      | `string` | **Required** to create the todo item |


Example

```bash
curl --location --request GET 'http://localhost:3000/api/v1/todo'

```

Example 

```bash
curl --location --request PUT 'localhost:3000/api/v1/todo/ref-cjgtist'

```

output
```
{
    "reference_id": "ref-cjgtist"
}
```

#### delete todo item

```http
  DELETE /api/v1/todo/:{reference_id}
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `reference_id`      | `string` | **Required** to update item as completed |


Example

```bash
curl --location --request GET 'http://localhost:3000/api/v1/todo/ref-lxqmyzio'

```

Example 

```bash
curl --location --request DELETE 'localhost:3000/api/v1/todo/ref-cjgtist'

```

output
```
When success
{
    "result": 1
}

When not found 
{
    "result": 0
}
```
## Architect

* Framework Used 
   * perl Dancer2 (light weight frame work)

   * (since todo app demands a simple crud api and single page application)

   * (blazing fast startup)

   * (Flexible, scalable)

   * (low dependancy on library)

* Database Used
    - sqlite3 
    (light weight and high in features) [more feature](https://www.sqlite.org/features.html)

* Technology

    - [Perl5](https://www.perl.org/)
    - [Javascript](https://www.javascript.com/)
    - [Jquery](https://jquery.com/)
    - [template toolkit](http://www.template-toolkit.org/)
    - [sqlite3](https://www.sqlite.org/index.html)
    - [Dancer2](https://perldancer.org/)
    - [Docker](https://www.docker.com/)
    - [Github](https://github.com/)

* CI/CD
    - [GitHub](https://github.com/features/actions)

* Unit Testing
    - [prove](https://perldoc.perl.org/prove)

## Authors

- [@sushrutp](https://www.github.com/sushrutp)


## License

[MIT](https://choosealicense.com/licenses/mit/)

MIT License

Copyright (c) 2021

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.