Graduate Simulator
==================

[![Build Status](https://travis-ci.org/LastOne817/graduate-adventure.svg)](https://travis-ci.org/LastOne817/graduate-adventure)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/LastOne817/graduate-adventure?branch=master&svg=true)](https://ci.appveyor.com/project/LastOne817/graduate-adventure)

Graduate simulator for SNU students

### Recommended Requirements

  - Python ≥ 3.5
  - node ≥ 6.x

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
python3 backend/manage.py runserver
```

#### Frontend

```bash
npm start
# http://localhost:8080 to access
```

==================

[MIT License](LICENSE)
