module Tests.Pages.Test exposing (tests)

import Test exposing (Test, describe)
import Tests.Pages.Prototype


tests : Test
tests = 
  describe "Pages"
    [ Tests.Pages.Prototype.tests
    ]