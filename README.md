Graduate Simulator
==================

[![Build Status](https://travis-ci.org/dnsdhrj/graduate-adventure.svg)](https://travis-ci.org/dnsdhrj/graduate-adventure)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/dnsdhrj/graduate-adventure?branch=master&svg=true)](https://ci.appveyor.com/project/dnsdhrj/graduate-adventure)

Graduate simulator for SNU students

### Recommended Requirements

  - Python ≥ 3.5
  - node ≥ 6.x
  - npm ≥ 5

### Installation

```bash
# Prepare virtualenv
python3 -m venv .venv
source .venv/bin/activate

# Install Dependencies
pip install -r requirements.txt
npm install --save-dev
```

### Running

#### Backend

```bash
python backend/manage.py runserver
```

#### Frontend

``` bash
# serve with hot reload at localhost:3000
$ npm run dev

# build for production and launch server
$ npm run build
$ npm start

# generate static project
$ npm run generate
```

==================

[MIT License](LICENSE)
